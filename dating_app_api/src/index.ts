import express from 'express';
import helmet from 'helmet';
import morgan from 'morgan';
import http from 'http';
import { Server as SocketIOServer } from 'socket.io';
import swaggerUi from 'swagger-ui-express';

import config = require('./config');
import routes from './routes';
import loggingMiddleware from './middleware/logging.middleware';
import corsMiddleware from './middleware/cors.middleware';
import socketManager from './socket';
import { buildOpenApiSpec } from './config/swagger';
import { HttpError } from './errors/http-error';
import { sendOk } from './utils/response.util';
import errorMiddleware = require('./middleware/error.middleware');

const app = express();
const server = http.createServer(app);

// Init Socket.IO
const io = new SocketIOServer(server, {
  cors: {
    origin: config.server.allowedOrigins === '*' ? true : config.server.allowedOrigins.split(','),
    methods: ['GET', 'POST'],
  },
});
socketManager.init(io);

// Middleware
app.use(helmet());
app.use(corsMiddleware);
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan('dev'));
app.use(loggingMiddleware);

// Root
app.get('/', (req, res) => {
  return sendOk(res, { service: 'Dating App API' }, '成功');
});

// Swagger UI
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(buildOpenApiSpec()));

// Routes
app.use('/api', routes);

app.use((_req, _res) => {
  throw new HttpError(404, '接口不存在');
});

// Error handler
app.use(errorMiddleware);

const PORT = config.server.port;
if (require.main === module) {
  server.listen(PORT, () => {
    console.log(`Express 后端服务已启动，地址：http://localhost:${PORT}`);
    console.log(`API Docs: http://localhost:${PORT}/api-docs`);
  });
}

export { app, server };

