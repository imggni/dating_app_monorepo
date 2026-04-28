const ioClient = require('socket.io-client');
const jwt = require('jsonwebtoken');
const { expect } = require('chai');

const serverModule = require('../../src/index.ts');
const server = serverModule.server;
const config = require('../../src/config/server.config');

describe('Socket authentication and heartbeat', function () {
  this.timeout(10000);

  let socket;
  let port;

  before(function (done) {
    if (server.listening) {
      const address = server.address();
      port = typeof address === 'object' && address ? address.port : config.port;
      return done();
    }

    // Bind to an ephemeral port to avoid collisions in local dev/CI.
    server.listen(0, () => {
      const address = server.address();
      port = typeof address === 'object' && address ? address.port : config.port;
      done();
    });
  });

  after(function (done) {
    try {
      if (socket && socket.connected) socket.disconnect();
    } catch (e) {}
    // Close server
    if (!server.listening) return done();
    server.close(() => done());
  });

  it('should connect with valid JWT and set online key', function (done) {
    const secret = config.jwtSecret || process.env.JWT_SECRET;
    if (!secret) return this.skip();

    const testUserId = 'test-user-1';
    const token = jwt.sign({ id: testUserId }, secret, { expiresIn: '1h' });

    socket = ioClient(`http://localhost:${port}`, {
      auth: { token },
      transports: ['websocket'],
    });

    socket.on('connect', async () => {
      try {
        expect(socket.connected).to.be.true;

        // wait a short time for server to set redis key
        const redis = require('../../src/utils/redis.util');
        if (process.env.REDIS_URL) {
          // verify online key exists
          const val = await redis.get(`online:${testUserId}`);
          expect(val).to.be.a('string');
        }

        socket.emit('heartbeat');
        setTimeout(() => {
          socket.disconnect();
          done();
        }, 200);
      } catch (e) {
        socket.disconnect();
        done(e);
      }
    });

    socket.on('connect_error', (err) => done(err));
  });
});
