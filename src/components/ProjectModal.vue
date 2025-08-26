<template>
  <div class="fixed inset-0 z-50 overflow-y-auto">
    <div class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
      <!-- Background overlay -->
      <div 
        class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity backdrop-blur-sm"
        @click="$emit('close')"
      ></div>

      <!-- Modal -->
      <div class="inline-block align-bottom bg-white dark:bg-gray-800 rounded-2xl text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-6xl sm:w-full">
        <!-- Header -->
        <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4 border-b border-gray-200 dark:border-gray-600">
          <div class="flex items-center justify-between">
            <h3 class="text-xl font-bold text-gray-900 dark:text-white">
              {{ project.title }}
            </h3>
            <button 
              @click="$emit('close')"
              class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-200 transition-colors"
            >
              <XMarkIcon class="w-6 h-6" />
            </button>
          </div>
        </div>

        <!-- Content -->
        <div class="px-6 py-6 max-h-[600px] overflow-y-auto bg-white dark:bg-gray-800">
          <div class="space-y-6">
            <!-- Description -->
            <div>
              <h4 class="text-lg font-semibold text-gray-900 dark:text-white mb-3">
                Description du Projet
              </h4>
              <p class="text-gray-600 dark:text-gray-300 leading-relaxed">
                {{ project.description }}
              </p>
            </div>

            <!-- Objectifs -->
            <div>
              <h4 class="text-lg font-semibold text-gray-900 dark:text-white mb-3">
                Objectifs
              </h4>
              <ul class="space-y-2">
                <li 
                  v-for="objectif in project.objectifs"
                  :key="objectif"
                  class="flex items-start space-x-2"
                >
                  <span class="text-green-500 mt-1">✓</span>
                  <span class="text-gray-600 dark:text-gray-300">{{ objectif }}</span>
                </li>
              </ul>
            </div>

            <!-- Réalisations -->
            <div>
              <h4 class="text-lg font-semibold text-gray-900 dark:text-white mb-3">
                Réalisations Techniques
              </h4>
              <ul class="space-y-2">
                <li 
                  v-for="realisation in project.realisations"
                  :key="realisation"
                  class="flex items-start space-x-2"
                >
                  <span class="text-primary-500 mt-1">→</span>
                  <span class="text-gray-600 dark:text-gray-300">{{ realisation }}</span>
                </li>
              </ul>
            </div>

            <!-- Fichiers et Liens -->
            <div v-if="project.fichiers && project.fichiers.length > 0">
              <h4 class="text-lg font-semibold text-gray-900 dark:text-white mb-3">
                Fichiers et Ressources
              </h4>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                <a
                  v-for="fichier in project.fichiers"
                  :key="fichier.id"
                  :href="fichier.url"
                  target="_blank"
                  rel="noopener noreferrer"
                  class="flex items-center space-x-3 p-3 bg-white/10 dark:bg-gray-700/30 rounded-lg hover:bg-white/20 dark:hover:bg-gray-700/50 transition-colors"
                >
                  <div class="w-8 h-8 rounded-lg flex items-center justify-center"
                       :class="fichier.type === 'Fichier' ? 'bg-blue-100 dark:bg-blue-900' : 'bg-green-100 dark:bg-green-900'">
                    <DocumentIcon v-if="fichier.type === 'Fichier'" class="w-4 h-4 text-blue-600 dark:text-blue-400" />
                    <LinkIcon v-else class="w-4 h-4 text-green-600 dark:text-green-400" />
                  </div>
                  <div class="flex-1">
                    <p class="font-medium text-gray-900 dark:text-white">{{ fichier.nom }}</p>
                    <p class="text-sm text-gray-500 dark:text-gray-400">{{ fichier.type }}</p>
                  </div>
                </a>
              </div>
            </div>
          </div>
        </div>

        <!-- Footer -->
        <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4 border-t border-gray-200 dark:border-gray-600 flex justify-between items-center">
          <div class="text-sm text-gray-500 dark:text-gray-400">
            <span class="font-medium">{{ project.duree }}</span> • {{ project.niveau }}
          </div>
          <button 
            @click="$emit('close')"
            class="btn-primary"
          >
            Fermer
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { XMarkIcon, DocumentIcon, LinkIcon } from '@heroicons/vue/24/outline'

export interface Project {
  id: string
  title: string
  description: string
  technologies: string[]
  objectifs: string[]
  realisations: string[]
  competences: string[]
  duree: string
  niveau: string
  fichiers?: Array<{
    id: string
    nom: string
    type: 'Fichier' | 'Lien'
    url: string
  }>
}

defineProps<{
  project: Project
  competences?: any[]
}>()

defineEmits(['close'])

const getCompetenceDisplayName = (competenceId: string) => {
  // If competences prop is available, try to find the full title
  if (props.competences && props.competences.length > 0) {
    const competence = props.competences.find(c => c.id === competenceId)
    if (competence) {
      return competence.title
    }
  }
  
  // Fallback: try localStorage for user competences
  try {
    const savedCompetences = localStorage.getItem('user_competences')
    if (savedCompetences) {
      const parsedCompetences = JSON.parse(savedCompetences)
      const competence = parsedCompetences.find(c => c.id === competenceId)
      if (competence) {
        return competence.title
      }
    }
  } catch (error) {
    console.error('Error parsing saved competences:', error)
  }
  
  // Final fallback: return the competence ID or a default message
  return competenceId || 'Compétence développée'
}
</script>