-- EduTrack Seed Data
-- Run after schema migration

-- 1. EXAMS
INSERT INTO exams (id, name, code, category, description, is_active) VALUES
('a1000000-0000-0000-0000-000000000001', 'CA Foundation', 'CA-FND', 'CA', 'Chartered Accountancy Foundation Level - ICAI', true),
('a1000000-0000-0000-0000-000000000002', 'CS Executive', 'CS-EXE', 'CS', 'Company Secretary Executive Level - ICSI', true),
('a1000000-0000-0000-0000-000000000003', 'JEE Main', 'JEE-M', 'JEE', 'Joint Entrance Examination Main', true);

-- 2. SUBJECTS (CA Foundation)
INSERT INTO subjects (id, exam_id, name, code, display_order) VALUES
('b1000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000001', 'Accounting', 'CA-ACC', 1),
('b1000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000001', 'Business Laws', 'CA-BLW', 2),
('b1000000-0000-0000-0000-000000000003', 'a1000000-0000-0000-0000-000000000001', 'Quantitative Aptitude', 'CA-QA', 3),
('b1000000-0000-0000-0000-000000000004', 'a1000000-0000-0000-0000-000000000001', 'Business Economics', 'CA-BE', 4);

-- 3. MODULES
INSERT INTO modules (id, subject_id, name, description, display_order) VALUES
('c1000000-0000-0000-0000-000000000001', 'b1000000-0000-0000-0000-000000000001', 'Theoretical Framework', 'Accounting fundamentals', 1),
('c1000000-0000-0000-0000-000000000002', 'b1000000-0000-0000-0000-000000000001', 'Special Transactions', 'Partnership, branch accounts', 2),
('c1000000-0000-0000-0000-000000000003', 'b1000000-0000-0000-0000-000000000001', 'Final Accounts', 'Financial statements', 3),
('c1000000-0000-0000-0000-000000000004', 'b1000000-0000-0000-0000-000000000002', 'Regulatory Framework', 'Constitution basics', 1),
('c1000000-0000-0000-0000-000000000005', 'b1000000-0000-0000-0000-000000000002', 'Companies Act 2013', 'Company formation', 2),
('c1000000-0000-0000-0000-000000000006', 'b1000000-0000-0000-0000-000000000003', 'Mathematics', 'Ratio, equations', 1),
('c1000000-0000-0000-0000-000000000007', 'b1000000-0000-0000-0000-000000000003', 'Statistics', 'Central tendency', 2),
('c1000000-0000-0000-0000-000000000008', 'b1000000-0000-0000-0000-000000000003', 'Logical Reasoning', 'Patterns', 3),
('c1000000-0000-0000-0000-000000000009', 'b1000000-0000-0000-0000-000000000004', 'Microeconomics', 'Demand, supply', 1),
('c1000000-0000-0000-0000-000000000010', 'b1000000-0000-0000-0000-000000000004', 'Macroeconomics', 'National income', 2);

-- 4. CHAPTERS
INSERT INTO chapters (id, module_id, name, description, display_order) VALUES
('d1000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000001', 'Introduction to Accounting', 'Meaning, scope', 1),
('d1000000-0000-0000-0000-000000000002', 'c1000000-0000-0000-0000-000000000001', 'Accounting Concepts', 'GAAP principles', 2),
('d1000000-0000-0000-0000-000000000003', 'c1000000-0000-0000-0000-000000000001', 'Accounting Process', 'Journal, ledger', 3),
('d1000000-0000-0000-0000-000000000004', 'c1000000-0000-0000-0000-000000000002', 'Partnership Accounts', 'Admission, retirement', 1),
('d1000000-0000-0000-0000-000000000005', 'c1000000-0000-0000-0000-000000000002', 'Branch Accounts', 'Dependent branches', 2),
('d1000000-0000-0000-0000-000000000006', 'c1000000-0000-0000-0000-000000000003', 'Company Final Accounts', 'Balance sheet', 1),
('d1000000-0000-0000-0000-000000000007', 'c1000000-0000-0000-0000-000000000004', 'Indian Constitution', 'Fundamental rights', 1),
('d1000000-0000-0000-0000-000000000008', 'c1000000-0000-0000-0000-000000000005', 'Company Incorporation', 'MOA, AOA', 1),
('d1000000-0000-0000-0000-000000000009', 'c1000000-0000-0000-0000-000000000005', 'Share Capital', 'Issue, transfer', 2),
('d1000000-0000-0000-0000-000000000010', 'c1000000-0000-0000-0000-000000000006', 'Ratio and Proportion', 'Basics', 1),
('d1000000-0000-0000-0000-000000000011', 'c1000000-0000-0000-0000-000000000006', 'Equations', 'Linear, quadratic', 2),
('d1000000-0000-0000-0000-000000000012', 'c1000000-0000-0000-0000-000000000007', 'Statistical Description', 'Charts', 1),
('d1000000-0000-0000-0000-000000000013', 'c1000000-0000-0000-0000-000000000007', 'Central Tendency', 'Mean, median, mode', 2),
('d1000000-0000-0000-0000-000000000014', 'c1000000-0000-0000-0000-000000000008', 'Number Series', 'Patterns', 1),
('d1000000-0000-0000-0000-000000000015', 'c1000000-0000-0000-0000-000000000009', 'Demand Analysis', 'Law of demand', 1),
('d1000000-0000-0000-0000-000000000016', 'c1000000-0000-0000-0000-000000000009', 'Market Equilibrium', 'Price determination', 2),
('d1000000-0000-0000-0000-000000000017', 'c1000000-0000-0000-0000-000000000010', 'National Income', 'GDP, GNP', 1),
('d1000000-0000-0000-0000-000000000018', 'c1000000-0000-0000-0000-000000000010', 'Money and Banking', 'Central bank', 2);

-- 5. TOPICS
INSERT INTO topics (id, chapter_id, name, description, display_order) VALUES
('e1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001', 'Meaning of Accounting', 'Definition', 1),
('e1000000-0000-0000-0000-000000000002', 'd1000000-0000-0000-0000-000000000001', 'Branches of Accounting', 'Financial, cost, management', 2),
('e1000000-0000-0000-0000-000000000003', 'd1000000-0000-0000-0000-000000000001', 'Role of Accountant', 'Functions', 3),
('e1000000-0000-0000-0000-000000000004', 'd1000000-0000-0000-0000-000000000002', 'Going Concern', 'Continuity assumption', 1),
('e1000000-0000-0000-0000-000000000005', 'd1000000-0000-0000-0000-000000000002', 'Accrual Concept', 'Revenue recognition', 2),
('e1000000-0000-0000-0000-000000000006', 'd1000000-0000-0000-0000-000000000002', 'Consistency Concept', 'Uniform practices', 3),
('e1000000-0000-0000-0000-000000000007', 'd1000000-0000-0000-0000-000000000003', 'Journal Entries', 'Double entry', 1),
('e1000000-0000-0000-0000-000000000008', 'd1000000-0000-0000-0000-000000000003', 'Ledger Posting', 'General ledger', 2),
('e1000000-0000-0000-0000-000000000009', 'd1000000-0000-0000-0000-000000000003', 'Trial Balance', 'Accuracy check', 3),
('e1000000-0000-0000-0000-000000000010', 'd1000000-0000-0000-0000-000000000004', 'Admission of Partner', 'Goodwill', 1),
('e1000000-0000-0000-0000-000000000011', 'd1000000-0000-0000-0000-000000000004', 'Retirement of Partner', 'Settlement', 2),
('e1000000-0000-0000-0000-000000000012', 'd1000000-0000-0000-0000-000000000010', 'Ratio Basics', 'Simple and compound', 1),
('e1000000-0000-0000-0000-000000000013', 'd1000000-0000-0000-0000-000000000010', 'Proportion', 'Direct and indirect', 2),
('e1000000-0000-0000-0000-000000000014', 'd1000000-0000-0000-0000-000000000015', 'Law of Demand', 'Demand curve', 1),
('e1000000-0000-0000-0000-000000000015', 'd1000000-0000-0000-0000-000000000015', 'Elasticity', 'Price, income elasticity', 2),
('e1000000-0000-0000-0000-000000000016', 'd1000000-0000-0000-0000-000000000017', 'GDP Calculation', 'Expenditure method', 1),
('e1000000-0000-0000-0000-000000000017', 'd1000000-0000-0000-0000-000000000017', 'GNP vs GDP', 'Concepts', 2);

-- 6. BADGES
INSERT INTO badges (id, name, slug, description, category, rarity_tier, criteria_json, points, is_active) VALUES
('f1000000-0000-0000-0000-000000000001', 'First Step', 'first-step', 'Complete your first topic', 'syllabus', 'common', '{"type":"topics_mastered","count":1}', 10, true),
('f1000000-0000-0000-0000-000000000002', 'Quick Learner', 'quick-learner', 'Master 5 topics', 'syllabus', 'common', '{"type":"topics_mastered","count":5}', 25, true),
('f1000000-0000-0000-0000-000000000003', 'Quarter Master', 'quarter-master', 'Complete 25% syllabus', 'syllabus', 'rare', '{"type":"syllabus_pct","pct":25}', 50, true),
('f1000000-0000-0000-0000-000000000004', 'Half-Way Hero', 'half-way-hero', 'Complete 50% syllabus', 'syllabus', 'epic', '{"type":"syllabus_pct","pct":50}', 100, true),
('f1000000-0000-0000-0000-000000000005', 'Conqueror', 'conqueror', 'Complete 100% syllabus', 'syllabus', 'legendary', '{"type":"syllabus_pct","pct":100}', 500, true),
('f1000000-0000-0000-0000-000000000006', '7-Day Burner', '7-day-burner', '7-day streak', 'consistency', 'common', '{"type":"streak","days":7}', 30, true),
('f1000000-0000-0000-0000-000000000007', 'Centurion', 'centurion', '30-day streak', 'consistency', 'rare', '{"type":"streak","days":30}', 100, true),
('f1000000-0000-0000-0000-000000000008', 'Unstoppable', 'unstoppable', '100-day streak', 'consistency', 'legendary', '{"type":"streak","days":100}', 1000, true),
('f1000000-0000-0000-0000-000000000009', 'Early Bird', 'early-bird', '5 tasks before 8 AM', 'habits', 'rare', '{"type":"early_tasks","count":5}', 40, true),
('f1000000-0000-0000-0000-000000000010', 'Focus Master', 'focus-master', '50 hours of focus', 'focus', 'epic', '{"type":"focus_hours","hours":50}', 150, true),
('f1000000-0000-0000-0000-000000000011', 'Pomodoro Pro', 'pomodoro-pro', '25 pomodoro sessions', 'focus', 'rare', '{"type":"pomodoro_count","count":25}', 60, true),
('f1000000-0000-0000-0000-000000000012', 'Podium Finisher', 'podium-finisher', 'Score 90%+ on test', 'academic', 'epic', '{"type":"test_score_pct","min":90}', 80, true),
('f1000000-0000-0000-0000-000000000013', 'Flawless', 'flawless', 'Score 100% on test', 'academic', 'legendary', '{"type":"test_score_pct","min":100}', 200, true),
('f1000000-0000-0000-0000-000000000014', 'Note Taker', 'note-taker', 'Create 10 notes', 'focus', 'common', '{"type":"notes_count","count":10}', 20, true),
('f1000000-0000-0000-0000-000000000015', 'Social Butterfly', 'social-butterfly', 'Join a peer room', 'social', 'common', '{"type":"peer_rooms_joined","count":1}', 15, true);

-- 7. TESTS
INSERT INTO tests (id, exam_id, title, description, total_marks, duration_mins, marking_scheme, week_number, year, is_published) VALUES
('g1000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000001', 'Week 1 - Accounting Basics', 'Test on fundamentals', 100, 60, '{"correct":4,"wrong":-1,"skip":0}', 1, 2026, true),
('g1000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000001', 'Week 2 - Business Laws', 'Regulatory framework', 100, 60, '{"correct":4,"wrong":-1,"skip":0}', 2, 2026, true);

-- 8. TEST QUESTIONS
INSERT INTO test_questions (id, test_id, topic_id, question_text, question_type, options, correct_option, marks, explanation, display_order) VALUES
('h1000000-0000-0000-0000-000000000001', 'g1000000-0000-0000-0000-000000000001', 'e1000000-0000-0000-0000-000000000001', 'Which best defines accounting?', 'mcq', '{"A":"Cash transactions only","B":"Identify, record, communicate economic events","C":"Tax returns","D":"Bank reconciliation"}', 'B', 4, 'Accounting is identifying, recording and communicating economic events.', 1),
('h1000000-0000-0000-0000-000000000002', 'g1000000-0000-0000-0000-000000000001', 'e1000000-0000-0000-0000-000000000002', 'Branch dealing with cost ascertainment?', 'mcq', '{"A":"Financial","B":"Cost Accounting","C":"Management","D":"Tax"}', 'B', 4, 'Cost Accounting deals with cost ascertainment.', 2),
('h1000000-0000-0000-0000-000000000003', 'g1000000-0000-0000-0000-000000000001', 'e1000000-0000-0000-0000-000000000004', 'Going concern assumes:', 'mcq', '{"A":"Liquidation soon","B":"Indefinite continuation","C":"Cash only","D":"Rising profits"}', 'B', 4, 'Going concern = business continues indefinitely.', 3),
('h1000000-0000-0000-0000-000000000004', 'g1000000-0000-0000-0000-000000000001', 'e1000000-0000-0000-0000-000000000005', 'Accrual means revenue recognized when:', 'mcq', '{"A":"Cash received","B":"Invoice sent","C":"When earned","D":"Year end"}', 'C', 4, 'Accrual: revenue recognized when earned.', 4),
('h1000000-0000-0000-0000-000000000005', 'g1000000-0000-0000-0000-000000000001', 'e1000000-0000-0000-0000-000000000007', 'Book of original entry is:', 'mcq', '{"A":"Ledger","B":"Journal","C":"Trial Balance","D":"Balance Sheet"}', 'B', 4, 'Journal is the book of original entry.', 5),
('h1000000-0000-0000-0000-000000000006', 'g1000000-0000-0000-0000-000000000001', 'e1000000-0000-0000-0000-000000000008', 'Ledger is also known as:', 'mcq', '{"A":"Book of prime entry","B":"Principal book","C":"Original entry","D":"Source document"}', 'B', 4, 'Ledger is the principal book of accounts.', 6),
('h1000000-0000-0000-0000-000000000007', 'g1000000-0000-0000-0000-000000000001', 'e1000000-0000-0000-0000-000000000009', 'Trial balance checks:', 'mcq', '{"A":"Accuracy of ledger","B":"Arithmetical accuracy","C":"Profitability","D":"Liquidity"}', 'B', 4, 'Trial balance verifies arithmetical accuracy.', 7),
('h1000000-0000-0000-0000-000000000008', 'g1000000-0000-0000-0000-000000000001', 'e1000000-0000-0000-0000-000000000010', 'Goodwill is recorded at:', 'mcq', '{"A":"Purchase always","B":"Only on admission/retirement","C":"Never recorded","D":"Every year"}', 'B', 4, 'Goodwill is recorded during admission/retirement.', 8),
('h1000000-0000-0000-0000-000000000009', 'g1000000-0000-0000-0000-000000000001', 'e1000000-0000-0000-0000-000000000006', 'Consistency concept means:', 'mcq', '{"A":"Same method every year","B":"No changes ever","C":"Copy competitors","D":"Change annually"}', 'A', 4, 'Consistency: use same methods year to year.', 9),
('h1000000-0000-0000-0000-000000000010', 'g1000000-0000-0000-0000-000000000001', 'e1000000-0000-0000-0000-000000000003', 'Role of accountant includes:', 'mcq', '{"A":"Only recording","B":"Recording and analyzing","C":"Only tax filing","D":"Only auditing"}', 'B', 4, 'Accountant records, analyzes and communicates.', 10),
('h1000000-0000-0000-0000-000000000011', 'g1000000-0000-0000-0000-000000000002', 'e1000000-0000-0000-0000-000000000014', 'Law of demand states:', 'mcq', '{"A":"Price up, demand up","B":"Price up, demand down","C":"No relationship","D":"Constant demand"}', 'B', 4, 'Inverse relationship between price and demand.', 1),
('h1000000-0000-0000-0000-000000000012', 'g1000000-0000-0000-0000-000000000002', 'e1000000-0000-0000-0000-000000000016', 'GDP measures:', 'mcq', '{"A":"Individual income","B":"Total output in country","C":"Government revenue","D":"Exports only"}', 'B', 4, 'GDP is total value of goods/services produced.', 2),
('h1000000-0000-0000-0000-000000000013', 'g1000000-0000-0000-0000-000000000002', 'e1000000-0000-0000-0000-000000000012', 'A ratio of 3:5 means:', 'mcq', '{"A":"3 divided by 5","B":"3 is to 5","C":"3 plus 5","D":"3 minus 5"}', 'B', 4, 'Ratio compares two quantities.', 3),
('h1000000-0000-0000-0000-000000000014', 'g1000000-0000-0000-0000-000000000002', 'e1000000-0000-0000-0000-000000000013', 'Arithmetic mean of 2,4,6 is:', 'mcq', '{"A":"4","B":"12","C":"6","D":"3"}', 'A', 4, 'Mean = (2+4+6)/3 = 4', 4),
('h1000000-0000-0000-0000-000000000015', 'g1000000-0000-0000-0000-000000000002', 'e1000000-0000-0000-0000-000000000015', 'Elasticity of demand measures:', 'mcq', '{"A":"Supply change","B":"Responsiveness of quantity to price","C":"Cost of production","D":"Profit margin"}', 'B', 4, 'Elasticity measures how quantity responds to price.', 5);

-- 9. PAST PAPERS
INSERT INTO past_papers (exam_id, title, year, term, file_url, file_type) VALUES
('a1000000-0000-0000-0000-000000000001', 'CA Foundation Nov 2025 Paper 1', 2025, 'Nov', 'https://example.com/ca-fnd-2025-nov-p1.pdf', 'pdf'),
('a1000000-0000-0000-0000-000000000001', 'CA Foundation Nov 2025 Paper 2', 2025, 'Nov', 'https://example.com/ca-fnd-2025-nov-p2.pdf', 'pdf'),
('a1000000-0000-0000-0000-000000000001', 'CA Foundation May 2025 Paper 1', 2025, 'May', 'https://example.com/ca-fnd-2025-may-p1.pdf', 'pdf'),
('a1000000-0000-0000-0000-000000000001', 'CA Foundation May 2025 Paper 2', 2025, 'May', 'https://example.com/ca-fnd-2025-may-p2.pdf', 'pdf');
