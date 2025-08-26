export interface Competence {
  id: string
  title: string
  subtitle: string
  description: string
  levels: number
  color: 'primary' | 'accent'
  icon: string
}

export interface Preuve {
  id: string
  titre: string
  type: 'Rapport' | 'Code' | 'Projet' | 'Présentation' | 'Documentation' | 'Autre'
  url: string
  projetId?: string
}

export interface Apprentissage {
  id: string
  competenceId: string
  level: number
  title: string
  description: string
  evaluation: 'Bien Maîtrisé' | 'Partiellement Maîtrisé' | 'Pas Maîtrisé'
  argumentaire: string
  preuves: Preuve[]
  dateCreation: string
  dateModification: string
  categoryId?: string
}

export interface Projet {
  id: string
  titre: string
  description: string
  icone: string
  niveau: string
  duree: string
  fonctionnalites: string[]
  technologies: string[]
  competences_developpees: string[]
  fichiers: FichierProjet[]
  dateCreation: string
  statut: 'En cours' | 'Terminé' | 'Archivé'
  categoryId?: string
}

export interface FichierProjet {
  id: string
  nom: string
  type: 'Fichier' | 'Lien'
  url: string
}

export const competencesData: Competence[] = [
  // Données vides par défaut - seront remplacées par les données utilisateur ou d'exemple
]

export const apprentissagesData: Apprentissage[] = [
  // Données vides par défaut - seront remplacées par les données utilisateur ou d'exemple
]

export const projetsData: Projet[] = [
  // Données vides par défaut - seront remplacées par les données utilisateur ou d'exemple
]