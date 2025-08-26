/*
  # Portfolio vide pour nouveaux utilisateurs

  1. Modifications
    - Mise à jour du trigger pour créer un profil vide
    - Aucune donnée par défaut ajoutée
    - Formation par défaut mise à jour

  2. Sécurité
    - Maintien des politiques RLS existantes
*/

-- Mise à jour de la fonction de création de profil
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, formation, annee_etudes, onboarding_completed)
  VALUES (
    new.id,
    new.email,
    COALESCE(new.raw_user_meta_data->>'full_name', ''),
    'Exemple de BUT + Parcours',
    '3',
    false
  );
  
  -- Aucune compétence, projet ou apprentissage par défaut
  -- Le portfolio reste complètement vide
  
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Mise à jour du trigger si il existe déjà
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE handle_new_user();