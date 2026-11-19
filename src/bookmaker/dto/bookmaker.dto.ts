import { IsBoolean, IsInt, IsNotEmpty, IsOptional, IsString, Matches, MaxLength } from 'class-validator';

// The integration is deliberately absent: an admin must never route a bookmaker to the 1XBET cash desk.

export class CreateBookmakerDto {
  @IsNotEmpty({ message: 'Le code est requis' })
  @IsString()
  @MaxLength(30)
  @Matches(/^[A-Za-z0-9_-]+$/, { message: 'Le code ne contient que des lettres, des chiffres, - et _' })
  code!: string;

  @IsNotEmpty({ message: 'Le nom est requis' })
  @IsString()
  @MaxLength(100)
  nom!: string;

  @IsOptional() @IsString() @MaxLength(255) imageUrl?: string;
  @IsOptional() @IsBoolean() active?: boolean;
  @IsOptional() @IsInt() ordre?: number;
}

export class UpdateBookmakerDto {
  @IsOptional() @IsString() @IsNotEmpty() @MaxLength(100) nom?: string;
  @IsOptional() @IsString() @MaxLength(255) imageUrl?: string;
  @IsOptional() @IsBoolean() active?: boolean;
  @IsOptional() @IsInt() ordre?: number;
}

export interface BookmakerResponseDto {
  trackingId: string;
  code: string;
  nom: string;
  imageUrl: string | null;
  active: boolean;
  ordre: number;
  /** True when deposits and withdrawals can be made with it; false = shown as "bientôt". */
  disponible: boolean;
}
