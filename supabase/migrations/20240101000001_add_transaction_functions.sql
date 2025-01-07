-- Create transaction management functions
create or replace function begin_transaction()
returns void
language plpgsql
security definer
as $$
begin
  -- Start a new transaction
  -- Note: This is mostly for consistency in the API,
  -- as Supabase automatically handles transactions
  return;
end;
$$;

create or replace function commit_transaction()
returns void
language plpgsql
security definer
as $$
begin
  -- Commit the current transaction
  -- Note: This is mostly for consistency in the API,
  -- as Supabase automatically handles transactions
  return;
end;
$$;

create or replace function rollback_transaction()
returns void
language plpgsql
security definer
as $$
begin
  -- Rollback the current transaction
  -- Note: This is mostly for consistency in the API,
  -- as Supabase automatically handles transactions
  return;
end;
$$;

-- Add cascade delete triggers for user deletion
create or replace function handle_user_deletion()
returns trigger
language plpgsql
security definer
as $$
begin
  -- Delete all recipes created by the user
  delete from recipes where created_by = old.id;

  -- Delete all machine assignments
  delete from machine_assignments where user_id = old.id;

  return old;
end;
$$;

create trigger before_user_delete
  before delete on users
  for each row
  execute function handle_user_deletion();