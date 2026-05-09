const { verifyAccessToken } = require('../utils/jwt');
const User = require('../models/userQueries');

/**
 * Protects routes — verifies JWT access token.
 * Attaches req.user = { id } on success.
 */
const protect = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'No token provided.' });
    }

    const token   = authHeader.split(' ')[1];
    const decoded = verifyAccessToken(token);

    // Confirm user still exists and is active
    const user = await User.findById(decoded.sub);
    if (!user || !user.is_active) {
      return res.status(401).json({ message: 'User no longer exists.' });
    }

    req.user = { id: user.id };
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ message: 'Token expired.', code: 'TOKEN_EXPIRED' });
    }
    return res.status(401).json({ message: 'Invalid token.' });
  }
};

module.exports = { protect };
