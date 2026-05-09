const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.controller');
const { protect } = require('../middleware/auth.middleware');
const { validate, rules } = require('../middleware/validate');

// All user routes require authentication
router.use(protect);

router.get('/profile', userController.getProfile);
router.patch('/profile/update', validate(rules.updateProfile), userController.updateProfile);
router.delete('/profile', userController.deleteAccount);

module.exports = router;
