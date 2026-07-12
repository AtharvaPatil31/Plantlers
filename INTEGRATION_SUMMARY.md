# Flutter App ↔ Custom Backend Integration Summary

## ✅ What Was Changed

### Backend (Node.js + Express + MongoDB)
✅ **Already Configured** - No changes needed!

Your backend at `backend/` folder already has:
- ✅ Email/password authentication
- ✅ OTP-based password reset via Gmail
- ✅ Google OAuth sign-in verification
- ✅ JWT token management (access + refresh tokens)
- ✅ MongoDB user storage
- ✅ Nodemailer for sending emails

### Flutter App Changes

#### 1. **Removed Supabase** ❌
- Removed `supabase_flutter` dependency from `pubspec.yaml`
- Deleted all Supabase client code

#### 2. **Updated Auth Data Source** ✅
File: `lib/features/auth/data/datasources/auth_remote_datasource.dart`

**Before:** Mixed Supabase + custom backend (confusing)
**After:** Pure custom backend using Dio HTTP client

**All API calls now use your backend:**
```dart
- POST /v1/auth/register     → Email/password registration
- POST /v1/auth/login        → Email/password login
- POST /v1/auth/logout       → Logout (invalidates refresh token)
- POST /v1/auth/forgot-password  → Send OTP email
- POST /v1/auth/verify-otp   → Verify OTP code
- POST /v1/auth/reset-password   → Reset password with OTP
- POST /v1/auth/google       → Google Sign-In (Firebase → Backend)
- POST /v1/auth/refresh      → Refresh access token
```

#### 3. **Fixed API Base URL** ✅
File: `lib/core/constants/api_constants.dart`

Changed port from `3000` → `5000` (matches backend)

```dart
static const String baseUrl = 'http://192.168.1.5:5000/v1';
```

#### 4. **Fixed Google Auth Model** ✅
File: `lib/features/auth/data/models/google_auth_model.dart`

Fixed syntax errors and JSON parsing to match backend response format.

---

## 🔄 Authentication Flow

### Email/Password Flow
```
User enters email/password
    ↓
Flutter App → POST /v1/auth/login
    ↓
Backend verifies password (bcrypt)
    ↓
Backend generates JWT tokens
    ↓
Flutter receives: {access_token, refresh_token, id, email, name}
    ↓
Tokens stored in flutter_secure_storage
```

### Google Sign-In Flow
```
User clicks "Sign in with Google"
    ↓
Flutter → Google Sign-In SDK (native picker)
    ↓
User selects Google account
    ↓
Flutter receives Google ID token
    ↓
Flutter → Firebase Auth (verifies token)
    ↓
Flutter gets Firebase ID token
    ↓
Flutter → POST /v1/auth/google {id_token: firebaseToken}
    ↓
Backend verifies Firebase token with Google
    ↓
Backend creates/finds user in MongoDB
    ↓
Backend generates JWT tokens
    ↓
Flutter receives: {access_token, refresh_token, id, email, name, avatar_url}
```

### Password Reset Flow
```
User clicks "Forgot Password"
    ↓
Flutter → POST /v1/auth/forgot-password {email}
    ↓
Backend generates 6-digit OTP
    ↓
Backend stores OTP + expiry (10 min) in MongoDB
    ↓
Backend sends email via Gmail SMTP
    ↓
User receives email with OTP
    ↓
User enters OTP in Flutter app
    ↓
Flutter → POST /v1/auth/verify-otp {email, otp}
    ↓
Backend validates OTP and expiry
    ↓
User enters new password
    ↓
Flutter → POST /v1/auth/reset-password {email, otp, new_password}
    ↓
Backend updates password, clears OTP, invalidates all tokens
```

---

## 📧 Email Configuration

Your backend uses **Gmail SMTP** to send OTP emails.

### Required .env Variables
```env
EMAIL_FROM=Plantlers <your_gmail@gmail.com>
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your_gmail@gmail.com
EMAIL_PASS=your_16_character_app_password  # NOT your regular password!
```

### How to Get Gmail App Password

1. **Enable 2-Step Verification**
   - Go to: https://myaccount.google.com/security
   - Enable **2-Step Verification**

2. **Create App Password**
   - Search for "App passwords"
   - Select: **Mail** + **Other (Custom name)** → "Plantlers"
   - Copy the 16-character password (remove spaces)
   - Paste into `.env` as `EMAIL_PASS`

### Email Template

The OTP email looks like:

```
Subject: Plantlers — Password Reset OTP

Reset Your Password

Use the OTP below to reset your Plantlers password. 
It expires in 10 minutes.

┌────────────┐
│  123456    │  ← 6-digit OTP
└────────────┘

If you didn't request this, ignore this email.
```

**Email file:** `backend/src/utils/email.js`

---

## 🔐 Google OAuth Configuration

### Backend Setup

1. **Get Google Client ID** from Firebase Console:
   - Firebase Project → **Project Settings** → **Service accounts**
   - Or: https://console.cloud.google.com/apis/credentials
   - Copy **Web client (auto created by Google Service)** ID

2. **Add to backend `.env`:**
```env
GOOGLE_CLIENT_ID=123456789-abc123.apps.googleusercontent.com
```

### Flutter App Setup

1. **Add Firebase to Flutter:**
```bash
flutterfire configure
```

2. **Ensure `google-services.json` exists:**
   - Download from Firebase Console
   - Place in: `android/app/google-services.json`

3. **Package name must match:**
   - Flutter: `com.example.plantlers` (in `android/app/build.gradle.kts`)
   - Firebase: Same package name when registering Android app

---

## 🚀 How to Run

### 1. Start Backend

```bash
cd backend
npm install
npm run dev
```

**Expected output:**
```
🌿 Plantlers API running on port 5000
   Environment : development
   Health check: http://localhost:5000/health
```

### 2. Update Flutter App IP

Find your local IP:
```bash
ipconfig  # Windows
```

Update `lib/core/constants/api_constants.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP_HERE:5000/v1';
```

### 3. Run Flutter App

```bash
flutter pub get
flutter run
```

---

## 🧪 Testing

### Test Backend Directly

```bash
# Health check
curl http://localhost:5000/health

# Register
curl -X POST http://localhost:5000/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"password123"}'

# Login
curl -X POST http://localhost:5000/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

### Test in Flutter App

1. **Register new account** → Should create user in MongoDB
2. **Login** → Should receive JWT tokens
3. **Forgot password** → Should receive OTP email
4. **Google Sign-In** → Should authenticate and create/login user

---

## 📊 Database Schema

### User Collection (MongoDB)

```javascript
{
  _id: ObjectId("..."),
  email: "user@example.com",
  name: "User Name",
  passwordHash: "$2a$10$...",  // bcrypt hashed (only for email/password users)
  googleId: "1234567890",       // Google user ID (only for Google users)
  authProvider: "local" | "google",
  avatarUrl: "https://...",
  resetOtp: "123456",           // Temporary OTP for password reset
  resetOtpExpiry: ISODate("..."), // OTP expiration (10 minutes)
  isActive: true,
  createdAt: ISODate("..."),
  updatedAt: ISODate("...")
}
```

### RefreshToken Collection

```javascript
{
  _id: ObjectId("..."),
  userId: ObjectId("..."),      // References User
  token: "eyJhbGc...",          // JWT refresh token
  createdAt: ISODate("..."),
  expiresAt: ISODate("...")     // 7 days from creation
}
```

---

## 🔒 Security Features

✅ **Password Hashing:** bcrypt (10 rounds)
✅ **JWT Tokens:** Signed with secret, includes expiry
✅ **Token Rotation:** Refresh tokens deleted on logout/password reset
✅ **OTP Expiry:** 10 minutes
✅ **Rate Limiting:** 20 requests/15min for auth endpoints
✅ **CORS:** Configured for mobile apps
✅ **Helmet:** Security headers enabled
✅ **Input Validation:** Email format, password length checks

---

## 🎯 What You Still Need to Do

### 1. Configure `.env` File ⚠️

Edit `backend/.env`:
```env
# Generate new JWT secret:
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"

JWT_SECRET=<paste_generated_secret_here>

# Add your Gmail credentials:
EMAIL_USER=your_gmail@gmail.com
EMAIL_PASS=your_16_char_app_password

# Add Google OAuth client ID:
GOOGLE_CLIENT_ID=123456789-abc.apps.googleusercontent.com
```

### 2. Update Flutter IP Address ⚠️

```dart
// lib/core/constants/api_constants.dart
static const String baseUrl = 'http://YOUR_LOCAL_IP:5000/v1';
```

### 3. Install MongoDB ⚠️

- **Local:** https://www.mongodb.com/try/download/community
- **Cloud:** https://www.mongodb.com/cloud/atlas (free tier)

### 4. Run `flutter pub get` ⚠️

```bash
flutter pub get  # Updates dependencies (removes Supabase)
```

---

## 📁 Changed Files Summary

### Flutter App
```
✅ lib/core/constants/api_constants.dart           (port 3000 → 5000)
✅ lib/features/auth/data/datasources/auth_remote_datasource.dart  (Supabase → Custom backend)
✅ lib/features/auth/data/models/google_auth_model.dart  (syntax fixes)
✅ pubspec.yaml  (removed supabase_flutter)
```

### Backend
```
✅ backend/.env           (added Gmail setup instructions)
✅ backend/.env.example   (added Gmail setup instructions)
✅ backend/SETUP_GUIDE.md (NEW - complete setup documentation)
```

### Documentation
```
✅ INTEGRATION_SUMMARY.md (NEW - this file)
```

---

## 📚 Additional Resources

- **Backend Setup Guide:** `backend/SETUP_GUIDE.md`
- **API Testing Guide:** `API_TESTING_GUIDE.md`
- **Gmail SMTP:** https://support.google.com/accounts/answer/185833
- **Firebase Docs:** https://firebase.google.com/docs
- **MongoDB Docs:** https://www.mongodb.com/docs/manual/

---

## ✅ Success Checklist

- [ ] Backend dependencies installed (`npm install`)
- [ ] MongoDB running (local or Atlas)
- [ ] `.env` configured with all secrets
- [ ] Gmail App Password created and added
- [ ] Google Client ID added to `.env`
- [ ] Backend running on port 5000
- [ ] Health check returns `200 OK`
- [ ] Flutter dependencies updated (`flutter pub get`)
- [ ] Flutter app points to correct IP
- [ ] Firebase configured in Flutter app
- [ ] `google-services.json` in `android/app/`
- [ ] Test registration works
- [ ] Test login works
- [ ] Test forgot password sends email
- [ ] Test Google Sign-In works

---

## 🎉 You're All Set!

Your Flutter app now uses **your custom backend exclusively** for all authentication:

- ✅ No more Supabase dependency
- ✅ Full control over auth logic
- ✅ Email OTP via your Gmail
- ✅ Google Sign-In verified by your backend
- ✅ JWT tokens managed by you
- ✅ User data in your MongoDB

**Next Steps:**
1. Configure `.env` file
2. Start backend: `npm run dev`
3. Update Flutter IP address
4. Run: `flutter pub get && flutter run`
5. Test all auth flows!
