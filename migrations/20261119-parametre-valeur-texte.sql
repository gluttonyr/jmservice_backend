-- Text value for parameters that are not numbers. CODE_PROMO is created empty at startup by ParametreService.
ALTER TABLE parametres
  ADD COLUMN IF NOT EXISTS valeur_texte text;
