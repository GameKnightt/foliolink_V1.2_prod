<template>
  <div class="space-y-4">
    <div class="flex items-center justify-between">
      <h4 class="text-lg font-semibold text-white">Thème du Portfolio</h4>
      <div v-if="isLoading" class="text-accent-400 text-sm">
        <span class="animate-spin mr-1">⏳</span>
        Sauvegarde...
      </div>
    </div>
    
    <p class="text-gray-300 text-sm">
      Personnalisez l'apparence de votre portfolio. Le thème choisi sera également appliqué à votre portfolio public.
    </p>
    
    <!-- Theme Grid -->
    <div class="grid grid-cols-2 md:grid-cols-3 gap-4">
      <button
        v-for="theme in availableThemes"
        :key="theme.name"
        @click="handleThemeChange(theme.name)"
        :disabled="isLoading"
        class="relative p-4 rounded-xl border-2 transition-all duration-300 hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed"
        :class="[
          currentTheme === theme.name 
            ? 'border-accent-400 bg-accent-400/10 shadow-lg shadow-accent-400/25' 
            : 'border-white/20 bg-white/5 hover:border-accent-400/50 hover:bg-white/10'
        ]"
      >
        <!-- Selected indicator -->
        <div 
          v-if="currentTheme === theme.name"
          class="absolute -top-2 -right-2 w-6 h-6 bg-accent-400 rounded-full flex items-center justify-center shadow-lg"
        >
          <span class="text-gray-900 text-xs font-bold">✓</span>
        </div>
        
        <!-- Theme preview -->
        <div class="text-center">
          <div class="text-2xl mb-2">{{ theme.icon }}</div>
          <h5 class="text-white font-semibold mb-1">{{ theme.label }}</h5>
          <p class="text-gray-400 text-xs">{{ theme.description }}</p>
        </div>
        
        <!-- Theme color preview -->
        <div class="flex justify-center space-x-1 mt-3">
          <div 
            class="w-3 h-3 rounded-full"
            :class="getThemePreviewColors(theme.name).primary"
          ></div>
          <div 
            class="w-3 h-3 rounded-full"
            :class="getThemePreviewColors(theme.name).accent"
          ></div>
          <div 
            class="w-3 h-3 rounded-full"
            :class="getThemePreviewColors(theme.name).background"
          ></div>
        </div>
      </button>
    </div>
    
    <!-- Current theme info -->
    <div class="bg-white/5 border border-white/10 rounded-lg p-4">
      <div class="flex items-center space-x-3">
        <div class="text-2xl">{{ getThemeInfo(currentTheme)?.icon }}</div>
        <div>
          <p class="text-white font-medium">
            Thème actuel : {{ getThemeInfo(currentTheme)?.label }}
          </p>
          <p class="text-gray-400 text-sm">
            {{ getThemeInfo(currentTheme)?.description }}
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useTheme } from '../composables/useTheme'
import { authService } from '../lib/supabase'
import { ref, onMounted } from 'vue'

const { 
  currentTheme, 
  availableThemes, 
  isLoading, 
  changeTheme, 
  getThemeInfo 
} = useTheme()

const isUserAuthenticated = ref(false)

onMounted(async () => {
  const user = await authService.getCurrentUser()
  isUserAuthenticated.value = !!user
})

const handleThemeChange = async (themeName: string) => {
  // Vérifier que l'utilisateur est connecté
  if (!isUserAuthenticated.value) {
    console.log('Changement de thème refusé : utilisateur non connecté')
    return
  }
  
  if (themeName !== currentTheme.value) {
    await changeTheme(themeName)
  }
}

const getThemePreviewColors = (themeName: string) => {
  const colorMap = {
    dark: {
      primary: 'bg-blue-500',
      accent: 'bg-yellow-400',
      background: 'bg-gray-800'
    },
    light: {
      primary: 'bg-sky-500',
      accent: 'bg-amber-500',
      background: 'bg-gray-100'
    },
    blue: {
      primary: 'bg-blue-600',
      accent: 'bg-sky-400',
      background: 'bg-slate-800'
    },
    green: {
      primary: 'bg-green-500',
      accent: 'bg-yellow-400',
      background: 'bg-gray-900'
    },
    purple: {
      primary: 'bg-purple-500',
      accent: 'bg-pink-400',
      background: 'bg-indigo-900'
    },
    orange: {
      primary: 'bg-orange-500',
      accent: 'bg-yellow-400',
      background: 'bg-stone-900'
    }
  }
  
  return colorMap[themeName] || colorMap.dark
}
</script>