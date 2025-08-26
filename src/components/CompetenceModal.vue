<template>
  <div class="fixed inset-0 z-50 overflow-y-auto">
    <div class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
      <!-- Background overlay -->
      <div 
        class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity backdrop-blur-sm"
        @click="$emit('close')"
      ></div>

      <!-- Modal -->
      <div class="inline-block align-bottom bg-white dark:bg-gray-800 rounded-2xl text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-2xl sm:w-full">
        <form @submit.prevent="handleSubmit">
          <!-- Header -->
          <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4 border-b border-gray-200 dark:border-gray-600">
            <div class="flex items-center justify-between">
              <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
                {{ competence?.id ? 'Modifier' : 'Ajouter' }} une Compétence
              </h3>
              <button 
                type="button"
                @click="$emit('close')"
                class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-200"
              >
                <XMarkIcon class="w-6 h-6" />
              </button>
            </div>
          </div>

          <!-- Content -->
          <div class="px-6 py-6">
            <div class="space-y-6">
              <!-- Titre -->
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Titre de la Compétence *
                </label>
                <input
                  v-model="form.title"
                  type="text"
                  required
                  maxlength="500"
                  class="input-field"
                  placeholder="ex: Concevoir, Vérifier, Intégrer..."
                />
                <div class="text-xs text-gray-400 mt-1 text-right">
                  {{ form.title.length }}/500 caractères
                </div>
              </div>

              <!-- Sous-titre -->
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Sous-titre
                </label>
                <input
                  v-model="form.subtitle"
                  type="text"
                  maxlength="500"
                  class="input-field"
                  placeholder="ex: Conception de systèmes"
                />
                <div class="text-xs text-gray-400 mt-1 text-right">
                  {{ form.subtitle.length }}/500 caractères
                </div>
              </div>

              <!-- Description -->
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Description
                </label>
                <textarea
                  v-model="form.description"
                  maxlength="500"
                  rows="3"
                  class="textarea-field"
                  placeholder="Description détaillée de la compétence"
                ></textarea>
                <div class="text-xs text-gray-400 mt-1 text-right">
                  {{ form.description.length }}/500 caractères
                </div>
              </div>

              <!-- Nombre de niveaux et Couleur -->
              <div class="grid grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Nombre de Niveaux *
                  </label>
                  <select v-model="form.levels" required class="input-field">
                    <option value="2">2 niveaux</option>
                    <option value="3">3 niveaux</option>
                  </select>
                </div>
                
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Couleur *
                  </label>
                  <select v-model="form.color" required class="input-field">
                    <option value="primary">Bleu (Primary)</option>
                    <option value="accent">Jaune (Accent)</option>
                  </select>
                </div>
              </div>

              <!-- Icône -->
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Icône de la Compétence *
                </label>
                <IconPicker 
                  :model-value="form.icon" 
                  @select="form.icon = $event" 
                />
              </div>
              
              <!-- BUT Programs Reference -->
            </div>
          </div>

          <!-- Footer -->
          <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4 border-t border-gray-200 dark:border-gray-600 flex justify-end space-x-3">
            <button 
              type="button"
              @click="$emit('close')"
              class="btn-secondary"
            >
              Annuler
            </button>
            <button 
              type="submit"
              class="btn-primary"
            >
              {{ competence?.id ? 'Modifier' : 'Créer' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import { XMarkIcon } from '@heroicons/vue/24/outline'
import IconPicker from './IconPicker.vue'
import type { Competence } from '../data/portfolio'

const props = defineProps<{
  competence: Competence | null
}>()

const emit = defineEmits(['save', 'close'])

const form = ref<Competence>({
  id: '',
  title: '',
  subtitle: '',
  description: '',
  levels: 3,
  color: 'primary',
  icon: '🎯'
})


// Initialize form when competence prop changes
watch(() => props.competence, (competence) => {
  if (competence) {
    form.value = { ...competence }
  } else {
    form.value = {
      id: '',
      title: '',
      subtitle: '',
      description: '',
      levels: 3,
      color: 'primary',
      icon: '🎯'
    }
  }
}, { immediate: true })

const handleSubmit = () => {
  if (form.value.title) {
    // Generate ID if new competence
    if (!form.value.id) {
      form.value.id = crypto.randomUUID()
    }
    emit('save', { ...form.value })
  }
}
</script>