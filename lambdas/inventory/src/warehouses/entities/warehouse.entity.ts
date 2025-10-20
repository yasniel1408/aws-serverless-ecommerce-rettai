import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, OneToMany, OneToOne, JoinColumn } from 'typeorm';
import { Product } from '../../products/entities/product.entity';
import { WarehouseAddress } from '../../warehouse-addresses/entities/warehouse-address.entity';

@Entity('warehouses')
export class Warehouse {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', length: 255 })
  name: string;

  @Column({ type: 'varchar', length: 100, unique: true })
  code: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ type: 'varchar', length: 50 })
  type: string; // main, secondary, distribution, etc.

  @Column({ type: 'int', default: 0 })
  capacity: number; // storage capacity

  @Column({ type: 'boolean', default: true })
  isActive: boolean;

  @Column({ type: 'varchar', length: 100, nullable: true })
  managerName: string;

  @Column({ type: 'varchar', length: 20, nullable: true })
  phone: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  email: string;

  @OneToOne(() => WarehouseAddress, address => address.warehouse, { cascade: true, eager: true })
  address: WarehouseAddress;

  @OneToMany(() => Product, product => product.warehouse)
  products: Product[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
