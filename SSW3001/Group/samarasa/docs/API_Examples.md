# SMAMRASA API Examples

This document provides examples for testing the SMAMRASA API endpoints.

## Base URL
```
http://localhost:8000
```

## Authentication Service

### 1. Register a New User

**Endpoint:** `POST /auth/register`

**Request:**
```bash
curl -X POST http://localhost:8000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "SecurePass123!",
    "name": "Test User",
    "phone": "+1234567890",
    "role": "patient"
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "User registered successfully. Please enable MFA to complete setup.",
  "data": {
    "user": {
      "id": "uuid",
      "email": "test@example.com",
      "name": "Test User",
      "role": "patient"
    },
    "mfa": {
      "secret": "base32_secret",
      "qrCode": "data:image/png;base64,...",
      "manualEntry": "otpauth://totp/..."
    }
  }
}
```

### 2. Login

**Endpoint:** `POST /auth/login`

**Request:**
```bash
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "patient@smamrasa.com",
    "password": "Admin123!"
  }'
```

**Response (without MFA):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "mfaRequired": false,
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "id": "uuid",
      "email": "patient@smamrasa.com",
      "name": "Jane Doe",
      "role": "patient"
    }
  }
}
```

**Response (with MFA):**
```json
{
  "success": true,
  "message": "MFA verification required",
  "data": {
    "mfaRequired": true,
    "userId": "uuid"
  }
}
```

### 3. Verify MFA Token

**Endpoint:** `POST /auth/verify-mfa`

**Request:**
```bash
curl -X POST http://localhost:8000/auth/verify-mfa \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user_uuid",
    "token": "123456"
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "MFA verified successfully",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "id": "uuid",
      "email": "patient@smamrasa.com",
      "name": "Jane Doe",
      "role": "patient"
    }
  }
}
```

### 4. Enable MFA

**Endpoint:** `POST /auth/enable-mfa`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request:**
```bash
curl -X POST http://localhost:8000/auth/enable-mfa \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..." \
  -H "Content-Type: application/json"
```

**Response:**
```json
{
  "success": true,
  "message": "MFA enabled successfully",
  "data": {
    "secret": "base32_secret",
    "qrCode": "data:image/png;base64,...",
    "manualEntry": "otpauth://totp/..."
  }
}
```

### 5. Refresh Token

**Endpoint:** `POST /auth/refresh`

**Request:**
```bash
curl -X POST http://localhost:8000/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user_uuid",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "Token refreshed successfully",
  "data": {
    "accessToken": "new_access_token",
    "refreshToken": "new_refresh_token"
  }
}
```

### 6. Validate Token

**Endpoint:** `GET /auth/validate`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request:**
```bash
curl -X GET http://localhost:8000/auth/validate \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..."
```

**Response:**
```json
{
  "success": true,
  "message": "Token valid",
  "data": {
    "userId": "uuid",
    "email": "patient@smamrasa.com",
    "role": "patient",
    "name": "Jane Doe",
    "iat": 1234567890,
    "exp": 1234568010
  }
}
```

### 7. Logout

**Endpoint:** `POST /auth/logout`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request:**
```bash
curl -X POST http://localhost:8000/auth/logout \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..."
```

**Response:**
```json
{
  "success": true,
  "message": "Logout successful"
}
```

## User Management Service

### 1. Get User Profile

**Endpoint:** `GET /users/{id}`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request:**
```bash
curl -X GET http://localhost:8000/users/user_uuid \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..."
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "patient@smamrasa.com",
    "name": "Jane Doe",
    "role": "patient",
    "profile": {
      "dateOfBirth": "1985-05-15",
      "gender": "Female",
      "bloodType": "O+",
      "allergies": ["Penicillin", "Peanuts"],
      "medications": ["Lisinopril 10mg"],
      "emergencyContact": {
        "name": "John Doe",
        "phone": "+1234567893",
        "relationship": "Spouse"
      }
    }
  }
}
```

### 2. Update User Profile

**Endpoint:** `PUT /users/{id}`

**Request:**
```bash
curl -X PUT http://localhost:8000/users/user_uuid \
  -H "Authorization: Bearer <access_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jane Smith",
    "phone": "+1234567899",
    "address": "123 Main St, City, State 12345"
  }'
```

### 3. Create Patient Profile

**Endpoint:** `POST /users/patient`

**Request:**
```bash
curl -X POST http://localhost:8000/users/patient \
  -H "Authorization: Bearer <access_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user_uuid",
    "dateOfBirth": "1985-05-15",
    "gender": "Female",
    "bloodType": "O+",
    "allergies": ["Penicillin", "Peanuts"],
    "medications": ["Lisinopril 10mg"],
    "emergencyContact": {
      "name": "John Doe",
      "phone": "+1234567893",
      "relationship": "Spouse"
    }
  }'
```

## Appointment Service

### 1. Create Appointment

**Endpoint:** `POST /appointments`

**Request:**
```bash
curl -X POST http://localhost:8000/appointments \
  -H "Authorization: Bearer <access_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "patientId": "patient_uuid",
    "providerId": "provider_uuid",
    "preferredTime": "2024-02-15T14:00:00Z",
    "reason": "Annual checkup",
    "isEmergency": false
  }'
```

**Response:**
```json
{
  "success": true,
  "data": {
    "appointmentId": "uuid",
    "confirmedTime": "2024-02-15T14:00:00Z",
    "status": "scheduled"
  }
}
```

### 2. Get Doctor's Schedule

**Endpoint:** `GET /appointments/doctor/{doctorId}`

**Request:**
```bash
curl -X GET "http://localhost:8000/appointments/doctor/provider_uuid?date=2024-02-15" \
  -H "Authorization: Bearer <access_token>"
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "scheduledTime": "2024-02-15T14:00:00Z",
      "patient": "Jane Doe",
      "reason": "Annual checkup",
      "status": "scheduled"
    }
  ]
}
```

### 3. Emergency Appointment

**Endpoint:** `POST /appointments/emergency`

**Request:**
```bash
curl -X POST http://localhost:8000/appointments/emergency \
  -H "Authorization: Bearer <access_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "patientId": "patient_uuid",
    "symptoms": [
      {"name": "chest_pain", "severity": "severe", "duration": "30 minutes"},
      {"name": "difficulty_breathing", "severity": "severe", "duration": "20 minutes"}
    ],
    "severity": "critical"
  }'
```

**Response:**
```json
{
  "success": true,
  "data": {
    "appointmentId": "uuid",
    "priority": 9,
    "estimatedWait": 5
  }
}
```

## Video Consultation Service

### 1. Create Video Session

**Endpoint:** `POST /video/session`

**Request:**
```bash
curl -X POST http://localhost:8000/video/session \
  -H "Authorization: Bearer <access_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "appointmentId": "appointment_uuid",
    "providerId": "provider_uuid",
    "patientId": "patient_uuid"
  }'
```

**Response:**
```json
{
  "success": true,
  "data": {
    "sessionId": "uuid",
    "token": "webrtc_token",
    "iceServers": [
      {"urls": "stun:stun.l.google.com:19302"},
      {"urls": "turn:your-turn-server.com:3478", "username": "...", "credential": "..."}
    ]
  }
}
```

## IoT Service

### 1. Register IoT Device

**Endpoint:** `POST /iot/device/register`

**Request:**
```bash
curl -X POST http://localhost:8000/iot/device/register \
  -H "Authorization: Bearer <access_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "deviceId": "BP_MONITOR_001",
    "type": "blood_pressure",
    "manufacturer": "Omron",
    "firmware": "v1.2.3"
  }'
```

**Response:**
```json
{
  "success": true,
  "data": {
    "registrationToken": "secure_token"
  }
}
```

### 2. Pair Device to Patient

**Endpoint:** `POST /iot/device/pair`

**Request:**
```bash
curl -X POST http://localhost:8000/iot/device/pair \
  -H "Authorization: Bearer <access_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "deviceId": "BP_MONITOR_001",
    "patientId": "patient_uuid",
    "pairingCode": "ABC123"
  }'
```

### 3. Get Vital Signs

**Endpoint:** `GET /iot/data/{patientId}`

**Request:**
```bash
curl -X GET "http://localhost:8000/iot/data/patient_uuid?metric=heart_rate&from=2024-02-14T00:00:00Z&to=2024-02-15T00:00:00Z" \
  -H "Authorization: Bearer <access_token>"
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "timestamp": "2024-02-14T10:00:00Z",
      "metric": "heart_rate",
      "value": 72,
      "unit": "bpm"
    },
    {
      "timestamp": "2024-02-14T11:00:00Z",
      "metric": "heart_rate",
      "value": 75,
      "unit": "bpm"
    }
  ]
}
```

## Prescription Service

### 1. Create Prescription

**Endpoint:** `POST /prescriptions`

**Request:**
```bash
curl -X POST http://localhost:8000/prescriptions \
  -H "Authorization: Bearer <access_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "appointmentId": "appointment_uuid",
    "providerId": "provider_uuid",
    "patientId": "patient_uuid",
    "medications": [
      {
        "name": "Amoxicillin",
        "dosage": "500mg",
        "frequency": "3 times daily",
        "duration": "7 days"
      }
    ],
    "notes": "Take with food"
  }'
```

**Response:**
```json
{
  "success": true,
  "data": {
    "prescriptionId": "uuid",
    "qrCode": "data:image/png;base64,..."
  }
}
```

## Triage Service

### 1. Assess Symptoms

**Endpoint:** `POST /triage/assess`

**Request:**
```bash
curl -X POST http://localhost:8000/triage/assess \
  -H "Authorization: Bearer <access_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "patientId": "patient_uuid",
    "symptoms": [
      {"name": "chest_pain", "severity": "severe", "duration": "30 minutes"},
      {"name": "nausea", "severity": "moderate", "duration": "1 hour"}
    ],
    "vitals": {
      "heartRate": 120,
      "bpSystolic": 160,
      "bpDiastolic": 95,
      "spo2": 94,
      "temperature": 37.8
    }
  }'
```

**Response:**
```json
{
  "success": true,
  "data": {
    "priority": 8,
    "recommendedAction": "immediate",
    "estimatedWait": 0,
    "suggestedProvider": "provider_uuid"
  }
}
```

## Testing Script

Save this as `test-api.sh`:

```bash
#!/bin/bash

# SMAMRASA API Test Script

BASE_URL="http://localhost:8000"

echo "Testing SMAMRASA API..."
echo ""

# Test Auth Service Health
echo "1. Testing Auth Service Health..."
curl -s "$BASE_URL/auth/health" | jq .
echo ""

# Register a test user
echo "2. Registering test user..."
curl -s -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test'"$(date +%s)"'@example.com",
    "password": "TestPass123!",
    "name": "Test User",
    "role": "patient"
  }' | jq .
echo ""

# Login with existing user
echo "3. Logging in..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "patient@smamrasa.com",
    "password": "Admin123!"
  }')

echo "$LOGIN_RESPONSE" | jq .

# Extract tokens
ACCESS_TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.data.accessToken // empty')

if [ -n "$ACCESS_TOKEN" ]; then
  echo ""
  echo "4. Validating token..."
  curl -s "$BASE_URL/auth/validate" \
    -H "Authorization: Bearer $ACCESS_TOKEN" | jq .

  echo ""
  echo "5. Getting user profile..."
  USER_ID=$(echo "$LOGIN_RESPONSE" | jq -r '.data.user.id')
  curl -s "$BASE_URL/users/$USER_ID" \
    -H "Authorization: Bearer $ACCESS_TOKEN" | jq .
fi

echo ""
echo "API tests completed!"
```

## Postman Collection

You can import this collection into Postman:

```json
{
  "info": {
    "name": "SMAMRASA API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Auth",
      "item": [
        {
          "name": "Register",
          "request": {
            "method": "POST",
            "header": [{"key": "Content-Type", "value": "application/json"}],
            "body": {
              "mode": "raw",
              "raw": "{\"email\":\"test@example.com\",\"password\":\"TestPass123!\",\"name\":\"Test User\",\"role\":\"patient\"}"
            },
            "url": {"raw": "{{baseUrl}}/auth/register", "host": ["{{baseUrl}}"], "path": ["auth", "register"]}
          }
        },
        {
          "name": "Login",
          "request": {
            "method": "POST",
            "header": [{"key": "Content-Type", "value": "application/json"}],
            "body": {
              "mode": "raw",
              "raw": "{\"email\":\"patient@smamrasa.com\",\"password\":\"Admin123!\"}"
            },
            "url": {"raw": "{{baseUrl}}/auth/login", "host": ["{{baseUrl}}"], "path": ["auth", "login"]}
          }
        }
      ]
    }
  ],
  "variable": [
    {"key": "baseUrl", "value": "http://localhost:8000"}
  ]
}
```

## WebSocket Events (Video Service)

For real-time video consultation:

```javascript
const io = require('socket.io-client');

const socket = io('http://localhost:4004', {
  auth: {
    token: 'your_access_token'
  }
});

// Join session
socket.emit('join_session', {
  sessionId: 'session_uuid',
  userId: 'user_uuid',
  role: 'doctor' // or 'patient'
});

// Handle WebRTC signaling
socket.on('offer', (data) => {
  // Handle offer from remote peer
});

socket.on('answer', (data) => {
  // Handle answer from remote peer
});

socket.on('ice_candidate', (data) => {
  // Handle ICE candidate
});

// Send offer
socket.emit('offer', {
  sessionId: 'session_uuid',
  offer: webrtc_offer
});
```

## MQTT (IoT Service)

For IoT device data streaming:

```javascript
const mqtt = require('mqtt');

const client = mqtt.connect('mqtt://localhost:1883', {
  username: 'device_id',
  password: 'device_token'
});

client.on('connect', () => {
  console.log('Connected to IoT service');

  // Publish vital signs
  client.publish('vitals/patient_001', JSON.stringify({
    metric: 'heart_rate',
    value: 72,
    unit: 'bpm',
    timestamp: new Date().toISOString()
  }));
});

client.on('message', (topic, message) => {
  console.log('Received:', topic, message.toString());
});
```

## Rate Limiting

All endpoints are rate-limited:

- **Registration**: 5 attempts per 15 minutes
- **Login**: 10 attempts per 15 minutes
- **Token Refresh**: 30 attempts per hour

When rate limit is exceeded:
```json
{
  "success": false,
  "message": "Too many requests. Please try again later."
}
```

## Error Responses

### 400 - Bad Request
```json
{
  "success": false,
  "message": "Validation failed.",
  "errors": [
    {"field": "email", "message": "Invalid email address"}
  ]
}
```

### 401 - Unauthorized
```json
{
  "success": false,
  "message": "Invalid or expired token."
}
```

### 403 - Forbidden
```json
{
  "success": false,
  "message": "Access denied. Insufficient permissions."
}
```

### 404 - Not Found
```json
{
  "success": false,
  "message": "Route not found"
}
```

### 500 - Internal Server Error
```json
{
  "success": false,
  "message": "Internal server error"
}
```

## Testing Checklist

- [ ] Auth Service: Register, Login, MFA, Token refresh
- [ ] User Service: Get/update profile, Patient/Provider creation
- [ ] Appointment Service: Create, reschedule, emergency booking
- [ ] Video Service: Session creation, WebRTC connection
- [ ] IoT Service: Device registration, data ingestion
- [ ] Prescription Service: Create prescriptions
- [ ] Triage Service: Symptom assessment
- [ ] Notification Service: Multi-channel delivery
- [ ] Rate limiting and security
- [ ] Error handling and validation

## Performance Testing

Use k6 for load testing:

```javascript
// load-test.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 100 },
    { duration: '1m', target: 500 },
    { duration: '30s', target: 0 },
  ],
};

export default function () {
  const res = http.post('http://localhost:8000/auth/login', {
    email: 'patient@smamrasa.com',
    password: 'Admin123!',
  });

  check(res, {
    'login successful': (r) => r.status === 200,
    'has access token': (r) => r.json().data.accessToken !== undefined,
  });

  sleep(1);
}
```

Run with: `k6 run load-test.js`
