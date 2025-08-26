/*
  # Ajouter la colonne fichiers à la table projets

  1. Modifications
    - Ajouter la colonne `fichiers` de type jsonb à la table `projets`
    - Valeur par défaut : tableau JSON vide `[]`
    - Permet de stocker les fichiers directement dans le projet

  2. Notes
    - Cette colonne stockera un tableau d'objets JSON contenant les informations des fichiers
    - Chaque fichier aura : nom, type, url
    - Remplace l'utilisation de la table séparée `fichiers_projets`
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'projets' AND column_name = 'fichiers'
  ) THEN
    ALTER TABLE projets ADD COLUMN fichiers jsonb DEFAULT '[]'::jsonb;
  END IF;
END $$;