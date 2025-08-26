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

        <!-- Navigation Links - Simplified for public portfolio -->
        <div class="hidden md:flex items-center space-x-8 ml-auto">
          <router-link 
            to="/" 
            class="nav-link relative group"
          >
            Portfolio
          </router-link>
          
          <!-- Login Button -->
          <router-link
            to="/"
            class="nav-link hover:text-accent-400 transition-colors"
          >
            Connexion
          </router-link>
        </div>

        <!-- Mobile Menu Button -->
        <div class="flex items-center space-x-4">
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
        class="md:hidden py-4 border-t border-white/10"
      >
        <div class="flex flex-col space-y-3">
          <router-link 
            to="/" 
            class="mobile-nav-link relative"
            @click="mobileMenuOpen = false"
          >
            Portfolio
          </router-link>
          
          <!-- Mobile Login Button -->
          <router-link
            to="/"
            class="mobile-nav-link text-left"
            @click="mobileMenuOpen = false"
          >
            Connexion
          </router-link>
        </div>
      </div>
    </div>
  </nav>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { Bars3Icon, XMarkIcon } from '@heroicons/vue/24/outline'

const mobileMenuOpen = ref(false)
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
</style>