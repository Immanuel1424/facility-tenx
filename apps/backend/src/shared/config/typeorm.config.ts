import { TypeOrmModuleOptions } from '@nestjs/typeorm';

export const typeOrmConfig = async (): Promise<TypeOrmModuleOptions> => {
  return {
    type: 'postgres',
    host: process.env.DB_HOST ?? 'localhost',
    port: Number(process.env.DB_PORT ?? '5432'),
    username: process.env.DB_USER ?? 'postgres',
    password: process.env.DB_PASSWORD ?? 'postgres',
    database: process.env.DB_NAME ?? 'facility_erp',
    entities: [__dirname + '/../../**/*.entity.{js,ts}'],
    synchronize: false, // Disabled - schema is managed via migrations
    logging: false,
  };
};


