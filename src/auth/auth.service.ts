import { Injectable, BadRequestException, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UtilisateurService } from '../utilisateur/utilisateur.service';
import * as bcrypt from 'bcryptjs';
import { UserMapper } from 'src/utilisateur/mappers/user.mapper';
import { User } from 'src/utilisateur/entities/user.entity';
import { normalizeEmail, normalizePhone } from 'src/utilisateur/contact';

@Injectable()
export class AuthService {
  constructor(
    private readonly utilisateurService: UtilisateurService,
    private readonly jwtService: JwtService,
    private readonly utilisateurMapper: UserMapper
  ) { }

  async validateUser(email: string, password: string) {
    const user = await this.utilisateurService.findByEmail(email);
    if (!user) return null;
    const isMatch = await bcrypt.compare(password, user.password || '');
    if (!isMatch) return null;
    return user;
  }

  async getToken(user: { id: number; email: string | null; role?: string }) {
    return {
      access_token: this.jwtService.sign({ sub: user.id, email: user.email, role: user.role }),
    };
  }

  // Sign-in with an email address or a phone number. Installed apps send { email, password };
  // the phone form sends { telephone, password }. A phone number typed in the email field also works.
  async login(body: { email?: string; telephone?: string; password: string }) {
    const emailInput = normalizeEmail(body.email);
    const byPhone = !!normalizePhone(body.telephone) || (!!emailInput && !emailInput.includes('@') && !!normalizePhone(emailInput));
    const password = typeof body.password === 'string' ? body.password : '';
    if (!password || (!emailInput && !byPhone)) {
      throw new BadRequestException('Identifiant et mot de passe requis');
    }

    let user: User | null = null;
    if (byPhone) {
      const candidates = await this.utilisateurService.findActiveByPhone(body.telephone || emailInput || '');
      if (!candidates.length) {
        throw new UnauthorizedException("Aucun compte n'est inscrit avec ce numéro de téléphone");
      }
      for (const candidate of candidates) {
        if (candidate.password && await bcrypt.compare(password, candidate.password)) {
          user = candidate;
          break;
        }
      }
      if (!user) throw new UnauthorizedException('Mot de passe incorrecte');
    } else {
      user = await this.utilisateurService.findByEmail(emailInput as string);
      if (!user) {
        throw new UnauthorizedException("Aucun utilisateur n'est inscrit avec cet email");
      }
      if (!user.password) {
        throw new UnauthorizedException('Mot de passe invalide');
      }
      if (!await bcrypt.compare(password, user.password)) {
        throw new UnauthorizedException('Mot de passe incorrecte');
      }
    }

    // Pas d'expiresIn ici : on garde celui configuré globalement dans
    // AuthModule (JwtModule.registerAsync), lu depuis JWT_EXPIRATION (.env).
    // Un expiresIn explicite ici l'écraserait et ignorerait le .env.
    const token = this.jwtService.sign({
      sub: user.id,
      email: user.email,
      role: user.role,
    });

    return {
      access_token: token,
      user: this.utilisateurMapper.toResponse(user),
    };
  }
}
