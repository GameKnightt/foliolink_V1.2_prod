<template>
  <div class="fixed inset-0 z-50 overflow-y-auto">
    <div class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
      <!-- Background overlay -->
      <div 
        class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity backdrop-blur-sm"
        @click="$emit('close')"
      ></div>

      <!-- Modal -->
      <div class="inline-block align-bottom bg-white dark:bg-gray-800 rounded-2xl text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-md sm:w-full">
        <form @submit.prevent="handleSubmit">
          <!-- Header -->
          <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4 border-b border-gray-200 dark:border-gray-600">
            <div class="flex items-center justify-between">
              <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
                {{ category?.id ? 'Modifier' : 'Créer' }} un Apprentissage Critique
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
            <div class="space-y-4">
              <!-- Explication de la hiérarchie (conditionnelle) -->
              <div v-if="showHelp" class="bg-blue-50 dark:bg-blue-900/20 rounded-xl p-6 mb-6 animate-fade-in">
                <h4 class="text-lg font-semibold text-blue-900 dark:text-blue-100 mb-4 flex items-center">
                  <span class="mr-2">📖</span>
                  À quoi servent les apprentissages critiques ?
                </h4>
                
                <p class="text-blue-800 dark:text-blue-200 text-sm mb-4">
                  Les apprentissages critiques vous permettent d'organiser vos apprentissages par thématiques pour une meilleure lisibilité de votre portfolio BUT.
                </p>
                
                <div class="bg-white/50 dark:bg-gray-800/50 rounded-lg p-4">
                  <h5 class="font-semibold text-blue-900 dark:text-blue-100 mb-3 text-sm">Structure hiérarchique :</h5>
                  <div class="font-mono text-xs text-blue-800 dark:text-blue-200 leading-relaxed">
                    🎯 {{ competenceTitle }}<br>
                    ├── 📊 Niveau {{ level }}<br>
                    │&nbsp;&nbsp;&nbsp;&nbsp;├── 📁 Apprentissage Critique 1 (ex: "Programmation et Développement")<br>
                    │&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;├── 📚 Apprentissage critique 1<br>
                    │&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;└── 📚 Apprentissage critique 2<br>
                    │&nbsp;&nbsp;&nbsp;&nbsp;├── 📁 Apprentissage Critique 2 (ex: "Analyse et Conception")<br>
                    │&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;└── 📚 Apprentissage critique 3<br>
                    │&nbsp;&nbsp;&nbsp;&nbsp;└── 📄 Apprentissages détaillés<br>
                    ├── 📊 Niveau {{ level + 1 }}<br>
                    │&nbsp;&nbsp;&nbsp;&nbsp;└── ...
                  </div>
                </div>
                
                <div class="mt-4 space-y-2">
                  <div class="flex items-center text-sm text-blue-800 dark:text-blue-200">
                    <span class="text-green-500 mr-2">✓</span>
                    <span>Organisez vos apprentissages par apprentissages critiques</span>
                  </div>
                  <div class="flex items-center text-sm text-blue-800 dark:text-blue-200">
                    <span class="text-green-500 mr-2">✓</span>
                    <span>Facilitez la navigation dans votre portfolio</span>
                  </div>
                  <div class="flex items-center text-sm text-blue-800 dark:text-blue-200">
                    <span class="text-green-500 mr-2">✓</span>
                    <span>Impressionnez le jury avec une présentation structurée</span>
                  </div>
                </div>
              </div>

              <!-- Titre -->
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Titre de l'Apprentissage Critique *
                </label>
                  <input
                    v-model="form.title"
                    type="text"
                    required
                    maxlength="500"
                    class="input-field"
                    placeholder="ex: Programmation et Développement"
                  />
                <div class="text-xs text-gray-400 mt-1 text-right">
                  {{ form.title.length }}/500 caractères
                </div>
              </div>

              <!-- Description -->
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Description (optionnelle)
                </label>
                <div class="relative">
                  <textarea
                    v-model="form.description"
                    maxlength="500"
                    rows="3"
                    class="textarea-field"
                    placeholder="Description de l'apprentissage critique..."
                  ></textarea>
                  <div class="absolute right-3 bottom-3 text-xs text-gray-400">
                    {{ form.description.length }}/500
                  </div>
                </div>
              </div>

              <!-- Info -->
              <div class="bg-blue-50 dark:bg-blue-900/20 rounded-lg p-4">
                <div class="flex items-center mb-2">
                  <span class="text-blue-400 mr-2">📁</span>
                  <h4 class="text-blue-900 dark:text-blue-100 font-medium text-sm">Organisation</h4>
                </div>
                <p class="text-blue-800 dark:text-blue-200 text-sm">
                  Cet apprentissage critique regroupera vos apprentissages pour la compétence 
                  <strong>{{ competenceTitle }}</strong> au <strong>Niveau {{ level }}</strong>.
                </p>
              </div>
            </div>
          </div>

          <!-- Footer -->
          <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4 border-t border-gray-200 dark:border-gray-600 flex justify-end space-x-3">
            <div class="flex items-center flex-1">
              <!-- Help section -->
              <div class="flex items-center">
                <button 
                  type="button"
                  @click="showHelp = !showHelp"
                  class="text-blue-600 hover:text-blue-700 dark:text-blue-400 dark:hover:text-blue-300 transition-colors flex items-center space-x-1 text-xs"
                  title="Aide sur les apprentissages critiques"
                >
                  <QuestionMarkCircleIcon class="w-4 h-4" />
                  <span class="font-medium">À quoi servent les apprentissages critiques ?</span>
                </button>
              </div>
            </div>
            
            <div class="flex items-center space-x-2">
              <button 
                type="button"
                @click="$emit('close')"
                class="btn-secondary px-4 py-2"
              >
                Annuler
              </button>
              <button 
                type="submit"
                :disabled="!form.title.trim()"
                class="btn-primary disabled:opacity-50 disabled:cursor-not-allowed px-4 py-2 text-sm whitespace-nowrap"
              >
                {{ category?.id ? 'Modifier' : 'Créer' }}<br>l'Apprentissage Critique
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import { XMarkIcon, QuestionMarkCircleIcon } from '@heroicons/vue/24/outline'

interface Category {
  id?: string
  competence_id: string
  level: number
  title: string
  description?: string
  order_index?: number
}

const props = defineProps<{
  category?: Category | null
  competenceId: string
  level: number
  competenceTitle: string
}>()

const emit = defineEmits(['save', 'close'])

const showHelp = ref(false)

const form = ref({
  title: '',
  description: ''
})

// Initialize form when category prop changes
watch(() => props.category, (category) => {
  if (category) {
    form.value = {
      title: category.title || '',
      description: category.description || ''
    }
  } else {
    form.value = {
      title: '',
      description: ''
    }
  }
}, { immediate: true })

const handleSubmit = () => {
  if (form.value.title.trim()) {
    const categoryData: Category = {
      competence_id: props.competenceId,
      level: props.level,
      title: form.value.title.trim(),
      description: form.value.description.trim() || undefined
    }
    
    if (props.category?.id) {
      categoryData.id = props.category.id
    }
    
    emit('save', categoryData)
  }
}
</script>

<style scoped>
@keyframes fade-in {
  from { opacity: 0; transform: translateY(-10px); }
  to { opacity: 1; transform: translateY(0); }
}

.animate-fade-in {
  animation: fade-in 0.3s ease-out;
}
</style>