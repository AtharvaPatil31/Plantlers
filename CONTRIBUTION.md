# 🎯 Contribution: Custom Backend Integration & Supabase Removal

**Contributor:** [@Manaswin05](https://github.com/Manaswin05)  
**Original Repo:** [@AtharvaPatil31/Plantlers](https://github.com/AtharvaPatil31/Plantlers)  
**Type:** Feature Enhancement  
**Status:** Ready for Review

---

## 📋 Summary

This contribution **removes Supabase dependency** from the Flutter app and **integrates it exclusively with the existing custom Node.js backend**, providing full control over authentication, database, and email functionality.

### What Changed?

✅ **Removed** Supabase Flutter SDK (`supabase_flutter`)  
✅ **Rewrote** authentication data source to use custom backend APIs  
✅ **Fixed** API endpoint configuration (port correction)  
✅ **Added** comprehensive setup documentation  
✅ **Maintained** all existing features (email/password auth, OTP, Google Sign-In)

---

## 🎯 Why This Change?

### Problems with Previous Setup:
1. **Mixed backends:** App used both Supabase AND custom backend (confusing)
2. **Vendor lock-in:** Dependent on Supabase for core auth functionality
3. **Incomplete migration:** Backend code existed but wasn't being used
4. **No control:** Email templates, rate limiting, and auth logic controlled by Supabase

### Benefits of This Change:
✅ **Full control** over authentication flow  
✅ **Custom email templates** (OTP styling, branding)  
✅ **No external dependencies** (except Firebase for Google Sign-In)  
✅ **Easier debugging** (all auth logic in your codebase)  
✅ **Cost-effective** (no Supabase subscription needed)  
✅ **Scalable** (deploy anywhere - Railway, Render, AWS, etc.)

---

## 📁 Files Changed

### Flutter App (Frontend)

#### Modified Files:
```
lib/core/constants/api_constants.dart
  └─ Changed port from 3000 → 5000 (matches backend)

lib/features/auth/data/datasources/auth_remote_datasource.dart
  └─ Removed all Supabase code
  └─ Implemented pure Dio HTTP client for backend APIs
  └─ Added support for refresh token endpoint

lib/features/auth/data/models/google_auth_model.dart
  └─ Fixed syntax errors
  └─ Updated JSON parsing to match backend response

pubspec.yaml
  └─ Removed: supabase_flutter: ^2.8.4
  └─ Kept: firebase_auth (for Google Sign-In only)
```

### Backend (Node.js)

#### Modified Files:
```
backend/.env.example
  └─ Added detailed Gmail setup instructions

backend/src/utils/email.js
  └─ Already perfect! (sends OTP via Gmail SMTP)

backend/src/controllers/auth.controller.js
  └─ Already perfect! (handles all auth logic)
```

#### New Files:
```
backend/SETUP_GUIDE.md
  └─ Complete backend setup documentation
  └─ MongoDB, Gmail, Firebase, Google OAuth setup
  └─ Deployment guides (Railway, Render)

backend/ENV_SETUP_QUICKSTART.md
  └─ 3-minute .env configuration guide
  └─ Quick reference for Gmail app password

backend/src/models/User.js
backend/src/models/RefreshToken.js
backend/src/models/Plant.js
backend/src/models/index.js
  └─ MongoDB schema definitions
```

### Documentation

#### New Files:
```
INTEGRATION_SUMMARY.md
  └─ Technical details of the integration
  └─ Authentication flows (email, OTP, Google)
  └─ Database schema documentation
  └─ Security features overview

NEXT_STEPS.md
  └─ Step-by-step setup checklist
  └─ Troubleshooting guide
  └─ Quick start for developers

API_TESTING_GUIDE.md
  └─ All API endpoints with examples
  └─ Curl commands for testing
  └─ Expected request/response formats
```

---

## 🔄 Authentication Flow Changes

### Before (Mixed Setup):
```
Flutter App
    ↓
Supabase (auth, database)
    ↓
Custom Backend (unused)
```

### After (Clean Setup):
```
Flutter App
    ↓
Custom Backend (all auth logic)
    ↓
MongoDB (user storage)
    ↓
Gmail SMTP (OTP emails)
```

### Google Sign-In Flow:
```
Flutter → Google SDK → Firebase Auth → Custom Backend → MongoDB
```

---

## 🧪 Testing Performed

### ✅ Email/Password Authentication
- [x] User registration creates account in MongoDB
- [x] Login returns JWT access + refresh tokens
- [x] Logout invalidates refresh token
- [x] Password is hashed with bcrypt

### ✅ Password Reset (OTP)
- [x] Forgot password generates 6-digit OTP
- [x] OTP email sent via Gmail SMTP
- [x] OTP expires after 10 minutes
- [x] Verify OTP validates correctly
- [x] Reset password updates hash and clears OTP

### ✅ Google Sign-In
- [x] Firebase verifies Google token
- [x] Backend receives Firebase ID token
- [x] User created/found in MongoDB
- [x] Returns custom JWT tokens

### ✅ Token Management
- [x] Access token expires in 7 days (configurable)
- [x] Refresh token rotates on use
- [x] Invalid tokens return 401
- [x] Tokens stored securely in flutter_secure_storage

---

## 📦 Dependencies

### Added:
- None! (Removed Supabase instead)

### Removed:
- `supabase_flutter: ^2.8.4`

### Kept:
- `firebase_auth: ^5.0.0` (for Google Sign-In only)
- `firebase_core: ^3.0.0`
- `dio: ^5.9.2` (HTTP client)
- `google_sign_in: ^7.2.0`

### Backend Dependencies (Already Existed):
- `express: 4.22.1`
- `mongoose: ^8.7.3`
- `nodemailer: 8.0.7`
- `jsonwebtoken: 9.0.2`
- `bcryptjs: 2.4.3`
- `google-auth-library: 9.10.0`

---

## 🚀 Setup Instructions

### For Reviewers/Contributors:

1. **Backend Setup:**
```bash
cd backend
npm install
cp .env.example .env
# Edit .env with your credentials (see backend/ENV_SETUP_QUICKSTART.md)
npm run dev
```

2. **Flutter Setup:**
```bash
flutter pub get
# Update lib/core/constants/api_constants.dart with your IP
flutter run
```

3. **See Complete Guide:**
   - `NEXT_STEPS.md` - Step-by-step checklist
   - `backend/SETUP_GUIDE.md` - Detailed backend setup
   - `INTEGRATION_SUMMARY.md` - Technical details

---

## 🔒 Security Considerations

✅ **Password Hashing:** bcrypt with 10 rounds  
✅ **JWT Tokens:** Signed with secret, includes expiry  
✅ **Token Rotation:** Refresh tokens deleted on logout  
✅ **OTP Expiry:** 10 minutes maximum  
✅ **Rate Limiting:** 20 requests/15min on auth endpoints  
✅ **Input Validation:** Email format, password length  
✅ **CORS:** Properly configured  
✅ **Helmet:** Security headers enabled  
✅ **Environment Variables:** Secrets in .env (gitignored)

---

## 📊 Breaking Changes

### ⚠️ Users Must:
1. **Remove Supabase project** (no longer needed)
2. **Set up MongoDB** (local or Atlas)
3. **Configure Gmail** for OTP emails
4. **Run `flutter pub get`** to remove Supabase dependency
5. **Update `.env`** with new credentials

### Migration Path:
- Existing Supabase users will need to re-register
- No automatic data migration provided (separate project)
- Fresh install recommended

---

## 🎯 Future Improvements

Potential follow-up contributions:
- [ ] Add email verification on registration
- [ ] Implement social login (Apple, Facebook)
- [ ] Add 2FA/TOTP support
- [ ] Implement rate limiting on Flutter side
- [ ] Add biometric authentication option
- [ ] Create admin dashboard for user management

---

## 📝 Checklist for Maintainers

Before merging:
- [ ] Code review completed
- [ ] All tests passing (manual testing done)
- [ ] Documentation reviewed
- [ ] `.env.example` doesn't contain secrets
- [ ] Sensitive files in `.gitignore`
- [ ] README updated with new setup instructions
- [ ] Contributors credited

---

## 🙏 Acknowledgments

- **Original Author:** [@AtharvaPatil31](https://github.com/AtharvaPatil31)
- **Backend Architecture:** Already well-designed, just needed integration
- **Contributor:** [@Manaswin05](https://github.com/Manaswin05)

---

## 📞 Questions?

For questions about this contribution:
- Open an issue in the repo
- Tag @Manaswin05
- Refer to documentation in:
  - `INTEGRATION_SUMMARY.md`
  - `backend/SETUP_GUIDE.md`
  - `NEXT_STEPS.md`

---

## ✅ Ready to Merge?

This PR is:
- ✅ Fully tested
- ✅ Well documented
- ✅ Backward incompatible (breaking change - document in release notes)
- ✅ Improves maintainability
- ✅ Reduces external dependencies
- ✅ Provides full control over auth

**Recommended:** Merge into `develop` first for testing, then `main` when stable.
