const db = require('../config/db');

// ── GET all plants (filter + search + paginate) ───────────────────────────────
const getPlants = async ({ category, search, page = 1, limit = 20 }) => {
  const offset = (parseInt(page) - 1) * parseInt(limit);
  const conditions = ['p.is_active = true'];
  const values = [];
  let idx = 1;

  if (category) {
    conditions.push(`$${idx} = ANY(p.categories)`);
    values.push(category);
    idx++;
  }

  if (search) {
    // Simple ILIKE search across name, subtitle, tag
    conditions.push(
      `(p.name ILIKE $${idx} OR p.subtitle ILIKE $${idx} OR p.tag ILIKE $${idx})`
    );
    values.push(`%${search}%`);
    idx++;
  }

  const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';

  // Count total
  const countResult = await db.query(
    `SELECT COUNT(*) FROM plants p ${where}`,
    values
  );
  const total = parseInt(countResult.rows[0].count, 10);

  // Fetch page
  const { rows } = await db.query(
    `SELECT * FROM plants p ${where}
     ORDER BY p.created_at DESC
     LIMIT $${idx} OFFSET $${idx + 1}`,
    [...values, parseInt(limit), offset]
  );

  return { plants: rows, total };
};

// ── GET plant by ID ───────────────────────────────────────────────────────────
const getPlantById = async (id) => {
  const { rows } = await db.query(
    'SELECT * FROM plants WHERE id = $1 AND is_active = true LIMIT 1',
    [id]
  );
  return rows[0] || null;
};

// ── CREATE plant ──────────────────────────────────────────────────────────────
const createPlant = async ({ name, subtitle, tag, priceInr, imageUrl, categories, description, stock }) => {
  const { rows } = await db.query(
    `INSERT INTO plants (name, subtitle, tag, price_inr, image_url, categories, description, stock)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
     RETURNING *`,
    [
      name,
      subtitle || null,
      tag ? tag.toUpperCase() : null,
      priceInr,
      imageUrl,
      categories || [],
      description || '',
      stock || 0,
    ]
  );
  return rows[0];
};

// ── Format plant for API response ────────────────────────────────────────────
const toApiObject = (p) => ({
  id: p.id,
  name: p.name,
  subtitle: p.subtitle,
  tag: p.tag,
  price_inr: p.price_inr,
  image_url: p.image_url,
  categories: p.categories,
  description: p.description,
  stock: p.stock,
});

module.exports = { getPlants, getPlantById, createPlant, toApiObject };
