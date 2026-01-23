const jwt = require('jsonwebtoken');
const config = require('../config');
const logger = require('../utils/logger');

// Verify JWT token
const verifyToken = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({
      success: false,
      message: 'Access denied. No token provided.',
    });
  }

  const token = authHeader.split(' ')[1]; // Bearer <token>

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Access denied. Invalid token format.',
    });
  }

  try {
    const decoded = jwt.verify(token, config.jwt.secret);
    req.user = decoded;
    logger.info('Token verified', { userId: decoded.userId, role: decoded.role });
    next();
  } catch (error) {
    logger.warn('Invalid token attempt', { error: error.message, ip: req.ip });
    return res.status(401).json({
      success: false,
      message: 'Invalid or expired token.',
    });
  }
};

// Verify role
const verifyRole = (...allowedRoles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'User not authenticated.',
      });
    }

    if (!allowedRoles.includes(req.user.role)) {
      logger.warn('Unauthorized role access attempt', {
        userId: req.user.userId,
        role: req.user.role,
        required: allowedRoles,
        path: req.path,
      });
      return res.status(403).json({
        success: false,
        message: 'Access denied. Insufficient permissions.',
      });
    }

    next();
  };
};

// Rate limiting middleware
const rateLimit = require('express-rate-limit');
const createRateLimiter = (windowMs, max, message) => {
  return rateLimit({
    windowMs,
    max,
    message: {
      success: false,
      message: message || 'Too many requests. Please try again later.',
    },
    standardHeaders: true,
    legacyHeaders: false,
    skip: (req) => req.path === '/health', // Skip health checks
  });
};

module.exports = {
  verifyToken,
  verifyRole,
  createRateLimiter,
};
