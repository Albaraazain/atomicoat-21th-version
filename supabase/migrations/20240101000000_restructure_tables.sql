-- Enable pgcrypto extension for password hashing
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Create users table if it doesn't exist
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    role TEXT NOT NULL,
    status TEXT DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create machines table if it doesn't exist
CREATE TABLE IF NOT EXISTS machines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    serial_number TEXT UNIQUE NOT NULL,
    location TEXT NOT NULL,
    machine_type TEXT NOT NULL,
    model TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'inactive',
    install_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create machine_assignments table if it doesn't exist
CREATE TABLE IF NOT EXISTS machine_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    machine_id UUID NOT NULL,
    user_id UUID NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('machineadmin', 'operator')),
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(machine_id, user_id)
);

-- Create initial superadmin if doesn't exist
DO $$
DECLARE
    auth_uid UUID;
BEGIN
    -- First, check if superadmin exists in auth.users
    IF NOT EXISTS (
        SELECT 1 FROM auth.users WHERE email = 'superadmin@atomicoat.com'
    ) THEN
        -- Create the user in auth.users
        INSERT INTO auth.users (
            instance_id,
            id,
            aud,
            role,
            email,
            encrypted_password,
            raw_app_meta_data,
            raw_user_meta_data,
            created_at,
            updated_at
        )
        VALUES (
            '00000000-0000-0000-0000-000000000000',
            gen_random_uuid(),
            'authenticated',
            'authenticated',
            'superadmin@atomicoat.com',
            crypt('password', gen_salt('bf')),
            '{"provider": "email", "providers": ["email"]}'::jsonb,
            '{"email_verified": true}'::jsonb,
            NOW(),
            NOW()
        )
        RETURNING id INTO auth_uid;

        -- Create corresponding entry in public.users
        INSERT INTO public.users (
            id,
            email,
            role,
            status,
            created_at,
            updated_at
        )
        VALUES (
            auth_uid,
            'superadmin@atomicoat.com',
            'superadmin',
            'active',
            NOW(),
            NOW()
        );
    END IF;
END $$;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_machine_assignments_machine_id ON machine_assignments(machine_id);
CREATE INDEX IF NOT EXISTS idx_machine_assignments_user_id ON machine_assignments(user_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_machines_serial_number ON machines(serial_number);

-- Add foreign key constraints
ALTER TABLE machine_assignments
    DROP CONSTRAINT IF EXISTS fk_machine_assignments_machine_id,
    ADD CONSTRAINT fk_machine_assignments_machine_id
    FOREIGN KEY (machine_id)
    REFERENCES machines(id)
    ON DELETE CASCADE;

ALTER TABLE machine_assignments
    DROP CONSTRAINT IF EXISTS fk_machine_assignments_user_id,
    ADD CONSTRAINT fk_machine_assignments_user_id
    FOREIGN KEY (user_id)
    REFERENCES users(id)
    ON DELETE CASCADE;

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_machines_updated_at ON machines;
CREATE TRIGGER update_machines_updated_at
    BEFORE UPDATE ON machines
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_machine_assignments_updated_at ON machine_assignments;
CREATE TRIGGER update_machine_assignments_updated_at
    BEFORE UPDATE ON machine_assignments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Keep backup tables for safety
-- You can drop them later with:
-- DROP TABLE users_backup;
-- DROP TABLE machines_backup;