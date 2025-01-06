-- Enable pgcrypto extension for password hashing
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Backup existing tables
CREATE TABLE IF NOT EXISTS users_backup AS SELECT * FROM users;
CREATE TABLE IF NOT EXISTS machines_backup AS SELECT * FROM machines;

-- Drop existing foreign key constraints if any
DO $$
BEGIN
    -- Drop any existing constraints
    EXECUTE (
        SELECT string_agg('ALTER TABLE ' || table_name || ' DROP CONSTRAINT ' || constraint_name, '; ')
        FROM information_schema.table_constraints
        WHERE constraint_type = 'FOREIGN KEY'
        AND table_name IN ('users', 'machines')
    );
EXCEPTION
    WHEN undefined_object THEN NULL;
END $$;

-- Create new machine_assignments table
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

-- Add status column to users if not exists
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'users' AND column_name = 'status'
    ) THEN
        ALTER TABLE users ADD COLUMN status TEXT DEFAULT 'pending';
    END IF;
END $$;

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
    ADD CONSTRAINT fk_machine_assignments_machine_id
    FOREIGN KEY (machine_id)
    REFERENCES machines(id)
    ON DELETE CASCADE;

ALTER TABLE machine_assignments
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