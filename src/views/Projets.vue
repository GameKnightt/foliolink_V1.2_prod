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
          <span class="text-accent-400 mr-2">🚀</span>
          <span class="text-white font-medium">Projets Étudiants BUT</span>
        </div>

        <!-- Main Title -->
        <div class="animate-slide-up">
          <h1 class="text-6xl md:text-8xl font-bold text-white mb-6 leading-tight">
            Mes <span class="gradient-text text-glow">Projets</span>
          </h1>
          
          <p class="text-xl md:text-2xl text-gray-300 mb-12 max-w-4xl mx-auto leading-relaxed">
            Découvrez mes projets étudiants BUT et mes réalisations concrètes durant ma formation
          </p>
          
          <!-- Limits Display for Non-Premium Users -->
          <div v-if="userLimits && !userLimits.isPremium && isAuthenticated" class="mt-8 max-w-md mx-auto">
            <div class="glass-card p-4">
              <div class="flex items-center justify-between">
                <LimitCounter 
                  type="projets"
                  :current="userLimits.current.projets"
                  :max="userLimits.limits.projets"
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

    <!-- Projets Grid -->
    <section class="py-20 relative">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-12">
          <!-- Bouton d'ajout de projet -->
          <article 
            class="glass-card p-8 hover:scale-105 transition-all duration-500 group cursor-pointer border-2 border-dashed border-accent-400/50 hover:border-accent-400 relative" 
            :class="{ 
              'opacity-60 cursor-not-allowed backdrop-blur-sm': !canCreateProjet && isAuthenticated,
              'hover:shadow-lg': canCreateProjet && isAuthenticated
            }"
            @click="openAddProjetModal"
          >
            <div v-if="!canCreateProjet" class="absolute -top-2 -right-2 w-8 h-8 bg-red-500 rounded-full flex items-center justify-center shadow-lg z-10">
              <span class="text-white text-sm">🔒</span>
            </div>
            <div v-if="!canCreateProjet" class="absolute inset-0 bg-gray-500/20 backdrop-blur-[1px] rounded-2xl"></div>
            <div class="flex flex-col items-center justify-center h-full min-h-[300px] text-center">
              <div class="w-16 h-16 bg-accent-400/20 rounded-2xl flex items-center justify-center mb-6 group-hover:scale-110 transition-transform duration-300">
                <span class="text-3xl text-accent-400">➕</span>
              </div>
              <h3 class="text-2xl font-bold text-white mb-4">
                {{ !isAuthenticated ? 'Connexion Requise' : (!canCreateProjet ? 'Limite Atteinte - Premium Requis' : 'Ajouter un Nouveau Projet') }}
              </h3>
              <p class="text-gray-300 leading-relaxed">
                {{ !isAuthenticated 
                  ? 'Connectez-vous pour ajouter de nouveaux projets à votre portfolio.'
                  : (!canCreateProjet 
                    ? `Vous avez atteint la limite de ${userLimits?.value?.limits.projets || 3} projets. Achetez Premium pour créer des projets illimités.`
                    : 'Cliquez ici pour ajouter un nouveau projet à votre portfolio et enrichir vos réalisations.')
                }}
              </p>
            </div>
          </article>

          <!-- Projets dynamiques -->
          <article 
            v-for="projet in projets" 
            :key="projet.id"
            class="glass-card p-8 hover:scale-105 transition-all duration-500 group relative"
          >
            <div class="flex items-start space-x-4 mb-6">
              <div class="w-16 h-16 bg-gradient-to-r from-accent-400 to-accent-500 rounded-2xl flex items-center justify-center group-hover:scale-110 transition-transform duration-300">
                <span class="text-3xl">{{ projet.icone }}</span>
              </div>
              <div class="flex-1">
                <h3 class="text-2xl font-bold text-white mb-3">{{ projet.titre }}</h3>
                <div class="flex flex-wrap gap-2 mb-4">
                  <span 
                    v-for="tech in projet.technologies"
                    :key="tech"
                    class="px-3 py-1 bg-primary-400/20 text-primary-400 rounded-full text-sm font-medium"
                  >
                    {{ tech }}
                  </span>
                </div>
              </div>
            </div>
            
            <p class="text-gray-300 mb-6 leading-relaxed">
              {{ projet.description }}
            </p>

            <div v-if="projet.fonctionnalites && projet.fonctionnalites.length > 0" class="space-y-4 mb-6">
              <h4 class="text-lg font-semibold text-white">Fonctionnalités principales :</h4>
              <ul class="space-y-2 text-gray-300">
                <li 
                  v-for="fonctionnalite in projet.fonctionnalites"
                  :key="fonctionnalite"
                  class="flex items-center"
                >
                  <span class="text-green-400 mr-2">✓</span>
                  {{ fonctionnalite }}
                </li>
              </ul>
            </div>

            <div class="flex items-center justify-between">
              <div class="text-sm text-gray-400">
                <span class="font-medium">{{ projet.niveau }}</span> • Durée : {{ projet.duree }}
              </div>
            </div>
            
            <!-- Hover overlay -->
            <div class="absolute inset-0 bg-black/20 opacity-0 group-hover:opacity-100 transition-opacity duration-300 rounded-2xl flex items-center justify-center">
              <div class="flex space-x-2">
                <button 
                  @click="openProjectModal(projet)"
                  class="btn-primary transform scale-90 group-hover:scale-100 transition-transform duration-300"
                >
                  <span class="mr-2">👁️</span>
                  Voir détails
                </button>
                <button 
                  v-if="isAuthenticated"
                  @click="openEditProjetModal(projet)"
                  class="btn-secondary transform scale-90 group-hover:scale-100 transition-transform duration-300"
                >
                  <span class="mr-2">✏️</span>
                  Modifier
                </button>
                <button 
                  v-if="isAuthenticated"
                  @click="deleteProjet(projet.id)"
                  class="bg-red-600 hover:bg-red-700 text-white font-semibold px-4 py-2 rounded-xl transition-all duration-300 hover:shadow-lg transform scale-90 group-hover:scale-100"
                >
                  <span class="mr-2">🗑️</span>
                  Supprimer
                </button>
              </div>
            </div>
          </article>
        </div>

        <!-- Call to Action -->
        <div class="text-center mt-16">
          <div class="glass-card p-8 max-w-2xl mx-auto">
            <h3 class="text-2xl font-bold text-white mb-4">Gestion des Projets</h3>
            <p class="text-gray-300 mb-6">
              Explorez mes réalisations ou ajoutez de nouveaux projets à mon portfolio.
            </p>
            <div class="flex flex-col sm:flex-row gap-4 justify-center">
              <!-- Mobile Action Menu for authenticated users -->
              <MobileActionMenu v-if="isAuthenticated" title="Actions" icon="🚀">
                <!-- Desktop Buttons -->
                <template #desktop-buttons>
                  <button 
                    @click="handleAddProjetClick"
                    class="btn-primary relative group"
                    :class="{ 'opacity-60 cursor-not-allowed filter blur-[1px]': !canCreateProjet }"
                  >
                    <div v-if="!canCreateProjet" class="absolute -top-2 -right-2 w-7 h-7 bg-red-500 rounded-full flex items-center justify-center shadow-lg z-10">
                      <span class="text-white text-sm">🔒</span>
                    </div>
                    <div v-if="!canCreateProjet" class="absolute inset-0 bg-gray-500/15 backdrop-blur-[1px] rounded-xl pointer-events-none"></div>
                    <span class="mr-2">➕</span>
                    Ajouter un Projet
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
                  <router-link to="/portfolio" class="btn-primary">
                    <span class="mr-2">📊</span>
                    Voir Compétences
                  </router-link>
                </template>
                
                <!-- Mobile Buttons -->
                <template #mobile-buttons>
                  <button 
                    @click="handleAddProjetClick"
                    class="w-full btn-primary h-12 px-4 text-sm font-semibold flex items-center justify-center relative group transition-all duration-300"
                    :class="{ 'opacity-60 cursor-not-allowed filter blur-[1px]': !canCreateProjet }"
                  >
                    <div v-if="!canCreateProjet" class="absolute -top-2 -right-2 w-6 h-6 bg-red-500 rounded-full flex items-center justify-center shadow-lg z-10">
                      <span class="text-white text-xs">🔒</span>
                    </div>
                    <span class="mr-2">➕</span>
                    Ajouter un Projet
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
                  
                  <router-link to="/portfolio" class="w-full btn-primary h-12 px-4 text-sm font-semibold flex items-center justify-center">
                    <span class="mr-2">📊</span>
                    Voir Compétences
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
                <router-link to="/portfolio" class="btn-primary w-full sm:w-auto">
                  <span class="mr-2">📊</span>
                  Voir Compétences
                </router-link>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Project Details Modal -->
    <ProjectModal
      v-if="showProjectModal && selectedProject"
      :project="getProjectDetails(selectedProject)"
      :competences="competences"
      @close="closeProjectModal"
    />

    <!-- Add/Edit Project Modal -->
    <ProjetModal
      v-if="showProjetModal"
      :projet="selectedProjet"
      @save="saveProjet"
      @close="closeProjetModal"
    />

    <!-- Confirm Delete Modal -->
    <ConfirmModal
      v-if="showConfirmModal"
      title="Supprimer le projet"
      message="Êtes-vous sûr de vouloir supprimer ce projet ? Cette action est irréversible."
      @confirm="confirmDelete"
      @cancel="cancelDelete"
    />

    <!-- Login Required Modal -->
    <LoginRequiredModal
      v-if="showLoginRequiredModal"
      @close="closeLoginRequiredModal"
      @login="handleLoginFromModal"
    />
    
    <!-- Floating Back to Top Button -->
    <button 
      @click="scrollToTop"
      class="fixed bottom-8 right-8 glass-card p-4 hover:scale-110 transition-all duration-300 z-50"
    >
      <ChevronDownIcon class="w-6 h-6 text-accent-400 transform rotate-180" />
    </button>

    <!-- Toast Notification -->
    <ToastNotification
      v-if="showToastNotification"
      :title="toastData.title"
      :message="toastData.message"
      :duration="3000"
      @close="closeToast"
    />

    <!-- Duplicate Modal -->
    <DuplicateModal
      v-if="showDuplicateModal.show"
      :title="showDuplicateModal.title"
      :message="showDuplicateModal.message"
      @close="showDuplicateModal.show = false"
      @edit-existing="editExistingProject"
    />
    
      <PremiumNotification
        v-if="showPremiumNotification"
        :title="premiumNotificationData.title"
        :message="premiumNotificationData.message"
        :duration="5000"
        @close="showPremiumNotification = false"
        @upgrade="handlePremiumUpgrade"
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
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ChevronDownIcon } from '@heroicons/vue/24/outline'
import ProjectModal from '../components/ProjectModal.vue'
import ProjetModal from '../components/ProjetModal.vue'
import ConfirmModal from '../components/ConfirmModal.vue'
import LimitCounter from '../components/LimitCounter.vue'
import PremiumLimitModal from '../components/PremiumLimitModal.vue'
import PremiumNotification from '../components/PremiumNotification.vue'
import { exportPortfolioToExcel, prepareExportData } from '../lib/excelExport'
import { type Projet } from '../data/portfolio'
import { authService, exampleDataService, projetService, profileService } from '../lib/supabase'
import { usePremiumLimits } from '../composables/usePremiumLimits'
import { useAuth } from '../composables/useAuth'
import LoginRequiredModal from '../components/LoginRequiredModal.vue'
import ToastNotification from '../components/ToastNotification.vue'
import DuplicateModal from '../components/DuplicateModal.vue'
import TrophyModal from '../components/TrophyModal.vue'
import MobileActionMenu from '../components/MobileActionMenu.vue'
import { useGamification } from '../composables/useGamification'

const router = useRouter()
const route = useRoute()
const { openAuthModal } = useAuth()
const showProjectModal = ref(false)
const selectedProject = ref<Projet | null>(null)
const showProjetModal = ref(false)
const selectedProjet = ref<Projet | null>(null)
const showConfirmModal = ref(false)
const projetToDelete = ref<string | null>(null)
const projets = ref<Projet[]>([])
const showLoginRequiredModal = ref(false)
const showToastNotification = ref(false)
const toastData = ref({ title: '', message: '' })
const showDuplicateModal = ref({
  show: false,
  title: '',
  message: '',
  existingItem: null
})
const competences = ref<any[]>([])
const showPremiumModal = ref(false)
const premiumModalType = ref<'competences' | 'apprentissages' | 'projets' | 'export'>('projets')
const showPremiumNotification = ref(false)
const premiumNotificationData = ref({ title: '', message: '' })
const exportLoading = ref(false)
const userProfile = ref<any>(null)

const isAuthenticated = ref(false)

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

const canCreateProjet = computed(() => canCreate.value.projets)

// Check authentication status and load data
const checkAuthAndLoadData = async () => {
  const user = await authService.getCurrentUser()
  isAuthenticated.value = !!user
  
  if (isAuthenticated.value && user) {
    // Load user limits first for immediate UI state
    await loadUserLimits()
    await loadGamificationStats()
    await loadUserProjets(user.id)
  } else {
    await loadExampleProjets()
  }
  
  // Check if we need to open a specific project
  const projectParam = route.query.project as string
  if (projectParam) {
    const project = projets.value.find(p => p.id === projectParam)
    if (project) {
      setTimeout(() => {
        openProjectModal(project)
      }, 500)
    }
  }
}

const loadUserProjets = async (userId: string) => {
  console.log('Loading user projects for:', userId)
  
  const { data } = await projetService.getUserProjets(userId)
  console.log('Projects loaded from database:', data)
  
  if (data) {
    projets.value = data.map(projet => ({
      ...projet,
      fonctionnalites: projet.fonctionnalites || [],
      technologies: projet.technologies || [],
      fichiers: projet.fichiers_projets || []
    }))
    console.log('Projects mapped for UI:', projets.value)
  }
  
  // Load profile for export
  const { data: profile } = await profileService.getProfile(userId)
  if (profile) {
    userProfile.value = profile
  }
  
  // Load competences for project details
  const savedCompetences = localStorage.getItem('user_competences')
  if (savedCompetences) {
    try {
      competences.value = JSON.parse(savedCompetences)
    } catch (error) {
      console.error('Error parsing saved competences:', error)
    }
  }
}

const loadExampleProjets = async () => {
  try {
    const { data } = await exampleDataService.getExampleProjets()
    if (data && data.length > 0) {
      projets.value = data.map(projet => ({
        id: projet.id,
        titre: projet.titre,
        description: projet.description,
        icone: projet.icone,
        niveau: projet.niveau,
        duree: projet.duree,
        fonctionnalites: projet.fonctionnalites || [],
        technologies: projet.technologies || [],
        competences_developpees: projet.competences_developpees,
        fichiers: [],
        dateCreation: new Date().toISOString(),
        statut: 'Terminé' as const
      }))
    } else {
      projets.value = [
        {
          id: 'demo-1',
          titre: 'Système de Contrôle Automatisé',
          description: 'Conception et développement d\'un système de contrôle automatisé pour une ligne de production industrielle.',
          icone: '⚙️',
          niveau: 'Projet de 2ème année',
          duree: '6 mois',
          fonctionnalites: ['Programmation automate', 'Interface SCADA', 'Communication Modbus'],
          technologies: ['Automatisme', 'PLC', 'SCADA', 'Supervision'],
          fichiers: [],
          dateCreation: new Date().toISOString(),
          statut: 'Terminé' as const
        },
        {
          id: 'demo-2',
          titre: 'Interface de Supervision IoT',
          description: 'Développement d\'une interface web moderne pour la supervision en temps réel d\'équipements industriels connectés.',
          icone: '📱',
          niveau: 'Projet de 3ème année',
          duree: '4 mois',
          fonctionnalites: ['Frontend Vue.js', 'Backend Node.js', 'WebSockets temps réel'],
          technologies: ['IoT', 'Vue.js', 'Data Viz', 'Real-time'],
          fichiers: [],
          dateCreation: new Date().toISOString(),
          statut: 'Terminé' as const
        }
      ]
    }
  } catch (error) {
    console.error('Error loading example projects:', error)
    projets.value = []
  }
}

const projectsDetails = [
  {
    id: '1',
    title: 'Système de Contrôle Automatisé',
    description: 'Conception et développement d\'un système de contrôle automatisé pour une ligne de production industrielle. Le projet intègre la programmation PLC, une interface SCADA moderne et des protocoles de communication industriels. Ce système permet de superviser et contrôler en temps réel les équipements de production avec une interface utilisateur intuitive.',
    technologies: ['Automatisme', 'PLC', 'SCADA', 'Supervision'],
    objectifs: [
      'Automatiser une ligne de production industrielle',
      'Développer une interface SCADA ergonomique',
      'Implémenter des protocoles de communication robustes',
      'Assurer la traçabilité et la sécurité des opérations'
    ],
    realisations: [
      'Programmation automate Schneider Electric avec logique séquentielle',
      'Interface SCADA développée avec Wonderware InTouch',
      'Communication Modbus TCP/IP entre automate et supervision',
      'Système d\'alarmes et de traçabilité des événements',
      'Tests et validation sur maquette industrielle'
    ],
    competences: ['Concevoir', 'Vérifier', 'Intégrer'],
    duree: '6 mois',
    niveau: 'Projet de 2ème année'
  },
  {
    id: '2',
    title: 'Interface de Supervision IoT',
    description: 'Développement d\'une interface web moderne pour la supervision en temps réel d\'équipements industriels connectés. Le système offre une visualisation avancée des données avec des graphiques interactifs, un système d\'alertes intelligentes et une architecture scalable pour gérer de multiples équipements.',
    technologies: ['IoT', 'Vue.js', 'Data Viz', 'Real-time'],
    objectifs: [
      'Créer une interface web responsive et moderne',
      'Implémenter la visualisation temps réel des données',
      'Développer un système d\'alertes intelligent',
      'Assurer la scalabilité pour de multiples équipements'
    ],
    realisations: [
      'Frontend Vue.js avec TypeScript et design responsive',
      'Backend Node.js avec WebSockets pour temps réel',
      'Base de données InfluxDB pour séries temporelles',
      'Graphiques interactifs avec Chart.js et D3.js',
      'API REST sécurisée avec authentification JWT'
    ],
    competences: ['Concevoir', 'Vérifier', 'Intégrer'],
    duree: '4 mois',
    niveau: 'Projet de 3ème année'
  }
]

const openProjectModal = (project) => {
  selectedProject.value = project
  showProjectModal.value = true
}

const closeProjectModal = () => {
  showProjectModal.value = false
  selectedProject.value = null
}

const getProjectDetails = (project: any) => {
  // Pour les projets existants avec des détails prédéfinis
  const existingDetail = projectsDetails.find(p => p.id === project.id)
  if (existingDetail) {
    return {
      ...existingDetail,
      competences_developpees: project.competences_developpees || [],
      fichiers: project.fichiers || []
    }
  }
  
  // Pour les nouveaux projets créés dynamiquement
  return {
    id: project.id,
    title: project.titre,
    description: project.description,
    technologies: project.technologies || [],
    objectifs: ['Objectifs à définir'],
    realisations: project.fonctionnalites || ['Réalisations à définir'],
    competences_developpees: project.competences_developpees || [],
    duree: project.duree || 'Non spécifié',
    niveau: project.niveau || 'Non spécifié',
    fichiers: project.fichiers || []
  }
}

const openAddProjetModal = () => {
  if (!isAuthenticated.value) {
    showLoginRequiredModal.value = true
    return
  }
  
  if (!isAuthenticated.value) {
    showLoginRequiredModal.value = true
    return
  }
  
  if (!canCreateProjet.value) {
    showPremiumNotification.value = true
    premiumNotificationData.value = {
      title: 'Limite atteinte - Premium requis',
      message: `Vous avez atteint la limite de ${userLimits?.value?.limits.projets || 3} projets. Achetez FolioLink Premium pour créer des projets illimités.`
    }
    return
  }
  
  // User is authenticated, proceed with project creation
  selectedProjet.value = {
    id: '',
    titre: '',
    description: '',
    icone: '📁',
    niveau: 'Projet de 1ère année',
    duree: '',
    fonctionnalites: [],
    technologies: [],
    fichiers: [],
    dateCreation: '',
    statut: 'En cours'
  }
  showProjetModal.value = true
}

const closeLoginRequiredModal = () => {
  showLoginRequiredModal.value = false
}

const handleLoginFromModal = () => {
  showLoginRequiredModal.value = false
  openAuthModal()
}

const openEditProjetModal = (projet: Projet) => {
  if (!isAuthenticated.value) {
    showLoginRequiredModal.value = true
    return
  }
  
  selectedProjet.value = { ...projet }
  showProjetModal.value = true
}

const deleteProjet = (projetId: string) => {
  if (!isAuthenticated.value) {
    showLoginRequiredModal.value = true
    return
  }
  
  projetToDelete.value = projetId
  showConfirmModal.value = true
}

const closeProjetModal = () => {
  showProjetModal.value = false
  selectedProjet.value = null
}

const saveProjet = (projet: Projet) => {
  if (!isAuthenticated.value) return
  
  // Vérifier les doublons
  const existingProjet = projets.value.find(p => 
    p.titre.toLowerCase() === projet.titre.toLowerCase() && 
    p.id !== projet.id
  )
  
  if (existingProjet) {
    showDuplicateModal.value = {
      show: true,
      title: 'Titre déjà existant',
      message: 'Un projet avec ce titre existe déjà.',
      existingItem: existingProjet
    }
    return
  }
  
  if (projet.id) {
    // Update existing project
    projetService.updateProjet(projet.id, {
      titre: projet.titre,
      description: projet.description,
      icone: projet.icone,
      niveau: projet.niveau,
      duree: projet.duree,
      fonctionnalites: projet.fonctionnalites,
      technologies: projet.technologies,
      statut: projet.statut
    }).then(({ data, error }) => {
      if (!error && data) {
        // Mise à jour immédiate de l'interface
        const index = projets.value.findIndex(p => p.id === projet.id)
        if (index !== -1) {
          projets.value[index] = {
            ...data,
            fonctionnalites: data.fonctionnalites || [],
            technologies: data.technologies || [],
            competences_developpees: data.competences_developpees || [],
            fichiers: projet.fichiers || []
          }
        }
        
        showToast({
          title: 'Projet modifié',
          message: 'Le projet a été mis à jour avec succès.'
        })
      } else {
        showToast({
          title: 'Erreur',
          message: 'Impossible de modifier le projet. Veuillez réessayer.'
        })
      }
    })
  } else {
    // Create new project
    projetService.createProjet(projet).then(({ data, error }) => {
      if (!error && data) {
        console.log('Project created successfully:', data)
        
        // Ajout immédiat à l'interface
        const newProjet = {
          ...data,
          fonctionnalites: data.fonctionnalites || [],
          technologies: data.technologies || [],
          competences_developpees: data.competences_developpees || [],
          fichiers: data.fichiers_projets || []
        }
        console.log('Adding project to UI:', newProjet)
        projets.value.unshift(newProjet)
        
        // Update counter immediately
        incrementCount('projets')
        
        // Check for new trophies
        setTimeout(() => {
          checkTrophies()
        }, 1000)
        
        showToast({
          title: 'Projet créé',
          message: 'Le nouveau projet a été ajouté avec succès.'
        })
      } else {
        console.error('Failed to create project:', error)
        showToast({
          title: 'Erreur',
          message: 'Impossible de créer le projet. Veuillez réessayer.'
        })
      }
    })
  }
  closeProjetModal()
}

const confirmDelete = () => {
  if (projetToDelete.value && isAuthenticated.value) {
    // Suppression immédiate de l'interface utilisateur AVANT l'appel API
    const projetIndex = projets.value.findIndex(p => p.id === projetToDelete.value)
    let deletedProjet = null
    
    if (projetIndex !== -1) {
      // Sauvegarder le projet pour le restaurer en cas d'erreur
      deletedProjet = { ...projets.value[projetIndex] }
      // Supprimer immédiatement de l'interface
      projets.value.splice(projetIndex, 1)
      // Update counter immediately
      decrementCount('projets')
    }
    
    // Appel API en arrière-plan
    projetService.deleteProjet(projetToDelete.value).then(({ error }) => {
      if (!error) {
        // Success
        showToast({
          title: 'Projet supprimé',
          message: 'Le projet a été supprimé avec succès.'
        })
      } else {
        // En cas d'erreur, restaurer le projet dans l'interface
        if (deletedProjet && projetIndex !== -1) {
          projets.value.splice(projetIndex, 0, deletedProjet)
          // Restore counter
          incrementCount('projets')
        }
        showToast({
          title: 'Erreur',
          message: 'Impossible de supprimer le projet. Veuillez réessayer.'
        })
      }
    })
  }
  cancelDelete()
}

const cancelDelete = () => {
  showConfirmModal.value = false
  projetToDelete.value = null
}

const scrollToTop = () => {
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

// Fonction pour afficher les toasts
const showToast = (data: { title: string, message: string }) => {
  toastData.value = data
  showToastNotification.value = true
}

const closeToast = () => {
  showToastNotification.value = false
}

const formatDate = (dateString: string) => {
  return new Date(dateString).toLocaleDateString('fr-FR')
}

const editExistingProject = () => {
  showDuplicateModal.value.show = false
  if (showDuplicateModal.value.existingItem) {
    openEditProjetModal(showDuplicateModal.value.existingItem)
  }
}

const handlePremiumUpgrade = () => {
  window.location.href = '/pricing'
}

// Export handler
const handleExportClick = async () => {
  if (!userLimits.value?.isPremium) {
    // Show premium notification for non-premium users
    const notification = document.createElement('div')
    notification.className = 'fixed top-20 right-4 z-50 glass-card p-4 max-w-sm shadow-2xl border border-yellow-400/30 animate-fade-in'
    notification.innerHTML = `
      <div class="flex items-center space-x-3">
        <div class="w-8 h-8 bg-yellow-500/20 rounded-full flex items-center justify-center">
          <span class="text-yellow-400 text-lg">👑</span>
        </div>
        <div class="flex-1">
          <p class="text-white font-medium text-sm">Premium Requis</p>
          <p class="text-gray-300 text-xs mt-1">L'export Excel est réservé aux utilisateurs Premium</p>
        </div>
      </div>
      <div class="mt-3 w-full bg-gray-700 rounded-full h-1">
        <div class="bg-yellow-400 h-1 rounded-full transition-all duration-100 ease-linear" style="width: 100%"></div>
      </div>
    `
    
    document.body.appendChild(notification)
    
    // Animate progress bar
    const progressBar = notification.querySelector('.bg-yellow-400') as HTMLElement
    if (progressBar) {
      let width = 100
      const interval = setInterval(() => {
        width -= 100 / 30 // 3 seconds = 30 intervals of 100ms
        progressBar.style.width = `${Math.max(0, width)}%`
        if (width <= 0) {
          clearInterval(interval)
          notification.remove()
        }
      }, 100)
    }
    
    // Auto remove after 3 seconds
    setTimeout(() => {
      if (notification.parentNode) {
        notification.remove()
      }
    }, 3000)
    
    return
  }
  
  if (!isAuthenticated.value || !userProfile.value) {
    alert('Impossible d\'exporter : données utilisateur manquantes')
    return
  }
  
  exportLoading.value = true
  
  try {
    // Préparer les données d'export (projets seulement pour cette page)
    const exportData = prepareExportData(
      userProfile.value,
      competences.value,
      [], // Pas d'apprentissages sur cette page
      projets.value,
      [] // Pas de catégories nécessaires pour l'export projets uniquement
    )
    
    // Exporter vers Excel
    await exportPortfolioToExcel(exportData)
    
    // Afficher un message de succès
    showToast({
      title: 'Export réussi !',
      message: 'Vos projets ont été exportés avec succès au format Excel.'
    })
  } catch (error) {
    console.error('Erreur lors de l\'export:', error)
    showToast({
      title: 'Erreur d\'export',
      message: 'Une erreur est survenue lors de l\'export. Veuillez réessayer.'
    })
  } finally {
    exportLoading.value = false
  }
}

// Initialize authentication check
checkAuthAndLoadData()
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
</style>