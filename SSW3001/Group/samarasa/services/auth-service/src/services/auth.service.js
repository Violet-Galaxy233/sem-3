const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const speakeasy = require('speakeasy');
const qrcode = require('qrcode');
const { v4: uuidv4 } = require('uuid');
const config = require('../config');
const db = require('../utils/database');
const redis = require('../utils/redis');
const logger = require('../utils/logger');

class AuthService {
  // Generate JWT tokens
  generateTokens(payload) {
    const accessToken = jwt.sign(payload, config.jwt.secret, {
      expiresIn: config.jwt.expiresIn,
    });

    const refreshToken = jwt.sign(payload, config.jwt.secret, {
      expiresIn: config.jwt.refreshExpiresIn,
    });

    return { accessToken, refreshToken };
  }

  // Hash password
  async hashPassword(password) {
    return bcrypt.hash(password, config.security.password.bcryptRounds);
  }

  // Verify password
  async verifyPassword(password, hash) {
    return bcrypt.compare(password, hash);
  }

  // Register new user
  async register(userData) {
    const { email, password, name, phone, role } = userData;

    // Check if user exists
    const existingUser = await db.query(
      'SELECT id FROM users WHERE email = $1',
      [email]
    );

    if (existingUser.rows.length > 0) {
      throw new Error('User with this email already exists');
    }

    // Hash password
    const passwordHash = await this.hashPassword(password);

    // Generate MFA secret for new users
    const mfaSecret = speakeasy.generateSecret({
      name: `SMAMRASA (${email})`,
      length: 32,
    });

    // Create user
    const userId = uuidv4();
    const result = await db.query(
      `INSERT INTO users (
        id, email, password_hash, name, phone, role,
        mfa_secret, mfa_enabled, email_verified, created_at, updated_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, false, false, NOW(), NOW())
      RETURNING id, email, name, role`,
      [userId, email, passwordHash, name, phone, role, mfaSecret.base32]
    );

    const user = result.rows[0];

    // Generate MFA QR code
    const qrCodeDataUrl = await qrcode.toDataURL(mfaSecret.otpauth_url);

    logger.info('User registered successfully', { userId, email, role });

    return {
      user,
      mfa: {
        secret: mfaSecret.base32,
        qrCode: qrCodeDataUrl,
        manualEntry: mfaSecret.otpauth_url,
      },
    };
  }

  // Login user
  async login(email, password) {
    // Get user from database
    const result = await db.query(
      'SELECT id, email, password_hash, name, role, mfa_enabled, mfa_secret FROM users WHERE email = $1',
      [email]
    );

    if (result.rows.length === 0) {
      throw new Error('Invalid credentials');
    }

    const user = result.rows[0];

    // Verify password
    const isValidPassword = await this.verifyPassword(password, user.password_hash);
    if (!isValidPassword) {
      throw new Error('Invalid credentials');
    }

    // Check if MFA is enabled
    if (user.mfa_enabled) {
      return {
        mfaRequired: true,
        userId: user.id,
        message: 'MFA verification required',
      };
    }

    // Generate tokens
    const payload = {
      userId: user.id,
      email: user.email,
      role: user.role,
      name: user.name,
    };

    const { accessToken, refreshToken } = this.generateTokens(payload);

    // Store refresh token in Redis
    await redis.setEx(
      `refresh_token:${user.id}`,
      config.redis.ttl,
      refreshToken
    );

    logger.info('User logged in successfully', { userId: user.id, email });

    return {
      mfaRequired: false,
      accessToken,
      refreshToken,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
      },
    };
  }

  // Verify MFA token
  async verifyMFA(userId, token) {
    const result = await db.query(
      'SELECT mfa_secret, mfa_enabled FROM users WHERE id = $1',
      [userId]
    );

    if (result.rows.length === 0) {
      throw new Error('User not found');
    }

    const { mfa_secret, mfa_enabled } = result.rows[0];

    if (!mfa_enabled) {
      throw new Error('MFA not enabled for this user');
    }

    // Verify token
    const verified = speakeasy.totp.verify({
      secret: mfa_secret,
      encoding: 'base32',
      token: token,
      window: config.security.mfa.window,
    });

    if (!verified) {
      logger.warn('Invalid MFA token attempt', { userId });
      throw new Error('Invalid MFA token');
    }

    // Get user details
    const userResult = await db.query(
      'SELECT id, email, name, role FROM users WHERE id = $1',
      [userId]
    );

    const user = userResult.rows[0];

    // Generate tokens
    const payload = {
      userId: user.id,
      email: user.email,
      role: user.role,
      name: user.name,
    };

    const { accessToken, refreshToken } = this.generateTokens(payload);

    // Store refresh token in Redis
    await redis.setEx(
      `refresh_token:${user.id}`,
      config.redis.ttl,
      refreshToken
    );

    logger.info('MFA verified successfully', { userId });

    return {
      accessToken,
      refreshToken,
      user,
    };
  }

  // Enable MFA
  async enableMFA(userId) {
    const result = await db.query(
      'SELECT mfa_secret FROM users WHERE id = $1',
      [userId]
    );

    if (result.rows.length === 0) {
      throw new Error('User not found');
    }

    const { mfa_secret } = result.rows[0];

    // Generate QR code
    const secret = speakeasy.generateSecret({
      name: `SMAMRASA (${userId})`,
      length: 32,
    });

    // Update user with new secret and enable MFA
    await db.query(
      'UPDATE users SET mfa_secret = $1, mfa_enabled = true WHERE id = $2',
      [secret.base32, userId]
    );

    const qrCodeDataUrl = await qrcode.toDataURL(secret.otpauth_url);

    logger.info('MFA enabled', { userId });

    return {
      secret: secret.base32,
      qrCode: qrCodeDataUrl,
      manualEntry: secret.otpauth_url,
    };
  }

  // Refresh token
  async refreshToken(userId, refreshToken) {
    // Verify refresh token
    try {
      const decoded = jwt.verify(refreshToken, config.jwt.secret);

      if (decoded.userId !== userId) {
        throw new Error('Invalid token');
      }

      // Check if token is in Redis (not revoked)
      const storedToken = await redis.get(`refresh_token:${userId}`);
      if (storedToken !== refreshToken) {
        throw new Error('Token revoked or expired');
      }

      // Generate new tokens
      const payload = {
        userId: decoded.userId,
        email: decoded.email,
        role: decoded.role,
        name: decoded.name,
      };

      const { accessToken, newRefreshToken } = this.generateTokens(payload);

      // Update Redis with new refresh token
      await redis.setEx(
        `refresh_token:${userId}`,
        config.redis.ttl,
        newRefreshToken
      );

      logger.info('Token refreshed', { userId });

      return { accessToken, refreshToken: newRefreshToken };
    } catch (error) {
      logger.warn('Token refresh failed', { userId, error: error.message });
      throw new Error('Invalid refresh token');
    }
  }

  // Logout user
  async logout(userId) {
    await redis.del(`refresh_token:${userId}`);
    logger.info('User logged out', { userId });
  }

  // Validate token
  async validateToken(token) {
    try {
      const decoded = jwt.verify(token, config.jwt.secret);
      return { valid: true, user: decoded };
    } catch (error) {
      return { valid: false, error: error.message };
    }
  }

  // Audit log
  async auditLog(userId, action, ip, userAgent) {
    if (!config.audit.enabled) return;

    await db.query(
      `INSERT INTO audit_log (id, user_id, action, ip_address, user_agent, timestamp)
       VALUES ($1, $2, $3, $4, $5, NOW())`,
      [uuidv4(), userId, action, ip, userAgent]
    );

    logger.info('Audit log recorded', { userId, action, ip });
  }
}

module.exports = new AuthService();
