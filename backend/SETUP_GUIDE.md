# Plantlers Backend Setup Guide

## 📋 Prerequisites

- **Node.js** 18+ installed
- **MongoDB** installed locally OR **MongoDB Atlas** account (cloud)
- **Gmail account** with 2-Step Verification enabled

---

## 🚀 Quick Start

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Configure Environment Variables

Copy the example file and update with your credentials:

```bash
copy .env.example .env
```

Then edit `.env`:

```env
# Database - Choose ONE:

# Option A: Local MongoDB (easiest for development)
MONGODB_URI=mongodb://localhost:27017/plantlers

# Option B: MongoDB Atlas (cloud)
# MONGODB_URI=mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/plantlers

# Server
PORT=5000
NODE_ENV=development

# JWT Secret (generate a new one!)
# Run: node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
JWT_SECRET=your-generated-secret-here
JWT_EXPIRES_IN=7d

# Gmail Configuration (for OTP emails)
EMAIL_FROM=Plantlers <your_gmail@gmail.com>
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your_gmail@gmail.com
EMAIL_PASS=your_16_character_app_password

# Google OAuth (get from Google Cloud Console)
GOOGLE_CLIENT_ID=your-google-client-id.apps.googleusercontent.com
```

---

## 📧 Gmail Setup for OTP Emails

Your backend uses Gmail to send OTP codes for password reset.

### Step 1: Enable 2-Step Verification

1. Go to: https://myaccount.google.com/security
2. Click **2-Step Verification**
3. Follow the prompts to enable it

### Step 2: Create App Password

1. Search for **"App passwords"** in your Google Account settings
2. Click **Create** and select:
   - **App**: Mail
   - **Device**: Other (Custom name) → "Plantlers Backend"
3. Copy the **16-character password** (e.g., `abcd efgh ijkl mnop`)
4. Paste it as `EMAIL_PASS` in your `.env` file

**Example:**
```env
EMAIL_USER=yourname@gmail.com
EMAIL_PASS=abcdefghijklmnop  # Remove spaces!
```

---

## 🔐 Google OAuth Setup (for Google Sign-In)

### Step 1: Create Firebase Project

1. Go to: https://console.firebase.google.com
2. Click **Add Project** → Enter "Plantlers"
3. Disable Google Analytics (optional)
4. Click **Create Project**

### Step 2: Enable Google Sign-In

1. In Firebase Console → **Authentication** → **Sign-in method**
2. Enable **Google** provider
3. Add support email

### Step 3: Add Android App

1. Go to **Project Settings** → **Your apps**
2. Click **Add app** → **Android**
3. Register app:
   - **Package name**: `com.example.plantlers` (must match Flutter app)
   - **App nickname**: Plantlers
4. Download `google-services.json` → place in `android/app/` folder

### Step 4: Get OAuth Client ID

1. In Firebase Console → **Project Settings** → **Service accounts**
2. Or go to: https://console.cloud.google.com/apis/credentials
3. Find **Web client (auto created by Google Service)**
4. Copy the **Client ID** (ends with `.apps.googleusercontent.com`)
5. Add to your backend `.env`:

```env
GOOGLE_CLIENT_ID=123456789-abc123.apps.googleusercontent.com
```

### Step 5: Update Flutter App

Replace `lib/firebase_options.dart` with your Firebase config:

```bash
# In Flutter project root:
flutterfire configure
```

---

## 🗄️ MongoDB Setup

### Option A: Local MongoDB (Recommended for Development)

1. **Download & Install**: https://www.mongodb.com/try/download/community
2. Start MongoDB service:
   - **Windows**: Already running as service
   - **Mac**: `brew services start mongodb-community`
   - **Linux**: `sudo systemctl start mongod`

3. Verify connection:
```bash
mongosh
# Should connect to mongodb://localhost:27017
```

### Option B: MongoDB Atlas (Cloud)

1. Go to: https://www.mongodb.com/cloud/atlas/register
2. Create **Free M0 Cluster**
3. **Database Access** → Add User (username/password)
4. **Network Access** → Add **0.0.0.0/0** (allow all IPs)
5. Click **Connect** → **Connect your application** → Copy connection string

```env
MONGODB_URI=mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/plantlers
```

---

## ▶️ Run the Backend

### Development Mode (auto-restarts on file changes)

```bash
npm run dev
```

### Production Mode

```bash
npm start
```

### Seed Database (optional - adds sample plants)

```bash
npm run seed
```

---

## 📱 Connect Flutter App to Backend

### Step 1: Find Your Local IP Address

**Windows:**
```bash
ipconfig
```
Look for **IPv4 Address** under your WiFi adapter (e.g., `192.168.1.5`)

**Mac/Linux:**
```bash
ifconfig
```

### Step 2: Update Flutter App

Edit `lib/core/constants/api_constants.dart`:

```dart
static const String baseUrl = 'http://192.168.1.5:5000/v1';
```

**Important:** Don't use `localhost` or `127.0.0.1` — Android emulator can't reach it!

### Step 3: Run Flutter App

```bash
flutter pub get
flutter run
```

---

## 🧪 Test the API

### Health Check

```bash
curl http://localhost:5000/health
```

**Response:**
```json
{
  "status": "ok",
  "service": "Plantlers API",
  "environment": "development"
}
```

### Register a New User

```bash
curl -X POST http://localhost:5000/v1/auth/register \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"Test User\",\"email\":\"test@example.com\",\"password\":\"password123\"}"
```

### Login

```bash
curl -X POST http://localhost:5000/v1/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"test@example.com\",\"password\":\"password123\"}"
```

### Forgot Password (sends OTP email)

```bash
curl -X POST http://localhost:5000/v1/auth/forgot-password \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"test@example.com\"}"
```

Check your terminal if email is not configured — OTP will be printed there.

---

## 🔧 Troubleshooting

### MongoDB Connection Errors

**Error:** `MongoNetworkError: connect ECONNREFUSED`

**Fix:**
- Ensure MongoDB is running: `mongosh` (should connect)
- Check `MONGODB_URI` in `.env`

### Email Not Sending

**Error:** `Invalid login: 535-5.7.8 Username and Password not accepted`

**Fix:**
- Ensure 2-Step Verification is enabled
- Create a new App Password (not your regular password)
- Remove spaces from the 16-character password

### Google Sign-In Fails

**Error:** `Invalid token` or `Token verification failed`

**Fix:**
- Ensure `GOOGLE_CLIENT_ID` in backend matches Firebase Web Client ID
- Check `google-services.json` is in `android/app/`
- Run `flutterfire configure` in Flutter project

### Android Can't Connect to Backend

**Error:** `DioException: Connection refused`

**Fix:**
- Use your computer's local IP (not `localhost`)
- Ensure phone and computer are on **same WiFi network**
- Check firewall isn't blocking port 5000

---

## 📁 Project Structure

```
backend/
├── src/
│   ├── config/          # Database configuration
│   ├── controllers/     # Request handlers
│   ├── middleware/      # Auth, validation
│   ├── models/          # MongoDB schemas
│   ├── routes/          # API endpoints
│   ├── utils/           # JWT, email helpers
│   └── app.js           # Express app setup
├── .env                 # Your secrets (NEVER commit!)
├── .env.example         # Template
└── package.json         # Dependencies
```

---

## 🚀 Deployment (Production)

### Railway (Recommended)

1. Create account: https://railway.app
2. **New Project** → **Deploy from GitHub**
3. Add **MongoDB** service
4. Add environment variables from `.env`
5. Deploy → Get production URL
6. Update Flutter app:
```dart
static const String baseUrl = 'https://your-app.railway.app/v1';
```

### Render

1. Create account: https://render.com
2. **New** → **Web Service**
3. Connect GitHub repo
4. Environment: `Node`
5. Build: `cd backend && npm install`
6. Start: `npm start`
7. Add environment variables

---

## 📚 API Documentation

See [API_TESTING_GUIDE.md](../API_TESTING_GUIDE.md) for complete endpoint documentation.

---

## ✅ Checklist

- [ ] Node.js 18+ installed
- [ ] MongoDB running (local or Atlas)
- [ ] `.env` file configured
- [ ] Gmail App Password created
- [ ] Firebase project created
- [ ] Google Sign-In enabled in Firebase
- [ ] `google-services.json` in Flutter app
- [ ] Backend running: `npm run dev`
- [ ] Health check works: `curl http://localhost:5000/health`
- [ ] Flutter app connected to local IP
- [ ] Test registration works

---

## 🆘 Need Help?

- **MongoDB**: https://www.mongodb.com/docs/manual/
- **Firebase**: https://firebase.google.com/docs
- **Gmail SMTP**: https://support.google.com/accounts/answer/185833
- **Railway Deploy**: https://docs.railway.app/
