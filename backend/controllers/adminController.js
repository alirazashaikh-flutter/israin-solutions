const Inquiry = require('../models/Inquiry');
const User = require('../models/User');
const ChatbotLog = require('../models/ChatbotLog');

exports.getStats = async (req, res) => {
  try {
    const totalInquiries = await Inquiry.countDocuments({ service_type: { $ne: 'general_chat' } });
    const newInquiries = await Inquiry.countDocuments({ status: 'new', service_type: { $ne: 'general_chat' } });
    const inDiscussion = await Inquiry.countDocuments({ status: 'in_discussion', service_type: { $ne: 'general_chat' } });
    const completed = await Inquiry.countDocuments({ status: 'completed', service_type: { $ne: 'general_chat' } });

    const totalCustomers = await User.countDocuments({ role: 'customer' });

    const escalatedQueries = await ChatbotLog.countDocuments({ escalated: true });
    const totalBotLogs = await ChatbotLog.countDocuments();
    const botResolutionRate = totalBotLogs > 0
      ? ((totalBotLogs - escalatedQueries) / totalBotLogs * 100).toFixed(1)
      : 0;

    const currentMonth = new Date();
    currentMonth.setDate(1);
    currentMonth.setHours(0, 0, 0, 0);

    const monthlyInquiries = await Inquiry.countDocuments({
      createdAt: { $gte: currentMonth },
      service_type: { $ne: 'general_chat' }
    });

    const inquiriesByService = await Inquiry.aggregate([
      {
        $match: {
          service_type: { $ne: 'general_chat' }
        }
      },
      {
        $group: {
          _id: '$service_type',
          count: { $sum: 1 }
        }
      }
    ]);

    res.json({
      totalInquiries,
      newInquiries,
      inDiscussion,
      completed,
      totalCustomers,
      escalatedQueries,
      botResolutionRate: parseFloat(botResolutionRate),
      monthlyInquiries,
      inquiriesByService
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
