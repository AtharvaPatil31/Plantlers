# Plantlers Backend

Node.js + Express + MongoDB backend for the Plantlers Flutter app.

## Stack

| Layer       | Technology                        |
|-------------|-----------------------------------|
| Runtime     | Node.js ≥ 18                      |
| Framework   | Express 4                         |
| Database    | MongoDB Atlas (Mongoose 8)        |
| Auth        | JWT (access + refresh tokens)     |
| Google Auth | google-auth-library (idToken verify) |
| Email       | Nodemailer + Gmail SMTP           |
| Security    | Helmet, CORS, express-rate-limit  |

---

## Project Structure

```
backend/
├── src/
│   ├── app.js                    # Express app entry point
│   ├── config/
│   │   └── db.js                 # MongoDB connection
│   ├── controllers/
│   │   ├── auth.controller.js    # Register, login, Google, OTP, refresh
│   │   ├── user.controller.js    # Profile get/update/delete
│   │   └── plant.controller.js   # Plant listing + CRUD
│   ├── middleware/
│   │   ├── auth.middleware.js    # JWT protect middleware
│   │   └── validate.js           # Request body validation
│   ├── models/
│   │   ├── User.js               # User schema (local + Google OAuth)
│   │   └── Plant.js              # Plant schema
│   ├── routes/
│   │   ├── auth.routes.js        # /v1/auth/*
│   │   ├── user.routes.js        # /v1/user/*
│   │   └── plant.routes.js       # /v1/plants/*
│   ├── scripts/
│   │   └── seed.js               # Seed sample plants into DB
│   └── utils/
│       ├── jwt.js                # Sign / verify JWT helpers
│       └── email.js              # Nodemailer OTP email
├── .env                          # Your secrets (never commit this)
├── .env.example                  # Template — safe to commit
├── .gitignore
└── package.json
```

---

## Setup

### 1. Install dependencies

```bash
cd backend
npm install
```

### 2. Configure environment

Copy `.env.example` to `.env` and fill in your values:

```bash
cp .env.example .env
```

**Required values:**

| Variable           | Where to get it |
|--------------------|-----------------|
| `MONGODB_URI`      | MongoDB Atlas → Connect → Drivers → Node.js |
| `JWT_ACCESS_SECRET`  | `node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"` |
| `JWT_REFRESH_SECRET` | Same command, run again |
| `GOOGLE_CLIENT_ID` | Google Cloud Console → OAuth 2.0 → Web Client ID |
| `EMAIL_USER`       | Your Gmail address |
| `EMAIL_PASS`       | Gmail → Security → 2FA → App Passwords (16-char) |

### 3. MongoDB Atlas setup

1. Go to [cloud.mongodb.com](https://cloud.mongodb.com)
2. Create a free M0 cluster
3. Create a database user (Database Access)
4. Whitelist your IP (Network Access → Add IP → Allow from anywhere: `0.0.0.0/0` for dev)
5. Connect → Drivers → Node.js → copy the connection string into `MONGODB_URI`

### 4. Seed sample plants

```bash
npm run seed
```

### 5. Start the server

```bash
# Development (auto-restart on file changes)
npm run dev

# Production
npm start
```

Server starts at `http://localhost:3000`

---

## API Reference

### Health

```
GET /health
```

---

### Auth — `/v1/auth`

| Method | Endpoint            | Auth | Body |
|--------|---------------------|------|------|
| POST   | `/register`         | —    | `{ name, email, password }` |
| POST   | `/login`            | —    | `{ email, password }` |
| POST   | `/google`           | —    | `{ id_token }` |
| POST   | `/refresh`          | —    | `{ refresh_token }` |
| POST   | `/logout`           | JWT  | `{ refresh_token }` |
| POST   | `/forgot-password`  | —    | `{ email }` |
| POST   | `/verify-otp`       | —    | `{ email, otp }` |
| POST   | `/reset-password`   | —    | `{ email, otp, new_password }` |

**Auth response shape** (register / login / google):
```json
{
  "id": "...",
  "email": "user@example.com",
  "name": "Jane",
  "avatar_url": null,
  "access_token": "<jwt>",
  "refresh_token": "<jwt>"
}
```

---

### User — `/v1/user` (all require `Authorization: Bearer <token>`)

| Method | Endpoint          | Body |
|--------|-------------------|------|
| GET    | `/profile`        | — |
| PATCH  | `/profile/update` | `{ name?, avatarUrl? }` |
| DELETE | `/profile`        | — (soft-delete) |

---

### Plants — `/v1/plants`

| Method | Endpoint   | Auth | Query params |
|--------|------------|------|--------------|
| GET    | `/`        | —    | `category`, `search`, `page`, `limit` |
| GET    | `/:id`     | —    | — |
| POST   | `/`        | JWT  | — |

---

## Flutter Integration

In `lib/core/constants/api_constants.dart`, set `baseUrl` to your machine's local IP:

```dart
// Development — find your IP with `ipconfig` on Windows
static const String baseUrl = 'http://192.168.X.X:3000/v1';

// Production
static const String baseUrl = 'https://your-api.railway.app/v1';
```

> Android emulator: use `10.0.2.2` instead of `localhost`.
> Physical device: use your machine's LAN IP (e.g. `192.168.1.5`).

---

## Deployment (Railway)

1. Push the `backend/` folder to a GitHub repo (or a monorepo)
2. Create a new project on [railway.app](https://railway.app)
3. Connect your repo → set root directory to `backend`
4. Add all `.env` variables in Railway's Variables tab
5. Railway auto-detects Node.js and runs `npm start`
6. Update `baseUrl` in Flutter to the Railway URL
