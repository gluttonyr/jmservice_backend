import { Column, Entity, Unique } from 'typeorm';
import { BaseEntity } from '../../common/base.entity';

@Entity('parametres')
@Unique(['code'])
export class Parametre extends BaseEntity {
  @Column()
  code!: string;

  @Column()
  libelle!: string;

  @Column('float')
  valeur!: number;

  // Text value for parameters that are not numbers (e.g. CODE_PROMO). Null for numeric ones.
  @Column({ name: 'valeur_texte', type: 'text', nullable: true })
  valeurTexte?: string | null;
}
