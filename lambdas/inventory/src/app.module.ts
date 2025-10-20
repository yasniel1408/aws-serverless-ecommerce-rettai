import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProductsModule } from './products/products.module';
import { WarehousesModule } from './warehouses/warehouses.module';
import { Product } from './products/entities/product.entity';
import { Warehouse } from './warehouses/entities/warehouse.entity';
import { WarehouseAddress } from './warehouse-addresses/entities/warehouse-address.entity';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get('DB_HOST'),
        port: configService.get('DB_PORT', 5432),
        username: configService.get('DB_USERNAME'),
        password: configService.get('DB_PASSWORD'),
        database: configService.get('DB_NAME'),
        entities: [Product, Warehouse, WarehouseAddress],
        synchronize: configService.get('NODE_ENV') !== 'production', // Set to false in production
        logging: configService.get('NODE_ENV') === 'development',
        ssl: configService.get('NODE_ENV') === 'production' ? {
          rejectUnauthorized: false,
        } : false,
      }),
      inject: [ConfigService],
    }),
    ProductsModule,
    WarehousesModule,
  ],
  controllers: [],
  providers: [],
})
export class AppModule {}
