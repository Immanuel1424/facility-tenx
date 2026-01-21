import {
  IsUUID,
  IsNotEmpty,
} from 'class-validator';
import { Expose } from 'class-transformer';

export class AssignTeamDto {
  @Expose()
  @IsUUID()
  @IsNotEmpty()
  team_id!: string;
}
