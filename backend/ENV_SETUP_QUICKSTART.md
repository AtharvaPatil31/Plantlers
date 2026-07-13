# .env Setup - Quick Reference

## 🚀 3-Minute Setup

### Step 1: Generate JWT Secret (30 seconds)

Open terminal in `backend/` folder:

```bash
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```

Copy the output (long random string).

---

### Step 2: Get Gmail App Password (2 minutes)

1. **Go to:** https://myaccount.google.com/security
2. **Enable** 2-Step Verification (if not already enabled)
3. **Search** for "App passwords"
4. **Create** → Select:
   - App: **Mail**
   - Device: **Other** → Type "Plantlers"
5. **Copy** the 16-character password (remove spaces!)

---

### Step 3: Update .env File

Open `backend/.env` and replace these values:

```env
# ── JWT Secret (paste from Step 1) ────────────────────────────────────────
JWT_SECRET=<paste your generated secret here>

# ── Gmail (paste from Step 2) ─────────────────────────────────────────────
EMAIL_USER=your_gmail@gmail.com
EMAIL_PASS=abcdefghijklmnop  # 16-char password (no spaces!)

# ── Google OAuth (optional for now) ───────────────────────────────────────
GOOGLE_CLIENT_ID=  # Leave empty, we'll add this later
```

---

### Step 4: Test It! (30 seconds)

```bash
npm run dev
```

**Expected output:**
```
🌿 Plantlers API running on port 5000
   Environment : development
   Health check: http://localhost:5000/health

✓ MongoDB connected
```

**Test health check:**
```bash
curl http://localhost:5000/health
```

Should return:
```json
{"status":"ok","service":"Plantlers API","environment":"development"}
```

---

## ✅ Done!

Your backend is now ready to:
- ✅ Accept registrations
- ✅ Handle logins
- ✅ Send OTP emails via Gmail
- 🔲 Google Sign-In (requires Google Client ID - see SETUP_GUIDE.md)

---

## 🔧 Troubleshooting

### MongoDB Connection Error

**Error:** `MongoNetworkError: connect ECONNREFUSED`

**Fix:** Install and start MongoDB
- Download: https://www.mongodb.com/try/download/community
- Windows: Auto-starts as service
- Mac: `brew services start mongodb-community`

### Email Not Sending

**Error:** `Invalid login: 535-5.7.8`

**Fix:** 
- Ensure 2-Step Verification is enabled
- Create NEW App Password (not your regular password)
- Remove ALL spaces from the 16-character password

### Still Having Issues?

See **complete guide:** `SETUP_GUIDE.md`
