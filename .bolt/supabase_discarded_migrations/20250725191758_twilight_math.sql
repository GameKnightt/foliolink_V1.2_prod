/*
  # Ajout de données d'exemple pour FolioLink

  1. Données d'exemple
    - Compétences d'exemple pour démonstration
    - Apprentissages critiques d'exemple
    - Projets d'exemple
  
  2. Sécurité
    - Les données d'exemple sont publiques (lecture seule)
    - Séparées des données utilisateur
*/

-- Table pour les compétences d'exemple (lecture seule pour tous)
CREATE TABLE IF NOT EXISTS example_competences (
  id text PRIMARY KEY,
  title text NOT NULL,
  subtitle text NOT NULL,
  description text NOT NULL,
  levels integer NOT NULL DEFAULT 3,
  color text NOT NULL DEFAULT 'primary',
  icon text NOT NULL DEFAULT '🎓',
  created_at timestamptz DEFAULT now()
);

-- Table pour les apprentissages d'exemple
CREATE TABLE IF NOT EXISTS example_apprentissages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  competence_id text NOT NULL,
  level integer NOT NULL,
  title text NOT NULL,
  description text NOT NULL,
  evaluation text NOT NULL CHECK (evaluation = ANY (ARRAY['Bien Maîtrisé'::text, 'Partiellement Maîtrisé'::text, 'Pas Maîtrisé'::text])),
  argumentaire text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Table pour les projets d'exemple
CREATE TABLE IF NOT EXISTS example_projets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  titre text NOT NULL,
  description text NOT NULL,
  icone text NOT NULL DEFAULT '📁',
  niveau text NOT NULL,
  duree text NOT NULL,
  fonctionnalites text[] DEFAULT '{}',
  technologies text[] DEFAULT '{}',
  statut text NOT NULL DEFAULT 'Terminé' CHECK (statut = ANY (ARRAY['En cours'::text, 'Terminé'::text, 'Archivé'::text])),
  created_at timestamptz DEFAULT now()
);

-- Table pour les preuves d'exemple
CREATE TABLE IF NOT EXISTS example_preuves (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  apprentissage_id uuid NOT NULL,
  titre text NOT NULL,
  type text NOT NULL CHECK (type = ANY (ARRAY['Rapport'::text, 'Code'::text, 'Projet'::text, 'Présentation'::text, 'Documentation'::text, 'Autre'::text])),
  url text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Activer RLS sur toutes les tables d'exemple
ALTER TABLE example_competences ENABLE ROW LEVEL SECURITY;
ALTER TABLE example_apprentissages ENABLE ROW LEVEL SECURITY;
ALTER TABLE example_projets ENABLE ROW LEVEL SECURITY;
ALTER TABLE example_preuves ENABLE ROW LEVEL SECURITY;

-- Politiques de lecture publique pour les données d'exemple
CREATE POLICY "Anyone can read example competences"
  ON example_competences
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Anyone can read example apprentissages"
  ON example_apprentissages
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Anyone can read example projets"
  ON example_projets
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Anyone can read example preuves"
  ON example_preuves
  FOR SELECT
  TO public
  USING (true);

-- Insérer les données d'exemple
INSERT INTO example_competences (id, title, subtitle, description, levels, color, icon) VALUES
('concevoir', 'Concevoir', 'Concevoir la partie GEII d''un système', 'Développer les compétences de conception en électrotechnique et électronique, de la conception partielle intégrant une démarche projet jusqu''à l''adoption d''une approche sélective dans les choix technologiques.', 3, 'primary', '🔧'),
('verifier', 'Vérifier', 'Vérifier la partie GEII d''un système', 'Maîtriser les méthodes de vérification et de validation, des tests et mesures de base jusqu''à l''élaboration de procédures intégrant une démarche qualité complète.', 3, 'accent', '✓'),
('maintenir', 'Maintenir', 'Assurer le maintien en condition opérationnelle d''un système', 'Développer les compétences de maintenance préventive et corrective, de l''intervention ponctuelle à la mise en place de stratégies de maintenance optimales.', 2, 'primary', '⚙️'),
('integrer', 'Intégrer', 'Intégrer un système de commande et de contrôle dans un procédé industriel', 'Acquérir les compétences d''intégration système, de l''installation selon protocole à l''interaction avec tous les acteurs dans une démarche qualité.', 2, 'accent', '🔗');

-- Insérer les projets d'exemple
INSERT INTO example_projets (titre, description, icone, niveau, duree, fonctionnalites, technologies, statut) VALUES
('Système de Contrôle Automatisé', 'Conception et développement d''un système de contrôle automatisé pour une ligne de production industrielle.', '🔧', 'Projet de 2ème année', '6 mois', ARRAY['Programmation automate Schneider Electric', 'Interface SCADA avec Wonderware InTouch', 'Communication Modbus TCP/IP', 'Système d''alarmes et de traçabilité'], ARRAY['Automatisme', 'PLC', 'SCADA', 'Supervision'], 'Terminé'),
('Interface de Supervision IoT', 'Développement d''une interface web moderne pour la supervision en temps réel d''équipements industriels connectés.', '📊', 'Projet de 3ème année', '4 mois', ARRAY['Frontend Vue.js avec TypeScript', 'Backend Node.js avec WebSockets', 'Base de données InfluxDB pour les séries temporelles', 'Graphiques interactifs avec Chart.js'], ARRAY['IoT', 'Vue.js', 'Data Viz', 'Real-time'], 'Terminé');

-- Insérer les apprentissages d'exemple
INSERT INTO example_apprentissages (competence_id, level, title, description, evaluation, argumentaire) VALUES
('concevoir', 1, 'Conception d''un circuit électronique analogique', 'Conception et réalisation d''un amplificateur opérationnel dans le cadre du projet de première année.', 'Bien Maîtrisé', 'J''ai réussi à concevoir un amplificateur opérationnel fonctionnel en respectant les spécifications techniques. La simulation SPICE a validé le comportement théorique avant la réalisation pratique.'),
('verifier', 1, 'Tests et mesures sur oscilloscope', 'Réalisation de mesures de signaux analogiques et numériques à l''oscilloscope lors des travaux pratiques.', 'Bien Maîtrisé', 'Maîtrise parfaite de l''oscilloscope numérique : configuration des voies, réglages des bases de temps, mesures automatiques, analyse FFT.'),
('maintenir', 1, 'Maintenance préventive équipement industriel', 'Intervention de maintenance préventive sur un automate programmable industriel lors du stage en entreprise.', 'Partiellement Maîtrisé', 'J''ai participé à plusieurs interventions de maintenance préventive mais toujours sous supervision. Je maîtrise les procédures de sécurité et les étapes de base.'),
('integrer', 1, 'Installation système de supervision SCADA', 'Participation à l''installation et configuration d''un système de supervision industriel.', 'Partiellement Maîtrisé', 'J''ai assisté l''équipe technique dans l''installation du système SCADA. J''ai pu configurer les interfaces de base et établir la communication avec les automates.');

-- Insérer les preuves d'exemple
INSERT INTO example_preuves (apprentissage_id, titre, type, url) 
SELECT 
  ea.id,
  CASE 
    WHEN ea.title LIKE '%circuit%' THEN 'Schéma électronique'
    WHEN ea.title LIKE '%oscilloscope%' THEN 'Captures d''écran oscilloscope'
    WHEN ea.title LIKE '%maintenance%' THEN 'Rapport de stage'
    WHEN ea.title LIKE '%SCADA%' THEN 'Documentation technique'
  END,
  CASE 
    WHEN ea.title LIKE '%circuit%' THEN 'Documentation'
    WHEN ea.title LIKE '%oscilloscope%' THEN 'Documentation'
    WHEN ea.title LIKE '%maintenance%' THEN 'Rapport'
    WHEN ea.title LIKE '%SCADA%' THEN 'Documentation'
  END,
  '#exemple'
FROM example_apprentissages ea;