-- Fix users table for Supabase Auth integration

ALTER TABLE users ALTER COLUMN password_hash DROP NOT NULL;
ALTER TABLE users ALTER COLUMN password_hash SET DEFAULT '';

DO $blk$ BEGIN
  ALTER TABLE users ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Users can insert own row" ON users FOR INSERT WITH CHECK (auth.uid() = id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Users can read own row" ON users FOR SELECT USING (auth.uid() = id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Users can update own row" ON users FOR UPDATE USING (auth.uid() = id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;

DO $blk$ BEGIN
  ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Profiles can insert own" ON user_profiles FOR INSERT WITH CHECK (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Profiles can read own" ON user_profiles FOR SELECT USING (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Profiles can update own" ON user_profiles FOR UPDATE USING (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
