import cors from 'cors';

import config = require('../config/server.config');

export default cors({
  origin: config.allowedOrigins === '*' ? true : config.allowedOrigins.split(','),
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
});

