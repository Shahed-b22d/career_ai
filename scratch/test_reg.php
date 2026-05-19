<?php
$base = 'http://127.0.0.1:8000/api/auth';
$testEmail = 'test_' . time() . '@demo.com';

// Register
$ch = curl_init("$base/register");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Accept: application/json', 'Content-Type: application/json']);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
    'name'     => 'Ahmed Al-Sayed',
    'email'    => $testEmail,
    'password' => 'secret123',
    'role'     => 'job',
    'phone'    => '0501234567',
]));
$body = curl_exec($ch);
$code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "REGISTER Status: $code\n";
echo $body . "\n";
