import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Warehouse } from '../entities/warehouse.entity';
import { WarehouseAddress } from '../../warehouse-addresses/entities/warehouse-address.entity';
import { CreateWarehouseDto } from '../dto/create-warehouse.dto';
import { UpdateWarehouseDto } from '../dto/update-warehouse.dto';

@Injectable()
export class WarehousesService {
  constructor(
    @InjectRepository(Warehouse)
    private readonly warehouseRepository: Repository<Warehouse>,
    @InjectRepository(WarehouseAddress)
    private readonly addressRepository: Repository<WarehouseAddress>,
  ) {}

  async create(createWarehouseDto: CreateWarehouseDto): Promise<Warehouse> {
    // Check if code already exists
    const existingWarehouse = await this.warehouseRepository.findOne({
      where: { code: createWarehouseDto.code },
    });

    if (existingWarehouse) {
      throw new ConflictException(`Warehouse with code ${createWarehouseDto.code} already exists`);
    }

    // Create warehouse
    const warehouse = this.warehouseRepository.create({
      ...createWarehouseDto,
      address: undefined,
    });

    const savedWarehouse = await this.warehouseRepository.save(warehouse);

    // Create address
    if (createWarehouseDto.address) {
      const address = this.addressRepository.create({
        ...createWarehouseDto.address,
        warehouseId: savedWarehouse.id,
      });
      await this.addressRepository.save(address);
    }

    return await this.findOne(savedWarehouse.id);
  }

  async findAll(filters?: {
    type?: string;
    isActive?: boolean;
  }): Promise<Warehouse[]> {
    const queryBuilder = this.warehouseRepository.createQueryBuilder('warehouse')
      .leftJoinAndSelect('warehouse.address', 'address')
      .leftJoinAndSelect('warehouse.products', 'products');

    if (filters?.type) {
      queryBuilder.andWhere('warehouse.type = :type', { type: filters.type });
    }

    if (filters?.isActive !== undefined) {
      queryBuilder.andWhere('warehouse.isActive = :isActive', { isActive: filters.isActive });
    }

    return await queryBuilder.getMany();
  }

  async findOne(id: string): Promise<Warehouse> {
    const warehouse = await this.warehouseRepository.findOne({
      where: { id },
      relations: ['address', 'products'],
    });

    if (!warehouse) {
      throw new NotFoundException(`Warehouse with ID ${id} not found`);
    }

    return warehouse;
  }

  async findByCode(code: string): Promise<Warehouse> {
    const warehouse = await this.warehouseRepository.findOne({
      where: { code },
      relations: ['address', 'products'],
    });

    if (!warehouse) {
      throw new NotFoundException(`Warehouse with code ${code} not found`);
    }

    return warehouse;
  }

  async update(id: string, updateWarehouseDto: UpdateWarehouseDto): Promise<Warehouse> {
    const warehouse = await this.findOne(id);

    // Check code uniqueness if being updated
    if (updateWarehouseDto.code && updateWarehouseDto.code !== warehouse.code) {
      const existingWarehouse = await this.warehouseRepository.findOne({
        where: { code: updateWarehouseDto.code },
      });

      if (existingWarehouse) {
        throw new ConflictException(`Warehouse with code ${updateWarehouseDto.code} already exists`);
      }
    }

    // Update warehouse
    Object.assign(warehouse, {
      ...updateWarehouseDto,
      address: undefined,
    });
    await this.warehouseRepository.save(warehouse);

    // Update address if provided
    if (updateWarehouseDto.address && warehouse.address) {
      Object.assign(warehouse.address, updateWarehouseDto.address);
      await this.addressRepository.save(warehouse.address);
    }

    return await this.findOne(id);
  }

  async remove(id: string): Promise<void> {
    const warehouse = await this.findOne(id);
    await this.warehouseRepository.remove(warehouse);
  }

  async getCapacityReport(id: string): Promise<{
    warehouse: Warehouse;
    totalProducts: number;
    utilizationPercentage: number;
  }> {
    const warehouse = await this.findOne(id);
    const totalProducts = warehouse.products?.reduce((sum, product) => sum + product.quantity, 0) || 0;
    const utilizationPercentage = warehouse.capacity > 0 
      ? (totalProducts / warehouse.capacity) * 100 
      : 0;

    return {
      warehouse,
      totalProducts,
      utilizationPercentage,
    };
  }
}
