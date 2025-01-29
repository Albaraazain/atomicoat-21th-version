#!/bin/bash

# Create backup directory if it doesn't exist
mkdir -p supabase/backups

# Tables to backup
TABLES=("users" "machines" "machine_assignments" "recipes" "recipe_steps")

# Backup each table
for table in "${TABLES[@]}"
do
    echo "Backing up $table..."
    supabase db dump \
        --db-url "postgresql://postgres:postgres@db.yceyfsqusdmcwgkwxcnt.supabase.co:5432/postgres" \
        -f "supabase/backups/${table}_backup.sql" \
        --data-only \
        --table "public.${table}"
done

echo "Backup completed!" 