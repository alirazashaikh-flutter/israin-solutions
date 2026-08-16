const ChatbotLog = require('../models/ChatbotLog');
const Message = require('../models/Message');
const Inquiry = require('../models/Inquiry');
const { getSocketIO } = require('../socket');

const RULES = [
  {
    keywords: ['pricing', 'price', 'cost', 'rate', 'kitne', 'paise', 'charge', 'budget'],
    response: "Our services start from:\n\nAI Development:\n- AI Chatbot: $2,500\n- Custom AI Agent: $5,000\n- Document Processing: $3,500\n\nDigital Marketing:\n- SEO: $1,500\n- Social Media: $2,000\n- PPC Ads: $1,800\n\nWould you like details on a specific service?"
  },
  {
    keywords: ['timeline', 'time', 'duration', 'days', 'weeks', 'kitna time', 'kab tak', 'deadline', 'long'],
    response: "Timelines vary by project:\n\n- AI Chatbot: 2-3 weeks\n- Custom AI Agent: 3-6 weeks\n- SEO: 4-8 weeks\n- Social Media: Ongoing monthly\n- PPC: 1-2 weeks setup\n\nUrgent projects can be discussed for faster delivery."
  },
  {
    keywords: ['service', 'services', 'kya karte', 'kya hai', 'offer', 'provide', 'kya hota', 'list'],
    response: "We offer two main services:\n\n1. AI Development\n- Chatbots & Virtual Assistants\n- Custom AI Agents\n- Document Processing\n\n2. Digital Marketing\n- SEO Optimization\n- Social Media Marketing\n- PPC & Paid Advertising\n\nWhich one interests you?"
  },
  {
    keywords: ['chatbot', 'bot', 'ai assistant', 'virtual assistant', 'conversational'],
    response: "Our AI Chatbot Development ($2,500) includes:\n\n- 24/7 automated customer support\n- Custom training on your business data\n- Multi-language support\n- Lead qualification\n- Integration with WhatsApp, website, social media\n- Delivered in 2-3 weeks\n\nWant to get started?"
  },
  {
    keywords: ['seo', 'search engine', 'ranking', 'google rank', 'organic'],
    response: "Our SEO service ($1,500) includes:\n\n- Technical SEO audit\n- Keyword research & strategy\n- Content optimization\n- Link building\n- Monthly analytics reports\n- Results visible in 4-8 weeks\n\nShall we schedule a free consultation?"
  },
  {
    keywords: ['marketing', 'social media', 'instagram', 'facebook', 'linkedin', 'ads'],
    response: "Our Digital Marketing services:\n\n- Social Media Marketing: $2,000/month\n  Content creation, scheduling, community management\n\n- PPC & Paid Ads: $1,800\n  Google Ads, Meta, LinkedIn campaigns\n\nBoth include analytics & reporting."
  },
  {
    keywords: ['contact', 'email', 'phone', 'call', 'reach', 'address', 'location'],
    response: "You can reach us at:\n\nEmail: arappsstudio10@gmail.com\nPhone: +92 300 1234567\nLocation: Lahore, Pakistan\n\nOr you can submit an inquiry through the app and we'll respond within 24 hours!"
  },
  {
    keywords: ['hello', 'hi', 'hey', 'salam', 'assalam', 'howdy'],
    response: "ESCALATE",
    escalateOnly: true
  },
  {
    keywords: ['team', 'about', 'company', 'who', 'kya ho', 'kaun ho'],
    response: "Israin Solutions is a digital agency specializing in:\n\n- AI-Powered Solutions\n- Digital Marketing\n\nWe help businesses transform through technology. Based in Lahore, Pakistan.\n\nWant to know more about our services?"
  },
  {
    keywords: ['refund', 'cancel', 'money back'],
    response: "Our refund policy depends on the project stage. For specific concerns, I'd recommend connecting with our team directly.\n\nShall I escalate this to our support team?"
  },
  {
    keywords: ['thank', 'thanks', 'shukriya', 'ji'],
    response: "You're welcome! Is there anything else I can help you with regarding our AI or Digital Marketing services?"
  },
  {
    keywords: ['help', 'kaise', 'madad', 'support'],
    response: "I can help you with:\n\n- Service information & pricing\n- Project timelines\n- Getting started with a project\n- Contact details\n\nJust ask me anything!"
  },
];

const FALLBACK = "Thanks for your message! For detailed assistance, I'd recommend connecting with our team directly.\n\nYou can submit an inquiry or contact us at arappsstudio10@gmail.com. Is there anything specific about our services I can help with?";

function getBotResponse(message) {
  const lower = message.toLowerCase();

  for (const rule of RULES) {
    if (rule.keywords.some(kw => lower.includes(kw))) {
      if (rule.escalateOnly) {
        return { response: null, escalated: true };
      }
      return { response: rule.response, escalated: false };
    }
  }

  if (lower.includes('custom') || lower.includes('complex') || lower.includes('meeting') || lower.includes('urgent') || lower.includes('complaint')) {
    return { response: FALLBACK, escalated: true };
  }

  return { response: FALLBACK, escalated: false };
}

exports.handleMessage = async (req, res) => {
  try {
    const { inquiry_id, message } = req.body;

    const inquiry = await Inquiry.findById(inquiry_id);
    if (!inquiry) {
      return res.status(404).json({ message: 'Inquiry not found' });
    }

    let botResponse, escalated;

    const SYSTEM_PROMPT = `You are an AI assistant for Israin Solutions, a digital agency. We offer AI Development (chatbots, AI agents, document processing) and Digital Marketing (SEO, social media, PPC). Be professional, helpful, and concise. If the query is complex or needs human help, start your response with "ESCALATE".`;

    if (process.env.GROQ_API_KEY && process.env.GROQ_API_KEY !== 'your_groq_api_key_here') {
      try {
        const OpenAI = require('openai');
        const groq = new OpenAI({
          apiKey: process.env.GROQ_API_KEY,
          baseURL: 'https://api.groq.com/openai/v1',
        });

        const completion = await groq.chat.completions.create({
          model: 'llama-3.3-70b-versatile',
          messages: [
            { role: 'system', content: SYSTEM_PROMPT },
            { role: 'user', content: message }
          ],
          max_tokens: 500,
          temperature: 0.7
        });

        let text = completion.choices[0].message.content;
        escalated = text.startsWith('ESCALATE');
        if (escalated) text = text.replace('ESCALATE', '').trim();
        botResponse = text;
      } catch (aiError) {
        console.log('Groq failed, falling back:', aiError.message);
        botResponse = null;
      }
    }

    if (!botResponse && process.env.GEMINI_API_KEY && process.env.GEMINI_API_KEY !== 'your_gemini_api_key_here') {
      try {
        const { GoogleGenerativeAI } = require('@google/generative-ai');
        const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
        const model = genAI.getGenerativeModel({ model: 'gemini-2.0-flash' });

        const result = await model.generateContent([
          SYSTEM_PROMPT,
          message
        ]);

        let text = result.response.text();
        escalated = text.startsWith('ESCALATE');
        if (escalated) text = text.replace('ESCALATE', '').trim();
        botResponse = text;
      } catch (aiError) {
        console.log('Gemini failed, falling back:', aiError.message);
        botResponse = null;
      }
    }

    if (!botResponse && process.env.OPENAI_API_KEY && process.env.OPENAI_API_KEY !== 'your_openai_api_key_here') {
      try {
        const OpenAI = require('openai');
        const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

        const completion = await openai.chat.completions.create({
          model: 'gpt-3.5-turbo',
          messages: [
            { role: 'system', content: SYSTEM_PROMPT },
            { role: 'user', content: message }
          ],
          max_tokens: 500,
          temperature: 0.7
        });

        let text = completion.choices[0].message.content;
        escalated = text.startsWith('ESCALATE');
        if (escalated) text = text.replace('ESCALATE', '').trim();
        botResponse = text;
      } catch (aiError) {
        console.log('OpenAI failed, falling back:', aiError.message);
        botResponse = null;
      }
    }

    if (!botResponse) {
      const result = getBotResponse(message);
      botResponse = result.response;
      escalated = result.escalated;
    }

    if (escalated) {
      await Inquiry.findByIdAndUpdate(inquiry_id, { status: 'new' });
      const admins = await require('../models/User').find({ role: 'admin' }).select('_id');
      for (const admin of admins) {
        await Notification.create({
          user_id: admin._id,
          title: 'Customer wants to talk',
          body: message.length > 80 ? message.substring(0, 80) + '...' : message,
          type: 'message',
        });
      }
    }

    const customerMsg = await Message.create({ inquiry_id, sender_id: req.user._id, text: message });

    const io = getSocketIO();
    if (io) {
      const populated = await Message.findById(customerMsg._id).populate('sender_id', 'name role');
      if (populated) {
        io.to(inquiry_id).emit('receive_message', populated);
      }
    }

    if (botResponse) {
      await ChatbotLog.create({ inquiry_id, customer_query: message, bot_response: botResponse, escalated });
      res.json({ response: botResponse, escalated });
    } else {
      await ChatbotLog.create({ inquiry_id, customer_query: message, bot_response: 'Escalated to team', escalated: true });
      res.json({ response: null, escalated: true });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
