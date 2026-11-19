import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Bookmaker } from './entities/bookmaker.entity';
import { BookmakerService } from './bookmaker.service';
import { BookmakerController } from './bookmaker.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Bookmaker])],
  providers: [BookmakerService],
  controllers: [BookmakerController],
  exports: [BookmakerService],
})
export class BookmakerModule {}
