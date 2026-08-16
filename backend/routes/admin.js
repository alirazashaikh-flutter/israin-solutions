const express = require('express');
const router = express.Router();
const { getStats } = require('../controllers/adminController');
const { auth, adminOnly } = require('../middleware/auth');
const Notification = require('../models/Notification');
const User = require('../models/User');

router.get('/stats', auth, adminOnly, getStats);

router.post('/broadcast', auth, adminOnly, async (req, res) => {
  try {
    const { title, message } = req.body;
    if (!title || !message) {
      return res.status(400).json({ message: 'Title and message are required' });
    }

    const customers = await User.find({ role: 'customer' }).select('_id');

    const notifications = customers.map(customer => ({
      user_id: customer._id,
      title,
      body: message,
      type: 'push',
    }));

    if (notifications.length > 0) {
      await Notification.insertMany(notifications);
    }

    res.json({
      message: `Broadcast sent to ${notifications.length} customers`,
      recipientCount: notifications.length,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
