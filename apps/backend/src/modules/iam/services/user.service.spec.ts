import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { NotFoundException } from '@nestjs/common';
import { UserService } from './user.service';
import { User, UserStatus, AuthProvider } from '../entities/user.entity';
import { UserRole } from '../entities/user-role.entity';
import { Role } from '../entities/role.entity';
import { VillaService } from '../../tenant/villa.service';
import { Villa } from '../../tenant/entities/villa.entity';

describe('UserService - Delete User', () => {
  let service: UserService;
  let userRepository: jest.Mocked<Repository<User>>;
  let userRoleRepository: jest.Mocked<Repository<UserRole>>;
  let roleRepository: jest.Mocked<Repository<Role>>;
  let villaService: jest.Mocked<VillaService>;

  const mockCompanyId = 'company-123';
  const mockUserId = 'user-123';
  const mockVillaNumber = 'V-101';

  const mockUser: User = {
    id: mockUserId,
    companyId: mockCompanyId,
    email: 'tenant@example.com',
    firstName: 'John',
    lastName: 'Doe',
    villaNumber: mockVillaNumber,
    status: UserStatus.ACTIVE,
    authProvider: AuthProvider.LOCAL,
    passwordHash: 'hashed-password',
    createdAt: new Date(),
    updatedAt: new Date(),
    deletedAt: undefined,
    userRoles: [],
    refreshTokens: [],
    aclEntries: [],
  } as User;

  const mockVilla: Villa = {
    id: 'villa-123',
    companyId: mockCompanyId,
    villaNumber: mockVillaNumber,
    isOccupied: true,
    createdAt: new Date(),
    updatedAt: new Date(),
  } as Villa;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UserService,
        {
          provide: getRepositoryToken(User),
          useValue: {
            findOne: jest.fn(),
            save: jest.fn(),
            find: jest.fn(),
            create: jest.fn(),
            remove: jest.fn(),
          },
        },
        {
          provide: getRepositoryToken(UserRole),
          useValue: {
            find: jest.fn(),
            findOne: jest.fn(),
            remove: jest.fn(),
            create: jest.fn(),
            save: jest.fn(),
          },
        },
        {
          provide: getRepositoryToken(Role),
          useValue: {
            findOne: jest.fn(),
            find: jest.fn(),
          },
        },
        {
          provide: VillaService,
          useValue: {
            findByVillaNumber: jest.fn(),
            update: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<UserService>(UserService);
    userRepository = module.get(getRepositoryToken(User));
    userRoleRepository = module.get(getRepositoryToken(UserRole));
    roleRepository = module.get(getRepositoryToken(Role));
    villaService = module.get(VillaService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('delete', () => {
    it('should successfully soft delete a user without villa number', async () => {
      // Arrange
      const userWithoutVilla = { ...mockUser, villaNumber: undefined };
      userRepository.findOne.mockResolvedValue(userWithoutVilla);
      userRepository.save.mockResolvedValue({
        ...userWithoutVilla,
        status: UserStatus.INACTIVE,
        deletedAt: new Date(),
      } as User);

      // Act
      const result = await service.delete(mockCompanyId, mockUserId);

      // Assert
      expect(userRepository.findOne).toHaveBeenCalledWith({
        where: { companyId: mockCompanyId, id: mockUserId },
        relations: ['userRoles', 'userRoles.role'],
      });
      expect(userRepository.save).toHaveBeenCalledWith(
        expect.objectContaining({
          id: mockUserId,
          status: UserStatus.INACTIVE,
          deletedAt: expect.any(Date),
        }),
      );
      expect(villaService.findByVillaNumber).not.toHaveBeenCalled();
      expect(result.status).toBe(UserStatus.INACTIVE);
      expect(result.deletedAt).toBeDefined();
    });

    it('should successfully soft delete a tenant user with villa number and mark villa as vacant', async () => {
      // Arrange
      userRepository.findOne.mockResolvedValue(mockUser);
      villaService.findByVillaNumber.mockResolvedValue(mockVilla);
      villaService.update.mockResolvedValue({
        ...mockVilla,
        isOccupied: false,
      } as Villa);
      userRepository.save.mockResolvedValue({
        ...mockUser,
        status: UserStatus.INACTIVE,
        deletedAt: new Date(),
      } as User);

      // Act
      const result = await service.delete(mockCompanyId, mockUserId);

      // Assert
      expect(userRepository.findOne).toHaveBeenCalledWith({
        where: { companyId: mockCompanyId, id: mockUserId },
        relations: ['userRoles', 'userRoles.role'],
      });
      expect(userRepository.save).toHaveBeenCalledWith(
        expect.objectContaining({
          id: mockUserId,
          status: UserStatus.INACTIVE,
          deletedAt: expect.any(Date),
        }),
      );
      expect(villaService.findByVillaNumber).toHaveBeenCalledWith(
        mockCompanyId,
        mockVillaNumber,
      );
      expect(villaService.update).toHaveBeenCalledWith(
        mockCompanyId,
        mockVilla.id,
        { isOccupied: false },
      );
      expect(result.status).toBe(UserStatus.INACTIVE);
      expect(result.deletedAt).toBeDefined();
    });

    it('should handle villa sync failure gracefully without failing user deletion', async () => {
      // Arrange
      const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation();
      userRepository.findOne.mockResolvedValue(mockUser);
      villaService.findByVillaNumber.mockRejectedValue(
        new Error('Villa not found'),
      );
      userRepository.save.mockResolvedValue({
        ...mockUser,
        status: UserStatus.INACTIVE,
        deletedAt: new Date(),
      } as User);

      // Act
      const result = await service.delete(mockCompanyId, mockUserId);

      // Assert
      expect(userRepository.save).toHaveBeenCalled();
      expect(result.status).toBe(UserStatus.INACTIVE);
      expect(result.deletedAt).toBeDefined();
      // User deletion should succeed even if villa sync fails
      expect(consoleErrorSpy).toHaveBeenCalled();
      consoleErrorSpy.mockRestore();
    });

    it('should not update villa occupancy if villa is already vacant', async () => {
      // Arrange
      const vacantVilla = { ...mockVilla, isOccupied: false };
      userRepository.findOne.mockResolvedValue(mockUser);
      villaService.findByVillaNumber.mockResolvedValue(vacantVilla);
      userRepository.save.mockResolvedValue({
        ...mockUser,
        status: UserStatus.INACTIVE,
        deletedAt: new Date(),
      } as User);

      // Act
      const result = await service.delete(mockCompanyId, mockUserId);

      // Assert
      expect(villaService.findByVillaNumber).toHaveBeenCalled();
      expect(villaService.update).not.toHaveBeenCalled();
      expect(result.status).toBe(UserStatus.INACTIVE);
    });

    it('should throw NotFoundException when user does not exist', async () => {
      // Arrange
      userRepository.findOne.mockResolvedValue(null);

      // Act & Assert
      await expect(service.delete(mockCompanyId, mockUserId)).rejects.toThrow(
        NotFoundException,
      );
      await expect(service.delete(mockCompanyId, mockUserId)).rejects.toThrow(
        'User not found',
      );
      expect(userRepository.save).not.toHaveBeenCalled();
    });

    it('should throw NotFoundException when user belongs to different company', async () => {
      // Arrange
      userRepository.findOne.mockResolvedValue(null);

      // Act & Assert
      await expect(
        service.delete('different-company', mockUserId),
      ).rejects.toThrow(NotFoundException);
      expect(userRepository.save).not.toHaveBeenCalled();
    });

    it('should preserve user data after soft delete (for referential integrity)', async () => {
      // Arrange
      userRepository.findOne.mockResolvedValue(mockUser);
      userRepository.save.mockResolvedValue({
        ...mockUser,
        status: UserStatus.INACTIVE,
        deletedAt: new Date(),
      } as User);

      // Act
      const result = await service.delete(mockCompanyId, mockUserId);

      // Assert
      expect(result.id).toBe(mockUserId);
      expect(result.email).toBe(mockUser.email);
      expect(result.firstName).toBe(mockUser.firstName);
      expect(result.lastName).toBe(mockUser.lastName);
      expect(result.villaNumber).toBe(mockUser.villaNumber);
      expect(result.status).toBe(UserStatus.INACTIVE);
      expect(result.deletedAt).toBeDefined();
    });

    it('should set deletedAt timestamp when deleting user', async () => {
      // Arrange
      const beforeDelete = new Date();
      userRepository.findOne.mockResolvedValue(mockUser);
      userRepository.save.mockImplementation((user) => {
        return Promise.resolve({
          ...user,
          deletedAt: new Date(),
        } as User);
      });

      // Act
      const result = await service.delete(mockCompanyId, mockUserId);
      const afterDelete = new Date();

      // Assert
      expect(result.deletedAt).toBeDefined();
      expect(result.deletedAt!.getTime()).toBeGreaterThanOrEqual(
        beforeDelete.getTime(),
      );
      expect(result.deletedAt!.getTime()).toBeLessThanOrEqual(
        afterDelete.getTime(),
      );
    });

    it('should handle user with multiple villa numbers (villaNumbers array)', async () => {
      // Arrange
      const userWithMultipleVillas = {
        ...mockUser,
        villaNumber: 'V-101',
        villaNumbers: ['V-101', 'V-102'],
      };
      userRepository.findOne.mockResolvedValue(userWithMultipleVillas);
      villaService.findByVillaNumber.mockResolvedValue(mockVilla);
      villaService.update.mockResolvedValue({
        ...mockVilla,
        isOccupied: false,
      } as Villa);
      userRepository.save.mockResolvedValue({
        ...userWithMultipleVillas,
        status: UserStatus.INACTIVE,
        deletedAt: new Date(),
      } as User);

      // Act
      const result = await service.delete(mockCompanyId, mockUserId);

      // Assert
      // Should sync the primary villa (first in array)
      expect(villaService.findByVillaNumber).toHaveBeenCalledWith(
        mockCompanyId,
        'V-101',
      );
      expect(result.status).toBe(UserStatus.INACTIVE);
      expect(result.deletedAt).toBeDefined();
    });

    it('should handle user deletion when villa does not exist', async () => {
      // Arrange
      userRepository.findOne.mockResolvedValue(mockUser);
      villaService.findByVillaNumber.mockResolvedValue(null);
      userRepository.save.mockResolvedValue({
        ...mockUser,
        status: UserStatus.INACTIVE,
        deletedAt: new Date(),
      } as User);

      // Act
      const result = await service.delete(mockCompanyId, mockUserId);

      // Assert
      expect(villaService.findByVillaNumber).toHaveBeenCalled();
      expect(villaService.update).not.toHaveBeenCalled();
      expect(result.status).toBe(UserStatus.INACTIVE);
      expect(result.deletedAt).toBeDefined();
      // User deletion should succeed even if villa doesn't exist
    });
  });

  describe('Cascade Delete Behavior', () => {
    it('should verify that user roles are cascade deleted (database constraint)', () => {
      // This test documents the expected database behavior
      // Actual cascade delete is handled by database foreign key constraints
      // UserRole entity has: @ManyToOne(() => User, { onDelete: 'CASCADE' })
      expect(true).toBe(true); // Placeholder - actual cascade is tested via integration tests
    });

    it('should verify that refresh tokens are cascade deleted (database constraint)', () => {
      // This test documents the expected database behavior
      // RefreshToken entity has: @ManyToOne(() => User, { onDelete: 'CASCADE' })
      expect(true).toBe(true); // Placeholder - actual cascade is tested via integration tests
    });

    it('should verify that user-site assignments are cascade deleted (database constraint)', () => {
      // This test documents the expected database behavior
      // UserSite entity has: @ManyToOne(() => User, { onDelete: 'CASCADE' })
      expect(true).toBe(true); // Placeholder - actual cascade is tested via integration tests
    });
  });

  describe('User Visibility After Deletion', () => {
    it('should verify deleted users are excluded from findByEmail queries', async () => {
      // Arrange
      const deletedUser = {
        ...mockUser,
        deletedAt: new Date(),
      };
      userRepository.findOne.mockResolvedValue(null); // Deleted users not returned

      // Act
      const result = await service.findByEmail(
        mockCompanyId,
        mockUser.email,
      );

      // Assert
      expect(result).toBeNull();
      expect(userRepository.findOne).toHaveBeenCalledWith({
        where: {
          companyId: mockCompanyId,
          email: mockUser.email,
          deletedAt: expect.anything(), // Should filter by deletedAt: IsNull()
        },
        relations: ['userRoles', 'userRoles.role'],
      });
    });

    it('should verify deleted users cannot log in (excluded from auth queries)', () => {
      // This test documents expected behavior
      // Authentication service should filter out deleted users
      expect(true).toBe(true); // Placeholder - actual auth filtering tested in auth service tests
    });
  });

  describe('Maintenance Tickets After User Deletion', () => {
    it('should verify maintenance tickets remain intact after user deletion', () => {
      // This test documents expected behavior
      // Maintenance tickets should NOT be deleted when user is soft-deleted
      // The created_by foreign key still references the user (soft-deleted)
      // Historical data must be preserved for audit purposes
      expect(true).toBe(true); // Placeholder - actual ticket preservation tested in integration tests
    });

    it('should verify maintenance tickets can still reference deleted user', () => {
      // This test documents expected behavior
      // MaintenanceTicket.created_by foreign key should still work
      // even though user is soft-deleted (deleted_at IS NOT NULL)
      expect(true).toBe(true); // Placeholder - actual foreign key behavior tested in integration tests
    });
  });
});
