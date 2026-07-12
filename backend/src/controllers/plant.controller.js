const { Plant } = require('../models');

// ── GET /plants ───────────────────────────────────────────────────────────────
exports.getPlants = async (req, res) => {
  try {
    const { category, search, page = 1, limit = 20 } = req.query;

    const { plants, total } = await Plant.getPlants({ category, search, page, limit });

    return res.status(200).json({
      plants: plants.map(p => ({
        id: p._id,
        name: p.name,
        subtitle: p.subtitle,
        tag: p.tag,
        price_inr: p.priceInr,
        image_url: p.imageUrl,
        categories: p.categories,
        description: p.description,
        stock: p.stock,
        createdAt: p.createdAt,
        updatedAt: p.updatedAt
      })),
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
    const plant = await Plant.findById(req.params.id);
    if (!plant || !plant.isActive) {
      return res.status(404).json({ message: 'Plant not found.' });
    }
    return res.status(200).json(plant.toApiObject());
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

    const plant = await Plant.create({
      name, 
      subtitle, 
      tag, 
      priceInr, 
      imageUrl, 
      categories: categories || [], 
      description: description || '', 
      stock: stock || 0
    });

    return res.status(201).json({ id: plant._id, message: 'Plant created.' });
  } catch (error) {
    console.error('Create plant error:', error);
    return res.status(500).json({ message: 'Failed to create plant.' });
  }
};
