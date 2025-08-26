<template>
  <div class="pt-16 min-h-screen bg-gradient-to-br from-gray-900 via-blue-900 to-gray-900">
    <!-- Loading State -->
    <div v-if="loading" class="flex items-center justify-center min-h-screen">
      <div class="glass-card p-8 text-center">
        <div class="w-16 h-16 bg-gradient-to-r from-accent-400 to-accent-500 rounded-full flex items-center justify-center mx-auto mb-4 animate-pulse">
          <span class="text-2xl">📊</span>
        </div>
        <h2 class="text-2xl font-bold text-white mb-2">Chargement du dashboard...</h2>
        <p class="text-gray-300">Récupération de vos données</p>
      </div>
    </div>

    <!-- Dashboard Content -->
    <div v-else class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <!-- Welcome Header -->
      <div class="text-center mb-12">
        <div class="inline-flex items-center glass-card px-6 py-3 mb-8">
          <span class="text-accent-400 mr-3">👋</span>
          <span class="text-white font-medium mr-4">Bienvenue sur votre Dashboard</span>
          <LevelBadge :level="currentLevel" :points="gamificationStats.totalPoints" />
        </div>
        
        <h1 class="text-4xl md:text-5xl font-bold text-white mb-6">
          Dashboard de <span class="gradient-text">{{ userProfile?.full_name || 'Mon Portfolio' }}</span>
        </h1>
        
        <p class="text-xl text-gray-300 max-w-3xl mx-auto">
          Gérez votre portfolio BUT, suivez vos progrès et accédez à toutes vos fonctionnalités
        </p>
      </div>

      <!-- Stats Cards -->
      <div id="stats-cards" class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-12">
        <div class="glass-card p-6 text-center hover:scale-105 transition-all duration-300">
          <div class="w-12 h-12 bg-gradient-to-r from-primary-400 to-primary-500 rounded-xl flex items-center justify-center mx-auto mb-4">
            <span class="text-2xl">🎯</span>
          </div>
          <div class="text-3xl font-bold gradient-text mb-2">{{ stats.competences }}</div>
          <div class="text-gray-300 text-sm">Compétences</div>
          <div v-if="!userLimits?.isPremium" class="text-xs text-gray-400 mt-1">
            {{ stats.competences }}/{{ userLimits?.limits.competences || 3 }}
          </div>
        </div>

        <div class="glass-card p-6 text-center hover:scale-105 transition-all duration-300">
          <div class="w-12 h-12 bg-gradient-to-r from-accent-400 to-accent-500 rounded-xl flex items-center justify-center mx-auto mb-4">
            <span class="text-2xl">📚</span>
          </div>
          <div class="text-3xl font-bold gradient-text mb-2">{{ stats.apprentissages }}</div>
          <div class="text-gray-300 text-sm">Apprentissages</div>
          <div v-if="!userLimits?.isPremium" class="text-xs text-gray-400 mt-1">
            {{ stats.apprentissages }}/{{ userLimits?.limits.apprentissages || 5 }}
          </div>
        </div>

        <div class="glass-card p-6 text-center hover:scale-105 transition-all duration-300">
          <div class="w-12 h-12 bg-gradient-to-r from-green-400 to-green-500 rounded-xl flex items-center justify-center mx-auto mb-4">
            <span class="text-2xl">🚀</span>
          </div>
          <div class="text-3xl font-bold gradient-text mb-2">{{ stats.projets }}</div>
          <div class="text-gray-300 text-sm">Projets</div>
          <div v-if="!userLimits?.isPremium" class="text-xs text-gray-400 mt-1">
            {{ stats.projets }}/{{ userLimits?.limits.projets || 3 }}
          </div>
        </div>

        <div class="glass-card p-6 text-center hover:scale-105 transition-all duration-300">
          <div class="w-12 h-12 bg-gradient-to-r from-purple-400 to-purple-500 rounded-xl flex items-center justify-center mx-auto mb-4">
            <span class="text-2xl">⭐</span>
          </div>
          <div class="text-3xl font-bold gradient-text mb-2">{{ stats.pourcentageMaitrise }}%</div>
          <div class="text-gray-300 text-sm">Bien Maîtrisées</div>
        </div>
      </div>

      <!-- Quick Actions -->
      <div id="quick-actions" class="glass-card p-8 mb-12">
        <h2 class="text-2xl font-bold text-white mb-6 flex items-center">
          <span class="mr-3">⚡</span>
          Actions Rapides
        </h2>
        
        <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
          <router-link to="/portfolio" class="btn-primary text-center block">
            <span class="mr-2">🎓</span>
            Gérer mes Compétences
          </router-link>
          
          <router-link to="/projets" class="btn-primary text-center block flex items-center justify-center">
            <span class="mr-2">🚀</span>
            Gérer mes Projets
          </router-link>
          
          <button
            @click="showProfileModal = true"
            class="btn-secondary text-center flex items-center justify-center"
          >
            <span class="mr-2">👤</span>
            Modifier mon Profil
          </button>
          
          <!-- Export Excel Button - Always visible but locked for non-premium -->
          <button 
            @click="handleExportClick"
            :disabled="exportLoading"
            class="btn-secondary text-center disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center relative group"
            :class="{ 'opacity-60 filter blur-[1px]': !userAccountInfo?.is_premium }"
          >
            <div v-if="!userAccountInfo?.is_premium" class="absolute -top-2 -right-2 w-6 h-6 bg-red-500 rounded-full flex items-center justify-center shadow-lg z-10 animate-pulse">
              <span class="text-white text-xs">🔒</span>
            </div>
            <div v-if="!userAccountInfo?.is_premium" class="absolute inset-0 bg-gray-900/20 backdrop-blur-[1px] rounded-lg"></div>
            <span class="mr-2">📊</span>
            {{ exportLoading ? 'Export...' : 'Exporter Excel' }}
          </button>
        </div>
      </div>

      <!-- Gamification Widget -->
      <div id="gamification-widget" class="mb-12">
        <GamificationWidget
          :user-stats="gamificationStats"
          :unlocked-trophies="unlockedTrophies"
          :locked-trophies="lockedTrophies"
          :current-level="currentLevel"
          :next-level-points="nextLevelPoints"
          :progress-to-next-level="progressToNextLevel"
        />
      </div>

      <!-- Recent Apprentissages -->
      <div id="recent-apprentissages" class="glass-card p-8 mb-12">
        <div class="flex items-center justify-between mb-6">
          <h2 class="text-2xl font-bold text-white flex items-center">
            <span class="mr-3">📚</span>
            Apprentissages Récents
          </h2>
          <router-link to="/portfolio" class="text-accent-400 hover:text-accent-300 text-sm transition-colors">
            Voir tout →
          </router-link>
        </div>
        
        <div v-if="recentApprentissages.length > 0" class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div 
            v-for="apprentissage in recentApprentissages.slice(0, 4)"
            :key="apprentissage.id"
            class="bg-white/5 p-6 rounded-xl hover:bg-white/10 transition-colors cursor-pointer"
            @click="navigateToApprentissage(apprentissage)"
          >
            <h3 class="text-lg font-semibold text-white mb-2">{{ apprentissage.title }}</h3>
            <EvaluationBadge :evaluation="apprentissage.evaluation" class="mb-3" />
            <p class="text-gray-300 text-sm line-clamp-2">{{ apprentissage.description }}</p>
            <div class="text-xs text-gray-400 mt-3">
              {{ formatDate(apprentissage.dateModification) }}
            </div>
          </div>
        </div>
        
        <div v-else class="text-center py-12">
          <div class="w-16 h-16 bg-gray-600/20 rounded-full flex items-center justify-center mx-auto mb-4">
            <span class="text-2xl text-gray-400">📚</span>
          </div>
          <p class="text-gray-400 mb-4">Aucun apprentissage critique créé</p>
          <router-link to="/portfolio" class="btn-primary">
            <span class="mr-2">➕</span>
            Créer mon premier apprentissage
          </router-link>
        </div>
      </div>

      <!-- Active Projects -->
      <div id="active-projects" class="glass-card p-8 mb-12">
        <div class="flex items-center justify-between mb-6">
          <h2 class="text-2xl font-bold text-white flex items-center">
            <span class="mr-3">🚀</span>
            Projets Actifs
          </h2>
          <router-link to="/projets" class="text-accent-400 hover:text-accent-300 text-sm transition-colors">
            Voir tout →
          </router-link>
        </div>
        
        <div v-if="activeProjets.length > 0" class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div 
            v-for="projet in activeProjets.slice(0, 4)"
            :key="projet.id"
            class="bg-white/5 p-6 rounded-xl hover:bg-white/10 transition-colors cursor-pointer"
            @click="navigateToProjet(projet)"
          >
            <div class="flex items-start space-x-4 mb-4">
              <div class="w-10 h-10 bg-gradient-to-r from-accent-400 to-accent-500 rounded-lg flex items-center justify-center">
                <span class="text-lg">{{ projet.icone }}</span>
              </div>
              <div class="flex-1">
                <h3 class="text-lg font-semibold text-white mb-2">{{ projet.titre }}</h3>
                <div class="flex flex-wrap gap-2">
                  <span 
                    v-for="tech in projet.technologies?.slice(0, 3)"
                    :key="tech"
                    class="px-2 py-1 bg-primary-400/20 text-primary-400 rounded-full text-xs"
                  >
                    {{ tech }}
                  </span>
                </div>
              </div>
            </div>
            <p class="text-gray-300 text-sm line-clamp-2">{{ projet.description }}</p>
            <div class="flex items-center justify-between mt-3">
              <span class="text-xs text-gray-400">{{ projet.niveau }}</span>
              <span class="px-2 py-1 bg-green-500/20 text-green-400 rounded-full text-xs">
                {{ projet.statut }}
              </span>
            </div>
          </div>
        </div>
        
        <div v-else class="text-center py-12">
          <div class="w-16 h-16 bg-gray-600/20 rounded-full flex items-center justify-center mx-auto mb-4">
            <span class="text-2xl text-gray-400">🚀</span>
          </div>
          <p class="text-gray-400 mb-4">Aucun projet créé</p>
          <router-link to="/projets" class="btn-primary">
            <span class="mr-2">➕</span>
            Créer mon premier projet
          </router-link>
        </div>
      </div>

      <!-- Public Portfolio Settings -->
      <div id="public-portfolio-section" class="glass-card p-8 mb-12">
        <div class="flex items-center justify-between mb-6">
          <h2 class="text-2xl font-bold text-white flex items-center">
            <span class="mr-3">🌐</span>
            Partage Public
          </h2>
          <button 
            @click="showPublicSection = !showPublicSection"
            class="text-gray-400 hover:text-white transition-colors p-2 rounded-lg hover:bg-white/10"
            :title="showPublicSection ? 'Réduire la section' : 'Développer la section'"
          >
            <div class="flex items-center space-x-2">
              <span class="text-sm">{{ showPublicSection ? 'Voir moins' : 'Voir plus' }}</span>
              <svg 
                class="w-5 h-5 transition-transform duration-300"
                :class="{ 'rotate-180': !showPublicSection }"
                fill="none" 
                stroke="currentColor" 
                viewBox="0 0 24 24"
              >
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
              </svg>
            </div>
          </button>
        </div>
        
        <PublicProfileSettings :is-collapsed="!showPublicSection" />
      </div>

      <!-- Profile Section -->
      <div id="profile-section" class="glass-card p-8 mb-12">
        <!-- Header with title and action buttons -->
        <div class="flex items-center justify-between mb-8">
          <h2 class="text-2xl font-bold text-white flex items-center">
            <span class="mr-3">👤</span>
            Mon Profil
          </h2>
          
          <!-- Mobile Action Menu -->
          <MobileActionMenu title="Actions" icon="⚙️">
            <!-- Desktop Buttons -->
            <template #desktop-buttons>
              <!-- Premium Status Indicator -->
              <div v-if="userAccountInfo?.is_premium" class="bg-gradient-to-r from-yellow-500 to-yellow-600 text-gray-900 font-bold px-6 py-3 rounded-xl flex items-center space-x-2 shadow-lg">
                <span class="text-xl">👑</span>
                <span class="text-lg">Premium</span>
              </div>
              <div v-else class="bg-gray-600 text-white font-medium px-6 py-3 rounded-xl flex items-center space-x-2">
                <span class="text-lg">🆓</span>
                <span class="text-lg">Gratuit</span>
              </div>
              
              <!-- Edit Profile Button -->
              <button 
                @click="showProfileModal = true"
                class="bg-gray-600 hover:bg-gray-700 text-white font-semibold px-4 py-2 rounded-lg transition-all duration-300 flex items-center space-x-2"
              >
                <span>✏️</span>
                <span>Modifier</span>
              </button>
              
              <!-- Restart Onboarding Button -->
              <button 
                @click="restartOnboarding"
                class="bg-blue-600 hover:bg-blue-700 text-white font-semibold px-4 py-2 rounded-lg transition-all duration-300 flex items-center space-x-2"
              >
                <span>🎯</span>
                <span>Visite Guidée</span>
              </button>
              
              <!-- Logout Button -->
              <button 
               @click="$emit('logout')"
                class="bg-red-600 hover:bg-red-700 text-white font-semibold px-4 py-2 rounded-lg transition-all duration-300 flex items-center space-x-2"
              >
                <span>🚪</span>
                <span>Déconnexion</span>
              </button>
            </template>
            
            <!-- Mobile Buttons -->
            <template #mobile-buttons>
              <!-- Premium Status -->
              <div v-if="userAccountInfo?.is_premium" class="w-full bg-gradient-to-r from-yellow-500 to-yellow-600 text-gray-900 font-bold px-4 py-3 rounded-lg flex items-center justify-center space-x-2">
                <span class="text-xl">👑</span>
                <span>Premium Actif</span>
              </div>
              <div v-else class="w-full bg-gray-600 text-white font-medium px-4 py-3 rounded-lg flex items-center justify-center space-x-2">
                <span>🆓</span>
                <span>Plan Gratuit</span>
              </div>
              
              <!-- Mobile Action Buttons -->
              <button 
                @click="showProfileModal = true; closeMenu()"
                class="w-full bg-gray-600 hover:bg-gray-700 text-white font-semibold px-4 py-3 rounded-lg transition-all duration-300 flex items-center justify-center space-x-2"
              >
                <span>✏️</span>
                <span>Modifier le Profil</span>
              </button>
              
              <button 
                @click="restartOnboarding(); closeMenu()"
                class="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold px-4 py-3 rounded-lg transition-all duration-300 flex items-center justify-center space-x-2"
              >
                <span>🎯</span>
                <span>Visite Guidée</span>
              </button>
              
              <button 
               @click="$emit('logout')"
                class="w-full bg-red-600 hover:bg-red-700 text-white font-semibold px-4 py-3 rounded-lg transition-all duration-300 flex items-center justify-center space-x-2"
              >
                <span>🚪</span>
                <span>Se Déconnecter</span>
              </button>
            </template>
          </MobileActionMenu>
        </div>
        
        <!-- Profile content -->
        <div class="flex items-center justify-between">
          <!-- User info with avatar -->
          <div class="flex items-center space-x-6">
            <div v-if="userProfile?.avatar_url" class="w-20 h-20 rounded-full overflow-hidden border-2 border-accent-400/50">
              <img :src="userProfile.avatar_url" :alt="userProfile.full_name" class="w-full h-full object-cover" />
            </div>
            <div v-else class="w-20 h-20 bg-gradient-to-r from-accent-400 to-accent-500 rounded-full flex items-center justify-center border-2 border-accent-400/50">
              <span class="text-2xl text-gray-900 font-bold">
                {{ getInitials(userProfile?.full_name) }}
              </span>
            </div>
            
            <div>
              <h3 class="text-2xl font-bold text-white mb-1">{{ userProfile?.full_name || 'Nom non renseigné' }}</h3>
              <p class="text-gray-300 text-lg">{{ userProfile?.formation || 'Formation non renseignée' }}</p>
              <p class="text-gray-400">{{ userProfile?.etablissement || 'Établissement non renseigné' }}</p>
              <div v-if="userProfile?.bio" class="mt-3 text-gray-300 text-sm">
                {{ userProfile.bio }}
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Onboarding Tour -->
      <OnboardingTour
        v-if="shouldShowOnboarding"
        :steps="onboardingSteps"
        :show="showOnboarding"
        @onboarding-finished="handleOnboardingFinished"
        @onboarding-skipped="handleOnboardingSkipped"
      />

      <!-- Premium Onboarding Modal -->
      <PremiumOnboardingModal
        v-if="showPremiumOnboarding"
        @close="closePremiumOnboarding"
        @free-selected="handleFreeSelected"
        @premium-purchased="handlePremiumPurchased"
      />

      <!-- Premium Congratulations Modal -->
      <PremiumCongratulationsModal
        v-if="showPremiumCongratulations"
        @close="closePremiumCongratulations"
      />

      <!-- Example Import Modal -->
      <ExampleImportModal
        v-if="showExampleImport"
        @close="closeExampleImport"
        @imported="handleExampleImported"
        @skipped="handleExampleSkipped"
      />

      <!-- Profile Modal -->
      <ProfileModal
        v-if="showProfileModal"
        :user="currentUser"
        :is-premium="isPremium.value"
        @save="handleProfileSave"
        @close="showProfileModal = false"
      />
      
      <!-- Trophy Modal -->
      <TrophyModal
        v-if="showTrophyModal"
        :new-trophies="newTrophies"
        :current-level="currentLevel"
        :total-points="gamificationStats.totalPoints"
        @close="closeTrophyModal"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { authService, profileService, competenceService, apprentissageService, projetService, supabase } from '../lib/supabase'
import { usePremiumLimits } from '../composables/usePremiumLimits'
import EvaluationBadge from '../components/EvaluationBadge.vue'
import PublicProfileSettings from '../components/PublicProfileSettings.vue'
import OnboardingTour from '../components/OnboardingTour.vue'
import PremiumOnboardingModal from '../components/PremiumOnboardingModal.vue'
import PremiumCongratulationsModal from '../components/PremiumCongratulationsModal.vue'
import ExampleImportModal from '../components/ExampleImportModal.vue'
import ProfileModal from '../components/ProfileModal.vue'
import GamificationWidget from '../components/GamificationWidget.vue'
import TrophyModal from '../components/TrophyModal.vue'
import LevelBadge from '../components/LevelBadge.vue'
import MobileActionMenu from '../components/MobileActionMenu.vue'
import { useTheme } from '../composables/useTheme'
import { useGamification } from '../composables/useGamification'

const router = useRouter()
const route = useRoute()

// State
const loading = ref(true)
const currentUser = ref<any>(null)
const userProfile = ref<any>(null)
const userAccountInfo = ref<any>(null)
const showProfileModal = ref(false)
const isPremium = computed(() => userAccountInfo.value?.is_premium || false)
const competences = ref<any[]>([])
const apprentissages = ref<any[]>([])
const projets = ref<any[]>([])
const categories = ref<any[]>([])

// Onboarding state
const showOnboarding = ref(false)
const shouldShowOnboarding = ref(false)
const showPremiumOnboarding = ref(false)
const showPremiumCongratulations = ref(false)
const showExampleImport = ref(false)
const showPublicSection = ref(false)

// Export state
const exportLoading = ref(false)

// Premium limits
const { userLimits, loadUserLimits } = usePremiumLimits()

// Gamification
const { 
  userStats: gamificationStats, 
  unlockedTrophies, 
  lockedTrophies, 
  currentLevel, 
  nextLevelPoints, 
  progressToNextLevel,
  newTrophies,
  showTrophyModal,
  loadUserStats: loadGamificationStats,
  checkTrophies,
  getRarityColor,
  getRarityGlow,
  closeTrophyModal,
  getTrophyProgress
} = useGamification()

// Theme
const { loadUserTheme } = useTheme()

// Computed
const stats = computed(() => ({
  competences: competences.value.length,
  apprentissages: apprentissages.value.length,
  projets: projets.value.length,
  bienMaitrise: apprentissages.value.filter(a => a.evaluation === 'Bien Maîtrisé').length,
  pourcentageMaitrise: apprentissages.value.length > 0 
    ? Math.round((apprentissages.value.filter(a => a.evaluation === 'Bien Maîtrisé').length / apprentissages.value.length) * 100)
    : 0
}))

const recentApprentissages = computed(() => {
  return apprentissages.value
    .sort((a, b) => new Date(b.dateModification).getTime() - new Date(a.dateModification).getTime())
    .slice(0, 4)
})

const activeProjets = computed(() => {
  return projets.value.filter(p => p.statut === 'En cours' || p.statut === 'Terminé')
})

// Onboarding steps
const onboardingSteps = [
  {
    targetId: 'stats-cards',
    title: 'Vos Statistiques',
    description: 'Suivez vos progrès avec un aperçu de vos compétences, apprentissages et projets.',
    position: 'bottom' as const
  },
  {
    targetId: 'quick-actions',
    title: 'Actions Rapides',
    description: 'Accédez rapidement à la gestion de vos compétences, projets et profil.',
    position: 'top' as const
  },
  {
    targetId: 'gamification-widget',
    title: 'Système de Progression',
    description: 'Débloquez des trophées et montez de niveau en enrichissant votre portfolio ! Suivez votre progression et découvrez les récompenses à obtenir.',
    position: 'top' as const
  },
  {
    targetId: 'recent-apprentissages',
    title: 'Apprentissages Récents',
    description: 'Consultez vos derniers apprentissages critiques et leur évaluation.',
    position: 'top' as const
  },
  {
    targetId: 'active-projects',
    title: 'Projets Actifs',
    description: 'Gérez vos projets en cours et terminés depuis cette section.',
    position: 'top' as const
  },
  {
    targetId: 'public-portfolio-section',
    title: 'Partage Public',
    description: 'Configurez le partage public de votre portfolio avec un lien personnalisé.',
    position: 'top' as const
  },
  {
    targetId: 'profile-section',
    title: 'Mon Profil',
    description: 'Gérez vos informations personnelles et professionnelles.',
    position: 'top' as const
  }
]

// Methods
onMounted(async () => {
  await loadDashboardData()
})

const loadDashboardData = async () => {
  loading.value = true
  
  try {
    // Get current user
    const user = await authService.getCurrentUser()
    if (!user) {
      router.push('/')
      return
    }
    
    currentUser.value = user
    console.log('Current user loaded:', user)
    
    // Load user profile
    await loadUserProfile(user.id)
    
    // Load user limits
    await loadUserLimits()
    // Load user theme
    await loadUserTheme()
    
    // Load gamification data
    await loadGamificationStats()
    
    // Load user account info (including premium status)
    await loadUserAccountInfo()
    
    // Load user data
    await Promise.all([
      loadUserCompetences(user.id),
      loadUserApprentissages(user.id),
      loadUserProjets(user.id),
      loadUserCategories(user.id)
    ])
    
    // Check for premium success from URL (before onboarding)
    const premiumSuccess = route.query.premium === 'success'
    if (premiumSuccess) {
      console.log('Premium success detected, showing congratulations')
      showPremiumCongratulations.value = true
      return // Don't show other onboarding if premium success
    }
    
  } catch (error) {
    console.error('Error loading dashboard data:', error)
  } finally {
    loading.value = false
  }
}

const loadUserAccountInfo = async () => {
  try {
    const user = await authService.getCurrentUser()
    if (!user) return
    
    const { data: orders } = await supabase
      .from('stripe_orders')
      .select('*')
      .eq('status', 'completed')
      .limit(1)
    
    userAccountInfo.value = {
      is_premium: !!(orders && orders.length > 0),
      premium_since: orders && orders.length > 0 ? orders[0].created_at : null
    }
  } catch (error) {
    console.error('Error checking premium status:', error)
    userAccountInfo.value = {
      is_premium: false,
      premium_since: null
    }
  }
}

const loadUserCompetences = async (userId: string) => {
  try {
    const { data } = await competenceService.getCompetences()
    if (data) {
      competences.value = data.filter(c => c.user_id === userId || c.user_id === null)
    }
  } catch (error) {
    console.error('Error loading competences:', error)
  }
}

const loadUserApprentissages = async (userId: string) => {
  try {
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
        dateModification: app.updated_at
      }))
    }
  } catch (error) {
    console.error('Error loading apprentissages:', error)
  }
}

const loadUserProjets = async (userId: string) => {
  try {
    console.log('Dashboard: Loading projects for user:', userId)
    const { data } = await projetService.getUserProjets(userId)
    console.log('Dashboard: Projects loaded:', data)
    if (data) {
      projets.value = data.map(projet => ({
        ...projet,
        fichiers: projet.fichiers_projets || []
      }))
      console.log('Dashboard: Projects mapped:', projets.value)
    }
  } catch (error) {
    console.error('Error loading projets:', error)
  }
}

const loadUserCategories = async (userId: string) => {
  try {
    const { apprentissageCategoryService } = await import('../lib/supabase')
    const { data } = await apprentissageCategoryService.getUserCategories(userId)
    if (data) {
      categories.value = data
    }
  } catch (error) {
    console.error('Error loading categories:', error)
  }
}

const loadUserProfile = async (userId: string) => {
  try {
    console.log('Loading user profile for:', userId)
    const { data: profile, error } = await profileService.getProfile(userId)
    
    if (error) {
      console.error('Error loading profile - Full details:', {
        error,
        code: error.code,
        message: error.message,
        details: error.details,
        userId
      })
      
      // Même en cas d'erreur, essayer de créer un profil de base
      if (currentUser.value) {
        console.log('Creating fallback profile due to error...')
        const fallbackData = {
          email: currentUser.value.email || '',
          full_name: currentUser.value.user_metadata?.full_name || '',
          formation: 'BUT GEII - Parcours AII',
          annee_etudes: '3',
          onboarding_completed: false
        }
        
        const { data: newProfile } = await profileService.createOrUpdateProfile(userId, fallbackData)
        if (newProfile) {
          userProfile.value = newProfile
          
          // Trigger onboarding for new profile
          await triggerOnboardingFlow(userId)
        }
      }
      return
    }
    
    if (profile) {
      console.log('Profile loaded successfully:', profile)
      userProfile.value = profile
      
      // Vérifier la persistance des données
      console.log('Profile data verification:', {
        full_name: profile.full_name,
        email: profile.email,
        formation: profile.formation,
        etablissement: profile.etablissement,
        telephone: profile.telephone,
        linkedin: profile.linkedin,
        github: profile.github,
        bio: profile.bio,
        updated_at: profile.updated_at
      })
      
      // Forcer la mise à jour de l'interface utilisateur
      await nextTick()
      
      // Check if onboarding should be shown
      await triggerOnboardingFlow(userId, profile)
    } else {
      console.warn('No profile data found for user:', userId)
      
      // Si aucun profil n'existe, en créer un avec les données de base
      if (currentUser.value) {
        console.log('Creating basic profile for user...')
        const basicProfileData = {
          email: currentUser.value.email || '',
          full_name: currentUser.value.user_metadata?.full_name || '',
          formation: 'BUT GEII - Parcours AII',
          annee_etudes: '3',
          onboarding_completed: false
        }
        
        console.log('Creating profile with data:', basicProfileData)
        const { data: newProfile, error: createError } = await profileService.createOrUpdateProfile(userId, basicProfileData)
        if (!createError && newProfile) {
          console.log('Basic profile created:', newProfile)
          userProfile.value = newProfile
          
          // Trigger onboarding for new profile
          await triggerOnboardingFlow(userId, newProfile)
        } else {
          console.error('Failed to create basic profile:', createError)
        }
      }
    }
  } catch (error) {
    console.error('Exception loading profile:', error)
  }
}

const getInitials = (name: string) => {
  if (!name) return '??'
  return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)
}

const formatDate = (dateString: string) => {
  return new Date(dateString).toLocaleDateString('fr-FR')
}

const getProfileCompletionPercentage = () => {
  if (!userProfile.value) return 0
  
  const fields = [
    userProfile.value.full_name,
    userProfile.value.formation,
    userProfile.value.etablissement,
    userProfile.value.bio,
    userProfile.value.telephone,
    userProfile.value.linkedin,
    userProfile.value.github
  ]
  
  const completedFields = fields.filter(field => field && field.trim() !== '').length
  return Math.round((completedFields / fields.length) * 100)
}

const formatMemberSince = () => {
  if (!userProfile.value?.created_at) return 'Récemment'
  return new Date(userProfile.value.created_at).toLocaleDateString('fr-FR', {
    year: 'numeric',
    month: 'long'
  })
}

const navigateToApprentissage = (apprentissage: any) => {
  router.push({
    path: '/portfolio',
    query: { 
      competence: apprentissage.competenceId,
      apprentissage: apprentissage.id 
    }
  })
}

const navigateToProjet = (projet: any) => {
  router.push({
    path: '/projets',
    query: { project: projet.id }
  })
}

const handleProfileSave = (profileData: any) => {
  console.log('Profile save handler called with:', profileData)
  
  // Mettre à jour immédiatement l'interface utilisateur
  if (profileData) {
    // Fusionner les données en préservant les valeurs existantes pour les champs non fournis
    userProfile.value = {
      ...userProfile.value,
      ...profileData,
      // S'assurer que l'email et le nom sont toujours présents
      email: profileData.email || userProfile.value?.email || currentUser.value?.email || '',
      full_name: profileData.full_name || userProfile.value?.full_name || currentUser.value?.user_metadata?.full_name || ''
    }
    console.log('Updated userProfile in dashboard:', userProfile.value)
  }
  
  // Forcer la mise à jour de l'interface
  nextTick(() => {
    console.log('UI updated after profile save')
  })
  
  // Recharger les données du profil pour s'assurer de la persistance
  setTimeout(async () => {
    if (currentUser.value) {
      console.log('Reloading profile data after save...')
      await loadUserProfile(currentUser.value.id)
    }
  }, 1000)
}

// Onboarding handlers
const handleOnboardingFinished = async () => {
  showOnboarding.value = false
  shouldShowOnboarding.value = false
  
  if (currentUser.value) {
    await profileService.updateOnboardingStatus(currentUser.value.id, true)
  }
}

const handleOnboardingSkipped = async () => {
  showOnboarding.value = false
  shouldShowOnboarding.value = false
  
  if (currentUser.value) {
    await profileService.updateOnboardingStatus(currentUser.value.id, true)
  }
}

const closePremiumOnboarding = () => {
  showPremiumOnboarding.value = false
  
  // Start regular onboarding if profile is not completed
  if (shouldShowOnboarding.value) {
    setTimeout(() => {
      showOnboarding.value = true
    }, 500)
  }
}

const handleFreeSelected = () => {
  closePremiumOnboarding()
}

const handlePremiumPurchased = () => {
  showPremiumOnboarding.value = false
  showPremiumCongratulations.value = true
}

const closePremiumCongratulations = () => {
  showPremiumCongratulations.value = false
  
  // Start regular onboarding if needed
  if (shouldShowOnboarding.value) {
    setTimeout(() => {
      showOnboarding.value = true
    }, 500)
  }
}

const restartOnboarding = async () => {
  // Reset onboarding status
  if (currentUser.value) {
    await profileService.updateOnboardingStatus(currentUser.value.id, false)
  }
  
  // Show onboarding tour
  shouldShowOnboarding.value = true
  showOnboarding.value = true
}


// Export handler
const handleExportClick = async () => {
  if (!userAccountInfo.value?.is_premium) {
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
  
  if (!userProfile.value) {
    alert('Impossible d\'exporter : données utilisateur manquantes')
    return
  }
  
  exportLoading.value = true
  
  try {
    // Import export functions
    const { exportPortfolioToExcel, prepareExportData } = await import('../lib/excelExport')
    
    console.log('Exporting with categories:', categories.value)
    
    // Préparer les données d'export
    const exportData = prepareExportData(
      userProfile.value,
      competences.value,
      apprentissages.value,
      projets.value,
      categories.value
    )
    
    console.log('Export data prepared:', {
      categoriesCount: exportData.categories?.length || 0,
      apprentissagesCount: exportData.apprentissages.length,
      apprentissagesWithCategories: exportData.apprentissages.filter(a => a.categoryId).length
    })
    
    // Exporter vers Excel
    await exportPortfolioToExcel(exportData)
    
    // Afficher un message de succès (optionnel)
    console.log('Export Excel réussi !')
  } catch (error) {
    console.error('Erreur lors de l\'export:', error)
    alert('Une erreur est survenue lors de l\'export. Veuillez réessayer.')
  } finally {
    exportLoading.value = false
  }
}


// Example import handlers
const closeExampleImport = () => {
  showExampleImport.value = false
  // Show premium onboarding after example import decision
  setTimeout(() => {
    showPremiumOnboarding.value = true
  }, 500)
}

const handleExampleImported = async () => {
  showExampleImport.value = false
  
  // Reload dashboard data to show imported examples
  await loadDashboardData()
  
  // Show success message
  const notification = document.createElement('div')
  notification.className = 'fixed top-20 right-4 z-50 glass-card p-4 max-w-sm shadow-2xl border border-green-400/30 animate-fade-in'
  notification.innerHTML = `
    <div class="flex items-center space-x-3">
      <div class="w-8 h-8 bg-green-500/20 rounded-full flex items-center justify-center">
        <span class="text-green-400 text-lg">✓</span>
      </div>
      <div class="flex-1">
        <p class="text-white font-medium text-sm">Exemples importés !</p>
        <p class="text-gray-300 text-xs mt-1">Vous pouvez maintenant les modifier selon vos besoins</p>
      </div>
    </div>
  `
  
  document.body.appendChild(notification)
  
  // Auto remove after 4 seconds
  setTimeout(() => {
    if (notification.parentNode) {
      notification.remove()
    }
  }, 4000)
  
  // Continue with premium onboarding
  setTimeout(() => {
    showPremiumOnboarding.value = true
  }, 1000)
}

const handleExampleSkipped = () => {
  showExampleImport.value = false
  // Continue with premium onboarding
  setTimeout(() => {
    showPremiumOnboarding.value = true
  }, 500)
}

// New function to handle onboarding flow
const triggerOnboardingFlow = async (userId: string, profile?: any) => {
  const currentProfile = profile || userProfile.value
  
  console.log('Triggering onboarding flow:', {
    userId,
    onboarding_completed: currentProfile?.onboarding_completed,
    hasProfile: !!currentProfile
  })
  
  // Only show onboarding if not completed
  if (!currentProfile?.onboarding_completed) {
    shouldShowOnboarding.value = true
    
    // Check if user has any data - if not, show example import first
    const hasData = await checkUserHasData(userId)
    console.log('User has existing data:', hasData)
    
    if (!hasData) {
      console.log('Showing example import modal')
      // Small delay to ensure UI is ready
      setTimeout(() => {
        showExampleImport.value = true
      }, 500)
    } else {
      console.log('Showing premium onboarding modal')
      // Small delay to ensure UI is ready
      setTimeout(() => {
        showPremiumOnboarding.value = true
      }, 500)
    }
  } else {
    console.log('Onboarding already completed, skipping')
  }
}

// Enhanced function to check if user has data
const checkUserHasData = async (userId: string) => {
  try {
    console.log('Checking if user has data for:', userId)
    
    const [competencesResult, apprentissagesResult, projetsResult] = await Promise.all([
      competenceService.getCompetences(),
      apprentissageService.getUserApprentissages(userId),
      projetService.getUserProjets(userId)
    ])
    
    const userCompetences = competencesResult.data?.filter(c => c.user_id === userId) || []
    const userApprentissages = apprentissagesResult.data || []
    const userProjets = projetsResult.data || []
    
    const hasData = userCompetences.length > 0 || userApprentissages.length > 0 || userProjets.length > 0
    
    console.log('User data check result:', {
      competences: userCompetences.length,
      apprentissages: userApprentissages.length,
      projets: userProjets.length,
      hasData
    })
    
    return hasData
  } catch (error) {
    console.error('Error checking user data:', error)
    return false
  }
}
</script>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>