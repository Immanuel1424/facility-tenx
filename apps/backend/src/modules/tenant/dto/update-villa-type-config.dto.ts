import { PartialType } from '@nestjs/swagger';
import { CreateVillaTypeConfigDto } from './create-villa-type-config.dto';

export class UpdateVillaTypeConfigDto extends PartialType(CreateVillaTypeConfigDto) {}

