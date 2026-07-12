# 🎯 Next Steps - Get Your App Running

## What Just Happened?

✅ **Removed Supabase** from Flutter app
✅ **Configured** Flutter to use your custom backend exclusively  
✅ **Fixed** auth data source to call your backend APIs
✅ **Updated** port from 3000 → 5000
✅ **Added** comprehensive setup documentation

---

## 🚀 Your Action Items (In Order)

### 1️⃣ Configure Backend Environment (5 minutes)

```bash
cd backend
```

**Edit `.env` file** and update these 3 things:

```env
# 1. Generate JWT secret:
#    Run: node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
JWT_SECRET=<paste generated secret>

# 2. Add your Gmail (for OTP emails)
EMAIL_USER=your_gmail@gmail.com
EMAIL_PASS=<16-char app password from Google>

# 3. Google OAuth (can skip for now, just test email/password first)
GOOGLE_CLIENT_ID=<get from Firebase console later>
```

**Quick guide:** `backend/ENV_SETUP_QUICKSTART.md`  
**Detailed guide:** `backend/SETUP_GUIDE.md`

---

### 2️⃣ Ensure MongoDB is Running (2 minutes)

**Check if installed:**
```bash
mongosh
```

If it connects → ✅ You're good!

If not installed:
- **Windows:** https://www.mongodb.com/try/download/community
- **Mac:** `brew install mongodb-community`
- **Linux:** `sudo apt install mongodb`

---

### 3️⃣ Start Backend (1 minute)

```bash
cd backend
npm install  # First time only
npm run dev
```

**You should see:**
```
🌿 Plantlers API running on port 5000
   Environment : development
   Health check: http://localhost:5000/health
```

---

### 4️⃣ Update Flutter App IP Address (1 minute)

**Find your local IP:**
```bash
ipconfig  # Windows (look for IPv4 Address under your WiFi adapter)
ifconfig  # Mac/Linux
```

Example: `192.168.1.5`

**Edit:** `lib/core/constants/api_constants.dart`

```dart
static const String baseUrl = 'http://192.168.1.5:5000/v1';
//                                   ^^^^^^^^^^^^^ YOUR IP HERE
```

**⚠️ Important:** 
- Don't use `localhost` or `127.0.0.1` (Android can't reach it)
- Your phone and computer must be on **same WiFi network**

---

### 5️⃣ Update Flutter Dependencies (1 minute)

```bash
flutter pub get
```

This removes Supabase and installs any missing packages.

---

### 6️⃣ Run Flutter App (1 minute)

```bash
flutter run
```

Or press **F5** in VS Code.

---

### 7️⃣ Test Everything! (5 minutes)

#### Test 1: Health Check
```bash
curl http://localhost:5000/health
```
✅ Should return: `{"status":"ok",...}`

#### Test 2: Register New User
In your Flutter app:
1. Click **Sign Up**
2. Enter name, email, password
3. Click **Register**

✅ Should create user and log in

#### Test 3: Login
1. Log out
2. Enter same email/password
3. Click **Login**

✅ Should log in successfully

#### Test 4: Forgot Password
1. Click **Forgot Password**
2. Enter your email
3. Check your email for OTP
4. Enter OTP and new password

✅ Should receive email and reset password

#### Test 5: Google Sign-In (optional - requires setup)
See `backend/SETUP_GUIDE.md` → **Google OAuth Setup**

---

## 📁 Documentation Guide

- **Quick Start:** `backend/ENV_SETUP_QUICKSTART.md` (3-minute setup)
- **Complete Setup:** `backend/SETUP_GUIDE.md` (includes Google OAuth, deployment)
- **Integration Details:** `INTEGRATION_SUMMARY.md` (what changed, architecture)
- **API Testing:** `API_TESTING_GUIDE.md` (all endpoints with curl examples)

---

## 🐛 Common Issues

### Backend won't start
```
Error: Cannot find module 'express'
```
**Fix:** `npm install`

---

### MongoDB connection error
```
MongoNetworkError: connect ECONNREFUSED
```
**Fix:** Start MongoDB service
- Windows: Auto-starts
- Mac: `brew services start mongodb-community`
- Linux: `sudo systemctl start mongod`

---

### Flutter can't connect
```
DioException: Connection refused
```
**Fix:**
1. Check backend is running on port 5000
2. Use your local IP (not localhost)
3. Phone and computer on same WiFi
4. Check firewall allows port 5000

---

### Gmail auth error
```
Invalid login: 535-5.7.8
```
**Fix:**
1. Enable 2-Step Verification in Google Account
2. Create App Password (not regular password)
3. Remove spaces from 16-char password

---

## ✅ Success Indicators

You'll know it's working when:

✅ Backend logs show: `MongoDB connected`  
✅ Health check returns `200 OK`  
✅ Registration creates user in database  
✅ Login returns JWT tokens  
✅ Forgot password sends email (check inbox AND spam!)  
✅ OTP verification works  
✅ Password reset succeeds  

---

## 🎉 All Done?

Once everything works:

### Next Steps for Production:

1. **Deploy Backend** (see `backend/SETUP_GUIDE.md`)
   - Railway (recommended) or Render
   - Update Flutter `baseUrl` to production URL

2. **Enable Google Sign-In** (optional)
   - Complete Firebase setup
   - Add `GOOGLE_CLIENT_ID` to backend
   - Test in Flutter app

3. **Add Plant Features**
   - Your backend already has `/v1/plants` endpoints
   - Implement plant listing, search, identification

4. **Security Hardening**
   - Use MongoDB Atlas (cloud) instead of local
   - Generate strong JWT secret
   - Enable HTTPS in production
   - Configure CORS for production domains

---

## 💡 Pro Tips

### Development Workflow
```bash
# Terminal 1: Backend
cd backend
npm run dev  # Auto-restarts on changes

# Terminal 2: MongoDB (if needed)
mongosh  # Monitor database

# Terminal 3: Flutter
flutter run
```

### View Database
```bash
mongosh
use plantlers
db.users.find().pretty()          # View all users
db.refreshtokens.find().pretty()  # View active sessions
```

### Clear OTP for Testing
```bash
mongosh
use plantlers
db.users.updateMany({}, {$unset: {resetOtp: "", resetOtpExpiry: ""}})
```

---

## 📞 Need Help?

1. **Read the docs** (most issues are covered!)
   - `backend/ENV_SETUP_QUICKSTART.md`
   - `backend/SETUP_GUIDE.md`
   - `INTEGRATION_SUMMARY.md`

2. **Check logs**
   - Backend: Terminal running `npm run dev`
   - Flutter: Debug console in VS Code
   - MongoDB: `mongosh` → `use plantlers` → `db.users.find()`

3. **Common fixes**
   - Restart backend: `Ctrl+C` → `npm run dev`
   - Clear Flutter cache: `flutter clean && flutter pub get`
   - Check `.env` file has correct values

---

## 🚀 Let's Go!

Start with **Step 1** above and work through each step in order.

**Estimated time:** 15 minutes total

You've got this! 💪
