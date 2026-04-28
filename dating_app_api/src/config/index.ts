import 'dotenv/config';

import db = require('./db.config');
import redis = require('./redis.config');
import cos = require('./cos.config');
import im = require('./im.config');
import push = require('./push.config');
import server = require('./server.config');

const config = {
  db,
  redis,
  cos,
  im,
  push,
  server,
};

export = config;

