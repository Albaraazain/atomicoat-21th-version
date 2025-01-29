#!/bin/bash

# Tables to restore in specific order due to dependencies
TABLES=("users" "machines" "machine_assignments" "recipes" "recipe_steps")

# Restore each table
for table in "${TABLES[@]}"
do
    if [ -f "supabase/backups/${table}_backup.sql" ]; then
        echo "Restoring $table..."
        # Clear existing data
        supabase db reset --db-url "postgresql://postgres:postgres@127.0.0.1:54322/postgres" --table "public.${table}"
        # Restore backup
        supabase db restore \
            --db-url "postgresql://postgres:postgres@127.0.0.1:54322/postgres" \
            -f "supabase/backups/${table}_backup.sql"
    else
        echo "Backup file for $table not found!"
    fi
done

echo "Restore completed!" 