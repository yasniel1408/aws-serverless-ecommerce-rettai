import { IsString, IsNumber, IsOptional, IsBoolean, IsEmail, MaxLength, Min } from 'class-validator';
import { Type } from 'class-transformer';

export class CreateWarehouseAddressDto {
  @IsString()
  @MaxLength(255)
  street: string;

  @IsString()
  @MaxLength(100)
  city: string;

  @IsString()
  @MaxLength(100)
  state: string;

  @IsString()
  @MaxLength(20)
  zipCode: string;

  @IsString()
  @MaxLength(100)
  country: string;

  @IsNumber()
  @Type(() => Number)
  @IsOptional()
  latitude?: number;

  @IsNumber()
  @Type(() => Number)
  @IsOptional()
  longitude?: number;

  @IsString()
  @IsOptional()
  notes?: string;
}

export class CreateWarehouseDto {
  @IsString()
  @MaxLength(255)
  name: string;

  @IsString()
  @MaxLength(100)
  code: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsString()
  @MaxLength(50)
  type: string;

  @IsNumber()
  @Type(() => Number)
  @Min(0)
  @IsOptional()
  capacity?: number;

  @IsBoolean()
  @IsOptional()
  isActive?: boolean;

  @IsString()
  @MaxLength(100)
  @IsOptional()
  managerName?: string;

  @IsString()
  @MaxLength(20)
  @IsOptional()
  phone?: string;

  @IsEmail()
  @IsOptional()
  email?: string;

  @Type(() => CreateWarehouseAddressDto)
  address: CreateWarehouseAddressDto;
}
