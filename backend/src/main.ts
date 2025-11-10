/* eslint-disable prettier/prettier */
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

    app.setGlobalPrefix('api');

  // Enable CORS for multiple possible origins
  app.enableCors({
    origin: [
      'http://localhost:3000',        // for local dev
      'http://frontend:3000',         // for Docker internal network
      'http://54.145.6.120/' ,
      'http://54.145.6.120/:5000',       // your EC2 public IP
    ],
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
    credentials: true,
  });

  // Swagger config
  const config = new DocumentBuilder()
    .setTitle('Task Management API')
    .setDescription('API documentation for the Task Management application')
    .setVersion('1.0')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  await app.listen(5000, '0.0.0.0');  // bind to all interfaces inside container
}
bootstrap();
