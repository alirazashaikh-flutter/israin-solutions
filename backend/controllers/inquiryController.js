const Inquiry = require('../models/Inquiry');
const Service = require('../models/Service');

exports.createInquiry = async (req, res) => {
  try {
    const { name, email, phone, service_type, message, service_id, budget, priority } = req.body;
    const inquiry = await Inquiry.create({
      customer_id: req.user._id,
      name,
      email,
      phone,
      service_type,
      message,
      service_id,
      budget: budget || '',
      priority: priority || 'standard',
    });

    try {
      const { sendEmail } = require('../services/emailService');
      const serviceLabel = service_type === 'ai_dev' ? 'AI Development' : 'Digital Marketing';
      const budgetLabels = {
        '\$100-\$500': '\$100 - \$500',
        '\$500-\$1000': '\$500 - \$1,000',
        '\$1000+': '\$1,000+',
      };
      const priorityLabel = priority === 'urgent' ? 'Urgent / Fast Delivery' : 'Standard Time';
      const budgetLabel = budgetLabels[budget] || budget || 'Not specified';

      const html = `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #19ADE4;">New Inquiry Received</h2>
          <table style="width: 100%; border-collapse: collapse;">
            <tr><td style="padding: 8px 0; font-weight: bold; color: #555;">Name:</td><td style="padding: 8px 0;">${name}</td></tr>
            <tr><td style="padding: 8px 0; font-weight: bold; color: #555;">Email:</td><td style="padding: 8px 0;">${email}</td></tr>
            <tr><td style="padding: 8px 0; font-weight: bold; color: #555;">Phone:</td><td style="padding: 8px 0;">${phone || 'N/A'}</td></tr>
            <tr><td style="padding: 8px 0; font-weight: bold; color: #555;">Service:</td><td style="padding: 8px 0;">${serviceLabel}</td></tr>
            <tr><td style="padding: 8px 0; font-weight: bold; color: #555;">Budget:</td><td style="padding: 8px 0;">${budgetLabel}</td></tr>
            <tr><td style="padding: 8px 0; font-weight: bold; color: #555;">Priority:</td><td style="padding: 8px 0;">${priorityLabel}</td></tr>
            <tr><td style="padding: 8px 0; font-weight: bold; color: #555;">Message:</td><td style="padding: 8px 0;">${message}</td></tr>
          </table>
        </div>
      `;

      await sendEmail({
        to: 'arappsstudio10@gmail.com',
        subject: `New Inquiry - ${serviceLabel} (${priorityLabel})`,
        html,
      });
    } catch (emailError) {
      console.error('Failed to send inquiry email:', emailError.message);
    }

    res.status(201).json(inquiry);

    if (service_id) {
      try {
        await Service.findByIdAndUpdate(service_id, { $inc: { requestCount: 1 } });
      } catch (e) {}
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getInquiries = async (req, res) => {
  try {
    let filter = {};
    if (req.user.role === 'customer') {
      filter = { customer_id: req.user._id };
    }
    if (req.query.status) {
      filter.status = req.query.status;
    }
    const inquiries = await Inquiry.find(filter)
      .populate('customer_id', 'name email')
      .populate('service_id', 'name category')
      .sort({ createdAt: -1 });
    res.json(inquiries);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getInquiryById = async (req, res) => {
  try {
    const inquiry = await Inquiry.findById(req.params.id)
      .populate('customer_id', 'name email')
      .populate('service_id', 'name category');
    if (!inquiry) {
      return res.status(404).json({ message: 'Inquiry not found' });
    }
    if (req.user.role === 'customer' && inquiry.customer_id._id.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Not authorized' });
    }
    res.json(inquiry);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getOrCreateChatInquiry = async (req, res) => {
  try {
    let inquiry = await Inquiry.findOne({
      customer_id: req.user._id,
      service_type: 'general_chat',
    }).sort({ createdAt: -1 });

    if (!inquiry) {
      inquiry = await Inquiry.create({
        customer_id: req.user._id,
        name: req.user.name,
        email: req.user.email,
        service_type: 'general_chat',
        message: 'General chat inquiry',
      });
    }

    res.json(inquiry);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.updateInquiry = async (req, res) => {
  try {
    const inquiry = await Inquiry.findByIdAndUpdate(
      req.params.id,
      { status: req.body.status },
      { new: true, runValidators: true }
    );
    if (!inquiry) {
      return res.status(404).json({ message: 'Inquiry not found' });
    }
    res.json(inquiry);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.cancelInquiry = async (req, res) => {
  try {
    const inquiry = await Inquiry.findById(req.params.id);
    if (!inquiry) return res.status(404).json({ message: 'Inquiry not found' });
    if (req.user.role === 'customer' && inquiry.customer_id.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Not authorized' });
    }
    inquiry.status = 'cancelled';
    await inquiry.save();
    res.json(inquiry);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.resolveInquiry = async (req, res) => {
  try {
    const inquiry = await Inquiry.findByIdAndUpdate(
      req.params.id,
      { status: 'resolved' },
      { new: true }
    );
    if (!inquiry) return res.status(404).json({ message: 'Inquiry not found' });
    res.json(inquiry);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getNotes = async (req, res) => {
  try {
    const inquiry = await Inquiry.findById(req.params.id)
      .populate('admin_notes.admin_id', 'name');
    if (!inquiry) return res.status(404).json({ message: 'Inquiry not found' });

    const notes = inquiry.admin_notes.map((n) => ({
      _id: n._id,
      text: n.text,
      author_name: n.admin_id && n.admin_id.name ? n.admin_id.name : 'Admin',
      createdAt: n.createdAt,
    }));
    res.json(notes);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.addNote = async (req, res) => {
  try {
    const inquiry = await Inquiry.findById(req.params.id);
    if (!inquiry) return res.status(404).json({ message: 'Inquiry not found' });
    inquiry.admin_notes.push({
      text: req.body.text,
      admin_id: req.user._id,
    });
    await inquiry.save();
    const note = inquiry.admin_notes[inquiry.admin_notes.length - 1];
    res.status(201).json({
      _id: note._id,
      text: note.text,
      author_name: req.user.name || 'Admin',
      createdAt: note.createdAt,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
