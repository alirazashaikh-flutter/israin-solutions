const express = require('express');
const router = express.Router();
const { submitRating, getRatings, getAverageRating } = require('../controllers/ratingController');
const { auth } = require('../middleware/auth');

router.post('/', auth, submitRating);
router.get('/', auth, getRatings);
router.get('/average', auth, getAverageRating);

module.exports = router;
