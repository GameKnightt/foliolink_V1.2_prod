<template>
  <div 
    class="min-h-screen"
    :class="portfolioData ? '' : 'bg-gradient-to-br from-gray-900 via-blue-900 to-gray-900'"
    :style="portfolioData ? getPortfolioBackgroundStyle() : {}"
  >
    <!-- Public Portfolio Navbar -->
    <PublicNavbar />
    
    <!-- SEO Meta Tags -->
    <Head v-if="portfolioData">
      <title>{{ `Portfolio de ${portfolioData.profile.full_name} - ${portfolioData.profile.formation}` }}</title>
      <meta name="description" :content="`Découvrez le portfolio étudiant BUT de ${portfolioData.profile.full_name}. ${portfolioData.profile.bio || 'Compétences, projets et apprentissages critiques.'}`" />
      <meta property="og:title" :content="`Portfolio de ${portfolioData.profile.full_name}`" />
      <meta property="og:description" :content="`${portfolioData.profile.formation} - ${portfolioData.profile.etablissement || 'Étudiant BUT'}`" />
      <meta property="og:type" content="profile" />
      <meta property="og:url" :content="currentUrl" />
      <meta property="og:image" :content="portfolioData.profile.avatar_url || defaultOgImage" />
      <meta name="twitter:card" content="summary_large_image" />
      <meta name="twitter:title" :content="`Portfolio de ${portfolioData.profile.full_name}`" />
      <meta name="twitter:description" :content="`${portfolioData.profile.formation} - Découvrez mes compétences et projets`" />
    </Head>
    
    <!-- Loading State -->
    <div v-if="loading" class="flex items-center justify-center min-h-screen">
      <div class="glass-card p-8 text-center">
        <div class="w-16 h-16 bg-gradient-to-r from-accent-400 to-accent-500 rounded-full flex items-center justify-center mx-auto mb-4 animate-pulse">
          <span class="text-2xl">📁</span>
        </div>
        <h2 class="text-2xl font-bold text-white mb-2">Chargement du portfolio...</h2>
        <p class="text-gray-300">Récupération des données</p>
      </div>
    </div>

    <!-- Password Required Modal -->

    <!-- Error State -->
    <div v-if="error" class="flex items-center justify-center min-h-screen">
      <div class="glass-card p-8 text-center max-w-md w-full mx-4">
        <div class="w-16 h-16 bg-red-500/20 rounded-full flex items-center justify-center mx-auto mb-4">
          <span class="text-2xl text-red-400">❌</span>
        </div>
        <h2 class="text-2xl font-bold text-white mb-2">Portfolio Non Trouvé</h2>
        <p class="text-gray-300 mb-6">{{ error }}</p>
        <router-link to="/" class="btn-primary">
          <span class="mr-2">🏠</span>
          Retour à l'accueil
        </router-link>
      </div>
    </div>

    <!-- Portfolio Content -->
    <div v-else-if="portfolioData" class="pt-16">
      <!-- Header -->
      <section class="relative py-20 overflow-hidden">
        <div class="absolute inset-0">
          <div class="absolute top-20 left-10 w-72 h-72 bg-accent-500/10 rounded-full blur-3xl animate-pulse"></div>
          <div class="absolute bottom-20 right-10 w-96 h-96 bg-primary-500/10 rounded-full blur-3xl animate-pulse delay-1000"></div>
        </div>
        
        <div class="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center z-10">
          <!-- Profile Info -->
          <div class="mb-12">
            <div v-if="portfolioData.profile.avatar_url" class="w-32 h-32 rounded-full overflow-hidden mx-auto mb-6 border-4 border-accent-400/50">
              <img :src="portfolioData.profile.avatar_url" :alt="portfolioData.profile.full_name" class="w-full h-full object-cover" />
            </div>
            <div v-else class="w-32 h-32 bg-gradient-to-r from-accent-400 to-accent-500 rounded-full flex items-center justify-center mx-auto mb-6 border-4 border-accent-400/50">
              <span class="text-4xl text-gray-900 font-bold">
                {{ getInitials(portfolioData.profile.full_name) }}
              </span>
            </div>
            
            <h1 class="text-4xl md:text-6xl font-bold text-white mb-4">
              Portfolio de <span class="gradient-text">{{ portfolioData.profile.full_name }}</span>
            </h1>
            
            <p class="text-xl text-gray-300 mb-4">{{ portfolioData.profile.formation }}</p>
            <p v-if="portfolioData.profile.etablissement" class="text-lg text-white mb-6">{{ portfolioData.profile.etablissement }}</p>
            <p v-if="portfolioData.profile.bio" class="text-white max-w-3xl mx-auto leading-relaxed">{{ portfolioData.profile.bio }}</p>
          </div>

          <!-- Stats -->
          <div class="grid grid-cols-2 md:grid-cols-3 gap-6 max-w-4xl mx-auto mb-16">
            <div class="glass-card p-6 text-center">
              <div class="text-3xl font-bold gradient-text mb-2">{{ portfolioData.apprentissages.length }}</div>
              <div class="text-white text-sm">Apprentissages</div>
            </div>
            <div class="glass-card p-6 text-center">
              <div class="text-3xl font-bold gradient-text mb-2">{{ portfolioData.projets.length }}</div>
              <div class="text-white text-sm">Projets</div>
            </div>
            <div class="glass-card p-6 text-center">
              <div class="text-3xl font-bold gradient-text mb-2">{{ masteredCount }}</div>
              <div class="text-white text-sm">Bien Maîtrisées</div>
            </div>
          </div>
        </div>
      </section>

      <!-- Featured Apprentissages -->
      <section v-if="portfolioData.featured.length > 0" class="py-20 relative">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="text-center mb-12">
            <h2 class="text-4xl font-bold text-white mb-6">
              Apprentissages <span class="gradient-text">Vedettes</span>
            </h2>
          </div>

          <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <div 
              v-for="featured in portfolioData.featured" 
              :key="featured.id"
              class="glass-card p-8 hover:scale-105 transition-all duration-500 cursor-pointer"
              @click="openApprentissageModal(featured.apprentissages)"
            >
              <div class="flex items-start justify-between mb-4">
                <h3 class="text-xl font-bold text-white mb-2">{{ featured.apprentissages.title }}</h3>
                <div class="text-accent-400 text-xl">⭐</div>
              </div>
              
              <EvaluationBadge :evaluation="featured.apprentissages.evaluation" class="mb-4" />
              
              <p class="text-white mb-6 leading-relaxed">
                {{ featured.apprentissages.description }}
              </p>
              
              <div class="text-sm text-white">
                Compétence : {{ getCompetenceTitle(featured.apprentissages.competence_id) }}
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Projects Section -->
      <section v-if="portfolioData.projets.length > 0" class="py-20 relative">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="text-center mb-12">
            <h2 class="text-4xl font-bold text-white mb-6">
              <span class="gradient-text">Projets</span> Étudiants
            </h2>
          </div>

          <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
            <div 
              v-for="projet in portfolioData.projets" 
              :key="projet.id"
             class="glass-card p-8 hover:scale-105 transition-all duration-500 cursor-pointer group"
             @click="openProjetModal(projet)"
            >
              <div class="flex items-start space-x-4 mb-6">
                <div class="w-12 h-12 bg-gradient-to-r from-accent-400 to-accent-500 rounded-xl flex items-center justify-center">
                  <span class="text-xl">{{ projet.icone }}</span>
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
              
              <p class="text-white mb-6 leading-relaxed">
                {{ projet.description }}
              </p>

              <div v-if="projet.fonctionnalites && projet.fonctionnalites.length > 0" class="space-y-4 mb-6">
                <h4 class="text-lg font-semibold text-white">Fonctionnalités principales :</h4>
                <ul class="space-y-2 text-white">
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
                <div class="text-sm text-white">
                  <span class="font-medium">{{ projet.niveau }}</span> • Durée : {{ projet.duree }}
                </div>
               <div class="flex items-center text-accent-400 opacity-0 group-hover:opacity-100 transition-all duration-300">
                 <span class="text-sm font-medium mr-1">Voir détails</span>
                 <span class="text-lg">→</span>
               </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Contact Section -->
      <section class="py-20 relative">
        <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <div class="glass-card p-8">
            <h2 class="text-3xl font-bold text-white mb-6">Contact</h2>
            
            <!-- Contact Links -->
            <div class="flex flex-wrap justify-center gap-4">
              <a v-if="portfolioData.profile.email" 
                 :href="`mailto:${portfolioData.profile.email}`" 
                 class="flex items-center space-x-2 glass-card px-4 py-2 hover:bg-white/20 transition-all duration-300 hover:scale-105 group">
                <span class="text-accent-400 text-lg">📧</span>
                <span class="text-white font-medium text-sm">Email</span>
              </a>
              
              <a v-if="portfolioData.profile.telephone" 
                 :href="`tel:${portfolioData.profile.telephone}`" 
                 class="flex items-center space-x-2 glass-card px-4 py-2 hover:bg-white/20 transition-all duration-300 hover:scale-105 group">
                <span class="text-accent-400 text-lg">📱</span>
                <span class="text-white font-medium text-sm">Téléphone</span>
              </a>
              
              <a v-if="portfolioData.profile.linkedin" 
                 :href="portfolioData.profile.linkedin" 
                 target="_blank" 
                 rel="noopener noreferrer"
                 class="flex items-center space-x-2 glass-card px-4 py-2 hover:bg-white/20 transition-all duration-300 hover:scale-105 group">
                <span class="text-blue-400 text-lg">💼</span>
                <span class="text-white font-medium text-sm">LinkedIn</span>
              </a>
              
              <a v-if="portfolioData.profile.github" 
                 :href="portfolioData.profile.github" 
                 target="_blank" 
                 rel="noopener noreferrer"
                 class="flex items-center space-x-2 glass-card px-4 py-2 hover:bg-white/20 transition-all duration-300 hover:scale-105 group">
                <span class="text-gray-300 text-lg">🐙</span>
                <span class="text-white font-medium text-sm">GitHub</span>
              </a>
            </div>
            
            <!-- Message si aucun contact disponible -->
            <div v-if="!portfolioData.profile.email && !portfolioData.profile.telephone && !portfolioData.profile.linkedin && !portfolioData.profile.github" 
                 class="text-center py-8">
              <div class="text-gray-400 mb-4">
                <span class="text-4xl">📞</span>
              </div>
              <p class="text-white">Aucune information de contact disponible</p>
            </div>
            
            <div class="mt-8">
              <p class="text-white leading-relaxed">
                Portfolio créé avec <a href="/" class="text-accent-400 hover:text-accent-300 transition-colors">FolioLink</a>
              </p>
            </div>
          </div>
        </div>
      </section>
    </div>
    
    <!-- Apprentissage Detail Modal -->
    <div v-if="showApprentissageModal && selectedApprentissage" class="fixed inset-0 z-50 overflow-y-auto">
      <div class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
        <!-- Background overlay -->
        <div 
          class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity backdrop-blur-sm"
          @click="closeApprentissageModal"
        ></div>

        <!-- Modal -->
        <div class="inline-block align-bottom glass-card text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-4xl sm:w-full">
          <!-- Header -->
          <div class="bg-white/10 px-6 py-4 border-b border-white/20">
            <div class="flex items-center justify-between group-hover:text-accent-400 transition-colors">
              <h3 class="text-xl font-bold text-white">
                {{ selectedApprentissage.title }}
              </h3>
              <button 
                @click="closeApprentissageModal"
                class="text-gray-400 hover:text-gray-200 transition-colors"
              >
                <span class="text-2xl">×</span>
              </button>
            </div>
            <EvaluationBadge :evaluation="selectedApprentissage.evaluation" class="mt-2" />
          </div>

          <!-- Content -->
          <div class="px-6 py-6 max-h-[500px] overflow-y-auto">
            <div class="space-y-6">
              <!-- Description -->
              <div>
                <h4 class="text-lg font-semibold text-white mb-3">
                  Description
                </h4>
                <p class="text-gray-300 leading-relaxed">
                  {{ selectedApprentissage.description }}
                </p>
              </div>

              <!-- Argumentaire -->
              <div>
                <h4 class="text-lg font-semibold text-white mb-3">
                  Argumentaire
                </h4>
                <p class="text-gray-300 leading-relaxed">
                  {{ selectedApprentissage.argumentaire }}
                </p>
              </div>

              <!-- Preuves -->
              <div v-if="selectedApprentissage.preuves && selectedApprentissage.preuves.length > 0">
                <h4 class="text-lg font-semibold text-white mb-3">
                  Preuves et Ressources
                </h4>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                  <a
                    v-for="preuve in selectedApprentissage.preuves"
                    :key="preuve.id"
                    :href="preuve.url"
                    target="_blank"
                    rel="noopener noreferrer"
                    class="flex items-center space-x-3 p-3 bg-white/10 rounded-lg hover:bg-white/20 transition-colors"
                  >
                    <div class="w-8 h-8 rounded-lg flex items-center justify-center bg-primary-400/20 border border-primary-400/30">
                      <span class="text-primary-400">🔗</span>
                    </div>
                    <div class="flex-1">
                      <p class="font-medium text-white">{{ preuve.titre }}</p>
                      <p class="text-sm text-gray-400">{{ preuve.type }}</p>
                    </div>
                  </a>
                </div>
              </div>

              <!-- Informations -->
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4 pt-4 border-t border-white/20">
                <div>
                  <p class="text-sm text-gray-400">Compétence</p>
                  <p class="font-medium text-white">{{ getCompetenceTitle(selectedApprentissage.competence_id) }}</p>
                </div>
                <div>
                  <p class="text-sm text-gray-400">Niveau</p>
                  <p class="font-medium text-white">Niveau {{ selectedApprentissage.level }}</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Footer -->
          <div class="bg-white/10 px-6 py-4 border-t border-white/20 flex justify-end">
            <button 
              @click="closeApprentissageModal"
              class="btn-primary"
            >
              Fermer
            </button>
          </div>
        </div>
      </div>
    </div>
    
   <!-- Projet Detail Modal -->
   <div v-if="showProjetModal && selectedProjet" class="fixed inset-0 z-50 overflow-y-auto">
     <div class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
       <!-- Background overlay -->
       <div 
         class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity backdrop-blur-sm"
         @click="closeProjetModal"
       ></div>

       <!-- Modal -->
       <div class="inline-block align-bottom glass-card text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-5xl sm:w-full">
         <!-- Header -->
         <div class="bg-white/10 px-6 py-4 border-b border-white/20">
           <div class="flex items-center justify-between">
             <div class="flex items-center space-x-3">
               <div class="w-10 h-10 bg-gradient-to-r from-accent-400 to-accent-500 rounded-xl flex items-center justify-center">
                 <span class="text-xl">{{ selectedProjet.icone }}</span>
              </div>
              <h3 class="text-xl font-bold text-white">
                {{ selectedProjet.titre }}
              </h3>
            </div>
            <button 
               @click="closeProjetModal"
               class="text-gray-400 hover:text-gray-200 transition-colors"
             >
               <span class="text-2xl">×</span>
             </button>
           </div>
           <div class="flex flex-wrap gap-2 mt-3">
             <span 
               v-for="tech in selectedProjet.technologies"
               :key="tech"
               class="px-3 py-1 bg-primary-400/20 text-primary-400 rounded-full text-sm font-medium"
             >
               {{ tech }}
             </span>
           </div>
         </div>

         <!-- Content -->
         <div class="px-6 py-6 max-h-[600px] overflow-y-auto">
           <div class="space-y-6">
             <!-- Description -->
             <div>
               <h4 class="text-lg font-semibold text-white mb-3">
                 Description du Projet
               </h4>
               <p class="text-gray-300 leading-relaxed">
                 {{ selectedProjet.description }}
               </p>
             </div>

             <!-- Fonctionnalités -->
             <div v-if="selectedProjet.fonctionnalites && selectedProjet.fonctionnalites.length > 0">
               <h4 class="text-lg font-semibold text-white mb-3">
                 Fonctionnalités Principales
               </h4>
               <ul class="space-y-2">
                 <li 
                   v-for="fonctionnalite in selectedProjet.fonctionnalites"
                   :key="fonctionnalite"
                   class="flex items-start space-x-2"
                 >
                   <span class="text-green-400 mr-2">✓</span>
                   <span class="text-gray-300">{{ fonctionnalite }}</span>
                 </li>
               </ul>
             </div>

             <!-- Technologies Détaillées -->
             <div v-if="selectedProjet.technologies && selectedProjet.technologies.length > 0">
               <h4 class="text-lg font-semibold text-white mb-3">
                 Technologies Utilisées
               </h4>
               <div class="grid grid-cols-2 md:grid-cols-3 gap-3">
                 <div 
                   v-for="tech in selectedProjet.technologies"
                   :key="tech"
                   class="bg-primary-400/10 border border-primary-400/30 rounded-lg p-3 text-center"
                 >
                   <p class="text-primary-400 font-medium">{{ tech }}</p>
                 </div>
               </div>
             </div>

             <!-- Fichiers et Liens -->
             <div v-if="getProjetFiles(selectedProjet).length > 0">
               <h4 class="text-lg font-semibold text-white mb-3">
                 Fichiers et Ressources
               </h4>
               <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                 <a
                   v-for="fichier in getProjetFiles(selectedProjet)"
                   :key="fichier.id"
                   :href="fichier.url"
                   target="_blank"
                   rel="noopener noreferrer"
                   class="flex items-center space-x-3 p-3 bg-white/10 rounded-lg hover:bg-white/20 transition-colors"
                 >
                   <div class="w-8 h-8 rounded-lg flex items-center justify-center bg-accent-400/20 border border-accent-400/30">
                     <span v-if="fichier.type === 'Fichier'" class="text-accent-400">📄</span>
                     <span v-else class="text-accent-400">🔗</span>
                   </div>
                   <div class="flex-1">
                     <p class="font-medium text-white">{{ fichier.nom }}</p>
                     <p class="text-sm text-gray-400">{{ fichier.type }}</p>
                   </div>
                 </a>
               </div>
             </div>

             <!-- Informations du Projet -->
             <div class="grid grid-cols-1 md:grid-cols-3 gap-4 pt-4 border-t border-white/20">
               <div>
                 <p class="text-sm text-gray-400">Niveau</p>
                 <p class="font-medium text-white">{{ selectedProjet.niveau }}</p>
               </div>
               <div>
                 <p class="text-sm text-gray-400">Durée</p>
                 <p class="font-medium text-white">{{ selectedProjet.duree }}</p>
               </div>
               <div>
                 <p class="text-sm text-gray-400">Statut</p>
                 <p class="font-medium text-white">{{ selectedProjet.statut }}</p>
               </div>
             </div>

             <!-- Date de création -->
             <div class="text-center pt-4 border-t border-white/20">
               <p class="text-sm text-gray-400">
                 Projet créé le {{ formatDate(selectedProjet.created_at) }}
               </p>
             </div>
           </div>
         </div>

         <!-- Footer -->
         <div class="bg-white/10 px-6 py-4 border-t border-white/20 flex justify-end">
           <button 
             @click="closeProjetModal"
             class="btn-primary"
           >
             Fermer
           </button>
         </div>
       </div>
     </div>
   </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { Head } from '@vueuse/head'
import { publicPortfolioService } from '../lib/supabase'
import EvaluationBadge from '../components/EvaluationBadge.vue'
import PublicNavbar from '../components/PublicNavbar.vue'

const route = useRoute()

// State
const loading = ref(true)
const error = ref('')
const passwordRequired = ref(false)
const passwordError = ref('')
const passwordLoading = ref(false)
const portfolioData = ref<any>(null)
// Modal state for apprentissage details
const showApprentissageModal = ref(false)
const selectedApprentissage = ref<any>(null)

// Modal state for projet details
const showProjetModal = ref(false)
const selectedProjet = ref<any>(null)


// Computed
const masteredCount = computed(() => {
  if (!portfolioData.value) return 0
  return portfolioData.value.apprentissages.filter((a: any) => a.evaluation === 'Bien Maîtrisé').length
})

// Helper methods for getting related data
const getApprentissagePreuves = (apprentissage: any) => {
  // Check if apprentissage is null or undefined
  if (!apprentissage) {
    return []
  }
  
  // Check if preuves are directly attached to the apprentissage
  if (apprentissage.preuves && Array.isArray(apprentissage.preuves)) {
    return apprentissage.preuves
  }
  
  // If not, try to find them in the portfolio data
  if (portfolioData.value && portfolioData.value.preuves) {
    return portfolioData.value.preuves.filter((p: any) => p.apprentissage_id === apprentissage.id)
  }
  
  return []
}

const getProjetFiles = (projet: any) => {
  // Check if fichiers are directly attached to the projet
  if (projet.fichiers && Array.isArray(projet.fichiers)) {
    return projet.fichiers
  }
  
  // If not, try to find them in the portfolio data
  if (portfolioData.value && portfolioData.value.fichiers_projets) {
    return portfolioData.value.fichiers_projets.filter((f: any) => f.projet_id === projet.id)
  }
  
  return []
}

// Methods
onMounted(async () => {
  const slug = route.params.slug as string
  if (slug) {
    await loadPortfolio(slug)
  } else {
    error.value = 'URL de portfolio invalide'
    loading.value = false
  }
})

const loadPortfolio = async (slug: string) => {
  loading.value = true
  error.value = ''
  
  try {
    const { data, error: portfolioError } = await publicPortfolioService.getPublicPortfolio(slug)
    
    if (portfolioError) {
      error.value = portfolioError.message
    } else if (data) {
      portfolioData.value = data
      
      // Apply the portfolio owner's theme
      if (data.profile && data.profile.theme) {
        const htmlElement = document.documentElement
        
        // Remove all existing theme classes
        const themeClasses = ['theme-light', 'theme-blue', 'theme-green', 'theme-purple']
        themeClasses.forEach(cls => htmlElement.classList.remove(cls))
        
        // Apply the owner's theme
        if (data.profile.theme !== 'dark') {
          htmlElement.classList.add(`theme-${data.profile.theme}`)
        }
        
        // Handle Tailwind's dark mode class
        if (data.profile.theme === 'light') {
          htmlElement.classList.remove('dark')
        } else {
          htmlElement.classList.add('dark')
        }
      } else {
        // Default to dark theme if no theme specified
        document.documentElement.classList.add('dark')
      }
    }
  } catch (err: any) {
    error.value = 'Erreur lors du chargement du portfolio'
    console.error('Error loading portfolio:', err)
  } finally {
    loading.value = false
  }
}

const getInitials = (name: string) => {
  if (!name) return '??'
  return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)
}

const getCompetenceTitle = (competenceId: string) => {
  if (!portfolioData.value) return 'Compétence'
  const competence = portfolioData.value.competences.find((c: any) => c.id === competenceId)
  return competence?.title || 'Compétence'
}

const openApprentissageModal = (apprentissage: any) => {
  selectedApprentissage.value = apprentissage
  showApprentissageModal.value = true
}

const closeApprentissageModal = () => {
  showApprentissageModal.value = false
  selectedApprentissage.value = null
}

const openProjetModal = (projet: any) => {
  selectedProjet.value = projet
  showProjetModal.value = true
}

const closeProjetModal = () => {
  showProjetModal.value = false
  selectedProjet.value = null
}
const formatDate = (dateString: string) => {
  return new Date(dateString).toLocaleDateString('fr-FR')
}

const getPortfolioBackgroundStyle = () => {
  if (!portfolioData.value?.profile) return {}
  
  const profile = portfolioData.value.profile
  
  switch (profile.background_type) {
    case 'image':
      return profile.background_url ? {
        backgroundImage: `url(${profile.background_url})`,
        backgroundSize: 'cover',
        backgroundPosition: 'center',
        backgroundAttachment: 'fixed',
        minHeight: '100vh'
      } : {}
    
    case 'gradient':
      return profile.background_settings?.gradient ? {
        background: profile.background_settings.gradient,
        minHeight: '100vh'
      } : {}
    
    case 'solid':
      return profile.background_settings?.color ? {
        backgroundColor: profile.background_settings.color,
        minHeight: '100vh'
      } : {}
    
    default:
      return {
        background: 'linear-gradient(135deg, #1f2937 0%, #374151 50%, #111827 100%)',
        minHeight: '100vh'
      }
  }
}
</script>