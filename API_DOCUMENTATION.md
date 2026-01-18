# Digital Public Infrastructure - API Documentation

## Base URL
```
http://127.0.0.1:8000/api
```

## Authentication

All protected endpoints require JWT authentication. Include the token in the Authorization header:
```
Authorization: Bearer YOUR_ACCESS_TOKEN
```

### Get Access Token
**POST** `/accounts/login/`

Request:
```json
{
  "username": "user1",
  "password": "password123"
}
```

Response:
```json
{
  "refresh": "refresh_token_here",
  "access": "access_token_here",
  "user": {
    "id": 1,
    "username": "user1",
    "email": "user@example.com",
    "role": "citizen"
  }
}
```

---

## Accounts API

### Register User
**POST** `/accounts/register/`

Request:
```json
{
  "username": "citizen1",
  "email": "citizen@example.com",
  "password": "password123",
  "password_confirm": "password123",
  "first_name": "John",
  "last_name": "Doe",
  "role": "citizen",
  "phone_number": "1234567890",
  "address": "123 Main St"
}
```

Response:
```json
{
  "message": "Registration successful",
  "user": {...},
  "requires_approval": false
}
```

### Get User Profile
**GET** `/accounts/profile/`

Requires: Authentication

Response:
```json
{
  "id": 1,
  "username": "citizen1",
  "email": "citizen@example.com",
  "first_name": "John",
  "last_name": "Doe",
  "role": "citizen",
  "is_approved": true
}
```

### List Approval Requests
**GET** `/accounts/approvals/`

Requires: Admin role

Response:
```json
{
  "count": 10,
  "results": [
    {
      "id": 1,
      "user": {...},
      "request_type": "doctor",
      "status": "pending",
      "requested_at": "2026-01-17T10:00:00Z"
    }
  ]
}
```

### Approve Service Provider
**POST** `/accounts/approvals/{id}/approve/`

Requires: Admin role

Response:
```json
{
  "message": "Approval request approved"
}
```

### List Users
**GET** `/accounts/users/`

Requires: Admin role

Response:
```json
{
  "count": 150,
  "results": [
    {
      "id": 1,
      "username": "citizen1",
      "email": "citizen@example.com",
      "first_name": "John",
      "last_name": "Doe",
      "role": "citizen",
      "is_approved": true,
      "profile": {...}
    }
  ]
}
```

---

## Core Platform API

### List Services
**GET** `/core/services/`

Response:
```json
{
  "count": 3,
  "results": [
    {
      "id": 1,
      "name": "Healthcare Services",
      "service_type": "healthcare",
      "description": "...",
      "is_active": true
    }
  ]
}
```

### Create Service
**POST** `/core/services/`

Requires: Admin role

Request:
```json
{
  "name": "Education Services",
  "service_type": "education",
  "description": "Educational services platform",
  "icon": "📚"
}
```

### Dashboard Statistics
**GET** `/core/dashboard/stats/`

Requires: Authentication

Response:
```json
{
  "total_users": 1234,
  "total_services": 3,
  "total_requests": 5678,
  "pending_approvals": 15,
  "healthcare": {
    "total": 450,
    "pending": 120
  },
  "city_services": {
    "total": 890,
    "pending": 45
  },
  "agriculture": {
    "total": 234,
    "pending": 38
  },
  "role_breakdown": {
    "citizen": 1000,
    "doctor": 50,
    "city_staff": 30,
    "agri_officer": 25,
    "admin": 5
  },
  "service_usage": {
    "healthcare": 450,
    "city_services": 890,
    "agriculture": 234
  },
  "daily_activity": [
    { "date": "Jan 12", "count": 45 },
    { "date": "Jan 13", "count": 52 },
    ...
  ],
  "performance": {
    "healthcare": 45,
    "city_services": 120,
    "agriculture": 38
  },
  "system_health": {
    "cpu_usage": 12.5,
    "memory_usage": 45.8,
    "avg_response_time": 180
  }
}
```

---

## Healthcare API

### List Doctors
**GET** `/healthcare/doctors/`

Response:
```json
{
  "count": 25,
  "results": [
    {
      "id": 1,
      "user_details": {
        "full_name": "Dr. John Smith",
        "email": "doctor@example.com"
      },
      "specialization": "Cardiology",
      "qualification": "MBBS, MD",
      "experience_years": 10,
      "consultation_fee": "500.00",
      "is_available": true
    }
  ]
}
```

### Get Available Doctors
**GET** `/healthcare/doctors/available/`

Response: Same as List Doctors, filtered by availability

### Book Appointment
**POST** `/healthcare/appointments/`

Requires: Authentication

Request:
```json
{
  "doctor": 1,
  "appointment_date": "2026-01-20",
  "appointment_time": "10:00:00",
  "reason": "Regular checkup"
}
```

Response:
```json
{
  "id": 1,
  "doctor_name": "Dr. John Smith",
  "patient_name": "John Doe",
  "appointment_date": "2026-01-20",
  "appointment_time": "10:00:00",
  "status": "scheduled",
  "created_at": "2026-01-17T10:00:00Z"
}
```

### List Appointments
**GET** `/healthcare/appointments/`

Requires: Authentication

Response:
```json
{
  "count": 5,
  "results": [...]
}
```

### Complete Appointment
**POST** `/healthcare/appointments/{id}/complete/`

Requires: Doctor role

Response:
```json
{
  "message": "Appointment completed"
}
```
### Create Medical Record
**POST** `/healthcare/medical-records/`

Requires: Doctor role

Request:
```json
{
  "patient": 1,
  "appointment": 1,
  "diagnosis": "Common cold",
  "symptoms": "Fever, cough",
  "vital_signs": {
    "temperature": "98.6",
    "bp": "120/80",
    "pulse": "72"
  },
  "treatment_plan": "Rest and fluids"
}
```
*Note: `appointment` is optional; records can be created by selecting a patient directly.*

### Get Patient History
**GET** `/healthcare/medical-records/patient_history/?patient_id=1`

Requires: Doctor role

Response:
```json
[
  {
    "id": 1,
    "doctor_name": "Dr. John Smith",
    "diagnosis": "Common cold",
    "created_at": "2026-01-15T10:00:00Z",
    "prescriptions": [...]
  }
]
```

### Download Prescription PDF
**GET** `/healthcare/medical-records/{id}/prescription_pdf/`

Generates a professionally branded PDF prescription with government healthcare branding, doctor details, and clinical notes.

Response: Binary PDF stream (application/pdf)

---

## City Services API

### Submit Complaint
**POST** `/city/complaints/`

Requires: Authentication

*Note: All submitted complaints are automatically analyzed by our **AI Prioritization Engine (GPT-4o-mini)** to assess public safety impact and assign a priority level (low/medium/high).*

Request:
```json
{
  "category": 1,
  "title": "Street Light Not Working",
  "description": "The street light on Main St has been out for 3 days",
  "location": "Main Street, Block A"
}
```

Response:
```json
{
  "id": 1,
  "complaint_id": "CMP-A1B2C3D4",
  "title": "Street Light Not Working",
  "status": "submitted",
  "priority": "medium",
  "created_at": "2026-01-17T10:00:00Z"
}
```

### List Complaints
**GET** `/city/complaints/`

Requires: Authentication

Response:
```json
{
  "count": 42,
  "results": [
    {
      "id": 1,
      "complaint_id": "CMP-A1B2C3D4",
      "citizen_name": "John Doe",
      "category_name": "Infrastructure",
      "title": "Street Light Not Working",
      "status": "submitted",
      "responses": []
    }
  ]
}
```

### Respond to Complaint
**POST** `/city/complaints/{id}/respond/`

Requires: City Staff role

Request:
```json
{
  "message": "We have received your complaint and will address it within 48 hours",
  "action_taken": "Assigned to maintenance team"
}
```

### Resolve Complaint
**POST** `/city/complaints/{id}/resolve/`

Requires: City Staff role

Response:
```json
{
  "message": "Complaint resolved"
}
```

---

## Agriculture API

### Submit Farmer Query
**POST** `/agriculture/queries/`

Requires: Authentication

Request:
```json
{
  "crop_category": 1,
  "title": "Pest control for wheat",
  "description": "My wheat crop is affected by pests. What should I do?",
  "location": "Village XYZ"
}
```

Response:
```json
{
  "id": 1,
  "query_id": "AGR-X1Y2Z3A4",
  "title": "Pest control for wheat",
  "status": "submitted",
  "created_at": "2026-01-17T10:00:00Z"
}
```

### List Farmer Queries
**GET** `/agriculture/queries/`

Requires: Authentication

Response:
```json
{
  "count": 38,
  "results": [...]
}
```

### Respond to Query
**POST** `/agriculture/queries/{id}/respond/`

Requires: Agricultural Officer role

Request:
```json
{
  "advice": "Use organic pesticide XYZ. Apply in the evening...",
  "is_validated": false
}
```

### List Agricultural Updates
**GET** `/agriculture/updates/`

Query Parameters:
- `district`: Filter by district
- `type`: Filter by update type (weather, market, scheme, advisory, pest)

Response:
```json
{
  "count": 12,
  "results": [
    {
      "id": 1,
      "title": "Weather Alert: Heavy Rain Expected",
      "content": "...",
      "update_type": "weather",
      "is_urgent": true,
      "created_at": "2026-01-17T10:00:00Z"
    }
  ]
}
```

### Post Agricultural Update
**POST** `/agriculture/updates/`

Requires: Agricultural Officer role

Request:
```json
{
  "title": "Market Price Update",
  "content": "Wheat prices have increased to Rs. 2500/quintal",
  "update_type": "market",
  "crop_category": 1,
  "district": "District ABC",
  "is_urgent": false
}
```

---

## Error Responses

### 400 Bad Request
```json
{
  "field_name": ["Error message"]
}
```

### 401 Unauthorized
```json
{
  "detail": "Authentication credentials were not provided."
}
```

### 403 Forbidden
```json
{
  "detail": "You do not have permission to perform this action."
}
```

### 404 Not Found
```json
{
  "detail": "Not found."
}
```

### 500 Internal Server Error
```json
{
  "detail": "Internal server error"
}
```

---

## Rate Limiting

Currently not implemented. For production:
- 100 requests per minute per user
- 1000 requests per hour per IP

---

## Pagination

All list endpoints support pagination:
- Default page size: 20
- Query parameters:
  - `page`: Page number (default: 1)
  - `page_size`: Items per page (max: 100)

Example:
```
GET /api/healthcare/doctors/?page=2&page_size=10
```

---

## Testing with curl

### Register and Login
```bash
# Register
curl -X POST http://127.0.0.1:8000/api/accounts/register/ \
  -H "Content-Type: application/json" \
  -d '{"username":"test","email":"test@example.com","password":"pass123","password_confirm":"pass123","first_name":"Test","last_name":"User","role":"citizen"}'

# Login
curl -X POST http://127.0.0.1:8000/api/accounts/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"pass123"}'
```

### Use API with Token
```bash
# Get profile
curl -X GET http://127.0.0.1:8000/api/accounts/profile/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"

# Get dashboard stats
curl -X GET http://127.0.0.1:8000/api/core/dashboard/stats/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

---

## AI & Machine Learning API

### Predict Disease Risks
**POST** `/healthcare/predict-disease/`

Provides an AI-driven health risk assessment based on demographic and lifestyle data.

Request:
```json
{
  "age": 45,
  "gender": "M",
  "bmi": 28.5,
  "smoking": "low",
  "alcohol": "moderate",
  "activity": "high",
  "family_diabetes": true,
  "family_heart": false,
  "family_cancer": true
}
```

Response:
```json
{
  "diabetes": 12.5,
  "heart": 45.8,
  "cancer": 22.3,
  "checkups": ["Blood Sugar Test", "ECG"],
  "advice": ["Maintain active lifestyle", "Monitor blood pressure"]
}
```

### Recommend Crop
**POST** `/agriculture/recommend-crop/`

Suggests the most suitable crop and predicts yield level using agricultural ML models.

Request:
```json
{
  "location": "North Region",
  "season": "Monsoon",
  "soil_type": "Clay",
  "irrigation": "Canal",
  "rainfall": "High",
  "land_size": 5.5
}
```

Response:
```json
{
  "crop": "Rice",
  "yield_level": 85.0,
  "advisory": "Nitrogen-rich fertilizer & water retention needed",
  "risk": "No major risk detected"
}
```

---

**Built for AU Hackathon 2026** 🚀
