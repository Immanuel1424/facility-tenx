"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.UserService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const bcrypt = __importStar(require("bcrypt"));
const user_entity_1 = require("../entities/user.entity");
const user_role_entity_1 = require("../entities/user-role.entity");
const role_entity_1 = require("../entities/role.entity");
const villa_service_1 = require("../../tenant/villa.service");
let UserService = class UserService {
    constructor(userRepository, userRoleRepository, roleRepository, villaService) {
        this.userRepository = userRepository;
        this.userRoleRepository = userRoleRepository;
        this.roleRepository = roleRepository;
        this.villaService = villaService;
    }
    async findByEmail(companyId, email) {
        return this.userRepository.findOne({
            where: { companyId, email },
            relations: ['userRoles', 'userRoles.role'],
        });
    }
    async findById(companyId, userId) {
        return this.userRepository.findOne({
            where: { companyId, id: userId },
            relations: ['userRoles', 'userRoles.role'],
        });
    }
    async findByIdWithoutCompany(userId) {
        return this.userRepository.findOne({
            where: { id: userId },
            relations: ['userRoles', 'userRoles.role'],
        });
    }
    async findByExternalId(companyId, externalId, provider) {
        return this.userRepository.findOne({
            where: { companyId, externalId, authProvider: provider },
            relations: ['userRoles', 'userRoles.role'],
        });
    }
    async validatePassword(password, hash) {
        return bcrypt.compare(password, hash);
    }
    async createLocalUser(companyId, email, password, firstName, lastName, villaNumber, villaNumbers, status, metadata) {
        const existing = await this.findByEmail(companyId, email);
        if (existing) {
            throw new common_1.BadRequestException('User with this email already exists');
        }
        let allVillaNumbers = [];
        if (villaNumbers && villaNumbers.length > 0) {
            allVillaNumbers = [...villaNumbers];
        }
        else if (villaNumber) {
            allVillaNumbers = [villaNumber];
        }
        allVillaNumbers = [...new Set(allVillaNumbers)];
        const primaryVillaNumber = allVillaNumbers.length > 0 ? allVillaNumbers[0] : null;
        if (primaryVillaNumber) {
            const existingVilla = await this.userRepository.findOne({
                where: { companyId, villaNumber: primaryVillaNumber },
            });
            if (existingVilla) {
                throw new common_1.BadRequestException(`Villa number ${primaryVillaNumber} is already assigned to another user`);
            }
        }
        const passwordHash = await bcrypt.hash(password, 10);
        const user = this.userRepository.create({
            companyId,
            email,
            passwordHash,
            firstName,
            lastName,
            villaNumber: primaryVillaNumber ?? undefined,
            villaNumbers: allVillaNumbers.length > 0 ? allVillaNumbers : undefined,
            status: status ?? user_entity_1.UserStatus.ACTIVE,
            authProvider: user_entity_1.AuthProvider.LOCAL,
            providerMetadata: metadata && Object.keys(metadata).length > 0 ? metadata : undefined,
        });
        const savedUser = await this.userRepository.save(user);
        if (primaryVillaNumber) {
            await this.syncVillaOccupancy(companyId, primaryVillaNumber, true);
        }
        return savedUser;
    }
    async createOrUpdateOidcUser(companyId, externalId, provider, email, metadata) {
        let user = await this.findByExternalId(companyId, externalId, provider);
        if (user) {
            user.email = email;
            user.firstName = metadata.firstName || user.firstName;
            user.lastName = metadata.lastName || user.lastName;
            user.providerMetadata = metadata;
            user.lastLoginAt = new Date();
            return this.userRepository.save(user);
        }
        user = this.userRepository.create({
            companyId,
            email,
            externalId,
            authProvider: provider,
            firstName: metadata.firstName,
            lastName: metadata.lastName,
            providerMetadata: metadata,
            status: user_entity_1.UserStatus.ACTIVE,
            lastLoginAt: new Date(),
        });
        return this.userRepository.save(user);
    }
    async assignRole(companyId, userId, roleId) {
        const role = await this.roleRepository.findOne({
            where: { companyId, id: roleId },
        });
        if (!role) {
            throw new common_1.NotFoundException(`Role ${roleId} not found`);
        }
        const existing = await this.userRoleRepository.findOne({
            where: { companyId, userId, roleId },
        });
        if (existing) {
            return existing;
        }
        const userRole = this.userRoleRepository.create({
            companyId,
            userId,
            roleId,
        });
        return this.userRoleRepository.save(userRole);
    }
    async getUserRoles(companyId, userId) {
        const userRoles = await this.userRoleRepository.find({
            where: { companyId, userId },
            relations: ['role'],
        });
        return userRoles.map((ur) => ur.role);
    }
    async updateLastLogin(companyId, userId) {
        await this.userRepository.update({ companyId, id: userId }, { lastLoginAt: new Date() });
    }
    async findTechnicians(companyId, siteId) {
        const queryBuilder = this.userRepository
            .createQueryBuilder('user')
            .leftJoinAndSelect('user.userRoles', 'userRole')
            .leftJoinAndSelect('userRole.role', 'role')
            .where('user.companyId = :companyId', { companyId })
            .andWhere('user.status = :status', { status: user_entity_1.UserStatus.ACTIVE })
            .andWhere("(role.name ILIKE :technicianRole OR role.name ILIKE :maintenanceRole OR role.name ILIKE :staffRole)", {
            technicianRole: '%TECHNICIAN%',
            maintenanceRole: '%MAINTENANCE%',
            staffRole: '%STAFF%',
        });
        return queryBuilder
            .orderBy('user.firstName', 'ASC')
            .addOrderBy('user.lastName', 'ASC')
            .getMany();
    }
    async findAdmins(companyId) {
        const queryBuilder = this.userRepository
            .createQueryBuilder('user')
            .leftJoinAndSelect('user.userRoles', 'userRole')
            .leftJoinAndSelect('userRole.role', 'role')
            .where('user.companyId = :companyId', { companyId })
            .andWhere('user.status = :status', { status: user_entity_1.UserStatus.ACTIVE })
            .andWhere('user.deleted_at IS NULL')
            .andWhere('role.name = :adminRole', { adminRole: 'ADMIN' });
        return queryBuilder
            .orderBy('user.firstName', 'ASC')
            .addOrderBy('user.lastName', 'ASC')
            .getMany();
    }
    async findAll(companyId, filters) {
        const queryBuilder = this.userRepository
            .createQueryBuilder('user')
            .leftJoinAndSelect('user.userRoles', 'userRole')
            .leftJoinAndSelect('userRole.role', 'role');
        if (companyId) {
            queryBuilder.where('user.companyId = :companyId', { companyId });
        }
        queryBuilder.andWhere('user.deleted_at IS NULL');
        if (filters?.status) {
            queryBuilder.andWhere('user.status = :status', {
                status: filters.status,
            });
        }
        if (filters?.role) {
            queryBuilder.andWhere('role.name = :roleName', {
                roleName: filters.role,
            });
        }
        return queryBuilder
            .orderBy('user.createdAt', 'DESC')
            .getMany();
    }
    async update(companyId, userId, userData) {
        const user = await this.findById(companyId, userId);
        if (!user) {
            throw new common_1.NotFoundException('User not found');
        }
        if (userData.email && userData.email !== user.email) {
            const existing = await this.findByEmail(companyId, userData.email);
            if (existing) {
                throw new common_1.BadRequestException('User with this email already exists');
            }
        }
        const oldVillaNumber = user.villaNumber;
        if (userData.villaNumber !== undefined &&
            userData.villaNumber !== user.villaNumber) {
            const existingVilla = await this.userRepository.findOne({
                where: { companyId, villaNumber: userData.villaNumber },
            });
            if (existingVilla && existingVilla.id !== userId) {
                throw new common_1.BadRequestException(`Villa number ${userData.villaNumber} is already assigned to another user`);
            }
        }
        Object.assign(user, userData);
        const savedUser = await this.userRepository.save(user);
        const newVillaNumber = user.villaNumber;
        if (oldVillaNumber !== newVillaNumber) {
            if (oldVillaNumber) {
                await this.syncVillaOccupancy(companyId, oldVillaNumber, false);
            }
            if (newVillaNumber) {
                await this.syncVillaOccupancy(companyId, newVillaNumber, true);
            }
        }
        return savedUser;
    }
    async activate(companyId, userId) {
        const user = await this.findById(companyId, userId);
        if (!user) {
            throw new common_1.NotFoundException('User not found');
        }
        user.status = user_entity_1.UserStatus.ACTIVE;
        return this.userRepository.save(user);
    }
    async deactivate(companyId, userId) {
        const user = await this.findById(companyId, userId);
        if (!user) {
            throw new common_1.NotFoundException('User not found');
        }
        user.status = user_entity_1.UserStatus.INACTIVE;
        return this.userRepository.save(user);
    }
    async delete(companyId, userId) {
        const user = await this.findById(companyId, userId);
        if (!user) {
            throw new common_1.NotFoundException('User not found');
        }
        const villaNumber = user.villaNumber;
        user.status = user_entity_1.UserStatus.INACTIVE;
        user.deletedAt = new Date();
        const savedUser = await this.userRepository.save(user);
        if (villaNumber) {
            await this.syncVillaOccupancy(companyId, villaNumber, false);
        }
        return savedUser;
    }
    async resetPassword(companyId, userId, newPassword) {
        const user = await this.findById(companyId, userId);
        if (!user) {
            throw new common_1.NotFoundException('User not found');
        }
        const passwordHash = await bcrypt.hash(newPassword, 10);
        user.passwordHash = passwordHash;
        await this.userRepository.save(user);
    }
    async changePassword(companyId, userId, currentPassword, newPassword) {
        const user = await this.findById(companyId, userId);
        if (!user) {
            throw new common_1.NotFoundException('User not found');
        }
        if (user.authProvider !== user_entity_1.AuthProvider.LOCAL) {
            throw new common_1.BadRequestException('Password change is only allowed for local accounts');
        }
        const isMatch = await bcrypt.compare(currentPassword, user.passwordHash || '');
        if (!isMatch) {
            throw new common_1.BadRequestException('Current password is incorrect');
        }
        const passwordHash = await bcrypt.hash(newPassword, 10);
        user.passwordHash = passwordHash;
        await this.userRepository.save(user);
    }
    async removeRole(companyId, userId, roleId) {
        const userRole = await this.userRoleRepository.findOne({
            where: { companyId, userId, roleId },
        });
        if (userRole) {
            await this.userRoleRepository.remove(userRole);
        }
    }
    async removeAllRoles(companyId, userId) {
        const userRoles = await this.userRoleRepository.find({
            where: { companyId, userId },
        });
        if (userRoles.length > 0) {
            await this.userRoleRepository.remove(userRoles);
        }
    }
    async assignDepartment(companyId, userId, departmentId) {
        const user = await this.findById(companyId, userId);
        if (!user) {
            throw new common_1.NotFoundException('User not found');
        }
        user.departmentId = departmentId;
        await this.userRepository.save(user);
    }
    async removeDepartment(companyId, userId) {
        const user = await this.findById(companyId, userId);
        if (!user) {
            throw new common_1.NotFoundException('User not found');
        }
        user.departmentId = undefined;
        await this.userRepository.save(user);
    }
    parseUserStatus(status) {
        if (!status)
            return undefined;
        const statusUpper = status.toUpperCase();
        if (Object.values(user_entity_1.UserStatus).includes(statusUpper)) {
            return statusUpper;
        }
        return undefined;
    }
    buildUserMetadata(dto) {
        const metadata = {};
        if (dto.employeeId)
            metadata.employeeId = dto.employeeId;
        if (dto.designation)
            metadata.designation = dto.designation;
        if (dto.joiningDate)
            metadata.joiningDate = dto.joiningDate;
        if (dto.emergencyContactName)
            metadata.emergencyContactName = dto.emergencyContactName;
        if (dto.emergencyContactPhone)
            metadata.emergencyContactPhone = dto.emergencyContactPhone;
        if (dto.notes)
            metadata.notes = dto.notes;
        return Object.keys(metadata).length > 0 ? metadata : undefined;
    }
    async getUserVillas(companyId, userId) {
        const rawVillas = await this.userRepository.query(`
        SELECT DISTINCT v.id,
               v.villa_number,
               v.villa_code,
               v.tenant_name AS name
        FROM user_villas uv
        JOIN villas v
          ON v.id = uv.villa_id
         AND v.company_id = uv.company_id
        WHERE uv.company_id = $1
          AND uv.user_id = $2
      `, [companyId, userId]);
        return rawVillas.map((v) => ({
            id: v.id,
            villaNumber: v.villa_number,
            villaCode: v.villa_code,
            name: v.name,
        }));
    }
    async getUserWithVillas(companyId, userId) {
        const user = await this.findById(companyId, userId);
        if (!user) {
            throw new common_1.NotFoundException('User not found');
        }
        const villas = await this.getUserVillas(companyId, userId);
        return {
            ...user,
            villas: villas.length > 0 ? villas : undefined,
        };
    }
    normalizeVillaNumbers(villaNumber, villaNumbers) {
        let allVillaNumbers = [];
        if (villaNumbers && villaNumbers.length > 0) {
            allVillaNumbers = [...villaNumbers];
        }
        else if (villaNumber) {
            allVillaNumbers = [villaNumber];
        }
        return [...new Set(allVillaNumbers)];
    }
    async createUserFromDto(companyId, dto) {
        const userStatus = this.parseUserStatus(dto.status);
        const metadata = this.buildUserMetadata({
            employeeId: dto.employeeId,
            designation: dto.designation,
            joiningDate: dto.joiningDate,
            emergencyContactName: dto.emergencyContactName,
            emergencyContactPhone: dto.emergencyContactPhone,
            notes: dto.notes,
        });
        const user = await this.createLocalUser(companyId, dto.email, dto.password, dto.firstName, dto.lastName, dto.villaNumber, dto.villaNumbers, userStatus, metadata);
        if (dto.roleId) {
            await this.assignRole(companyId, user.id, dto.roleId);
        }
        if (dto.departmentId) {
            await this.assignDepartment(companyId, user.id, dto.departmentId);
        }
        return user;
    }
    async updateUserFromDto(companyId, userId, dto) {
        const user = await this.findById(companyId, userId);
        if (!user) {
            throw new common_1.NotFoundException('User not found');
        }
        if (dto.email !== undefined)
            user.email = dto.email;
        if (dto.firstName !== undefined)
            user.firstName = dto.firstName;
        if (dto.lastName !== undefined)
            user.lastName = dto.lastName;
        if (dto.status !== undefined)
            user.status = dto.status;
        if (dto.villaNumbers !== undefined || dto.villaNumber !== undefined) {
            const allVillaNumbers = this.normalizeVillaNumbers(dto.villaNumber, dto.villaNumbers);
            const primaryVillaNumber = allVillaNumbers.length > 0 ? allVillaNumbers[0] : null;
            user.villaNumber = primaryVillaNumber ?? undefined;
            user.villaNumbers = allVillaNumbers.length > 0 ? allVillaNumbers : undefined;
        }
        await this.update(companyId, userId, user);
        if (dto.roleId !== undefined) {
            await this.removeAllRoles(companyId, userId);
            if (dto.roleId) {
                await this.assignRole(companyId, userId, dto.roleId);
            }
        }
        if (dto.departmentId !== undefined) {
            if (dto.departmentId) {
                await this.assignDepartment(companyId, userId, dto.departmentId);
            }
            else {
                await this.removeDepartment(companyId, userId);
            }
        }
        return this.findById(companyId, userId);
    }
    async getAllowedVillaNumbers(companyId, userId) {
        const user = await this.findById(companyId, userId);
        if (!user) {
            return [];
        }
        const rows = await this.userRepository.query(`
        SELECT DISTINCT v.villa_number AS "villaNumber"
        FROM user_villas uv
        JOIN villas v
          ON v.id = uv.villa_id
         AND v.company_id = uv.company_id
        WHERE uv.company_id = $1
          AND uv.user_id = $2
      `, [companyId, userId]);
        const dbNumbers = rows
            .map((row) => row.villaNumber)
            .filter((value) => value !== null && value !== undefined);
        const allNumbers = new Set(dbNumbers);
        if (user.villaNumbers && Array.isArray(user.villaNumbers)) {
            user.villaNumbers.forEach((n) => {
                if (n != null && n !== '') {
                    allNumbers.add(String(n));
                }
            });
        }
        if (user.villaNumber != null && user.villaNumber !== '') {
            allNumbers.add(String(user.villaNumber));
        }
        return Array.from(allNumbers);
    }
    async syncVillaOccupancy(companyId, villaNumber, isOccupied) {
        try {
            const villa = await this.villaService.findByVillaNumber(companyId, villaNumber);
            if (villa && villa.isOccupied !== isOccupied) {
                await this.villaService.update(companyId, villa.id, { isOccupied });
            }
        }
        catch (error) {
            console.error(`Failed to sync villa occupancy for villa ${villaNumber}:`, error);
        }
    }
};
exports.UserService = UserService;
exports.UserService = UserService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(user_entity_1.User)),
    __param(1, (0, typeorm_1.InjectRepository)(user_role_entity_1.UserRole)),
    __param(2, (0, typeorm_1.InjectRepository)(role_entity_1.Role)),
    __param(3, (0, common_1.Inject)((0, common_1.forwardRef)(() => villa_service_1.VillaService))),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        villa_service_1.VillaService])
], UserService);
