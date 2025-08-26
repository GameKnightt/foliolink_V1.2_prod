<template>
  <div class="pt-16 min-h-screen bg-gray-50 dark:bg-gray-900">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <!-- Header -->
      <div class="text-center mb-12">
        <h1 class="text-4xl md:text-5xl font-bold text-gray-900 dark:text-white mb-6">
          Portfolio de <span class="gradient-text text-glow">Compétences BUT</span>
        </h1>
        <p class="text-xl text-gray-600 dark:text-gray-300 max-w-3xl mx-auto mb-8">
          Présentation détaillée de mes compétences BUT avec apprentissages critiques et preuves de maîtrise
        </p>
        
        <!-- Filters and Search -->
        <div class="flex flex-col gap-4 justify-center items-center max-w-4xl mx-auto">
          <!-- First row: Search and filters -->
          <div class="flex flex-col sm:flex-row gap-4 justify-center items-center w-full">
            <div class="relative flex-1 w-full sm:w-auto min-w-[280px]">
              <MagnifyingGlassIcon class="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
              <input
                v-model="searchTerm"
                type="text"
                placeholder="Rechercher"
                class="input-field pl-10 h-12 text-base"
              />
            </div>
            <select v-model="selectedCompetenceFilter" class="input-field w-full sm:w-auto h-12 min-w-[200px]">
              <option value="">Toutes les compétences</option>
              <option v-for="comp in competences" :key="comp.id" :value="comp.id">
                {{ comp.title }}
              </option>
            </select>
            <select v-model="sortBy" class="input-field w-full sm:w-auto h-12 min-w-[150px]">
              <option value="default">Tri par défaut</option>
              <option value="title">Titre A-Z</option>
              <option value="recent">Plus récents</option>
              <option value="evaluation">Évaluation</option>
              <option value="level">Par niveau</option>
            </select>
            <select v-model="filterFeatured" class="input-field w-full sm:w-auto h-12 min-w-[180px]">
              <option value="">Tous les apprentissages</option>
              <option value="featured">Apprentissages vedettes ⭐</option>
              <option value="not-featured">Non mis en vedette</option>
            </select>
          </div>
          
          <!-- Second row: Action buttons -->
          <div class="flex flex-col sm:flex-row gap-4 justify-center items-center w-full">
            <!-- Mobile Action Menu for authenticated users -->
            <MobileActionMenu v-if="isAuthenticated" title="Actions" icon="⚙️">
              <!-- Desktop Buttons -->
              <template #desktop-buttons>
                <button 
                  @click="handleAddCompetenceClick"
                  class="btn-primary whitespace-nowrap h-12 px-6 text-sm font-semibold flex items-center justify-center relative group transition-all duration-300"
                  :class="{ 'opacity-60 cursor-not-allowed filter blur-[1px]': !canCreateCompetence }"
                >
                  <div v-if="!canCreateCompetence" class="absolute -top-2 -right-2 w-7 h-7 bg-red-500 rounded-full flex items-center justify-center shadow-lg z-10">
                    <span class="text-white text-sm">🔒</span>
                  </div>
                  <div v-if="!canCreateCompetence" class="absolute inset-0 bg-gray-500/20 backdrop-blur-[1px] rounded-xl pointer-events-none"></div>
                  <PlusIcon class="w-4 h-4 mr-2" />
                  Ajouter Compétence
                </button>
                <ButProgramsDropdown />
                <button 
                  v-if="userLimits?.isPremium"
                  @click="handleExportClick"
                  :disabled="exportLoading"
                  class="btn-secondary whitespace-nowrap h-12 px-6 text-sm font-semibold flex items-center justify-center"
                >
                  <ArrowDownTrayIcon class="w-4 h-4 mr-2" />
                  {{ exportLoading ? 'Export...' : 'Exporter Excel' }}
                </button>
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
                  <PlusIcon class="w-4 h-4 mr-2" />
                  Ajouter Compétence
                </button>
                
                <div class="w-full">
                  <ButProgramsDropdown />
                </div>
                
                <button 
                  v-if="userLimits?.isPremium"
                  @click="handleExportClick"
                  :disabled="exportLoading"
                  class="w-full btn-secondary h-12 px-4 text-sm font-semibold flex items-center justify-center"
                >
                  <ArrowDownTrayIcon class="w-4 h-4 mr-2" />
                  {{ exportLoading ? 'Export...' : 'Exporter Excel' }}
                </button>
              </template>
            </MobileActionMenu>
            
            <!-- Non-authenticated user buttons -->
            <div v-else class="flex flex-col sm:flex-row gap-4 justify-center items-center w-full">
              <ButProgramsDropdown />
            </div>
          </div>
        
          <!-- Limits Display for Non-Premium Users -->
          <div v-if="userLimits && !userLimits.isPremium && isAuthenticated" class="mt-8 max-w-2xl mx-auto">
            <div class="glass-card p-4">
              <div class="flex items-center justify-between">
                <div class="flex items-center space-x-4">
                  <LimitCounter 
                    type="competences"
                    :current="userLimits.current.competences"
                    :max="userLimits.limits.competences"
                    :is-premium="userLimits.isPremium"
                  />
                  <LimitCounter 
                    type="apprentissages"
                    :current="userLimits.current.apprentissages"
                    :max="userLimits.limits.apprentissages"
                    :is-premium="userLimits.isPremium"
                  />
                </div>
                <router-link to="/pricing" class="text-accent-400 hover:text-accent-300 text-sm font-medium transition-colors">
                  Acheter Premium →
                </router-link>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Competences -->
      <div class="space-y-12">
        <div 
          v-for="competence in filteredCompetences" 
          :key="competence.id"
          class="animate-slide-up"
        >
          <CompetenceSection 
            :competence="competence"
            :apprentissages="getApprentissagesForCompetence(competence.id)"
            :featured-apprentissages="featuredApprentissages"
            :user-limits="userLimits"
            :categories="categories"
            :is-authenticated="isAuthenticated"
            @add-apprentissage="handleAddApprentissageWithCategory"
            @show-premium-notification="handleShowPremiumNotification"
            @edit-apprentissage="openEditModal"
            @delete-apprentissage="deleteApprentissage"
            @view-apprentissage="openViewModal"
            @open-project="openProjectFromApprentissage"
            @toggle-featured="toggleFeaturedApprentissage"
            @edit-competence="openEditCompetenceModal"
            @delete-competence="deleteCompetence"
            @add-category="openAddCategoryModal"
            @edit-category="openEditCategoryModal"
            @delete-category="deleteCategory"
          >
            <template #add-button="{ competenceId, level }">
              <button 
                v-if="isAuthenticated"
                @click="openAddModal(competenceId, level)"
                class="btn-secondary text-sm px-4 py-2 flex items-center space-x-2"
              >
                <PlusIcon class="w-4 h-4" />
                <span>Ajouter un apprentissage détaillé</span>
              </button>
              <div 
                v-else
                @click="() => { router.push('/'); openAuthModal() }"
                class="text-accent-400 hover:text-accent-300 cursor-pointer transition-colors"
              >
                Connectez-vous pour ajouter des apprentissages détaillés
              </div>
            </template>
            <template #apprentissage-actions="{ apprentissage }">
              <button 
                v-if="isAuthenticated"
                @click="openEditModal(apprentissage)"
                @click.stop
                class="p-1 text-gray-400 hover:text-primary-600 dark:hover:text-primary-400 opacity-0 group-hover:opacity-100 transition-opacity"
                title="Modifier"
              >
                <PencilIcon class="w-4 h-4" />
              </button>
              <button 
                v-if="isAuthenticated"
                @click="deleteApprentissage(apprentissage.id)"
                @click.stop
                class="p-1 text-gray-400 hover:text-red-600 dark:hover:text-red-400 opacity-0 group-hover:opacity-100 transition-opacity"
                title="Supprimer"
              >
                <TrashIcon class="w-4 h-4" />
              </button>
              <button 
                v-if="isAuthenticated"
                @click="toggleFeaturedApprentissage(apprentissage)"
                @click.stop
                class="p-1 transition-opacity"
                :class="featuredApprentissages.includes(apprentissage.id) ? 'text-accent-400 opacity-100' : 'text-gray-400 hover:text-accent-400 opacity-0 group-hover:opacity-100'"
                :title="featuredApprentissages.includes(apprentissage.id) ? 'Retirer des vedettes' : 'Épingler en vedette'"
              >
                <span class="text-sm">{{ featuredApprentissages.includes(apprentissage.id) ? '⭐' : '☆' }}</span>
              </button>
            </template>
          </CompetenceSection>
        </div>
      </div>

      <!-- Add/Edit Modal -->
      <ApprentissageModal
        v-if="showModal"
        :apprentissage="selectedApprentissage"
        :competences="competences"
        :projets="projets"
        :categories="categories"
        @save="saveApprentissage"
        @close="closeModal"
      />

      <!-- View Modal -->
      <ApprentissageViewModal
        v-if="showViewModal"
        :apprentissage="viewApprentissage"
        :competences="competences"
        @close="closeViewModal"
        @edit="editFromView"
        @open-project="openProjectFromApprentissage"
      >
        <template #edit-button>
          <button 
            v-if="isAuthenticated"
            @click="editFromView"
            class="btn-secondary flex items-center space-x-2"
          >
            <PencilIcon class="w-4 h-4" />
            <span>Modifier</span>
          </button>
        </template>
      </ApprentissageViewModal>

      <!-- Confirm Delete Modal -->
      <ConfirmModal
        v-if="showConfirmModal"
        title="Supprimer l'apprentissage critique"
        message="Êtes-vous sûr de vouloir supprimer cet apprentissage critique ? Cette action est irréversible."
        @confirm="confirmDelete"
        @cancel="cancelDelete"
      />

      <!-- Confirm Delete Competence Modal -->
      <ConfirmModal
        v-if="showCompetenceConfirmModal"
        title="Supprimer la compétence"
        message="Êtes-vous sûr de vouloir supprimer cette compétence ? Tous les apprentissages associés seront également supprimés. Cette action est irréversible."
        @confirm="confirmDeleteCompetence"
        @cancel="cancelDeleteCompetence"
      />

      <!-- Competence Modal -->
      <CompetenceModal
        v-if="showCompetenceModal"
        :competence="selectedCompetenceForModal"
        @save="saveCompetence"
        @close="closeCompetenceModal"
      />

      <!-- Project Modal -->
      <ProjectModal
        v-if="showProjectModal && selectedProject"
        :project="getProjectDetails(selectedProject)"
        @close="closeProjectModal"
      />

      <!-- Limit Modal -->
      <LimitModal
        v-if="showLimitModal"
        @close="showLimitModal = false"
      />

      <!-- Duplicate Modal -->
      <DuplicateModal
        v-if="showDuplicateModal.show"
        :title="showDuplicateModal.title"
        :message="showDuplicateModal.message"
        @close="showDuplicateModal.show = false"
        @edit-existing="editExistingItem"
      />
      
      <!-- Premium Limit Modal -->
      <PremiumNotification
        v-if="showPremiumNotification"
        :title="premiumNotificationData.title"
        :message="premiumNotificationData.message"
        :duration="5000"
        @close="showPremiumNotification = false"
      />
      
      <!-- Category Modal -->
      <CategoryModal
        v-if="showCategoryModal"
        :category="selectedCategory"
        :competence-id="categoryCompetenceId"
        :level="categoryLevel"
        :competence-title="getCompetenceTitle(categoryCompetenceId)"
        @save="saveCategory"
        @close="closeCategoryModal"
      />
      
      <!-- Confirm Delete Category Modal -->
      <ConfirmModal
        v-if="showCategoryConfirmModal"
        title="Supprimer l'apprentissage critique"
        message="Êtes-vous sûr de vouloir supprimer cet apprentissage critique ? Les apprentissages ne seront pas supprimés mais deviendront non catégorisés."
        @confirm="confirmDeleteCategory"
        @cancel="cancelDeleteCategory"
      />
      
      <!-- Trophy Modal -->
      <TrophyModal
        v-if="showTrophyModal"
        :new-trophies="newTrophies"
        :current-level="currentLevel"
        :total-points="0"
        @close="closeTrophyModal"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { MagnifyingGlassIcon, PlusIcon, PencilIcon, TrashIcon, ArrowDownTrayIcon } from '@heroicons/vue/24/outline'
import CompetenceSection from '../components/CompetenceSection.vue'
import ApprentissageModal from '../components/ApprentissageModal.vue'
import ApprentissageViewModal from '../components/ApprentissageViewModal.vue'
import ConfirmModal from '../components/ConfirmModal.vue'
import ProjectModal from '../components/ProjectModal.vue'
import CompetenceModal from '../components/CompetenceModal.vue'
import LimitModal from '../components/LimitModal.vue'
import DuplicateModal from '../components/DuplicateModal.vue'
import LimitCounter from '../components/LimitCounter.vue'
import PremiumLimitModal from '../components/PremiumLimitModal.vue'
import PremiumNotification from '../components/PremiumNotification.vue'
import CategoryModal from '../components/CategoryModal.vue'
import TrophyModal from '../components/TrophyModal.vue'
import ButProgramsDropdown from '../components/ButProgramsDropdown.vue'
import MobileActionMenu from '../components/MobileActionMenu.vue'
import { exportPortfolioToExcel, prepareExportData } from '../lib/excelExport'
import { type Competence, type Apprentissage, type Projet } from '../data/portfolio'
import { authService, exampleDataService, competenceService, apprentissageService, projetService, profileService, apprentissageCategoryService } from '../lib/supabase'
import { featuredApprentissageService } from '../lib/supabase'
import { usePremiumLimits } from '../composables/usePremiumLimits'
import { useGamification } from '../composables/useGamification'
import { useAuth } from '../composables/useAuth'

const route = useRoute()
const router = useRouter()
const { openAuthModal } = useAuth()

const searchTerm = ref('')
const selectedCompetenceFilter = ref('')
const sortBy = ref('default')
const filterFeatured = ref('')
const showModal = ref(false)
const showViewModal = ref(false)
const showConfirmModal = ref(false)
const showProjectModal = ref(false)
const selectedApprentissage = ref<Apprentissage | null>(null)
const viewApprentissage = ref<Apprentissage | null>(null)
const selectedProject = ref<Projet | null>(null)
const showCompetenceModal = ref(false)
const selectedCompetenceForModal = ref<Competence | null>(null)
const apprentissageToDelete = ref<string | null>(null)
const showCompetenceConfirmModal = ref(false)
const competenceToDelete = ref<string | null>(null)
const showLimitModal = ref(false)
const showDuplicateModal = ref({
  show: false,
  title: '',
  message: '',
  existingItem: null
})
const competences = ref<Competence[]>([])
const apprentissages = ref<Apprentissage[]>([])
const projets = ref<Projet[]>([])
const featuredApprentissages = ref<string[]>([])
const categories = ref<any[]>([])

const isAuthenticated = ref(false)

const { userLimits, loadUserLimits, canCreate, incrementCount, incrementCountBy, decrementCount, decrementCountBy, checkLimit } = usePremiumLimits()

// Gamification
const { 
  newTrophies,
  showTrophyModal,
  currentLevel,
  loadUserStats: loadGamificationStats,
  checkTrophies,
  closeTrophyModal
} = useGamification()

const showPremiumModal = ref(false)
const premiumModalType = ref<'competences' | 'apprentissages' | 'projets' | 'export'>('competences')
const showPremiumNotification = ref(false)
const premiumNotificationData = ref({ title: '', message: '' })
const exportLoading = ref(false)
const userProfile = ref<any>(null)
const showCategoryModal = ref(false)
const selectedCategory = ref<any>(null)
const categoryCompetenceId = ref('')
const categoryLevel = ref(1)
const showCategoryConfirmModal = ref(false)
const categoryToDelete = ref<string | null>(null)

const canCreateCompetence = computed(() => canCreate.value.competences)
const canCreateApprentissage = computed(() => canCreate.value.apprentissages)

// Check authentication status
onMounted(async () => {
  const user = await authService.getCurrentUser()
  isAuthenticated.value = !!user
  
  // Load user limits immediately if authenticated
  if (isAuthenticated.value) {
    await loadUserLimits()
    await loadGamificationStats()
  }
  
  // Load data based on authentication status
  if (isAuthenticated.value) {
    await loadUserData()
  } else {
    await loadExampleData()
  }
  
  // Check if we need to scroll to a specific competence
  const competenceParam = route.query.competence as string
  const apprentissageParam = route.query.apprentissage as string
  
  if (competenceParam) {
    selectedCompetenceFilter.value = competenceParam
    setTimeout(() => {
      const element = document.getElementById(`competence-${competenceParam}`)
      element?.scrollIntoView({ behavior: 'smooth' })
      
      // If specific apprentissage is requested, open its modal
      if (apprentissageParam) {
        const apprentissage = apprentissages.value.find(a => a.id === apprentissageParam)
        if (apprentissage) {
          setTimeout(() => {
            openViewModal(apprentissage)
          }, 500)
        }
      }
    }, 100)
  }
})

const loadUserData = async () => {
  const user = await authService.getCurrentUser()
  if (!user) return
  
  // Load profile
  const { data: profile } = await profileService.getProfile(user.id)
  if (profile) {
    userProfile.value = profile
  }
  
  // Load user's competences - start with empty array for new users
  competences.value = []
  
  // Load competences from database (includes user's custom + public ones)
  const { data: userCompetences } = await competenceService.getCompetences()
  if (userCompetences && userCompetences.length > 0) {
    competences.value = userCompetences
  }
  
  // Migrate localStorage competences to database if they exist
  const savedCompetences = localStorage.getItem('user_competences')
  if (savedCompetences) {
    try {
      const parsedCompetences = JSON.parse(savedCompetences)
      if (Array.isArray(parsedCompetences) && parsedCompetences.length > 0) {
        // Migrate each competence to database
        for (const comp of parsedCompetences) {
          // Check if competence already exists in database
          const existsInDatabase = competences.value.some(existing => existing.id === comp.id)
          if (!existsInDatabase) {
            try {
              await competenceService.createCompetence(comp)
            } catch (error) {
              console.warn('Competence migration failed:', comp.id, error)
            }
          }
        }
        // Clear localStorage after successful migration
        localStorage.removeItem('user_competences')
        // Reload competences from database
        const { data: updatedCompetences } = await competenceService.getCompetences()
        if (updatedCompetences) {
          competences.value = updatedCompetences
        }
      }
    } catch (error) {
      console.error('Error parsing saved competences:', error)
    }
  }
  
  const { data: userApprentissages } = await apprentissageService.getUserApprentissages(user.id)
  const { data: userProjets } = await projetService.getUserProjets(await authService.getCurrentUser().then(u => u?.id || ''))
  
  if (userApprentissages) {
    apprentissages.value = userApprentissages.map(app => ({
      id: app.id,
      competenceId: app.competence_id,
      level: app.level,
      title: app.title,
      description: app.description,
      evaluation: app.evaluation,
      argumentaire: app.argumentaire,
      categoryId: app.category_id,
      preuves: app.preuves?.map(preuve => ({
        id: preuve.id,
        titre: preuve.titre,
        type: preuve.type as 'Rapport' | 'Code' | 'Projet' | 'Présentation' | 'Documentation' | 'Autre',
        url: preuve.url,
        projetId: preuve.projet_id
      })) || [],
      dateCreation: app.created_at,
      dateModification: app.updated_at
    }))
    
  }
  if (userProjets) projets.value = userProjets
  
  // Load featured apprentissages
  const { data: featured } = await featuredApprentissageService.getFeaturedApprentissages(user.id)
  if (featured) {
    featuredApprentissages.value = featured.map(f => f.apprentissage_id)
  }
  
  // Load categories
  const { data: userCategories } = await apprentissageCategoryService.getUserCategories(user.id)
  if (userCategories) {
    categories.value = userCategories
  }
}

const loadExampleData = async () => {
  try {
    // Load example data for non-authenticated users
    const { data: exampleCompetences } = await exampleDataService.getExampleCompetences()
    const { data: exampleApprentissages } = await exampleDataService.getExampleApprentissages()
    const { data: exampleProjets } = await exampleDataService.getExampleProjets()
    
    if (exampleCompetences && exampleCompetences.length > 0) {
      competences.value = exampleCompetences.map(comp => ({
        id: comp.id,
        title: comp.title,
        subtitle: comp.subtitle,
        description: comp.description,
        levels: comp.levels,
        color: comp.color as 'primary' | 'accent',
        icon: comp.icon
      }))
    } else {
      // Fallback competences data
      competences.value = [
        {
          id: 'concevoir',
          title: 'Concevoir',
          subtitle: 'Conception de systèmes',
          description: 'Concevoir l\'architecture matérielle et logicielle d\'un système',
          levels: 3,
          color: 'primary' as const,
          icon: '🎯'
        }
      ]
    }
    
    if (exampleApprentissages && exampleApprentissages.length > 0) {
      apprentissages.value = exampleApprentissages.map(app => ({
        id: app.id,
        competenceId: app.competence_id,
        level: app.level,
        title: app.title,
        description: app.description,
        evaluation: app.evaluation as 'Bien Maîtrisé' | 'Partiellement Maîtrisé' | 'Pas Maîtrisé',
        argumentaire: app.argumentaire,
        categoryId: app.category_id,
        preuves: app.example_preuves?.map((preuve: any) => ({
          id: preuve.id,
          titre: preuve.titre,
          type: preuve.type as 'Rapport' | 'Code' | 'Projet' | 'Présentation' | 'Documentation' | 'Autre',
          url: preuve.url,
          projetId: preuve.projet_id
        })) || [],
        dateCreation: app.created_at,
        dateModification: app.created_at
      }))
    } else {
      apprentissages.value = []
    }
    
    if (exampleProjets && exampleProjets.length > 0) {
      projets.value = exampleProjets.map(projet => ({
        id: projet.id,
        titre: projet.titre,
        description: projet.description,
        icone: projet.icone,
        niveau: projet.niveau,
        duree: projet.duree,
        fonctionnalites: projet.fonctionnalites || [],
        technologies: projet.technologies || [],
        fichiers: [],
        dateCreation: projet.created_at,
        statut: projet.statut as 'En cours' | 'Terminé' | 'Archivé'
      }))
    } else {
      projets.value = []
    }
  } catch (error) {
    console.error('Error loading example data:', error)
    // Set empty arrays as fallback
    competences.value = []
    apprentissages.value = []
    projets.value = []
  }
}
const requireAuth = (action: () => void) => {
  if (!isAuthenticated.value) {
    alert('Vous devez être connecté pour effectuer cette action.')
    router.push('/')
    return
  }
  action();
}

const filteredCompetences = computed(() => {
  let filtered = competences.value

  if (selectedCompetenceFilter.value) {
    filtered = filtered.filter(comp => comp.id === selectedCompetenceFilter.value)
  }

  // Apply search filter
  if (searchTerm.value) {
    const searchLower = searchTerm.value.toLowerCase()
    filtered = filtered.filter(comp => 
      comp.title.toLowerCase().includes(searchLower) ||
      comp.subtitle.toLowerCase().includes(searchLower) ||
      comp.description.toLowerCase().includes(searchLower)
    )
  }

  // If filtering by featured, only show competences that have featured apprentissages
  if (filterFeatured.value === 'featured') {
    filtered = filtered.filter(comp => {
      const competenceApprentissages = apprentissages.value.filter(app => app.competenceId === comp.id)
      return competenceApprentissages.some(app => featuredApprentissages.value.includes(app.id))
    })
  }

  // Apply sorting
  if (sortBy.value === 'title') {
    filtered.sort((a, b) => a.title.localeCompare(b.title))
  } else if (sortBy.value === 'recent') {
    // Sort by most recent apprentissages in each competence
    filtered.sort((a, b) => {
      const aLatest = getLatestApprentissageDate(a.id)
      const bLatest = getLatestApprentissageDate(b.id)
      return new Date(bLatest).getTime() - new Date(aLatest).getTime()
    })
  }

  return filtered
})

const getApprentissagesForCompetence = (competenceId: string) => {
  let filtered = apprentissages.value.filter(app => {
    const matchesCompetence = app.competenceId === competenceId
    
    // Search is now handled at competence level, so we don't filter apprentissages here
    // unless we want to search within apprentissages of visible competences
    let matchesSearch = true
    if (searchTerm.value && !selectedCompetenceFilter.value) {
      // Only apply apprentissage search if no specific competence is selected
      const searchLower = searchTerm.value.toLowerCase()
      matchesSearch = app.title.toLowerCase().includes(searchLower) ||
        app.description.toLowerCase().includes(searchLower) ||
        app.argumentaire.toLowerCase().includes(searchLower)
    }
    
    // Apply featured filter
    let matchesFeatured = true
    if (filterFeatured.value === 'featured') {
      matchesFeatured = featuredApprentissages.value.includes(app.id)
    } else if (filterFeatured.value === 'not-featured') {
      matchesFeatured = !featuredApprentissages.value.includes(app.id)
    }
    
    return matchesCompetence && matchesSearch && matchesFeatured
  })
  
  // Apply sorting
  if (sortBy.value === 'title' || sortBy.value === 'default') {
    filtered.sort((a, b) => a.title.localeCompare(b.title))
  } else if (sortBy.value === 'recent') {
    filtered.sort((a, b) => new Date(b.dateModification).getTime() - new Date(a.dateModification).getTime())
  } else if (sortBy.value === 'evaluation') {
    const evaluationOrder = { 'Bien Maîtrisé': 3, 'Partiellement Maîtrisé': 2, 'Pas Maîtrisé': 1 }
    filtered.sort((a, b) => evaluationOrder[b.evaluation] - evaluationOrder[a.evaluation])
  } else if (sortBy.value === 'level') {
    filtered.sort((a, b) => a.level - b.level)
  }
  
  return filtered
}

const openAddModal = (competenceId: string, level: number) => {
  if (!isAuthenticated.value) {
    router.push('/')
    openAuthModal()
    return
  }
  
  if (!canCreateApprentissage.value) {
    showPremiumNotification.value = true
    premiumNotificationData.value = {
      title: 'Limite atteinte - Premium requis',
      message: `Vous avez atteint la limite de ${userLimits.value?.limits.apprentissages || 5} apprentissages. Achetez FolioLink Premium pour créer des apprentissages illimités.`
    }
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
    dateCreation: new Date().toISOString(),
    dateModification: new Date().toISOString()
  }
  showModal.value = true
}

// Overloaded function to handle category assignment
const openAddModalWithCategory = (competenceId: string, level: number, categoryId?: string) => {
  if (!isAuthenticated.value) {
    router.push('/')
    openAuthModal()
    return
  }
  
  if (!canCreateApprentissage.value) {
    showPremiumNotification.value = true
    premiumNotificationData.value = {
      title: 'Limite atteinte - Premium requis',
      message: `Vous avez atteint la limite de ${userLimits.value?.limits.apprentissages || 5} apprentissages. Achetez FolioLink Premium pour créer des apprentissages illimités.`
    }
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
    dateCreation: new Date().toISOString(),
    dateModification: new Date().toISOString(),
    categoryId: categoryId
  }
  showModal.value = true
}

const handleAddApprentissageClick = (competenceId: string, level: number) => {
  if (!canCreateApprentissage.value) {
    showPremiumNotification.value = true
    premiumNotificationData.value = {
      title: 'Limite atteinte - Premium requis',
      message: `Vous avez atteint la limite de ${userLimits.value?.limits.apprentissages || 5} apprentissages. Achetez FolioLink Premium pour créer des apprentissages illimités.`
    }
    return
  }
  openAddModal(competenceId, level)
}

// New handler for apprentissage with optional category
const handleAddApprentissageWithCategory = (competenceId: string, level: number, categoryId?: string) => {
  if (!canCreateApprentissage.value) {
    showPremiumNotification.value = true
    premiumNotificationData.value = {
      title: 'Limite atteinte - Premium requis',
      message: `Vous avez atteint la limite de ${userLimits.value?.limits.apprentissages || 5} apprentissages. Achetez FolioLink Premium pour créer des apprentissages illimités.`
    }
    return
  }
  
  if (categoryId) {
    openAddModalWithCategory(competenceId, level, categoryId)
  } else {
    openAddModal(competenceId, level)
  }
}

const openEditModal = (apprentissage: Apprentissage) => {
  requireAuth(() => {
    selectedApprentissage.value = { ...apprentissage }
    showModal.value = true
  })
}

const openViewModal = (apprentissage: Apprentissage) => {
  viewApprentissage.value = apprentissage
  showViewModal.value = true
}

const closeViewModal = () => {
  showViewModal.value = false
  viewApprentissage.value = null
}

const editFromView = () => {
  requireAuth(() => {
    if (viewApprentissage.value) {
      const apprentissageToEdit = { ...viewApprentissage.value }
      closeViewModal()
      openEditModal(apprentissageToEdit)
    }
  })
}

const closeModal = () => {
  showModal.value = false
  selectedApprentissage.value = null
}

const saveApprentissage = (apprentissage: Apprentissage) => {
  if (!isAuthenticated.value) return
  
  // Vérifier les doublons
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
  
  if (apprentissage.id) {
    // Update existing apprentissage
    apprentissageService.updateApprentissage(apprentissage.id, {
      competence_id: apprentissage.competenceId,
      level: apprentissage.level,
      title: apprentissage.title,
      description: apprentissage.description,
      evaluation: apprentissage.evaluation,
      argumentaire: apprentissage.argumentaire,
      category_id: apprentissage.categoryId,
      preuves: apprentissage.preuves
    }).then(({ data, error }) => {
      if (!error && data) {
        const index = apprentissages.value.findIndex(a => a.id === apprentissage.id)
        if (index !== -1) {
          apprentissages.value[index] = {
            id: data.id,
            competenceId: data.competence_id,
            level: data.level,
            title: data.title,
            description: data.description,
            evaluation: data.evaluation,
            argumentaire: data.argumentaire,
            categoryId: data.category_id,
            preuves: apprentissage.preuves || [],
            dateCreation: data.created_at,
            dateModification: data.updated_at
          }
        }
      }
    })
  } else {
    // Create new apprentissage
    apprentissageService.createApprentissage({
      competenceId: apprentissage.competenceId,
      level: apprentissage.level,
      title: apprentissage.title,
      description: apprentissage.description,
      evaluation: apprentissage.evaluation,
      argumentaire: apprentissage.argumentaire,
      categoryId: apprentissage.categoryId,
      preuves: apprentissage.preuves
    }).then(({ data, error }) => {
      if (!error && data) {
        const newApprentissage = {
          id: data.id,
          competenceId: data.competence_id,
          level: data.level,
          title: data.title,
          description: data.description,
          evaluation: data.evaluation,
          argumentaire: data.argumentaire,
          categoryId: data.category_id,
          preuves: apprentissage.preuves || [],
          dateCreation: data.created_at,
          dateModification: data.updated_at
        }
        apprentissages.value.unshift(newApprentissage)
        // Update counter immediately
        incrementCount('apprentissages')
        
        // Check for new trophies
        setTimeout(() => {
          checkTrophies()
        }, 1000)
      }
    })
  }
  closeModal()
}

const deleteApprentissage = (id: string) => {
  requireAuth(() => {
    apprentissageToDelete.value = id
    showConfirmModal.value = true
  })
}

const confirmDelete = () => {
  if (apprentissageToDelete.value && isAuthenticated.value) {
    // Remove from UI immediately for better UX
    const index = apprentissages.value.findIndex(a => a.id === apprentissageToDelete.value)
    if (index !== -1) {
      apprentissages.value.splice(index, 1)
      // Update counter immediately
      decrementCount('apprentissages')
    }
    
    // Supprimer de la base de données
    apprentissageService.deleteApprentissage(apprentissageToDelete.value).then(({ error }) => {
      if (error) {
        console.error('Erreur lors de la suppression:', error)
        // Restore the item if deletion failed
        if (index !== -1) {
          apprentissages.value.splice(index, 0, apprentissages.value[index])
          incrementCount('apprentissages')
        }
        alert('Erreur lors de la suppression de l\'apprentissage')
      }
      
      // Supprimer aussi des apprentissages vedettes si présent
      const featuredIndex = featuredApprentissages.value.indexOf(apprentissageToDelete.value!)
      if (featuredIndex !== -1) {
        featuredApprentissages.value.splice(featuredIndex, 1)
      }
    })
    
    // Close modal immediately
    cancelDelete()
  } else if (!isAuthenticated.value) {
    // Pour les utilisateurs non connectés, suppression locale uniquement
    const index = apprentissages.value.findIndex(a => a.id === apprentissageToDelete.value)
    if (index !== -1) {
      apprentissages.value.splice(index, 1)
    }
    cancelDelete()
  }
}

const cancelDelete = () => {
  showConfirmModal.value = false
  apprentissageToDelete.value = null
}

const getLatestApprentissageDate = (competenceId: string) => {
  const competenceApprentissages = apprentissages.value.filter(app => app.competenceId === competenceId)
  if (competenceApprentissages.length === 0) return new Date(0).toISOString()
  
  return competenceApprentissages
    .sort((a, b) => new Date(b.dateModification).getTime() - new Date(a.dateModification).getTime())[0]
    .dateModification
}


const cancelDeleteCompetence = () => {
  showCompetenceConfirmModal.value = false
  competenceToDelete.value = null
}

const openAddCompetenceModal = () => {
  handleAddCompetenceClick()
}

const handleAddCompetenceClick = () => {
  if (!isAuthenticated.value) {
    router.push('/')
    openAuthModal()
    return
  }
  
  if (!canCreateCompetence.value) {
    showPremiumNotification.value = true
    premiumNotificationData.value = {
      title: 'Limite atteinte - Premium requis',
      message: `Vous avez atteint la limite de ${userLimits.value?.limits.competences || 3} compétences. Achetez Premium pour créer des compétences illimitées.`
    }
    return
  }
  
  selectedCompetenceForModal.value = null
  showCompetenceModal.value = true
}

const openEditCompetenceModal = (competence: Competence) => {
  requireAuth(() => {
    selectedCompetenceForModal.value = { ...competence }
    showCompetenceModal.value = true
  })
}

const closeCompetenceModal = () => {
  showCompetenceModal.value = false
  selectedCompetenceForModal.value = null
}

const saveCompetence = (competence: Competence) => {
  if (!isAuthenticated.value) return
  
  // Vérifier les doublons
  const existingCompetence = competences.value.find(c => 
    c.title.toLowerCase() === competence.title.toLowerCase() && 
    c.id !== competence.id
  )
  
  if (existingCompetence) {
    showDuplicateModal.value = {
      show: true,
      title: 'Titre déjà existant',
      message: 'Une compétence avec ce titre existe déjà.',
      existingItem: existingCompetence
    }
    return
  }
  
  if (competence.id && competences.value.find(c => c.id === competence.id)) {
    // Update existing competence in database
    competenceService.updateCompetence(competence.id, competence).then(({ data, error }) => {
      if (!error && data) {
        const index = competences.value.findIndex(c => c.id === competence.id)
        if (index !== -1) {
          competences.value[index] = data
        }
      } else {
        console.error('Error updating competence:', error)
        alert('Erreur lors de la modification de la compétence')
      }
    })
  } else {
    // Create new competence in database
    competenceService.createCompetence(competence).then(({ data, error }) => {
      if (!error && data) {
        competences.value.push(data)
        // Update counter immediately
        incrementCount('competences')
        
        // Check for new trophies
        setTimeout(() => {
          checkTrophies()
        }, 1000)
      } else {
        console.error('Error creating competence:', error)
        alert('Erreur lors de la création de la compétence')
      }
    })
  }
  
  closeCompetenceModal()
}

const deleteCompetence = (competenceId: string) => {
  requireAuth(() => {
    competenceToDelete.value = competenceId
    showCompetenceConfirmModal.value = true
  })
}

const confirmDeleteCompetence = () => {
  if (competenceToDelete.value) {
    // Count apprentissages that will be deleted
    const apprentissagesToDelete = apprentissages.value.filter(a => a.competenceId === competenceToDelete.value)
    const apprentissagesCount = apprentissagesToDelete.length
    
    if (isAuthenticated.value) {
      // Remove from UI immediately for better UX
      const competenceIndex = competences.value.findIndex(c => c.id === competenceToDelete.value)
      let removedCompetence = null
      let removedApprentissages = []
      
      if (competenceIndex !== -1) {
        // Save for potential rollback
        removedCompetence = { ...competences.value[competenceIndex] }
        removedApprentissages = [...apprentissagesToDelete]
        
        // Remove from UI immediately
        competences.value.splice(competenceIndex, 1)
        apprentissages.value = apprentissages.value.filter(a => a.competenceId !== competenceToDelete.value)
        
        // Update counts immediately
        decrementCountBy('apprentissages', apprentissagesCount)
        decrementCount('competences')
      }
      
      // Delete from database in background
      Promise.all([
        apprentissageService.deleteApprentissagesByCompetence(competenceToDelete.value),
        competenceService.deleteCompetence(competenceToDelete.value)
      ]).then(([apprentissagesResult, competenceResult]) => {
        if (apprentissagesResult.error || competenceResult.error) {
          console.error('Error deleting competence or apprentissages:', apprentissagesResult.error, competenceResult.error)
          // Rollback UI changes on error
          if (removedCompetence && competenceIndex !== -1) {
            competences.value.splice(competenceIndex, 0, removedCompetence)
            apprentissages.value.push(...removedApprentissages)
            // Restore counts
            incrementCount('competences')
            incrementCountBy('apprentissages', apprentissagesCount)
          }
          alert('Erreur lors de la suppression de la compétence')
        }
      })
    } else {
      // For non-authenticated users, just remove from local state
      const competenceIndex = competences.value.findIndex(c => c.id === competenceToDelete.value)
      if (competenceIndex !== -1) {
        competences.value.splice(competenceIndex, 1)
      }
      apprentissages.value = apprentissages.value.filter(a => a.competenceId !== competenceToDelete.value)
    }
  }
  cancelDeleteCompetence()
}

const openProjectFromApprentissage = (projetId: string) => {
  const projet = projets.value.find(p => p.id === projetId)
  if (projet) {
    selectedProject.value = projet
    showProjectModal.value = true
  }
}

const closeProjectModal = () => {
  showProjectModal.value = false
  selectedProject.value = null
}

const getProjectDetails = (project: Projet) => {
  // Adapter les données du projet pour le modal
  return {
    id: project.id,
    title: project.titre,
    description: project.description,
    technologies: project.technologies || [],
    objectifs: ['Objectifs à définir'],
    realisations: project.fonctionnalites || ['Réalisations à définir'],
    competences: ['Compétences développées'],
    duree: project.duree || 'Non spécifié',
    niveau: project.niveau || 'Non spécifié',
    fichiers: project.fichiers || []
  }
}

const toggleFeaturedApprentissage = async (apprentissage: Apprentissage) => {
  if (!isAuthenticated.value) return
  
  const user = await authService.getCurrentUser()
  if (!user) return
  
  const isFeatured = featuredApprentissages.value.includes(apprentissage.id)
  
  if (isFeatured) {
    // Remove from featured
    const { error } = await featuredApprentissageService.removeFeaturedApprentissage(user.id, apprentissage.id)
    if (!error) {
      featuredApprentissages.value = featuredApprentissages.value.filter(id => id !== apprentissage.id)
    }
  } else {
    // Add to featured (check limit)
    if (featuredApprentissages.value.length >= 3) {
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
    }
  }
}

const editExistingItem = () => {
  showDuplicateModal.value.show = false
  if (showDuplicateModal.value.existingItem) {
    if ('competenceId' in showDuplicateModal.value.existingItem) {
      // It's an apprentissage
      openEditModal(showDuplicateModal.value.existingItem)
    } else {
      // It's a competence
      openEditCompetenceModal(showDuplicateModal.value.existingItem)
    }
  }
}

const handlePremiumNotification = (notificationData: { title: string, message: string }) => {
  showPremiumNotification.value = true
  premiumNotificationData.value = notificationData
}

const handleShowPremiumNotification = (data: { title: string, message: string }) => {
  showPremiumNotification.value = true
  premiumNotificationData.value = data
}

const handlePremiumUpgrade = () => {
  router.push('/pricing')
}

// Category management functions
const openAddCategoryModal = (competenceId: string, level: number) => {
  if (!isAuthenticated.value) {
    router.push('/')
    openAuthModal()
    return
  }
  
  selectedCategory.value = null
  categoryCompetenceId.value = competenceId
  categoryLevel.value = level
  showCategoryModal.value = true
}

const openEditCategoryModal = (category: any) => {
  if (!isAuthenticated.value) {
    router.push('/')
    openAuthModal()
    return
  }
  
  selectedCategory.value = category
  categoryCompetenceId.value = category.competence_id
  categoryLevel.value = category.level
  showCategoryModal.value = true
}

const closeCategoryModal = () => {
  showCategoryModal.value = false
  selectedCategory.value = null
  categoryCompetenceId.value = ''
  categoryLevel.value = 1
}

const saveCategory = async (categoryData: any) => {
  if (!isAuthenticated.value) return
  
  try {
    if (categoryData.id) {
      // Update existing category
      const { data, error } = await apprentissageCategoryService.updateCategory(categoryData.id, {
        title: categoryData.title,
        description: categoryData.description
      })
      
      if (!error && data) {
        const index = categories.value.findIndex(c => c.id === categoryData.id)
        if (index !== -1) {
          categories.value[index] = data
        }
      }
    } else {
      // Create new category
      const { data, error } = await apprentissageCategoryService.createCategory({
        competenceId: categoryData.competence_id,
        level: categoryData.level,
        title: categoryData.title,
        description: categoryData.description
      })
      
      if (!error && data) {
        categories.value.push(data)
      }
    }
  } catch (error) {
    console.error('Error saving category:', error)
  }
  
  closeCategoryModal()
}

const deleteCategory = async (categoryId: string) => {
  if (!isAuthenticated.value) return
  
  categoryToDelete.value = categoryId
  showCategoryConfirmModal.value = true
}

const confirmDeleteCategory = async () => {
  if (categoryToDelete.value && isAuthenticated.value) {
    try {
      const { error } = await apprentissageCategoryService.deleteCategory(categoryToDelete.value)
      
      if (!error) {
        // Remove from UI
        categories.value = categories.value.filter(c => c.id !== categoryToDelete.value)
        
        // Update apprentissages to remove category reference
        apprentissages.value = apprentissages.value.map(app => 
          app.categoryId === categoryToDelete.value ? { ...app, categoryId: undefined } : app
        )
      }
    } catch (error) {
      console.error('Error deleting category:', error)
    }
  }
  cancelDeleteCategory()
}

const cancelDeleteCategory = () => {
  showCategoryConfirmModal.value = false
  categoryToDelete.value = null
}

const getCompetenceTitle = (competenceId: string) => {
  const competence = competences.value.find(c => c.id === competenceId)
  return competence?.title || 'Compétence'
}

// Export handler
const handleExportClick = async () => {
  if (!isAuthenticated.value || !userProfile.value) {
    alert('Impossible d\'exporter : données utilisateur manquantes')
    return
  }
  
  exportLoading.value = true
  
  try {
    console.log('Portfolio export - Categories available:', categories.value)
    console.log('Portfolio export - Apprentissages with categories:', 
      apprentissages.value.filter(a => a.categoryId).map(a => ({ 
        title: a.title, 
        categoryId: a.categoryId 
      }))
    )
    
    // Préparer les données d'export
    const exportData = prepareExportData(
      userProfile.value,
      competences.value,
      apprentissages.value,
      projets.value,
      categories.value
    )
    
    console.log('Portfolio export data prepared:', {
      categoriesCount: exportData.categories?.length || 0,
      apprentissagesCount: exportData.apprentissages.length
    })
    
    // Exporter vers Excel
    await exportPortfolioToExcel(exportData)
    
    // Afficher un message de succès
    showPremiumNotification.value = true
    premiumNotificationData.value = {
      title: 'Export réussi !',
      message: 'Votre portfolio a été exporté avec succès au format Excel professionnel.'
    }
  } catch (error) {
    console.error('Erreur lors de l\'export:', error)
    showPremiumNotification.value = true
    premiumNotificationData.value = {
      title: 'Erreur d\'export',
      message: 'Une erreur est survenue lors de l\'export. Veuillez réessayer.'
    }
  } finally {
    exportLoading.value = false
  }
}
</script>