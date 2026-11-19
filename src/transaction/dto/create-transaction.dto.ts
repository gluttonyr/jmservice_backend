import { IsEnum, IsInt, IsOptional, IsString, MaxLength, Min } from 'class-validator';
import { TransactionType } from '../entities/transaction.entity';

export class CreateTransactionDto {
  @IsEnum(TransactionType) type!: TransactionType;
  @IsOptional() @IsInt() @Min(1) montant?: number;
  @IsOptional() @IsString() operateur?: string;
  @IsOptional() @IsString() numeroTelephone?: string;
  @IsOptional() @IsString() compteDestinataire?: string;
  @IsOptional() @IsString() codeRetrait?: string;
  // Sent only by app versions with the bookmaker step; absent = 1XBET.
  @IsOptional() @IsString() @MaxLength(30) bookmaker?: string;
}
