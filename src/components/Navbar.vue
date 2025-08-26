<template>
  <nav class="glass-navbar fixed top-0 left-0 right-0 z-50 transition-all duration-300">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex justify-between items-center h-16">
        <!-- Logo -->
        <router-link to="/" class="flex items-center space-x-3 group">
          <div class="glass-card p-2 group-hover:scale-110 transition-transform duration-300">
            <div class="w-8 h-8 bg-gradient-to-r from-accent-400 to-accent-500 rounded-lg flex items-center justify-center">
              <img 
                src="https://ruzavevslvfzrdqsculj.supabase.co/storage/v1/object/public/branding/logo_navbar.png" 
                alt="FolioLink Logo" 
                class="w-6 h-6 object-contain"
              />
            </div>
          </div>
          <div class="hidden sm:block">
            <h1 class="text-lg font-bold nav-text">FolioLink</h1>
            <p class="text-xs nav-text-secondary">Portfolio Builder BUT</p>
          </div>
        </router-link>

        <!-- Navigation Links -->
        <div class="hidden md:flex items-center space-x-8">
          <router-link 
            to="/" 
            class="nav-link relative group"
          >
            Accueil
          </router-link>
          <router-link 
            to="/portfolio" 
            class="nav-link relative group"
          >
            Compétences
          </router-link>
          <router-link 
            to="/projets" 
            class="nav-link relative group"
          >
            Projets
          </router-link>
          
          <!-- User Menu for Authenticated Users -->
          <div v-if="isAuthenticated" class="flex items-center space-x-6">
            <!-- Premium Tab - Only for non-premium users -->
            <router-link
              v-if="!isPremium"
              to="/pricing" 
              class="relative group"
            >
              <span class="bg-red-500 hover:bg-red-600 text-white font-bold px-4 py-2 rounded-lg transition-all duration-300 flex items-center space-x-1">
                <span>Premium</span>
                <span class="text-xs">-50%</span>
              </span>
            </router-link>
            
            <router-link 
              to="/dashboard"
              class="nav-link relative group"
              :class="{ 'dashboard-glow': showDashboardGlow }"
            >
              Dashboard
            </router-link>
            
            <div class="relative group">
              <button class="nav-link flex items-center space-x-2 hover:text-accent-400 transition-colors">
                <span>Mon Compte</span>
                <svg class="w-4 h-4 transition-transform group-hover:rotate-180" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                </svg>
              </button>
              
              <!-- Dropdown Menu -->
              <div class="absolute right-0 mt-2 w-48 glass-card rounded-lg shadow-lg opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all duration-200 z-50">
                <div class="py-2">
                  <!-- Premium Status -->
                  <div v-if="isPremium" class="px-4 py-2 border-b border-white/10">
                    <div class="flex items-center space-x-2">
                      <span class="text-yellow-400">👑</span>
                      <span class="text-white text-sm font-medium">Premium Actif</span>
                    </div>
                  </div>
                  <div v-else class="px-4 py-2 border-b border-white/10">
                    <div class="flex items-center justify-between">
                      <span class="text-gray-300 text-sm">Plan Gratuit</span>
                    </div>
                  </div>
                  
                  <!-- Menu Items -->
                  <button 
                    @click="handleLogout"
                    class="w-full text-left px-4 py-2 text-gray-300 hover:text-white hover:bg-white/10 transition-colors"
                  >
                    Se déconnecter
                  </button>
                </div>
              </div>
            </div>
          </div>
          
          <!-- Login Button for Non-Authenticated Users -->
          <div v-else class="flex items-center space-x-8">
            <!-- Premium Tab for non-authenticated users -->
            <router-link
              to="/pricing" 
              class="relative group"
            >
              <span class="bg-red-500 hover:bg-red-600 text-white font-bold px-4 py-2 rounded-lg transition-all duration-300 flex items-center space-x-1">
                <span>Premium</span>
                <span class="text-xs">-50%</span>
              </span>
            </router-link>
            
            <button
              @click="openAuthModal"
              class="nav-link hover:text-accent-400 transition-colors"
            >
              Connexion
            </button>
          </div>
        </div>

        <!-- Theme Toggle & Mobile Menu -->
        <div class="flex items-center space-x-4">
          <!-- Mobile Menu Button -->
          <button
            @click="mobileMenuOpen = !mobileMenuOpen"
            class="md:hidden glass-card p-2 hover:bg-white/20 transition-all duration-300 nav-text"
          >
            <Bars3Icon v-if="!mobileMenuOpen" class="w-5 h-5" />
            <XMarkIcon v-else class="w-5 h-5" />
          </button>
        </div>
      </div>

      <!-- Mobile Menu -->
      <div 
        v-show="mobileMenuOpen"
        class="md:hidden py-4 border-t border-white/10 bg-gray-900/95 backdrop-blur-md rounded-b-xl mx-4 mt-2 shadow-2xl"
      >
        <div class="flex flex-col space-y-3">
          <router-link 
            to="/" 
            class="mobile-nav-link relative mx-2"
            @click="mobileMenuOpen = false"
          >
            Accueil
            <div v-if="$route.path === '/'" class="absolute left-0 top-0 w-1 h-full bg-accent-400 rounded-r"></div>
          </router-link>
          <router-link 
            to="/portfolio"
            class="mobile-nav-link relative mx-2"
            @click="mobileMenuOpen = false"
          >
            Compétences
            <div v-if="$route.path === '/portfolio'" class="absolute left-0 top-0 w-1 h-full bg-accent-400 rounded-r"></div>
          </router-link>
          <router-link 
            to="/projets"
            class="mobile-nav-link relative mx-2"
            @click="mobileMenuOpen = false"
          >
            Projets
            <div v-if="$route.path === '/projets'" class="absolute left-0 top-0 w-1 h-full bg-accent-400 rounded-r"></div>
          </router-link>
          
          <!-- Mobile User Menu -->
          <div v-if="isAuthenticated" class="border-t border-white/10 pt-3 mt-3 mx-2">
            <!-- Premium Tab Mobile - Only for non-premium users -->
            <router-link
              v-if="!isPremium"
              to="/pricing"
              class="mobile-nav-link relative block mb-3"
              @click="mobileMenuOpen = false"
            >
              <span class="bg-red-500 text-white font-bold px-4 py-2 rounded-lg text-sm flex items-center justify-center space-x-2 w-full">
                <span>Premium</span>
                <span class="text-xs">-50%</span>
              </span>
              <div v-if="$route.path === '/pricing'" class="absolute left-0 top-0 w-1 h-full bg-accent-400 rounded-r"></div>
            </router-link>
            
            <router-link 
              to="/dashboard"
              class="mobile-nav-link relative text-white block"
              :class="{ 'dashboard-glow': showDashboardGlow }"
              @click="mobileMenuOpen = false"
            >
              Dashboard
              <div v-if="$route.path === '/dashboard'" class="absolute left-0 top-0 w-1 h-full bg-accent-400 rounded-r"></div>
            </router-link>
            
            <!-- Premium Status -->
            <div v-if="isPremium" class="mobile-nav-link flex items-center justify-center space-x-2 bg-yellow-500/20 border border-yellow-400/30 rounded-lg py-2 mt-2">
              <span class="text-yellow-400">👑</span>
              <span>Premium Actif</span>
            </div>
            <div v-else class="mobile-nav-link flex items-center justify-center bg-gray-600/20 border border-gray-500/30 rounded-lg py-2 mt-2">
              <span>Plan Gratuit</span>
            </div>
            
            <button
              @click="handleLogout(); mobileMenuOpen = false" 
              class="mobile-nav-link text-center w-full bg-red-600/20 border border-red-500/30 rounded-lg py-2 mt-2 hover:bg-red-600/30 transition-colors"
            >
              Se déconnecter
            </button>
          </div>
          
          <!-- Mobile Login Button -->
          <div v-else class="space-y-3 mx-2">
            <!-- Premium Tab Mobile for non-authenticated users -->
            <router-link
              to="/pricing"
              class="mobile-nav-link relative block"
              @click="mobileMenuOpen = false"
            >
              <span class="bg-red-500 text-white font-bold px-4 py-2 rounded-lg text-sm flex items-center justify-center space-x-2 w-full">
                <span>Premium</span>
                <span class="text-xs">-50%</span>
              </span>
              <div v-if="$route.path === '/pricing'" class="absolute left-0 top-0 w-1 h-full bg-accent-400 rounded-r"></div>
            </router-link>
            
            <button
              @click="openAuthModal(); mobileMenuOpen = false" 
              class="mobile-nav-link text-center w-full bg-accent-600/20 border border-accent-500/30 rounded-lg py-2 hover:bg-accent-600/30 transition-colors"
            >
              Connexion
            </button>
          </div>
        </div>
      </div>
    </div>
  </nav>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import { Bars3Icon, XMarkIcon } from '@heroicons/vue/24/outline'
import { useAuth } from '../composables/useAuth'

const props = defineProps<{
  isAuthenticated: boolean
  isPremium?: boolean
}>()

const emit = defineEmits(['logout'])

const { openAuthModal } = useAuth()

const route = useRoute()
const mobileMenuOpen = ref(false)
const showDashboardGlow = ref(false)

const handleLogout = () => {
  // Emit logout for cleanup first
  emit('logout')
  
  // Force immediate redirect as backup
  setTimeout(() => {
    window.location.href = '/'
  }, 100)
}

// Watch for authentication changes to trigger glow effect
watch(() => props.isAuthenticated, (newVal, oldVal) => {
  if (newVal && !oldVal) {
    // User just logged in, show glow effect
    showDashboardGlow.value = true
    setTimeout(() => {
      showDashboardGlow.value = false
    }, 3000) // Remove glow after 3 seconds
  }
})

const getCurrentThemeIcon = () => {
  const themeInfo = getThemeInfo(currentTheme.value)
  return themeInfo?.icon || '🌙'
}
</script>

<style scoped>
.nav-text {
  @apply text-white dark:text-white;
}

.nav-text-secondary {
  @apply text-gray-300 dark:text-gray-300;
}

.nav-link {
  @apply text-gray-300 dark:text-gray-300 hover:text-accent-400 font-medium transition-all duration-300 relative;
}

/* Active link indicator */
.nav-link.router-link-active {
  @apply text-accent-400;
  position: relative;
}

.nav-link.router-link-active::after {
  content: '';
  position: absolute;
  bottom: -4px;
  left: 0;
  right: 0;
  height: 2px;
  background: #facc15;
  border-radius: 1px;
}

/* Hover effect - only show if not active */
.nav-link:not(.router-link-active):hover::after {
  content: '';
  position: absolute;
  bottom: -4px;
  left: 0;
  right: 0;
  height: 2px;
  background: #facc15;
  border-radius: 1px;
  transform: scaleX(0);
  animation: slideIn 0.3s ease forwards;
}

@keyframes slideIn {
  to {
    transform: scaleX(1);
  }
}

.mobile-nav-link {
  @apply text-gray-300 dark:text-gray-300 hover:text-accent-400 font-medium transition-all duration-300 px-4 py-2 rounded-lg hover:bg-white/10;
}

/* Dashboard glow animation */
.dashboard-glow {
  animation: dashboardGlow 3s ease-in-out;
  text-shadow: 0 0 10px #facc15, 0 0 20px #facc15, 0 0 30px #facc15;
}

@keyframes dashboardGlow {
  0% {
    text-shadow: 0 0 5px #facc15, 0 0 10px #facc15, 0 0 15px #facc15;
    transform: scale(1);
  }
  50% {
    text-shadow: 0 0 15px #facc15, 0 0 25px #facc15, 0 0 35px #facc15;
    transform: scale(1.05);
  }
  100% {
    text-shadow: 0 0 5px #facc15, 0 0 10px #facc15, 0 0 15px #facc15;
    transform: scale(1);
  }
}
</style>