$headers = @{
    "apikey"       = "sb_publishable_gmhfQyBzPt8cLMOSa_E26A_UvEjFOMC"
    "Authorization" = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJkZHJ1YmtiZ2tia3J0eG9ka3N2Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NzI4Nzc1NiwiZXhwIjoyMTAyODYzNzU2fQ.57KGPc-pqsOyVv-TBTldX0siuDtcRbGdYHGL7CfuTQ0"
    "Content-Type" = "application/json"
}

# Get existing questions to see the schema
$result = Invoke-RestMethod -Uri "https://rddrubkbgkbkrtxodksv.supabase.co/rest/v1/test_questions?select=*&limit=2" -Method Get -Headers $headers
$result | ConvertTo-Json -Depth 5

# Try a single question insert with verbose error
Write-Host "`n--- Attempting single question insert ---"
$singleQ = @{
    test_id = "e9eb8ae4-8c62-4476-805d-96fd3c21379f"
    question_text = "Test question?"
    options = @{a="Opt A";b="Opt B";c="Opt C";d="Opt D"}
    correct_option_index = 0
    explanation = "Test explanation"
    topic_id = "3ccc0b13-29c4-4582-b2f3-e6c01c0da6fc"
} | ConvertTo-Json -Depth 3

Write-Host "JSON body: $singleQ"

try {
    $r = Invoke-RestMethod -Uri "https://rddrubkbgkbkrtxodksv.supabase.co/rest/v1/test_questions" -Method Post -Headers $headers -Body $singleQ
    Write-Host "SUCCESS: $($r | ConvertTo-Json)"
} catch {
    Write-Host "ERROR: $_"
    # Try to get more details
    try {
        $errStream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errStream)
        $errBody = $reader.ReadToEnd()
        Write-Host "Error body: $errBody"
    } catch {
        Write-Host "Could not read error body"
    }
}
