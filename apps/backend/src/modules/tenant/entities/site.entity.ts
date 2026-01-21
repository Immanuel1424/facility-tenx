import { Column, Entity, ManyToOne, OneToMany, JoinColumn, Index } from 'typeorm';
import { TenantBaseEntity } from '../../../shared/database/tenant-base.entity';
import { Company } from './company.entity';
import { UserSite } from './user-site.entity';

@Entity({ name: 'sites' })
@Index(['companyId', 'code'], { unique: true })
@Index(['companyId', 'isActive'])
export class Site extends TenantBaseEntity {
  @ManyToOne(() => Company, (company) => company.sites, { nullable: false })
  @JoinColumn({ name: 'company_id' })
  company!: Company;

  @Column({ type: 'varchar', length: 20 })
  code!: string;

  @Column({ type: 'varchar', length: 255 })
  name!: string;

  @Column({ type: 'text', nullable: true })
  description?: string;

  @Column({ type: 'varchar', length: 500, nullable: true })
  address?: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  city?: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  country?: string;

  @Column({ type: 'boolean', name: 'is_parent', default: true })
  isParent!: boolean;

  @Column({ type: 'boolean', name: 'is_active', default: true })
  isActive!: boolean;

  @ManyToOne(() => Site, (site) => site.childSites, { nullable: true })
  @JoinColumn({ name: 'parent_site_id' })
  parentSite?: Site;

  @OneToMany(() => Site, (site) => site.parentSite)
  childSites!: Site[];

  @OneToMany(() => UserSite, (userSite) => userSite.site)
  userSites!: UserSite[];
}


