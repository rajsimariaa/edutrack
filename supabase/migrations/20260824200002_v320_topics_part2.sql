-- v3.2.0 Part 2b: Topics for CA Final, CS Executive, CMA Foundation, CFA Level 1

-- CA FINAL: CAPM and APT
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000040-0000-0000-0000-000000000001', 'Capital Asset Pricing Model', 'E(Ri) = Rf + Bi[E(Rm) - Rf]. Required return compensates for systematic risk only. Unsystematic risk diversified away.', 1),
('aa000040-0000-0000-0000-000000000001', 'Beta and Systematic Risk', 'Beta measures sensitivity to market returns. Beta=1: same volatility. Beta>1: more volatile. Portfolio beta = weighted average.', 2),
('aa000040-0000-0000-0000-000000000001', 'Arbitrage Pricing Theory', 'Multi-factor model: E(R) = Rf + b1F1 + b2F2 + ... Factors: GDP, inflation, interest rates. Assumes no arbitrage.', 3);

-- CA FINAL: Bond Valuation
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000041-0000-0000-0000-000000000001', 'Bond Pricing Formula', 'Price = C*[(1-(1+r)^-n)/r] + FV/(1+r)^n. Price inversely related to yield. Premium when coupon > yield.', 1),
('aa000041-0000-0000-0000-000000000001', 'Duration and Price Sensitivity', 'Modified duration = Macaulay duration/(1+y). Price change % = -ModDur * yield change. Convexity improves accuracy.', 2);

-- CA FINAL: Mutual Fund Analysis
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000042-0000-0000-0000-000000000001', 'NAV Calculation', 'NAV = (Market value of assets - Liabilities) / Outstanding units. Calculated daily for open-ended funds.', 1),
('aa000042-0000-0000-0000-000000000001', 'Performance Measures', 'Alpha: excess return over benchmark. Sharpe: risk-adjusted return. Sortino: downside risk-adjusted. Information ratio: alpha/tracking error.', 2);

-- CA FINAL: Value at Risk
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000044-0000-0000-0000-000000000001', 'VaR Definition', 'Maximum expected loss over given period at given confidence level. Example: 1-day 95% VaR of Rs 10 lakh.', 1),
('aa000044-0000-0000-0000-000000000001', 'VaR Methods', 'Historical: past returns. Parametric: normal distribution. Monte Carlo: random scenarios. Each has strengths.', 2),
('aa000044-0000-0000-0000-000000000001', 'Expected Shortfall', 'Average of losses exceeding VaR. Also called CVaR. Better measure of tail risk than VaR alone.', 3);

-- CA FINAL: Derivatives Pricing
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000045-0000-0000-0000-000000000001', 'Black-Scholes Model', 'C = S*N(d1) - X*e^(-rT)*N(d2). Assumes no dividends, constant volatility, no arbitrage.', 1),
('aa000045-0000-0000-0000-000000000001', 'Put-Call Parity', 'C - P = S - X*e^(-rT). Violation creates arbitrage opportunity. Fundamental relationship in options pricing.', 2);

-- CA FINAL: Hedging Strategies
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000046-0000-0000-0000-000000000001', 'Hedge Ratios', 'Optimal = correlation*(sigma_spot/sigma_futures). Cross-hedging when no exact match. Effectiveness measured by variance reduction.', 1),
('aa000046-0000-0000-0000-000000000001', 'Currency Hedging', 'Forwards: lock exchange rate. Money market hedge: borrow/lend foreign currency. Options: protect against adverse moves.', 2);

-- CA FINAL: IFRS 15
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000048-0000-0000-0000-000000000001', 'Five-Step Revenue Model', '(1) Identify contract, (2) Identify performance obligations, (3) Determine transaction price, (4) Allocate price, (5) Recognize when obligation satisfied.', 1),
('aa000048-0000-0000-0000-000000000001', 'Variable Consideration', 'May include discounts, rebates, refunds, bonuses. Estimate using expected value or most likely amount. Constrain to highly probable of no reversal.', 2);

-- CA FINAL: IFRS 16
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000049-0000-0000-0000-000000000001', 'Lessee Accounting', 'Recognize right-of-use asset and lease liability at PV of lease payments. Depreciate asset, interest on liability. No operating/finance distinction.', 1),
('aa000049-0000-0000-0000-000000000001', 'Lease Modifications', 'Increases scope: separate lease if adds right-of-use and commensurate payment. Others: remeasure liability, adjust asset.', 2);

-- CA FINAL: IFRS 9
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000050-0000-0000-0000-000000000001', 'Classification Categories', 'Amortised cost: hold to collect. FVOCI: hold to collect and sell. FVPL: trading. Business model and cash flow tests.', 1),
('aa000050-0000-0000-0000-000000000001', 'Expected Credit Loss', 'Stage 1: 12-month ECL. Stage 2: lifetime ECL. Stage 3: credit-impaired. Forward-looking information required.', 2);

-- CS EXECUTIVE: Share Capital
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000051-0000-0000-0000-000000000001', 'Types of Share Capital', 'Authorized: maximum issuable. Issued: offered. Subscribed: taken up. Called-up: amount called. Paid-up: amount paid.', 1),
('aa000051-0000-0000-0000-000000000001', 'Allotment of Shares', 'Appropriation of shares to applicants. Must be within incorporation period. Cannot allot before minimum subscription.', 2),
('aa000051-0000-0000-0000-000000000001', 'Forfeiture and Re-issue', 'Forfeiture for non-payment of calls. Board resolution required. Re-issue at discount not exceeding forfeiture amount.', 3);

-- CS EXECUTIVE: Debentures
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000052-0000-0000-0000-000000000001', 'Debenture Types', 'Secured/Unsecured. Convertible/Non-convertible. Redeemable/Irredeemable. Debenture holders are creditors, not owners.', 1),
('aa000052-0000-0000-0000-000000000001', 'Debenture Trust Deed', 'Document between company and debenture holders. Contains terms, rights, security details, redemption provisions. Trustee protects interests.', 2);

-- CS EXECUTIVE: Management and Administration
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000053-0000-0000-0000-000000000001', 'Board of Directors', 'Min 3 for public, 2 for private. Max 15. Elected by shareholders. Powers: manage business, strategic decisions, appoint management.', 1),
('aa000053-0000-0000-0000-000000000001', 'Company Meetings', 'AGM: mandatory, within 6 months of FY end. EGM: urgent matters. Board meetings: quarterly, max 120 days gap.', 2),
('aa000053-0000-0000-0000-000000000001', 'Directors Liability', 'Fiduciary duty. Duty of care, skill, diligence. Cannot make secret profits. Must disclose interest. Disqualified persons cannot act.', 3);

-- CS EXECUTIVE: Winding Up
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000054-0000-0000-0000-000000000001', 'Modes of Winding Up', 'By Tribunal (compulsory). Voluntary: members (solvent) or creditors (insolvent). Continuation as company in liquidation.', 1),
('aa000054-0000-0000-0000-000000000001', 'Priority of Claims', 'Costs, secured creditors, workmen 24 months, employees 12 months, financial institutions, government, unsecured, preference, equity.', 2);

-- CS EXECUTIVE: Board of Directors
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000056-0000-0000-0000-000000000001', 'Appointment of Directors', 'By shareholders. Written consent required. DIN mandatory. Disqualification: unsound mind, insolvent, convicted.', 1),
('aa000056-0000-0000-0000-000000000001', 'Independent Directors', 'Min 1/3 for listed. Not less than 2. No material pecuniary relationship. Max 5 consecutive years. 3-year cooling off.', 2),
('aa000056-0000-0000-0000-000000000001', 'Woman Director', 'Mandatory for listed and certain public companies. At least one woman director.', 3);

-- CS EXECUTIVE: Committees
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000057-0000-0000-0000-000000000001', 'Audit Committee', 'Min 3 directors, majority independent. Chairman independent. Meet at least 4 times yearly. Reviews financial statements.', 1),
('aa000057-0000-0000-0000-000000000001', 'Nomination and Remuneration Committee', 'Min 3 directors, majority independent. Identifies qualified persons, recommends remuneration policy.', 2);

-- CS EXECUTIVE: Related Party Transactions
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000058-0000-0000-0000-000000000001', 'Definition of Related Party', 'Directors, relatives, KMP, their relatives, partner firms, subsidiaries, holding companies, associates.', 1),
('aa000058-0000-0000-0000-000000000001', 'Approval Requirements', 'Board approval for material RPTs. Shareholder approval for transactions >10% turnover. Audit committee reviews all.', 2);

-- CS EXECUTIVE: Factories Act
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000060-0000-0000-0000-000000000001', 'Applicability', 'Factories with 10+ workers (with power) or 20+ (without power). Registration with Chief Inspector required.', 1),
('aa000060-0000-0000-0000-000000000001', 'Working Hours', 'Max 48 hours/week, 9 hours/day. Overtime at double rate. 30 minutes rest after 5 hours continuous work.', 2),
('aa000060-0000-0000-0000-000000000001', 'Safety Provisions', 'Fencing of machinery, no child worker, no woman night shifts (exceptions). Safety officer for 1000+ workers.', 3);

-- CS EXECUTIVE: Shops and Establishments
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000061-0000-0000-0000-000000000001', 'Registration', 'Register within 30 days. Certificate displayed. Annual renewal in some states.', 1),
('aa000061-0000-0000-0000-000000000001', 'Employment Conditions', 'Max 8 hours/day, 48 hours/week. One holiday per week. Night shifts with women safety provisions.', 2);

-- CS EXECUTIVE: Payment of Wages Act
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000062-0000-0000-0000-000000000001', 'Coverage', 'Applies to employees earning up to Rs 24,000/month. Fixed wage period. Wages on working days.', 1),
('aa000062-0000-0000-0000-000000000001', 'Deductions', 'Authorized: fines, absence, damage, advances. Max 50% of wages in any period. No deduction for employer amenities.', 2);

-- CS EXECUTIVE: Minimum Wages Act
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000063-0000-0000-0000-000000000001', 'Minimum Wage Fixation', 'Central/state government fixes. Based on committee recommendations. Basic + DA. Reviewed every 5 years.', 1),
('aa000063-0000-0000-0000-000000000001', 'Employer Obligations', 'Pay minimum wages. Maintain register. Issue wage slips. No unauthorized deductions. Display abstract at workplace.', 2);

-- CS EXECUTIVE: Tax Laws
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000067-0000-0000-0000-000000000001', 'Residential Status', 'Resident: 182+ days OR 60+ days + 365 in 4 years. RNOR: resident but not ordinary. NR: neither. Tax liability depends on status.', 1),
('aa000067-0000-0000-0000-000000000001', 'Capital Gains', 'STCG: listed equity 15%, others slab. LTCG: listed >1L 10%, others 20% with indexation. Exemptions 54, 54EC, 54F.', 2);

INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000068-0000-0000-0000-000000000001', 'Tax Computation', 'Gross total income, clubbing, current year losses, Chapter VI-A deductions, slab rates, surcharge and cess.', 1),
('aa000068-0000-0000-0000-000000000001', 'Advance Tax', 'Required if liability >Rs 10,000. Installments: 15% Jun, 45% Sep, 75% Dec, 100% Mar. Interest 234A/B/C.', 2);

INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000069-0000-0000-0000-000000000001', 'GST Registration', 'Mandatory: turnover >Rs 40L (goods)/Rs 20L (services). Voluntary allowed. Form GST REG-01 within 30 days.', 1),
('aa000069-0000-0000-0000-000000000001', 'Composition Scheme', 'Small taxpayer. Turnover up to Rs 1.5 crore. Fixed percentage. Cannot collect tax. No ITC.', 2);

INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000070-0000-0000-0000-000000000001', 'GST Return Calendar', 'GSTR-1: 11th. GSTR-3B: 20th. GSTR-9: annual by 31st Dec. GSTR-9C for turnover >Rs 2 crore.', 1),
('aa000070-0000-0000-0000-000000000001', 'E-Invoicing', 'Mandatory for turnover >Rs 5 crore. IRP portal registration. IRN generated. B2B supplies only.', 2);

-- CMA FOUNDATION: Marginal Costing
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000071-0000-0000-0000-000000000001', 'Marginal Costing Concept', 'Variable costs charged to products. Fixed costs as period costs. Contribution = Sales - Variable. Profit = Contribution - Fixed.', 1),
('aa000071-0000-0000-0000-000000000001', 'CVP Analysis', 'BEP = Fixed Costs/Contribution per unit. P/V ratio = Contribution/Sales*100. Margin of safety = Actual - BEP sales.', 2),
('aa000071-0000-0000-0000-000000000001', 'Decision Making', 'Make or buy, accept/reject orders, continue/discontinue products, product mix with limiting factors, pricing.', 3);

-- CMA FOUNDATION: Standard Costing
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000072-0000-0000-0000-000000000001', 'Setting Standards', 'Ideal: perfection. Attainable: achievable. Basic: long-term base. Current: for current period. Used for variance analysis.', 1),
('aa000072-0000-0000-0000-000000000001', 'Variance Analysis', 'Material price = (SP-AP)*AQ. Usage = (SQ-AQ)*SP. Labor rate = (SR-AR)*AH. Efficiency = (SH-AH)*SR.', 2),
('aa000072-0000-0000-0000-000000000001', 'Responsibility for Variances', 'Purchase: material price. Production: usage, labor efficiency. HR: labor rate. Investigate significant variances only.', 3);

-- CMA FOUNDATION: Budgetary Control
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000073-0000-0000-0000-000000000001', 'Budget Types', 'Fixed: single activity level. Flexible: adjusts for different levels. Rolling: continuously updated. Zero-based: justify all from zero.', 1),
('aa000073-0000-0000-0000-000000000001', 'Master Budget Components', 'Sales, production, material, labor, overhead, cash budget, budgeted P&L and balance sheet. Coordinated by budget committee.', 2),
('aa000073-0000-0000-0000-000000000001', 'Variance Reporting', 'Actual vs Budget. Favorable: better. Adverse: worse. Investigate material variances. Corrective action. Feed-forward control.', 3);

-- CMA FOUNDATION: Permutations and Combinations
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000074-0000-0000-0000-000000000001', 'Permutation Formula', 'nPr = n!/(n-r)!. Order matters. Circular: (n-1)!. Repetition: n^r. Arrangements and ordering.', 1),
('aa000074-0000-0000-0000-000000000001', 'Combination Formula', 'nCr = n!/(r!(n-r)!). Order does not matter. nCr = nC(n-r). Selection and grouping.', 2);

-- CMA FOUNDATION: Binomial Theorem
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000075-0000-0000-0000-000000000001', 'Binomial Expansion', '(a+b)^n = Sum nCr*a^(n-r)*b^r. General term: T(r+1) = nCr*a^(n-r)*b^r.', 1),
('aa000075-0000-0000-0000-000000000001', 'Properties of Coefficients', 'Sum = 2^n. Alternating sum = 0. nC0+nC2+nC4 = nC1+nC3+nC5 = 2^(n-1).', 2);

-- CMA FOUNDATION: Sequences and Series
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000076-0000-0000-0000-000000000001', 'Arithmetic Progression', 'nth term: a+(n-1)d. Sum: n/2*(2a+(n-1)d). AM between a,b = (a+b)/2.', 1),
('aa000076-0000-0000-0000-000000000001', 'Geometric Progression', 'nth term: ar^(n-1). Sum: a(r^n-1)/(r-1). Infinite sum: a/(1-r) if |r|<1. GM = sqrt(ab).', 2),
('aa000076-0000-0000-0000-000000000001', 'Harmonic Progression', 'Reciprocals form AP. HM between a,b = 2ab/(a+b). HM < GM < AM always.', 3);

-- CMA FOUNDATION: Central Tendency
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000078-0000-0000-0000-000000000001', 'Mean Median Mode', 'Mean = sum/n. Median = middle value. Mode = most frequent. Grouped: median = L+(N/2-cf)/f*h.', 1),
('aa000078-0000-0000-0000-000000000001', 'Weighted Mean', 'Sum(weight*value)/Sum(weights). Different importance for observations.', 2),
('aa000078-0000-0000-0000-000000000001', 'Mean-Median-Mode Relationship', 'Mode = 3Median - 2Mean (approximate). Symmetric: all equal. Skewed: Mean > Median > Mode.', 3);

-- CMA FOUNDATION: Dispersion
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000079-0000-0000-0000-000000000001', 'Range and IQR', 'Range = Max-Min. IQR = Q3-Q1. Outlier: below Q1-1.5*IQR or above Q3+1.5*IQR.', 1),
('aa000079-0000-0000-0000-000000000001', 'Standard Deviation', 'Population: sqrt(sum(xi-mu)^2/N). Sample: sqrt(sum(xi-xbar)^2/(n-1)). CV = (SD/Mean)*100.', 2);

-- CMA FOUNDATION: Correlation and Regression
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000080-0000-0000-0000-000000000001', 'Pearson Correlation', 'r = sum((xi-xbar)(yi-ybar))/sqrt(sum(xi-xbar)^2*sum(yi-ybar)^2). Range -1 to +1. r^2 = coefficient of determination.', 1),
('aa000080-0000-0000-0000-000000000001', 'Simple Linear Regression', 'Y = a + bX. b = sum((xi-xbar)(yi-ybar))/sum(xi-xbar)^2. a = ybar-b*xbar. Least squares method.', 2);

-- CFA: Consumer Theory
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000010-0000-0000-0000-000000000001', 'Utility Maximization', 'Maximize utility subject to budget constraint. Optimal where budget line tangent to highest IC. MRS = Px/Py.', 1),
('aa000010-0000-0000-0000-000000000001', 'Indifference Curve Properties', 'Higher = higher utility. Never intersect. Convex. Slope = MRS = -MUx/MUy.', 2),
('aa000010-0000-0000-0000-000000000001', 'Substitution and Income Effects', 'Substitution: price change holding utility constant. Income: purchasing power change. Giffen: income > substitution.', 3);

-- CFA: Production Theory
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000011-0000-0000-0000-000000000001', 'Production Function', 'Q = f(K,L). Short run: one factor fixed. Diminishing returns: MP rises, falls, then negative.', 1),
('aa000011-0000-0000-0000-000000000001', 'Returns to Scale', 'Increasing: output more than proportional. Constant: proportional. Decreasing: less than proportional.', 2),
('aa000011-0000-0000-0000-000000000001', 'Cost Minimization', 'MPL/PL = MPK/PK. Isoquant: same output. Isocost: same cost.', 3);

-- CFA: Business Cycles
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000012-0000-0000-0000-000000000001', 'Phases of Business Cycle', 'Expansion: rising GDP. Peak: maximum. Contraction: falling GDP. Trough: lowest. Leading indicators predict turning points.', 1),
('aa000012-0000-0000-0000-000000000001', 'Economic Indicators', 'Leading: stock prices, permits. Coincident: GDP, production. Lagging: unemployment, CPI.', 2);

-- CFA: Monetary Policy
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000013-0000-0000-0000-000000000001', 'Central Bank Tools', 'OMO, reserve requirements, policy rates, MSF. Influences money supply and interest rates.', 1),
('aa000013-0000-0000-0000-000000000001', 'Transmission Mechanism', 'Policy rate affects lending rates, bond yields, exchange rates, asset prices. Takes time.', 2);

-- CFA: Fiscal Policy
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000014-0000-0000-0000-000000000001', 'Government Spending Multiplier', 'Multiplier = 1/(1-MPC). Tax multiplier = -MPC/(1-MPC). Balanced budget multiplier = 1.', 1),
('aa000014-0000-0000-0000-000000000001', 'Automatic Stabilizers', 'Progressive taxes, unemployment benefits. Act without explicit government action.', 2);

-- CFA: Income Statements
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000114-0000-0000-0000-000000000001', 'IAS 1 Income Statement', 'Nature or function method. Function: COGS, gross profit, operating expenses, operating income, PBT, tax, PAT.', 1),
('aa000114-0000-0000-0000-000000000001', 'EPS Calculation', 'Basic: (NI-Pref Div)/Weighted Avg Shares. Diluted: assumes dilutive security conversion.', 2);

-- CFA: Balance Sheets
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000115-0000-0000-0000-000000000001', 'Statement of Financial Position', 'Assets = Liabilities + Equity. Current: within 12 months. Non-current: PPE, intangibles, investments.', 1),
('aa000115-0000-0000-0000-000000000001', 'Equity Components', 'Share capital, premium, retained earnings, OCI, treasury stock. Changes: profit, dividends, shares.', 2);

-- CFA: Cash Flow Statements
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000116-0000-0000-0000-000000000001', 'Three Activities', 'Operating: core business. Investing: long-term assets. Financing: debt, equity, dividends. Net = O+I+F.', 1),
('aa000116-0000-0000-0000-000000000001', 'Indirect Method', 'Start with net income. Add non-cash items. Adjust working capital. Adjust non-operating items.', 2);

-- CFA: NPV and IRR
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000117-0000-0000-0000-000000000001', 'Net Present Value', 'NPV = sum of PV of all cash flows. NPV>0: accept. Accounts for time value of money.', 1),
('aa000117-0000-0000-0000-000000000001', 'Internal Rate of Return', 'Discount rate at NPV=0. IRR>required return: accept. Multiple IRRs possible for non-conventional flows.', 2);

-- CFA: Payback Period
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000118-0000-0000-0000-000000000001', 'Payback Period Method', 'Time to recover investment. Ignores cash flows after payback. Shorter preferred.', 1);

-- CFA: WACC
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000119-0000-0000-0000-000000000001', 'Weighted Average Cost of Capital', 'WACC = (E/V*Re)+(D/V*Rd*(1-T)). E=equity, D=debt, V=E+D. Re=cost of equity, Rd=cost of debt.', 1),
('aa000119-0000-0000-0000-000000000001', 'Cost of Equity', 'CAPM: Re=Rf+B(Rm-Rf). DDM: Re=D1/P0+g. Bond yield plus risk premium.', 2);

-- CFA: CAPM Application
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000120-0000-0000-0000-000000000001', 'Security Market Line', 'Plot of E(R) vs beta. Above SML: undervalued (positive alpha). Below: overvalued.', 1),
('aa000120-0000-0000-0000-000000000001', 'Portfolio Beta', 'Weighted average of individual betas. Risk-free: 0. Market: 1. Leveraged: BL=BU[1+(1-T)(D/E)].', 2);

-- CFA: EMH Forms
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000021-0000-0000-0000-000000000001', 'Weak Form Efficiency', 'Prices reflect past trading info. Technical analysis cannot earn excess returns.', 1),
('aa000021-0000-0000-0000-000000000001', 'Semi-Strong Efficiency', 'Prices reflect all public info. Fundamental analysis cannot earn excess returns.', 2),
('aa000021-0000-0000-0000-000000000001', 'Strong Form Efficiency', 'Prices reflect all info including insider. Even insiders cannot earn excess returns.', 3);

-- CFA: Porter Five Forces
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000022-0000-0000-0000-000000000001', 'Threat of New Entrants', 'Barriers: economies of scale, differentiation, capital, switching costs, distribution, government.', 1),
('aa000022-0000-0000-0000-000000000001', 'Bargaining Power', 'Suppliers: few substitutes, unique inputs, high switching costs. Buyers: many alternatives, low switching costs.', 2);

-- CFA: SWOT Analysis
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000023-0000-0000-0000-000000000001', 'SWOT Framework', 'Strengths: internal positive. Weaknesses: internal negative. Opportunities: external positive. Threats: external negative.', 1);

-- CFA: Duration and Convexity
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000124-0000-0000-0000-000000000001', 'Modified Duration', 'Duration = price sensitivity. ModDur = MacDur/(1+YTM/n). Price change = -ModDur*yield change.', 1),
('aa000124-0000-0000-0000-000000000001', 'Convexity', 'Measures curvature. Positive: price increase > decrease for same yield change. Improves estimate.', 2);

-- CFA: Bond Yield
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000125-0000-0000-0000-000000000001', 'Bond Yield Measures', 'Current yield = coupon/price. YTM: PV of cash flows = price. YTC: yield at call date.', 1);

-- CFA: Forward Pricing
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000126-0000-0000-0000-000000000001', 'Forward Price Formula', 'F = S*e^(rT). Cost of carry model. No arbitrage principle.', 1);

-- CFA: Covered Calls and Puts
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000127-0000-0000-0000-000000000001', 'Covered Call Strategy', 'Own stock + sell call. Income from premium. Upside limited. Neutral to moderately bullish.', 1);

-- CFA: Straddles and Strangles
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000128-0000-0000-0000-000000000001', 'Long Straddle', 'Buy call + put at same strike. Profit from large move. Max loss = premium.', 1),
('aa000128-0000-0000-0000-000000000001', 'Long Strangle', 'Buy OTM call + put. Cheaper but needs larger move.', 2);

-- CFA: REIT
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000129-0000-0000-0000-000000000001', 'REIT Analysis', 'NAV: fair value of properties minus liabilities. FFO: net income + depreciation - gains.', 1);

-- CFA: LBO
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000130-0000-0000-0000-000000000001', 'Leveraged Buyout', 'Acquisition using significant debt. Equity IRR = (exit-entry)/entry. Target 20-30% IRR.', 1);

-- CFA: Efficient Frontier
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000131-0000-0000-0000-000000000001', 'Markowitz Portfolio Theory', 'Efficient frontier: max return for given risk. Diversification reduces unsystematic risk.', 1);

-- CFA: Sharpe Ratio
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000132-0000-0000-0000-000000000001', 'Sharpe Ratio', '(Rp-Rf)/sigma_p. Risk-adjusted return. Higher is better. Excess return per unit total risk.', 1);

-- CFA: Asset Allocation
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000033-0000-0000-0000-000000000001', 'Strategic Asset Allocation', 'Long-term target weights. Tactical: short-term deviations. Core-satellite: core passive + active satellites.', 1);

-- CFA: Rebalancing
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000034-0000-0000-0000-000000000001', 'Portfolio Rebalancing', 'Restore target weights. Calendar/threshold/hybrid methods. Tax implications: sell high, buy low.', 1);

-- CFA: GIPS
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000081-0000-0000-0000-000000000001', 'GIPS Overview', 'Voluntary standards. Fair representation and full disclosure. Firm definition, compliant composites.', 1),
('aa000081-0000-0000-0000-000000000001', 'Composite Construction', 'All discretionary fee-paying portfolios in composites. Cannot cherry-pick.', 2);

-- CFA: Soft Dollar Standards
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000082-0000-0000-0000-000000000001', 'Soft Dollar Benefits', 'Commissions for research and brokerage. Must benefit investment process. Cannot use for admin costs.', 1);

-- CFA: Sampling Distributions
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000083-0000-0000-0000-000000000001', 'Central Limit Theorem', 'Sample mean distribution approaches normal. Mean = population mean. SE = sigma/sqrt(n).', 1);

-- CFA: Confidence Intervals
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000084-0000-0000-0000-000000000001', 'CI for Population Mean', 'xbar +/- z*(sigma/sqrt(n)). 95%: z=1.96. 99%: z=2.576. Narrower with larger n.', 1);

-- CFA: Linear Regression
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000085-0000-0000-0000-000000000001', 'Simple Linear Regression', 'Y = b0+b1X+e. b1 = corr*(Sy/Sx). R-squared = variance explained. t-test for b1.', 1),
('aa000085-0000-0000-0000-000000000001', 'Multiple Regression', 'Y = b0+b1X1+b2X2+e. Adjusted R2 penalizes variables. Multicollinearity: VIF>10 problematic.', 2);
