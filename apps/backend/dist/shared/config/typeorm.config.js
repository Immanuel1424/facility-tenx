"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.typeOrmConfig = void 0;
const typeOrmConfig = async () => {
    return {
        type: 'postgres',
        host: process.env.DB_HOST ?? 'localhost',
        port: Number(process.env.DB_PORT ?? '5432'),
        username: process.env.DB_USER ?? 'postgres',
        password: process.env.DB_PASSWORD ?? 'postgres',
        database: process.env.DB_NAME ?? 'facility_erp',
        entities: [__dirname + '/../../**/*.entity.{js,ts}'],
        synchronize: false,
        logging: false,
    };
};
exports.typeOrmConfig = typeOrmConfig;
