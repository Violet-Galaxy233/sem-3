const { body, validationResult } = require('express-validator');
const logger = require('../utils/logger');

// Validation result handler
const validate = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    logger.warn('Validation failed', {
      errors: errors.array(),
      path: req.path,
      ip: req.ip,
    });
    return res.status(400).json({
      success: false,
      message: 'Validation failed.',
      errors: errors.array().map(e => ({
        field: e.param,
        message: e.msg,
      })),
    });
  }
  next();
};

// Registration validation
const registerValidation = [
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Invalid email address'),

  body('password')
    .isLength({ min: 8 })
    .withMessage('Password must be at least 8 characters')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
    .withMessage('Password must contain uppercase, lowercase, and number'),

  body('name')
    .trim()
    .isLength({ min: 2, max: 255 })
    .withMessage('Name must be 2-255 characters'),

  body('phone')
    .optional()
    .isMobilePhone()
    .withMessage('Invalid phone number'),

  body('role')
    .isIn(['patient', 'doctor', 'admin'])
    .withMessage('Invalid role. Must be patient, doctor, or admin'),

  validate,
];

// Login validation
const loginValidation = [
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Invalid email address'),

  body('password')
    .notEmpty()
    .withMessage('Password is required'),

  validate,
];

// MFA verification validation
const mfaValidation = [
  body('userId')
    .isUUID()
    .withMessage('Invalid user ID'),

  body('token')
    .isLength({ min: 6, max: 6 })
    .isNumeric()
    .withMessage('Invalid MFA token'),

  validate,
];

// Refresh token validation
const refreshValidation = [
  body('refreshToken')
    .notEmpty()
    .withMessage('Refresh token is required'),

  validate,
];

module.exports = {
  registerValidation,
  loginValidation,
  mfaValidation,
  refreshValidation,
  validate,
};
