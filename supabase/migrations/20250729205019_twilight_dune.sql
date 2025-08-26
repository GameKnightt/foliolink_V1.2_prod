/*
  # Ajouter la colonne preuves à la table apprentissages

  1. Modifications
    - Ajouter la colonne `preuves` de type jsonb à la table `apprentissages`
    - Valeur par défaut : tableau JSON vide `[]`
    - Permet de stocker les preuves directement dans l'apprentissage

  2. Notes
    - Cette colonne stockera un tableau d'objets JSON contenant les informations des preuves
    - Chaque preuve aura : titre, type, url, projet_id (optionnel)
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'apprentissages' AND column_name = 'preuves'
  ) THEN
    ALTER TABLE apprentissages ADD COLUMN preuves jsonb DEFAULT '[]'::jsonb;
  END IF;
END $$;