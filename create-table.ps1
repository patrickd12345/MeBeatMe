$headers = @{
    'Content-Type' = 'application/json'
    'apikey' = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNjcm1mY3ZtZ2FmbmtjdGJobWZ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc4NzM0OTIsImV4cCI6MjA2MzQ0OTQ5Mn0.08UECoDCJeZn_XSCYF8UOEecrCqcfHbWSCv85uJCsX4'
    'Authorization' = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNjcm1mY3ZtZ2FmbmtjdGJobWZ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc4NzM0OTIsImV4cCI6MjA2MzQ0OTQ5Mn0.08UECoDCJeZn_XSCYF8UOEecrCqcfHbWSCv85uJCsX4'
}

$body = @{
    query = "create table if not exists sessions (id text primary key, activity_id text unique, source text not null default 'strava', name text, distance integer not null, duration integer not null, created_at timestamptz not null, ppi integer not null, best_ppi integer not null); alter table sessions enable row level security;"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri 'https://scrmfcvmgafnkctbhmfu.supabase.co/rest/v1/rpc/exec_sql' -Method Post -Headers $headers -Body $body
    Write-Host "Success: Table created"
    $response
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}

