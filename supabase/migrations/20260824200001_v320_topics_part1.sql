-- v3.2.0 Part 2a: Topics for CA Inter, CA Final, CS Executive, CMA, CFA (non-science)

-- CA INTER: IAS 1
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000001-0000-0000-0000-000000000001', 'IAS 1 Components', 'Financial statements comprise: Statement of Financial Position, Statement of Comprehensive Income, Statement of Changes in Equity, Statement of Cash Flows, and Notes. Must be prepared at least annually.', 1),
('aa000001-0000-0000-0000-000000000001', 'Going Concern under IAS 1', 'IAS 1 requires management to assess entity going concern. If significant doubt, must be disclosed. Assets and liabilities classified as current/non-current based on this assessment.', 2),
('aa000001-0000-0000-0000-000000000001', 'Materiality and Aggregation', 'IAS 1 requires material items presented separately. Immaterial items may be aggregated. Materiality depends on size and nature relative to entity.', 3),
('aa000001-0000-0000-0000-000000000001', 'Comparative Information', 'IAS 1 requires comparative information for prior periods for all amounts. If entity changes presentation, prior periods reclassified unless impracticable.', 4);

-- CA INTER: IAS 16
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000002-0000-0000-0000-000000000001', 'Recognition of PPE', 'PPE recognized when: (1) probable future economic benefits will flow, (2) cost measured reliably. Initial cost includes purchase price + directly attributable costs.', 1),
('aa000002-0000-0000-0000-000000000001', 'Subsequent Measurement Models', 'Cost Model: carried at cost less depreciation and impairment. Revaluation Model: carried at fair value less subsequent depreciation. Must be applied to entire class.', 2),
('aa000002-0000-0000-0000-000000000001', 'Depreciation under IAS 16', 'Depreciation begins when asset available for use. Method reflects expected consumption pattern. Residual value and useful life reviewed annually. Component depreciation required.', 3),
('aa000002-0000-0000-0000-000000000001', 'Subsequent Expenditure', 'Recognized only if increases future economic benefits beyond original assessment. Repairs and maintenance expensed. Improvements and replacements may be capitalized.', 4);

-- CA INTER: IAS 38
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000003-0000-0000-0000-000000000001', 'Recognition of Intangibles', 'Internally generated: Research = expense. Development = capitalize if 6 criteria met: technical feasibility, intention to complete, ability to use/sell, probable benefits, reliable measurement, adequate resources.', 1),
('aa000003-0000-0000-0000-000000000001', 'Internally Generated Brands', 'Brands, mastheads, customer lists cannot be recognized as intangibles because not separable nor arise from contractual/legal rights.', 2),
('aa000003-0000-0000-0000-000000000001', 'Useful Life Assessment', 'Indefinite life: no foreseeable limit on use period. Tested for impairment annually. Finite life: amortized over useful life. Review residual value and useful life annually.', 3);

-- CA INTER: IAS 36
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000004-0000-0000-0000-000000000001', 'Impairment Indicators', 'Internal: damage, obsolescence, worse performance. External: market decline, adverse technology/legal changes, interest rate increases.', 1),
('aa000004-0000-0000-0000-000000000001', 'Recoverable Amount', 'Higher of Fair Value Less Costs of Disposal (FVLCD) and Value in Use (VIU). VIU = present value of future cash flows from continuing use and disposal.', 2),
('aa000004-0000-0000-0000-000000000001', 'Impairment Loss Recognition', 'Loss = Carrying amount - Recoverable amount. Recognized in P&L. For CGU, allocated first to goodwill, then pro rata. Cannot reverse goodwill impairment.', 3);

-- CA INTER: IAS 37
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000005-0000-0000-0000-000000000001', 'Provision Recognition Criteria', 'Recognize when: (1) present obligation from past event, (2) probable outflow, (3) reliable estimate. Mere intention does not create provision.', 1),
('aa000005-0000-0000-0000-000000000001', 'Onerous Contracts', 'Unavoidable costs exceed benefits. Present obligation recognized as provision. Example: lease on unprofitable factory.', 2),
('aa000005-0000-0000-0000-000000000001', 'Restructuring Provisions', 'Recognized when: detailed formal plan, main features communicated, no further board approval needed. Cannot include future operating losses.', 3);

-- CA INTER: IFRS 3
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000006-0000-0000-0000-000000000001', 'Acquisition Method', 'Steps: (1) Identify acquirer, (2) Determine acquisition date, (3) Recognize identifiable assets/liabilities at fair value, (4) Recognize goodwill or bargain purchase gain.', 1),
('aa000006-0000-0000-0000-000000000001', 'Goodwill Calculation', 'Goodwill = Consideration + NCI fair value + FV previously held interest - Net identifiable assets. Recognized as asset, tested annually for impairment.', 2),
('aa000006-0000-0000-0000-000000000001', 'Measurement of Consideration', 'Consideration at fair value: cash, other assets, equity instruments, liabilities. Contingent consideration at fair value at acquisition, remeasured through P&L.', 3);

-- CA INTER: IFRS 10
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000007-0000-0000-0000-000000000001', 'Control Concept', 'Control = power over investee + exposure to variable returns + ability to use power to affect returns. Presumed at >50% voting rights.', 1),
('aa000007-0000-0000-0000-000000000001', 'Consolidation Procedures', 'Eliminate parent investment against subsidiary equity. Eliminate intra-group balances and transactions. Combine like items.', 2),
('aa000007-0000-0000-0000-000000000001', 'Non-Controlling Interest', 'NCI presented separately in equity. Measured at fair value or proportionate share. Share of profit allocated between parent and NCI.', 3);

-- CA INTER: IFRS 11
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000008-0000-0000-0000-000000000001', 'Joint Operation vs Joint Venture', 'Joint Operation: rights to assets and obligations for liabilities. Joint Venture: rights to net assets. Classification depends on structure, legal form, terms.', 1),
('aa000008-0000-0000-0000-000000000001', 'Accounting for Joint Operations', 'Recognize assets, liabilities, revenues, expenses for your share. Similar to accounting for individual assets/liabilities.', 2);

-- CA INTER: IFRS 13
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000009-0000-0000-0000-000000000001', 'Fair Value Definition', 'Price received to sell asset or paid to transfer liability in orderly transaction between market participants at measurement date (exit price).', 1),
('aa000009-0000-0000-0000-000000000001', 'Fair Value Hierarchy', 'Level 1: quoted prices for identical items. Level 2: observable inputs. Level 3: unobservable inputs. Maximize Level 1.', 2),
('aa000009-0000-0000-0000-000000000001', 'Highest and Best Use', 'Fair value assumes highest and best use. Must be consistent with use in market and with other complementary assets.', 3);

-- CA INTER: Audit Evidence
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000010-0000-0000-0000-000000000001', 'Sufficient Appropriate Evidence', 'Sufficiency = quantity. Appropriateness = relevance and reliability. More risk = more evidence needed.', 1),
('aa000010-0000-0000-0000-000000000001', 'Audit Procedures', 'Inspection, observation, inquiry, confirmation, recalculation, reperformance, analytical procedures. Selection depends on assertion tested.', 2),
('aa000010-0000-0000-0000-000000000001', 'Management Assertions', 'Transactions: occurrence, completeness, accuracy, cutoff, classification. Balances: existence, rights/obligations, completeness, valuation.', 3);

-- CA INTER: Audit Sampling
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000011-0000-0000-0000-000000000001', 'Statistical vs Non-Statistical', 'Statistical uses random selection and probability theory. Non-statistical uses auditor judgment. Both require professional judgment.', 1),
('aa000011-0000-0000-0000-000000000001', 'Sampling Risk', 'Risk auditor conclusion differs from testing entire population. Reduce by increasing sample size.', 2);

-- CA INTER: Audit Report
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000012-0000-0000-0000-000000000001', 'Types of Audit Opinions', 'Unmodified: fairly presented. Qualified: except for certain matters. Adverse: material misstatement throughout. Disclaimer: unable to form opinion.', 1),
('aa000012-0000-0000-0000-000000000001', 'Key Audit Matters', 'Communicated in listed entity audits. Matters of most significance. Not required for all audits.', 2);

-- CA INTER: Company Audit
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000013-0000-0000-0000-000000000001', 'Rotation of Auditors', 'Individual auditor rotation every 5 years, firm rotation every 10 years for listed companies. Ensures independence.', 1),
('aa000013-0000-0000-0000-000000000001', 'Rights of Company Auditor', 'Access books, obtain information, attend general meeting, report to members on accounts examined.', 2);

-- CA INTER: Cost Audit
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000014-0000-0000-0000-000000000001', 'Cost Audit Requirements', 'Manufacturing companies must get cost records audited. Cost auditor must be Cost Accountant in Practice.', 1),
('aa000014-0000-0000-0000-000000000001', 'Cost Audit Report Contents', 'States whether cost records maintained, cost statements give true and fair view, compliance with cost accounting standards.', 2);

-- CA INTER: Process Costing
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000021-0000-0000-0000-000000000001', 'Process Costing Method', 'Continuous production of homogeneous products. Costs accumulated by process. Equivalent units calculated for WIP.', 1),
('aa000021-0000-0000-0000-000000000001', 'Equivalent Units', 'Work done expressed as completed units. 100 units 50% complete = 50 equivalent units. Used to allocate costs.', 2),
('aa000021-0000-0000-0000-000000000001', 'Normal and Abnormal Loss', 'Normal: inherent to process, cost absorbed by good units. Abnormal: unexpected, charged to costing P&L.', 3);

-- CA INTER: Job Costing
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000022-0000-0000-0000-000000000001', 'Job Order Costing', 'Costs accumulated for each distinct job. Job cost sheet tracks material, labor, overheads. Used in construction, shipbuilding.', 1),
('aa000022-0000-0000-0000-000000000001', 'Overhead Absorption', 'Predetermined rate calculated. Applied based on labor hours, machine hours. Under/over absorption adjusted at period end.', 2);

-- CA INTER: Activity Based Costing
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000023-0000-0000-0000-000000000001', 'ABC Costing Concept', 'Costs assigned to activities first, then to cost objects. More accurate for complex product mixes. Identifies cost drivers.', 1),
('aa000023-0000-0000-0000-000000000001', 'Cost Drivers', 'Factors causing cost change: setups, orders, machine hours, inspection hours. Activity rate = Total cost / Driver volume.', 2);

-- CA INTER: Heads of Income
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000033-0000-0000-0000-000000000001', 'Five Heads of Income', '(1) Salary, (2) House Property, (3) Business/Profession, (4) Capital Gains, (5) Other Sources. Each has specific computation provisions.', 1),
('aa000033-0000-0000-0000-000000000001', 'Salary Computation', 'Gross salary minus exemptions. Deductions under Section 16: standard deduction, entertainment allowance, professional tax.', 2),
('aa000033-0000-0000-0000-000000000001', 'House Property Income', 'NAV = GAV minus Municipal Taxes. Standard deduction 30%. Interest on borrowed capital deductible. Self-occupied vs let out.', 3);

-- CA INTER: Deductions
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000034-0000-0000-0000-000000000001', 'Section 80C Deductions', 'Max Rs 1.5 lakh. LIC, PPF, NSC, ELSS, EPF, home loan principal, Sukanya Samriddhi, 5-year FD, tuition fees.', 1),
('aa000034-0000-0000-0000-000000000001', 'Section 80D Health Insurance', 'Self/family: Rs 25,000 (Rs 50,000 senior). Parents: additional Rs 25,000. Prevention check-up Rs 5,000.', 2),
('aa000034-0000-0000-0000-000000000001', 'Section 80G Donations', '100% or 50% deduction. Qualifying limit 10% adjusted GTI. Approved funds, institutions, PM CARES.', 3);

-- CA INTER: Assessment of Individuals
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000035-0000-0000-0000-000000000001', 'Income Tax Slabs 2026', 'Old: 0-2.5L nil, 2.5-5L 5%, 5-10L 20%, 10L+ 30%. New: 0-3L nil, 3-6L 5%, 6-9L 10%, 9-12L 15%, 12-15L 20%, 15L+ 30%.', 1),
('aa000035-0000-0000-0000-000000000001', 'Surcharge and Cess', 'Surcharge: 10%-37% based on income slabs. Health and Education Cess: 4% on tax + surcharge.', 2);

-- CA INTER: GST Supply
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000036-0000-0000-0000-000000000001', 'Types of Supply', 'Taxable: attracts GST. Exempt: no GST. Zero-rated: exports. Reverse charge: recipient pays. Mixed: multiple supplies at highest rate.', 1),
('aa000036-0000-0000-0000-000000000001', 'Time of Supply', 'Forward: earliest of invoice, payment, or availability. Reverse: earliest of payment or 30 days after invoice.', 2),
('aa000036-0000-0000-0000-000000000001', 'Place of Supply', 'Goods: location where movement terminates. Services B2B: recipient location. B2C: supplier location.', 3);

-- CA INTER: Input Tax Credit
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000037-0000-0000-0000-000000000001', 'ITC Conditions', 'Must have tax invoice, received goods/services, tax paid, filed return, not on exempt/negative list.', 1),
('aa000037-0000-0000-0000-000000000001', 'Blocked Credits', 'Not available: motor vehicles, food/beverages, beauty treatment, health services, club memberships.', 2),
('aa000037-0000-0000-0000-000000000001', 'Reversal of ITC', 'Reversed when: goods returned, payment not within 180 days, partial exempt use. Through ITC-04 or GSTR-3B.', 3);

-- CA INTER: GST Returns
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000038-0000-0000-0000-000000000001', 'GSTR-1 Filing', 'Monthly/quarterly outward supplies return. Due: 11th monthly or 13th after quarter. Invoice-wise B2B details.', 1),
('aa000038-0000-0000-0000-000000000001', 'GSTR-3B Filing', 'Monthly self-declaration. Summary of outward supplies, ITC, tax payment. Due: 20th of following month.', 2);
