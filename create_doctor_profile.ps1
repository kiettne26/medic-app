$base_url = "http://localhost:8080/api"
$email = "doctor_final@example.com"
$password = "123456"

# 1. Login
$loginUrl = "$base_url/auth/login"
$loginBody = @{
    email = $email
    password = $password
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri $loginUrl -Method Post -Body $loginBody -ContentType "application/json"
    $token = $loginResponse.data.accessToken
    $userId = $loginResponse.data.user.id
    Write-Host "Login Success. UserId: $userId"
} catch {
    Write-Error "Login Failed: $_"
    exit
}

# 2. Update/Create Profile
$profileUrl = "$base_url/profiles/user/$userId"
$profileBody = @{
    fullName = "Bác sĩ Final"
    phone = "0987654321"
    address = "123 Medical Center"
    gender = "MALE"
    dob = "1980-01-01"
    avatarUrl = "https://ui-avatars.com/api/?name=Dr+Final&background=random"
} | ConvertTo-Json

try {
    $headers = @{
        Authorization = "Bearer $token"
    }
    $profileResponse = Invoke-RestMethod -Uri $profileUrl -Method Put -Body $profileBody -ContentType "application/json" -Headers $headers
    Write-Host "Profile Created/Updated:"
    $profileResponse | ConvertTo-Json -Depth 10
} catch {
    Write-Error "Profile Update Failed: $_"
    exit
}
