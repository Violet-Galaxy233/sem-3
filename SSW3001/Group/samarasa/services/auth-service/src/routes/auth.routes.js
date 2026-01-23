const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const validation = require('../middleware/validation');
const { verifyToken, createRateLimiter } = require('../middleware/auth');
const config = require('../config');

// Rate limiters
const registerLimiter = createRateLimiter(
  15 * 60 * 1000, // 15 minutes
  5, // 5 attempts
  'Too many registration attempts. Please try again later.'
);

const loginLimiter = createRateLimiter(
  15 * 60 * 1000, // 15 minutes
  10, // 10 attempts
  'Too many login attempts. Please try again later.'
);

const refreshLimiter = createRateLimiter(
  60 * 60 * 1000, // 1 hour
  30, // 30 attempts
  'Too many refresh attempts.'
);

// Public routes
router.get('/health', authController.health);

router.post(
  '/register',
  registerLimiter,
  validation.registerValidation,
  authController.register
);

router.post(
  '/login',
  loginLimiter,
  validation.loginValidation,
  authController.login
);

router.post(
  '/verify-mfa',
  loginLimiter,
  validation.mfaValidation,
  authController.verifyMFA
);

router.post(
  '/refresh',
  refreshLimiter,
  validation.refreshValidation,
  authController.refreshToken
);

// Protected routes (require valid JWT)
router.post('/logout', verifyToken, authController.logout);

router.get('/validate', verifyToken, authController.validate);

router.post('/enable-mfa', verifyToken, authController.enableMFA);

module.exports = router;
