import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  // Browsers only (the mobile apps are not subject to CORS): the JM Services website.
  // CORS_ORIGINS = comma-separated list, e.g. "https://app.example.com,http://localhost:8081".
  const origins = (process.env.CORS_ORIGINS ?? 'http://localhost:8081')
    .split(',')
    .map((o) => o.trim())
    .filter(Boolean);
  app.enableCors({ origin: origins });
  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
