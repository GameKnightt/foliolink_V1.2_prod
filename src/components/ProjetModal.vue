<template>
  <div class="fixed inset-0 z-50 overflow-y-auto">
    <div class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
      <!-- Background overlay -->
      <div 
        class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity backdrop-blur-sm"
        @click="handleBackgroundClick"
      ></div>

      <!-- Modal -->
      <div class="inline-block align-bottom glass-card text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-3xl sm:w-full">
        <form @submit.prevent="handleSubmit">
          <!-- Header -->
          <div class="bg-white/10 dark:bg-gray-800/50 px-6 py-4 border-b border-white/20 dark:border-gray-600/30">
            <div class="flex items-center justify-between">
              <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
                {{ projet?.id ? 'Modifier' : 'Ajouter' }} un Projet
              </h3>
              <button 
                type="button"
                @click="handleClose"
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
                  Titre du Projet *
                </label>
                <input
                  v-model="form.titre"
                  type="text"
                  required
                  maxlength="500"
                  class="input-field"
                  placeholder="Nom du projet"
                />
                <div class="text-xs text-gray-400 mt-1 text-right">
                  {{ form.titre.length }}/500 caractères
                </div>
              </div>

              <!-- Icône -->
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Icône du Projet *
                </label>
                <IconPicker 
                  :model-value="form.icone" 
                  @select="form.icone = $event" 
                />
              </div>

              <!-- Niveau et Durée -->
              <div class="grid grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Niveau *
                  </label>
                  <select v-model="form.niveau" required class="input-field">
                    <option value="Projet de 1ère année">Projet de 1ère année</option>
                    <option value="Projet de 2ème année">Projet de 2ème année</option>
                    <option value="Projet de 3ème année">Projet de 3ème année</option>
                    <option value="Alternance">Alternance</option>
                    <option value="Stage">Stage</option>
                    <option value="Personnel">Personnel</option>
                  </select>
                </div>
                
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Durée *
                  </label>
                  <input
                    v-model="form.duree"
                    type="text"
                    required
                    maxlength="500"
                    class="input-field"
                    placeholder="ex: 6 mois, 3 semaines..."
                  />
                  <div class="text-xs text-gray-400 mt-1 text-right">
                    {{ form.duree.length }}/500 caractères
                  </div>
                </div>
              </div>

              <!-- Description -->
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Description *
                </label>
                <textarea
                  v-model="form.description"
                  required
                  maxlength="2000"
                  rows="4"
                  class="textarea-field"
                  placeholder="Description détaillée du projet"
                ></textarea>
                <div class="text-xs text-gray-400 mt-1 text-right">
                  {{ form.description.length }}/2000 caractères
                </div>
              </div>

              <!-- Fonctionnalités principales -->
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Fonctionnalités Principales
                </label>
                <div class="space-y-2 mb-3">
                  <div 
                    v-for="(fonctionnalite, index) in form.fonctionnalites"
                    :key="index"
                    class="flex items-center justify-between bg-gray-50 dark:bg-gray-700 p-3 rounded-lg"
                  >
                    <span class="text-gray-900 dark:text-white">{{ fonctionnalite }}</span>
                    <button 
                      type="button"
                      @click="removeFonctionnalite(index)"
                      class="text-red-500 hover:text-red-700"
                    >
                      <TrashIcon class="w-4 h-4" />
                    </button>
                  </div>
                </div>
                <div class="flex space-x-2">
                  <input
                    v-model="newFonctionnalite"
                    type="text"
                    maxlength="500"
                    placeholder="Ajouter une fonctionnalité"
                    class="input-field flex-1"
                    @keyup.enter="addFonctionnalite"
                  />
                  <button 
                    type="button"
                    @click="addFonctionnalite"
                    class="btn-secondary px-4"
                  >
                    Ajouter
                  </button>
                </div>
                <div class="text-xs text-gray-400 mt-1">
                  {{ newFonctionnalite.length }}/500 caractères
                </div>
              </div>

              <!-- Technologies -->
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Technologies Utilisées
                </label>
                <div class="flex flex-wrap gap-2 mb-3">
                  <span 
                    v-for="(tech, index) in form.technologies"
                    :key="index"
                    class="inline-flex items-center px-3 py-1 bg-primary-100 dark:bg-primary-900 text-primary-700 dark:text-primary-300 rounded-full text-sm"
                  >
                    {{ tech }}
                    <button 
                      type="button"
                      @click="removeTechnology(index)"
                      class="ml-2 text-primary-500 hover:text-primary-700"
                    >
                      ×
                    </button>
                  </span>
                </div>
                <div class="flex space-x-2">
                  <input
                    v-model="newTechnology.name"
                    type="text"
                    maxlength="500"
                    placeholder="Ajouter une technologie"
                    class="input-field flex-1"
                    @keyup.enter="addTechnology"
                  />
                  <button 
                    type="button"
                    @click="addTechnology"
                    class="btn-secondary px-4"
                  >
                    Ajouter
                  </button>
                </div>
                <div class="text-xs text-gray-400 mt-1">
                  {{ newTechnology.name.length }}/500 caractères
                </div>
              </div>

              <!-- Compétences Développées -->

              <!-- Statut -->
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Statut *
                </label>
                <select v-model="form.statut" class="input-field">
                  <option value="En cours">En cours</option>
                  <option value="Terminé">Terminé</option>
                  <option value="Archivé">Archivé</option>
                </select>
              </div>

              <!-- Fichiers et Liens -->
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Fichiers et Liens
                </label>
                
                <!-- Liste des fichiers existants -->
                <div v-if="form.fichiers.length > 0" class="space-y-2 mb-4">
                  <div 
                    v-for="(fichier, index) in form.fichiers"
                    :key="index"
                    class="flex items-center justify-between bg-gray-50 dark:bg-gray-700 p-3 rounded-lg"
                  >
                    <div class="flex items-center space-x-3">
                      <div class="w-8 h-8 rounded-lg flex items-center justify-center"
                           :class="fichier.type === 'Fichier' ? 'bg-blue-100 dark:bg-blue-900' : 'bg-green-100 dark:bg-green-900'">
                        <DocumentIcon v-if="fichier.type === 'Fichier'" class="w-4 h-4 text-blue-600 dark:text-blue-400" />
                        <LinkIcon v-else class="w-4 h-4 text-green-600 dark:text-green-400" />
                      </div>
                      <div class="flex-1">
                        <p class="font-medium text-gray-900 dark:text-white text-sm">{{ fichier.nom }}</p>
                        <p class="text-gray-500 dark:text-gray-400 text-xs">{{ fichier.type }}</p>
                      </div>
                    </div>
                    <button 
                      type="button"
                      @click="removeFichier(index)"
                      class="text-red-500 hover:text-red-700"
                    >
                      <TrashIcon class="w-4 h-4" />
                    </button>
                  </div>
                </div>

                <!-- Formulaire d'ajout de fichier -->
                <div class="space-y-3 p-4 bg-gray-100 dark:bg-gray-700 rounded-lg border border-gray-200 dark:border-gray-600">
                  <div class="grid grid-cols-2 gap-3">
                    <input
                      v-model="newFichier.nom"
                      type="text"
                      placeholder="Nom du fichier/lien"
                      class="input-field text-sm"
                    />
                    <select v-model="newFichier.type" class="input-field text-sm">
                      <option value="Fichier">Fichier</option>
                      <option value="Lien">Lien</option>
                    </select>
                  </div>
                  <input
                    v-model="newFichier.url"
                    type="url"
                    placeholder="URL ou lien vers le fichier"
                    class="input-field text-sm"
                  />
                  <button 
                    type="button"
                    @click="addFichier"
                    :disabled="!newFichier.nom || !newFichier.url"
                    class="w-full btn-secondary text-sm py-2 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    Ajouter le fichier/lien
                  </button>
                </div>
              </div>
            </div>
          </div>

          <!-- Footer -->
          <div class="bg-gray-50 dark:bg-gray-800 px-6 py-4 flex justify-end space-x-3">
            <button 
              type="button"
              @click="handleClose"
              class="btn-secondary"
            >
              Annuler
            </button>
            <button 
              type="submit"
              class="btn-primary"
            >
              {{ projet?.id ? 'Modifier' : 'Ajouter' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
  
  <!-- Confirm Exit Modal -->
  <div v-if="showConfirmExit" class="fixed inset-0 z-[60] overflow-y-auto">
    <div class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
      <!-- Background overlay -->
      <div 
        class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity backdrop-blur-sm"
        @click="cancelExit"
      ></div>

      <!-- Modal -->
      <div class="inline-block align-bottom glass-card text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-md sm:w-full">
        <!-- Header -->
        <div class="bg-amber-50 dark:bg-amber-900/50 px-6 py-4 border-b border-amber-200 dark:border-amber-700">
          <div class="flex items-center">
            <div class="flex-shrink-0">
              <ExclamationTriangleIcon class="h-6 w-6 text-amber-600 dark:text-amber-400" />
            </div>
            <div class="ml-3">
              <h3 class="text-lg font-medium text-amber-800 dark:text-amber-200">
                Modifications non sauvegardées
              </h3>
            </div>
          </div>
        </div>

        <!-- Content -->
        <div class="px-6 py-4 bg-white dark:bg-gray-800">
          <p class="text-gray-600 dark:text-gray-300">
            Vous avez des modifications non sauvegardées. Êtes-vous sûr de vouloir quitter sans sauvegarder ?
          </p>
          <p class="text-gray-500 dark:text-gray-400 text-sm mt-2">
            Toutes les modifications en cours seront perdues.
          </p>
        </div>

        <!-- Footer -->
        <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4 border-t border-gray-200 dark:border-gray-600 flex justify-end space-x-3">
          <button 
            @click="cancelExit"
            class="btn-secondary"
          >
            Continuer l'édition
          </button>
          <button 
            @click="confirmExit"
            class="bg-red-600 hover:bg-red-700 text-white font-semibold px-6 py-2 rounded-xl transition-all duration-300 hover:shadow-lg"
          >
            Quitter sans sauvegarder
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import { XMarkIcon, TrashIcon, DocumentIcon, LinkIcon, ExclamationTriangleIcon } from '@heroicons/vue/24/outline'
import IconPicker from './IconPicker.vue'

interface FichierProjet {
  id: string
  nom: string
  type: 'Fichier' | 'Lien'
  url: string
}

interface Projet {
  id?: string
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
  statut: string
  categoryId?: string
}

interface Props {
  projet?: Projet | null
}

interface Emits {
  (e: 'close'): void
  (e: 'save', projet: Projet): void
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

// State for unsaved changes tracking
const hasUnsavedChanges = ref(false)
const showConfirmExit = ref(false)
const originalForm = ref<any>(null)

const uploading = ref(false)
const uploadError = ref('')

const form = ref<Projet>({
  id: '',
  titre: '',
  description: '',
  icone: '📁',
  niveau: 'Projet de 1ère année',
  duree: '',
  fonctionnalites: [],
  technologies: [],
  competences_developpees: [],
  fichiers: [],
  dateCreation: '',
  statut: 'En cours',
  categoryId: ''
})

const newFonctionnalite = ref('')
const newTechnology = ref({
  name: '',
  color: 'blue'
})

const newFichier = ref<Omit<FichierProjet, 'id'>>({
  nom: '',
  type: 'Fichier',
  url: ''
})

// Initialize form when projet prop changes
watch(() => props.projet, (projet) => {
  if (projet) {
    form.value = { ...projet }
    // Store original form data for comparison
    originalForm.value = JSON.parse(JSON.stringify(form.value))
  } else {
    form.value = {
      id: '',
      titre: '',
      description: '',
      icone: '📁',
      niveau: 'Projet de 1ère année',
      duree: '',
      fonctionnalites: [],
      technologies: [],
      competences_developpees: [],
      fichiers: [],
      dateCreation: '',
      statut: 'En cours'
    }
    // Store original form data for comparison
    originalForm.value = JSON.parse(JSON.stringify(form.value))
  }
  hasUnsavedChanges.value = false
}, { immediate: true })

// Watch for form changes to track unsaved changes
watch(form, (newForm) => {
  if (originalForm.value) {
    hasUnsavedChanges.value = JSON.stringify(newForm) !== JSON.stringify(originalForm.value)
  }
}, { deep: true })

const getTechColorClasses = (color: string) => {
  const colorMap = {
    blue: 'bg-blue-100 dark:bg-blue-900 text-blue-700 dark:text-blue-300',
    green: 'bg-green-100 dark:bg-green-900 text-green-700 dark:text-green-300',
    purple: 'bg-purple-100 dark:bg-purple-900 text-purple-700 dark:text-purple-300',
    yellow: 'bg-yellow-100 dark:bg-yellow-900 text-yellow-700 dark:text-yellow-300',
    red: 'bg-red-100 dark:bg-red-900 text-red-700 dark:text-red-300',
    indigo: 'bg-indigo-100 dark:bg-indigo-900 text-indigo-700 dark:text-indigo-300',
    pink: 'bg-pink-100 dark:bg-pink-900 text-pink-700 dark:text-pink-300',
    gray: 'bg-gray-100 dark:bg-gray-900 text-gray-700 dark:text-gray-300'
  }
  return colorMap[color] || colorMap.blue
}

const addTechnology = () => {
  if (newTechnology.value.name.trim() && !form.value.technologies.some(tech => tech === newTechnology.value.name.trim())) {
    form.value.technologies.push(newTechnology.value.name.trim())
    newTechnology.value = { name: '', color: 'blue' }
  }
}

const addFonctionnalite = () => {
  if (newFonctionnalite.value.trim() && !form.value.fonctionnalites.includes(newFonctionnalite.value.trim())) {
    form.value.fonctionnalites.push(newFonctionnalite.value.trim())
    newFonctionnalite.value = ''
  }
}

const removeFonctionnalite = (index: number) => {
  form.value.fonctionnalites.splice(index, 1)
}

const removeTechnology = (index: number) => {
  form.value.technologies.splice(index, 1)
}

const addFichier = () => {
  if (newFichier.value.nom && newFichier.value.url) {
    form.value.fichiers.push({
      id: Date.now().toString(),
      ...newFichier.value
    })
    newFichier.value = { nom: '', type: 'Fichier', url: '' }
  }
}

const handleFileUpload = async (event: Event) => {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]
  
  if (!file) return
  
  // Validation
  if (file.size > 10 * 1024 * 1024) { // 10MB limit
    uploadError.value = 'Fichier trop volumineux. Maximum 10MB.'
    return
  }
  
  uploading.value = true
  uploadError.value = ''
  
  try {
    // Generate a unique filename
    const fileExt = file.name.split('.').pop()
    const fileName = `projet-${Date.now()}-${Math.random().toString(36).substring(7)}.${fileExt}`
    
    // For demo purposes, we'll create a mock URL
    // In a real implementation, you would upload to Supabase storage
    const mockUrl = `https://storage.example.com/projets/${fileName}`
    
    // Simulate upload delay
    await new Promise(resolve => setTimeout(resolve, 1000))
    
    newFichier.value.url = mockUrl
    
  } catch (error) {
    uploadError.value = 'Erreur lors de l\'upload du fichier'
    console.error('File upload error:', error)
  } finally {
    uploading.value = false
  }
}

const removeFichier = (index: number) => {
  form.value.fichiers.splice(index, 1)
}

const handleSubmit = () => {
  if (form.value.titre && form.value.description && form.value.icone && form.value.niveau && form.value.duree) {
    emit('save', { ...form.value })
    hasUnsavedChanges.value = false
  }
}

// Handle close with unsaved changes check
const handleClose = () => {
  if (hasUnsavedChanges.value) {
    showConfirmExit.value = true
  } else {
    emit('close')
  }
}

// Handle background click
const handleBackgroundClick = () => {
  if (hasUnsavedChanges.value) {
    showConfirmExit.value = true
  } else {
    emit('close')
  }
}

// Confirm exit without saving
const confirmExit = () => {
  showConfirmExit.value = false
  hasUnsavedChanges.value = false
  emit('close')
}

// Cancel exit and continue editing
const cancelExit = () => {
  showConfirmExit.value = false
}
</script>