DO $blk$ BEGIN
  ALTER TABLE schedules ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Users can CRUD own schedules" ON schedules FOR ALL USING (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  ALTER TABLE schedule_items ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Users can manage own schedule items" ON schedule_items FOR ALL USING (schedule_id IN (SELECT id FROM schedules WHERE user_id = auth.uid()));
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  ALTER TABLE peer_rooms ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Anyone can read active rooms" ON peer_rooms FOR SELECT USING (is_active = true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Authenticated users can create rooms" ON peer_rooms FOR INSERT WITH CHECK (auth.uid() = created_by);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Room creator can update room" ON peer_rooms FOR UPDATE USING (auth.uid() = created_by);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  ALTER TABLE peer_room_members ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Users can read room members" ON peer_room_members FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Authenticated users can join rooms" ON peer_room_members FOR INSERT WITH CHECK (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Users can leave rooms" ON peer_room_members FOR DELETE USING (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  ALTER TABLE pomodoro_sessions ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Users can CRUD own sessions" ON pomodoro_sessions FOR ALL USING (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  ALTER TABLE notes ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Users can CRUD own notes" ON notes FOR ALL USING (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  ALTER TABLE habits ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Users can CRUD own habits" ON habits FOR ALL USING (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  ALTER TABLE habit_entries ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Users can manage own habit entries" ON habit_entries FOR ALL USING (habit_id IN (SELECT id FROM habits WHERE user_id = auth.uid()));
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  ALTER TABLE user_topic_progress ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Users can manage own progress" ON user_topic_progress FOR ALL USING (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  ALTER TABLE user_badges ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Users can read own badges" ON user_badges FOR SELECT USING (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "System can award badges" ON user_badges FOR INSERT WITH CHECK (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Users can pin unpin own badges" ON user_badges FOR UPDATE USING (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  ALTER TABLE user_milestones ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Users can read own milestones" ON user_milestones FOR SELECT USING (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  ALTER TABLE heatmap_entries ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Users can CRUD own heatmap" ON heatmap_entries FOR ALL USING (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  ALTER TABLE user_test_submissions ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Users can read own submissions" ON user_test_submissions FOR SELECT USING (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Users can create own submissions" ON user_test_submissions FOR INSERT WITH CHECK (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  ALTER TABLE user_test_answers ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Users can read own answers" ON user_test_answers FOR SELECT USING (submission_id IN (SELECT id FROM user_test_submissions WHERE user_id = auth.uid()));
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Users can create own answers" ON user_test_answers FOR INSERT WITH CHECK (submission_id IN (SELECT id FROM user_test_submissions WHERE user_id = auth.uid()));
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  ALTER TABLE leaderboards ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Anyone can read leaderboards" ON leaderboards FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  ALTER TABLE leaderboard_entries ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Anyone can read leaderboard entries" ON leaderboard_entries FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  ALTER TABLE exams ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Anyone can read exams" ON exams FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  ALTER TABLE subjects ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Anyone can read subjects" ON subjects FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  ALTER TABLE modules ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Anyone can read modules" ON modules FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  ALTER TABLE chapters ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Anyone can read chapters" ON chapters FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  ALTER TABLE topics ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Anyone can read topics" ON topics FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  ALTER TABLE tests ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Anyone can read tests" ON tests FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  ALTER TABLE test_questions ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Anyone can read test questions" ON test_questions FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  ALTER TABLE badges ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Anyone can read badges" ON badges FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  ALTER TABLE milestones ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Anyone can read milestones" ON milestones FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  ALTER TABLE past_papers ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Anyone can read past papers" ON past_papers FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  ALTER TABLE youtube_links ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Anyone can read youtube links" ON youtube_links FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Authenticated users can add youtube links" ON youtube_links FOR INSERT WITH CHECK (auth.uid() = added_by);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
DO $blk$ BEGIN
  ALTER TABLE progress_cards ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $blk$;
DO $blk$ BEGIN
  CREATE POLICY "Users can read own progress cards" ON progress_cards FOR SELECT USING (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $blk$;
