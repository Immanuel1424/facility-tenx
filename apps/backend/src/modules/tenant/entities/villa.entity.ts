import {
  Column,
  Entity,
  Index,
  ManyToOne,
  JoinColumn,
  OneToMany,
} from 'typeorm';
import { TenantBaseEntity } from '../../../shared/database/tenant-base.entity';
import { Site } from './site.entity';
import { Space } from './space.entity';

@Entity({ name: 'villas' })
@Index(['companyId', 'villaNumber'], { unique: true })
@Index(['companyId', 'villaCode'], { unique: true, where: 'villa_code IS NOT NULL' })
@Index(['companyId', 'siteId'])
@Index(['companyId', 'isActive'])
export class Villa extends TenantBaseEntity {
  @Column({ type: 'varchar', length: 50, name: 'villa_number' })
  villaNumber!: string;

  @Column({ type: 'varchar', length: 50, nullable: true, name: 'villa_code' })
  villaCode?: string;

  @Column({ type: 'uuid', nullable: true, name: 'site_id' })
  siteId?: string;

  @ManyToOne(() => Site, { nullable: true })
  @JoinColumn({ name: 'site_id' })
  site?: Site;

  @Column({ type: 'uuid', nullable: true, name: 'space_id' })
  spaceId?: string;

  @ManyToOne(() => Space, { nullable: true })
  @JoinColumn({ name: 'space_id' })
  space?: Space;

  // Owner/Tenant information
  @Column({ type: 'varchar', length: 255, nullable: true, name: 'owner_name' })
  ownerName?: string;

  @Column({ type: 'varchar', length: 255, nullable: true, name: 'tenant_name' })
  tenantName?: string;

  @Column({ type: 'varchar', length: 50, nullable: true, name: 'contact_phone' })
  contactPhone?: string;

  @Column({ type: 'varchar', length: 255, nullable: true, name: 'contact_email' })
  contactEmail?: string;

  // Address details
  @Column({ type: 'varchar', length: 50, nullable: true })
  block?: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  street?: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  city?: string;

  @Column({ type: 'varchar', length: 20, nullable: true, name: 'pin_code' })
  pinCode?: string;

  @Column({ type: 'varchar', length: 50, nullable: true, name: 'makani_number' })
  makaniNumber?: string;

  @Column({ type: 'varchar', length: 50, nullable: true, name: 'po_box' })
  poBox?: string;

  // Status
  @Column({ type: 'boolean', default: true, name: 'is_active' })
  isActive!: boolean;

  @Column({ type: 'boolean', default: true, name: 'is_occupied' })
  isOccupied!: boolean;

  // Additional metadata
  @Column({ type: 'int', nullable: true, name: 'floor_count' })
  floorCount?: number;

  @Column({ type: 'int', nullable: true, name: 'bedroom_count' })
  bedroomCount?: number;

  @Column({ type: 'int', nullable: true, name: 'bathroom_count' })
  bathroomCount?: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true, name: 'area_sqm' })
  areaSqm?: number;

  @Column({ type: 'varchar', length: 50, nullable: true, name: 'villa_type' })
  villaType?: string;

  @Column({ type: 'varchar', length: 100, nullable: true, name: 'building_name' })
  buildingName?: string;

  @Column({ type: 'date', nullable: true, name: 'open_from' })
  openFrom?: Date;

  @Column({ type: 'varchar', length: 50, nullable: true, name: 'unit_no' })
  unitNo?: string;

  @Column({ type: 'varchar', length: 100, nullable: true, name: 'unit_name' })
  unitName?: string;

  @Column({ type: 'varchar', length: 50, nullable: true, name: 'primary_view' })
  primaryView?: string;

  @Column({ type: 'varchar', length: 50, nullable: true, name: 'unit_category' })
  unitCategory?: string;

  @Column({ type: 'varchar', length: 50, nullable: true, name: 'floor' })
  floor?: string;

  @Column({ type: 'varchar', length: 50, nullable: true, name: 'parking_slot_number' })
  parkingSlotNumber?: string;

  @Column({ type: 'varchar', length: 50, nullable: true, name: 'meter_number' })
  meterNumber?: string;

  @Column({ type: 'varchar', length: 50, nullable: true, name: 'water_meter_number' })
  waterMeterNumber?: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  measure?: string;

  @Column({ type: 'varchar', length: 255, nullable: true, name: 'external_area' })
  externalArea?: string;

  @Column({ type: 'text', nullable: true })
  remarks?: string;

  @Column({ type: 'jsonb', nullable: true })
  metadata?: Record<string, unknown>;
}

