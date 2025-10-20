import { Controller, Get, Post, Body, Patch, Param, Delete, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { WarehousesService } from '../services/warehouses.service';
import { CreateWarehouseDto } from '../dto/create-warehouse.dto';
import { UpdateWarehouseDto } from '../dto/update-warehouse.dto';
import { AdminGuard } from '../../auth/guards/admin.guard';

@ApiTags('warehouses')
@ApiBearerAuth()
@Controller('warehouses')
@UseGuards(AdminGuard)
export class WarehousesController {
  constructor(private readonly warehousesService: WarehousesService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new warehouse (Admin only)' })
  @ApiResponse({ status: 201, description: 'Warehouse created successfully' })
  @ApiResponse({ status: 409, description: 'Warehouse with code already exists' })
  create(@Body() createWarehouseDto: CreateWarehouseDto) {
    return this.warehousesService.create(createWarehouseDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all warehouses with optional filters (Admin only)' })
  @ApiResponse({ status: 200, description: 'List of warehouses' })
  findAll(
    @Query('type') type?: string,
    @Query('isActive') isActive?: string,
  ) {
    return this.warehousesService.findAll({
      type,
      isActive: isActive === 'true',
    });
  }

  @Get('code/:code')
  @ApiOperation({ summary: 'Get warehouse by code (Admin only)' })
  @ApiResponse({ status: 200, description: 'Warehouse found' })
  @ApiResponse({ status: 404, description: 'Warehouse not found' })
  findByCode(@Param('code') code: string) {
    return this.warehousesService.findByCode(code);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get warehouse by ID (Admin only)' })
  @ApiResponse({ status: 200, description: 'Warehouse found' })
  @ApiResponse({ status: 404, description: 'Warehouse not found' })
  findOne(@Param('id') id: string) {
    return this.warehousesService.findOne(id);
  }

  @Get(':id/capacity')
  @ApiOperation({ summary: 'Get warehouse capacity report (Admin only)' })
  @ApiResponse({ status: 200, description: 'Capacity report' })
  @ApiResponse({ status: 404, description: 'Warehouse not found' })
  getCapacityReport(@Param('id') id: string) {
    return this.warehousesService.getCapacityReport(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update warehouse (Admin only)' })
  @ApiResponse({ status: 200, description: 'Warehouse updated successfully' })
  @ApiResponse({ status: 404, description: 'Warehouse not found' })
  update(@Param('id') id: string, @Body() updateWarehouseDto: UpdateWarehouseDto) {
    return this.warehousesService.update(id, updateWarehouseDto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete warehouse (Admin only)' })
  @ApiResponse({ status: 200, description: 'Warehouse deleted successfully' })
  @ApiResponse({ status: 404, description: 'Warehouse not found' })
  remove(@Param('id') id: string) {
    return this.warehousesService.remove(id);
  }
}
