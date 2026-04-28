const serverConfig = {
  port: (process.env.PORT ? Number(process.env.PORT) : undefined) || 3000,
  env: process.env.NODE_ENV || 'development',
  jwtSecret: process.env.JWT_SECRET,
  allowedOrigins: process.env.ALLOWED_ORIGINS || '*',
};

export = serverConfig;

