const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  host: process.env.EMAIL_HOST,
  port: parseInt(process.env.EMAIL_PORT, 10),
  secure: false, // true for 465, false for 587
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

/**
 * Sends a 6-digit OTP email for password reset.
 */
const sendOtpEmail = async (toEmail, otp) => {
  // Check if email is configured
  if (!process.env.EMAIL_HOST || !process.env.EMAIL_USER || !process.env.EMAIL_PASS) {
    console.log('\n=== EMAIL NOT CONFIGURED - DEVELOPMENT MODE ===');
    console.log(`📧 OTP for ${toEmail}: ${otp}`);
    console.log('==============================================\n');
    return; // Skip actual email sending
  }

  await transporter.sendMail({
    from: process.env.EMAIL_FROM,
    to: toEmail,
    subject: 'Plantlers — Password Reset OTP',
    html: `
      <div style="font-family: sans-serif; max-width: 480px; margin: 0 auto;">
        <h2 style="color: #00450D;">Reset Your Password</h2>
        <p>Use the OTP below to reset your Plantlers password. It expires in <strong>10 minutes</strong>.</p>
        <div style="
          background: #f0f7f0;
          border: 1px solid #00450D;
          border-radius: 8px;
          padding: 24px;
          text-align: center;
          font-size: 36px;
          font-weight: bold;
          letter-spacing: 8px;
          color: #00450D;
        ">${otp}</div>
        <p style="color: #757575; font-size: 13px; margin-top: 16px;">
          If you didn't request this, ignore this email.
        </p>
      </div>
    `,
  });
};

module.exports = { sendOtpEmail };
