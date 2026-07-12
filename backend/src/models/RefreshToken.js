const mongoose = require('mongoose');

const refreshTokenSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  token: {
    type: String,
    required: true,
    unique: true
  },
  createdAt: {
    type: Date,
    default: Date.now,
    expires: 60 * 60 * 24 * 7 // 7 days in seconds
  }
});

// Index for performance and automatic cleanup
refreshTokenSchema.index({ userId: 1 });
refreshTokenSchema.index({ token: 1 });
refreshTokenSchema.index({ createdAt: 1 }, { expireAfterSeconds: 0 });

// Static method to add refresh token and maintain limit
refreshTokenSchema.statics.addToken = async function(userId, token) {
  // Add new token
  await this.create({ userId, token });
  
  // Keep only the 5 most recent tokens per user (multi-device support)
  const tokens = await this.find({ userId })
    .sort({ createdAt: -1 })
    .skip(5);
  
  if (tokens.length > 0) {
    const tokenIds = tokens.map(t => t._id);
    await this.deleteMany({ _id: { $in: tokenIds } });
  }
};

// Static method to find token with user info
refreshTokenSchema.statics.findWithUser = async function(token) {
  return this.findOne({ token })
    .populate('userId', 'isActive')
    .lean();
};

const RefreshToken = mongoose.model('RefreshToken', refreshTokenSchema);

module.exports = RefreshToken;