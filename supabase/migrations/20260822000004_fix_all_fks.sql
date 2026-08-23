-- Fix all FK constraints to reference auth.users instead of custom users table

-- SCHEDULES: fix user_id FK
DO $blk$ BEGIN
  ALTER TABLE schedules DROP CONSTRAINT IF EXISTS schedules_user_id_fkey;
  ALTER TABLE schedules ADD CONSTRAINT schedules_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;

-- PEER_ROOMS: fix created_by FK
DO $blk$ BEGIN
  ALTER TABLE peer_rooms DROP CONSTRAINT IF EXISTS peer_rooms_created_by_fkey;
  ALTER TABLE peer_rooms ADD CONSTRAINT peer_rooms_created_by_fkey 
    FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE CASCADE;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;

-- PEER_ROOM_MEMBERS: fix user_id FK
DO $blk$ BEGIN
  ALTER TABLE peer_room_members DROP CONSTRAINT IF EXISTS peer_room_members_user_id_fkey;
  ALTER TABLE peer_room_members ADD CONSTRAINT peer_room_members_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;

-- POMODORO_SESSIONS: fix user_id FK
DO $blk$ BEGIN
  ALTER TABLE pomodoro_sessions DROP CONSTRAINT IF EXISTS pomodoro_sessions_user_id_fkey;
  ALTER TABLE pomodoro_sessions ADD CONSTRAINT pomodoro_sessions_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;

-- NOTES: fix user_id FK
DO $blk$ BEGIN
  ALTER TABLE notes DROP CONSTRAINT IF EXISTS notes_user_id_fkey;
  ALTER TABLE notes ADD CONSTRAINT notes_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;

-- HABITS: fix user_id FK
DO $blk$ BEGIN
  ALTER TABLE habits DROP CONSTRAINT IF EXISTS habits_user_id_fkey;
  ALTER TABLE habits ADD CONSTRAINT habits_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;

-- HEATMAP_ENTRIES: fix user_id FK
DO $blk$ BEGIN
  ALTER TABLE heatmap_entries DROP CONSTRAINT IF EXISTS heatmap_entries_user_id_fkey;
  ALTER TABLE heatmap_entries ADD CONSTRAINT heatmap_entries_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;

-- USER_TOPIC_PROGRESS: fix user_id FK
DO $blk$ BEGIN
  ALTER TABLE user_topic_progress DROP CONSTRAINT IF EXISTS user_topic_progress_user_id_fkey;
  ALTER TABLE user_topic_progress ADD CONSTRAINT user_topic_progress_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;

-- USER_BADGES: fix user_id FK
DO $blk$ BEGIN
  ALTER TABLE user_badges DROP CONSTRAINT IF EXISTS user_badges_user_id_fkey;
  ALTER TABLE user_badges ADD CONSTRAINT user_badges_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;

-- USER_MILESTONES: fix user_id FK
DO $blk$ BEGIN
  ALTER TABLE user_milestones DROP CONSTRAINT IF EXISTS user_milestones_user_id_fkey;
  ALTER TABLE user_milestones ADD CONSTRAINT user_milestones_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;

-- USER_TEST_SUBMISSIONS: fix user_id FK
DO $blk$ BEGIN
  ALTER TABLE user_test_submissions DROP CONSTRAINT IF EXISTS user_test_submissions_user_id_fkey;
  ALTER TABLE user_test_submissions ADD CONSTRAINT user_test_submissions_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;

-- PROGRESS_CARDS: fix user_id FK
DO $blk$ BEGIN
  ALTER TABLE progress_cards DROP CONSTRAINT IF EXISTS progress_cards_user_id_fkey;
  ALTER TABLE progress_cards ADD CONSTRAINT progress_cards_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;

-- LEADERBOARD_ENTRIES: fix user_id FK
DO $blk$ BEGIN
  ALTER TABLE leaderboard_entries DROP CONSTRAINT IF EXISTS leaderboard_entries_user_id_fkey;
  ALTER TABLE leaderboard_entries ADD CONSTRAINT leaderboard_entries_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;

-- YOUTUBE_LINKS: fix added_by FK
DO $blk$ BEGIN
  ALTER TABLE youtube_links DROP CONSTRAINT IF EXISTS youtube_links_added_by_fkey;
  ALTER TABLE youtube_links ADD CONSTRAINT youtube_links_added_by_fkey 
    FOREIGN KEY (added_by) REFERENCES auth.users(id) ON DELETE SET NULL;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;
