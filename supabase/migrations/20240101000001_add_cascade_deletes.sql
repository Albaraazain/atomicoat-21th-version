-- First, drop existing foreign key constraints
ALTER TABLE recipe_steps DROP CONSTRAINT IF EXISTS recipe_steps_recipe_id_fkey;
ALTER TABLE recipes DROP CONSTRAINT IF EXISTS recipes_created_by_fkey;
ALTER TABLE machine_assignments DROP CONSTRAINT IF EXISTS machine_assignments_user_id_fkey;

-- Recreate the constraints with CASCADE
ALTER TABLE recipe_steps
  ADD CONSTRAINT recipe_steps_recipe_id_fkey
  FOREIGN KEY (recipe_id)
  REFERENCES recipes(id)
  ON DELETE CASCADE;

ALTER TABLE recipes
  ADD CONSTRAINT recipes_created_by_fkey
  FOREIGN KEY (created_by)
  REFERENCES users(id)
  ON DELETE CASCADE;

ALTER TABLE machine_assignments
  ADD CONSTRAINT machine_assignments_user_id_fkey
  FOREIGN KEY (user_id)
  REFERENCES users(id)
  ON DELETE CASCADE;