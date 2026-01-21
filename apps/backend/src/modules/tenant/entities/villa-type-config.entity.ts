import {
  Column,
  Entity,
  Index,
} from 'typeorm';
import { TenantBaseEntity } from '../../../shared/database/tenant-base.entity';

/**
 * Villa Type Configuration Entity
 * 
 * Stores configurable defaults for villa types per company.
 * Allows admins to define default bedroom count, floor count, and area
 * for each villa type, enabling faster data entry.
 * 
 * Example:
 * - Company A: 1BHK → 1 bedroom, 1 floor, 50 sqm
 * - Company B: 1BHK → 1 bedroom, 2 floors, 60 sqm
 */
@Entity({ name: 'villa_type_configs' })
@Index(['companyId', 'villaType'], { unique: true })
@Index(['companyId', 'isActive'])
export class VillaTypeConfig extends TenantBaseEntity {
  /**
   * Villa type code (e.g., '1BHK', '2BHK', 'Studio', 'Duplex')
   * Must be unique per company
   */
  @Column({ type: 'varchar', length: 50, name: 'villa_type' })
  villaType!: string;

  /**
   * Display name for the villa type (e.g., '1 Bedroom Hall Kitchen')
   * Optional, defaults to villaType if not provided
   */
  @Column({ type: 'varchar', length: 255, nullable: true, name: 'display_name' })
  displayName?: string;

  /**
   * Default bedroom count for this villa type
   * Auto-filled when creating a villa with this type
   */
  @Column({ type: 'int', nullable: true, name: 'default_bedroom_count' })
  defaultBedroomCount?: number;

  /**
   * Default floor count for this villa type
   * Auto-filled when creating a villa with this type
   */
  @Column({ type: 'int', nullable: true, name: 'default_floor_count' })
  defaultFloorCount?: number;

  /**
   * Default area in square meters
   * Auto-filled when creating a villa with this type
   */
  @Column({ 
    type: 'decimal', 
    precision: 10, 
    scale: 2, 
    nullable: true, 
    name: 'default_area_sqm' 
  })
  defaultAreaSqm?: number;

  /**
   * Display order for dropdowns/lists
   * Lower numbers appear first
   */
  @Column({ type: 'int', default: 0, name: 'display_order' })
  displayOrder!: number;

  /**
   * Whether this configuration is active
   * Inactive configs won't appear in dropdowns but existing villas remain valid
   */
  @Column({ type: 'boolean', default: true, name: 'is_active' })
  isActive!: boolean;

  /**
   * Additional metadata (JSONB)
   * Can store custom fields like description, amenities, etc.
   */
  @Column({ type: 'jsonb', nullable: true })
  metadata?: Record<string, unknown>;
}

