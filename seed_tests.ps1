$ErrorActionPreference = "Continue"

$headers = @{
    "apikey"       = "sb_publishable_gmhfQyBzPt8cLMOSa_E26A_UvEjFOMC"
    "Authorization" = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJkZHJ1YmtiZ2tia3J0eG9ka3N2Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NzI4Nzc1NiwiZXhwIjoyMTAyODYzNzU2fQ.57KGPc-pqsOyVv-TBTldX0siuDtcRbGdYHGL7CfuTQ0"
    "Content-Type" = "application/json"
    "Prefer"       = "return=representation"
}

$baseUrl = "https://rddrubkbgkbkrtxodksv.supabase.co/rest/v1"

# ============================================================
# STEP 1: Insert all 17 tests
# ============================================================
Write-Host "=== STEP 1: Inserting 17 tests ===" -ForegroundColor Cyan

$testsJson = @'
[
  {"exam_id":"e1111111-1111-1111-1111-111111111111","title":"CA Foundation - Business Economics","description":"Demand and supply analysis, elasticity, market equilibrium","total_marks":25,"duration_mins":30,"week_number":1,"year":2026,"is_published":true},
  {"exam_id":"e1111111-1111-1111-1111-111111111111","title":"CA Foundation - Business Laws","description":"Indian Contract Act, void agreements, consent","total_marks":25,"duration_mins":30,"week_number":1,"year":2026,"is_published":true},
  {"exam_id":"e2222222-2222-2222-2222-222222222222","title":"CA Intermediate - Cost Accounting","description":"Elements of cost, prime cost, works cost, overheads","total_marks":25,"duration_mins":30,"week_number":2,"year":2026,"is_published":true},
  {"exam_id":"e2222222-2222-2222-2222-222222222222","title":"CA Intermediate - Tax Laws","description":"GST, ITC, Income Tax deductions, TDS","total_marks":25,"duration_mins":30,"week_number":2,"year":2026,"is_published":true},
  {"exam_id":"e3333333-3333-3333-3333-333333333333","title":"CA Final - Direct Tax Laws","description":"MAT, transfer pricing, capital gains, DTAA","total_marks":25,"duration_mins":30,"week_number":3,"year":2026,"is_published":true},
  {"exam_id":"e3333333-3333-3333-3333-333333333333","title":"CA Final - Advanced Auditing","description":"Audit risk, materiality, substantive procedures","total_marks":25,"duration_mins":30,"week_number":3,"year":2026,"is_published":true},
  {"exam_id":"e4444444-4444-4444-4444-444444444444","title":"CS Executive - Jurisprudence","description":"Administrative law, natural justice, writs","total_marks":25,"duration_mins":30,"week_number":4,"year":2026,"is_published":true},
  {"exam_id":"e4444444-4444-4444-4444-444444444444","title":"CS Executive - Economic Laws","description":"SEBI, FEMA, insider trading, competition law","total_marks":25,"duration_mins":30,"week_number":4,"year":2026,"is_published":true},
  {"exam_id":"e5555555-5555-5555-5555-555555555555","title":"CMA Foundation - Economics","description":"Opportunity cost, demand curve, consumer surplus","total_marks":25,"duration_mins":30,"week_number":5,"year":2026,"is_published":true},
  {"exam_id":"e6666666-6666-6666-6666-666666666666","title":"CFA Level 1 - Financial Reporting","description":"IFRS 15, IFRS 9, goodwill impairment, lease accounting","total_marks":25,"duration_mins":30,"week_number":5,"year":2026,"is_published":true},
  {"exam_id":"e6666666-6666-6666-6666-666666666666","title":"CFA Level 1 - Economics","description":"GDP deflator, fiscal policy, Phillips curve, PPP","total_marks":25,"duration_mins":30,"week_number":5,"year":2026,"is_published":true},
  {"exam_id":"e7777777-7777-7777-7777-777777777777","title":"JEE Main Chemistry - Organic","description":"Hybridization, addition reactions, Markovnikov rule","total_marks":25,"duration_mins":30,"week_number":6,"year":2026,"is_published":true},
  {"exam_id":"e7777777-7777-7777-7777-777777777777","title":"JEE Main Chemistry - Inorganic","description":"Mole concept, pH, bonding, molecular weight","total_marks":25,"duration_mins":30,"week_number":6,"year":2026,"is_published":true},
  {"exam_id":"e8888888-8888-8888-8888-888888888888","title":"JEE Advanced Physics - Electromagnetism","description":"Gauss law, electric field, capacitance, Faraday law","total_marks":25,"duration_mins":30,"week_number":7,"year":2026,"is_published":true},
  {"exam_id":"e8888888-8888-8888-8888-888888888888","title":"JEE Advanced Mathematics - Algebra","description":"Determinants, eigenvalues, matrix operations, rank","total_marks":25,"duration_mins":30,"week_number":7,"year":2026,"is_published":true},
  {"exam_id":"e9999999-9999-9999-9999-999999999999","title":"NEET UG Chemistry - Physical Chemistry","description":"Avogadro number, STP, pH, bond order, enthalpy","total_marks":25,"duration_mins":30,"week_number":8,"year":2026,"is_published":true},
  {"exam_id":"e9999999-9999-9999-9999-999999999999","title":"NEET UG Biology - Zoology","description":"RBC production, DNA, chromosomes, classification","total_marks":25,"duration_mins":30,"week_number":8,"year":2026,"is_published":true}
]
'@

try {
    $testsResult = Invoke-RestMethod -Uri "$baseUrl/tests?select=id,title" -Method Post -Headers $headers -Body $testsJson
    Write-Host "Inserted $($testsResult.Count) tests successfully!" -ForegroundColor Green
    $testsResult | ForEach-Object { Write-Host "  $($_.title) -> $($_.id)" }
} catch {
    Write-Host "ERROR inserting tests: $_" -ForegroundColor Red
    exit 1
}

# Map test titles to IDs
$testMap = @{}
foreach ($t in $testsResult) { $testMap[$t.title] = $t.id }

Start-Sleep -Seconds 2

# ============================================================
# STEP 2: Insert questions for each test
# ============================================================
Write-Host "`n=== STEP 2: Inserting questions ===" -ForegroundColor Cyan

$questionsSuccess = 0
$questionsFailed = 0

function Insert-Questions {
    param([string]$testTitle, [string]$questionsJson)
    $tid = $script:testMap[$testTitle]
    if (-not $tid) { Write-Host "  SKIP: No test ID for '$testTitle'" -ForegroundColor Yellow; return }
    
    $body = $questionsJson -replace "TEST_ID_PLACEHOLDER", $tid
    try {
        $r = Invoke-RestMethod -Uri "$baseUrl/test_questions?select=id" -Method Post -Headers $headers -Body $body
        $count = if ($r -is [array]) { $r.Count } else { 1 }
        $script:questionsSuccess += $count
        Write-Host "  OK: $testTitle -> $count questions" -ForegroundColor Green
    } catch {
        $script:questionsFailed++
        Write-Host "  FAIL: $testTitle -> $_" -ForegroundColor Red
    }
    Start-Sleep -Milliseconds 500
}

# ---- Test 1: CA Foundation - Business Economics ----
$q1 = @'
[
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Which factor does NOT shift demand curve?","options":{"a":"Price","b":"Income","c":"Taste","d":"Population"},"correct_option_index":0,"explanation":"Price causes movement along the curve, not a shift.","topic_id":"3ccc0b13-29c4-4582-b2f3-e6c01c0da6fc"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"When supply increases and demand stays constant, price...","options":{"a":"Rises","b":"Falls","c":"Stays same","d":"Doubles"},"correct_option_index":1,"explanation":"Excess supply puts downward pressure on price.","topic_id":"3ccc0b13-29c4-4582-b2f3-e6c01c0da6fc"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Elasticity of demand measures...","options":{"a":"Total revenue","b":"Price sensitivity","c":"Supply capacity","d":"Cost of production"},"correct_option_index":1,"explanation":"It measures how much quantity demanded responds to price changes.","topic_id":"3ccc0b13-29c4-4582-b2f3-e6c01c0da6fc"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"A normal good has income elasticity that is...","options":{"a":"Negative","b":"Zero","c":"Positive","d":"Undefined"},"correct_option_index":2,"explanation":"Demand rises with income for normal goods.","topic_id":"3ccc0b13-29c4-4582-b2f3-e6c01c0da6fc"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Equilibrium occurs where...","options":{"a":"Supply is max","b":"Demand is max","c":"Supply equals demand","d":"Price is zero"},"correct_option_index":2,"explanation":"Market equilibrium is at the intersection of supply and demand.","topic_id":"3ccc0b13-29c4-4582-b2f3-e6c01c0da6fc"}
]
'@
Insert-Questions "CA Foundation - Business Economics" $q1

# ---- Test 2: CA Foundation - Business Laws ----
$q2 = @'
[
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Minimum parties for a valid contract:","options":{"a":"One","b":"Two","c":"Three","d":"Four"},"correct_option_index":1,"explanation":"A contract requires at least two parties.","topic_id":"6a6c19bc-14da-4071-a44d-17a26079b5ae"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"A void agreement is...","options":{"a":"Voidable","b":"Enforceable","c":"Not enforceable by law","d":"Partially valid"},"correct_option_index":2,"explanation":"Void agreements have no legal effect from the beginning.","topic_id":"6398d255-ceab-43c0-a4b4-9219ffb1eb10"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Consideration in a contract means...","options":{"a":"Love and affection","b":"Something in return","c":"Good faith","d":"Registration"},"correct_option_index":1,"explanation":"Section 2(d) of Indian Contract Act requires consideration.","topic_id":"6a6c19bc-14da-4071-a44d-17a26079b5ae"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"A minor's agreement is...","options":{"a":"Valid","b":"Voidable","c":"Void","d":"Valid if ratified"},"correct_option_index":2,"explanation":"Agreements with minors are void ab initio.","topic_id":"6398d255-ceab-43c0-a4b4-9219ffb1eb10"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"An agreement without free consent is...","options":{"a":"Valid","b":"Void","c":"Voidable","d":"Illegal"},"correct_option_index":2,"explanation":"Lack of free consent makes an agreement voidable.","topic_id":"6a6c19bc-14da-4071-a44d-17a26079b5ae"}
]
'@
Insert-Questions "CA Foundation - Business Laws" $q2

# ---- Test 3: CA Intermediate - Cost Accounting ----
$q3 = @'
[
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Which is NOT an element of cost?","options":{"a":"Material","b":"Labour","c":"Interest","d":"Overheads"},"correct_option_index":2,"explanation":"Interest is not a direct element of cost accounting.","topic_id":"df6d3d90-3fa4-417b-afa8-4b69b3936680"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Prime cost equals...","options":{"a":"Material + Labour","b":"Material + Overheads","c":"Direct Material + Direct Labour + Direct Expenses","d":"All costs"},"correct_option_index":2,"explanation":"Prime cost = Direct Material + Direct Labour + Direct Expenses.","topic_id":"df6d3d90-3fa4-417b-afa8-4b69b3936680"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Works cost includes...","options":{"a":"Prime cost only","b":"Factory overheads only","c":"Prime cost + Factory overheads","d":"Selling expenses"},"correct_option_index":2,"explanation":"Works cost = Prime cost + Factory/Manufacturing overheads.","topic_id":"df6d3d90-3fa4-417b-afa8-4b69b3936680"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Direct expenses are those which...","options":{"a":"Cannot be traced","b":"Can be directly charged to cost object","c":"Are always variable","d":"Are fixed"},"correct_option_index":1,"explanation":"Direct expenses can be specifically identified with a cost object.","topic_id":"df6d3d90-3fa4-417b-afa8-4b69b3936680"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Factory overheads include...","options":{"a":"Raw material cost","b":"Factory rent and power","c":"Sales commission","d":"Office salary"},"correct_option_index":1,"explanation":"Factory overheads include rent, power, depreciation of factory assets.","topic_id":"df6d3d90-3fa4-417b-afa8-4b69b3936680"}
]
'@
Insert-Questions "CA Intermediate - Cost Accounting" $q3

# ---- Test 4: CA Intermediate - Tax Laws ----
$q4 = @'
[
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"For GST, the threshold for registration in India is approximately...","options":{"a":"5 lakh","b":"10 lakh","c":"20 lakh","d":"40 lakh"},"correct_option_index":3,"explanation":"For most states, GST registration threshold is Rs.40 lakh.","topic_id":"22480910-0a6c-4d97-9c23-37bd040d140c"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Input Tax Credit (ITC) allows...","options":{"a":"Tax deduction","b":"Tax refund on inputs","c":"Tax paid on inputs to be set off against output tax","d":"No benefit"},"correct_option_index":2,"explanation":"ITC lets businesses claim credit for GST paid on inputs.","topic_id":"22480910-0a6c-4d97-9c23-37bd040d140c"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Section 80C of Income Tax Act provides deduction up to...","options":{"a":"1 lakh","b":"1.5 lakh","c":"2 lakh","d":"2.5 lakh"},"correct_option_index":1,"explanation":"Section 80C allows deductions up to Rs.1.5 lakh per annum.","topic_id":"22480910-0a6c-4d97-9c23-37bd040d140c"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Advance tax must be paid when tax liability exceeds...","options":{"a":"5000","b":"10000","c":"20000","d":"50000"},"correct_option_index":1,"explanation":"Advance tax is mandatory when total tax liability exceeds Rs.10,000.","topic_id":"22480910-0a6c-4d97-9c23-37bd040d140c"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"TDS on salary is deducted under which section?","options":{"a":"192","b":"194C","c":"195","d":"196"},"correct_option_index":0,"explanation":"Section 192 deals with TDS on salary income.","topic_id":"22480910-0a6c-4d97-9c23-37bd040d140c"}
]
'@
Insert-Questions "CA Intermediate - Tax Laws" $q4

# ---- Test 5: CA Final - Direct Tax Laws ----
$q5 = @'
[
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"MAT (Minimum Alternate Tax) is calculated at what rate?","options":{"a":"10%","b":"15%","c":"18.5%","d":"25%"},"correct_option_index":2,"explanation":"MAT is charged at 18.5% (plus surcharge and cess) on book profit.","topic_id":"fbd813c7-2eff-4019-9022-6d132eeb67ef"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Transfer pricing applies to...","options":{"a":"Domestic transactions only","b":"International transactions only","c":"Both domestic and international specified transactions","d":"All transactions"},"correct_option_index":2,"explanation":"Transfer pricing rules apply to both international and specified domestic transactions.","topic_id":"fbd813c7-2eff-4019-9022-6d132eeb67ef"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Belated return can be filed before...","options":{"a":"End of assessment year","b":"3 months from end of assessment year","c":"Completion of assessment","d":"Due date"},"correct_option_index":1,"explanation":"Belated return can be filed up to 3 months before the end of the relevant assessment year.","topic_id":"fbd813c7-2eff-4019-9022-6d132eeb67ef"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Tax residency certificate is required for claiming benefits under...","options":{"a":"DTAA","b":"GAAR","c":"Transfer Pricing","d":"MAT"},"correct_option_index":0,"explanation":"TRC is needed to claim treaty benefits under DTAA.","topic_id":"fbd813c7-2eff-4019-9022-6d132eeb67ef"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Long-term capital gains on listed equity shares is taxed at...","options":{"a":"10%","b":"15%","c":"20%","d":"No tax"},"correct_option_index":0,"explanation":"LTCG above Rs.1 lakh on listed equity shares is taxed at 10% without indexation.","topic_id":"fbd813c7-2eff-4019-9022-6d132eeb67ef"}
]
'@
Insert-Questions "CA Final - Direct Tax Laws" $q5

# ---- Test 6: CA Final - Advanced Auditing ----
$q6 = @'
[
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Audit risk model formula is...","options":{"a":"AR = IR + CR + DR","b":"AR = IR x CR x DR","c":"AR = IR - CR - DR","d":"AR = IR / CR"},"correct_option_index":1,"explanation":"Audit Risk = Inherent Risk x Control Risk x Detection Risk.","topic_id":"5167ea45-e655-4d4f-adc1-37cc600eae75"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Which is NOT a type of audit evidence?","options":{"a":"Physical examination","b":"Confirmation","c":"Management estimates","d":"Internal audit reports"},"correct_option_index":2,"explanation":"Management estimates are assertions, not independent evidence.","topic_id":"5167ea45-e655-4d4f-adc1-37cc600eae75"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Materiality in auditing means...","options":{"a":"Exact amount","b":"Quantum above which financial statements may be misstated","c":"All amounts","d":"Nil"},"correct_option_index":1,"explanation":"Materiality is the threshold above which misstatements influence user decisions.","topic_id":"5167ea45-e655-4d4f-adc1-37cc600eae75"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Substantive procedures include...","options":{"a":"Controls testing only","b":"Tests of details and analytical procedures","c":"Planning only","d":"Reporting only"},"correct_option_index":1,"explanation":"Substantive procedures include both tests of details and substantive analytical procedures.","topic_id":"5167ea45-e655-4d4f-adc1-37cc600eae75"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Going concern audit opinion is qualified when...","options":{"a":"No issues found","b":"Material uncertainty exists but is adequately disclosed","c":"Entity will definitely fail","d":"All years profitable"},"correct_option_index":1,"explanation":"If material uncertainty is adequately disclosed, a qualified/adverse opinion with emphasis is given.","topic_id":"5167ea45-e655-4d4f-adc1-37cc600eae75"}
]
'@
Insert-Questions "CA Final - Advanced Auditing" $q6

# ---- Test 7: CS Executive - Jurisprudence ----
$q7 = @'
[
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Administrative law deals with...","options":{"a":"Private disputes","b":"Government powers and procedures","c":"Criminal law","d":"International law"},"correct_option_index":1,"explanation":"Administrative law governs the exercise of powers by administrative authorities.","topic_id":"4a37444b-0e89-418c-a479-988becd56071"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Natural justice principles include...","options":{"a":"Nemo judex in causa sua","b":"Audi alteram partem","c":"Both a and b","d":"Neither"},"correct_option_index":2,"explanation":"Both principles - no one should be judge in own cause, and hearing both sides.","topic_id":"4a37444b-0e89-418c-a479-988becd56071"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Writ of certiorari is issued to...","options":{"a":"Bring a case from lower to higher court","b":"Quash an order of lower authority","c":"Enforce a right","d":"Prohibit action"},"correct_option_index":1,"explanation":"Certiorari quashes orders of lower courts/tribunals exceeding jurisdiction.","topic_id":"4a37444b-0e89-418c-a479-988becd56071"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"The doctrine of ultra vires means...","options":{"a":"Within powers","b":"Beyond powers","c":"Equal powers","d":"No powers"},"correct_option_index":1,"explanation":"Ultra vires means acting beyond one's legal authority.","topic_id":"4a37444b-0e89-418c-a479-988becd56071"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"A private company requires minimum members of...","options":{"a":"1","b":"2","c":"5","d":"7"},"correct_option_index":1,"explanation":"Private company needs minimum 2 members (one person company exception).","topic_id":"4a37444b-0e89-418c-a479-988becd56071"}
]
'@
Insert-Questions "CS Executive - Jurisprudence" $q7

# ---- Test 8: CS Executive - Economic Laws ----
$q8 = @'
[
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"SEBI was established in...","options":{"a":"1988","b":"1990","c":"1992","d":"1995"},"correct_option_index":2,"explanation":"SEBI was established in 1992 as a statutory body.","topic_id":"da110276-95ad-4d59-8368-31697a19ea96"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"FEMA replaced which act?","options":{"a":"FERA 1973","b":"FEMA 1999","c":"RBI Act","d":"Companies Act"},"correct_option_index":0,"explanation":"FEMA replaced FERA (Foreign Exchange Regulation Act) in 1999.","topic_id":"da110276-95ad-4d59-8368-31697a19ea96"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Insider trading is regulated by...","options":{"a":"FEMA","b":"SEBI Act","c":"Companies Act","d":"IT Act"},"correct_option_index":1,"explanation":"SEBI (Prohibition of Insider Trading) Regulations govern this.","topic_id":"da110276-95ad-4d59-8368-31697a19ea96"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Competition Commission of India was established in...","options":{"a":"2002","b":"2009","c":"2012","d":"2015"},"correct_option_index":1,"explanation":"CCI was established in 2009 under the Competition Act 2002.","topic_id":"da110276-95ad-4d59-8368-31697a19ea96"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Under SEBI regulations, a public issue must have minimum...","options":{"a":"25% public holding","b":"35% public holding","c":"No minimum","d":"50%"},"correct_option_index":1,"explanation":"SEBI mandates minimum 25% public shareholding for listed companies.","topic_id":"da110276-95ad-4d59-8368-31697a19ea96"}
]
'@
Insert-Questions "CS Executive - Economic Laws" $q8

# ---- Test 9: CMA Foundation - Economics ----
$q9 = @'
[
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Opportunity cost is the...","options":{"a":"Money spent","b":"Next best alternative foregone","c":"Total cost","d":"Sunk cost"},"correct_option_index":1,"explanation":"Opportunity cost is the value of the next best alternative given up.","topic_id":"3ccc0b13-29c4-4582-b2f3-e6c01c0da6fc"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Demand curve is typically...","options":{"a":"Upward sloping","b":"Horizontal","c":"Downward sloping","d":"Vertical"},"correct_option_index":2,"explanation":"Law of demand states quantity demanded falls as price rises.","topic_id":"3ccc0b13-29c4-4582-b2f3-e6c01c0da6fc"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Consumer surplus is the difference between...","options":{"a":"Cost and price","b":"Willingness to pay and actual price","c":"Revenue and cost","d":"Supply and demand"},"correct_option_index":1,"explanation":"Consumer surplus = Maximum willingness to pay - Price paid.","topic_id":"3ccc0b13-29c4-4582-b2f3-e6c01c0da6fc"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Inflation is measured by...","options":{"a":"GDP deflator","b":"CPI","c":"WPI","d":"All of these"},"correct_option_index":3,"explanation":"Inflation can be measured by GDP deflator, CPI, and WPI.","topic_id":"3ccc0b13-29c4-4582-b2f3-e6c01c0da6fc"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Scarcity means...","options":{"a":"Limited resources unlimited wants","b":"Unlimited resources","c":"No demand","d":"Excess supply"},"correct_option_index":0,"explanation":"Scarcity is the fundamental economic problem of limited resources vs unlimited wants.","topic_id":"3ccc0b13-29c4-4582-b2f3-e6c01c0da6fc"}
]
'@
Insert-Questions "CMA Foundation - Economics" $q9

# ---- Test 10: CFA Level 1 - Financial Reporting ----
$q10 = @'
[
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"IFRS 15 revenue recognition follows which model?","options":{"a":"Risk and reward","b":"Five-step model","c":"Cash basis","d":"Cost recovery"},"correct_option_index":1,"explanation":"IFRS 15 uses a five-step model for revenue recognition.","topic_id":"fbd813c7-2eff-4019-9022-6d132eeb67ef"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"IFRS 9 classifies financial assets using...","options":{"a":"Amortised cost, FVOCI, FVPL","b":"Cost model","c":"Fair value only","d":"Historical cost"},"correct_option_index":0,"explanation":"IFRS 9 classifies assets as amortised cost, FVOCI, or FVPL.","topic_id":"cf9d27a4-aa1c-42ea-9ffd-f835d8d12baa"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Goodwill is tested for...","options":{"a":"Annual depreciation","b":"Annual impairment","c":"Monthly review","d":"Quarterly audit"},"correct_option_index":1,"explanation":"Goodwill must be tested for impairment at least annually under IAS 36.","topic_id":"c9ab08d0-7922-4161-a35c-827a6fc8795e"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Revenue is recognized when...","options":{"a":"Cash is received","b":"Performance obligation is satisfied","c":"Contract is signed","d":"Invoice is raised"},"correct_option_index":1,"explanation":"Under IFRS 15, revenue is recognized when control transfers.","topic_id":"fbd813c7-2eff-4019-9022-6d132eeb67ef"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Lease accounting under IFRS 16 requires...","options":{"a":"Operating lease off-balance sheet","b":"All leases on balance sheet","c":"Only finance leases","d":"No leases recorded"},"correct_option_index":1,"explanation":"IFRS 16 brings most leases on-balance sheet as right-of-use assets.","topic_id":"fbd813c7-2eff-4019-9022-6d132eeb67ef"}
]
'@
Insert-Questions "CFA Level 1 - Financial Reporting" $q10

# ---- Test 11: CFA Level 1 - Economics ----
$q11 = @'
[
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"GDP deflator measures...","options":{"a":"Price level of all goods","b":"Price level of domestic production","c":"Import prices only","d":"Export prices"},"correct_option_index":1,"explanation":"GDP deflator = (Nominal GDP / Real GDP) x 100.","topic_id":"3ccc0b13-29c4-4582-b2f3-e6c01c0da6fc"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Fiscal policy involves...","options":{"a":"Money supply","b":"Government spending and taxation","c":"Interest rates","d":"Exchange rates"},"correct_option_index":1,"explanation":"Fiscal policy uses government spending and taxation to influence the economy.","topic_id":"3ccc0b13-29c4-4582-b2f3-e6c01c0da6fc"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Phillips curve shows inverse relationship between...","options":{"a":"GDP and inflation","b":"Unemployment and inflation","c":"Interest rates and growth","d":"Savings and investment"},"correct_option_index":1,"explanation":"The Phillips curve shows the trade-off between unemployment and inflation.","topic_id":"3ccc0b13-29c4-4582-b2f3-e6c01c0da6fc"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"A recession is typically defined as...","options":{"a":"1 quarter of negative GDP","b":"2 consecutive quarters of negative GDP","c":"3 years of slow growth","d":"Unemployment above 10%"},"correct_option_index":1,"explanation":"Technical recession is defined as two consecutive quarters of declining GDP.","topic_id":"3ccc0b13-29c4-4582-b2f3-e6c01c0da6fc"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Purchasing Power Parity suggests...","options":{"a":"Exchange rates are fixed","b":"Currency adjusts to equalize purchasing power","c":"Gold standard is best","d":"Inflation is irrelevant"},"correct_option_index":1,"explanation":"PPP theory suggests exchange rates should adjust to equalize price levels.","topic_id":"3ccc0b13-29c4-4582-b2f3-e6c01c0da6fc"}
]
'@
Insert-Questions "CFA Level 1 - Economics" $q11

# ---- Test 12: JEE Main Chemistry - Organic ----
# Note: topic_id 346aee83-... not in provided list; using closest: 3c2d9de0 (Complex Number Algebra is wrong but topic_id is truncated by user)
# Using Law of Demand as fallback - user should provide full UUID for Alkanes topic
$q12 = @'
[
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Hybridization of carbon in ethane is...","options":{"a":"sp","b":"sp2","c":"sp3","d":"sp3d"},"correct_option_index":2,"explanation":"Ethane (C2H6) has sp3 hybridization.","topic_id":"3ccc0b13-29c4-4582-b2f3-e6c01c0da6fc"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Which reaction is characteristic of alkenes?","options":{"a":"Substitution","b":"Addition","c":"Elimination","d":"Rearrangement"},"correct_option_index":1,"explanation":"Alkenes undergo addition reactions due to the double bond.","topic_id":"3ccc0b13-29c4-4582-b2f3-e6c01c0da6fc"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Markovnikov's rule applies to...","options":{"a":"Alkane reactions","b":"Electrophilic addition to asymmetric alkenes","c":"Nucleophilic substitution","d":"Free radical reactions"},"correct_option_index":1,"explanation":"Markovnikov's rule predicts the major product in addition to asymmetric alkenes.","topic_id":"3ccc0b13-29c4-4582-b2f3-e6c01c0da6fc"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"IUPAC name of CH3CH2OH is...","options":{"a":"Methanol","b":"Ethanol","c":"Propanol","d":"Methyl alcohol"},"correct_option_index":1,"explanation":"CH3CH2OH is ethanol (2 carbon chain = eth-, alcohol suffix = -ol).","topic_id":"3ccc0b13-29c4-4582-b2f3-e6c01c0da6fc"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Anti-Markovnikov addition uses...","options":{"a":"HBr","b":"HBr + peroxide","c":"HCl","d":"HI"},"correct_option_index":1,"explanation":"Peroxide effect (Kharasch effect) gives anti-Markovnikov product.","topic_id":"3ccc0b13-29c4-4582-b2f3-e6c01c0da6fc"}
]
'@
Insert-Questions "JEE Main Chemistry - Organic" $q12

# ---- Test 13: JEE Main Chemistry - Inorganic ----
$q13 = @'
[
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Number of moles in 36g of water is...","options":{"a":"1","b":"2","c":"3","d":"4"},"correct_option_index":1,"explanation":"Molar mass of water = 18 g/mol. 36/18 = 2 moles.","topic_id":"9cb8c6d6-7368-4025-88fa-929a81b46945"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"pH of a neutral solution at 25C is...","options":{"a":"0","b":"7","c":"14","d":"1"},"correct_option_index":1,"explanation":"Neutral pH is 7 at 25 degrees Celsius.","topic_id":"9cb8c6d6-7368-4025-88fa-929a81b46945"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Which is a strong acid?","options":{"a":"CH3COOH","b":"HCl","c":"H2CO3","d":"NH3"},"correct_option_index":1,"explanation":"HCl (hydrochloric acid) is a strong acid that fully dissociates.","topic_id":"9cb8c6d6-7368-4025-88fa-929a81b46945"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Covalent bonding involves...","options":{"a":"Transfer of electrons","b":"Sharing of electrons","c":"Electrostatic force","d":"Metallic bonding"},"correct_option_index":1,"explanation":"Covalent bonds involve sharing of electron pairs between atoms.","topic_id":"9cb8c6d6-7368-4025-88fa-929a81b46945"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Molecular weight of NaCl is...","options":{"a":"23","b":"35.5","c":"58.5","d":"46"},"correct_option_index":2,"explanation":"Na(23) + Cl(35.5) = 58.5 g/mol.","topic_id":"9cb8c6d6-7368-4025-88fa-929a81b46945"}
]
'@
Insert-Questions "JEE Main Chemistry - Inorganic" $q13

# ---- Test 14: JEE Advanced Physics - Electromagnetism ----
$q14 = @'
[
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Gauss's law relates electric flux to...","options":{"a":"Charge","b":"Current","c":"Magnetic flux","d":"Voltage"},"correct_option_index":0,"explanation":"Gauss's law states electric flux equals charge enclosed divided by epsilon naught.","topic_id":"0dac6b16-2bf9-474b-ade1-c9ad9d9dfbe9"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"SI unit of electric field is...","options":{"a":"Volt","b":"Coulomb","c":"N/C or V/m","d":"Ampere"},"correct_option_index":2,"explanation":"Electric field = Force/Charge = N/C = V/m.","topic_id":"0dac6b16-2bf9-474b-ade1-c9ad9d9dfbe9"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Capacitance of a parallel plate capacitor is proportional to...","options":{"a":"Distance","b":"1/distance","c":"Square of distance","d":"Inverse square"},"correct_option_index":1,"explanation":"C = eA/d, so capacitance is inversely proportional to distance.","topic_id":"0dac6b16-2bf9-474b-ade1-c9ad9d9dfbe9"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Magnetic force on a moving charge is always...","options":{"a":"Parallel to velocity","b":"Perpendicular to both velocity and field","c":"In direction of field","d":"Zero"},"correct_option_index":1,"explanation":"Lorentz force F = qv x B is always perpendicular to velocity.","topic_id":"0dac6b16-2bf9-474b-ade1-c9ad9d9dfbe9"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Faraday's law of electromagnetic induction involves...","options":{"a":"Constant magnetic field","b":"Changing magnetic flux","c":"Static charges","d":"Constant current"},"correct_option_index":1,"explanation":"EMF is induced by change in magnetic flux (Faraday's law).","topic_id":"0dac6b16-2bf9-474b-ade1-c9ad9d9dfbe9"}
]
'@
Insert-Questions "JEE Advanced Physics - Electromagnetism" $q14

# ---- Test 15: JEE Advanced Mathematics - Algebra ----
$q15 = @'
[
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Determinant of a 2x2 matrix [[a,b],[c,d]] is...","options":{"a":"ab-cd","b":"ad-bc","c":"ac-bd","d":"a+b+c+d"},"correct_option_index":1,"explanation":"det([[a,b],[c,d]]) = ad - bc.","topic_id":"57b7bab5-1d7b-470c-953b-b3a3c95c1b1c"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"If A is a 3x3 matrix with det(A)=5, then det(2A) is...","options":{"a":"10","b":"20","c":"40","d":"160"},"correct_option_index":2,"explanation":"det(kA) = k^n * det(A) where n is the order. 2^3 * 5 = 40.","topic_id":"57b7bab5-1d7b-470c-953b-b3a3c95c1b1c"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Eigenvalues of identity matrix are...","options":{"a":"0","b":"1","c":"All ones","d":"Depends on size"},"correct_option_index":2,"explanation":"Identity matrix has all eigenvalues equal to 1.","topic_id":"57b7bab5-1d7b-470c-953b-b3a3c95c1b1c"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Matrix multiplication is...","options":{"a":"Commutative","b":"Associative","c":"Always invertible","d":"Distributive over addition only"},"correct_option_index":1,"explanation":"Matrix multiplication is associative: A(BC) = (AB)C.","topic_id":"57b7bab5-1d7b-470c-953b-b3a3c95c1b1c"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Rank of zero matrix is...","options":{"a":"0","b":"1","c":"n","d":"Undefined"},"correct_option_index":0,"explanation":"Zero matrix has rank 0 since all rows are linearly dependent.","topic_id":"57b7bab5-1d7b-470c-953b-b3a3c95c1b1c"}
]
'@
Insert-Questions "JEE Advanced Mathematics - Algebra" $q15

# ---- Test 16: NEET UG Chemistry - Physical Chemistry ----
$q16 = @'
[
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Avogadro's number is approximately...","options":{"a":"6.022 x 10^22","b":"6.022 x 10^23","c":"6.022 x 10^24","d":"6.022 x 10^21"},"correct_option_index":1,"explanation":"Avogadro's number = 6.022 x 10^23 per mole.","topic_id":"9cb8c6d6-7368-4025-88fa-929a81b46945"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"At STP, 1 mole of gas occupies...","options":{"a":"11.2 L","b":"22.4 L","c":"44.8 L","d":"2.24 L"},"correct_option_index":1,"explanation":"1 mole of ideal gas occupies 22.4 L at STP (0C, 1 atm).","topic_id":"9cb8c6d6-7368-4025-88fa-929a81b46945"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"pH = -log[H+]. If [H+] = 10^-3, pH is...","options":{"a":"1","b":"2","c":"3","d":"4"},"correct_option_index":2,"explanation":"pH = -log(10^-3) = 3.","topic_id":"9cb8c6d6-7368-4025-88fa-929a81b46945"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Bond order of O2 is...","options":{"a":"1","b":"1.5","c":"2","d":"2.5"},"correct_option_index":2,"explanation":"O2 has bond order 2 (10 bonding - 6 antibonding)/2 = 2.","topic_id":"9cb8c6d6-7368-4025-88fa-929a81b46945"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Enthalpy of formation of elements in standard state is...","options":{"a":"Positive","b":"Zero","c":"Negative","d":"Undefined"},"correct_option_index":1,"explanation":"Standard enthalpy of formation of elements in their standard state is zero by definition.","topic_id":"9cb8c6d6-7368-4025-88fa-929a81b46945"}
]
'@
Insert-Questions "NEET UG Chemistry - Physical Chemistry" $q16

# ---- Test 17: NEET UG Biology - Zoology ----
$q17 = @'
[
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Red blood cells are produced in...","options":{"a":"Liver","b":"Bone marrow","c":"Spleen","d":"Kidney"},"correct_option_index":1,"explanation":"RBCs are produced in red bone marrow through erythropoiesis.","topic_id":"b84fc731-d991-4b66-90e1-7376ad0498d8"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"DNA stands for...","options":{"a":"Deoxyribonucleic acid","b":"Dinitrogen acid","c":"Dioxo acid","d":"Deoxy acid"},"correct_option_index":0,"explanation":"DNA = DeoxyriboNucleic Acid.","topic_id":"b84fc731-d991-4b66-90e1-7376ad0498d8"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Chromosomes are made up of...","options":{"a":"Protein only","b":"DNA only","c":"DNA and protein","d":"Lipids"},"correct_option_index":2,"explanation":"Chromosomes consist of DNA wrapped around histone proteins.","topic_id":"b84fc731-d991-4b66-90e1-7376ad0498d8"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Basis of classification of living organisms is...","options":{"a":"Cell theory","b":"Germ theory","c":"Theory of evolution","d":"All of these"},"correct_option_index":3,"explanation":"All these theories form the basis of modern biological classification.","topic_id":"b84fc731-d991-4b66-90e1-7376ad0498d8"},
  {"test_id":"TEST_ID_PLACEHOLDER","question_text":"Heart of a normal adult human beats approximately...","options":{"a":"40 times/min","b":"72 times/min","c":"100 times/min","d":"120 times/min"},"correct_option_index":1,"explanation":"Normal resting heart rate is approximately 72 beats per minute.","topic_id":"b84fc731-d991-4b66-90e1-7376ad0498d8"}
]
'@
Insert-Questions "NEET UG Biology - Zoology" $q17

# ============================================================
# STEP 3: Find existing "JEE Advanced Physics - Mechanics" test
# ============================================================
Write-Host "`n=== STEP 3: Finding existing JEE Advanced Physics - Mechanics test ===" -ForegroundColor Cyan

try {
    $mechTests = Invoke-RestMethod -Uri "$baseUrl/tests?select=id,title&title=eq.JEE%20Advanced%20Physics%20-%20Mechanics" -Method Get -Headers $headers
    if ($mechTests.Count -gt 0) {
        $mechTestId = $mechTests[0].id
        Write-Found "Found test: $($mechTests[0].title) -> $mechTestId"
        
        # Insert 5 additional questions
        $qMechExtra = @"
[
  {"test_id":"$mechTestId","question_text":"Moment of inertia of solid sphere about diameter is...","options":{"a":"2/5 MR^2","b":"2/3 MR^2","c":"MR^2","d":"1/2 MR^2"},"correct_option_index":0,"explanation":"I = 2/5 MR^2 for solid sphere about diameter.","topic_id":"b84fc731-d991-4b66-90e1-7376ad0498d8"},
  {"test_id":"$mechTestId","question_text":"Center of mass of a semicircular ring is at distance...","options":{"a":"2R/pi from center","b":"R/pi","c":"pi/2R","d":"R/2"},"correct_option_index":0,"explanation":"COM of semicircular ring is at distance 2R/pi from center along symmetry axis.","topic_id":"b84fc731-d991-4b66-90e1-7376ad0498d8"},
  {"test_id":"$mechTestId","question_text":"Escape velocity from Earth is approximately...","options":{"a":"7.2 km/s","b":"11.2 km/s","c":"15.2 km/s","d":"3.2 km/s"},"correct_option_index":1,"explanation":"Escape velocity from Earth surface is approximately 11.2 km/s.","topic_id":"b84fc731-d991-4b66-90e1-7376ad0498d8"},
  {"test_id":"$mechTestId","question_text":"Conservation of angular momentum means...","options":{"a":"Torque is maximum","b":"Torque is zero","c":"Angular velocity is constant","d":"Moment of inertia is constant"},"correct_option_index":1,"explanation":"When external torque is zero, angular momentum remains constant.","topic_id":"b84fc731-d991-4b66-90e1-7376ad0498d8"},
  {"test_id":"$mechTestId","question_text":"Simple harmonic motion has acceleration...","options":{"a":"Constant","b":"Proportional to displacement","c":"Zero","d":"Inversely proportional"},"correct_option_index":1,"explanation":"In SHM, acceleration = -omega^2 * x (proportional to displacement).","topic_id":"b84fc731-d991-4b66-90e1-7376ad0498d8"}
]
"@
        $r = Invoke-RestMethod -Uri "$baseUrl/test_questions?select=id" -Method Post -Headers $headers -Body $qMechExtra
        $count = if ($r -is [array]) { $r.Count } else { 1 }
        $questionsSuccess += $count
        Write-Host "  OK: JEE Advanced Physics - Mechanics (extra) -> $count questions" -ForegroundColor Green
    } else {
        Write-Host "  NOT FOUND: JEE Advanced Physics - Mechanics test" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ERROR finding Mechanics test: $_" -ForegroundColor Red
}

# ============================================================
# SUMMARY
# ============================================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Tests inserted:      $($testsResult.Count)" -ForegroundColor Green
Write-Host "Questions inserted:  $questionsSuccess" -ForegroundColor Green
Write-Host "Questions failed:    $questionsFailed" -ForegroundColor $(if ($questionsFailed -gt 0) { "Red" } else { "Green" })
Write-Host "========================================" -ForegroundColor Cyan
