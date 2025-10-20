import { IsString, IsNumber, IsOptional, IsBoolean, IsUUID, Min, MaxLength } from 'class-validator';
import { Type } from 'class-transformer';

export class CreateProductDto {
  @IsString()
  @MaxLength(255)
  name: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsString()
  @MaxLength(100)
  sku: string;

  @IsNumber()
  @Type(() => Number)
  @Min(0)
  price: number;

  @IsNumber()
  @Type(() => Number)
  @Min(0)
  @IsOptional()
  cost?: number;

  @IsNumber()
  @Type(() => Number)
  @Min(0)
  @IsOptional()
  quantity?: number;

  @IsNumber()
  @Type(() => Number)
  @Min(0)
  @IsOptional()
  minStock?: number;

  @IsString()
  @IsOptional()
  category?: string;

  @IsString()
  @IsOptional()
  brand?: string;

  @IsString()
  @IsOptional()
  unit?: string;

  @IsBoolean()
  @IsOptional()
  isActive?: boolean;

  @IsUUID()
  @IsOptional()
  warehouseId?: string;

  @IsOptional()
  metadata?: Record<string, any>;
}
