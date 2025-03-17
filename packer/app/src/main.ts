import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { join } from 'path';
import { AppModule } from './app.module';
import * as session from 'express-session';
import {RedisStore} from "connect-redis"
import { createClient } from 'redis';
import { randomBytes } from 'crypto';
import { AppSessionBaseType } from './libs/data-structures/app-session.type';

declare module 'express-session' {
  export interface SessionData extends AppSessionBaseType {}
}

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  // Create Redis client
  const redisClient = createClient({
    socket: {
      host: process.env.REDIS_HOST || 'localhost',
      port: process.env.REDIS_PORT ? +process.env.REDIS_PORT : 6379,
    }
  });

  await redisClient.connect();

  // Create Redis store instance
  const store = new RedisStore({
    client: redisClient,
    prefix: 'sess:',
  });

  // Express session middleware with Redis
  app.use(session({
    store,
    secret: process.env.SESSION_SECRET || randomBytes(20).toString('hex'),
    resave: false,
    saveUninitialized: false,
    cookie: { secure: false, httpOnly: true, maxAge: 1000 * 60 * 60 },
  }));

  app.useStaticAssets(join(__dirname, '..', 'public'));
  app.setBaseViewsDir(join(__dirname, 'views'));
  app.setViewEngine('hbs');

  await app.listen(3000);
}
bootstrap();
