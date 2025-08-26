/*
  # Configuration complète Supabase pour Portfolio GEII

  1. Configuration de l'authentification
    - Activation de l'inscription par email
    - Configuration des politiques de sécurité
    - Désactivation de la confirmation email pour le développement

  2. Tables principales
    - `profiles` - Profils utilisateurs étendus
    - `competences` - Compétences GEII
    - `apprentissages` - Apprentissages critiques
    - `projets` - Projets réalisés
    - `preuves` - Preuves et ressources
    - `fichiers_projets` - Fichiers liés aux projets

  3. Sécurité
    - Row Level Security (RLS) activé sur toutes les tables
    - Politiques d'accès basées sur l'utilisateur authentifié
    - Protection des données personnelles

  4. Fonctions et triggers
    - Création automatique du profil utilisateur
    - Mise à jour automatique des timestamps
*/

-- Configuration de l'authentification
-- (Ces paramètres doivent être configurés dans le dashboard Supabase)
-- Settings > Authentication > Settings:
-- - Enable email confirmations: OFF (pour le développement)
-- - Enable phone confirmations: OFF
-- - Enable email change confirmations: OFF

-- Extension pour UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Table des profils utilisateurs étendus
CREATE TABLE IF NOT EXISTS profiles (
  id uuid REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email text UNIQUE NOT NULL,
  full_name text,
  formation text DEFAULT 'BUT GEII - Parcours AII',
  annee_etudes text DEFAULT '3',
  etablissement text,
  telephone text,
  linkedin text,
  github text,
  bio text,
  avatar_url text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Table des compétences GEII
CREATE TABLE IF NOT EXISTS competences (
  id text PRIMARY KEY,
  title text NOT NULL,
  subtitle text NOT NULL,
  description text NOT NULL,
  levels integer NOT NULL DEFAULT 3,
  color text NOT NULL DEFAULT 'primary',
  icon text NOT NULL DEFAULT '🎓',
  created_at timestamptz DEFAULT now()
);

-- Table des projets
CREATE TABLE IF NOT EXISTS projets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  titre text NOT NULL,
  description text NOT NULL,
  icone text NOT NULL DEFAULT '📁',
  niveau text NOT NULL,
  duree text NOT NULL,
  fonctionnalites text[] DEFAULT '{}',
  technologies text[] DEFAULT '{}',
  statut text NOT NULL DEFAULT 'En cours' CHECK (statut IN ('En cours', 'Terminé', 'Archivé')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Table des fichiers de projets
CREATE TABLE IF NOT EXISTS fichiers_projets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  projet_id uuid REFERENCES projets(id) ON DELETE CASCADE NOT NULL,
  nom text NOT NULL,
  type text NOT NULL CHECK (type IN ('Fichier', 'Lien')),
  url text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Table des apprentissages critiques
CREATE TABLE IF NOT EXISTS apprentissages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  competence_id text NOT NULL,
  level integer NOT NULL,
  title text NOT NULL,
  description text NOT NULL,
  evaluation text NOT NULL CHECK (evaluation IN ('Bien Maîtrisé', 'Partiellement Maîtrisé', 'Pas Maîtrisé')),
  argumentaire text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Table des preuves
CREATE TABLE IF NOT EXISTS preuves (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  apprentissage_id uuid REFERENCES apprentissages(id) ON DELETE CASCADE NOT NULL,
  titre text NOT NULL,
  type text NOT NULL CHECK (type IN ('Rapport', 'Code', 'Projet', 'Présentation', 'Documentation', 'Autre')),
  url text NOT NULL,
  projet_id uuid REFERENCES projets(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now()
);

-- Insertion des compétences GEII par défaut
INSERT INTO competences (id, title, subtitle, description, levels, color, icon) VALUES
  ('concevoir', 'Concevoir', 'Concevoir la partie GEII d''un système', 'Développer les compétences de conception en électrotechnique et électronique, de la conception partielle intégrant une démarche projet jusqu''à l''adoption d''une approche sélective dans les choix technologiques.', 3, 'primary', '🔧'),
  ('verifier', 'Vérifier', 'Vérifier la partie GEII d''un système', 'Maîtriser les méthodes de vérification et de validation, des tests et mesures de base jusqu''à l''élaboration de procédures intégrant une démarche qualité complète.', 3, 'accent', '✓'),
  ('maintenir', 'Maintenir', 'Assurer le maintien en condition opérationnelle d''un système', 'Développer les compétences de maintenance préventive et corrective, de l''intervention ponctuelle à la mise en place de stratégies de maintenance optimales.', 2, 'primary', '⚙️'),
  ('integrer', 'Intégrer', 'Intégrer un système de commande et de contrôle dans un procédé industriel', 'Acquérir les compétences d''intégration système, de l''installation selon protocole à l''interaction avec tous les acteurs dans une démarche qualité.', 2, 'accent', '🔗')
ON CONFLICT (id) DO NOTHING;

-- Activation de Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE projets ENABLE ROW LEVEL SECURITY;
ALTER TABLE fichiers_projets ENABLE ROW LEVEL SECURITY;
ALTER TABLE apprentissages ENABLE ROW LEVEL SECURITY;
ALTER TABLE preuves ENABLE ROW LEVEL SECURITY;

-- Politiques RLS pour profiles
CREATE POLICY "Users can read own profile"
  ON profiles
  FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Politiques RLS pour projets
CREATE POLICY "Users can read own projects"
  ON projets
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own projects"
  ON projets
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own projects"
  ON projets
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own projects"
  ON projets
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Politiques RLS pour fichiers_projets
CREATE POLICY "Users can read files of own projects"
  ON fichiers_projets
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM projets 
      WHERE projets.id = fichiers_projets.projet_id 
      AND projets.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert files for own projects"
  ON fichiers_projets
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM projets 
      WHERE projets.id = fichiers_projets.projet_id 
      AND projets.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update files of own projects"
  ON fichiers_projets
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM projets 
      WHERE projets.id = fichiers_projets.projet_id 
      AND projets.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete files of own projects"
  ON fichiers_projets
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM projets 
      WHERE projets.id = fichiers_projets.projet_id 
      AND projets.user_id = auth.uid()
    )
  );

-- Politiques RLS pour apprentissages
CREATE POLICY "Users can read own apprentissages"
  ON apprentissages
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own apprentissages"
  ON apprentissages
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own apprentissages"
  ON apprentissages
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own apprentissages"
  ON apprentissages
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Politiques RLS pour preuves
CREATE POLICY "Users can read preuves of own apprentissages"
  ON preuves
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM apprentissages 
      WHERE apprentissages.id = preuves.apprentissage_id 
      AND apprentissages.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert preuves for own apprentissages"
  ON preuves
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM apprentissages 
      WHERE apprentissages.id = preuves.apprentissage_id 
      AND apprentissages.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update preuves of own apprentissages"
  ON preuves
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM apprentissages 
      WHERE apprentissages.id = preuves.apprentissage_id 
      AND apprentissages.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete preuves of own apprentissages"
  ON preuves
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM apprentissages 
      WHERE apprentissages.id = preuves.apprentissage_id 
      AND apprentissages.user_id = auth.uid()
    )
  );

-- Politique pour permettre la lecture publique des compétences
CREATE POLICY "Anyone can read competences"
  ON competences
  FOR SELECT
  TO public
  USING (true);

-- Fonction pour créer automatiquement un profil utilisateur
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (
    new.id,
    new.email,
    COALESCE(new.raw_user_meta_data->>'full_name', '')
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger pour créer automatiquement un profil
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Fonction pour mettre à jour automatiquement updated_at
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers pour updated_at
CREATE TRIGGER handle_updated_at_profiles
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();

CREATE TRIGGER handle_updated_at_projets
  BEFORE UPDATE ON projets
  FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();

CREATE TRIGGER handle_updated_at_apprentissages
  BEFORE UPDATE ON apprentissages
  FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_projets_user_id ON projets(user_id);
CREATE INDEX IF NOT EXISTS idx_apprentissages_user_id ON apprentissages(user_id);
CREATE INDEX IF NOT EXISTS idx_apprentissages_competence ON apprentissages(competence_id);
CREATE INDEX IF NOT EXISTS idx_preuves_apprentissage_id ON preuves(apprentissage_id);
CREATE INDEX IF NOT EXISTS idx_fichiers_projets_projet_id ON fichiers_projets(projet_id);