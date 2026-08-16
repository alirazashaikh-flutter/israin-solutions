const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS
  }
});

const sendEmail = async ({ to, subject, html }) => {
  if (!process.env.SMTP_USER || !process.env.SMTP_PASS) {
    console.error('[EMAIL ERROR] SMTP_USER or SMTP_PASS not set in environment');
    throw new Error('Email service not configured (missing SMTP credentials)');
  }

  try {
    const info = await transporter.sendMail({
      from: process.env.SMTP_FROM || `Israin Solutions <${process.env.SMTP_USER}>`,
      to,
      subject,
      html
    });
    console.log(`[EMAIL SENT] To: ${to}, MessageId: ${info.messageId}`);
    return info;
  } catch (error) {
    console.error('[EMAIL ERROR]', error.message);
    throw error;
  }
};

const sendOtpEmail = async (email, otp) => {
  return sendEmail({
    to: email,
    subject: 'Israin Solutions - Password Reset OTP',
    html: `
      <div style="font-family: Inter, Arial, sans-serif; max-width: 480px; margin: 0 auto; padding: 32px;">
        <div style="background: #19ADE4; border-radius: 16px; padding: 32px; text-align: center;">
          <h1 style="color: white; margin: 0; font-size: 24px;">Israin Solutions</h1>
        </div>
        <div style="padding: 32px 0;">
          <h2 style="color: #1a1a2e; font-size: 20px;">Password Reset Request</h2>
          <p style="color: #666; font-size: 14px; line-height: 1.6;">
            We received a request to reset your password. Use the OTP below to proceed:
          </p>
          <div style="background: #f0f4ff; border-radius: 12px; padding: 20px; text-align: center; margin: 24px 0;">
            <span style="font-size: 32px; font-weight: 700; color: #19ADE4; letter-spacing: 8px;">${otp}</span>
          </div>
          <p style="color: #999; font-size: 12px;">
            This OTP expires in 10 minutes. If you didn't request this, ignore this email.
          </p>
        </div>
      </div>
    `
  });
};

module.exports = { sendEmail, sendOtpEmail };