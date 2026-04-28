import { Redis } from '@upstash/redis';

import config = require('../config/redis.config');

const redis = new Redis({
  url: config.url,
  token: config.token,
});

export = redis;

