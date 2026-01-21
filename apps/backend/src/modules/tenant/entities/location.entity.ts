import {
  Column,
  Entity,
  Index,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { City } from './city.entity';

@Entity({ name: 'locations' })
@Index(['cityId'])
@Index(['isActive'])
@Index(['displayOrder'])
export class Location {
  @Column({ type: 'uuid', primary: true, generated: 'uuid', name: 'id' })
  id!: string;

  @Column({ type: 'uuid', name: 'city_id' })
  cityId!: string;

  @ManyToOne(() => City, (city) => city.locations, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'city_id' })
  city?: City;

  @Column({ type: 'varchar', length: 100 })
  name!: string;

  @Column({ type: 'varchar', length: 10, nullable: true })
  code?: string;

  @Column({ type: 'int', default: 0, name: 'display_order' })
  displayOrder!: number;

  @Column({ type: 'boolean', default: true, name: 'is_active' })
  isActive!: boolean;

  @Column({ type: 'timestamptz', default: () => 'now()', name: 'created_at' })
  createdAt!: Date;

  @Column({ type: 'timestamptz', default: () => 'now()', name: 'updated_at' })
  updatedAt!: Date;
}

