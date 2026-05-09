const Plant = require('../models/plantQueries');

// ── GET /plants ───────────────────────────────────────────────────────────────
exports.getPlants = async (req, res) => {
  try {
    const { category, search, page = 1, limit = 20 } = req.query;

    const { plants, total } = await Plant.getPlants({ category, search, page, limit });

    return res.status(200).json({
      plants: plants.map(Plant.toApiObject),
      pagination: {
        total,
        page:  parseInt(page),
        limit: parseInt(limit),
        pages: Math.ceil(total / parseInt(limit)),
      },
    });
  } catch (error) {
    console.error('Get plants error:', error);
    return res.status(500).json({ message: 'Failed to fetch plants.' });
  }
};

// ── GET /plants/:id ───────────────────────────────────────────────────────────
exports.getPlantById = async (req, res) => {
  try {
    const plant = await Plant.getPlantById(req.params.id);
    if (!plant) {
      return res.status(404).json({ message: 'Plant not found.' });
    }
    return res.status(200).json(Plant.toApiObject(plant));
  } catch (error) {
    return res.status(500).json({ message: 'Failed to fetch plant.' });
  }
};

// ── POST /plants ──────────────────────────────────────────────────────────────
exports.createPlant = async (req, res) => {
  try {
    const { name, subtitle, tag, priceInr, imageUrl, categories, description, stock } = req.body;

    if (!name || !priceInr || !imageUrl) {
      return res.status(400).json({ message: 'Name, price and image URL are required.' });
    }

    const plant = await Plant.createPlant({
      name, subtitle, tag, priceInr, imageUrl, categories, description, stock,
    });

    return res.status(201).json({ id: plant.id, message: 'Plant created.' });
  } catch (error) {
    return res.status(500).json({ message: 'Failed to create plant.' });
  }
};
