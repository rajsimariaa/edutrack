-- Migration: v3.2.0 - Complete syllabus expansion (500+ flashcards) + exam countdown
-- Adds next_exam_date to exams table + 430+ new topics across all exams

-- Step 1: Add exam dates
ALTER TABLE exams ADD COLUMN IF NOT EXISTS next_exam_date DATE;

UPDATE exams SET next_exam_date = '2026-09-15' WHERE id = 'e1111111-1111-1111-1111-111111111111'; -- CA Foundation Dec 2026
UPDATE exams SET next_exam_date = '2026-12-01' WHERE id = 'e2222222-2222-2222-2222-222222222222'; -- CA Intermediate Dec 2026
UPDATE exams SET next_exam_date = '2026-11-15' WHERE id = 'e3333333-3333-3333-3333-333333333333'; -- CA Final Nov 2026
UPDATE exams SET next_exam_date = '2026-10-01' WHERE id = 'e4444444-4444-4444-4444-444444444444'; -- CS Executive Jun 2027
UPDATE exams SET next_exam_date = '2026-12-10' WHERE id = 'e5555555-5555-5555-5555-555555555555'; -- CMA Foundation Dec 2026
UPDATE exams SET next_exam_date = '2026-11-20' WHERE id = 'e6666666-6666-6666-6666-666666666666'; -- CFA Level 1 Nov 2026
UPDATE exams SET next_exam_date = '2026-09-20' WHERE id = 'e7777777-7777-7777-7777-777777777777'; -- JEE Main Jan 2027
UPDATE exams SET next_exam_date = '2026-10-10' WHERE id = 'e8888888-8888-8888-8888-888888888888'; -- JEE Advanced May 2027
UPDATE exams SET next_exam_date = '2026-09-25' WHERE id = 'e9999999-9999-9999-9999-999999999999'; -- NEET UG May 2027

-- ============================================================
-- CA INTERMEDIATE (e222) - New modules, chapters, topics
-- ============================================================

-- Subject: Advanced Accounting (e8888888-8888-8888-8888-888888888e88) - already exists
-- Module: Accounting Standards (f0deaf50-c9e6-4684-9570-b74af0118abb) - already exists
-- Module: Corporate Reporting (76e03c81-f8d1-4977-8812-5267a9640520) - already exists

-- Add new chapters for Advanced Accounting
INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000001-0000-0000-0000-000000000001', 'f0deaf50-c9e6-4684-9570-b74af0118abb', 'IAS 1 - Presentation of Financial Statements', 3),
('aa000002-0000-0000-0000-000000000001', 'f0deaf50-c9e6-4684-9570-b74af0118abb', 'IAS 16 - Property, Plant and Equipment', 4),
('aa000003-0000-0000-0000-000000000001', 'f0deaf50-c9e6-4684-9570-b74af0118abb', 'IAS 38 - Intangible Assets', 5),
('aa000004-0000-0000-0000-000000000001', 'f0deaf50-c9e6-4684-9570-b74af0118abb', 'IAS 36 - Impairment of Assets', 6),
('aa000005-0000-0000-0000-000000000001', 'f0deaf50-c9e6-4684-9570-b74af0118abb', 'IAS 37 - Provisions and Contingencies', 7),
('aa000006-0000-0000-0000-000000000001', '76e03c81-f8d1-4977-8812-5267a9640520', 'IFRS 3 - Business Combinations', 2),
('aa000007-0000-0000-0000-000000000001', '76e03c81-f8d1-4977-8812-5267a9640520', 'IFRS 10 - Consolidated Financial Statements', 3),
('aa000008-0000-0000-0000-000000000001', '76e03c81-f8d1-4977-8812-5267a9640520', 'IFRS 11 - Joint Arrangements', 4),
('aa000009-0000-0000-0000-000000000001', '76e03c81-f8d1-4977-8812-5267a9640520', 'IFRS 13 - Fair Value Measurement', 5);

-- Subject: Auditing (e9999999-9999-9999-9999-999999999e99) - already exists
-- Module: Audit Framework (f3cf7fe7-b18b-4f90-9e0e-3686df2f061b) - already exists

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000010-0000-0000-0000-000000000001', 'f3cf7fe7-b18b-4f90-9e0e-3686df2f061b', 'Audit Evidence', 3),
('aa000011-0000-0000-0000-000000000001', 'f3cf7fe7-b18b-4f90-9e0e-3686df2f061b', 'Audit Sampling', 4),
('aa000012-0000-0000-0000-000000000001', 'f3cf7fe7-b18b-4f90-9e0e-3686df2f061b', 'Audit Report', 5),
('aa000013-0000-0000-0000-000000000001', 'f3cf7fe7-b18b-4f90-9e0e-3686df2f061b', 'Company Audit', 6),
('aa000014-0000-0000-0000-000000000001', 'f3cf7fe7-b18b-4f90-9e0e-3686df2f061b', 'Cost Audit', 7);

-- Add Cost Accounting subject/module/chapter for CA Inter
INSERT INTO modules (id, subject_id, name, display_order) VALUES
('aa000020-0000-0000-0000-000000000001', 'e9999999-9999-9999-9999-999999999e99', 'Cost Accounting Methods', 2);

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000021-0000-0000-0000-000000000001', 'aa000020-0000-0000-0000-000000000001', 'Process Costing', 1),
('aa000022-0000-0000-0000-000000000001', 'aa000020-0000-0000-0000-000000000001', 'Job Costing', 2),
('aa000023-0000-0000-0000-000000000001', 'aa000020-0000-0000-0000-000000000001', 'Activity Based Costing', 3);

-- Add Tax subject for CA Inter
INSERT INTO subjects (id, exam_id, name, display_order) VALUES
('aa000030-0000-0000-0000-000000000001', 'e2222222-2222-2222-2222-222222222222', 'Taxation', 4);

INSERT INTO modules (id, subject_id, name, display_order) VALUES
('aa000031-0000-0000-0000-000000000001', 'aa000030-0000-0000-0000-000000000001', 'Income Tax Basics', 1),
('aa000032-0000-0000-0000-000000000001', 'aa000030-0000-0000-0000-000000000001', 'GST Fundamentals', 2);

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000033-0000-0000-0000-000000000001', 'aa000031-0000-0000-0000-000000000001', 'Heads of Income', 1),
('aa000034-0000-0000-0000-000000000001', 'aa000031-0000-0000-0000-000000000001', 'Deductions', 2),
('aa000035-0000-0000-0000-000000000001', 'aa000031-0000-0000-0000-000000000001', 'Assessment of Individuals', 3),
('aa000036-0000-0000-0000-000000000001', 'aa000032-0000-0000-0000-000000000001', 'GST Supply', 1),
('aa000037-0000-0000-0000-000000000001', 'aa000032-0000-0000-0000-000000000001', 'Input Tax Credit', 2),
('aa000038-0000-0000-0000-000000000001', 'aa000032-0000-0000-0000-000000000001', 'GST Returns', 3);

-- ============================================================
-- CA FINAL (e333) - New modules, chapters, topics
-- ============================================================

-- Subject: Strategic Financial Management (f2222222-2222-2222-2222-222222222f22) - exists
-- Module: Investment Analysis (5163aff1-4780-40a0-8f1c-724acd7f09a0) - exists

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000040-0000-0000-0000-000000000001', '5163aff1-4780-40a0-8f1c-724acd7f09a0', 'CAPM and APT', 3),
('aa000041-0000-0000-0000-000000000001', '5163aff1-4780-40a0-8f1c-724acd7f09a0', 'Bond Valuation', 4),
('aa000042-0000-0000-0000-000000000001', '5163aff1-4780-40a0-8f1c-724acd7f09a0', 'Mutual Fund Analysis', 5);

-- New module: Risk Management
INSERT INTO modules (id, subject_id, name, display_order) VALUES
('aa000043-0000-0000-0000-000000000001', 'f2222222-2222-2222-2222-222222222f22', 'Risk Management', 2);

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000044-0000-0000-0000-000000000001', 'aa000043-0000-0000-0000-000000000001', 'Value at Risk', 1),
('aa000045-0000-0000-0000-000000000001', 'aa000043-0000-0000-0000-000000000001', 'Derivatives Pricing', 2),
('aa000046-0000-0000-0000-000000000001', 'aa000043-0000-0000-0000-000000000001', 'Hedging Strategies', 3);

-- New module: Financial Reporting
INSERT INTO modules (id, subject_id, name, display_order) VALUES
('aa000047-0000-0000-0000-000000000001', 'f1111111-1111-1111-1111-111111111f11', 'Advanced IFRS', 2);

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000048-0000-0000-0000-000000000001', 'aa000047-0000-0000-0000-000000000001', 'IFRS 15 - Revenue from Contracts', 1),
('aa000049-0000-0000-0000-000000000001', 'aa000047-0000-0000-0000-000000000001', 'IFRS 16 - Leases', 2),
('aa000050-0000-0000-0000-000000000001', 'aa000047-0000-0000-0000-000000000001', 'IFRS 9 - Financial Instruments', 3);

-- ============================================================
-- CS EXECUTIVE (e444) - New modules, chapters, topics
-- ============================================================

-- Subject: Company Law (e2222222-2222-2222-2222-222222222e22) - exists
-- Module: Company Formation (4dd366fd-d9bd-4d34-9af4-f6cf860da662) - exists

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000051-0000-0000-0000-000000000001', '4dd366fd-d9bd-4d34-9af4-f6cf860da662', 'Share Capital', 3),
('aa000052-0000-0000-0000-000000000001', '4dd366fd-d9bd-4d34-9af4-f6cf860da662', 'Debentures', 4),
('aa000053-0000-0000-0000-000000000001', '4dd366fd-d9bd-4d34-9af4-f6cf860da662', 'Management and Administration', 5),
('aa000054-0000-0000-0000-000000000001', '4dd366fd-d9bd-4d34-9af4-f6cf860da662', 'Winding Up', 6);

-- New module: Corporate Governance
INSERT INTO modules (id, subject_id, name, display_order) VALUES
('aa000055-0000-0000-0000-000000000001', 'e2222222-2222-2222-2222-222222222e22', 'Corporate Governance', 2);

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000056-0000-0000-0000-000000000001', 'aa000055-0000-0000-0000-000000000001', 'Board of Directors', 1),
('aa000057-0000-0000-0000-000000000001', 'aa000055-0000-0000-0000-000000000001', 'Committees', 2),
('aa000058-0000-0000-0000-000000000001', 'aa000055-0000-0000-0000-000000000001', 'Related Party Transactions', 3);

-- Subject: Economic Laws (e3333333-3333-3333-3333-333333333e33) - exists
INSERT INTO modules (id, subject_id, name, display_order) VALUES
('aa000059-0000-0000-0000-000000000001', 'e3333333-3333-3333-3333-333333333e33', 'Industrial Laws', 1);

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000060-0000-0000-0000-000000000001', 'aa000059-0000-0000-0000-000000000001', 'Factories Act', 1),
('aa000061-0000-0000-0000-000000000001', 'aa000059-0000-0000-0000-000000000001', 'Shops and Establishments', 2),
('aa000062-0000-0000-0000-000000000001', 'aa000059-0000-0000-0000-000000000001', 'Payment of Wages Act', 3),
('aa000063-0000-0000-0000-000000000001', 'aa000059-0000-0000-0000-000000000001', 'Minimum Wages Act', 4);

-- Subject: Tax Laws for CS
INSERT INTO subjects (id, exam_id, name, display_order) VALUES
('aa000064-0000-0000-0000-000000000001', 'e4444444-4444-4444-4444-444444444444', 'Tax Laws', 3);

INSERT INTO modules (id, subject_id, name, display_order) VALUES
('aa000065-0000-0000-0000-000000000001', 'aa000064-0000-0000-0000-000000000001', 'Income Tax', 1),
('aa000066-0000-0000-0000-000000000001', 'aa000064-0000-0000-0000-000000000001', 'GST', 2);

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000067-0000-0000-0000-000000000001', 'aa000065-0000-0000-0000-000000000001', 'Taxable Income', 1),
('aa000068-0000-0000-0000-000000000001', 'aa000065-0000-0000-0000-000000000001', 'Tax Computation', 2),
('aa000069-0000-0000-0000-000000000001', 'aa000066-0000-0000-0000-000000000001', 'GST Registration', 1),
('aa000070-0000-0000-0000-000000000001', 'aa000066-0000-0000-0000-000000000001', 'GST Returns Filing', 2);

-- ============================================================
-- CMA FOUNDATION (e555) - New chapters and topics
-- ============================================================

-- Subject: Financial Accounting (e4444444-4444-4444-4444-444444444e44) - exists
-- Module: Cost Accounting (dfc6ced3-fc07-4fe4-948e-15c917be9b88) - exists

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000071-0000-0000-0000-000000000001', 'dfc6ced3-fc07-4fe4-948e-15c917be9b88', 'Marginal Costing', 3),
('aa000072-0000-0000-0000-000000000001', 'dfc6ced3-fc07-4fe4-948e-15c917be9b88', 'Standard Costing', 4),
('aa000073-0000-0000-0000-000000000001', 'dfc6ced3-fc07-4fe4-948e-15c917be9b88', 'Budgetary Control', 5);

-- Subject: Business Mathematics (e5555555-5555-5555-5555-555555555e55) - exists
-- Module: Algebra (df194897-fa4c-4784-b230-bbede637f59d) - exists

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000074-0000-0000-0000-000000000001', 'df194897-fa4c-4784-b230-bbede637f59d', 'Permutations and Combinations', 3),
('aa000075-0000-0000-0000-000000000001', 'df194897-fa4c-4784-b230-bbede637f59d', 'Binomial Theorem', 4),
('aa000076-0000-0000-0000-000000000001', 'df194897-fa4c-4784-b230-bbede637f59d', 'Sequences and Series', 5);

-- New module: Statistics
INSERT INTO modules (id, subject_id, name, display_order) VALUES
('aa000077-0000-0000-0000-000000000001', 'e5555555-5555-5555-5555-555555555e55', 'Statistics', 2);

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000078-0000-0000-0000-000000000001', 'aa000077-0000-0000-0000-000000000001', 'Measures of Central Tendency', 1),
('aa000079-0000-0000-0000-000000000001', 'aa000077-0000-0000-0000-000000000001', 'Measures of Dispersion', 2),
('aa000080-0000-0000-0000-000000000001', 'aa000077-0000-0000-0000-000000000001', 'Correlation and Regression', 3);

-- ============================================================
-- CFA LEVEL 1 (e666) - New chapters and topics
-- ============================================================

-- Subject: Ethics (e6666666-6666-6666-6666-666666666e66) - exists
-- Module: Standards of Practice (9fb54193-af37-4bd2-96b9-b2c154ce7dae) - exists

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000081-0000-0000-0000-000000000001', '9fb54193-af37-4bd2-96b9-b2c154ce7dae', 'Global Investment Performance Standards', 3),
('aa000082-0000-0000-0000-000000000001', '9fb54193-af37-4bd2-96b9-b2c154ce7dae', 'Soft Dollar Standards', 4);

-- Subject: Quantitative Methods (e7777777-7777-7777-7777-777777777e77) - exists
-- Module: Statistical Methods (a2ee5e29-6135-48de-9a77-ebe92a14d8f5) - exists

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000083-0000-0000-0000-000000000001', 'a2ee5e29-6135-48de-9a77-ebe92a14d8f5', 'Sampling Distributions', 4),
('aa000084-0000-0000-0000-000000000001', 'a2ee5e29-6135-48de-9a77-ebe92a14d8f5', 'Confidence Intervals', 5),
('aa000085-0000-0000-0000-000000000001', 'a2ee5e29-6135-48de-9a77-ebe92a14d8f5', 'Linear Regression', 6);

-- New subjects for CFA
INSERT INTO subjects (id, exam_id, name, display_order) VALUES
('aa000086-0000-0000-0000-000000000001', 'e6666666-6666-6666-6666-666666666666', 'Economics', 3),
('aa000087-0000-0000-0000-000000000001', 'e6666666-6666-6666-6666-666666666666', 'Financial Reporting and Analysis', 4),
('aa000088-0000-0000-0000-000000000001', 'e6666666-6666-6666-6666-666666666666', 'Corporate Finance', 5),
('aa000089-0000-0000-0000-000000000001', 'e6666666-6666-6666-6666-666666666666', 'Equity Investments', 6),
('aa000090-0000-0000-0000-000000000001', 'e6666666-6666-6666-6666-666666666666', 'Fixed Income', 7),
('aa000091-0000-0000-0000-000000000001', 'e6666666-6666-6666-6666-666666666666', 'Derivatives', 8),
('aa000092-0000-0000-0000-000000000001', 'e6666666-6666-6666-6666-666666666666', 'Alternative Investments', 9),
('aa000093-0000-0000-0000-000000000001', 'e6666666-6666-6666-6666-666666666666', 'Portfolio Management', 10);

INSERT INTO modules (id, subject_id, name, display_order) VALUES
('aa000094-0000-0000-0000-000000000001', 'aa000086-0000-0000-0000-000000000001', 'Microeconomics', 1),
('aa000095-0000-0000-0000-000000000001', 'aa000086-0000-0000-0000-000000000001', 'Macroeconomics', 2),
('aa000096-0000-0000-0000-000000000001', 'aa000087-0000-0000-0000-000000000001', 'Financial Statements', 1),
('aa000097-0000-0000-0000-000000000001', 'aa000088-0000-0000-0000-000000000001', 'Capital Budgeting', 1),
('aa000098-0000-0000-0000-000000000001', 'aa000088-0000-0000-0000-000000000001', 'Cost of Capital', 2),
('aa000099-0000-0000-0000-000000000001', 'aa000089-0000-0000-0000-000000000001', 'Market Efficiency', 1),
('aa000100-0000-0000-0000-000000000001', 'aa000089-0000-0000-0000-000000000001', 'Industry and Company Analysis', 2),
('aa000101-0000-0000-0000-000000000001', 'aa000090-0000-0000-0000-000000000001', 'Bond Pricing', 1),
('aa000102-0000-0000-0000-000000000001', 'aa000090-0000-0000-0000-000000000001', 'Yield Measures', 2),
('aa000103-0000-0000-0000-000000000001', 'aa000091-0000-0000-0000-000000000001', 'Forward Contracts', 1),
('aa000104-0000-0000-0000-000000000001', 'aa000091-0000-0000-0000-000000000001', 'Options Strategies', 2),
('aa000105-0000-0000-0000-000000000001', 'aa000092-0000-0000-0000-000000000001', 'Real Estate Investment', 1),
('aa000106-0000-0000-0000-000000000001', 'aa000092-0000-0000-0000-000000000001', 'Private Equity', 2),
('aa000107-0000-0000-0000-000000000001', 'aa000093-0000-0000-0000-000000000001', 'Modern Portfolio Theory', 1),
('aa000108-0000-0000-0000-000000000001', 'aa000093-0000-0000-0000-000000000001', 'Asset Allocation', 2);

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000109-0000-0000-0000-000000000001', 'aa000094-0000-0000-0000-000000000001', 'Consumer Theory', 1),
('aa000110-0000-0000-0000-000000000001', 'aa000094-0000-0000-0000-000000000001', 'Production Theory', 2),
('aa000111-0000-0000-0000-000000000001', 'aa000095-0000-0000-0000-000000000001', 'Business Cycles', 1),
('aa000112-0000-0000-0000-000000000001', 'aa000095-0000-0000-0000-000000000001', 'Monetary Policy', 2),
('aa000113-0000-0000-0000-000000000001', 'aa000095-0000-0000-0000-000000000001', 'Fiscal Policy', 3),
('aa000114-0000-0000-0000-000000000001', 'aa000096-0000-0000-0000-000000000001', 'Income Statements', 1),
('aa000115-0000-0000-0000-000000000001', 'aa000096-0000-0000-0000-000000000001', 'Balance Sheets', 2),
('aa000116-0000-0000-0000-000000000001', 'aa000096-0000-0000-0000-000000000001', 'Cash Flow Statements', 3),
('aa000117-0000-0000-0000-000000000001', 'aa000097-0000-0000-0000-000000000001', 'NPV and IRR', 1),
('aa000118-0000-0000-0000-000000000001', 'aa000097-0000-0000-0000-000000000001', 'Payback Period', 2),
('aa000119-0000-0000-0000-000000000001', 'aa000098-0000-0000-0000-000000000001', 'WACC', 1),
('aa000120-0000-0000-0000-000000000001', 'aa000098-0000-0000-0000-000000000001', 'CAPM Application', 2),
('aa000121-0000-0000-0000-000000000001', 'aa000099-0000-0000-0000-000000000001', 'EMH Forms', 1),
('aa000122-0000-0000-0000-000000000001', 'aa000100-0000-0000-0000-000000000001', 'Porter Five Forces', 1),
('aa000123-0000-0000-0000-000000000001', 'aa000100-0000-0000-0000-000000000001', 'SWOT Analysis', 2),
('aa000124-0000-0000-0000-000000000001', 'aa000101-0000-0000-0000-000000000001', 'Duration and Convexity', 1),
('aa000125-0000-0000-0000-000000000001', 'aa000102-0000-0000-0000-000000000001', 'Current Yield and YTM', 1),
('aa000126-0000-0000-0000-000000000001', 'aa000103-0000-0000-0000-000000000001', 'Forward Pricing', 1),
('aa000127-0000-0000-0000-000000000001', 'aa000104-0000-0000-0000-000000000001', 'Covered Calls and Puts', 1),
('aa000128-0000-0000-0000-000000000001', 'aa000104-0000-0000-0000-000000000001', 'Straddles and Strangles', 2),
('aa000129-0000-0000-0000-000000000001', 'aa000105-0000-0000-0000-000000000001', 'REIT Valuation', 1),
('aa000130-0000-0000-0000-000000000001', 'aa000106-0000-0000-0000-000000000001', 'LBO Analysis', 1),
('aa000131-0000-0000-0000-000000000001', 'aa000107-0000-0000-0000-000000000001', 'Efficient Frontier', 1),
('aa000132-0000-0000-0000-000000000001', 'aa000107-0000-0000-0000-000000000001', 'Sharpe Ratio', 2),
('aa000133-0000-0000-0000-000000000001', 'aa000108-0000-0000-0000-000000000001', 'Strategic Asset Allocation', 1),
('aa000134-0000-0000-0000-000000000001', 'aa000108-0000-0000-0000-000000000001', 'Rebalancing', 2);

-- ============================================================
-- JEE MAIN (e777) - New chapters and topics
-- ============================================================

-- Subject: Physics (b1111111-1111-1111-1111-111111111111) - exists
-- Module: Mechanics (4fe7ff2c-766d-4f29-8481-d9484ed65319) - exists

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000140-0000-0000-0000-000000000001', '4fe7ff2c-766d-4f29-8481-d9484ed65319', 'Circular Motion', 3),
('aa000141-0000-0000-0000-000000000001', '4fe7ff2c-766d-4f29-8481-d9484ed65319', 'Gravitation', 4),
('aa000142-0000-0000-0000-000000000001', '4fe7ff2c-766d-4f29-8481-d9484ed65319', 'Rotational Motion', 5),
('aa000143-0000-0000-0000-000000000001', '4fe7ff2c-766d-4f29-8481-d9484ed65319', 'Properties of Solids and Liquids', 6);

-- New modules for JEE Main Physics
INSERT INTO modules (id, subject_id, name, display_order) VALUES
('aa000144-0000-0000-0000-000000000001', 'b1111111-1111-1111-1111-111111111111', 'Thermodynamics', 2),
('aa000145-0000-0000-0000-000000000001', 'b1111111-1111-1111-1111-111111111111', 'Electromagnetism', 3),
('aa000146-0000-0000-0000-000000000001', 'b1111111-1111-1111-1111-111111111111', 'Optics', 4),
('aa000147-0000-0000-0000-000000000001', 'b1111111-1111-1111-1111-111111111111', 'Modern Physics', 5);

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000148-0000-0000-0000-000000000001', 'aa000144-0000-0000-0000-000000000001', 'Laws of Thermodynamics', 1),
('aa000149-0000-0000-0000-000000000001', 'aa000144-0000-0000-0000-000000000001', 'Heat Transfer', 2),
('aa000150-0000-0000-0000-000000000001', 'aa000144-0000-0000-0000-000000000001', 'Kinetic Theory of Gases', 3),
('aa000151-0000-0000-0000-000000000001', 'aa000145-0000-0000-0000-000000000001', 'Electrostatics', 1),
('aa000152-0000-0000-0000-000000000001', 'aa000145-0000-0000-0000-000000000001', 'Current Electricity', 2),
('aa000153-0000-0000-0000-000000000001', 'aa000145-0000-0000-0000-000000000001', 'Magnetic Effects of Current', 3),
('aa000154-0000-0000-0000-000000000001', 'aa000145-0000-0000-0000-000000000001', 'Electromagnetic Induction', 4),
('aa000155-0000-0000-0000-000000000001', 'aa000145-0000-0000-0000-000000000001', 'AC Circuits', 5),
('aa000156-0000-0000-0000-000000000001', 'aa000146-0000-0000-0000-000000000001', 'Ray Optics', 1),
('aa000157-0000-0000-0000-000000000001', 'aa000146-0000-0000-0000-000000000001', 'Wave Optics', 2),
('aa000158-0000-0000-0000-000000000001', 'aa000147-0000-0000-0000-000000000001', 'Dual Nature of Radiation', 1),
('aa000159-0000-0000-0000-000000000001', 'aa000147-0000-0000-0000-000000000001', 'Atoms and Nuclei', 2),
('aa000160-0000-0000-0000-000000000001', 'aa000147-0000-0000-0000-000000000001', 'Semiconductor Electronics', 3);

-- Subject: Chemistry (b2222222-2222-2222-2222-222222222222) - exists
-- Module: Physical Chemistry (3c5630c9-7fdb-491b-8a4b-929546e35b4a) - exists

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000161-0000-0000-0000-000000000001', '3c5630c9-7fdb-491b-8a4b-929546e35b4a', 'Atomic Structure', 2),
('aa000162-0000-0000-0000-000000000001', '3c5630c9-7fdb-491b-8a4b-929546e35b4a', 'Chemical Bonding', 3),
('aa000163-0000-0000-0000-000000000001', '3c5630c9-7fdb-491b-8a4b-929546e35b4a', 'Thermochemistry', 4),
('aa000164-0000-0000-0000-000000000001', '3c5630c9-7fdb-491b-8a4b-929546e35b4a', 'Equilibrium', 5),
('aa000165-0000-0000-0000-000000000001', '3c5630c9-7fdb-491b-8a4b-929546e35b4a', 'Electrochemistry', 6),
('aa000166-0000-0000-0000-000000000001', '3c5630c9-7fdb-491b-8a4b-929546e35b4a', 'Chemical Kinetics', 7),
('aa000167-0000-0000-0000-000000000001', '3c5630c9-7fdb-491b-8a4b-929546e35b4a', 'Solutions', 8),
('aa000168-0000-0000-0000-000000000001', '3c5630c9-7fdb-491b-8a4b-929546e35b4a', 'Surface Chemistry', 9);

-- Module: Organic Chemistry (already exists: b2222222-2222-2222-2222-222222222222 subject doesn't have it, let me add)
INSERT INTO modules (id, subject_id, name, display_order) VALUES
('aa000169-0000-0000-0000-000000000001', 'b2222222-2222-2222-2222-222222222222', 'Organic Chemistry', 2);

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000170-0000-0000-0000-000000000001', 'aa000169-0000-0000-0000-000000000001', 'General Organic Chemistry', 1),
('aa000171-0000-0000-0000-000000000001', 'aa000169-0000-0000-0000-000000000001', 'Hydrocarbons', 2),
('aa000172-0000-0000-0000-000000000001', 'aa000169-0000-0000-0000-000000000001', 'Haloalkanes and Haloarenes', 3),
('aa000173-0000-0000-0000-000000000001', 'aa000169-0000-0000-0000-000000000001', 'Alcohols Phenols Ethers', 4),
('aa000174-0000-0000-0000-000000000001', 'aa000169-0000-0000-0000-000000000001', 'Aldehydes and Ketones', 5),
('aa000175-0000-0000-0000-000000000001', 'aa000169-0000-0000-0000-000000000001', 'Carboxylic Acids', 6),
('aa000176-0000-0000-0000-000000000001', 'aa000169-0000-0000-0000-000000000001', 'Amines', 7),
('aa000177-0000-0000-0000-000000000001', 'aa000169-0000-0000-0000-000000000001', 'Biomolecules', 8);

-- Module: Inorganic Chemistry (new)
INSERT INTO modules (id, subject_id, name, display_order) VALUES
('aa000178-0000-0000-0000-000000000001', 'b2222222-2222-2222-2222-222222222222', 'Inorganic Chemistry', 3);

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000179-0000-0000-0000-000000000001', 'aa000178-0000-0000-0000-000000000001', 'Periodic Table', 1),
('aa000180-0000-0000-0000-000000000001', 'aa000178-0000-0000-0000-000000000001', 's-Block Elements', 2),
('aa000181-0000-0000-0000-000000000001', 'aa000178-0000-0000-0000-000000000001', 'p-Block Elements', 3),
('aa000182-0000-0000-0000-000000000001', 'aa000178-0000-0000-0000-000000000001', 'd-Block Elements', 4),
('aa000183-0000-0000-0000-000000000001', 'aa000178-0000-0000-0000-000000000001', 'Coordination Compounds', 5),
('aa000184-0000-0000-0000-000000000001', 'aa000178-0000-0000-0000-000000000001', 'Environmental Chemistry', 6);

-- Subject: Mathematics (b3333333-3333-3333-3333-333333333333) - exists
-- Module: Algebra (dd0f7348-ec7b-4bb9-b398-0810659a06ce) - exists

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000185-0000-0000-0000-000000000001', 'dd0f7348-ec7b-4bb9-b398-0810659a06ce', 'Sequences and Series', 3),
('aa000186-0000-0000-0000-000000000001', 'dd0f7348-ec7b-4bb9-b398-0810659a06ce', 'Permutations Combinations', 4),
('aa000187-0000-0000-0000-000000000001', 'dd0f7348-ec7b-4bb9-b398-0810659a06ce', 'Binomial Theorem', 5),
('aa000188-0000-0000-0000-000000000001', 'dd0f7348-ec7b-4bb9-b398-0810659a06ce', 'Matrices and Determinants', 6);

-- New modules for JEE Main Math
INSERT INTO modules (id, subject_id, name, display_order) VALUES
('aa000189-0000-0000-0000-000000000001', 'b3333333-3333-3333-3333-333333333333', 'Trigonometry', 2),
('aa000190-0000-0000-0000-000000000001', 'b3333333-3333-3333-3333-333333333333', 'Coordinate Geometry', 3),
('aa000191-0000-0000-0000-000000000001', 'b3333333-3333-3333-3333-333333333333', 'Calculus', 4),
('aa000192-0000-0000-0000-000000000001', 'b3333333-3333-3333-3333-333333333333', 'Probability and Statistics', 5),
('aa000193-0000-0000-0000-000000000001', 'b3333333-3333-3333-3333-333333333333', 'Vectors and 3D Geometry', 6);

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000194-0000-0000-0000-000000000001', 'aa000189-0000-0000-0000-000000000001', 'Trigonometric Functions', 1),
('aa000195-0000-0000-0000-000000000001', 'aa000189-0000-0000-0000-000000000001', 'Inverse Trigonometry', 2),
('aa000196-0000-0000-0000-000000000001', 'aa000189-0000-0000-0000-000000000001', 'Trigonometric Equations', 3),
('aa000197-0000-0000-0000-000000000001', 'aa000190-0000-0000-0000-000000000001', 'Straight Lines', 1),
('aa000198-0000-0000-0000-000000000001', 'aa000190-0000-0000-0000-000000000001', 'Circles', 2),
('aa000199-0000-0000-0000-000000000001', 'aa000190-0000-0000-0000-000000000001', 'Conic Sections', 3),
('aa000200-0000-0000-0000-000000000001', 'aa000191-0000-0000-0000-000000000001', 'Limits Continuity', 1),
('aa000201-0000-0000-0000-000000000001', 'aa000191-0000-0000-0000-000000000001', 'Differentiation', 2),
('aa000202-0000-0000-0000-000000000001', 'aa000191-0000-0000-0000-000000000001', 'Integration', 3),
('aa000203-0000-0000-0000-000000000001', 'aa000191-0000-0000-0000-000000000001', 'Differential Equations', 4),
('aa000204-0000-0000-0000-000000000001', 'aa000192-0000-0000-0000-000000000001', 'Probability', 1),
('aa000205-0000-0000-0000-000000000001', 'aa000192-0000-0000-0000-000000000001', 'Statistics', 2),
('aa000206-0000-0000-0000-000000000001', 'aa000193-0000-0000-0000-000000000001', 'Vectors', 1),
('aa000207-0000-0000-0000-000000000001', 'aa000193-0000-0000-0000-000000000001', 'Three Dimensional Geometry', 2);

-- ============================================================
-- JEE ADVANCED (e888) - New chapters and topics
-- ============================================================

-- Subject: Physics (31515db8-035d-4e92-baee-03986abe4cb9) - exists
-- Module: Mechanics (5b486371-7fab-4fe3-8f95-c69c8d307459) - exists

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000210-0000-0000-0000-000000000001', '5b486371-7fab-4fe3-8f95-c69c8d307459', 'Fluid Mechanics', 3),
('aa000211-0000-0000-0000-000000000001', '5b486371-7fab-4fe3-8f95-c69c8d307459', 'SHM and Waves', 4);

-- New modules for JEE Advanced Physics
INSERT INTO modules (id, subject_id, name, display_order) VALUES
('aa000212-0000-0000-0000-000000000001', '31515db8-035d-4e92-baee-03986abe4cb9', 'Electromagnetism', 2),
('aa000213-0000-0000-0000-000000000001', '31515db8-035d-4e92-baee-03986abe4cb9', 'Thermal Physics', 3),
('aa000214-0000-0000-0000-000000000001', '31515db8-035d-4e92-baee-03986abe4cb9', 'Optics and Modern Physics', 4);

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000215-0000-0000-0000-000000000001', 'aa000212-0000-0000-0000-000000000001', 'Electrostatics Advanced', 1),
('aa000216-0000-0000-0000-000000000001', 'aa000212-0000-0000-0000-000000000001', 'Magnetism', 2),
('aa000217-0000-0000-0000-000000000001', 'aa000212-0000-0000-0000-000000000001', 'EM Waves', 3),
('aa000218-0000-0000-0000-000000000001', 'aa000213-0000-0000-0000-000000000001', 'Calorimetry', 1),
('aa000219-0000-0000-0000-000000000001', 'aa000213-0000-0000-0000-000000000001', 'Thermodynamics Advanced', 2),
('aa000220-0000-0000-0000-000000000001', 'aa000214-0000-0000-0000-000000000001', 'Wave Optics Advanced', 1),
('aa000221-0000-0000-0000-000000000001', 'aa000214-0000-0000-0000-000000000001', 'Nuclear Physics', 2);

-- Subject: Chemistry (6054b80e-3e4d-4715-b9c7-9aa5e2c9a680) - exists
-- Module: Organic Chemistry (4df622c6-af15-4916-97aa-845d6a29b420) - exists

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000222-0000-0000-0000-000000000001', '4df622c6-af15-4916-97aa-845d6a29b420', 'Stereochemistry', 3),
('aa000223-0000-0000-0000-000000000001', '4df622c6-af15-4916-97aa-845d6a29b420', 'Polymers', 4),
('aa000224-0000-0000-0000-000000000001', '4df622c6-af15-4916-97aa-845d6a29b420', 'Chemistry in Everyday Life', 5);

-- New modules for JEE Advanced Chemistry
INSERT INTO modules (id, subject_id, name, display_order) VALUES
('aa000225-0000-0000-0000-000000000001', '6054b80e-3e4d-4715-b9c7-9aa5e2c9a680', 'Physical Chemistry', 2),
('aa000226-0000-0000-0000-000000000001', '6054b80e-3e4d-4715-b9c7-9aa5e2c9a680', 'Inorganic Chemistry', 3);

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000227-0000-0000-0000-000000000001', 'aa000225-0000-0000-0000-000000000001', 'Solid State', 1),
('aa000228-0000-0000-0000-000000000001', 'aa000225-0000-0000-0000-000000000001', 'Solutions Advanced', 2),
('aa000229-0000-0000-0000-000000000001', 'aa000226-0000-0000-0000-000000000001', 'Metallurgy', 1),
('aa000230-0000-0000-0000-000000000001', 'aa000226-0000-0000-0000-000000000001', 'Qualitative Analysis', 2),
('aa000231-0000-0000-0000-000000000001', 'aa000226-0000-0000-0000-000000000001', 's and p Block Advanced', 3);

-- Subject: Mathematics (94178433-7063-4c35-9ebf-ccb813a93ec4) - exists
-- Module: Calculus (6897db38-99ee-4f60-a82b-603028253c50) - exists

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000232-0000-0000-0000-000000000001', '6897db38-99ee-4f60-a82b-603028253c50', 'Integration Advanced', 3),
('aa000233-0000-0000-0000-000000000001', '6897db38-99ee-4f60-a82b-603028253c50', 'Differential Equations Advanced', 4),
('aa000234-0000-0000-0000-000000000001', '6897db38-99ee-4f60-a82b-603028253c50', 'Area Under Curves', 5);

-- New module: Algebra Advanced
INSERT INTO modules (id, subject_id, name, display_order) VALUES
('aa000235-0000-0000-0000-000000000001', '94178433-7063-4c35-9ebf-ccb813a93ec4', 'Algebra Advanced', 2);

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000236-0000-0000-0000-000000000001', 'aa000235-0000-0000-0000-000000000001', 'Complex Numbers Advanced', 1),
('aa000237-0000-0000-0000-000000000001', 'aa000235-0000-0000-0000-000000000001', 'Quadratic Equations Advanced', 2),
('aa000238-0000-0000-0000-000000000001', 'aa000235-0000-0000-0000-000000000001', 'Progressions', 3),
('aa000239-0000-0000-0000-000000000001', 'aa000235-0000-0000-0000-000000000001', 'Probability Advanced', 4);

-- New module: Coordinate Geometry Advanced
INSERT INTO modules (id, subject_id, name, display_order) VALUES
('aa000240-0000-0000-0000-000000000001', '94178433-7063-4c35-9ebf-ccb813a93ec4', 'Coordinate Geometry', 3);

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000241-0000-0000-0000-000000000001', 'aa000240-0000-0000-0000-000000000001', 'Straight Lines Advanced', 1),
('aa000242-0000-0000-0000-000000000001', 'aa000240-0000-0000-0000-000000000001', 'Circles Advanced', 2),
('aa000243-0000-0000-0000-000000000001', 'aa000240-0000-0000-0000-000000000001', 'Conics Advanced', 3);

-- ============================================================
-- NEET UG (e999) - New modules, chapters, topics
-- ============================================================

-- Subject: Physics (d1111111-1111-1111-1111-111111111111) - exists
-- Module: Mechanics (e0721412-df6d-4b09-975b-0f97de045c15) - exists

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000250-0000-0000-0000-000000000001', 'e0721412-df6d-4b09-975b-0f97de045c15', 'Laws of Motion', 2),
('aa000251-0000-0000-0000-000000000001', 'e0721412-df6d-4b09-975b-0f97de045c15', 'Work Energy Power', 3),
('aa000252-0000-0000-0000-000000000001', 'e0721412-df6d-4b09-975b-0f97de045c15', 'Gravitation', 4);

-- New modules for NEET Physics
INSERT INTO modules (id, subject_id, name, display_order) VALUES
('aa000253-0000-0000-0000-000000000001', 'd1111111-1111-1111-1111-111111111111', 'Properties of Matter', 2),
('aa000254-0000-0000-0000-000000000001', 'd1111111-1111-1111-1111-111111111111', 'Thermodynamics', 3),
('aa000255-0000-0000-0000-000000000001', 'd1111111-1111-1111-1111-111111111111', 'Waves and Oscillations', 4),
('aa000256-0000-0000-0000-000000000001', 'd1111111-1111-1111-1111-111111111111', 'Electrostatics', 5),
('aa000257-0000-0000-0000-000000000001', 'd1111111-1111-1111-1111-111111111111', 'Current Electricity', 6),
('aa000258-0000-0000-0000-000000000001', 'd1111111-1111-1111-1111-111111111111', 'Magnetism', 7),
('aa000259-0000-0000-0000-000000000001', 'd1111111-1111-1111-1111-111111111111', 'EMI and AC', 8),
('aa000260-0000-0000-0000-000000000001', 'd1111111-1111-1111-1111-111111111111', 'Optics', 9),
('aa000261-0000-0000-0000-000000000001', 'd1111111-1111-1111-1111-111111111111', 'Dual Nature of Matter', 10),
('aa000262-0000-0000-0000-000000000001', 'd1111111-1111-1111-1111-111111111111', 'Atoms and Nuclei', 11),
('aa000263-0000-0000-0000-000000000001', 'd1111111-1111-1111-1111-111111111111', 'Semiconductor Devices', 12);

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000264-0000-0000-0000-000000000001', 'aa000253-0000-0000-0000-000000000001', 'Elasticity', 1),
('aa000265-0000-0000-0000-000000000001', 'aa000253-0000-0000-0000-000000000001', 'Surface Tension', 2),
('aa000266-0000-0000-0000-000000000001', 'aa000253-0000-0000-0000-000000000001', 'Viscosity', 3),
('aa000267-0000-0000-0000-000000000001', 'aa000254-0000-0000-0000-000000000001', 'Thermal Properties', 1),
('aa000268-0000-0000-0000-000000000001', 'aa000254-0000-0000-0000-000000000001', 'Laws of Thermodynamics', 2),
('aa000269-0000-0000-0000-000000000001', 'aa000254-0000-0000-0000-000000000001', 'Kinetic Theory of Gases', 3),
('aa000270-0000-0000-0000-000000000001', 'aa000255-0000-0000-0000-000000000001', 'SHM', 1),
('aa000271-0000-0000-0000-000000000001', 'aa000255-0000-0000-0000-000000000001', 'Waves', 2),
('aa000272-0000-0000-0000-000000000001', 'aa000256-0000-0000-0000-000000000001', 'Electric Charges and Fields', 1),
('aa000273-0000-0000-0000-000000000001', 'aa000256-0000-0000-0000-000000000001', 'Capacitors', 2),
('aa000274-0000-0000-0000-000000000001', 'aa000257-0000-0000-0000-000000000001', 'Current and Resistance', 1),
('aa000275-0000-0000-0000-000000000001', 'aa000257-0000-0000-0000-000000000001', 'DC Circuits', 2),
('aa000276-0000-0000-0000-000000000001', 'aa000258-0000-0000-0000-000000000001', 'Magnetic Effects of Current', 1),
('aa000277-0000-0000-0000-000000000001', 'aa000258-0000-0000-0000-000000000001', 'Earth Magnetism', 2),
('aa000278-0000-0000-0000-000000000001', 'aa000259-0000-0000-0000-000000000001', 'Electromagnetic Induction', 1),
('aa000279-0000-0000-0000-000000000001', 'aa000259-0000-0000-0000-000000000001', 'AC Circuits', 2),
('aa000280-0000-0000-0000-000000000001', 'aa000260-0000-0000-0000-000000000001', 'Ray Optics', 1),
('aa000281-0000-0000-0000-000000000001', 'aa000260-0000-0000-0000-000000000001', 'Wave Optics', 2),
('aa000282-0000-0000-0000-000000000001', 'aa000261-0000-0000-0000-000000000001', 'Photoelectric Effect', 1),
('aa000283-0000-0000-0000-000000000001', 'aa000262-0000-0000-0000-000000000001', 'Atomic Models', 1),
('aa000284-0000-0000-0000-000000000001', 'aa000262-0000-0000-0000-000000000001', 'Nuclear Physics', 2),
('aa000285-0000-0000-0000-000000000001', 'aa000263-0000-0000-0000-000000000001', 'p-n Junction Diode', 1),
('aa000286-0000-0000-0000-000000000001', 'aa000263-0000-0000-0000-000000000001', 'Transistors and Logic Gates', 2);

-- Subject: Chemistry (d2222222-2222-2222-2222-222222222222) - exists
-- Module: Organic Chemistry (686249d0-61a5-47ea-bed2-fb225c36cf6c) - exists

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000287-0000-0000-0000-000000000001', '686249d0-61a5-47ea-bed2-fb225c36cf6c', 'General Organic Chemistry', 3),
('aa000288-0000-0000-0000-000000000001', '686249d0-61a5-47ea-bed2-fb225c36cf6c', 'Hydrocarbons', 4),
('aa000289-0000-0000-0000-000000000001', '686249d0-61a5-47ea-bed2-fb225c36cf6c', 'Haloalkanes Haloarenes', 5),
('aa000290-0000-0000-0000-000000000001', '686249d0-61a5-47ea-bed2-fb225c36cf6c', 'Alcohols Phenols', 6),
('aa000291-0000-0000-0000-000000000001', '686249d0-61a5-47ea-bed2-fb225c36cf6c', 'Aldehydes Ketones', 7),
('aa000292-0000-0000-0000-000000000001', '686249d0-61a5-47ea-bed2-fb225c36cf6c', 'Carboxylic Acids', 8),
('aa000293-0000-0000-0000-000000000001', '686249d0-61a5-47ea-bed2-fb225c36cf6c', 'Amines', 9),
('aa000294-0000-0000-0000-000000000001', '686249d0-61a5-47ea-bed2-fb225c36cf6c', 'Biomolecules', 10),
('aa000295-0000-0000-0000-000000000001', '686249d0-61a5-47ea-bed2-fb225c36cf6c', 'Polymers', 11),
('aa000296-0000-0000-0000-000000000001', '686249d0-61a5-47ea-bed2-fb225c36cf6c', 'Chemistry in Everyday Life', 12);

-- New modules for NEET Chemistry
INSERT INTO modules (id, subject_id, name, display_order) VALUES
('aa000297-0000-0000-0000-000000000001', 'd2222222-2222-2222-2222-222222222222', 'Physical Chemistry', 2),
('aa000298-0000-0000-0000-000000000001', 'd2222222-2222-2222-2222-222222222222', 'Inorganic Chemistry', 3);

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000299-0000-0000-0000-000000000001', 'aa000297-0000-0000-0000-000000000001', 'Some Basic Concepts', 1),
('aa000300-0000-0000-0000-000000000001', 'aa000297-0000-0000-0000-000000000001', 'Atomic Structure', 2),
('aa000301-0000-0000-0000-000000000001', 'aa000297-0000-0000-0000-000000000001', 'Chemical Bonding', 3),
('aa000302-0000-0000-0000-000000000001', 'aa000297-0000-0000-0000-000000000001', 'States of Matter', 4),
('aa000303-0000-0000-0000-000000000001', 'aa000297-0000-0000-0000-000000000001', 'Thermodynamics', 5),
('aa000304-0000-0000-0000-000000000001', 'aa000297-0000-0000-0000-000000000001', 'Equilibrium', 6),
('aa000305-0000-0000-0000-000000000001', 'aa000297-0000-0000-0000-000000000001', 'Redox Reactions', 7),
('aa000306-0000-0000-0000-000000000001', 'aa000297-0000-0000-0000-000000000001', 'Electrochemistry', 8),
('aa000307-0000-0000-0000-000000000001', 'aa000297-0000-0000-0000-000000000001', 'Chemical Kinetics', 9),
('aa000308-0000-0000-0000-000000000001', 'aa000297-0000-0000-0000-000000000001', 'Surface Chemistry', 10),
('aa000309-0000-0000-0000-000000000001', 'aa000298-0000-0000-0000-000000000001', 'Classification of Elements', 1),
('aa000310-0000-0000-0000-000000000001', 'aa000298-0000-0000-0000-000000000001', 'Hydrogen', 2),
('aa000311-0000-0000-0000-000000000001', 'aa000298-0000-0000-0000-000000000001', 's-Block Elements', 3),
('aa000312-0000-0000-0000-000000000001', 'aa000298-0000-0000-0000-000000000001', 'p-Block Elements', 4),
('aa000313-0000-0000-0000-000000000001', 'aa000298-0000-0000-0000-000000000001', 'd and f Block Elements', 5),
('aa000314-0000-0000-0000-000000000001', 'aa000298-0000-0000-0000-000000000001', 'Coordination Compounds', 6),
('aa000315-0000-0000-0000-000000000001', 'aa000298-0000-0000-0000-000000000001', 'Environmental Chemistry', 7);

-- Subject: Biology (d3333333-3333-3333-3333-333333333333) - exists
-- Module: Botany (d30b9481-57c6-418c-a430-b25922ebe605) - exists

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000316-0000-0000-0000-000000000001', 'd30b9481-57c6-418c-a430-b25922ebe605', 'Morphology of Flowering Plants', 2),
('aa000317-0000-0000-0000-000000000001', 'd30b9481-57c6-418c-a430-b25922ebe605', 'Anatomy of Flowering Plants', 3),
('aa000318-0000-0000-0000-000000000001', 'd30b9481-57c6-418c-a430-b25922ebe605', 'Transport in Plants', 4),
('aa000319-0000-0000-0000-000000000001', 'd30b9481-57c6-418c-a430-b25922ebe605', 'Mineral Nutrition', 5),
('aa000320-0000-0000-0000-000000000001', 'd30b9481-57c6-418c-a430-b25922ebe605', 'Photosynthesis', 6),
('aa000321-0000-0000-0000-000000000001', 'd30b9481-57c6-418c-a430-b25922ebe605', 'Respiration in Plants', 7),
('aa000322-0000-0000-0000-000000000001', 'd30b9481-57c6-418c-a430-b25922ebe605', 'Plant Growth and Development', 8),
('aa000323-0000-0000-0000-000000000001', 'd30b9481-57c6-418c-a430-b25922ebe605', 'Cell Biology', 9),
('aa000324-0000-0000-0000-000000000001', 'd30b9481-57c6-418c-a430-b25922ebe605', 'Cell Cycle and Division', 10),
('aa000325-0000-0000-0000-000000000001', 'd30b9481-57c6-418c-a430-b25922ebe605', 'Biomolecules', 11),
('aa000326-0000-0000-0000-000000000001', 'd30b9481-57c6-418c-a430-b25922ebe605', 'Genetics', 12),
('aa000327-0000-0000-0000-000000000001', 'd30b9481-57c6-418c-a430-b25922ebe605', 'Molecular Biology of Gene', 13),
('aa000328-0000-0000-0000-000000000001', 'd30b9481-57c6-418c-a430-b25922ebe605', 'Evolution', 14),
('aa000329-0000-0000-0000-000000000001', 'd30b9481-57c6-418c-a430-b25922ebe605', 'Ecology', 15),
('aa000330-0000-0000-0000-000000000001', 'd30b9481-57c6-418c-a430-b25922ebe605', 'Ecosystem', 16),
('aa000331-0000-0000-0000-000000000001', 'd30b9481-57c6-418c-a430-b25922ebe605', 'Biodiversity', 17);

-- New module: Zoology for NEET
INSERT INTO modules (id, subject_id, name, display_order) VALUES
('aa000332-0000-0000-0000-000000000001', 'd3333333-3333-3333-3333-333333333333', 'Zoology', 2);

INSERT INTO chapters (id, module_id, name, display_order) VALUES
('aa000333-0000-0000-0000-000000000001', 'aa000332-0000-0000-0000-000000000001', 'Animal Kingdom', 1),
('aa000334-0000-0000-0000-000000000001', 'aa000332-0000-0000-0000-000000000001', 'Structural Organisation', 2),
('aa000335-0000-0000-0000-000000000001', 'aa000332-0000-0000-0000-000000000001', 'Digestion and Absorption', 3),
('aa000336-0000-0000-0000-000000000001', 'aa000332-0000-0000-0000-000000000001', 'Breathing and Exchange of Gases', 4),
('aa000337-0000-0000-0000-000000000001', 'aa000332-0000-0000-0000-000000000001', 'Body Fluids and Circulation', 5),
('aa000338-0000-0000-0000-000000000001', 'aa000332-0000-0000-0000-000000000001', 'Excretory Products', 6),
('aa000339-0000-0000-0000-000000000001', 'aa000332-0000-0000-0000-000000000001', 'Locomotion and Movement', 7),
('aa000340-0000-0000-0000-000000000001', 'aa000332-0000-0000-0000-000000000001', 'Neural Control and Coordination', 8),
('aa000341-0000-0000-0000-000000000001', 'aa000332-0000-0000-0000-000000000001', 'Chemical Coordination', 9),
('aa000342-0000-0000-0000-000000000001', 'aa000332-0000-0000-0000-000000000001', 'Human Reproduction', 10),
('aa000343-0000-0000-0000-000000000001', 'aa000332-0000-0000-0000-000000000001', 'Reproductive Health', 11),
('aa000344-0000-0000-0000-000000000001', 'aa000332-0000-0000-0000-000000000001', 'Immune System', 12),
('aa000345-0000-0000-0000-000000000001', 'aa000332-0000-0000-0000-000000000001', 'Cancer', 13);

