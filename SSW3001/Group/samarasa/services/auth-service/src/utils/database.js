const { Pool } = require('pg');
const config = require('../config');
const logger = require('./logger');

const pool = new Pool(config.database);

pool.on('connect', () => {
  logger.info('Database connected successfully');
});

pool.on('error', (err) => {
  logger.error('Database connection error', { error: err.message });
});

// Test connection
pool.query('SELECT NOW()', (err, res) => {
  if (err) {
    logger.error('Database connection test failed', { error: err.message });
  } else {
    logger.info('Database connection test passed', { timestamp: res.rows[0].now });
  }
});

module.exports = {
  query: (text, params) => pool.query(text, params),
  pool,
};
