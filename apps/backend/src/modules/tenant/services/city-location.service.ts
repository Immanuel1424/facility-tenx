import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { City } from '../entities/city.entity';
import { Location } from '../entities/location.entity';

@Injectable()
export class CityLocationService {
  constructor(
    @InjectRepository(City)
    private readonly cityRepo: Repository<City>,
    @InjectRepository(Location)
    private readonly locationRepo: Repository<Location>,
  ) {}

  async findAllCities(): Promise<City[]> {
    return this.cityRepo.find({
      where: { isActive: true },
      order: { displayOrder: 'ASC', name: 'ASC' },
    });
  }

  async findLocationsByCity(cityId: string): Promise<Location[]> {
    return this.locationRepo.find({
      where: { cityId, isActive: true },
      relations: ['city'],
      order: { displayOrder: 'ASC', name: 'ASC' },
    });
  }

  async findAllLocations(): Promise<Location[]> {
    return this.locationRepo.find({
      where: { isActive: true },
      relations: ['city'],
      order: { displayOrder: 'ASC', name: 'ASC' },
    });
  }
}

