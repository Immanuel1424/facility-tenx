import {
  Column,
  Entity,
  Index,
  ManyToOne,
  OneToMany,
} from 'typeorm';
import { TenantBaseEntity } from '../../../shared/database/tenant-base.entity';

@Entity('hierarchy_nodes')
@Index(['companyId', 'type'])
@Index(['companyId', 'externalId'])
export class HierarchyNode extends TenantBaseEntity {
  @Column({ type: 'varchar', length: 100 })
  type!: string;

  @Column({ type: 'varchar', length: 255 })
  name!: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  externalId?: string;

  @Column({ type: 'uuid', nullable: true })
  parentId?: string;

  @ManyToOne(() => HierarchyNode, (node) => node.children, {
    nullable: true,
    onDelete: 'CASCADE',
  })
  parent?: HierarchyNode;

  @OneToMany(() => HierarchyNode, (node) => node.parent)
  children?: HierarchyNode[];

  @Column({ type: 'jsonb', nullable: true })
  metadata?: Record<string, unknown>;
}


