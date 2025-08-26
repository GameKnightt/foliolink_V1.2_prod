<template>
  <div class="space-y-8">
    <!-- Header -->
    <div v-if="!isCollapsed" class="text-center">
      <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-4">
        Partage Public de Portfolio
      </h2>
      <p class="text-gray-600 dark:text-gray-300">
        Créez un lien personnalisé pour partager votre portfolio avec des employeurs, maîtres de stage ou le jury
      </p>
    </div>

    <!-- Current Status -->
    <div 
      class="transition-all duration-300 ease-in-out"
      :class="{ 'opacity-0 max-h-0 overflow-hidden': isCollapsed && !currentSettings, 'opacity-100': !isCollapsed || currentSettings }"
    >
    <div v-if="currentSettings" class="glass-card p-6">
      <div class="flex items-center justify-between mb-4">
        <h3 class="text-lg font-semibold text-white">Statut Actuel</h3>
        <div class="flex items-center space-x-2">
          <div 
            class="w-3 h-3 rounded-full"
            :class="currentSettings.is_public ? 'bg-green-400' : 'bg-gray-400'"
          ></div>
          <span class="text-white text-sm">
            {{ currentSettings.is_public ? 'Public' : 'Privé' }}
          </span>
        </div>
      </div>
      
      <div v-if="currentSettings.public_slug" class="space-y-3">
        <div class="flex items-center justify-between bg-white/5 p-3 rounded-lg">
          <div class="flex-1">
            <p class="text-gray-300 text-sm mb-1">Votre lien de portfolio :</p>
            <p class="text-white font-mono text-sm break-all">
              {{ getPortfolioUrl(currentSettings.public_slug) }}
            </p>
          </div>
          <button 
            @click="copyPortfolioLink"
            class="btn-secondary text-sm px-4 py-2 ml-3"
          >
            <span class="mr-1">📋</span>
            Copier
          </button>
        </div>
        
        <div class="flex items-center space-x-4">
          <a 
            :href="getPortfolioUrl(currentSettings.public_slug)"
            target="_blank"
            rel="noopener noreferrer"
            class="text-accent-400 hover:text-accent-300 text-sm transition-colors"
          >
            👁️ Prévisualiser le portfolio public
          </a>
          
          <button 
            @click="sharePortfolio"
            class="text-accent-400 hover:text-accent-300 text-sm transition-colors"
          >
            📤 Partager
          </button>
        </div>
      </div>
    </div>
    </div>

    <!-- URL Customization -->
    <div 
      v-if="!isCollapsed"
      class="glass-card p-6 transition-all duration-300 ease-in-out"
    >
      <h3 class="text-lg font-semibold text-white mb-4">Personnaliser l'URL</h3>
      
      <div class="space-y-4">
        <div>
          <label class="block text-sm font-medium text-gray-300 mb-2">
            Nom d'utilisateur personnalisé
          </label>
          <div class="flex items-center space-x-2">
            <span class="text-gray-400 text-sm">{{ baseUrl }}/</span>
            <div class="flex-1 relative">
              <input
                v-model="slugForm.slug"
                type="text"
                :disabled="slugLoading"
                class="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-400 focus:ring-2 focus:ring-accent-400 focus:border-accent-400 transition-colors backdrop-blur-xl"
                placeholder="mon-nom-utilisateur"
                @input="checkSlugAvailability"
              />
              
              <!-- Availability Indicator -->
              <div class="absolute right-3 top-1/2 transform -translate-y-1/2">
                <div v-if="slugChecking" class="w-5 h-5 animate-spin">
                  <span class="text-gray-400">⏳</span>
                </div>
                <div v-else-if="slugForm.slug && slugAvailability.checked">
                  <span v-if="slugAvailability.available" class="text-green-400">✓</span>
                  <span v-else class="text-red-400">✗</span>
                </div>
              </div>
            </div>
          </div>
          
          <!-- Availability Message -->
          <div class="mt-2">
            <p v-if="slugForm.slug && slugAvailability.checked" class="text-sm">
              <span v-if="slugAvailability.available" class="text-green-400">
                ✓ Ce nom d'utilisateur est disponible
              </span>
              <span v-else class="text-red-400">
                ✗ Ce nom d'utilisateur n'est pas disponible
              </span>
            </p>
            <p class="text-gray-400 text-xs mt-1">
              3-30 caractères, lettres, chiffres, tirets et underscores uniquement
            </p>
          </div>
        </div>

        <button 
          @click="updateSlug"
          :disabled="!canUpdateSlug"
          class="btn-primary disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <span v-if="slugLoading" class="mr-2">⏳</span>
          <span v-else class="mr-2">💾</span>
          {{ slugLoading ? 'Sauvegarde...' : 'Enregistrer l\'URL' }}
        </button>
      </div>
    </div>

    <!-- Visibility Controls -->
    <div 
      v-if="!isCollapsed"
      class="glass-card p-6 transition-all duration-300 ease-in-out"
    >
      <h3 class="text-lg font-semibold text-white mb-4">Contrôles de Confidentialité</h3>
      
      <div class="space-y-6">
        <!-- Public/Private Toggle -->
        <div class="flex items-center justify-between">
          <div>
            <h4 class="text-white font-medium">Portfolio Public</h4>
            <p class="text-gray-400 text-sm">Permettre aux visiteurs de voir votre portfolio sans connexion</p>
          </div>
          <label class="relative inline-flex items-center cursor-pointer">
            <input 
              v-model="visibilityForm.isPublic" 
              type="checkbox" 
              class="sr-only peer"
            />
            <div class="w-11 h-6 bg-gray-600 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-accent-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-accent-400"></div>
          </label>
        </div>

        <!-- Password Protection (only if public) -->

        <button 
          @click="updateVisibility"
          :disabled="!canUpdateVisibility"
          class="btn-primary disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <span v-if="visibilityLoading" class="mr-2">⏳</span>
          <span v-else class="mr-2">🔒</span>
          {{ visibilityLoading ? 'Sauvegarde...' : 'Enregistrer les Paramètres' }}
        </button>
      </div>
    </div>

    <!-- Error/Success Messages -->
    <div 
      v-if="!isCollapsed && error" 
      class="p-4 bg-red-500/20 border border-red-500/30 rounded-lg transition-all duration-300 ease-in-out"
    >
      <p class="text-red-200 text-sm">{{ error }}</p>
    </div>

    <div 
      v-if="!isCollapsed && success" 
      class="p-4 bg-green-500/20 border border-green-500/30 rounded-lg transition-all duration-300 ease-in-out"
    >
      <p class="text-green-200 text-sm">{{ success }}</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { publicPortfolioService, authService } from '../lib/supabase'

const props = defineProps<{
  isPremium?: boolean
  isCollapsed?: boolean
}>()

// Security: Rate limiting pour les mises à jour de slug
const slugUpdateAttempts = ref(0)
const maxSlugUpdates = 10 // Maximum 10 mises à jour par session
const slugUpdateCooldown = ref(false)
// Reactive state
const currentSettings = ref<any>(null)
const slugForm = ref({ slug: '' })
const visibilityForm = ref({
  isPublic: false,
})

// Loading states
const slugLoading = ref(false)
const visibilityLoading = ref(false)
const slugChecking = ref(false)

// Availability checking
const slugAvailability = ref({
  checked: false,
  available: false
})

// Messages
const error = ref('')
const success = ref('')

// Debounce timer
let slugCheckTimeout: NodeJS.Timeout | null = null

// Computed
const baseUrl = computed(() => window.location.origin)

const canUpdateSlug = computed(() => {
  return slugForm.value.slug && 
         slugAvailability.value.checked && 
         slugAvailability.value.available && 
         !slugLoading.value
})

const canUpdateVisibility = computed(() => {
  return !visibilityLoading.value
})

// Methods
onMounted(async () => {
  await loadCurrentSettings()
})

const loadCurrentSettings = async () => {
  try {
    const user = await authService.getCurrentUser()
    if (!user) return

    // Load current profile settings (using existing profileService)
    const { profileService } = await import('../lib/supabase')
    const { data: profile } = await profileService.getProfile(user.id)
    
    if (profile) {
      currentSettings.value = profile
      slugForm.value.slug = profile.public_slug || ''
      visibilityForm.value.isPublic = profile.is_public || false
    }
  } catch (err) {
    console.error('Error loading settings:', err)
  }
}

const checkSlugAvailability = () => {
  // Clear previous timeout
  if (slugCheckTimeout) {
    clearTimeout(slugCheckTimeout)
  }

  // Reset availability state
  slugAvailability.value.checked = false
  
  if (!slugForm.value.slug) {
    return
  }

  // Validation côté client immédiate
  const slugRegex = /^[a-zA-Z0-9_-]{3,30}$/
  if (!slugRegex.test(slugForm.value.slug)) {
    slugAvailability.value = {
      checked: true,
      available: false
    }
    return
  }
  // Debounce the check
  slugCheckTimeout = setTimeout(async () => {
    slugChecking.value = true
    
    try {
      const { available } = await publicPortfolioService.checkSlugAvailability(slugForm.value.slug)
      slugAvailability.value = {
        checked: true,
        available
      }
    } catch (err) {
      console.error('Error checking slug availability:', err)
      slugAvailability.value = {
        checked: true,
        available: false
      }
    } finally {
      slugChecking.value = false
    }
  }, 800) // 800ms debounce pour réduire les appels API
}

const updateSlug = async () => {
  if (!canUpdateSlug.value) return

  // Vérification du rate limiting
  if (slugUpdateAttempts.value >= maxSlugUpdates) {
    error.value = 'Trop de tentatives de mise à jour. Veuillez patienter.'
    return
  }

  // Enhanced slug validation
  const slug = slugForm.value.slug.trim().toLowerCase()
  const slugRegex = /^[a-z0-9_-]{3,30}$/
  if (!slugRegex.test(slug)) {
    error.value = 'Le nom d\'utilisateur doit contenir entre 3 et 30 caractères (lettres minuscules, chiffres, tirets et underscores uniquement)'
    return
  }

  // Check for forbidden patterns
  const forbiddenPatterns = ['admin', 'root', 'api', 'www', 'mail', 'ftp', 'test', 'demo', 'support', 'help']
  if (forbiddenPatterns.some(pattern => slug.includes(pattern))) {
    error.value = 'Ce nom d\'utilisateur contient des termes réservés'
    return
  }

  slugLoading.value = true
  error.value = ''
  success.value = ''

  try {
    const user = await authService.getCurrentUser()
    if (!user) throw new Error('User not authenticated')

    slugUpdateAttempts.value++
    
    const { data, error: updateError } = await publicPortfolioService.updatePublicSlug(
      user.id, 
      slug
    )

    if (updateError) {
      error.value = updateError.message
    } else {
      success.value = 'URL personnalisée enregistrée avec succès !'
      currentSettings.value = { ...currentSettings.value, public_slug: slug }
      slugForm.value.slug = slug
      
      // Reset attempts on success
      slugUpdateAttempts.value = 0
    }
  } catch (err: any) {
    error.value = 'Erreur lors de la sauvegarde de l\'URL'
  } finally {
    slugLoading.value = false
  }
}

const updateVisibility = async () => {
  if (!canUpdateVisibility.value) return

  visibilityLoading.value = true
  error.value = ''
  success.value = ''

  try {
    const user = await authService.getCurrentUser()
    if (!user) throw new Error('User not authenticated')

    // First update visibility
    const { error: visibilityError } = await publicPortfolioService.updatePortfolioVisibility(
      user.id, 
      visibilityForm.value.isPublic
    )

    if (visibilityError) {
      error.value = visibilityError.message
      return
    }


    success.value = 'Paramètres de confidentialité mis à jour !'
    currentSettings.value = { 
      ...currentSettings.value, 
      is_public: visibilityForm.value.isPublic 
    }


  } catch (err: any) {
    error.value = err.message || 'Erreur lors de la sauvegarde des paramètres'
  } finally {
    visibilityLoading.value = false
  }
}

const getPortfolioUrl = (slug: string) => {
  return `${baseUrl.value}/${slug}`
}

const copyPortfolioLink = async () => {
  if (!currentSettings.value?.public_slug) return

  try {
    const url = getPortfolioUrl(currentSettings.value.public_slug)
    await navigator.clipboard.writeText(url)
    success.value = 'Lien copié dans le presse-papiers !'
    
    // Clear success message after 3 seconds
    setTimeout(() => {
      success.value = ''
    }, 3000)
  } catch (err) {
    error.value = 'Impossible de copier le lien'
  }
}

const sharePortfolio = async () => {
  if (!currentSettings.value?.public_slug) return

  const url = getPortfolioUrl(currentSettings.value.public_slug)
  const title = `Portfolio de ${currentSettings.value.full_name || 'Mon Portfolio'}`
  const text = 'Découvrez mon portfolio étudiant BUT avec mes compétences et projets'

  if (navigator.share) {
    try {
      await navigator.share({
        title,
        text,
        url
      })
    } catch (err) {
      // User cancelled sharing or error occurred
      console.log('Sharing cancelled or failed')
    }
  } else {
    // Fallback: copy to clipboard
    await copyPortfolioLink()
  }
}
</script>