#!/bin/bash

# Create backup directory if it doesn't exist
mkdir -p supabase/backups

# Set environment variables
export SUPABASE_ACCESS_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InljZXlmc3F1c2RtY3dna3d4Y250Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczNTk5NjM3NSwiZXhwIjoyMDUxNTcyMzc1fQ.k-r8lYAPhf-wbB7jZ_mwFQezBK4-AytiesjoD-OqWnU"
export REMOTE_DB_URL="postgresql://postgres:postgres@db.yceyfsqusdmcwgkwxcnt.supabase.co:6543/postgres"
export LOCAL_DB_URL="postgresql://postgres:postgres@127.0.0.1:54322/postgres"

# Tables to sync
TABLES=("users" "machines" "machine_assignments" "recipes" "recipe_steps")

# Function to fetch data from remote table
fetch_remote_data() {
    local table=$1
    echo "Fetching data from remote $table..."
    PGPASSWORD=postgres psql "$REMOTE_DB_URL" -t -A -c "SELECT json_agg(t) FROM public.$table t;" > "supabase/backups/${table}.json"
}

# Function to insert data into local table
insert_local_data() {
    local table=$1
    echo "Inserting data into local $table..."
    # Clear existing data
    PGPASSWORD=postgres psql "$LOCAL_DB_URL" -c "TRUNCATE TABLE public.$table CASCADE;"
    # Insert new data
    if [ -s "supabase/backups/${table}.json" ]; then
        PGPASSWORD=postgres psql "$LOCAL_DB_URL" -c "\copy public.$table FROM 'supabase/backups/${table}.json' WITH (FORMAT json, FREEZE);"
    fi
}

# Main sync process
for table in "${TABLES[@]}"
do
    fetch_remote_data "$table"
    insert_local_data "$table"
done

echo "Database sync completed!" 