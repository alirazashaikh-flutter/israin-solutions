const OpenAI = require('openai');
const ChatbotLog = require('../models/ChatbotLog');
const Message = require('../models/Message');
const Inquiry = require('../models/Inquiry');

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

const SYSTEM_PROMPT = `You are an AI assistant for Israin Solutions, a digital agency offering two main services:

1. AI Development Services:
   - Custom AI Solutions: $5,000 - $25,000
   - Machine Learning Models: $3,000 - $15,000
   - Natural Language Processing: $4,000 - $20,000
   - Computer Vision: $5,000 - $30,000
   - AI Chatbots & Virtual Assistants: $2,000 - $10,000
   - Timeline: 2-8 weeks depending on complexity

2. Digital Marketing Services:
   - Social Media Management: $500 - $2,000/month
   - SEO Optimization: $1,000 - $5,000
   - PPC Campaign Management: $800 - $3,000/month
   - Content Marketing: $600 - $2,500/month
   - Email Marketing: $400 - $1,500/month
   - Timeline: Ongoing monthly services

FAQs:
- Do you offer free consultations? Yes, we offer a free 30-minute consultation.
- What payment methods do you accept? We accept bank transfer, PayPal, and Stripe.
- Do you provide project updates? Yes, weekly progress reports are included.
- Can I get a refund? Refund policy varies by project stage.

If the query is complex, requires custom pricing, or you're not confident in your response, respond with "ESCALATE" at the beginning of your message. Also escalate if the customer uses keywords like: custom, complex, team, call, meeting, urgent, complaint, refund.

Always be professional, helpful, and concise.`;

exports.handleMessage = async (req, res) => {
  try {
    const { inquiry_id, message } = req.body;

    const inquiry = await Inquiry.findById(inquiry_id);
    if (!inquiry) {
      return res.status(404).json({ message: 'Inquiry not found' });
    }

    const completion = await openai.chat.completions.create({
      model: 'gpt-3.5-turbo',
      messages: [
        { role: 'system', content: SYSTEM_PROMPT },
        { role: 'user', content: message }
      ],
      max_tokens: 500,
      temperature: 0.7
    });

    let botResponse = completion.choices[0].message.content;
    let escalated = false;

    if (botResponse.startsWith('ESCALATE')) {
      escalated = true;
      botResponse = botResponse.replace('ESCALATE', '').trim();
      await Inquiry.findByIdAndUpdate(inquiry_id, { status: 'new' });
    }

    await Message.create({
      inquiry_id,
      sender_id: req.user._id,
      text: message
    });

    const botMessage = await Message.create({
      inquiry_id,
      sender_id: req.user._id,
      text: botResponse
    });

    await ChatbotLog.create({
      inquiry_id,
      customer_query: message,
      bot_response: botResponse,
      escalated
    });

    res.json({
      response: botResponse,
      escalated,
      messageId: botMessage._id
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
