# PowerShell script to push database schema to Supabase
param(
    [string]$SupabaseUrl = "https://xkffzkwrcnbuzvgaxrgy.supabase.co",
    [string]$SupabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhrZmZ6a3dyY25idXp2Z2F4cmd5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgzOTczNDMsImV4cCI6MjA3Mzk3MzM0M30.t9BGFXQy_MUdy6JUBQge_XsJ05GqpNekTvloEuM7jyo"
)

Write-Host "🚀 Starting database push to Supabase..." -ForegroundColor Green
Write-Host "📡 Target: $SupabaseUrl" -ForegroundColor Cyan

# Read SQL file
$sqlFile = "database\setup_database.sql"
if (-not (Test-Path $sqlFile)) {
    Write-Host "❌ SQL file not found: $sqlFile" -ForegroundColor Red
    exit 1
}

Write-Host "📖 Reading SQL file..." -ForegroundColor Yellow
$sqlContent = Get-Content $sqlFile -Raw -Encoding UTF8
Write-Host "📊 SQL file size: $($sqlContent.Length) characters" -ForegroundColor Cyan

# Split into statements
$statements = $sqlContent -split ';' | Where-Object { $_.Trim() -ne '' }
Write-Host "📊 Found $($statements.Count) SQL statements" -ForegroundColor Cyan

# Headers for Supabase API
$headers = @{
    "apikey" = $SupabaseKey
    "Authorization" = "Bearer $SupabaseKey"
    "Content-Type" = "application/json"
    "Prefer" = "return=minimal"
}

$successCount = 0
$totalCount = $statements.Count

# Execute each statement
for ($i = 0; $i -lt $statements.Count; $i++) {
    $statement = $statements[$i].Trim()
    if ($statement -eq '') { continue }
    
    Write-Host "🔄 Executing statement $($i + 1)/$totalCount..." -ForegroundColor Yellow
    
    # Prepare the request body
    $body = @{
        sql = $statement
    } | ConvertTo-Json
    
    try {
        # Make the request to Supabase's SQL execution endpoint
        $response = Invoke-RestMethod -Uri "$SupabaseUrl/rest/v1/rpc/exec_sql" -Method Post -Headers $headers -Body $body -TimeoutSec 30
        
        Write-Host "✅ Statement $($i + 1) executed successfully" -ForegroundColor Green
        $successCount++
    }
    catch {
        Write-Host "❌ Statement $($i + 1) failed: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "   Response: $responseBody" -ForegroundColor Red
        }
    }
}

# Summary
Write-Host "`n📈 Execution Summary:" -ForegroundColor Cyan
Write-Host "✅ Successful: $successCount/$totalCount" -ForegroundColor Green
Write-Host "❌ Failed: $($totalCount - $successCount)/$totalCount" -ForegroundColor Red

if ($successCount -eq $totalCount) {
    Write-Host "`n🎉 Database schema pushed successfully!" -ForegroundColor Green
    Write-Host "`n🔍 Next steps:" -ForegroundColor Yellow
    Write-Host "1. Go to your Supabase dashboard" -ForegroundColor White
    Write-Host "2. Check the 'Table Editor' to see your tables" -ForegroundColor White
    Write-Host "3. Run this query to verify:" -ForegroundColor White
    Write-Host "   SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';" -ForegroundColor Gray
} else {
    Write-Host "`n⚠️  Some commands failed. Check the output above for details." -ForegroundColor Yellow
    Write-Host "💡 You may need to run the SQL manually in Supabase SQL Editor." -ForegroundColor Yellow
}

