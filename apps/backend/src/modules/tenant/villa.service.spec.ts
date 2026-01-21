import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository, SelectQueryBuilder } from 'typeorm';
import { ConflictException, NotFoundException } from '@nestjs/common';
import { VillaService, CreateVillaDto, UpdateVillaDto } from './villa.service';
import { Villa } from './entities/villa.entity';
import { User } from '../iam/entities/user.entity';
import { VillaTypeConfigService } from './villa-type-config.service';

describe('VillaService', () => {
  let service: VillaService;
  let villaRepository: jest.Mocked<Repository<Villa>>;
  let userRepository: jest.Mocked<Repository<User>>;
  let villaTypeConfigService: jest.Mocked<VillaTypeConfigService>;

  const mockCompanyId = 'company-123';
  const mockVillaId = 'villa-123';
  const mockVillaNumber = 'V-101';

  const mockVilla: Villa = {
    id: mockVillaId,
    companyId: mockCompanyId,
    villaNumber: mockVillaNumber,
    isActive: true,
    isOccupied: false,
    createdAt: new Date(),
    updatedAt: new Date(),
  } as Villa;

  const mockUser: User = {
    id: 'user-123',
    companyId: mockCompanyId,
    email: 'user@example.com',
    villaNumber: mockVillaNumber,
    createdAt: new Date(),
    updatedAt: new Date(),
  } as User;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        VillaService,
        {
          provide: getRepositoryToken(Villa),
          useValue: {
            findOne: jest.fn(),
            find: jest.fn(),
            create: jest.fn(),
            save: jest.fn(),
            remove: jest.fn(),
            createQueryBuilder: jest.fn(() => ({
              where: jest.fn().mockReturnThis(),
              andWhere: jest.fn().mockReturnThis(),
              getMany: jest.fn(),
            })),
          },
        },
        {
          provide: getRepositoryToken(User),
          useValue: {
            find: jest.fn(),
            findOne: jest.fn(),
            create: jest.fn(),
            save: jest.fn(),
          },
        },
        {
          provide: VillaTypeConfigService,
          useValue: {
            getDefaults: jest.fn(),
            findByVillaType: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<VillaService>(VillaService);
    villaRepository = module.get(getRepositoryToken(Villa));
    userRepository = module.get(getRepositoryToken(User));
    villaTypeConfigService = module.get(VillaTypeConfigService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('create', () => {
    it('should successfully create a villa with minimal required data', async () => {
      // Arrange
      const dto: CreateVillaDto = {
        villaNumber: mockVillaNumber,
      };

      villaRepository.findOne.mockResolvedValue(null); // No existing villa
      villaRepository.create.mockReturnValue(mockVilla);
      villaRepository.save.mockResolvedValue(mockVilla);

      // Act
      const result = await service.create(mockCompanyId, dto);

      // Assert
      expect(villaRepository.findOne).toHaveBeenCalledWith({
        where: { companyId: mockCompanyId, villaNumber: mockVillaNumber },
      });
      expect(villaRepository.create).toHaveBeenCalledWith({
        companyId: mockCompanyId,
        villaNumber: mockVillaNumber,
        bedroomCount: undefined,
        floorCount: undefined,
        areaSqm: undefined,
      });
      expect(villaRepository.save).toHaveBeenCalledWith(mockVilla);
      expect(result).toEqual(mockVilla);
      expect(villaTypeConfigService.getDefaults).not.toHaveBeenCalled();
    });

    it('should successfully create a villa with all optional fields', async () => {
      // Arrange
      const dto: CreateVillaDto = {
        villaNumber: mockVillaNumber,
        villaCode: 'VC-101',
        siteId: 'site-123',
        spaceId: 'space-123',
        ownerName: 'John Owner',
        tenantName: 'Jane Tenant',
        contactPhone: '+971501234567',
        contactEmail: 'tenant@example.com',
        block: 'Block A',
        street: 'Main Street',
        city: 'Dubai',
        pinCode: '12345',
        makaniNumber: 'MK-12345',
        poBox: 'PO-123',
        isActive: true,
        isOccupied: false,
        floorCount: 2,
        bedroomCount: 3,
        bathroomCount: 2,
        areaSqm: 150.5,
        villaType: 'Luxury',
        buildingName: 'Tower A',
        openFrom: new Date('2024-01-01'),
        unitNo: 'U-101',
        unitName: 'Penthouse',
        primaryView: 'Sea View',
        unitCategory: 'Premium',
        floor: '5',
        parkingSlotNumber: 'P-101',
        meterNumber: 'M-101',
        waterMeterNumber: 'WM-101',
        measure: '150 sqm',
        externalArea: '50 sqm',
        remarks: 'Test remarks',
      };

      const fullVilla: Villa = {
        ...mockVilla,
        ...dto,
      } as Villa;

      villaRepository.findOne.mockResolvedValue(null);
      villaRepository.create.mockReturnValue(fullVilla);
      villaRepository.save.mockResolvedValue(fullVilla);

      // Act
      const result = await service.create(mockCompanyId, dto);

      // Assert
      expect(villaRepository.findOne).toHaveBeenCalledWith({
        where: { companyId: mockCompanyId, villaNumber: mockVillaNumber },
      });
      expect(villaRepository.create).toHaveBeenCalledWith({
        companyId: mockCompanyId,
        ...dto,
        bedroomCount: 3,
        floorCount: 2,
        areaSqm: 150.5,
      });
      expect(villaRepository.save).toHaveBeenCalledWith(fullVilla);
      expect(result).toEqual(fullVilla);
    });

    it('should throw ConflictException when villa number already exists', async () => {
      // Arrange
      const dto: CreateVillaDto = {
        villaNumber: mockVillaNumber,
      };

      const existingVilla: Villa = {
        ...mockVilla,
        villaNumber: mockVillaNumber,
      } as Villa;

      villaRepository.findOne.mockResolvedValue(existingVilla);

      // Act & Assert
      await expect(service.create(mockCompanyId, dto)).rejects.toThrow(
        ConflictException,
      );
      await expect(service.create(mockCompanyId, dto)).rejects.toThrow(
        `Villa number ${mockVillaNumber} already exists`,
      );
      expect(villaRepository.findOne).toHaveBeenCalledWith({
        where: { companyId: mockCompanyId, villaNumber: mockVillaNumber },
      });
      expect(villaRepository.create).not.toHaveBeenCalled();
      expect(villaRepository.save).not.toHaveBeenCalled();
    });

    it('should auto-fill defaults from villa type configuration when villa type is provided', async () => {
      // Arrange
      const dto: CreateVillaDto = {
        villaNumber: mockVillaNumber,
        villaType: 'Standard',
      };

      const defaults = {
        defaultBedroomCount: 2,
        defaultFloorCount: 1,
        defaultAreaSqm: 100.0,
      };

      const villaWithDefaults: Villa = {
        ...mockVilla,
        villaType: 'Standard',
        bedroomCount: 2,
        floorCount: 1,
        areaSqm: 100.0,
      } as Villa;

      villaRepository.findOne.mockResolvedValue(null);
      villaTypeConfigService.getDefaults.mockResolvedValue(defaults);
      villaRepository.create.mockReturnValue(villaWithDefaults);
      villaRepository.save.mockResolvedValue(villaWithDefaults);

      // Act
      const result = await service.create(mockCompanyId, dto);

      // Assert
      expect(villaTypeConfigService.getDefaults).toHaveBeenCalledWith(
        mockCompanyId,
        'Standard',
      );
      expect(villaRepository.create).toHaveBeenCalledWith({
        companyId: mockCompanyId,
        villaNumber: mockVillaNumber,
        villaType: 'Standard',
        bedroomCount: 2,
        floorCount: 1,
        areaSqm: 100.0,
      });
      expect(result).toEqual(villaWithDefaults);
    });

    it('should allow manual override of defaults from villa type configuration', async () => {
      // Arrange
      const dto: CreateVillaDto = {
        villaNumber: mockVillaNumber,
        villaType: 'Standard',
        bedroomCount: 4, // Manual override
        floorCount: 3, // Manual override
        areaSqm: 200.0, // Manual override
      };

      const defaults = {
        defaultBedroomCount: 2,
        defaultFloorCount: 1,
        defaultAreaSqm: 100.0,
      };

      const villaWithOverrides: Villa = {
        ...mockVilla,
        villaType: 'Standard',
        bedroomCount: 4,
        floorCount: 3,
        areaSqm: 200.0,
      } as Villa;

      villaRepository.findOne.mockResolvedValue(null);
      villaTypeConfigService.getDefaults.mockResolvedValue(defaults);
      villaRepository.create.mockReturnValue(villaWithOverrides);
      villaRepository.save.mockResolvedValue(villaWithOverrides);

      // Act
      const result = await service.create(mockCompanyId, dto);

      // Assert
      expect(villaTypeConfigService.getDefaults).toHaveBeenCalledWith(
        mockCompanyId,
        'Standard',
      );
      // Manual values should be used, not defaults
      expect(villaRepository.create).toHaveBeenCalledWith({
        companyId: mockCompanyId,
        villaNumber: mockVillaNumber,
        villaType: 'Standard',
        bedroomCount: 4, // Manual override
        floorCount: 3, // Manual override
        areaSqm: 200.0, // Manual override
      });
      expect(result).toEqual(villaWithOverrides);
    });

    it('should handle partial defaults from villa type configuration', async () => {
      // Arrange
      const dto: CreateVillaDto = {
        villaNumber: mockVillaNumber,
        villaType: 'Standard',
        bedroomCount: 3, // Manual override
        // floorCount and areaSqm should use defaults
      };

      const defaults = {
        defaultFloorCount: 2,
        defaultAreaSqm: 120.0,
        // No defaultBedroomCount
      };

      const villaWithPartialDefaults: Villa = {
        ...mockVilla,
        villaType: 'Standard',
        bedroomCount: 3,
        floorCount: 2,
        areaSqm: 120.0,
      } as Villa;

      villaRepository.findOne.mockResolvedValue(null);
      villaTypeConfigService.getDefaults.mockResolvedValue(defaults);
      villaRepository.create.mockReturnValue(villaWithPartialDefaults);
      villaRepository.save.mockResolvedValue(villaWithPartialDefaults);

      // Act
      const result = await service.create(mockCompanyId, dto);

      // Assert
      expect(villaRepository.create).toHaveBeenCalledWith({
        companyId: mockCompanyId,
        villaNumber: mockVillaNumber,
        villaType: 'Standard',
        bedroomCount: 3, // Manual value
        floorCount: 2, // From defaults
        areaSqm: 120.0, // From defaults
      });
      expect(result).toEqual(villaWithPartialDefaults);
    });

    it('should handle villa type configuration not found gracefully', async () => {
      // Arrange
      const dto: CreateVillaDto = {
        villaNumber: mockVillaNumber,
        villaType: 'NonExistent',
      };

      const villaWithoutDefaults: Villa = {
        ...mockVilla,
        villaType: 'NonExistent',
      } as Villa;

      villaRepository.findOne.mockResolvedValue(null);
      villaTypeConfigService.getDefaults.mockResolvedValue(null); // Config not found
      villaRepository.create.mockReturnValue(villaWithoutDefaults);
      villaRepository.save.mockResolvedValue(villaWithoutDefaults);

      // Act
      const result = await service.create(mockCompanyId, dto);

      // Assert
      expect(villaTypeConfigService.getDefaults).toHaveBeenCalledWith(
        mockCompanyId,
        'NonExistent',
      );
      expect(villaRepository.create).toHaveBeenCalledWith({
        companyId: mockCompanyId,
        villaNumber: mockVillaNumber,
        villaType: 'NonExistent',
        bedroomCount: undefined,
        floorCount: undefined,
        areaSqm: undefined,
      });
      expect(result).toEqual(villaWithoutDefaults);
    });

    it('should set companyId correctly in created villa', async () => {
      // Arrange
      const dto: CreateVillaDto = {
        villaNumber: mockVillaNumber,
      };

      villaRepository.findOne.mockResolvedValue(null);
      villaRepository.create.mockReturnValue(mockVilla);
      villaRepository.save.mockResolvedValue(mockVilla);

      // Act
      const result = await service.create(mockCompanyId, dto);

      // Assert
      expect(villaRepository.create).toHaveBeenCalledWith(
        expect.objectContaining({
          companyId: mockCompanyId,
        }),
      );
      expect(result.companyId).toBe(mockCompanyId);
    });

    it('should handle database save errors', async () => {
      // Arrange
      const dto: CreateVillaDto = {
        villaNumber: mockVillaNumber,
      };

      const dbError = new Error('Database connection failed');
      villaRepository.findOne.mockResolvedValue(null);
      villaRepository.create.mockReturnValue(mockVilla);
      villaRepository.save.mockRejectedValue(dbError);

      // Act & Assert
      await expect(service.create(mockCompanyId, dto)).rejects.toThrow(
        'Database connection failed',
      );
      expect(villaRepository.findOne).toHaveBeenCalled();
      expect(villaRepository.create).toHaveBeenCalled();
      expect(villaRepository.save).toHaveBeenCalled();
    });

    it('should create villa with isActive defaulting to true when not specified', async () => {
      // Arrange
      const dto: CreateVillaDto = {
        villaNumber: mockVillaNumber,
        // isActive not specified
      };

      const villaWithDefaultActive: Villa = {
        ...mockVilla,
        isActive: true,
      } as Villa;

      villaRepository.findOne.mockResolvedValue(null);
      villaRepository.create.mockReturnValue(villaWithDefaultActive);
      villaRepository.save.mockResolvedValue(villaWithDefaultActive);

      // Act
      const result = await service.create(mockCompanyId, dto);

      // Assert
      expect(result.isActive).toBe(true);
    });

    it('should create villa with isOccupied defaulting to false when not specified', async () => {
      // Arrange
      const dto: CreateVillaDto = {
        villaNumber: mockVillaNumber,
        // isOccupied not specified
      };

      const villaWithDefaultOccupied: Villa = {
        ...mockVilla,
        isOccupied: false,
      } as Villa;

      villaRepository.findOne.mockResolvedValue(null);
      villaRepository.create.mockReturnValue(villaWithDefaultOccupied);
      villaRepository.save.mockResolvedValue(villaWithDefaultOccupied);

      // Act
      const result = await service.create(mockCompanyId, dto);

      // Assert
      expect(result.isOccupied).toBe(false);
    });

    it('should handle date string conversion for openFrom field', async () => {
      // Arrange
      const openFromDate = new Date('2024-01-01');
      const dto: CreateVillaDto = {
        villaNumber: mockVillaNumber,
        openFrom: '2024-01-01' as any, // String date
      };

      const villaWithDate: Villa = {
        ...mockVilla,
        openFrom: openFromDate,
      } as Villa;

      villaRepository.findOne.mockResolvedValue(null);
      villaRepository.create.mockReturnValue(villaWithDate);
      villaRepository.save.mockResolvedValue(villaWithDate);

      // Act
      const result = await service.create(mockCompanyId, dto);

      // Assert
      expect(villaRepository.create).toHaveBeenCalledWith(
        expect.objectContaining({
          openFrom: '2024-01-01',
        }),
      );
      expect(result).toEqual(villaWithDate);
    });
  });

  describe('findAll', () => {
    it('should return all villas for a company ordered by villa number', async () => {
      // Arrange
      const villas: Villa[] = [
        { ...mockVilla, id: 'villa-1', villaNumber: 'V-101' },
        { ...mockVilla, id: 'villa-2', villaNumber: 'V-102' },
        { ...mockVilla, id: 'villa-3', villaNumber: 'V-103' },
      ] as Villa[];

      villaRepository.find.mockResolvedValue(villas);
      userRepository.find.mockResolvedValue([]);

      // Act
      const result = await service.findAll(mockCompanyId);

      // Assert
      expect(villaRepository.find).toHaveBeenCalledWith({
        where: { companyId: mockCompanyId },
        order: { villaNumber: 'ASC' },
        relations: ['site', 'space'],
      });
      expect(userRepository.find).toHaveBeenCalledWith({
        where: { companyId: mockCompanyId },
        select: [
          'id',
          'villaNumber',
          'villaNumbers',
          'firstName',
          'lastName',
          'phoneNumber',
          'email',
        ],
      });
      expect(result).toEqual(villas);
    });

    it('should ensure occupancy accuracy by checking user assignments', async () => {
      // Arrange
      const villas: Villa[] = [
        { ...mockVilla, id: 'villa-1', villaNumber: 'V-101', isOccupied: false },
      ] as Villa[];

      const users: User[] = [
        {
          id: 'user-1',
          companyId: mockCompanyId,
          villaNumber: 'V-101',
          firstName: 'John',
          lastName: 'Doe',
          phoneNumber: '+971501234567',
          email: 'john@example.com',
        } as User,
      ];

      villaRepository.find.mockResolvedValue(villas);
      userRepository.find.mockResolvedValue(users);

      // Act
      const result = await service.findAll(mockCompanyId);

      // Assert
      expect(result[0].isOccupied).toBe(true);
      expect(result[0].tenantName).toBe('John Doe');
      expect(result[0].contactPhone).toBe('+971501234567');
      expect(result[0].contactEmail).toBe('john@example.com');
    });

    it('should return empty array when no villas exist', async () => {
      // Arrange
      villaRepository.find.mockResolvedValue([]);
      userRepository.find.mockResolvedValue([]);

      // Act
      const result = await service.findAll(mockCompanyId);

      // Assert
      expect(result).toEqual([]);
      expect(userRepository.find).not.toHaveBeenCalled(); // ensureOccupancyAccuracy returns early for empty array
    });

    it('should populate tenant info from primary user when multiple users assigned', async () => {
      // Arrange
      const villas: Villa[] = [
        { ...mockVilla, id: 'villa-1', villaNumber: 'V-101', isOccupied: false },
      ] as Villa[];

      const users: User[] = [
        {
          id: 'user-1',
          companyId: mockCompanyId,
          villaNumber: 'V-101',
          firstName: 'John',
          lastName: 'Doe',
          phoneNumber: '+971501234567',
          email: 'john@example.com',
        },
        {
          id: 'user-2',
          companyId: mockCompanyId,
          villaNumbers: ['V-101'],
          firstName: 'Jane',
          lastName: 'Smith',
          phoneNumber: '+971509876543',
          email: 'jane@example.com',
        },
      ] as User[];

      villaRepository.find.mockResolvedValue(villas);
      userRepository.find.mockResolvedValue(users);

      // Act
      const result = await service.findAll(mockCompanyId);

      // Assert
      // Should use first user (primary tenant)
      expect(result[0].tenantName).toBe('John Doe');
      expect(result[0].contactPhone).toBe('+971501234567');
      expect(result[0].contactEmail).toBe('john@example.com');
    });
  });

  describe('findActive', () => {
    it('should return only active villas ordered by villa number', async () => {
      // Arrange
      const activeVillas: Villa[] = [
        { ...mockVilla, id: 'villa-1', villaNumber: 'V-101', isActive: true },
        { ...mockVilla, id: 'villa-2', villaNumber: 'V-102', isActive: true },
      ] as Villa[];

      villaRepository.find.mockResolvedValue(activeVillas);

      // Act
      const result = await service.findActive(mockCompanyId);

      // Assert
      expect(villaRepository.find).toHaveBeenCalledWith({
        where: { companyId: mockCompanyId, isActive: true },
        order: { villaNumber: 'ASC' },
      });
      expect(result).toEqual(activeVillas);
      expect(result.every((v) => v.isActive)).toBe(true);
    });

    it('should return empty array when no active villas exist', async () => {
      // Arrange
      villaRepository.find.mockResolvedValue([]);

      // Act
      const result = await service.findActive(mockCompanyId);

      // Assert
      expect(result).toEqual([]);
    });
  });

  describe('findAvailable', () => {
    it('should return only available villas (active, not occupied, not assigned)', async () => {
      // Arrange
      // Note: findAvailable filters by isOccupied: false, so only V-101 and V-102 will be returned
      const activeVillas: Villa[] = [
        { ...mockVilla, id: 'villa-1', villaNumber: 'V-101', isActive: true, isOccupied: false },
        { ...mockVilla, id: 'villa-2', villaNumber: 'V-102', isActive: true, isOccupied: false },
      ] as Villa[];

      const users: User[] = [
        { ...mockUser, villaNumber: 'V-101' } as User,
      ];

      villaRepository.find.mockResolvedValue(activeVillas);
      userRepository.find.mockResolvedValue(users);

      // Act
      const result = await service.findAvailable(mockCompanyId);

      // Assert
      expect(villaRepository.find).toHaveBeenCalledWith({
        where: { companyId: mockCompanyId, isActive: true, isOccupied: false },
        order: { villaNumber: 'ASC' },
      });
      expect(userRepository.find).toHaveBeenCalledWith({
        where: { companyId: mockCompanyId },
        select: ['villaNumber', 'villaNumbers'],
      });
      // V-101 is assigned, V-102 is available
      expect(result).toHaveLength(1);
      expect(result[0].villaNumber).toBe('V-102');
    });

    it('should filter out villas assigned via villaNumbers array', async () => {
      // Arrange
      const activeVillas: Villa[] = [
        { ...mockVilla, id: 'villa-1', villaNumber: 'V-101', isActive: true, isOccupied: false },
        { ...mockVilla, id: 'villa-2', villaNumber: 'V-102', isActive: true, isOccupied: false },
      ] as Villa[];

      const users: User[] = [
        { ...mockUser, villaNumbers: ['V-101', 'V-102'] } as User,
      ];

      villaRepository.find.mockResolvedValue(activeVillas);
      userRepository.find.mockResolvedValue(users);

      // Act
      const result = await service.findAvailable(mockCompanyId);

      // Assert
      expect(result).toHaveLength(0); // Both villas are assigned
    });

    it('should return empty array when all villas are assigned', async () => {
      // Arrange
      const activeVillas: Villa[] = [
        { ...mockVilla, id: 'villa-1', villaNumber: 'V-101', isActive: true, isOccupied: false },
      ] as Villa[];

      const users: User[] = [
        { ...mockUser, villaNumber: 'V-101' } as User,
      ];

      villaRepository.find.mockResolvedValue(activeVillas);
      userRepository.find.mockResolvedValue(users);

      // Act
      const result = await service.findAvailable(mockCompanyId);

      // Assert
      expect(result).toEqual([]);
    });

    it('should handle users with both villaNumber and villaNumbers', async () => {
      // Arrange
      const activeVillas: Villa[] = [
        { ...mockVilla, id: 'villa-1', villaNumber: 'V-101', isActive: true, isOccupied: false },
        { ...mockVilla, id: 'villa-2', villaNumber: 'V-102', isActive: true, isOccupied: false },
      ] as Villa[];

      const users: User[] = [
        {
          ...mockUser,
          villaNumber: 'V-101',
          villaNumbers: ['V-102'],
        } as User,
      ];

      villaRepository.find.mockResolvedValue(activeVillas);
      userRepository.find.mockResolvedValue(users);

      // Act
      const result = await service.findAvailable(mockCompanyId);

      // Assert
      expect(result).toEqual([]); // Both villas are assigned
    });
  });

  describe('findOne', () => {
    it('should return villa by ID with relations', async () => {
      // Arrange
      const villa: Villa = {
        ...mockVilla,
        site: { id: 'site-1', name: 'Site 1' } as any,
        space: { id: 'space-1', name: 'Space 1' } as any,
      } as Villa;

      villaRepository.findOne.mockResolvedValue(villa);
      userRepository.find.mockResolvedValue([]);

      // Act
      const result = await service.findOne(mockCompanyId, mockVillaId);

      // Assert
      expect(villaRepository.findOne).toHaveBeenCalledWith({
        where: { companyId: mockCompanyId, id: mockVillaId },
        relations: ['site', 'space'],
      });
      expect(result).toEqual(villa);
    });

    it('should throw NotFoundException when villa does not exist', async () => {
      // Arrange
      villaRepository.findOne.mockResolvedValue(null);

      // Act & Assert
      await expect(service.findOne(mockCompanyId, mockVillaId)).rejects.toThrow(
        NotFoundException,
      );
      await expect(service.findOne(mockCompanyId, mockVillaId)).rejects.toThrow(
        `Villa with ID ${mockVillaId} not found`,
      );
    });

    it('should ensure occupancy accuracy for single villa', async () => {
      // Arrange
      const villa: Villa = {
        ...mockVilla,
        isOccupied: false,
      } as Villa;

      const users: User[] = [
        {
          id: 'user-1',
          companyId: mockCompanyId,
          villaNumber: mockVillaNumber,
          firstName: 'John',
          lastName: 'Doe',
        } as User,
      ];

      villaRepository.findOne.mockResolvedValue(villa);
      userRepository.find.mockResolvedValue(users);

      // Act
      const result = await service.findOne(mockCompanyId, mockVillaId);

      // Assert
      expect(result.isOccupied).toBe(true);
      expect(result.tenantName).toBe('John Doe');
    });
  });

  describe('findByVillaNumber', () => {
    it('should return villa by villa number', async () => {
      // Arrange
      villaRepository.findOne.mockResolvedValue(mockVilla);

      // Act
      const result = await service.findByVillaNumber(mockCompanyId, mockVillaNumber);

      // Assert
      expect(villaRepository.findOne).toHaveBeenCalledWith({
        where: { companyId: mockCompanyId, villaNumber: mockVillaNumber },
      });
      expect(result).toEqual(mockVilla);
    });

    it('should return null when villa does not exist', async () => {
      // Arrange
      villaRepository.findOne.mockResolvedValue(null);

      // Act
      const result = await service.findByVillaNumber(mockCompanyId, 'NON-EXISTENT');

      // Assert
      expect(result).toBeNull();
    });
  });

  describe('update', () => {
    it('should successfully update villa with new data', async () => {
      // Arrange
      const dto: UpdateVillaDto = {
        ownerName: 'Updated Owner',
        contactPhone: '+971509876543',
      };

      const updatedVilla: Villa = {
        ...mockVilla,
        ...dto,
      } as Villa;

      villaRepository.findOne.mockResolvedValue(mockVilla);
      userRepository.find.mockResolvedValue([]);
      villaRepository.findOne.mockResolvedValueOnce(mockVilla); // For findOne
      villaRepository.findOne.mockResolvedValueOnce(null); // For duplicate check
      villaRepository.save.mockResolvedValue(updatedVilla);

      // Act
      const result = await service.update(mockCompanyId, mockVillaId, dto);

      // Assert
      expect(villaRepository.save).toHaveBeenCalledWith(
        expect.objectContaining(dto),
      );
      expect(result).toEqual(updatedVilla);
    });

    it('should throw NotFoundException when villa does not exist', async () => {
      // Arrange
      const dto: UpdateVillaDto = { ownerName: 'Updated Owner' };
      villaRepository.findOne.mockResolvedValue(null);

      // Act & Assert
      await expect(service.update(mockCompanyId, mockVillaId, dto)).rejects.toThrow(
        NotFoundException,
      );
      expect(villaRepository.save).not.toHaveBeenCalled();
    });

    it('should throw ConflictException when updating to duplicate villa number', async () => {
      // Arrange
      const dto: UpdateVillaDto = { villaNumber: 'V-999' };
      const existingVilla: Villa = {
        ...mockVilla,
        villaNumber: 'V-101',
      } as Villa;
      const duplicateVilla: Villa = {
        ...mockVilla,
        id: 'villa-999',
        villaNumber: 'V-999',
      } as Villa;

      // Mock findOne: first call returns existingVilla (for findOne in update), second returns duplicateVilla (for duplicate check)
      villaRepository.findOne
        .mockResolvedValueOnce(existingVilla) // For findOne in update method
        .mockResolvedValueOnce(duplicateVilla); // For duplicate check via findByVillaNumber
      userRepository.find.mockResolvedValue([]); // For ensureOccupancyAccuracy in findOne

      // Act & Assert
      const updatePromise = service.update(mockCompanyId, mockVillaId, dto);
      await expect(updatePromise).rejects.toThrow(ConflictException);
      await expect(updatePromise).rejects.toThrow('Villa number V-999 already exists');
      expect(villaRepository.save).not.toHaveBeenCalled();
    });

    it('should allow updating to same villa number', async () => {
      // Arrange
      const dto: UpdateVillaDto = {
        villaNumber: mockVillaNumber, // Same number
        ownerName: 'Updated Owner',
      };

      const updatedVilla: Villa = {
        ...mockVilla,
        ...dto,
      } as Villa;

      villaRepository.findOne.mockResolvedValue(mockVilla);
      userRepository.find.mockResolvedValue([]);
      villaRepository.save.mockResolvedValue(updatedVilla);

      // Act
      const result = await service.update(mockCompanyId, mockVillaId, dto);

      // Assert
      // Should not check for duplicate when villa number is unchanged
      expect(villaRepository.save).toHaveBeenCalled();
      expect(result).toEqual(updatedVilla);
    });

    it('should update partial fields', async () => {
      // Arrange
      const dto: UpdateVillaDto = {
        isActive: false,
      };

      const updatedVilla: Villa = {
        ...mockVilla,
        isActive: false,
      } as Villa;

      villaRepository.findOne.mockResolvedValue(mockVilla);
      userRepository.find.mockResolvedValue([]);
      villaRepository.save.mockResolvedValue(updatedVilla);

      // Act
      const result = await service.update(mockCompanyId, mockVillaId, dto);

      // Assert
      expect(result.isActive).toBe(false);
    });
  });

  describe('delete', () => {
    it('should successfully delete a villa', async () => {
      // Arrange
      villaRepository.findOne.mockResolvedValue(mockVilla);
      userRepository.find.mockResolvedValue([]);
      villaRepository.remove.mockResolvedValue(mockVilla);

      // Act
      await service.delete(mockCompanyId, mockVillaId);

      // Assert
      expect(villaRepository.findOne).toHaveBeenCalledWith({
        where: { companyId: mockCompanyId, id: mockVillaId },
        relations: ['site', 'space'],
      });
      expect(villaRepository.remove).toHaveBeenCalledWith(mockVilla);
    });

    it('should throw NotFoundException when villa does not exist', async () => {
      // Arrange
      villaRepository.findOne.mockResolvedValue(null);

      // Act & Assert
      await expect(service.delete(mockCompanyId, mockVillaId)).rejects.toThrow(
        NotFoundException,
      );
      expect(villaRepository.remove).not.toHaveBeenCalled();
    });

    it('should handle database errors during deletion', async () => {
      // Arrange
      const dbError = new Error('Database error');
      villaRepository.findOne.mockResolvedValue(mockVilla);
      userRepository.find.mockResolvedValue([]);
      villaRepository.remove.mockRejectedValue(dbError);

      // Act & Assert
      await expect(service.delete(mockCompanyId, mockVillaId)).rejects.toThrow(
        'Database error',
      );
    });
  });

  describe('deactivate', () => {
    it('should successfully deactivate a villa', async () => {
      // Arrange
      const activeVilla: Villa = {
        ...mockVilla,
        isActive: true,
      } as Villa;

      const deactivatedVilla: Villa = {
        ...mockVilla,
        isActive: false,
      } as Villa;

      villaRepository.findOne.mockResolvedValue(activeVilla);
      userRepository.find.mockResolvedValue([]);
      villaRepository.save.mockResolvedValue(deactivatedVilla);

      // Act
      const result = await service.deactivate(mockCompanyId, mockVillaId);

      // Assert
      expect(villaRepository.save).toHaveBeenCalledWith(
        expect.objectContaining({ isActive: false }),
      );
      expect(result.isActive).toBe(false);
    });

    it('should throw NotFoundException when villa does not exist', async () => {
      // Arrange
      villaRepository.findOne.mockResolvedValue(null);

      // Act & Assert
      await expect(service.deactivate(mockCompanyId, mockVillaId)).rejects.toThrow(
        NotFoundException,
      );
      expect(villaRepository.save).not.toHaveBeenCalled();
    });
  });

  describe('activate', () => {
    it('should successfully activate a villa', async () => {
      // Arrange
      const inactiveVilla: Villa = {
        ...mockVilla,
        isActive: false,
      } as Villa;

      const activatedVilla: Villa = {
        ...mockVilla,
        isActive: true,
      } as Villa;

      villaRepository.findOne.mockResolvedValue(inactiveVilla);
      userRepository.find.mockResolvedValue([]);
      villaRepository.save.mockResolvedValue(activatedVilla);

      // Act
      const result = await service.activate(mockCompanyId, mockVillaId);

      // Assert
      expect(villaRepository.save).toHaveBeenCalledWith(
        expect.objectContaining({ isActive: true }),
      );
      expect(result.isActive).toBe(true);
    });

    it('should throw NotFoundException when villa does not exist', async () => {
      // Arrange
      villaRepository.findOne.mockResolvedValue(null);

      // Act & Assert
      await expect(service.activate(mockCompanyId, mockVillaId)).rejects.toThrow(
        NotFoundException,
      );
      expect(villaRepository.save).not.toHaveBeenCalled();
    });
  });

  describe('syncVillaOccupancy', () => {
    it('should mark villa as occupied when user is assigned', async () => {
      // Arrange
      const vacantVilla: Villa = {
        ...mockVilla,
        isOccupied: false,
      } as Villa;

      const users: User[] = [
        { ...mockUser, villaNumber: mockVillaNumber } as User,
      ];

      const mockQueryBuilder = {
        where: jest.fn().mockReturnThis(),
        andWhere: jest.fn().mockReturnThis(),
        getMany: jest.fn().mockResolvedValue([]),
      };

      villaRepository.findOne.mockResolvedValue(vacantVilla);
      userRepository.find.mockResolvedValue(users);
      userRepository.createQueryBuilder = jest.fn(() => mockQueryBuilder as any);
      villaRepository.save.mockResolvedValue({ ...vacantVilla, isOccupied: true });

      // Act
      await service.syncVillaOccupancy(mockCompanyId, mockVillaNumber);

      // Assert
      expect(villaRepository.findOne).toHaveBeenCalledWith({
        where: { companyId: mockCompanyId, villaNumber: mockVillaNumber },
      });
      expect(villaRepository.save).toHaveBeenCalledWith(
        expect.objectContaining({ isOccupied: true }),
      );
    });

    it('should mark villa as vacant when no users are assigned', async () => {
      // Arrange
      const occupiedVilla: Villa = {
        ...mockVilla,
        isOccupied: true,
      } as Villa;

      const mockQueryBuilder = {
        where: jest.fn().mockReturnThis(),
        andWhere: jest.fn().mockReturnThis(),
        getMany: jest.fn().mockResolvedValue([]),
      };

      villaRepository.findOne.mockResolvedValue(occupiedVilla);
      userRepository.find.mockResolvedValue([]);
      userRepository.createQueryBuilder = jest.fn(() => mockQueryBuilder as any);
      villaRepository.save.mockResolvedValue({ ...occupiedVilla, isOccupied: false });

      // Act
      await service.syncVillaOccupancy(mockCompanyId, mockVillaNumber);

      // Assert
      expect(villaRepository.save).toHaveBeenCalledWith(
        expect.objectContaining({ isOccupied: false }),
      );
    });

    it('should not update villa if occupancy status is already correct', async () => {
      // Arrange
      const occupiedVilla: Villa = {
        ...mockVilla,
        isOccupied: true,
      } as Villa;

      const users: User[] = [
        { ...mockUser, villaNumber: mockVillaNumber } as User,
      ];

      const mockQueryBuilder = {
        where: jest.fn().mockReturnThis(),
        andWhere: jest.fn().mockReturnThis(),
        getMany: jest.fn().mockResolvedValue([]),
      };

      villaRepository.findOne.mockResolvedValue(occupiedVilla);
      userRepository.find.mockResolvedValue(users);
      userRepository.createQueryBuilder = jest.fn(() => mockQueryBuilder as any);

      // Act
      await service.syncVillaOccupancy(mockCompanyId, mockVillaNumber);

      // Assert
      expect(villaRepository.save).not.toHaveBeenCalled();
    });

    it('should handle villa not found gracefully', async () => {
      // Arrange
      villaRepository.findOne.mockResolvedValue(null);

      // Act
      await service.syncVillaOccupancy(mockCompanyId, 'NON-EXISTENT');

      // Assert
      expect(userRepository.find).not.toHaveBeenCalled();
      expect(villaRepository.save).not.toHaveBeenCalled();
    });

    it('should check villaNumbers JSONB array for assignments', async () => {
      // Arrange
      const vacantVilla: Villa = {
        ...mockVilla,
        isOccupied: false,
      } as Villa;

      const users: User[] = [
        { ...mockUser, villaNumbers: [mockVillaNumber] } as User,
      ];

      const mockQueryBuilder = {
        where: jest.fn().mockReturnThis(),
        andWhere: jest.fn().mockReturnThis(),
        getMany: jest.fn().mockResolvedValue(users),
      };

      villaRepository.findOne.mockResolvedValue(vacantVilla);
      userRepository.find.mockResolvedValue([]);
      userRepository.createQueryBuilder = jest.fn(() => mockQueryBuilder as any);
      villaRepository.save.mockResolvedValue({ ...vacantVilla, isOccupied: true });

      // Act
      await service.syncVillaOccupancy(mockCompanyId, mockVillaNumber);

      // Assert
      expect(mockQueryBuilder.where).toHaveBeenCalledWith(
        'user.companyId = :companyId',
        { companyId: mockCompanyId },
      );
      expect(mockQueryBuilder.andWhere).toHaveBeenCalledWith(
        'user.villaNumbers @> :villaNumber',
        { villaNumber: JSON.stringify([mockVillaNumber]) },
      );
      expect(villaRepository.save).toHaveBeenCalledWith(
        expect.objectContaining({ isOccupied: true }),
      );
    });
  });

  describe('syncAllVillaOccupancy', () => {
    it('should sync occupancy for all villas in company', async () => {
      // Arrange
      const villas: Villa[] = [
        { ...mockVilla, id: 'villa-1', villaNumber: 'V-101', isOccupied: false },
        { ...mockVilla, id: 'villa-2', villaNumber: 'V-102', isOccupied: false },
        { ...mockVilla, id: 'villa-3', villaNumber: 'V-103', isOccupied: false },
      ] as Villa[];

      const users: User[] = [
        { ...mockUser, id: 'user-1', villaNumber: 'V-101' } as User,
        { ...mockUser, id: 'user-2', villaNumbers: ['V-103'] } as User,
      ];

      villaRepository.find.mockResolvedValue(villas);
      userRepository.find.mockResolvedValue(users);
      villaRepository.save.mockResolvedValue(mockVilla);

      // Act
      const result = await service.syncAllVillaOccupancy(mockCompanyId);

      // Assert
      expect(result.total).toBe(3);
      expect(result.updated).toBe(2); // V-101 and V-103 need updates (false -> true), V-102 stays false
      expect(result.errors).toBe(0);
      expect(villaRepository.save).toHaveBeenCalledTimes(2);
    });

    it('should handle errors during sync gracefully', async () => {
      // Arrange
      const villas: Villa[] = [
        { ...mockVilla, id: 'villa-1', villaNumber: 'V-101', isOccupied: false },
        { ...mockVilla, id: 'villa-2', villaNumber: 'V-102', isOccupied: false },
      ] as Villa[];

      const users: User[] = [
        { ...mockUser, villaNumber: 'V-101' } as User,
        { ...mockUser, id: 'user-2', villaNumber: 'V-102' } as User, // V-102 also needs update
      ];

      const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation();

      villaRepository.find.mockResolvedValue(villas);
      userRepository.find.mockResolvedValue(users);
      // First save succeeds, second save fails
      villaRepository.save
        .mockResolvedValueOnce({ ...villas[0], isOccupied: true })
        .mockRejectedValueOnce(new Error('Database error'));

      // Act
      const result = await service.syncAllVillaOccupancy(mockCompanyId);

      // Assert
      expect(result.total).toBe(2);
      expect(result.updated).toBe(1); // V-101 updated successfully
      expect(result.errors).toBe(1); // V-102 save failed
      expect(consoleErrorSpy).toHaveBeenCalled();
      consoleErrorSpy.mockRestore();
    });

    it('should return zero updates when all villas are in sync', async () => {
      // Arrange
      const villas: Villa[] = [
        { ...mockVilla, id: 'villa-1', villaNumber: 'V-101', isOccupied: true },
        { ...mockVilla, id: 'villa-2', villaNumber: 'V-102', isOccupied: false },
      ] as Villa[];

      const users: User[] = [
        { ...mockUser, villaNumber: 'V-101' } as User,
      ];

      villaRepository.find.mockResolvedValue(villas);
      userRepository.find.mockResolvedValue(users);

      // Act
      const result = await service.syncAllVillaOccupancy(mockCompanyId);

      // Assert
      expect(result.total).toBe(2);
      expect(result.updated).toBe(0);
      expect(result.errors).toBe(0);
      expect(villaRepository.save).not.toHaveBeenCalled();
    });

    it('should handle empty villa list', async () => {
      // Arrange
      villaRepository.find.mockResolvedValue([]);
      userRepository.find.mockResolvedValue([]);

      // Act
      const result = await service.syncAllVillaOccupancy(mockCompanyId);

      // Assert
      expect(result.total).toBe(0);
      expect(result.updated).toBe(0);
      expect(result.errors).toBe(0);
    });

    it('should handle users with both villaNumber and villaNumbers', async () => {
      // Arrange
      const villas: Villa[] = [
        { ...mockVilla, id: 'villa-1', villaNumber: 'V-101', isOccupied: false },
        { ...mockVilla, id: 'villa-2', villaNumber: 'V-102', isOccupied: false },
      ] as Villa[];

      const users: User[] = [
        {
          ...mockUser,
          villaNumber: 'V-101',
          villaNumbers: ['V-102'],
        } as User,
      ];

      villaRepository.find.mockResolvedValue(villas);
      userRepository.find.mockResolvedValue(users);
      villaRepository.save.mockResolvedValue(mockVilla);

      // Act
      const result = await service.syncAllVillaOccupancy(mockCompanyId);

      // Assert
      expect(result.updated).toBe(2); // Both villas should be marked as occupied
    });
  });
});
