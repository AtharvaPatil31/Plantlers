const mongoose = require('mongoose');

const plantSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Plant name is required'],
    trim: true,
    maxlength: [200, 'Plant name cannot exceed 200 characters']
  },
  subtitle: {
    type: String,
    trim: true,
    maxlength: [300, 'Subtitle cannot exceed 300 characters'],
    default: null
  },
  tag: {
    type: String,
    trim: true,
    uppercase: true,
    maxlength: [50, 'Tag cannot exceed 50 characters'],
    default: null
  },
  priceInr: {
    type: Number,
    required: [true, 'Price is required'],
    min: [0, 'Price cannot be negative']
  },
  imageUrl: {
    type: String,
    required: [true, 'Image URL is required'],
    trim: true
  },
  categories: [{
    type: String,
    trim: true,
    lowercase: true
  }],
  description: {
    type: String,
    default: '',
    maxlength: [2000, 'Description cannot exceed 2000 characters']
  },
  stock: {
    type: Number,
    default: 0,
    min: [0, 'Stock cannot be negative']
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true,
  toJSON: { 
    transform: function(doc, ret) {
      delete ret.__v;
      return ret;
    }
  }
});

// Indexes for performance
plantSchema.index({ name: 'text', subtitle: 'text', tag: 'text' }); // Full text search
plantSchema.index({ categories: 1 });
plantSchema.index({ isActive: 1 });
plantSchema.index({ createdAt: -1 });

// Static method for filtered search with pagination
plantSchema.statics.getPlants = async function({ category, search, page = 1, limit = 20 }) {
  const offset = (parseInt(page) - 1) * parseInt(limit);
  const query = { isActive: true };

  // Add category filter
  if (category) {
    query.categories = { $in: [category.toLowerCase()] };
  }

  // Add search filter
  if (search) {
    query.$or = [
      { name: { $regex: search, $options: 'i' } },
      { subtitle: { $regex: search, $options: 'i' } },
      { tag: { $regex: search, $options: 'i' } },
      { description: { $regex: search, $options: 'i' } }
    ];
  }

  // Get total count
  const total = await this.countDocuments(query);

  // Get paginated results
  const plants = await this.find(query)
    .sort({ createdAt: -1 })
    .skip(offset)
    .limit(parseInt(limit))
    .lean();

  return { plants, total };
};

// Instance method to convert to API object
plantSchema.methods.toApiObject = function() {
  return {
    id: this._id,
    name: this.name,
    subtitle: this.subtitle,
    tag: this.tag,
    price_inr: this.priceInr,
    image_url: this.imageUrl,
    categories: this.categories,
    description: this.description,
    stock: this.stock,
    createdAt: this.createdAt,
    updatedAt: this.updatedAt
  };
};

const Plant = mongoose.model('Plant', plantSchema);

module.exports = Plant;