# Plantlers API Testing Guide

## Base URL
```
http://localhost:5000
```

## Health Check
### GET /health
**Description:** Check if the API is running
**Authentication:** None required
**URL:** `http://localhost:5000/health`
**Method:** GET
**Response:**
```json
{
  "status": "ok",
  "service": "Plantlers API", 
  "environment": "development",
  "timestamp": "2026-07-08T10:30:00.000Z"
}
```

---

## Authentication Endpoints

### 1. Register User
**URL:** `http://localhost:5000/v1/auth/register`
**Method:** POST
**Authentication:** None
**Content-Type:** application/json

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "Password123"
}
```

**Validation Rules:**
- `name`: Required, max 100 characters
- `email`: Required, valid email format
- `password`: Required, min 8 characters, must contain uppercase letter and number

---

### 2. Login User
**URL:** `http://localhost:5000/v1/auth/login`
**Method:** POST
**Authentication:** None
**Content-Type:** application/json

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "Password123"
}
```

**Validation Rules:**
- `email`: Required, valid email format
- `password`: Required

---

### 3. Google Sign In
**URL:** `http://localhost:5000/v1/auth/google`
**Method:** POST
**Authentication:** None
**Content-Type:** application/json

**Request Body:**
```json
{
  "id_token": "google_oauth_id_token_here"
}
```

**Validation Rules:**
- `id_token`: Required

---

### 4. Refresh Token
**URL:** `http://localhost:5000/v1/auth/refresh`
**Method:** POST
**Authentication:** None
**Content-Type:** application/json

**Request Body:**
```json
{
  "refresh_token": "your_refresh_token_here"
}
```

---

### 5. Forgot Password
**URL:** `http://localhost:5000/v1/auth/forgot-password`
**Method:** POST
**Authentication:** None
**Content-Type:** application/json

**Request Body:**
```json
{
  "email": "john@example.com"
}
```

**Validation Rules:**
- `email`: Required, valid email format

---

### 6. Verify OTP
**URL:** `http://localhost:5000/v1/auth/verify-otp`
**Method:** POST
**Authentication:** None
**Content-Type:** application/json

**Request Body:**
```json
{
  "email": "john@example.com",
  "otp": "123456"
}
```

**Validation Rules:**
- `email`: Required, valid email format
- `otp`: Required, exactly 6 characters

---

### 7. Reset Password
**URL:** `http://localhost:5000/v1/auth/reset-password`
**Method:** POST
**Authentication:** None
**Content-Type:** application/json

**Request Body:**
```json
{
  "email": "john@example.com",
  "otp": "123456",
  "new_password": "NewPassword123"
}
```

**Validation Rules:**
- `email`: Required, valid email format
- `otp`: Required
- `new_password`: Required, min 8 characters, must contain uppercase letter and number

---

### 8. Logout
**URL:** `http://localhost:5000/v1/auth/logout`
**Method:** POST
**Authentication:** Required (Bearer Token)
**Headers:**
```
Authorization: Bearer your_jwt_token_here
```

---

## User Profile Endpoints
*All user endpoints require authentication*

### 1. Get User Profile
**URL:** `http://localhost:5000/v1/user/profile`
**Method:** GET
**Authentication:** Required (Bearer Token)
**Headers:**
```
Authorization: Bearer your_jwt_token_here
```

---

### 2. Update User Profile
**URL:** `http://localhost:5000/v1/user/profile/update`
**Method:** PATCH
**Authentication:** Required (Bearer Token)
**Content-Type:** application/json
**Headers:**
```
Authorization: Bearer your_jwt_token_here
```

**Request Body:**
```json
{
  "name": "Updated Name"
}
```

**Validation Rules:**
- `name`: Optional, max 100 characters

---

### 3. Delete User Account
**URL:** `http://localhost:5000/v1/user/profile`
**Method:** DELETE
**Authentication:** Required (Bearer Token)
**Headers:**
```
Authorization: Bearer your_jwt_token_here
```

---

## Plant Endpoints

### 1. Get All Plants
**URL:** `http://localhost:5000/v1/plants`
**Method:** GET
**Authentication:** None required

---

### 2. Get Plant by ID
**URL:** `http://localhost:5000/v1/plants/{plant_id}`
**Method:** GET
**Authentication:** None required

**Example:** `http://localhost:5000/v1/plants/60f7b3b3b3b3b3b3b3b3b3b3`

---

### 3. Create Plant (Admin)
**URL:** `http://localhost:5000/v1/plants`
**Method:** POST
**Authentication:** Required (Bearer Token)
**Content-Type:** application/json
**Headers:**
```
Authorization: Bearer your_jwt_token_here
```

**Request Body:**
```json
{
  "name": "Monstera Deliciosa",
  "scientific_name": "Monstera deliciosa",
  "description": "A popular houseplant with large, split leaves",
  "care_instructions": {
    "watering": "Water when top inch of soil is dry",
    "light": "Bright, indirect light",
    "humidity": "High humidity preferred"
  },
  "price": 25.99,
  "availability": true,
  "category": "Indoor Plants",
  "image_url": "https://example.com/monstera.jpg"
}
```

---

## Rate Limiting
- **Authentication endpoints:** 20 requests per 15 minutes
- **General endpoints:** 100 requests per 15 minutes

---

## Testing Tools Recommendations

### Postman Collection
1. Create a new Postman collection
2. Set up environment variables:
   - `base_url`: `http://localhost:5000`
   - `auth_token`: (set after login)

### cURL Examples

#### Register:
```bash
curl -X POST http://localhost:5000/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com", 
    "password": "Password123"
  }'
```

#### Login:
```bash
curl -X POST http://localhost:5000/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Password123"
  }'
```

#### Get Profile (after login):
```bash
curl -X GET http://localhost:5000/v1/user/profile \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

---

## Error Responses
All endpoints return errors in the following format:
```json
{
  "message": "Error description here"
}
```

Common HTTP status codes:
- `200`: Success
- `201`: Created
- `400`: Bad Request (validation errors)
- `401`: Unauthorized (missing/invalid token)
- `404`: Not Found
- `429`: Too Many Requests (rate limited)
- `500`: Internal Server Error

---

## Notes
1. **JWT Tokens:** Save the token from login/register responses and include it in the Authorization header for protected endpoints
2. **CORS:** The API allows requests from `http://localhost:3000` by default
3. **MongoDB:** Make sure MongoDB is running on `mongodb://localhost:27017/plantlers`
4. **Environment:** API runs in development mode on port 5000

## Testing Checklist
- [ ] Health check endpoint works
- [ ] User can register with valid data
- [ ] User can login with correct credentials
- [ ] Protected endpoints reject requests without tokens
- [ ] Protected endpoints work with valid tokens
- [ ] Validation errors return 400 status
- [ ] Rate limiting works (test with multiple rapid requests)
- [ ] Plants can be fetched without authentication
- [ ] Plants can be created with authentication