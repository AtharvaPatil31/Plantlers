const User = require('../models/userQueries');

// ── GET /user/profile ─────────────────────────────────────────────────────────
exports.getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found.' });
    }
    return res.status(200).json(User.toSafeObject(user));
  } catch (error) {
    console.error('Get profile error:', error);
    return res.status(500).json({ message: 'Failed to fetch profile.' });
  }
};

// ── PATCH /user/profile/update ────────────────────────────────────────────────
exports.updateProfile = async (req, res) => {
  try {
    const { name, avatarUrl } = req.body;

    const updates = {};
    if (name      !== undefined) updates.name      = name;
    if (avatarUrl !== undefined) updates.avatarUrl = avatarUrl;

    if (Object.keys(updates).length === 0) {
      return res.status(400).json({ message: 'No fields provided to update.' });
    }

    const user = await User.updateProfile(req.user.id, updates);
    if (!user) {
      return res.status(404).json({ message: 'User not found.' });
    }

    return res.status(200).json(User.toSafeObject(user));
  } catch (error) {
    console.error('Update profile error:', error);
    return res.status(500).json({ message: 'Failed to update profile.' });
  }
};

// ── DELETE /user/profile ──────────────────────────────────────────────────────
exports.deleteAccount = async (req, res) => {
  try {
    await User.deactivate(req.user.id);
    await User.deleteAllRefreshTokens(req.user.id);
    return res.status(200).json({ message: 'Account deactivated successfully.' });
  } catch (error) {
    console.error('Delete account error:', error);
    return res.status(500).json({ message: 'Failed to deactivate account.' });
  }
};
