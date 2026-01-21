import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserSite } from '../entities/user-site.entity';
import { User } from '../../iam/entities/user.entity';
import { Site } from '../entities/site.entity';

@Injectable()
export class UserSiteService {
  constructor(
    @InjectRepository(UserSite)
    private readonly userSiteRepository: Repository<UserSite>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(Site)
    private readonly siteRepository: Repository<Site>,
  ) {}

  /**
   * Assign a user to a site
   */
  async assignUserToSite(
    companyId: string,
    userId: string,
    siteId: string,
  ): Promise<UserSite> {
    // Verify user exists and belongs to company
    const user = await this.userRepository.findOne({
      where: { id: userId, companyId },
    });

    if (!user) {
      throw new NotFoundException(
        `User with id ${userId} not found in company ${companyId}`,
      );
    }

    // Verify site exists and belongs to company
    const site = await this.siteRepository.findOne({
      where: { id: siteId, companyId },
    });

    if (!site) {
      throw new NotFoundException(
        `Site with id ${siteId} not found in company ${companyId}`,
      );
    }

    // Check if relationship already exists
    const existing = await this.userSiteRepository.findOne({
      where: { companyId, userId, siteId },
    });

    if (existing) {
      return existing;
    }

    // Create new relationship
    const userSite = this.userSiteRepository.create({
      companyId,
      userId,
      siteId,
    });

    return this.userSiteRepository.save(userSite);
  }

  /**
   * Remove a user from a site
   */
  async removeUserFromSite(
    companyId: string,
    userId: string,
    siteId: string,
  ): Promise<void> {
    const userSite = await this.userSiteRepository.findOne({
      where: { companyId, userId, siteId },
    });

    if (!userSite) {
      throw new NotFoundException(
        `User ${userId} is not assigned to site ${siteId}`,
      );
    }

    await this.userSiteRepository.remove(userSite);
  }

  /**
   * Get all sites for a user
   */
  async getUserSites(companyId: string, userId: string): Promise<Site[]> {
    const userSites = await this.userSiteRepository.find({
      where: { companyId, userId },
      relations: ['site'],
    });

    return userSites.map((us) => us.site);
  }

  /**
   * Get all users for a site
   */
  async getSiteUsers(companyId: string, siteId: string): Promise<User[]> {
    const userSites = await this.userSiteRepository.find({
      where: { companyId, siteId },
      relations: ['user'],
    });

    return userSites.map((us) => us.user);
  }

  /**
   * Check if a user is assigned to a site
   */
  async isUserAssignedToSite(
    companyId: string,
    userId: string,
    siteId: string,
  ): Promise<boolean> {
    const userSite = await this.userSiteRepository.findOne({
      where: { companyId, userId, siteId },
    });

    // Debug logging to help diagnose assignment issues
    if (!userSite) {
      // Check if assignment exists with different companyId
      const anyAssignment = await this.userSiteRepository.findOne({
        where: { userId, siteId },
      });
      if (anyAssignment) {
        console.error(
          `[UserSiteService] Assignment exists but companyId mismatch: ` +
            `Expected=${companyId}, Found=${anyAssignment.companyId}, ` +
            `userId=${userId}, siteId=${siteId}`,
        );
      } else {
        // Check if assignment exists with different siteId
        const userSites = await this.userSiteRepository.find({
          where: { companyId, userId },
        });
        console.error(
          `[UserSiteService] No assignment found. ` +
            `companyId=${companyId}, userId=${userId}, siteId=${siteId}. ` +
            `User has ${userSites.length} site assignment(s) in this company.`,
        );
      }
    }

    return !!userSite;
  }
}

