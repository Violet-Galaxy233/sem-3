require('dotenv').config();

module.exports = {
  port: parseInt(process.env.PORT || 4001),
  nodeEnv: process.env.NODE_ENV || 'development',

  database: {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || 5432),
    database: process.env.DB_NAME || 'smamrasa',
    user: process.env.DB_USER || 'smamrasa_admin',
    password: process.env.DB_PASSWORD || 'smamrasa_password_2024',
    max: 20,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
  },

  redis: {
    host: process.env.REDIS_HOST || 'localhost',
    port: parseInt(process.env.REDIS_PORT || 6379),
    password: process.env.REDIS_PASSWORD || 'redis_password_2024',
    ttl: 3600, // 1 hour
  },

  jwt: {
    secret: process.env.JWT_SECRET || 'your_jwt_secret_key_here',
    expiresIn: process.env.JWT_EXPIRES_IN || '15m',
    refreshExpiresIn: process.env.REFRESH_TOKEN_EXPIRES_IN || '7d',
  },

  rateLimit: {
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || 900000), // 15 minutes
    max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || 100),
  },

  cors: {
    origin: process.env.CORS_ORIGIN || 'http://localhost:3001,http://localhost:3002,http://localhost:3003',
    credentials: true,
  },

  security: {
    mfa: {
      window: 1, // 1 time step before/after
      otpLength: 6,
    },
    password: {
      min: 8,
      max: 128,
      bcryptRounds: 12,
    },
  },

  logging: {
    level: process.env.LOG_LEVEL || 'info',
    format: process.env.LOG_FORMAT || 'json',
  },

  audit: {
    enabled: process.env.AUDIT_LOG_ENABLED === 'true',
    retentionYears: parseInt(process.env.AUDIT_LOG_RETENTION_YEARS || 7),
  },
};
