const Message = require('../models/Message');
const Inquiry = require('../models/Inquiry');
const Notification = require('../models/Notification');

exports.sendMessage = async (req, res) => {
  try {
    const { inquiry_id, text } = req.body;

    const inquiry = await Inquiry.findById(inquiry_id);
    if (!inquiry) {
      return res.status(404).json({ message: 'Inquiry not found' });
    }

    if (req.user.role === 'customer' && inquiry.customer_id.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    const message = await Message.create({
      inquiry_id,
      sender_id: req.user._id,
      text
    });

    if (req.user.role === 'admin' && inquiry.status === 'new') {
      await Inquiry.findByIdAndUpdate(inquiry_id, { status: 'in_discussion' });
    }

    if (req.user.role === 'admin') {
      await Notification.create({
        user_id: inquiry.customer_id,
        title: 'New Reply',
        body: text.length > 80 ? text.substring(0, 80) + '...' : text,
        type: 'message',
      });
    }

    if (req.user.role === 'customer') {
      const admins = await require('../models/User').find({ role: 'admin' }).select('_id');
      for (const admin of admins) {
        await Notification.create({
          user_id: admin._id,
          title: 'New Customer Reply',
          body: text.length > 80 ? text.substring(0, 80) + '...' : text,
          type: 'message',
        });
      }
    }

    res.status(201).json(message);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getMessages = async (req, res) => {
  try {
    const messages = await Message.find({ inquiry_id: req.params.inquiry_id })
      .populate('sender_id', 'name role')
      .sort({ createdAt: 1 });
    res.json(messages);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.searchMessages = async (req, res) => {
  try {
    const { q } = req.query;
    const filter = { text: { $regex: q, $options: 'i' } };
    if (req.user.role === 'customer') {
      const inquiries = await Inquiry.find({ customer_id: req.user._id }).select('_id');
      filter.inquiry_id = { $in: inquiries.map(i => i._id) };
    }
    const messages = await Message.find(filter)
      .populate('sender_id', 'name role')
      .populate('inquiry_id', 'service_type')
      .sort({ createdAt: -1 })
      .limit(50);
    res.json(messages);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
