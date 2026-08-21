-- EduTrack Database Schema v1.2.0
-- PostgreSQL / Supabase compatible
-- Run this in order: tables first, then indexes

-- ============================================================
-- 1. AUTH & PROFILE
-- ============================================================

CREATE TABLE IF NOT EXISTS users (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email           VARCHAR(255) UNIQUE NOT NULL,
    phone           VARCHAR(20) UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    full_name       VARCHAR(150) NOT NULL,
    avatar_url      TEXT,
    is_verified     BOOLEAN DEFAULT FALSE,
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_profiles (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    date_of_birth   DATE,
    city            VARCHAR(100),
    institution     VARCHAR(200),
    exam_category   VARCHAR(50) NOT NULL,
    target_year     SMALLINT,
    daily_study_hrs NUMERIC(3,1),
    preferred_start TIME,
    social_visibility BOOLEAN DEFAULT TRUE,
    onboarding_step SMALLINT DEFAULT 0,
    profile_pct     NUMERIC(5,2) DEFAULT 0.00,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 2. SYLLABUS & PROGRESS
-- ============================================================

CREATE TABLE IF NOT EXISTS exams (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(100) NOT NULL,
    code            VARCHAR(20) UNIQUE NOT NULL,
    category        VARCHAR(50) NOT NULL,
    description     TEXT,
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS subjects (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exam_id         UUID NOT NULL REFERENCES exams(id) ON DELETE CASCADE,
    name            VARCHAR(200) NOT NULL,
    code            VARCHAR(30),
    display_order   SMALLINT DEFAULT 0,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS modules (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subject_id      UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    name            VARCHAR(200) NOT NULL,
    description     TEXT,
    display_order   SMALLINT DEFAULT 0,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS chapters (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module_id       UUID NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
    name            VARCHAR(200) NOT NULL,
    description     TEXT,
    display_order   SMALLINT DEFAULT 0,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS topics (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chapter_id      UUID NOT NULL REFERENCES chapters(id) ON DELETE CASCADE,
    name            VARCHAR(200) NOT NULL,
    description     TEXT,
    display_order   SMALLINT DEFAULT 0,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_topic_progress (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    topic_id        UUID NOT NULL REFERENCES topics(id) ON DELETE CASCADE,
    status          VARCHAR(20) DEFAULT 'not_started'
                        CHECK (status IN ('not_started', 'in_progress', 'mastered')),
    started_at      TIMESTAMPTZ,
    mastered_at     TIMESTAMPTZ,
    updated_at      TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, topic_id)
);

-- ============================================================
-- 3. MILESTONES & BADGES
-- ============================================================

CREATE TABLE IF NOT EXISTS badges (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(100) NOT NULL,
    slug            VARCHAR(100) UNIQUE NOT NULL,
    description     TEXT,
    icon_url        TEXT,
    category        VARCHAR(50) NOT NULL,
    rarity_tier     VARCHAR(20) DEFAULT 'common'
                        CHECK (rarity_tier IN ('common', 'rare', 'epic', 'legendary')),
    criteria_json   JSONB NOT NULL,
    points          INT DEFAULT 0,
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_badges (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    badge_id        UUID NOT NULL REFERENCES badges(id) ON DELETE CASCADE,
    unlocked_at     TIMESTAMPTZ DEFAULT NOW(),
    is_pinned       BOOLEAN DEFAULT FALSE,
    pin_order       SMALLINT CHECK (pin_order BETWEEN 1 AND 3),
    UNIQUE(user_id, badge_id),
    UNIQUE(user_id, pin_order)
);

CREATE TABLE IF NOT EXISTS milestones (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(100) NOT NULL,
    slug            VARCHAR(100) UNIQUE NOT NULL,
    category        VARCHAR(50) NOT NULL,
    criteria_json   JSONB NOT NULL,
    badge_id        UUID REFERENCES badges(id),
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_milestones (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    milestone_id    UUID NOT NULL REFERENCES milestones(id) ON DELETE CASCADE,
    unlocked_at     TIMESTAMPTZ DEFAULT NOW(),
    eval_payload    JSONB,
    UNIQUE(user_id, milestone_id)
);

-- ============================================================
-- 4. SCHEDULE & TIMETABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS schedules (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title           VARCHAR(200),
    start_date      DATE NOT NULL,
    end_date        DATE NOT NULL,
    is_active       BOOLEAN DEFAULT TRUE,
    ai_generated    BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS schedule_items (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    schedule_id     UUID NOT NULL REFERENCES schedules(id) ON DELETE CASCADE,
    topic_id        UUID REFERENCES topics(id),
    title           VARCHAR(200) NOT NULL,
    scheduled_date  DATE NOT NULL,
    start_time      TIME,
    end_time        TIME,
    status          VARCHAR(20) DEFAULT 'pending'
                        CHECK (status IN ('pending', 'completed', 'missed', 'rescheduled')),
    original_date   DATE,
    priority        SMALLINT DEFAULT 1,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 5. WEEKLY DIAGNOSTIC TESTS
-- ============================================================

CREATE TABLE IF NOT EXISTS tests (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exam_id         UUID NOT NULL REFERENCES exams(id) ON DELETE CASCADE,
    title           VARCHAR(200) NOT NULL,
    description     TEXT,
    total_marks     INT NOT NULL,
    duration_mins   INT NOT NULL,
    marking_scheme  JSONB,
    week_number     SMALLINT,
    year            SMALLINT,
    is_published    BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS test_questions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    test_id         UUID NOT NULL REFERENCES tests(id) ON DELETE CASCADE,
    topic_id        UUID REFERENCES topics(id),
    question_text   TEXT NOT NULL,
    question_type   VARCHAR(20) DEFAULT 'mcq'
                        CHECK (question_type IN ('mcq', 'integer', 'assertion_reason')),
    options         JSONB NOT NULL,
    correct_option  VARCHAR(5) NOT NULL,
    marks           NUMERIC(4,1) NOT NULL,
    explanation     TEXT,
    display_order   SMALLINT DEFAULT 0,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_test_submissions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    test_id         UUID NOT NULL REFERENCES tests(id) ON DELETE CASCADE,
    score           NUMERIC(6,2),
    percentile      NUMERIC(5,2),
    rank_in_category INT,
    total_correct   SMALLINT,
    total_wrong     SMALLINT,
    total_unattempted SMALLINT,
    time_taken_mins SMALLINT,
    submitted_at    TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, test_id)
);

CREATE TABLE IF NOT EXISTS user_test_answers (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    submission_id   UUID NOT NULL REFERENCES user_test_submissions(id) ON DELETE CASCADE,
    question_id     UUID NOT NULL REFERENCES test_questions(id) ON DELETE CASCADE,
    selected_option VARCHAR(5),
    is_correct      BOOLEAN,
    marks_obtained  NUMERIC(4,1) DEFAULT 0
);

-- ============================================================
-- 6. FOCUS & PRODUCTIVITY
-- ============================================================

CREATE TABLE IF NOT EXISTS pomodoro_sessions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    topic_id        UUID REFERENCES topics(id),
    chapter_id      UUID REFERENCES chapters(id),
    duration_mins   SMALLINT NOT NULL DEFAULT 25,
    started_at      TIMESTAMPTZ NOT NULL,
    ended_at        TIMESTAMPTZ,
    status          VARCHAR(20) DEFAULT 'running'
                        CHECK (status IN ('running', 'completed', 'interrupted')),
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS notes (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    chapter_id      UUID NOT NULL REFERENCES chapters(id) ON DELETE CASCADE,
    topic_id        UUID REFERENCES topics(id),
    title           VARCHAR(200),
    content_md      TEXT NOT NULL DEFAULT '',
    is_pinned       BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS youtube_links (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chapter_id      UUID NOT NULL REFERENCES chapters(id) ON DELETE CASCADE,
    topic_id        UUID REFERENCES topics(id),
    video_url       TEXT NOT NULL,
    title           VARCHAR(300),
    channel_name    VARCHAR(200),
    upvotes         INT DEFAULT 0,
    added_by        UUID REFERENCES users(id),
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 7. GAMIFICATION & SOCIAL
-- ============================================================

CREATE TABLE IF NOT EXISTS heatmap_entries (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    activity_date   DATE NOT NULL,
    tasks_completed SMALLINT DEFAULT 0,
    focus_mins      SMALLINT DEFAULT 0,
    streak_count    SMALLINT DEFAULT 0,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, activity_date)
);

CREATE TABLE IF NOT EXISTS leaderboards (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exam_category   VARCHAR(50) NOT NULL,
    board_type      VARCHAR(30) NOT NULL
                        CHECK (board_type IN ('weekly', 'monthly', 'all_time')),
    week_number     SMALLINT,
    year            SMALLINT,
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS leaderboard_entries (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    leaderboard_id  UUID NOT NULL REFERENCES leaderboards(id) ON DELETE CASCADE,
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    score           NUMERIC(10,2) NOT NULL DEFAULT 0,
    rank            INT,
    pinned_badges   JSONB,
    updated_at      TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(leaderboard_id, user_id)
);

CREATE TABLE IF NOT EXISTS peer_rooms (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(150) NOT NULL,
    code            VARCHAR(10) UNIQUE NOT NULL,
    exam_category   VARCHAR(50) NOT NULL,
    created_by      UUID NOT NULL REFERENCES users(id),
    max_members     SMALLINT DEFAULT 10,
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS peer_room_members (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id         UUID NOT NULL REFERENCES peer_rooms(id) ON DELETE CASCADE,
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role            VARCHAR(20) DEFAULT 'member'
                        CHECK (role IN ('admin', 'member')),
    joined_at       TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(room_id, user_id)
);

CREATE TABLE IF NOT EXISTS progress_cards (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    card_type       VARCHAR(30) DEFAULT 'weekly'
                        CHECK (card_type IN ('weekly', 'milestone', 'streak')),
    payload_json    JSONB NOT NULL,
    image_url       TEXT,
    shared_at       TIMESTAMPTZ,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 8. RESOURCE VAULT & HABITS
-- ============================================================

CREATE TABLE IF NOT EXISTS past_papers (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exam_id         UUID NOT NULL REFERENCES exams(id) ON DELETE CASCADE,
    title           VARCHAR(300) NOT NULL,
    year            SMALLINT NOT NULL,
    term            VARCHAR(50),
    file_url        TEXT NOT NULL,
    file_type       VARCHAR(10) DEFAULT 'pdf',
    file_size_kb    INT,
    download_count  INT DEFAULT 0,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS habits (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name            VARCHAR(150) NOT NULL,
    frequency       VARCHAR(20) DEFAULT 'daily'
                        CHECK (frequency IN ('daily', 'weekly')),
    target_count    SMALLINT DEFAULT 1,
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS habit_entries (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    habit_id        UUID NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
    checkin_date    DATE NOT NULL,
    count           SMALLINT DEFAULT 1,
    note            TEXT,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(habit_id, checkin_date)
);

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_user_profiles_user ON user_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_category ON user_profiles(exam_category);

CREATE INDEX IF NOT EXISTS idx_subjects_exam ON subjects(exam_id);
CREATE INDEX IF NOT EXISTS idx_modules_subject ON modules(subject_id);
CREATE INDEX IF NOT EXISTS idx_chapters_module ON chapters(module_id);
CREATE INDEX IF NOT EXISTS idx_topics_chapter ON topics(chapter_id);

CREATE INDEX IF NOT EXISTS idx_utoic_progress_user ON user_topic_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_utoic_progress_topic ON user_topic_progress(topic_id);

CREATE INDEX IF NOT EXISTS idx_user_badges_user ON user_badges(user_id);
CREATE INDEX IF NOT EXISTS idx_user_badges_badge ON user_badges(badge_id);

CREATE INDEX IF NOT EXISTS idx_user_milestones_user ON user_milestones(user_id);

CREATE INDEX IF NOT EXISTS idx_schedules_user ON schedules(user_id);
CREATE INDEX IF NOT EXISTS idx_schedule_items_schedule ON schedule_items(schedule_id);
CREATE INDEX IF NOT EXISTS idx_schedule_items_date ON schedule_items(scheduled_date);
CREATE INDEX IF NOT EXISTS idx_schedule_items_status ON schedule_items(status);

CREATE INDEX IF NOT EXISTS idx_tests_exam ON tests(exam_id);
CREATE INDEX IF NOT EXISTS idx_test_questions_test ON test_questions(test_id);
CREATE INDEX IF NOT EXISTS idx_test_submissions_user ON user_test_submissions(user_id);
CREATE INDEX IF NOT EXISTS idx_test_submissions_test ON user_test_submissions(test_id);

CREATE INDEX IF NOT EXISTS idx_pomodoro_user ON pomodoro_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_notes_user ON notes(user_id);
CREATE INDEX IF NOT EXISTS idx_notes_chapter ON notes(chapter_id);
CREATE INDEX IF NOT EXISTS idx_youtube_links_chapter ON youtube_links(chapter_id);

CREATE INDEX IF NOT EXISTS idx_heatmap_user_date ON heatmap_entries(user_id, activity_date);
CREATE INDEX IF NOT EXISTS idx_leaderboard_entries_board ON leaderboard_entries(leaderboard_id);
CREATE INDEX IF NOT EXISTS idx_leaderboard_entries_user ON leaderboard_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_peer_room_members_room ON peer_room_members(room_id);
CREATE INDEX IF NOT EXISTS idx_peer_room_members_user ON peer_room_members(user_id);
CREATE INDEX IF NOT EXISTS idx_progress_cards_user ON progress_cards(user_id);

CREATE INDEX IF NOT EXISTS idx_past_papers_exam ON past_papers(exam_id);
CREATE INDEX IF NOT EXISTS idx_habits_user ON habits(user_id);
CREATE INDEX IF NOT EXISTS idx_habit_entries_habit ON habit_entries(habit_id);
CREATE INDEX IF NOT EXISTS idx_habit_entries_date ON habit_entries(checkin_date);
