/*
  # Ajout du statut d'onboarding aux profils utilisateur

  1. Modifications
    - Ajouter la colonne `onboarding_completed` à la table `profiles`
    - Définir la valeur par défaut à `false`
    - Ajouter un commentaire pour documenter la colonne

  2. Sécurité
    - Aucune modification des politiques RLS nécessaire
    - La colonne hérite des politiques existantes de la table `profiles`
*/

-- Ajouter la colonne onboarding_completed à la table profiles
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'onboarding_completed'
  ) THEN
    ALTER TABLE profiles ADD COLUMN onboarding_completed BOOLEAN DEFAULT false;
    COMMENT ON COLUMN profiles.onboarding_completed IS 'Indique si l''utilisateur a terminé ou ignoré l''onboarding';
  END IF;
END $$;