<?php
$base = 'http://127.0.0.1:8000/api/auth';
$testEmail = 'test_' . time() . '@demo.com';

function req($method, $url, $data = [], $token = null) {
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);
    $h = ['Accept: application/json', 'Content-Type: application/json'];
    if ($token) $h[] = "Authorization: Bearer $token";
    curl_setopt($ch, CURLOPT_HTTPHEADER, $h);
    if ($data) curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    $body = curl_exec($ch);
    $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    return [$code, json_decode($body, true)];
}

// 1. Register Job Seeker
echo "===== 1. REGISTER JOB SEEKER =====\n";
[$c, $r] = req('POST', "$base/register", [
    'name' => 'Mohammed Ali', 'email' => $testEmail,
    'password' => 'secret123', 'role' => 'job', 'phone' => '0501234567',
    'governorate' => 'Damascus',
]);
echo "Status: $c\n" . json_encode($r, JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE) . "\n\n";
$token1 = $r['token'] ?? null;

// 2. Login with correct role
echo "===== 2. LOGIN JOB SEEKER =====\n";
[$c, $r] = req('POST', "$base/login", [
    'email' => $testEmail, 'password' => 'secret123', 'role' => 'job',
]);
echo "Status: $c\n" . json_encode($r, JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE) . "\n\n";
$loginToken = $r['token'] ?? $token1;

// 3. Get profile (ME)
echo "===== 3. GET PROFILE (ME) =====\n";
[$c, $r] = req('GET', "$base/me", [], $loginToken);
echo "Status: $c\n" . json_encode($r, JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE) . "\n\n";

// 4. Wrong role login
echo "===== 4. WRONG ROLE (should fail) =====\n";
[$c, $r] = req('POST', "$base/login", [
    'email' => $testEmail, 'password' => 'secret123', 'role' => 'company',
]);
echo "Status: $c\n" . json_encode($r, JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE) . "\n\n";

// 5. Wrong password
echo "===== 5. WRONG PASSWORD (should fail) =====\n";
[$c, $r] = req('POST', "$base/login", [
    'email' => $testEmail, 'password' => 'wrongpass', 'role' => 'job',
]);
echo "Status: $c\n" . json_encode($r, JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE) . "\n\n";

// 6. Register Company
$compEmail = 'company_' . time() . '@demo.com';
echo "===== 6. REGISTER COMPANY =====\n";
[$c, $r] = req('POST', "$base/register", [
    'name' => 'Tech Corp', 'email' => $compEmail,
    'password' => 'secret123', 'role' => 'company',
    'phone' => '0501111111', 'business_type' => 'Technology / IT',
    'governorate' => 'Aleppo',
]);
echo "Status: $c\n" . json_encode($r, JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE) . "\n\n";
$compToken = $r['token'] ?? null;

// 7. Logout
echo "===== 7. LOGOUT =====\n";
[$c, $r] = req('POST', "$base/logout", [], $loginToken);
echo "Status: $c\n" . json_encode($r, JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE) . "\n\n";

// 8. Use token after logout (should fail)
echo "===== 8. USE EXPIRED TOKEN (should fail) =====\n";
[$c, $r] = req('GET', "$base/me", [], $loginToken);
echo "Status: $c\n" . json_encode($r, JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE) . "\n";
