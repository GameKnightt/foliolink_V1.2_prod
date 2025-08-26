<template>
  <div class="fixed inset-0 z-50 overflow-y-auto">
    <div class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
      <!-- Background overlay -->
      <div 
        class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"
        @click="handleBackgroundClick"
      ></div>

      <!-- Modal -->
      <div class="inline-block align-bottom bg-white dark:bg-gray-800 rounded-2xl text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-5xl sm:w-full">
        <form @submit.prevent="handleSubmit">
          <!-- Header -->
          <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4 border-b border-gray-200 dark:border-gray-600">
            <div class="flex items-center justify-between">
              <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
                {{ apprentissage?.id ? 'Modifier' : 'Ajouter' }} un Apprentissage
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
          <div class="px-6 py-6 bg-white dark:bg-gray-800">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <!-- Left Column -->
              <div class="space-y-6">
                <!-- Titre -->
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Titre de l'apprentissage *
                  </label>
                    <input
                      v-model="form.title"
                      type="text"
                      required
                      maxlength="500"
                      @input="validateInput"
                      class="input-field"
                      placeholder="Titre de l'apprentissage"
                    />
                  <div class="text-xs text-gray-400 mt-1 text-right">
                    {{ form.title.length }}/500 caractères
                  </div>
                </div>

                <!-- Compétence et Niveau -->
                <div class="grid grid-cols-2 gap-4">
                  <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                      Compétence *
                    </label>
                    <select v-model="form.competenceId" required class="input-field">
                      <option v-for="comp in competences" :key="comp.id" :value="comp.id">
                        {{ comp.title }}
                      </option>
                    </select>
                  </div>
                  
                  <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                      Niveau *
                    </label>
                    <select v-model="form.level" required class="input-field">
                      <option v-for="level in getAvailableLevels()" :key="level" :value="level">
                        Niveau {{ level }}
                      </option>
                    </select>
                  </div>
                </div>
                
                <!-- Catégorie -->
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Apprentissage critique (optionnel)
                  </label>
                  <select v-model="form.categoryId" class="input-field">
                    <option value="">Aucun apprentissage critique</option>
                    <option 
                      v-for="category in getAvailableCategories()"
                      :key="category.id" 
                      :value="category.id"
                    >
                      📁 {{ category.title }}
                    </option>
                  </select>
                  <p class="text-xs text-gray-400 mt-1">
                    Organisez vos apprentissages par apprentissages critiques
                  </p>
                </div>

                <!-- Évaluation -->
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Évaluation de Maîtrise *
                  </label>
                  <select v-model="form.evaluation" required class="input-field">
                    <option value="Pas Maîtrisé">Pas Maîtrisé</option>
                    <option value="Partiellement Maîtrisé">Partiellement Maîtrisé</option>
                    <option value="Bien Maîtrisé">Bien Maîtrisé</option>
                  </select>
                </div>

                <!-- Description -->
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Description de l'apprentissage
                  </label>
                    <textarea
                      v-model="form.description"
                      maxlength="500"
                      rows="4"
                      class="textarea-field"
                      placeholder="Description détaillée de l'apprentissage"
                    ></textarea>
                  <div class="text-xs text-gray-400 mt-1 text-right">
                    {{ form.description.length }}/500 caractères
                  </div>
                </div>
                
                <!-- AI Assistant Button -->
                <div class="mt-3">
                  <div class="flex items-start space-x-4">
                    <button
                      type="button"
                      @click="generateArgumentWithAI"
                      :disabled="aiLoading || !form.title || !form.description || !form.competenceId || !isPremium"
                      class="flex-1 bg-gradient-to-r from-purple-500 to-purple-600 hover:from-purple-600 hover:to-purple-700 text-white font-semibold py-3 px-4 rounded-lg transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center space-x-2 relative group"
                      :class="{ 'opacity-60 filter blur-[1px]': !isPremium }"
                    >
                      <div v-if="!isPremium" class="absolute -top-2 -right-2 w-6 h-6 bg-red-500 rounded-full flex items-center justify-center shadow-lg z-10">
                        <span class="text-white text-xs">🔒</span>
                      </div>
                      <div v-if="!isPremium" class="absolute inset-0 bg-gray-900/20 backdrop-blur-[1px] rounded-lg"></div>
                      <span v-if="aiLoading" class="animate-spin">🤖</span>
                      <span v-else>🤖</span>
                      <span>{{ aiLoading ? 'Génération en cours...' : (isPremium ? 'Générer l\'argumentaire avec l\'IA' : 'IA Premium Requis') }}</span>
                    </button>
                  </div>
                  
                  <!-- AI Error Message -->
                  <div v-if="aiError" class="mt-2 p-2 bg-red-500/20 border border-red-500/30 rounded-lg">
                    <p class="text-red-200 text-sm">{{ aiError }}</p>
                  </div>
                  
                  <!-- AI Help Text -->
                  <p class="text-xs text-gray-400 mt-2">
                    {{ isPremium ? '💡 L\'IA génère un argumentaire personnalisé basé sur votre profil et votre formation BUT' : '👑 Fonctionnalité Premium : L\'IA personnalisée est réservée aux utilisateurs Premium' }}
                  </p>
                </div>
              </div>

              <!-- Right Column -->
              <div class="space-y-6">
                <!-- Argumentaire -->
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Argumentaire *
                  </label>
                  <div class="relative">
                    <textarea
                      v-model="form.argumentaire"
                      required
                      maxlength="1500"
                      rows="6"
                      class="textarea-field"
                      placeholder="Justification de l'évaluation de maîtrise avec exemples concrets"
                    ></textarea>
                    <!-- Expand Button -->
                    <button
                      type="button"
                      @click="showArgumentairePreview = true"
                      class="absolute top-3 right-3 p-1 text-gray-400 hover:text-gray-600 dark:hover:text-gray-200 transition-colors bg-white/10 rounded"
                      title="Aperçu en grand"
                    >
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 8V4m0 0h4M4 4l5 5m11-1V4m0 0h-4m4 0l-5 5M4 16v4m0 0h4m-4 0l5-5m11 5l-5-5m5 5v-4m0 4h-4"></path>
                      </svg>
                    </button>
                  </div>
                  <div class="text-xs text-gray-400 mt-1 text-right">
                    {{ form.argumentaire.length }}/1500 caractères
                  </div>
                </div>
                  
                <!-- Preuves Section -->
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Preuves et Ressources
                  </label>
                
                  <!-- Liste des preuves existantes -->
                  <div v-if="form.preuves.length > 0" class="space-y-2 mb-4">
                    <div 
                      v-for="(preuve, index) in form.preuves"
                      :key="index"
                      class="flex items-center justify-between bg-gray-50 dark:bg-gray-700 p-3 rounded-lg group hover:bg-gray-100 dark:hover:bg-gray-600 transition-colors"
                    >
                      <div class="flex-1">
                        <p class="font-medium text-gray-900 dark:text-white text-sm">{{ preuve.titre }}</p>
                        <p class="text-gray-500 dark:text-gray-400 text-xs">{{ preuve.type }}</p>
                        <p class="text-gray-500 dark:text-gray-400 text-xs truncate">{{ preuve.url }}</p>
                      </div>
                      <div class="flex items-center space-x-2">
                        <button 
                          type="button"
                          @click="editPreuve(index)"
                          class="p-1 text-gray-400 hover:text-blue-600 dark:hover:text-blue-400 opacity-0 group-hover:opacity-100 transition-all duration-200"
                          title="Modifier la preuve"
                        >
                          <PencilIcon class="w-4 h-4" />
                        </button>
                        <button 
                          type="button"
                          @click="removePreuve(index)"
                          class="p-1 text-gray-400 hover:text-red-600 dark:hover:text-red-400 opacity-0 group-hover:opacity-100 transition-all duration-200"
                          title="Supprimer la preuve"
                        >
                          <TrashIcon class="w-4 h-4" />
                        </button>
                      </div>
                    </div>
                  </div>

                  <!-- Formulaire d'ajout de preuve -->
                  <div class="space-y-3 p-4 bg-gray-100 dark:bg-gray-700 rounded-lg border border-gray-200 dark:border-gray-600">
                    <div v-if="editingPreuveIndex !== null" class="bg-blue-50 dark:bg-blue-900/20 p-3 rounded-lg mb-3">
                      <div class="flex items-center justify-between">
                        <span class="text-blue-800 dark:text-blue-200 text-sm font-medium">
                          ✏️ Modification de la preuve
                        </span>
                        <button 
                          type="button"
                          @click="cancelEditPreuve"
                          class="text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-200 text-xs"
                        >
                          Annuler
                        </button>
                      </div>
                    </div>
                    <div class="grid grid-cols-2 gap-3">
                      <input
                        v-model="newPreuve.titre"
                        type="text"
                        :placeholder="editingPreuveIndex !== null ? 'Modifier le nom' : 'Nom du fichier/lien'"
                        class="input-field text-sm"
                      />
                      <select v-model="newPreuve.type" class="input-field text-sm">
                        <option value="Rapport">Rapport</option>
                        <option value="Code">Code</option>
                        <option value="Projet">Projet</option>
                        <option value="Présentation">Présentation</option>
                        <option value="Documentation">Documentation</option>
                        <option value="Autre">Autre</option>
                      </select>
                    </div>
                    
                    <!-- Sélection de projet si type "Projet" -->
                    <div v-if="newPreuve.type === 'Projet'" class="space-y-2">
                      <label class="block text-sm font-medium text-gray-300">Sélectionner un projet existant :</label>
                      <select 
                        v-model="selectedProjetId" 
                        @change="onProjetSelected"
                        class="input-field text-sm"
                      >
                        <option value="">-- Choisir un projet --</option>
                        <option 
                          v-for="projet in projets" 
                          :key="projet.id" 
                          :value="projet.id"
                        >
                          {{ projet.titre }}
                        </option>
                      </select>
                      <p class="text-xs text-gray-400">
                        Ou saisissez manuellement l'URL ci-dessous
                      </p>
                    </div>
                    
                    <input
                      v-model="newPreuve.url"
                      type="url"
                      :placeholder="editingPreuveIndex !== null ? 'Modifier l\'URL' : 'URL ou lien vers la ressource'"
                      class="input-field text-sm"
                    />
                    <button 
                      type="button"
                      @click="editingPreuveIndex !== null ? updatePreuve() : addPreuve()"
                      :disabled="!newPreuve.titre || !newPreuve.url"
                      class="w-full btn-secondary text-sm py-2 disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      {{ editingPreuveIndex !== null ? 'Modifier la preuve' : 'Ajouter la preuve' }}
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Footer -->
          <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4 border-t border-gray-200 dark:border-gray-600 flex justify-end space-x-3">
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
              {{ apprentissage?.id ? 'Modifier' : 'Créer' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
  
  <!-- Argumentaire Preview Modal -->
  <div v-if="showArgumentairePreview" class="fixed inset-0 z-[60] overflow-y-auto">
    <div class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
      <!-- Background overlay -->
      <div 
        class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity backdrop-blur-sm"
        @click="showArgumentairePreview = false"
      ></div>

      <!-- Modal -->
      <div class="inline-block align-bottom bg-white dark:bg-gray-800 rounded-2xl text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-4xl sm:w-full">
        <!-- Header -->
        <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4 border-b border-gray-200 dark:border-gray-600">
          <div class="flex items-center justify-between">
            <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
              Aperçu de l'Argumentaire
            </h3>
            <button 
              @click="showArgumentairePreview = false"
              class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-200"
            >
              <XMarkIcon class="w-6 h-6" />
            </button>
          </div>
        </div>

        <!-- Content -->
        <div class="px-6 py-6">
          <div class="space-y-4">
            <!-- Character count -->
            <div class="flex items-center justify-between">
              <span class="text-sm text-gray-500 dark:text-gray-400">Longueur de l'argumentaire :</span>
              <span class="text-sm font-medium" :class="form.argumentaire.length > 1200 ? 'text-yellow-600' : 'text-gray-600 dark:text-gray-300'">
                {{ form.argumentaire.length }}/1500 caractères
              </span>
            </div>
            
            <!-- Progress bar -->
            <div class="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2">
              <div 
                class="h-2 rounded-full transition-all duration-300"
                :class="form.argumentaire.length > 1200 ? 'bg-yellow-500' : 'bg-blue-500'"
                :style="{ width: `${Math.min((form.argumentaire.length / 1500) * 100, 100)}%` }"
              ></div>
            </div>
            
            <!-- Large textarea -->
            <div class="relative">
              <textarea
                v-model="form.argumentaire"
                maxlength="1500"
                rows="20"
                class="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition-colors resize-none text-base leading-relaxed"
                placeholder="Justification de l'évaluation de maîtrise avec exemples concrets"
              ></textarea>
            </div>
            
            <!-- Tips -->
            <div class="bg-blue-50 dark:bg-blue-900/20 rounded-lg p-4">
              <h4 class="text-sm font-semibold text-blue-900 dark:text-blue-100 mb-2">
                💡 Conseils pour un bon argumentaire :
              </h4>
              <ul class="text-sm text-blue-800 dark:text-blue-200 space-y-1">
                <li>• Utilisez des exemples concrets de votre formation</li>
                <li>• Justifiez votre niveau de maîtrise avec des preuves</li>
                <li>• Mentionnez les contextes d'apprentissage (projets, stages)</li>
                <li>• Adoptez un vocabulaire technique approprié</li>
              </ul>
            </div>
          </div>
        </div>

        <!-- Footer -->
        <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4 border-t border-gray-200 dark:border-gray-600 flex justify-end space-x-3">
          <button 
            @click="showArgumentairePreview = false"
            class="btn-primary"
          >
            Fermer l'aperçu
          </button>
        </div>
      </div>
    </div>
  </div>
  
  <!-- Confirm Exit Modal -->
  <div v-if="showConfirmExit" class="fixed inset-0 z-[70] overflow-y-auto">
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
  
  <!-- Replace/Append Argumentaire Modal -->
  <div v-if="showReplaceModal" class="fixed inset-0 z-[70] overflow-y-auto">
    <div class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
      <!-- Background overlay -->
      <div 
        class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity backdrop-blur-sm"
        @click="handleCancelReplace"
      ></div>

      <!-- Modal -->
      <div class="inline-block align-bottom glass-card text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-md sm:w-full">
        <!-- Header -->
        <div class="bg-blue-50 dark:bg-blue-900/50 px-6 py-4 border-b border-blue-200 dark:border-blue-700">
          <div class="flex items-center">
            <div class="flex-shrink-0">
              <div class="w-8 h-8 bg-blue-500/20 rounded-full flex items-center justify-center">
                <span class="text-blue-400">🤖</span>
              </div>
            </div>
            <div class="ml-3">
              <h3 class="text-lg font-medium text-blue-800 dark:text-blue-200">
                Argumentaire généré par l'IA
              </h3>
            </div>
          </div>
        </div>

        <!-- Content -->
        <div class="px-6 py-4 bg-white dark:bg-gray-800">
          <p class="text-gray-600 dark:text-gray-300 mb-4">
            L'IA a généré un nouvel argumentaire. Vous avez déjà un argumentaire existant.
          </p>
          <p class="text-gray-500 dark:text-gray-400 text-sm">
            Que souhaitez-vous faire ?
          </p>
        </div>

        <!-- Footer -->
        <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4 border-t border-gray-200 dark:border-gray-600 flex flex-col space-y-2">
          <button 
            @click="handleReplaceArgument"
            class="w-full btn-primary"
          >
            <span class="mr-2">🔄</span>
            Remplacer l'argumentaire existant
          </button>
          <button 
            @click="handleAppendArgument"
            class="w-full btn-secondary"
          >
            <span class="mr-2">➕</span>
            Ajouter à la suite
          </button>
          <button 
            @click="handleCancelReplace"
            class="w-full text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200 text-sm transition-colors"
          >
            Annuler
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, onMounted } from 'vue'
import { XMarkIcon, TrashIcon, ExclamationTriangleIcon, PencilIcon } from '@heroicons/vue/24/outline'
import type { Competence, Apprentissage, Preuve, Projet } from '../data/portfolio'
import { aiService, profileService, authService, supabase } from '../lib/supabase'

const props = defineProps<{
  apprentissage: Apprentissage | null
  competences: Competence[]
  projets: Projet[]
  categories?: any[]
}>()

const emit = defineEmits(['save', 'close'])

// State for unsaved changes tracking
const hasUnsavedChanges = ref(false)
const showConfirmExit = ref(false)
const originalForm = ref<any>(null)

// AI Assistant state
const aiLoading = ref(false)
const aiError = ref('')
const userProfile = ref<any>(null)
const isPremium = ref(false)

const form = ref<Apprentissage>({
  id: '',
  competenceId: '',
  level: 1,
  title: '',
  description: '',
  evaluation: 'Pas Maîtrisé',
  argumentaire: '',
  preuves: [],
  dateCreation: '',
  dateModification: '',
  categoryId: undefined
})

const newPreuve = ref<Omit<Preuve, 'id'>>({
  titre: '',
  type: 'Rapport',
  url: ''
})

const selectedProjetId = ref('')
const editingPreuveIndex = ref<number | null>(null)

// Load user profile for AI context
onMounted(async () => {
  const user = await authService.getCurrentUser()
  if (user) {
    const { data: profile } = await profileService.getProfile(user.id)
    if (profile) {
      userProfile.value = profile
    }
    
    // Check premium status
    await checkPremiumStatus()
  }
})

const checkPremiumStatus = async () => {
  try {
    const { data: orders } = await supabase
      .from('stripe_orders')
      .select('*')
      .eq('status', 'completed')
      .limit(1)
    
    isPremium.value = !!(orders && orders.length > 0)
  } catch (error) {
    console.error('Error checking premium status:', error)
    isPremium.value = false
  }
}

// Argumentaire preview modal state
const showArgumentairePreview = ref(false)

// Modal pour remplacer/ajouter l'argumentaire
const showReplaceModal = ref(false)
const pendingArgument = ref('')

// Initialize form when apprentissage prop changes
watch(() => props.apprentissage, (apprentissage) => {
  if (apprentissage) {
    form.value = { 
      ...apprentissage,
      preuves: apprentissage.preuves || [],
      categoryId: apprentissage.categoryId
    }
    // Store original form data for comparison
    originalForm.value = JSON.parse(JSON.stringify(form.value))
  } else {
    // Reset form with default values
    const firstCompetence = props.competences[0]
    form.value = {
      id: '',
      competenceId: firstCompetence?.id || '',
      level: 1,
      title: '',
      description: '',
      evaluation: 'Pas Maîtrisé',
      argumentaire: '',
      preuves: [],
      dateCreation: '',
      dateModification: '',
      categoryId: undefined
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

const getAvailableLevels = () => {
  const selectedCompetence = props.competences.find(c => c.id === form.value.competenceId)
  if (!selectedCompetence) return [1]
  
  // Always start from level 1 and include all levels up to the maximum
  const levels = []
  for (let i = 1; i <= selectedCompetence.levels; i++) {
    levels.push(i)
  }
  return levels
}

const getAvailableCategories = () => {
  if (!props.categories) return []
  return props.categories.filter(cat => 
    cat.competence_id === form.value.competenceId && 
    cat.level === form.value.level
  )
}

const addPreuve = () => {
  if (newPreuve.value.titre && newPreuve.value.url) {
    form.value.preuves.push({
      id: Date.now().toString(),
      ...newPreuve.value
    })
    newPreuve.value = { titre: '', type: 'Rapport', url: '' }
    selectedProjetId.value = ''
  }
}

const editPreuve = (index: number) => {
  const preuve = form.value.preuves[index]
  if (preuve) {
    newPreuve.value = {
      titre: preuve.titre,
      type: preuve.type,
      url: preuve.url
    }
    editingPreuveIndex.value = index
    
    // Si c'est un projet, récupérer l'ID du projet
    if (preuve.projetId) {
      selectedProjetId.value = preuve.projetId
    }
  }
}

const updatePreuve = () => {
  if (editingPreuveIndex.value !== null && newPreuve.value.titre && newPreuve.value.url) {
    form.value.preuves[editingPreuveIndex.value] = {
      id: form.value.preuves[editingPreuveIndex.value].id,
      ...newPreuve.value
    }
    cancelEditPreuve()
  }
}

const cancelEditPreuve = () => {
  editingPreuveIndex.value = null
  newPreuve.value = { titre: '', type: 'Rapport', url: '' }
  selectedProjetId.value = ''
}

const onProjetSelected = () => {
  if (selectedProjetId.value) {
    const selectedProjet = props.projets.find(p => p.id === selectedProjetId.value)
    if (selectedProjet) {
      // Auto-remplir le titre et l'URL avec les infos du projet
      newPreuve.value.titre = selectedProjet.titre
      newPreuve.value.url = `#projet-${selectedProjet.id}` // Lien interne pour ouvrir le modal
      newPreuve.value.projetId = selectedProjet.id // Stocker l'ID du projet
    }
  }
}

const removePreuve = (index: number) => {
  form.value.preuves.splice(index, 1)
}

const generateArgumentWithAI = async () => {
  if (!isPremium.value) {
    aiError.value = 'La génération d\'argumentaire par IA est réservée aux utilisateurs Premium. Achetez Premium pour débloquer cette fonctionnalité.'
    return
  }

  if (!userProfile.value) {
    aiError.value = 'Profil utilisateur non disponible'
    return
  }

  if (!form.value.title || !form.value.description || !form.value.competenceId) {
    aiError.value = 'Veuillez remplir le titre, la description et sélectionner une compétence avant de générer l\'argumentaire'
    return
  }

  // Check character limit before AI generation
  const remainingChars = 1500 - form.value.argumentaire.length
  if (remainingChars < 200) {
    aiError.value = 'Pas assez d\'espace restant pour générer un argumentaire (minimum 200 caractères requis)'
    return
  }
  
  aiLoading.value = true
  aiError.value = ''

  try {
    const selectedCompetence = props.competences.find(c => c.id === form.value.competenceId)
    if (!selectedCompetence) {
      throw new Error('Compétence non trouvée')
    }

    console.log('Calling AI service with data:', {
      apprentissage: {
        title: form.value.title,
        description: form.value.description,
        evaluation: form.value.evaluation,
        competenceId: form.value.competenceId,
        level: form.value.level
      },
      competence: {
        title: selectedCompetence.title,
        subtitle: selectedCompetence.subtitle,
        description: selectedCompetence.description
      },
      profile: {
        full_name: userProfile.value.full_name,
        formation: userProfile.value.formation,
        etablissement: userProfile.value.etablissement,
        annee_etudes: userProfile.value.annee_etudes,
        bio: userProfile.value.bio
      }
    })
    const { data, error } = await aiService.generateArgument(
      {
        title: form.value.title,
        description: form.value.description,
        evaluation: form.value.evaluation,
        competenceId: form.value.competenceId,
        level: form.value.level
      },
      {
        title: selectedCompetence.title,
        subtitle: selectedCompetence.subtitle,
        description: selectedCompetence.description
      },
      {
        full_name: userProfile.value.full_name,
        formation: userProfile.value.formation,
        etablissement: userProfile.value.etablissement,
        annee_etudes: userProfile.value.annee_etudes,
        bio: userProfile.value.bio
      }
    )

    console.log('AI service response received:', { data, error })
    if (error) {
      console.error('AI service returned error:', error)
      aiError.value = error.message
    } else if (data && (data.argument || data.content)) {
      // Ensure the generated argument respects character limits
      let generatedArgument = data.argument || data.content
      
      // If adding to existing content would exceed limit, truncate
      if (form.value.argumentaire.length + generatedArgument.length > 1500) {
        const maxLength = 1500 - form.value.argumentaire.length - 10 // Leave some margin
        generatedArgument = generatedArgument.substring(0, maxLength) + '...'
      }
      
      // Si il y a déjà un argumentaire, demander via modal
      if (form.value.argumentaire.trim()) {
        pendingArgument.value = generatedArgument
        showReplaceModal.value = true
      } else {
        // Pas d'argumentaire existant, ajouter directement
        form.value.argumentaire = generatedArgument
      }
    } else {
      console.error('No argument content in response. Full response:', JSON.stringify(data, null, 2))
      aiError.value = 'Aucun contenu généré par l\'IA. Veuillez réessayer.'
    }
  } catch (error: any) {
    console.error('AI generation exception:', error)
    aiError.value = error.message || 'Erreur lors de la génération de l\'argumentaire'
  } finally {
    aiLoading.value = false
  }
}

const handleSubmit = () => {
  // Client-side validation
  if (!form.value.title.trim() || !form.value.argumentaire.trim()) {
    return
  }

  // Sanitize form data
  const sanitizedForm = {
    ...form.value,
    title: form.value.title.trim().replace(/[<>]/g, ''),
    description: form.value.description.trim().replace(/[<>]/g, '') || '',
    argumentaire: form.value.argumentaire.trim().replace(/[<>]/g, ''),
    preuves: form.value.preuves.map(preuve => ({
      ...preuve,
      titre: preuve.titre.trim().replace(/[<>]/g, ''),
      url: preuve.url.trim()
    }))
  }

  if (form.value.title && form.value.argumentaire) {
    emit('save', sanitizedForm)
    hasUnsavedChanges.value = false
  }
}

const validateInput = (event: Event) => {
  const target = event.target as HTMLInputElement
  // Remove potentially dangerous characters in real-time
  target.value = target.value.replace(/[<>]/g, '')
}

const handleReplaceArgument = () => {
  form.value.argumentaire = pendingArgument.value
  showReplaceModal.value = false
  pendingArgument.value = ''
}

const handleAppendArgument = () => {
  form.value.argumentaire = form.value.argumentaire + '\n\n' + pendingArgument.value
  showReplaceModal.value = false
  pendingArgument.value = ''
}

const handleCancelReplace = () => {
  showReplaceModal.value = false
  pendingArgument.value = ''
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