/**
 * Seed script — inserts sample plants into MongoDB.
 *
 * Run with:
 *   node src/scripts/seed.js
 */

require('dotenv').config({ path: require('path').resolve(__dirname, '../../.env') });
const { connectDB } = require('../config/db');
const { Plant } = require('../models');

const plants = [
  {
    name: 'Monstera Deliciosa',
    subtitle: 'Swiss Cheese Plant',
    tag: 'BESTSELLER',
    priceInr: 499,
    imageUrl: 'https://images.unsplash.com/photo-1614594975525-e45190c55d0b?w=400',
    categories: ['tropical', 'lowlight'],
    description: 'The iconic split-leaf Monstera is a statement plant that thrives in indirect light. Perfect for living rooms and offices.',
    stock: 25,
  },
  {
    name: 'Snake Plant',
    subtitle: 'Sansevieria Trifasciata',
    tag: 'LOW MAINTENANCE',
    priceInr: 299,
    imageUrl: 'https://images.unsplash.com/photo-1593691509543-c55fb32d8de5?w=400',
    categories: ['lowlight', 'office', 'airpurifier'],
    description: 'One of the hardiest houseplants. Tolerates low light and infrequent watering. A top air purifier.',
    stock: 40,
  },
  {
    name: 'Peace Lily',
    subtitle: 'Spathiphyllum',
    tag: 'PET SAFE',
    priceInr: 349,
    imageUrl: 'https://images.unsplash.com/photo-1616690248441-9e4b5e5e5e5e?w=400',
    categories: ['petfriendly', 'lowlight', 'airpurifier'],
    description: 'Elegant white blooms and glossy leaves. Thrives in shade and helps purify indoor air.',
    stock: 18,
  },
  {
    name: 'Pothos',
    subtitle: 'Epipremnum Aureum',
    tag: 'BEGINNER FRIENDLY',
    priceInr: 199,
    imageUrl: 'https://images.unsplash.com/photo-1572688484438-313a6e50c333?w=400',
    categories: ['lowlight', 'office'],
    description: 'The ultimate beginner plant. Trails beautifully from shelves and tolerates neglect like a champ.',
    stock: 60,
  },
  {
    name: 'Fiddle Leaf Fig',
    subtitle: 'Ficus Lyrata',
    tag: 'TRENDING',
    priceInr: 799,
    imageUrl: 'https://images.unsplash.com/photo-1545241047-6083a3684587?w=400',
    categories: ['tropical'],
    description: 'The darling of interior designers. Large, violin-shaped leaves make a dramatic statement in bright rooms.',
    stock: 12,
  },
  {
    name: 'Spider Plant',
    subtitle: 'Chlorophytum Comosum',
    tag: 'PET SAFE',
    priceInr: 249,
    imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
    categories: ['petfriendly', 'office', 'airpurifier'],
    description: 'Fast-growing and pet-safe. Produces charming "spiderettes" that dangle from the mother plant.',
    stock: 35,
  },
  {
    name: 'ZZ Plant',
    subtitle: 'Zamioculcas Zamiifolia',
    tag: 'DROUGHT TOLERANT',
    priceInr: 449,
    imageUrl: 'https://images.unsplash.com/photo-1611735341450-74d61e660ad2?w=400',
    categories: ['lowlight', 'office'],
    description: 'Virtually indestructible. Stores water in its rhizomes, making it perfect for forgetful plant parents.',
    stock: 22,
  },
  {
    name: 'Rubber Plant',
    subtitle: 'Ficus Elastica',
    tag: 'AIR PURIFIER',
    priceInr: 599,
    imageUrl: 'https://images.unsplash.com/photo-1597055181449-a9c7b3e0e5e5?w=400',
    categories: ['tropical', 'airpurifier'],
    description: 'Bold, glossy burgundy leaves that add a dramatic touch. Excellent at removing toxins from the air.',
    stock: 15,
  },
];

const seed = async () => {
  try {
    console.log('🔄 Connecting to MongoDB...');
    await connectDB();

    console.log('🔄 Seeding plants...\n');

    // Clear existing plants
    await Plant.deleteMany({});
    console.log('🗑️  Cleared existing plants');

    // Insert new plants
    for (const plantData of plants) {
      const plant = await Plant.create(plantData);
      console.log(`  ✅ ${plant.name} (₹${plant.priceInr})`);
    }

    console.log(`\n🌱 Seeded ${plants.length} plants successfully!`);
    process.exit(0);
  } catch (err) {
    console.error('❌ Seed failed:', err.message);
    process.exit(1);
  }
};

seed();
