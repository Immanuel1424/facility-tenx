import { Column, Entity, Index, OneToMany } from 'typeorm';
import { Location } from './location.entity';

@Entity({ name: 'cities' })
@Index(['isActive'])
@Index(['displayOrder'])
@Index(['country'])
@Index(['region'])
export class City {
  @Column({ type: 'uuid', primary: true, generated: 'uuid', name: 'id' })
  id!: string;

  @Column({ type: 'varchar', length: 100, unique: true })
  name!: string;

  @Column({ type: 'varchar', length: 10, nullable: true })
  code?: string;

  @Column({ type: 'varchar', length: 50, nullable: true })
  country?: string;

  @Column({ type: 'varchar', length: 50, nullable: true })
  region?: string;

  @Column({ type: 'varchar', length: 100, nullable: true, name: 'location_description' })
  locationDescription?: string;

  @Column({ type: 'int', default: 0, name: 'display_order' })
  displayOrder!: number;

  @Column({ type: 'boolean', default: true, name: 'is_active' })
  isActive!: boolean;

  @Column({ type: 'timestamptz', default: () => 'now()', name: 'created_at' })
  createdAt!: Date;

  @Column({ type: 'timestamptz', default: () => 'now()', name: 'updated_at' })
  updatedAt!: Date;

  @OneToMany(() => Location, (location) => location.city)
  locations?: Location[];
}

