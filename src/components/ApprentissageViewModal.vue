<template>
  <div class="fixed inset-0 z-50 overflow-y-auto">
    <div class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
      <!-- Background overlay -->
      <div 
        class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity backdrop-blur-sm"
        @click="$emit('close')"
      ></div>

      <!-- Modal -->
      <div class="inline-block align-bottom bg-white dark:bg-gray-800 rounded-2xl text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-5xl sm:w-full">
        <!-- Header -->
        <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4 border-b border-gray-200 dark:border-gray-600">
          <div class="flex items-center justify-between">
            <h3 class="text-xl font-bold text-gray-900 dark:text-white">
              {{ apprentissage.title }}
            </h3>
          </div>
          <EvaluationBadge :evaluation="apprentissage.evaluation" class="mt-2" />
        </div>

        <!-- Content -->
        <div class="px-6 py-6 max-h-[500px] overflow-y-auto bg-white dark:bg-gray-800">
          <div class="space-y-6">
            <!-- Description -->
            <div>
              <h4 class="text-lg font-semibold text-gray-900 dark:text-white mb-3">
                Description
              </h4>
              <p class="text-gray-600 dark:text-gray-300 leading-relaxed">
                {{ apprentissage.description }}
              </p>
            </div>

            <!-- Argumentaire -->
            <div>
              <h4 class="text-lg font-semibold text-gray-900 dark:text-white mb-3">
                Argumentaire
              </h4>
              <p class="text-gray-600 dark:text-gray-300 leading-relaxed">
                {{ apprentissage.argumentaire }}
              </p>
            </div>

            <!-- Preuves -->
            <div v-if="apprentissage.preuves.length > 0">
              <h4 class="text-lg font-semibold text-gray-900 dark:text-white mb-3">
                Preuves et Ressources
              </h4>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                <button
                  v-for="preuve in apprentissage.preuves"
                  :key="preuve.id"
                  @click="handlePreuveClick(preuve)"
                  class="flex items-center space-x-3 p-3 bg-white/10 dark:bg-gray-700/30 rounded-lg hover:bg-white/20 dark:hover:bg-gray-700/50 transition-colors"
                >
                  <LinkIcon class="w-5 h-5 text-primary-500" />
                  <div class="flex-1">
                    <p class="font-medium text-gray-900 dark:text-white">{{ preuve.titre }}</p>
                    <p class="text-sm text-gray-500 dark:text-gray-400">{{ preuve.type }}</p>
                  </div>
                </button>
              </div>
            </div>

            <!-- Informations -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 pt-4 border-t border-white/20 dark:border-gray-600/30">
              <div>
                <p class="text-sm text-gray-500 dark:text-gray-400">Compétence</p>
                <p class="font-medium text-gray-900 dark:text-white">{{ getCompetenceTitle() }}</p>
              </div>
              <div>
                <p class="text-sm text-gray-500 dark:text-gray-400">Niveau</p>
                <p class="font-medium text-gray-900 dark:text-white">Niveau {{ apprentissage.level }}</p>
              </div>
              <div>
                <p class="text-sm text-gray-500 dark:text-gray-400">Créé le</p>
                <p class="font-medium text-gray-900 dark:text-white">{{ formatDate(apprentissage.dateCreation) }}</p>
              </div>
              <div v-if="apprentissage.dateModification !== apprentissage.dateCreation">
                <p class="text-sm text-gray-500 dark:text-gray-400">Modifié le</p>
                <p class="font-medium text-gray-900 dark:text-white">{{ formatDate(apprentissage.dateModification) }}</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Footer -->
        <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4 border-t border-gray-200 dark:border-gray-600 flex justify-end space-x-3">
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
import { XMarkIcon, LinkIcon, PencilIcon } from '@heroicons/vue/24/outline'
import EvaluationBadge from './EvaluationBadge.vue'
import type { Apprentissage, Preuve } from '../data/portfolio'
import { authService } from '../lib/supabase'
import { ref, onMounted } from 'vue'

const props = defineProps<{
  apprentissage: Apprentissage
  competences?: any[]
}>()

const emit = defineEmits(['close', 'edit', 'open-project'])

const isAuthenticated = ref(false)

onMounted(async () => {
  const user = await authService.getCurrentUser()
  isAuthenticated.value = !!user
})

const handlePreuveClick = (preuve: Preuve) => {
  if (preuve.projetId) {
    // Si c'est un lien vers un projet, émettre l'événement pour ouvrir le modal
    emit('open-project', preuve.projetId)
  } else {
    // Sinon, ouvrir le lien normalement
    window.open(preuve.url, '_blank', 'noopener,noreferrer')
  }
}
const getCompetenceTitle = () => {
  // First try to find in passed competences prop
  if (props.competences && props.competences.length > 0) {
    const competence = props.competences.find(c => c.id === props.apprentissage.competenceId)
    if (competence) {
      return competence.title
    }
  }
  
  // Fallback: try localStorage for user competences
  try {
    const savedCompetences = localStorage.getItem('user_competences')
    if (savedCompetences) {
      const parsedCompetences = JSON.parse(savedCompetences)
      const competence = parsedCompetences.find(c => c.id === props.apprentissage.competenceId)
      if (competence) {
        return competence.title
      }
    }
  } catch (error) {
    console.error('Error parsing saved competences:', error)
  }
  
  // Final fallback: return competence ID if no title found
  return props.apprentissage.competenceId || 'Compétence non trouvée'
}

const formatDate = (dateString: string) => {
  return new Date(dateString).toLocaleDateString('fr-FR')
}
</script>