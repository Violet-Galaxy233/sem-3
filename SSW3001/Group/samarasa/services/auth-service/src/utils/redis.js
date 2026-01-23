const redis = require('redis');
const config = require('../config');
const logger = require('./logger');

const client = redis.createClient({
  socket: {
    host: config.redis.host,
    port: config.redis.port,
  },
  password: config.redis.password,
  legacyMode: true,
});

client.on('connect', () => {
  logger.info('Redis connected successfully');
});

client.on('error', (err) => {
  logger.error('Redis error', { error: err.message });
});

client.on('ready', () => {
  logger.info('Redis client ready');
});

// Connect
client.connect().catch(console.error);

module.exports = client;
