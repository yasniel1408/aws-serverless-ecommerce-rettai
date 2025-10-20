import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { WarehousesController } from './controllers/warehouses.controller';
import { WarehousesService } from './services/warehouses.service';
import { Warehouse } from './entities/warehouse.entity';
import { WarehouseAddress } from '../warehouse-addresses/entities/warehouse-address.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Warehouse, WarehouseAddress])],
  controllers: [WarehousesController],
  providers: [WarehousesService],
  exports: [WarehousesService],
})
export class WarehousesModule {}
