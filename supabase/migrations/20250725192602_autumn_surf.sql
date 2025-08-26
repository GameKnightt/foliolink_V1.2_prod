/*
  # Création des tables d'exemple pour FolioLink

  1. Nouvelles Tables
    - `example_competences` - Compétences d'exemple pour la démonstration
    - `example_projets` - Projets d'exemple pour la démonstration  
    - `example_apprentissages` - Apprentissages critiques d'exemple
    - `example_preuves` - Preuves d'exemple liées aux apprentissages
    - `example_fichiers_projets` - Fichiers d'exemple liés aux projets

  2. Sécurité
    - Toutes les tables sont accessibles en lecture publique
    - Pas de RLS car ce sont des données d'exemple publiques

  3. Données d'exemple
    - Insertion de données de démonstration pour BUT GEII
    - Compétences, projets et apprentissages réalistes
*/

-- Table des compétences d'exemple
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

-- Table des projets d'exemple
CREATE TABLE IF NOT EXISTS example_projets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  titre text NOT NULL,
  description text NOT NULL,
  icone text NOT NULL DEFAULT '📁',
  niveau text NOT NULL,
  duree text NOT NULL,
  fonctionnalites text[] DEFAULT '{}',
  technologies text[] DEFAULT '{}',
  statut text NOT NULL DEFAULT 'Terminé',
  created_at timestamptz DEFAULT now()
);

-- Table des apprentissages d'exemple
CREATE TABLE IF NOT EXISTS example_apprentissages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  competence_id text NOT NULL,
  level integer NOT NULL,
  title text NOT NULL,
  description text NOT NULL,
  evaluation text NOT NULL,
  argumentaire text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Table des preuves d'exemple
CREATE TABLE IF NOT EXISTS example_preuves (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  apprentissage_id uuid REFERENCES example_apprentissages(id) ON DELETE CASCADE,
  titre text NOT NULL,
  type text NOT NULL,
  url text NOT NULL,
  projet_id uuid REFERENCES example_projets(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now()
);

-- Table des fichiers de projets d'exemple
CREATE TABLE IF NOT EXISTS example_fichiers_projets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  projet_id uuid REFERENCES example_projets(id) ON DELETE CASCADE,
  nom text NOT NULL,
  type text NOT NULL,
  url text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Insertion des compétences d'exemple
INSERT INTO example_competences (id, title, subtitle, description, levels, color, icon) VALUES
('concevoir', 'Concevoir', 'Concevoir un système automatisé', 'Analyser un cahier des charges, proposer des solutions techniques et concevoir tout ou partie d''un système automatisé.', 3, 'primary', '🎯'),
('verifier', 'Vérifier', 'Vérifier et valider', 'Vérifier la conformité d''un système automatisé aux spécifications et valider son fonctionnement.', 3, 'accent', '✅'),
('integrer', 'Intégrer', 'Intégrer des systèmes', 'Intégrer des équipements automatisés dans un système de production et assurer leur mise en service.', 3, 'primary', '🔧');

-- Insertion des projets d'exemple
INSERT INTO example_projets (titre, description, icone, niveau, duree, fonctionnalites, technologies, statut) VALUES
('Système de Contrôle Automatisé', 'Conception et développement d''un système de contrôle automatisé pour une ligne de production industrielle avec interface SCADA.', '🏭', 'Projet de 2ème année', '6 mois', 
ARRAY['Programmation automate PLC', 'Interface SCADA moderne', 'Communication Modbus TCP/IP', 'Système d''alarmes', 'Traçabilité des événements'], 
ARRAY['Automatisme', 'PLC', 'SCADA', 'Modbus', 'Schneider Electric'], 'Terminé'),

('Interface de Supervision IoT', 'Développement d''une interface web moderne pour la supervision temps réel d''équipements industriels connectés.', '📱', 'Projet de 3ème année', '4 mois',
ARRAY['Interface web responsive', 'Visualisation temps réel', 'Système d''alertes intelligent', 'Architecture scalable', 'API REST sécurisée'],
ARRAY['Vue.js', 'Node.js', 'WebSockets', 'InfluxDB', 'Chart.js'], 'Terminé'),

('Régulation de Température', 'Système de régulation automatique de température avec contrôleur PID et interface utilisateur tactile.', '🌡️', 'Projet de 1ère année', '3 mois',
ARRAY['Contrôleur PID', 'Interface tactile', 'Acquisition de données', 'Régulation automatique', 'Historisation'],
ARRAY['Arduino', 'PID', 'Capteurs', 'Interface HMI', 'C++'], 'Terminé');

-- Insertion des apprentissages d'exemple
INSERT INTO example_apprentissages (competence_id, level, title, description, evaluation, argumentaire) VALUES
('concevoir', 1, 'Analyse de cahier des charges', 'Analyser et interpréter un cahier des charges technique pour identifier les besoins fonctionnels et non-fonctionnels d''un système automatisé.', 'Bien Maîtrisé', 'J''ai développé cette compétence à travers plusieurs projets où j''ai dû analyser des cahiers des charges complexes. Mon approche méthodique me permet d''identifier clairement les contraintes techniques et fonctionnelles.'),

('concevoir', 2, 'Conception d''architecture système', 'Concevoir l''architecture globale d''un système automatisé en définissant les interfaces entre les différents sous-systèmes.', 'Bien Maîtrisé', 'Lors du projet de système de contrôle automatisé, j''ai conçu une architecture modulaire intégrant automates, supervision et communication. Cette approche a facilité la maintenance et les évolutions.'),

('concevoir', 3, 'Optimisation et innovation', 'Proposer des solutions innovantes et optimisées pour améliorer les performances d''un système automatisé existant.', 'Partiellement Maîtrisé', 'J''ai commencé à développer cette compétence en proposant des améliorations sur les projets existants. Je dois encore approfondir mes connaissances en optimisation énergétique et en nouvelles technologies.'),

('verifier', 1, 'Tests unitaires et validation', 'Effectuer des tests unitaires sur les composants d''un système automatisé et valider leur conformité aux spécifications.', 'Bien Maîtrisé', 'J''ai systématiquement appliqué une démarche de tests rigoureux sur tous mes projets. J''utilise des protocoles de test structurés et documente tous les résultats pour assurer la traçabilité.'),

('verifier', 2, 'Tests d''intégration système', 'Valider le fonctionnement global d''un système automatisé par des tests d''intégration complets.', 'Bien Maîtrisé', 'Sur le projet IoT, j''ai mis en place une stratégie de tests d''intégration complète incluant tests de charge, tests de robustesse et validation des interfaces. Tous les tests ont été automatisés.'),

('integrer', 1, 'Installation et câblage', 'Installer et câbler les équipements automatisés selon les schémas techniques et les normes en vigueur.', 'Bien Maîtrisé', 'J''ai acquis une solide expérience en installation d''équipements industriels. Je maîtrise les normes de câblage et de sécurité, et j''ai toujours respecté les délais d''installation sur mes projets.'),

('integrer', 2, 'Configuration et paramétrage', 'Configurer et paramétrer les équipements automatisés pour leur intégration dans le système global.', 'Partiellement Maîtrisé', 'J''ai configuré plusieurs types d''équipements (automates, variateurs, capteurs). Je continue à approfondir mes connaissances sur les protocoles de communication industriels avancés.');

-- Insertion des preuves d'exemple
INSERT INTO example_preuves (apprentissage_id, titre, type, url) 
SELECT 
  ea.id,
  CASE 
    WHEN ea.title LIKE '%cahier des charges%' THEN 'Rapport d''analyse fonctionnelle'
    WHEN ea.title LIKE '%architecture%' THEN 'Schémas d''architecture système'
    WHEN ea.title LIKE '%innovation%' THEN 'Présentation des améliorations proposées'
    WHEN ea.title LIKE '%Tests unitaires%' THEN 'Protocoles de tests et résultats'
    WHEN ea.title LIKE '%intégration%' THEN 'Rapport de tests d''intégration'
    WHEN ea.title LIKE '%Installation%' THEN 'Photos et schémas d''installation'
    WHEN ea.title LIKE '%Configuration%' THEN 'Documentation de configuration'
    ELSE 'Documentation technique'
  END,
  CASE 
    WHEN ea.title LIKE '%cahier des charges%' THEN 'Rapport'
    WHEN ea.title LIKE '%architecture%' THEN 'Documentation'
    WHEN ea.title LIKE '%innovation%' THEN 'Présentation'
    WHEN ea.title LIKE '%Tests%' THEN 'Rapport'
    WHEN ea.title LIKE '%Installation%' THEN 'Documentation'
    WHEN ea.title LIKE '%Configuration%' THEN 'Documentation'
    ELSE 'Autre'
  END,
  '#'
FROM example_apprentissages ea;

-- Politiques d'accès public pour toutes les tables d'exemple
ALTER TABLE example_competences ENABLE ROW LEVEL SECURITY;
ALTER TABLE example_projets ENABLE ROW LEVEL SECURITY;
ALTER TABLE example_apprentissages ENABLE ROW LEVEL SECURITY;
ALTER TABLE example_preuves ENABLE ROW LEVEL SECURITY;
ALTER TABLE example_fichiers_projets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read example competences"
  ON example_competences FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Anyone can read example projets"
  ON example_projets FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Anyone can read example apprentissages"
  ON example_apprentissages FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Anyone can read example preuves"
  ON example_preuves FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Anyone can read example fichiers projets"
  ON example_fichiers_projets FOR SELECT
  TO public
  USING (true);