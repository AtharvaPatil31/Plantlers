const express = require('express');
const router = express.Router();
const plantController = require('../controllers/plant.controller');
const { protect } = require('../middleware/auth.middleware');

// Public
router.get('/', plantController.getPlants);
router.get('/:id', plantController.getPlantById);

// Protected (admin — add role check later)
router.post('/', protect, plantController.createPlant);

module.exports = router;
