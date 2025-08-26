/*
  # Ajout des colonnes competences aux tables apprentissages et projets

  1. Modifications
    - Ajouter la colonne `competences` (jsonb) à la table `apprentissages`
    - Ajouter la colonne `competences` (jsonb) à la table `projets`
    - Définir des valeurs par défaut pour les nouvelles colonnes

  2. Sécurité
    - Les colonnes sont ajoutées de manière sécurisée avec IF NOT EXISTS
    - Valeurs par défaut définies pour éviter les erreurs
*/

-- Ajouter la colonne competences à la table apprentissages si elle n'existe pas
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'apprentissages' AND column_name = 'competences'
  ) THEN
    ALTER TABLE apprentissages ADD COLUMN competences jsonb DEFAULT '[]'::jsonb;
  END IF;
END $$;

-- Ajouter la colonne competences à la table projets si elle n'existe pas
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'projets' AND column_name = 'competences'
  ) THEN
    ALTER TABLE projets ADD COLUMN competences jsonb DEFAULT '[]'::jsonb;
  END IF;
END $$;