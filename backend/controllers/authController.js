const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Otp = require('../models/Otp');
const crypto = require('crypto');
const { sendOtpEmail } = require('../services/emailService');

const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, { expiresIn: '30d' });
};

exports.signup = async (req, res) => {
  try {
    const { name, email, phone, password, role } = req.body;

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: 'User already exists' });
    }

    const user = await User.create({
      name,
      email,
      phone,
      password_hash: password,
      role: role || 'customer'
    });

    const token = generateToken(user._id);

    res.status(201).json({
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
        twoFactorEnabled: false
      }
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const token = generateToken(user._id);

    res.json({
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
        twoFactorEnabled: user.twoFactorEnabled || false
      }
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.logout = async (req, res) => {
  res.json({ message: 'Logged out successfully' });
};

exports.forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: 'No account found with this email' });
    }

    const otp = crypto.randomInt(100000, 999999).toString();

    await Otp.deleteMany({ email, purpose: 'forgot_password' });

    await Otp.create({
      email,
      otp,
      purpose: 'forgot_password',
      expiresAt: new Date(Date.now() + 10 * 60 * 1000)
    });

    await sendOtpEmail(email, otp);

    res.json({ message: 'OTP sent to your email' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.verifyOtp = async (req, res) => {
  try {
    const { email, otp } = req.body;

    const record = await Otp.findOne({
      email,
      purpose: 'forgot_password',
      used: false,
      expiresAt: { $gt: new Date() }
    }).sort({ createdAt: -1 });

    if (!record) {
      return res.status(400).json({ message: 'Invalid or expired OTP' });
    }

    if (record.otp !== otp) {
      return res.status(400).json({ message: 'Incorrect OTP' });
    }

    record.used = true;
    await record.save();

    const resetToken = jwt.sign({ email, purpose: 'reset_password' }, process.env.JWT_SECRET, { expiresIn: '15m' });

    res.json({ message: 'OTP verified', resetToken });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.resetPassword = async (req, res) => {
  try {
    const { resetToken, newPassword } = req.body;

    let decoded;
    try {
      decoded = jwt.verify(resetToken, process.env.JWT_SECRET);
    } catch {
      return res.status(400).json({ message: 'Reset token expired or invalid' });
    }

    if (decoded.purpose !== 'reset_password') {
      return res.status(400).json({ message: 'Invalid reset token' });
    }

    const user = await User.findOne({ email: decoded.email });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    user.password_hash = newPassword;
    await user.save();

    res.json({ message: 'Password reset successful' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.updateProfile = async (req, res) => {
  try {
    const { name, phone, avatar, twoFactorEnabled } = req.body;
    const update = {};
    if (name) update.name = name;
    if (phone !== undefined) update.phone = phone;
    if (avatar !== undefined) update.avatar = avatar;
    if (twoFactorEnabled !== undefined) update.twoFactorEnabled = twoFactorEnabled;
    const user = await User.findByIdAndUpdate(req.user._id, update, { new: true }).select('-password_hash');
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.toggle2FA = async (req, res) => {
  try {
    const { enabled } = req.body;
    const user = await User.findByIdAndUpdate(
      req.user._id,
      { twoFactorEnabled: enabled },
      { new: true }
    ).select('-password_hash');
    res.json({ twoFactorEnabled: user.twoFactorEnabled });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.send2faOtp = async (req, res) => {
  try {
    const { email } = req.body;
    const user = await User.findOne({ email });
    if (!user || !user.twoFactorEnabled) {
      return res.status(400).json({ message: '2FA not enabled for this account' });
    }

    const otp = crypto.randomInt(100000, 999999).toString();

    await Otp.deleteMany({ email, purpose: 'two_factor' });

    await Otp.create({
      email,
      otp,
      purpose: 'two_factor',
      expiresAt: new Date(Date.now() + 10 * 60 * 1000)
    });

    await sendOtpEmail(email, otp);

    res.json({ message: 'OTP sent to your email' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.verify2faOtp = async (req, res) => {
  try {
    const { email, otp } = req.body;

    const record = await Otp.findOne({
      email,
      purpose: 'two_factor',
      used: false,
      expiresAt: { $gt: new Date() }
    }).sort({ createdAt: -1 });

    if (!record) {
      return res.status(400).json({ message: 'Invalid or expired OTP' });
    }

    if (record.otp !== otp) {
      return res.status(400).json({ message: 'Incorrect OTP' });
    }

    record.used = true;
    await record.save();

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const token = generateToken(user._id);

    res.json({
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
        twoFactorEnabled: user.twoFactorEnabled
      }
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.toggleFavorite = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    const serviceId = req.params.serviceId;
    const index = user.favorites.indexOf(serviceId);
    if (index > -1) {
      user.favorites.splice(index, 1);
    } else {
      user.favorites.push(serviceId);
    }
    await user.save();
    res.json({ favorites: user.favorites });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getFavorites = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    res.json({ favorites: user.favorites });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
