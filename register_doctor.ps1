$email = Read-Host -Prompt 'Enter Email'
$password = Read-Host -Prompt 'Enter Password (min 6 chars)'
$fullName = Read-Host -Prompt 'Enter Full Name'
$phone = Read-Host -Prompt 'Enter Phone'

$body = @{
    email = $email
    password = $password
    fullName = $fullName
    phone = $phone
} | ConvertTo-Json

Write-Host "Registering user..."

try {
    # Try Gateway first
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/register" -Method Post -Body $body -ContentType "application/json"
    Write-Host "Registration Successful!" -ForegroundColor Green
    Write-Host "Response: $($response | ConvertTo-Json -Depth 5)"
    Write-Host "`nIMPORTANT: Default role is PATIENT. Since this is the Doctor Portal, you may need to update the role in your database:" -ForegroundColor Yellow
    Write-Host "UPDATE users SET role = 'DOCTOR' WHERE email = '$email';" -ForegroundColor Cyan
} catch {
    Write-Host "Registration Failed on Gateway (8080). Trying direct to Auth Service (8081)..." -ForegroundColor Yellow
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:8081/auth/register" -Method Post -Body $body -ContentType "application/json"
        Write-Host "Registration Successful (Direct)!" -ForegroundColor Green
        Write-Host "Response: $($response | ConvertTo-Json -Depth 5)"
        Write-Host "`nIMPORTANT: Default role is PATIENT. Since this is the Doctor Portal, you may need to update the role in your database:" -ForegroundColor Yellow
        Write-Host "UPDATE users SET role = 'DOCTOR' WHERE email = '$email';" -ForegroundColor Cyan
    } catch {
        Write-Host "Registration Failed!" -ForegroundColor Red
        Write-Host $_.Exception.Message
        if ($_.Exception.Response) {
             # Powershell Core vs Windows Powershell error handling diffs, trying generic approach
            try {
                $stream = $_.Exception.Response.GetResponseStream()
                if ($stream) {
                    $reader = New-Object System.IO.StreamReader($stream)
                    $responseBody = $reader.ReadToEnd()
                    Write-Host "Server Response: $responseBody" -ForegroundColor Red
                }
            } catch {}
        }
    }
}
Pause
