const Rating = require('../models/Rating');

exports.submitRating = async (req, res) => {
  try {
    const { inquiry_id, rating, review } = req.body;
    const existing = await Rating.findOne({ inquiry_id, customer_id: req.user._id });
    if (existing) {
      existing.rating = rating;
      existing.review = review || '';
      await existing.save();
      return res.json(existing);
    }
    const newRating = await Rating.create({
      inquiry_id,
      customer_id: req.user._id,
      rating,
      review,
    });
    res.status(201).json(newRating);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getRatings = async (req, res) => {
  try {
    const ratings = await Rating.find()
      .populate('customer_id', 'name')
      .populate('inquiry_id', 'service_type')
      .sort({ createdAt: -1 });
    res.json(ratings);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getAverageRating = async (req, res) => {
  try {
    const result = await Rating.aggregate([
      { $group: { _id: null, avg: { $avg: '$rating' }, count: { $sum: 1 } } }
    ]);
    res.json(result[0] || { avg: 0, count: 0 });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
