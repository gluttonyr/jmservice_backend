import { Body, Controller, Delete, Get, Param, Post, Put, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { AdminGuard } from '../auth/admin.guard';
import { ApiResponse } from '../common/api-response.interface';
import { BookmakerService } from './bookmaker.service';
import { CreateBookmakerDto, UpdateBookmakerDto } from './dto/bookmaker.dto';

@Controller('bookmakers')
@UseGuards(AuthGuard('jwt'))
export class BookmakerController {
  constructor(private readonly bookmakerService: BookmakerService) {}

  @Get()
  async findVisible(): Promise<ApiResponse> {
    const bookmakers = await this.bookmakerService.findVisible();
    return { data: bookmakers.map((b) => this.bookmakerService.toResponse(b)), message: 'Liste des bookmakers', status: 200 };
  }

  @UseGuards(AdminGuard)
  @Get('admin')
  async findAll(): Promise<ApiResponse> {
    const bookmakers = await this.bookmakerService.findAll();
    return { data: bookmakers.map((b) => this.bookmakerService.toResponse(b)), message: 'Liste des bookmakers', status: 200 };
  }

  @UseGuards(AdminGuard)
  @Post()
  async create(@Body() body: CreateBookmakerDto): Promise<ApiResponse> {
    const bookmaker = await this.bookmakerService.create(body);
    return { data: this.bookmakerService.toResponse(bookmaker), message: 'Bookmaker créé', status: 201 };
  }

  @UseGuards(AdminGuard)
  @Put(':id')
  async update(@Param('id') id: string, @Body() body: UpdateBookmakerDto): Promise<ApiResponse> {
    const bookmaker = await this.bookmakerService.update(id, body);
    return { data: this.bookmakerService.toResponse(bookmaker), message: 'Bookmaker mis à jour', status: 200 };
  }

  @UseGuards(AdminGuard)
  @Delete(':id')
  async remove(@Param('id') id: string): Promise<ApiResponse> {
    await this.bookmakerService.remove(id);
    return { data: null, message: 'Bookmaker supprimé', status: 200 };
  }
}
