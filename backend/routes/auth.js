const express = require('express');
const router = express.Router();
const { signup, login, logout, forgotPassword, verifyOtp, resetPassword, updateProfile, toggleFavorite, getFavorites, toggle2FA, send2faOtp, verify2faOtp } = require('../controllers/authController');
const { auth } = require('../middleware/auth');
const User = require('../models/User');

router.post('/signup', signup);
router.post('/login', login);
router.post('/logout', logout);
router.post('/forgot-password', forgotPassword);
router.post('/verify-otp', verifyOtp);
router.post('/reset-password', resetPassword);

router.get('/me', auth, async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select('-password_hash');
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.put('/profile', auth, updateProfile);
router.put('/toggle-2fa', auth, toggle2FA);
router.post('/send-2fa-otp', send2faOtp);
router.post('/verify-2fa-otp', verify2faOtp);
router.post('/favorites/:serviceId', auth, toggleFavorite);
router.get('/favorites', auth, getFavorites);

module.exports = router;
