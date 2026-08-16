const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const dotenv = require('dotenv');

dotenv.config();

const User = require('./models/User');
const Service = require('./models/Service');
const ShopItem = require('./models/ShopItem');

const seedAll = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('MongoDB connected');

    const existingAdmin = await User.findOne({ email: 'arappsstudio10@gmail.com' });
    if (existingAdmin) {
      existingAdmin.role = 'admin';
      existingAdmin.password_hash = 'Admin@123';
      await existingAdmin.save();
      console.log('Admin user updated');
    } else {
      await User.create({ name: 'Admin', email: 'arappsstudio10@gmail.com', password_hash: 'Admin@123', role: 'admin' });
      console.log('Admin user created');
    }

    const serviceCount = await Service.countDocuments();
    if (serviceCount === 0) {
      await Service.insertMany([
        {
          name: 'AI Chatbot Development',
          category: 'ai_dev',
          description: 'Intelligent conversational AI that handles customer support, lead qualification, and FAQ automation 24/7. Built with GPT and custom training on your business data.',
          price: 2500,
          timeline: '2-3 weeks',
          useCases: ['Customer support automation', 'Lead qualification', 'FAQ handling', 'Multi-language support'],
        },
        {
          name: 'Custom AI Agent Development',
          category: 'ai_dev',
          description: 'Autonomous AI agents that streamline business operations — from data analysis to workflow automation. Reduce manual overhead and accelerate decision-making.',
          price: 5000,
          timeline: '3-6 weeks',
          useCases: ['Workflow automation', 'Data analysis agents', 'Process optimization', 'Predictive analytics'],
        },
        {
          name: 'AI-Powered Document Processing',
          category: 'ai_dev',
          description: 'Extract, classify, and process documents automatically using AI. Handle invoices, contracts, and reports with 99% accuracy.',
          price: 3500,
          timeline: '2-4 weeks',
          useCases: ['Invoice processing', 'Contract analysis', 'Report generation', 'Data extraction'],
        },
        {
          name: 'SEO Optimization',
          category: 'digital_marketing',
          description: 'Data-driven SEO strategies that improve your search rankings, drive organic traffic, and increase conversions. Technical SEO, content strategy, and link building.',
          price: 1500,
          timeline: '4-8 weeks',
          useCases: ['Technical SEO audit', 'Keyword research', 'Content optimization', 'Link building'],
        },
        {
          name: 'Social Media Marketing',
          category: 'digital_marketing',
          description: 'End-to-end social media management — content creation, scheduling, community management, and analytics across all major platforms.',
          price: 2000,
          timeline: 'Ongoing monthly',
          useCases: ['Content creation', 'Community management', 'Paid social campaigns', 'Analytics & reporting'],
        },
        {
          name: 'PPC & Paid Advertising',
          category: 'digital_marketing',
          description: 'Maximize ROI with targeted paid campaigns on Google Ads, Meta, LinkedIn, and more. Data-driven bidding, A/B testing, and conversion optimization.',
          price: 1800,
          timeline: '1-2 weeks setup',
          useCases: ['Google Ads management', 'Meta advertising', 'Retargeting campaigns', 'Landing page optimization'],
        },
      ]);
      console.log('6 services seeded');
    } else {
      console.log(`${serviceCount} services already exist`);
    }

    const shopCount = await ShopItem.countDocuments();
    if (shopCount === 0) {
      await ShopItem.insertMany([
        { name: 'Logo Design', category: 'graphics', description: 'Professional custom logo design for your brand. Includes 3 concepts and 2 revisions.', price: 30, deliveryTime: '3-5 days', features: ['3 concepts', '2 revisions', 'Source files', 'PNG + SVG'] },
        { name: 'Business Card Design', category: 'graphics', description: 'Sleek, modern business card design that leaves a lasting impression.', price: 15, deliveryTime: '1-2 days', features: ['Front + Back', 'Print-ready', 'Source file'] },
        { name: 'Social Media Kit', category: 'graphics', description: 'Complete social media branding kit — posts, stories, and cover images for all platforms.', price: 50, deliveryTime: '3-5 days', features: ['20 templates', 'All platforms', ' editable files'] },
        { name: 'Banner & Poster Design', category: 'graphics', description: 'Eye-catching banners and posters for events, ads, or social media.', price: 25, deliveryTime: '1-3 days', features: ['Custom design', 'Print & digital', 'Source file'] },
        { name: 'Landing Page Design', category: 'web', description: 'High-converting responsive landing page design and development.', price: 100, deliveryTime: '5-7 days', features: ['Responsive', 'SEO optimized', 'Contact form', 'Analytics setup'] },
        { name: 'WordPress Website', category: 'web', description: 'Professional WordPress website with custom theme and CMS setup.', price: 200, deliveryTime: '7-14 days', features: ['Custom theme', 'CMS setup', 'SEO basics', '1 month support'] },
        { name: 'E-Commerce Store', category: 'web', description: 'Full-featured online store with product management and payment integration.', price: 350, deliveryTime: '14-21 days', features: ['Product catalog', 'Payment gateway', 'Order management', 'Admin panel'] },
        { name: 'Monthly SEO Package', category: 'marketing', description: 'Ongoing SEO optimization to boost your search rankings monthly.', price: 80, deliveryTime: 'Monthly', features: ['Keyword research', 'On-page SEO', 'Monthly report', 'Link building'] },
        { name: 'Social Media Management', category: 'marketing', description: '30-day social media content calendar with scheduling and engagement.', price: 60, deliveryTime: 'Monthly', features: ['15 posts', 'Content calendar', 'Hashtag research', 'Analytics'] },
        { name: 'Google Ads Setup', category: 'marketing', description: 'Complete Google Ads campaign setup with keyword research and optimization.', price: 75, deliveryTime: '3-5 days', features: ['Campaign setup', 'Keyword research', 'Ad copy', 'A/B testing'] },
        { name: 'AI Chatbot Integration', category: 'ai', description: 'Ready-to-use AI chatbot for your website or app. Trained on your FAQ data.', price: 120, deliveryTime: '5-7 days', features: ['Custom training', 'Multi-platform', 'Analytics', '1 month support'] },
        { name: '2D Animation Video', category: 'animation', description: '30-second 2D animated explainer video for your product or service.', price: 150, deliveryTime: '7-10 days', features: ['Script writing', 'Voiceover', 'Background music', 'HD output'] },
      ]);
      console.log('12 shop items seeded');
    } else {
      console.log(`${shopCount} shop items already exist`);
    }

    process.exit(0);
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
};

seedAll();
