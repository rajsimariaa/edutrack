-- Drop the FK constraint that's causing the error
-- user_profiles.user_id should reference auth.users, not custom users table
ALTER TABLE user_profiles DROP CONSTRAINT IF EXISTS user_profiles_user_id_fkey;

-- Re-add FK to reference Supabase Auth users directly
ALTER TABLE user_profiles ADD CONSTRAINT user_profiles_user_id_fkey 
  FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- Also make sure RLS allows profile operations
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  DROP POLICY IF EXISTS "Profiles can insert own" ON user_profiles;
  CREATE POLICY "Profiles can insert own" ON user_profiles
    FOR INSERT WITH CHECK (auth.uid() = user_id);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$ BEGIN
  DROP POLICY IF EXISTS "Profiles can read own" ON user_profiles;
  CREATE POLICY "Profiles can read own" ON user_profiles
    FOR SELECT USING (auth.uid() = user_id);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$ BEGIN
  DROP POLICY IF EXISTS "Profiles can update own" ON user_profiles;
  CREATE POLICY "Profiles can update own" ON user_profiles
    FOR UPDATE USING (auth.uid() = user_id);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
