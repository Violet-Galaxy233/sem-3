const authService = require('../services/auth.service');
const logger = require('../utils/logger');

// Register
const register = async (req, res) => {
  try {
    const result = await authService.register(req.body);

    // Audit log
    await authService.auditLog(
      result.user.id,
      'USER_REGISTER',
      req.ip,
      req.get('User-Agent')
    );

    res.status(201).json({
      success: true,
      message: 'User registered successfully. Please enable MFA to complete setup.',
      data: result,
    });
  } catch (error) {
    logger.error('Registration error', { error: error.message, ip: req.ip });
    res.status(400).json({
      success: false,
      message: error.message,
    });
  }
};

// Login
const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    const result = await authService.login(email, password);

    // Audit log
    if (!result.mfaRequired) {
      await authService.auditLog(
        result.user.id,
        'USER_LOGIN',
        req.ip,
        req.get('User-Agent')
      );
    }

    res.status(200).json({
      success: true,
      message: result.mfaRequired ? 'MFA verification required' : 'Login successful',
      data: result,
    });
  } catch (error) {
    logger.error('Login error', { error: error.message, ip: req.ip });
    res.status(401).json({
      success: false,
      message: error.message,
    });
  }
};

// Verify MFA
const verifyMFA = async (req, res) => {
  try {
    const { userId, token } = req.body;
    const result = await authService.verifyMFA(userId, token);

    // Audit log
    await authService.auditLog(
      userId,
      'MFA_VERIFIED',
      req.ip,
      req.get('User-Agent')
    );

    res.status(200).json({
      success: true,
      message: 'MFA verified successfully',
      data: result,
    });
  } catch (error) {
    logger.error('MFA verification error', { error: error.message, ip: req.ip });
    res.status(401).json({
      success: false,
      message: error.message,
    });
  }
};

// Enable MFA
const enableMFA = async (req, res) => {
  try {
    const result = await authService.enableMFA(req.user.userId);

    // Audit log
    await authService.auditLog(
      req.user.userId,
      'MFA_ENABLED',
      req.ip,
      req.get('User-Agent')
    );

    res.status(200).json({
      success: true,
      message: 'MFA enabled successfully',
      data: result,
    });
  } catch (error) {
    logger.error('Enable MFA error', { error: error.message, userId: req.user.userId });
    res.status(400).json({
      success: false,
      message: error.message,
    });
  }
};

// Refresh token
const refreshToken = async (req, res) => {
  try {
    const { userId, refreshToken } = req.body;
    const result = await authService.refreshToken(userId, refreshToken);

    // Audit log
    await authService.auditLog(
      userId,
      'TOKEN_REFRESH',
      req.ip,
      req.get('User-Agent')
    );

    res.status(200).json({
      success: true,
      message: 'Token refreshed successfully',
      data: result,
    });
  } catch (error) {
    logger.error('Token refresh error', { error: error.message, ip: req.ip });
    res.status(401).json({
      success: false,
      message: error.message,
    });
  }
};

// Logout
const logout = async (req, res) => {
  try {
    await authService.logout(req.user.userId);

    // Audit log
    await authService.auditLog(
      req.user.userId,
      'USER_LOGOUT',
      req.ip,
      req.get('User-Agent')
    );

    res.status(200).json({
      success: true,
      message: 'Logout successful',
    });
  } catch (error) {
    logger.error('Logout error', { error: error.message, userId: req.user.userId });
    res.status(500).json({
      success: false,
      message: 'Logout failed',
    });
  }
};

// Validate token
const validate = async (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'No token provided',
      });
    }

    const result = await authService.validateToken(token);

    if (!result.valid) {
      return res.status(401).json({
        success: false,
        message: 'Invalid token',
      });
    }

    res.status(200).json({
      success: true,
      message: 'Token valid',
      data: result.user,
    });
  } catch (error) {
    logger.error('Token validation error', { error: error.message });
    res.status(401).json({
      success: false,
      message: 'Token validation failed',
    });
  }
};

// Health check
const health = (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Auth service is healthy',
    timestamp: new Date().toISOString(),
  });
};

module.exports = {
  register,
  login,
  verifyMFA,
  enableMFA,
  refreshToken,
  logout,
  validate,
  health,
};
