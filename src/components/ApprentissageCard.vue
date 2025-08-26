<template>
  <div 
    class="card-glass p-6 hover:shadow-lg transition-all duration-300 group cursor-pointer relative"
    @click="$emit('view', apprentissage)"
  >
    <!-- Drag Handle (visible on hover for authenticated users) -->
    <div 
      v-if="isAuthenticated"
      class="drag-handle absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity duration-200 cursor-grab active:cursor-grabbing z-10"
    >
      <div class="bg-white/10 backdrop-blur-sm rounded-lg p-2">
        <svg class="w-4 h-4 text-gray-400" fill="currentColor" viewBox="0 0 24 24">
          <path d="M8 6a2 2 0 1 1-4 0 2 2 0 0 1 4 0zM8 12a2 2 0 1 1-4 0 2 2 0 0 1 4 0zM8 18a2 2 0 1 1-4 0 2 2 0 0 1 4 0zM14 6a2 2 0 1 1-4 0 2 2 0 0 1 4 0zM14 12a2 2 0 1 1-4 0 2 2 0 0 1 4 0zM14 18a2 2 0 1 1-4 0 2 2 0 0 1 4 0zM20 6a2 2 0 1 1-4 0 2 2 0 0 1 4 0zM20 12a2 2 0 1 1-4 0 2 2 0 0 1 4 0zM20 18a2 2 0 1 1-4 0 2 2 0 0 1 4 0z"/>
        </svg>
      </div>
    </div>

    <div 
      class="flex items-start justify-between mb-4"
    >
      <h4 class="text-lg font-semibold text-gray-900 dark:text-white line-clamp-2 flex-1">
        {{ apprentissage.title }}
      </h4>
      <div class="flex items-center space-x-2 ml-4">
        <slot name="action-buttons">
          <button 
            v-if="isAuthenticated"
            @click="$emit('edit', apprentissage)"
            @click.stop=""
            class="p-1 text-gray-400 hover:text-primary-600 dark:hover:text-primary-400 opacity-0 group-hover:opacity-100 transition-opacity"
            title="Modifier"
          >
            <PencilIcon class="w-4 h-4" />
          </button>
          <button 
            v-if="isAuthenticated"
            @click="$emit('toggle-featured', apprentissage)"
            @click.stop=""
            class="p-1 transition-opacity"
            :class="isFeatured ? 'text-accent-400 opacity-100' : 'text-gray-400 hover:text-accent-400 opacity-0 group-hover:opacity-100'"
            :title="isFeatured ? 'Retirer des vedettes' : 'Épingler en vedette'"
          >
            <span class="text-sm">{{ isFeatured ? '⭐' : '☆' }}</span>
          </button>
          <button 
            v-if="isAuthenticated"
            @click="$emit('delete', apprentissage.id)"
            @click.stop=""
            class="p-1 text-gray-400 hover:text-red-600 dark:hover:text-red-400 opacity-0 group-hover:opacity-100 transition-opacity"
            title="Supprimer"
          >
            <TrashIcon class="w-4 h-4" />
          </button>
        </slot>
      </div>
    </div>

    <EvaluationBadge :evaluation="apprentissage.evaluation" class="mb-4" />

    <p class="text-gray-600 dark:text-gray-400 text-sm mb-4 line-clamp-3">
      {{ apprentissage.description }}
    </p>

    <div class="mb-4">
      <h5 class="font-medium text-gray-900 dark:text-white mb-2">Argumentaire :</h5>
      <p class="text-gray-600 dark:text-gray-400 text-sm line-clamp-4">
        {{ apprentissage.argumentaire }}
      </p>
    </div>

    <!-- Preuves -->
    <div v-if="apprentissage.preuves.length > 0" class="mb-4">
      <h5 class="font-medium text-gray-900 dark:text-white mb-2">Preuves :</h5>
      <div class="flex flex-wrap gap-2">
        <button
          v-for="preuve in apprentissage.preuves.slice(0, 3)"
          :key="preuve.id"
          @click="handlePreuveClick(preuve)"
          @click.stop=""
          class="inline-flex items-center space-x-1 text-xs bg-primary-100 dark:bg-primary-900 text-primary-700 dark:text-primary-300 px-2 py-1 rounded-full hover:bg-primary-200 dark:hover:bg-primary-800 transition-colors"
        >
          <LinkIcon class="w-3 h-3" />
          <span class="truncate max-w-20">{{ preuve.titre }}</span>
        </button>
        <span 
          v-if="apprentissage.preuves.length > 3"
          class="text-xs text-gray-500 dark:text-gray-400 px-2 py-1"
        >
          +{{ apprentissage.preuves.length - 3 }} autres
        </span>
      </div>
    </div>

    <!-- Date -->
    <div class="flex justify-between items-center text-xs text-gray-500 dark:text-gray-400">
      <span>Créé le {{ formatDate(apprentissage.dateCreation) }}</span>
      <span v-if="apprentissage.dateModification !== apprentissage.dateCreation">
        Modifié le {{ formatDate(apprentissage.dateModification) }}
      </span>
    </div>
  </div>
</template>

<script setup lang="ts">
import { PencilIcon, TrashIcon, LinkIcon } from '@heroicons/vue/24/outline'
import EvaluationBadge from './EvaluationBadge.vue'
import type { Apprentissage, Preuve } from '../data/portfolio'
import { authService } from '../lib/supabase'
import { ref, onMounted } from 'vue'

defineProps<{
  apprentissage: Apprentissage
  isFeatured?: boolean
}>()

const emit = defineEmits(['edit', 'delete', 'view', 'open-project', 'toggle-featured'])

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
const formatDate = (dateString: string) => {
  return new Date(dateString).toLocaleDateString('fr-FR')
}
</script>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.line-clamp-3 {
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.line-clamp-4 {
  display: -webkit-box;
  -webkit-line-clamp: 4;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>