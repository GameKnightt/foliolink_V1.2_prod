<template>
  <div class="pt-16 min-h-screen bg-gradient-to-br from-gray-900 via-blue-900 to-gray-900">
    <!-- Hero Section -->
    <section class="relative py-20 overflow-hidden">
      <!-- Animated Background Elements -->
      <div class="absolute inset-0">
        <div class="absolute top-20 left-10 w-72 h-72 bg-accent-500/10 rounded-full blur-3xl animate-pulse"></div>
        <div class="absolute bottom-20 right-10 w-96 h-96 bg-primary-500/10 rounded-full blur-3xl animate-pulse delay-1000"></div>
      </div>
      
      <div class="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center z-10">
        <!-- Badge -->
        <div class="inline-flex items-center glass-card px-6 py-3 mb-8 animate-fade-in">
          <span class="text-accent-400 mr-2">🎯</span>
          <span class="text-white font-medium">Compétences BUT</span>
        </div>

        <!-- Main Title -->
        <div class="animate-slide-up">
          <h1 class="text-6xl md:text-8xl font-bold text-white mb-6 leading-tight">
            Mes <span class="gradient-text text-glow">Compétences</span>
          </h1>
          
          <p class="text-xl md:text-2xl text-gray-300 mb-12 max-w-4xl mx-auto leading-relaxed">
            Découvrez mes compétences BUT avec leurs apprentissages critiques et évaluations de maîtrise
          </p>
          
          <!-- Limits Display for Non-Premium Users -->
          <div v-if="userLimits && !userLimits.isPremium && isAuthenticated" class="mt-8 max-w-md mx-auto">
            <div class="glass-card p-4">
              <div class="flex items-center justify-between">
                <LimitCounter 
                  type="apprentissages"
                  :current="userLimits.current.apprentissages"
                  :max="userLimits.limits.apprentissages"
                  :is-premium="userLimits.isPremium"
                />
                <router-link to="/pricing" class="text-accent-400 hover:text-accent-300 text-sm font-medium transition-colors">
                  Premium →
                </router-link>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Drag and Drop Status -->
    <div v-if="isDragging" class="fixed top-20 left-1/2 transform -translate-x-1/2 z-50 glass-card p-4 animate-bounce">
      <div class="flex items-center space-x-3">
        <div class="w-8 h-8 bg-accent-400/20 rounded-full flex items-center justify-center animate-spin">
          <span class="text-accent-400">🔄</span>
        </div>
        <div>
          <p class="text-white font-medium text-sm">Déplacement en cours...</p>
          <p class="text-gray-300 text-xs">Déposez dans une zone compatible</p>
        </div>
      </div>
    </div>

    <!-- Save Status -->
    <div v-if="isSaving" class="fixed top-20 right-4 z-50 glass-card p-4">
      <div class="flex items-center space-x-3">
        <div class="w-6 h-6 bg-blue-500/20 rounded-full flex items-center justify-center animate-pulse">
          <span class="text-blue-400">💾</span>
        </div>
        <span class="text-white text-sm">Sauvegarde...</span>
      </div>
    </div>

    <!-- Compétences Section -->
    <section class="py-20 relative">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="space-y-12">
          <!-- Add Competence Button -->
          <div 
            class="glass-card p-8 hover:scale-105 transition-all duration-500 group cursor-pointer border-2 border-dashed border-accent-400/50 hover:border-accent-400 relative" 
            :class="{ 
              'opacity-60 cursor-not-allowed backdrop-blur-sm': !canCreateCompetence && isAuthenticated,
              'hover:shadow-lg': canCreateCompetence && isAuthenticated
            }"
            @click="openAddCompetenceModal"
          >
            <div v-if="!canCreateCompetence" class="absolute -top-2 -right-2 w-8 h-8 bg-red-500 rounded-full flex items-center justify-center shadow-lg z-10">
              <span class="text-white text-sm">🔒</span>
            </div>
            <div v-if="!canCreateCompetence" class="absolute inset-0 bg-gray-500/20 backdrop-blur-[1px] rounded-2xl"></div>
            <div class="flex flex-col items-center justify-center h-full min-h-[200px] text-center">
              <div class="w-16 h-16 bg-accent-400/20 rounded-2xl flex items-center justify-center mb-6 group-hover:scale-110 transition-transform duration-300">
                <span class="text-3xl text-accent-400">➕</span>
              </div>
              <h3 class="text-2xl font-bold text-white mb-4">
                {{ !isAuthenticated ? 'Connexion Requise' : (!canCreateCompetence ? 'Limite Atteinte - Premium Requis' : 'Ajouter une Nouvelle Compétence') }}
              </h3>
              <p class="text-gray-300 leading-relaxed">
                {{ !isAuthenticated 
                  ? 'Connectez-vous pour ajouter de nouvelles compétences à votre portfolio.'
                  : (!canCreateCompetence 
                    ? `Vous avez atteint la limite de ${userLimits?.limits.competences || 3} compétences. Achetez Premium pour créer des compétences illimitées.`
                    : 'Cliquez ici pour ajouter une nouvelle compétence à votre portfolio et enrichir vos apprentissages.')
                }}
              </p>
            </div>
          </div>

          <!-- Competences List with Drag and Drop -->
          <DragDropZone
            v-for="competence in competences"
            :key="competence.id"
            :zone-id="`competence-${competence.id}`"
            type="competence-level"
            :competence-id="competence.id"
            :level="1"
            base-classes="mb-8"
            :accept-types="['category', 'apprentissage']"
          >
            <CompetenceSection
              :competence="competence"
              :apprentissages="getApprentissagesForCompetence(competence.id)"
              :featured-apprentissages="featuredApprentissages"
              :user-limits="userLimits"
              :categories="categories"
              :is-authenticated="isAuthenticated"
              @add-apprentissage="openAddApprentissageModal"
              @edit-apprentissage="openEditApprentissageModal"
              @delete-apprentissage="deleteApprentissage"
              @view-apprentissage="openViewApprentissageModal"
              @open-project="openProjectFromApprentissage"
              @edit-competence="openEditCompetenceModal"
              @delete-competence="deleteCompetence"
              @toggle-featured="toggleFeaturedApprentissage"
              @add-category="openAddCategoryModal"
              @edit-category="openEditCategoryModal"
              @delete-category="deleteCategory"
            />
          </DragDropZone>
        </div>

        <!-- Call to Action -->
        <div class="text-center mt-16">
          <div class="glass-card p-8 max-w-2xl mx-auto">
            <h3 class="text-2xl font-bold text-white mb-4">Gestion des Compétences</h3>
            <p class="text-gray-300 mb-6">
              Explorez mes compétences BUT ou ajoutez de nouveaux apprentissages critiques.
            </p>
            <div class="flex flex-col sm:flex-row gap-4 justify-center">
              <!-- Mobile Action Menu for authenticated users -->
              <MobileActionMenu v-if="isAuthenticated" title="Actions" icon="🎯">
                <!-- Desktop Buttons -->
                <template #desktop-buttons>
                  <button 
                    @click="handleAddCompetenceClick"
                    class="btn-primary relative group"
                    :class="{ 'opacity-60 cursor-not-allowed filter blur-[1px]': !canCreateCompetence }"
                  >
                    <div v-if="!canCreateCompetence" class="absolute -top-2 -right-2 w-7 h-7 bg-red-500 rounded-full flex items-center justify-center shadow-lg z-10">
                      <span class="text-white text-sm">🔒</span>
                    </div>
                    <div v-if="!canCreateCompetence" class="absolute inset-0 bg-gray-500/15 backdrop-blur-[1px] rounded-xl pointer-events-none"></div>
                    <span class="mr-2">➕</span>
                    Ajouter une Compétence
                  </button>
                  <button 
                    v-if="userLimits?.isPremium"
                    @click="handleExportClick"
                    :disabled="exportLoading"
                    class="btn-secondary"
                  >
                    <span class="mr-2">📊</span>
                    {{ exportLoading ? 'Export...' : 'Exporter Excel' }}
                  </button>
                  <router-link to="/projets" class="btn-primary">
                    <span class="mr-2">🚀</span>
                    Voir Projets
                  </router-link>
                </template>
                
                <!-- Mobile Buttons -->
                <template #mobile-buttons>
                  <button 
                    @click="handleAddCompetenceClick"
                    class="w-full btn-primary h-12 px-4 text-sm font-semibold flex items-center justify-center relative group transition-all duration-300"
                    :class="{ 'opacity-60 cursor-not-allowed filter blur-[1px]': !canCreateCompetence }"
                  >
                    <div v-if="!canCreateCompetence" class="absolute -top-2 -right-2 w-6 h-6 bg-red-500 rounded-full flex items-center justify-center shadow-lg z-10">
                      <span class="text-white text-xs">🔒</span>
                    </div>
                    <span class="mr-2">➕</span>
                    Ajouter une Compétence
                  </button>
                  
                  <button 
                    v-if="userLimits?.isPremium"
                    @click="handleExportClick"
                    :disabled="exportLoading"
                    class="w-full btn-secondary h-12 px-4 text-sm font-semibold flex items-center justify-center"
                  >
                    <span class="mr-2">📊</span>
                    {{ exportLoading ? 'Export...' : 'Exporter Excel' }}
                  </button>
                  
                  <router-link to="/projets" class="w-full btn-primary h-12 px-4 text-sm font-semibold flex items-center justify-center">
                    <span class="mr-2">🚀</span>
                    Voir Projets
                  </router-link>
                </template>
              </MobileActionMenu>
              
              <!-- Non-authenticated user buttons -->
              <div v-else class="flex flex-col sm:flex-row gap-4 justify-center">
                <button 
                  @click="openAuthModal"
                  class="btn-primary w-full sm:w-auto"
                >
                  <span class="mr-2">🔑</span>
                  Se connecter
                </button>
                <router-link to="/projets" class="btn-primary w-full sm:w-auto">
                  <span class="mr-2">🚀</span>
                  Voir Projets
                </router-link>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Modals -->
    <CompetenceModal
      v-if="showCompetenceModal"
      :competence="selectedCompetence"
      @save="saveCompetence"
      @close="closeCompetenceModal"
    />

    <ApprentissageModal
      v-if="showApprentissageModal"
      :apprentissage="selectedApprentissage"
      :competences="competences"
      :projets="projets"
      :categories="categories"
      @save="saveApprentissage"
      @close="closeApprentissageModal"
    />

    <CategoryModal
      v-if="showCategoryModal"
      :category="selectedCategory"
      :competence-id="categoryModalData.competenceId"
      :level="categoryModalData.level"
      :competence-title="categoryModalData.competenceTitle"
      @save="saveCategory"
      @close="closeCategoryModal"
    />

    <ApprentissageViewModal
      v-if="showViewModal && selectedViewApprentissage"
      :apprentissage="selectedViewApprentissage"
      :competences="competences"
      @close="closeViewModal"
      @edit="openEditApprentissageModal"
      @open-project="openProjectFromApprentissage"
    />

    <ProjectModal
      v-if="showProjectModal && selectedProject"
      :project="selectedProject"
      :competences="competences"
      @close="closeProjectModal"
    />

    <ConfirmModal
      v-if="showConfirmModal"
      :title="confirmModalData.title"
      :message="confirmModalData.message"
      @confirm="confirmAction"
      @cancel="cancelAction"
    />

    <LoginRequiredModal
      v-if="showLoginRequiredModal"
      @close="closeLoginRequiredModal"
      @login="handleLoginFromModal"
    />

    <LimitModal
      v-if="showLimitModal"
      @close="closeLimitModal"
    />

    <ToastNotification
      v-if="showToastNotification"
      :title="toastData.title"
      :message="toastData.message"
      :duration="3000"
      @close="closeToast"
    />

    <DuplicateModal
      v-if="showDuplicateModal.show"
      :title="showDuplicateModal.title"
      :message="showDuplicateModal.message"
      @close="showDuplicateModal.show = false"
      @edit-existing="editExistingItem"
    />

    <TrophyModal
      v-if="showTrophyModal"
      :new-trophies="newTrophies"
      :current-level="currentLevel"
      :total-points="0"
      @close="closeTrophyModal"
    />

    <!-- Drag and Drop Status Messages -->
    <div v-if="saveError" class="fixed bottom-20 left-1/2 transform -translate-x-1/2 z-50 glass-card p-4 border border-red-400/30">
      <div class="flex items-center space-x-3">
        <span class="text-red-400">❌</span>
        <span class="text-white text-sm">{{ saveError }}</span>
      </div>
    </div>

    <div v-if="saveSuccess" class="fixed bottom-20 left-1/2 transform -translate-x-1/2 z-50 glass-card p-4 border border-green-400/30">
      <div class="flex items-center space-x-3">
        <span class="text-green-400">✅</span>
        <span class="text-white text-sm">{{ saveSuccess }}</span>
      </div>
    </div>

    <!-- Floating Back to Top Button -->
    <button 
      @click="scrollToTop"
      class="fixed bottom-8 right-8 glass-card p-4 hover:scale-110 transition-all duration-300 z-50"
    >
      <ChevronDownIcon class="w-6 h-6 text-accent-400 transform rotate-180" />
    </button>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ChevronDownIcon } from '@heroicons/vue/24/outline'
import CompetenceSection from '../components/CompetenceSection.vue'
import CompetenceModal from '../components/CompetenceModal.vue'
import ApprentissageModal from '../components/ApprentissageModal.vue'
import CategoryModal from '../components/CategoryModal.vue'
import ApprentissageViewModal from '../components/ApprentissageViewModal.vue'
import ProjectModal from '../components/ProjectModal.vue'
import ConfirmModal from '../components/ConfirmModal.vue'
import LimitCounter from '../components/LimitCounter.vue'
import LoginRequiredModal from '../components/LoginRequiredModal.vue'
import LimitModal from '../components/LimitModal.vue'
import ToastNotification from '../components/ToastNotification.vue'
import DuplicateModal from '../components/DuplicateModal.vue'
import TrophyModal from '../components/TrophyModal.vue'
import MobileActionMenu from '../components/MobileActionMenu.vue'
import DragDropZone from '../components/DragDropZone.vue'
import { authService, exampleDataService, competenceService, apprentissageService, projetService, profileService } from '../lib/supabase'
import { featuredApprentissageService, apprentissageCategoryService } from '../lib/supabase'
import { usePremiumLimits } from '../composables/usePremiumLimits'
import { useAuth } from '../composables/useAuth'
import { useGamification } from '../composables/useGamification'
import { useDragDrop } from '../composables/useDragDrop'
import { exportPortfolioToExcel, prepareExportData } from '../lib/excelExport'
import type { Competence, Apprentissage, Projet } from '../data/portfolio'

const router = useRouter()
const route = useRoute()
const { openAuthModal } = useAuth()

// Drag and Drop
const {
  isDragging,
  isSaving,
  saveError,
  saveSuccess
} = useDragDrop()

// State
const competences = ref<Competence[]>([])
const apprentissages = ref<Apprentissage[]>([])
const projets = ref<Projet[]>([])
const categories = ref<any[]>([])
const featuredApprentissages = ref<string[]>([])
const isAuthenticated = ref(false)
const userProfile = ref<any>(null)

// Modal states
const showCompetenceModal = ref(false)
const selectedCompetence = ref<Competence | null>(null)
const showApprentissageModal = ref(false)
const selectedApprentissage = ref<Apprentissage | null>(null)
const showCategoryModal = ref(false)
const selectedCategory = ref<any>(null)
const categoryModalData = ref({ competenceId: '', level: 1, competenceTitle: '' })
const showViewModal = ref(false)
const selectedViewApprentissage = ref<Apprentissage | null>(null)
const showProjectModal = ref(false)
const selectedProject = ref<any>(null)
const showConfirmModal = ref(false)
const confirmModalData = ref({ title: '', message: '', action: null as (() => void) | null })
const showLoginRequiredModal = ref(false)
const showLimitModal = ref(false)
const showToastNotification = ref(false)
const toastData = ref({ title: '', message: '' })
const showDuplicateModal = ref({
  show: false,
  title: '',
  message: '',
  existingItem: null
})
const exportLoading = ref(false)

// Premium limits
const { userLimits, loadUserLimits, canCreate, incrementCount, decrementCount } = usePremiumLimits()

// Gamification
const { 
  newTrophies,
  showTrophyModal,
  currentLevel,
  loadUserStats: loadGamificationStats,
  checkTrophies,
  closeTrophyModal
} = useGamification()

const canCreateCompetence = computed(() => canCreate.value.competences)
const canCreateApprentissage = computed(() => canCreate.value.apprentissages)

// Initialize data
onMounted(async () => {
  await checkAuthAndLoadData()
  
  // Listen for drag and drop events
  window.addEventListener('category-moved', handleCategoryMoved)
  window.addEventListener('apprentissage-moved', handleApprentissageMoved)
})

onUnmounted(() => {
  window.removeEventListener('category-moved', handleCategoryMoved)
  window.removeEventListener('apprentissage-moved', handleApprentissageMoved)
})

// Event handlers for drag and drop
const handleCategoryMoved = async (event: CustomEvent) => {
  const { categoryId, newCompetenceId, newLevel } = event.detail
  console.log('🔄 Category moved event received:', { categoryId, newCompetenceId, newLevel })
  
  // Reload categories to reflect the change
  await loadCategories()
  
  showToast({
    title: 'Apprentissage critique déplacé',
    message: 'L\'apprentissage critique a été déplacé avec succès.'
  })
}

const handleApprentissageMoved = async (event: CustomEvent) => {
  const { apprentissageId, newCompetenceId, newLevel, newCategoryId } = event.detail
  console.log('🔄 Apprentissage moved event received:', { apprentissageId, newCompetenceId, newLevel, newCategoryId })
  
  // Reload apprentissages to reflect the change
  await loadApprentissages()
  
  showToast({
    title: 'Apprentissage déplacé',
    message: 'L\'apprentissage a été déplacé avec succès.'
  })
}

const checkAuthAndLoadData = async () => {
  const user = await authService.getCurrentUser()
  isAuthenticated.value = !!user
  
  if (isAuthenticated.value && user) {
    await loadUserLimits()
    await loadGamificationStats()
    await loadUserData(user.id)
  } else {
    await loadExampleData()
  }
  
  // Check if we need to open a specific competence or apprentissage
  const competenceParam = route.query.competence as string
  const apprentissageParam = route.query.apprentissage as string
  
  if (competenceParam && apprentissageParam) {
    const apprentissage = apprentissages.value.find(a => a.id === apprentissageParam)
    if (apprentissage) {
      setTimeout(() => {
        openViewApprentissageModal(apprentissage)
      }, 500)
    }
  }
}

const loadUserData = async (userId: string) => {
  await Promise.all([
    loadCompetences(userId),
    loadApprentissages(userId),
    loadProjets(userId),
    loadCategories(userId),
    loadFeaturedApprentissages(userId),
    loadUserProfile(userId)
  ])
}

const loadCompetences = async (userId?: string) => {
  try {
    const { data } = await competenceService.getCompetences()
    if (data) {
      competences.value = userId 
        ? data.filter(c => c.user_id === userId || c.user_id === null)
        : data.filter(c => c.user_id === null)
    }
  } catch (error) {
    console.error('Error loading competences:', error)
  }
}

const loadApprentissages = async (userId?: string) => {
  try {
    if (userId) {
      const { data } = await apprentissageService.getUserApprentissages(userId)
      if (data) {
        apprentissages.value = data.map(app => ({
          id: app.id,
          competenceId: app.competence_id,
          level: app.level,
          title: app.title,
          description: app.description,
          evaluation: app.evaluation,
          argumentaire: app.argumentaire,
          preuves: app.preuves || [],
          dateCreation: app.created_at,
          dateModification: app.updated_at,
          categoryId: app.category_id
        }))
      }
    } else {
      const { data } = await exampleDataService.getExampleApprentissages()
      if (data) {
        apprentissages.value = data.map(app => ({
          id: app.id,
          competenceId: app.competence_id,
          level: app.level,
          title: app.title,
          description: app.description,
          evaluation: app.evaluation,
          argumentaire: app.argumentaire,
          preuves: app.example_preuves || [],
          dateCreation: app.created_at,
          dateModification: app.created_at
        }))
      }
    }
  } catch (error) {
    console.error('Error loading apprentissages:', error)
  }
}

const loadProjets = async (userId: string) => {
  try {
    const { data } = await projetService.getUserProjets(userId)
    if (data) {
      projets.value = data.map(projet => ({
        id: projet.id,
        titre: projet.titre,
        description: projet.description,
        icone: projet.icone,
        niveau: projet.niveau,
        duree: projet.duree,
        fonctionnalites: projet.fonctionnalites || [],
        technologies: projet.technologies || [],
        competences_developpees: projet.competences_developpees || [],
        fichiers: projet.fichiers_projets || [],
        dateCreation: projet.created_at,
        statut: projet.statut
      }))
    }
  } catch (error) {
    console.error('Error loading projets:', error)
  }
}

const loadCategories = async (userId?: string) => {
  try {
    if (userId) {
      const { data } = await apprentissageCategoryService.getUserCategories(userId)
      if (data) {
        categories.value = data
      }
    }
  } catch (error) {
    console.error('Error loading categories:', error)
  }
}

const loadFeaturedApprentissages = async (userId: string) => {
  try {
    const { data } = await featuredApprentissageService.getFeaturedApprentissages(userId)
    if (data) {
      featuredApprentissages.value = data.map(f => f.apprentissage_id)
    }
  } catch (error) {
    console.error('Error loading featured apprentissages:', error)
  }
}

const loadUserProfile = async (userId: string) => {
  try {
    const { data } = await profileService.getProfile(userId)
    if (data) {
      userProfile.value = data
    }
  } catch (error) {
    console.error('Error loading user profile:', error)
  }
}

const loadExampleData = async () => {
  try {
    const [competencesResult, apprentissagesResult] = await Promise.all([
      exampleDataService.getExampleCompetences(),
      exampleDataService.getExampleApprentissages()
    ])

    if (competencesResult.data) {
      competences.value = competencesResult.data
    }

    if (apprentissagesResult.data) {
      apprentissages.value = apprentissagesResult.data.map(app => ({
        id: app.id,
        competenceId: app.competence_id,
        level: app.level,
        title: app.title,
        description: app.description,
        evaluation: app.evaluation,
        argumentaire: app.argumentaire,
        preuves: app.example_preuves || [],
        dateCreation: app.created_at,
        dateModification: app.created_at
      }))
    }
  } catch (error) {
    console.error('Error loading example data:', error)
  }
}

// Helper functions
const getApprentissagesForCompetence = (competenceId: string) => {
  return apprentissages.value.filter(a => a.competenceId === competenceId)
}

// Modal handlers
const openAddCompetenceModal = () => {
  if (!isAuthenticated.value) {
    showLoginRequiredModal.value = true
    return
  }
  
  if (!canCreateCompetence.value) {
    showToast({
      title: 'Limite atteinte - Premium requis',
      message: `Vous avez atteint la limite de ${userLimits.value?.limits.competences || 3} compétences. Achetez Premium pour créer des compétences illimitées.`
    })
    return
  }
  
  selectedCompetence.value = null
  showCompetenceModal.value = true
}

const handleAddCompetenceClick = () => {
  openAddCompetenceModal()
}

const openEditCompetenceModal = (competence: Competence) => {
  selectedCompetence.value = competence
  showCompetenceModal.value = true
}

const closeCompetenceModal = () => {
  showCompetenceModal.value = false
  selectedCompetence.value = null
}

const openAddApprentissageModal = (competenceId: string, level: number, categoryId?: string) => {
  if (!isAuthenticated.value) {
    showLoginRequiredModal.value = true
    return
  }
  
  if (!canCreateApprentissage.value) {
    showToast({
      title: 'Limite atteinte - Premium requis',
      message: `Vous avez atteint la limite de ${userLimits.value?.limits.apprentissages || 5} apprentissages. Achetez Premium pour créer des apprentissages illimités.`
    })
    return
  }
  
  selectedApprentissage.value = {
    id: '',
    competenceId,
    level,
    title: '',
    description: '',
    evaluation: 'Pas Maîtrisé',
    argumentaire: '',
    preuves: [],
    dateCreation: '',
    dateModification: '',
    categoryId
  }
  showApprentissageModal.value = true
}

const openEditApprentissageModal = (apprentissage: Apprentissage) => {
  selectedApprentissage.value = apprentissage
  showApprentissageModal.value = true
}

const closeApprentissageModal = () => {
  showApprentissageModal.value = false
  selectedApprentissage.value = null
}

const openAddCategoryModal = (competenceId: string, level: number) => {
  if (!isAuthenticated.value) {
    showLoginRequiredModal.value = true
    return
  }
  
  const competence = competences.value.find(c => c.id === competenceId)
  categoryModalData.value = {
    competenceId,
    level,
    competenceTitle: competence?.title || 'Compétence'
  }
  selectedCategory.value = null
  showCategoryModal.value = true
}

const openEditCategoryModal = (category: any) => {
  const competence = competences.value.find(c => c.id === category.competence_id)
  categoryModalData.value = {
    competenceId: category.competence_id,
    level: category.level,
    competenceTitle: competence?.title || 'Compétence'
  }
  selectedCategory.value = category
  showCategoryModal.value = true
}

const closeCategoryModal = () => {
  showCategoryModal.value = false
  selectedCategory.value = null
}

const openViewApprentissageModal = (apprentissage: Apprentissage) => {
  selectedViewApprentissage.value = apprentissage
  showViewModal.value = true
}

const closeViewModal = () => {
  showViewModal.value = false
  selectedViewApprentissage.value = null
}

const openProjectFromApprentissage = (projetId: string) => {
  const projet = projets.value.find(p => p.id === projetId)
  if (projet) {
    selectedProject.value = {
      id: projet.id,
      title: projet.titre,
      description: projet.description,
      technologies: projet.technologies || [],
      objectifs: ['Objectifs à définir'],
      realisations: projet.fonctionnalites || [],
      competences: [],
      duree: projet.duree,
      niveau: projet.niveau,
      fichiers: projet.fichiers || []
    }
    showProjectModal.value = true
  }
}

const closeProjectModal = () => {
  showProjectModal.value = false
  selectedProject.value = null
}

const closeLoginRequiredModal = () => {
  showLoginRequiredModal.value = false
}

const handleLoginFromModal = () => {
  showLoginRequiredModal.value = false
  openAuthModal()
}

const closeLimitModal = () => {
  showLimitModal.value = false
}

// CRUD operations
const saveCompetence = async (competence: Competence) => {
  if (!isAuthenticated.value) return
  
  try {
    if (competence.id && competences.value.find(c => c.id === competence.id)) {
      // Update existing competence
      const { data, error } = await competenceService.updateCompetence(competence.id, competence)
      if (!error && data) {
        const index = competences.value.findIndex(c => c.id === competence.id)
        if (index !== -1) {
          competences.value[index] = data
        }
        showToast({
          title: 'Compétence modifiée',
          message: 'La compétence a été mise à jour avec succès.'
        })
      }
    } else {
      // Create new competence
      const { data, error } = await competenceService.createCompetence(competence)
      if (!error && data) {
        competences.value.push(data)
        incrementCount('competences')
        setTimeout(() => checkTrophies(), 1000)
        showToast({
          title: 'Compétence créée',
          message: 'La nouvelle compétence a été ajoutée avec succès.'
        })
      }
    }
  } catch (error) {
    console.error('Error saving competence:', error)
    showToast({
      title: 'Erreur',
      message: 'Impossible de sauvegarder la compétence.'
    })
  }
  closeCompetenceModal()
}

const saveApprentissage = async (apprentissage: Apprentissage) => {
  if (!isAuthenticated.value) return
  
  // Check for duplicates
  const existingApprentissage = apprentissages.value.find(a => 
    a.title.toLowerCase() === apprentissage.title.toLowerCase() && 
    a.id !== apprentissage.id
  )
  
  if (existingApprentissage) {
    showDuplicateModal.value = {
      show: true,
      title: 'Titre déjà existant',
      message: 'Un apprentissage avec ce titre existe déjà.',
      existingItem: existingApprentissage
    }
    return
  }
  
  try {
    if (apprentissage.id) {
      // Update existing apprentissage
      const { data, error } = await apprentissageService.updateApprentissage(apprentissage.id, {
        competence_id: apprentissage.competenceId,
        level: apprentissage.level,
        title: apprentissage.title,
        description: apprentissage.description,
        evaluation: apprentissage.evaluation,
        argumentaire: apprentissage.argumentaire,
        category_id: apprentissage.categoryId,
        preuves: apprentissage.preuves
      })
      
      if (!error && data) {
        const index = apprentissages.value.findIndex(a => a.id === apprentissage.id)
        if (index !== -1) {
          apprentissages.value[index] = {
            ...apprentissage,
            dateModification: new Date().toISOString()
          }
        }
        showToast({
          title: 'Apprentissage modifié',
          message: 'L\'apprentissage a été mis à jour avec succès.'
        })
      }
    } else {
      // Create new apprentissage
      const { data, error } = await apprentissageService.createApprentissage(apprentissage)
      if (!error && data) {
        apprentissages.value.push({
          ...apprentissage,
          id: data.id,
          dateCreation: data.created_at,
          dateModification: data.updated_at
        })
        incrementCount('apprentissages')
        setTimeout(() => checkTrophies(), 1000)
        showToast({
          title: 'Apprentissage créé',
          message: 'Le nouvel apprentissage a été ajouté avec succès.'
        })
      }
    }
  } catch (error) {
    console.error('Error saving apprentissage:', error)
    showToast({
      title: 'Erreur',
      message: 'Impossible de sauvegarder l\'apprentissage.'
    })
  }
  closeApprentissageModal()
}

const saveCategory = async (category: any) => {
  if (!isAuthenticated.value) return
  
  try {
    if (category.id) {
      // Update existing category
      const { data, error } = await apprentissageCategoryService.updateCategory(category.id, {
        title: category.title,
        description: category.description
      })
      if (!error && data) {
        const index = categories.value.findIndex(c => c.id === category.id)
        if (index !== -1) {
          categories.value[index] = data
        }
        showToast({
          title: 'Apprentissage critique modifié',
          message: 'L\'apprentissage critique a été mis à jour avec succès.'
        })
      }
    } else {
      // Create new category
      const { data, error } = await apprentissageCategoryService.createCategory({
        competenceId: category.competence_id,
        level: category.level,
        title: category.title,
        description: category.description
      })
      if (!error && data) {
        categories.value.push(data)
        showToast({
          title: 'Apprentissage critique créé',
          message: 'Le nouvel apprentissage critique a été ajouté avec succès.'
        })
      }
    }
  } catch (error) {
    console.error('Error saving category:', error)
    showToast({
      title: 'Erreur',
      message: 'Impossible de sauvegarder l\'apprentissage critique.'
    })
  }
  closeCategoryModal()
}

// Delete operations
const deleteCompetence = (competenceId: string) => {
  const competence = competences.value.find(c => c.id === competenceId)
  if (competence) {
    confirmModalData.value = {
      title: 'Supprimer la compétence',
      message: `Êtes-vous sûr de vouloir supprimer la compétence "${competence.title}" ? Tous les apprentissages associés seront également supprimés.`,
      action: () => confirmDeleteCompetence(competenceId)
    }
    showConfirmModal.value = true
  }
}

const confirmDeleteCompetence = async (competenceId: string) => {
  try {
    // Delete related apprentissages first
    await apprentissageService.deleteApprentissagesByCompetence(competenceId)
    
    // Delete competence
    const { error } = await competenceService.deleteCompetence(competenceId)
    if (!error) {
      competences.value = competences.value.filter(c => c.id !== competenceId)
      apprentissages.value = apprentissages.value.filter(a => a.competenceId !== competenceId)
      decrementCount('competences')
      showToast({
        title: 'Compétence supprimée',
        message: 'La compétence et ses apprentissages ont été supprimés.'
      })
    }
  } catch (error) {
    console.error('Error deleting competence:', error)
    showToast({
      title: 'Erreur',
      message: 'Impossible de supprimer la compétence.'
    })
  }
}

const deleteApprentissage = (apprentissageId: string) => {
  const apprentissage = apprentissages.value.find(a => a.id === apprentissageId)
  if (apprentissage) {
    confirmModalData.value = {
      title: 'Supprimer l\'apprentissage',
      message: `Êtes-vous sûr de vouloir supprimer l'apprentissage "${apprentissage.title}" ?`,
      action: () => confirmDeleteApprentissage(apprentissageId)
    }
    showConfirmModal.value = true
  }
}

const confirmDeleteApprentissage = async (apprentissageId: string) => {
  try {
    const { error } = await apprentissageService.deleteApprentissage(apprentissageId)
    if (!error) {
      apprentissages.value = apprentissages.value.filter(a => a.id !== apprentissageId)
      featuredApprentissages.value = featuredApprentissages.value.filter(id => id !== apprentissageId)
      decrementCount('apprentissages')
      showToast({
        title: 'Apprentissage supprimé',
        message: 'L\'apprentissage a été supprimé avec succès.'
      })
    }
  } catch (error) {
    console.error('Error deleting apprentissage:', error)
    showToast({
      title: 'Erreur',
      message: 'Impossible de supprimer l\'apprentissage.'
    })
  }
}

const deleteCategory = (categoryId: string) => {
  const category = categories.value.find(c => c.id === categoryId)
  if (category) {
    confirmModalData.value = {
      title: 'Supprimer l\'apprentissage critique',
      message: `Êtes-vous sûr de vouloir supprimer l'apprentissage critique "${category.title}" ? Les apprentissages qu'il contient ne seront pas supprimés.`,
      action: () => confirmDeleteCategory(categoryId)
    }
    showConfirmModal.value = true
  }
}

const confirmDeleteCategory = async (categoryId: string) => {
  try {
    const { error } = await apprentissageCategoryService.deleteCategory(categoryId)
    if (!error) {
      categories.value = categories.value.filter(c => c.id !== categoryId)
      // Remove category reference from apprentissages
      apprentissages.value.forEach(a => {
        if (a.categoryId === categoryId) {
          a.categoryId = undefined
        }
      })
      showToast({
        title: 'Apprentissage critique supprimé',
        message: 'L\'apprentissage critique a été supprimé avec succès.'
      })
    }
  } catch (error) {
    console.error('Error deleting category:', error)
    showToast({
      title: 'Erreur',
      message: 'Impossible de supprimer l\'apprentissage critique.'
    })
  }
}

// Featured apprentissages
const toggleFeaturedApprentissage = async (apprentissage: Apprentissage) => {
  if (!isAuthenticated.value) return
  
  const user = await authService.getCurrentUser()
  if (!user) return
  
  const isFeatured = featuredApprentissages.value.includes(apprentissage.id)
  
  try {
    if (isFeatured) {
      // Remove from featured
      const { error } = await featuredApprentissageService.removeFeaturedApprentissage(user.id, apprentissage.id)
      if (!error) {
        featuredApprentissages.value = featuredApprentissages.value.filter(id => id !== apprentissage.id)
        showToast({
          title: 'Retiré des vedettes',
          message: 'L\'apprentissage a été retiré des vedettes.'
        })
      }
    } else {
      // Add to featured (check limit)
      if (featuredApprentissages.value.length >= 6) {
        showLimitModal.value = true
        return
      }
      
      const { error } = await featuredApprentissageService.addFeaturedApprentissage(
        user.id, 
        apprentissage.id, 
        featuredApprentissages.value.length + 1
      )
      if (!error) {
        featuredApprentissages.value.push(apprentissage.id)
        showToast({
          title: 'Ajouté aux vedettes',
          message: 'L\'apprentissage a été épinglé en vedette.'
        })
      }
    }
  } catch (error) {
    console.error('Error toggling featured:', error)
    showToast({
      title: 'Erreur',
      message: 'Impossible de modifier le statut vedette.'
    })
  }
}

// Confirm modal handlers
const confirmAction = () => {
  if (confirmModalData.value.action) {
    confirmModalData.value.action()
  }
  cancelAction()
}

const cancelAction = () => {
  showConfirmModal.value = false
  confirmModalData.value = { title: '', message: '', action: null }
}

// Toast notification
const showToast = (data: { title: string, message: string }) => {
  toastData.value = data
  showToastNotification.value = true
}

const closeToast = () => {
  showToastNotification.value = false
}

// Duplicate modal
const editExistingItem = () => {
  showDuplicateModal.value.show = false
  if (showDuplicateModal.value.existingItem) {
    if ('competenceId' in showDuplicateModal.value.existingItem) {
      // It's an apprentissage
      openEditApprentissageModal(showDuplicateModal.value.existingItem)
    } else {
      // It's a competence
      openEditCompetenceModal(showDuplicateModal.value.existingItem)
    }
  }
}

// Export functionality
const handleExportClick = async () => {
  if (!userLimits.value?.isPremium) {
    showToast({
      title: 'Premium Requis',
      message: 'L\'export Excel est réservé aux utilisateurs Premium.'
    })
    return
  }
  
  if (!isAuthenticated.value || !userProfile.value) {
    showToast({
      title: 'Erreur',
      message: 'Données utilisateur manquantes pour l\'export.'
    })
    return
  }
  
  exportLoading.value = true
  
  try {
    const exportData = prepareExportData(
      userProfile.value,
      competences.value,
      apprentissages.value,
      projets.value,
      categories.value
    )
    
    await exportPortfolioToExcel(exportData)
    
    showToast({
      title: 'Export réussi !',
      message: 'Votre portfolio a été exporté avec succès au format Excel.'
    })
  } catch (error) {
    console.error('Erreur lors de l\'export:', error)
    showToast({
      title: 'Erreur d\'export',
      message: 'Une erreur est survenue lors de l\'export.'
    })
  } finally {
    exportLoading.value = false
  }
}

// Utility functions
const scrollToTop = () => {
  window.scrollTo({ top: 0, behavior: 'smooth' })
}
</script>

<style scoped>
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes slideUp {
  from { opacity: 0; transform: translateY(40px); }
  to { opacity: 1; transform: translateY(0); }
}

.animate-fade-in {
  animation: fadeIn 0.8s ease-out;
}

.animate-slide-up {
  animation: slideUp 1s ease-out 0.2s both;
}

/* Global drag and drop styles */
:global(.dragging) {
  cursor: grabbing !important;
}

:global(.dragging *) {
  cursor: grabbing !important;
}

:global(.drag-preview) {
  position: fixed;
  z-index: 9999;
  pointer-events: none;
  transform: rotate(5deg);
  opacity: 0.9;
}
</style>