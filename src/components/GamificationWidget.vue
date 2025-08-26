<template>
  <div class="glass-card p-6">
    <!-- Header -->
    <div class="flex items-center justify-between mb-6">
      <h3 class="text-xl font-bold text-white flex items-center">
        <span class="mr-2">🏆</span>
        Progression
      </h3>
      <button 
        @click="showAllTrophies = !showAllTrophies"
        class="text-accent-400 hover:text-accent-300 text-sm transition-colors"
      >
        {{ showAllTrophies ? 'Masquer' : 'Voir tout' }}
      </button>
    </div>

    <!-- Level Progress -->
    <div class="mb-6">
      <div class="flex items-center justify-between mb-2">
        <div class="flex items-center space-x-2">
          <div class="w-8 h-8 bg-gradient-to-r from-accent-400 to-accent-500 rounded-full flex items-center justify-center">
            <span class="text-gray-900 font-bold text-sm">{{ currentLevel }}</span>
          </div>
          <span class="text-white font-medium">Niveau {{ currentLevel }}</span>
        </div>
        <span class="text-gray-400 text-sm">{{ userStats.totalPoints }}/{{ nextLevelPoints }} pts</span>
      </div>
      
      <!-- Progress Bar -->
      <div class="w-full bg-gray-700 rounded-full h-3 overflow-hidden">
        <div 
          class="h-full bg-gradient-to-r from-accent-400 to-accent-500 rounded-full transition-all duration-1000 ease-out relative"
          :style="{ width: `${progressToNextLevel}%` }"
        >
          <div class="absolute inset-0 bg-white/20 animate-pulse"></div>
        </div>
      </div>
    </div>

    <!-- Recent Trophies -->
    <div v-if="!showAllTrophies" class="space-y-3">
      <h4 class="text-lg font-semibold text-white mb-4">Trophées Récents</h4>
      
      <div v-if="recentTrophies.length > 0" class="space-y-2">
        <div 
          v-for="trophy in recentTrophies" 
          :key="trophy.id"
          class="flex items-center space-x-3 p-3 bg-white/5 rounded-lg border"
          :class="getRarityColor(trophy.rarity)"
        >
          <div class="text-2xl">{{ trophy.icon }}</div>
          <div class="flex-1 text-left">
            <div class="text-white font-medium text-sm">{{ trophy.title }}</div>
            <div class="text-gray-400 text-xs">+{{ trophy.points }} points</div>
          </div>
          <div class="text-xs text-gray-400">
            {{ formatDate(trophy.unlockedAt!) }}
          </div>
        </div>
      </div>
      
      <div v-else class="text-center py-6">
        <div class="text-4xl mb-2">🏆</div>
        <p class="text-gray-400 text-sm">Aucun trophée débloqué</p>
        <p class="text-gray-500 text-xs">Créez du contenu pour gagner vos premiers trophées !</p>
      </div>
    </div>

    <!-- All Trophies Grid -->
    <div v-else class="space-y-4">
      <h4 class="text-lg font-semibold text-white mb-4">Tous les Trophées</h4>
      
      <!-- Unlocked Trophies -->
      <div v-if="unlockedTrophies.length > 0" class="mb-6">
        <h5 class="text-md font-medium text-green-400 mb-3 flex items-center">
          <span class="mr-2">✅</span>
          Débloqués ({{ unlockedTrophies.length }})
        </h5>
        <div class="grid grid-cols-2 md:grid-cols-3 gap-3">
          <div 
            v-for="trophy in unlockedTrophies" 
            :key="trophy.id"
            class="p-3 bg-white/10 rounded-lg border text-center"
            :class="[getRarityColor(trophy.rarity), getRarityGlow(trophy.rarity)]"
          >
            <div class="text-2xl mb-1">{{ trophy.icon }}</div>
            <div class="text-white font-medium text-xs">{{ trophy.title }}</div>
            <div class="text-gray-400 text-xs">{{ trophy.points }} pts</div>
            <div class="text-green-400 text-xs mt-1">✓ Débloqué</div>
          </div>
        </div>
      </div>

      <!-- Locked Trophies -->
      <div v-if="lockedTrophies.length > 0">
        <h5 class="text-md font-medium text-gray-400 mb-3 flex items-center">
          <span class="mr-2">🔒</span>
          À débloquer ({{ lockedTrophies.length }})
        </h5>
        <div class="grid grid-cols-2 md:grid-cols-3 gap-3">
          <div 
            v-for="trophy in lockedTrophies" 
            :key="trophy.id"
            class="bg-gray-800/50 rounded-lg border border-gray-600 overflow-hidden"
          >
            <div class="p-4">
              <div class="flex items-start space-x-3">
                <div class="text-2xl grayscale">{{ trophy.icon }}</div>
                <div class="flex-1">
                  <div class="flex items-center justify-between mb-2">
                    <h6 class="text-white font-medium text-sm">{{ trophy.title }}</h6>
                    <div class="flex items-center space-x-2">
                      <span class="text-xs px-2 py-1 rounded-full border" :class="getRarityColor(trophy.rarity)">
                        {{ trophy.rarity.toUpperCase() }}
                      </span>
                      <span class="text-gray-400 text-xs">{{ trophy.points }} pts</span>
                    </div>
                  </div>
                  <p class="text-gray-400 text-xs mb-3">{{ trophy.description }}</p>
                  
                  <!-- Progress Section -->
                  <div class="space-y-2">
                    <div class="flex items-center justify-between">
                      <span class="text-gray-300 text-xs font-medium">Progression</span>
                      <span class="text-accent-400 text-xs font-bold">{{ getProgressData(trophy).progress }}%</span>
                    </div>
                    
                    <!-- Progress Bar -->
                    <div class="w-full bg-gray-700 rounded-full h-2">
                      <div 
                        class="h-2 rounded-full transition-all duration-500"
                        :class="getProgressData(trophy).progress >= 100 ? 'bg-green-500' : 'bg-accent-400'"
                        :style="{ width: `${getProgressData(trophy).progress}%` }"
                      ></div>
                    </div>
                    
                    <!-- Progress Description -->
                    <p class="text-gray-400 text-xs">
                      {{ getProgressData(trophy).description }}
                    </p>
                    
                    <!-- Current vs Target for count-based trophies -->
                    <div v-if="trophy.requirement.type === 'count' || trophy.requirement.type === 'percentage'" 
                         class="flex items-center justify-between text-xs">
                      <span class="text-gray-500">Actuel: {{ getProgressData(trophy).current }}</span>
                      <span class="text-gray-500">Objectif: {{ getProgressData(trophy).target }}</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Quick Stats -->
    <div class="mt-6 pt-4 border-t border-white/20">
      <div class="grid grid-cols-3 gap-4 text-center">
        <div>
          <div class="text-lg font-bold text-accent-400">{{ unlockedTrophies.length }}</div>
          <div class="text-gray-400 text-xs">Trophées</div>
        </div>
        <div>
          <div class="text-lg font-bold text-accent-400">{{ userStats.totalPoints }}</div>
          <div class="text-gray-400 text-xs">Points</div>
        </div>
        <div>
          <div class="text-lg font-bold text-accent-400">{{ currentLevel }}</div>
          <div class="text-gray-400 text-xs">Niveau</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import type { Trophy, UserStats } from '../composables/useGamification'

const props = defineProps<{
  userStats: UserStats
  unlockedTrophies: Trophy[]
  lockedTrophies: Trophy[]
  currentLevel: number
  nextLevelPoints: number
  progressToNextLevel: number
}>()

const showAllTrophies = ref(false)

const recentTrophies = computed(() => 
  props.unlockedTrophies
    .filter(t => t.unlockedAt)
    .sort((a, b) => new Date(b.unlockedAt!).getTime() - new Date(a.unlockedAt!).getTime())
    .slice(0, 3)
)

// Simple progress calculation for display
const getProgressData = (trophy: Trophy) => {
  let current = 0
  let target = trophy.requirement.target
  let progress = 0
  let description = 'En cours...'

  switch (trophy.requirement.type) {
    case 'count':
      current = props.userStats[trophy.requirement.field as keyof UserStats] as number || 0
      progress = target > 0 ? Math.min(100, (current / target) * 100) : 0
      const remaining = Math.max(0, target - current)
      description = remaining > 0 
        ? `Il vous reste ${remaining} ${getFieldDisplayName(trophy.requirement.field)} à créer`
        : 'Prêt à être débloqué !'
      break

    case 'percentage':
      if (trophy.requirement.field === 'bienMaitrise') {
        const percentage = props.userStats.apprentissages > 0 
          ? (props.userStats.bienMaitrise / props.userStats.apprentissages) * 100 
          : 0
        current = percentage
        progress = target > 0 ? Math.min(100, (percentage / target) * 100) : 0
        const remaining = Math.max(0, target - percentage)
        description = remaining > 0
          ? `Il vous faut ${remaining.toFixed(1)}% d'apprentissages "Bien Maîtrisé" en plus`
          : 'Prêt à être débloqué !'
      }
      break

    case 'special':
      // For special trophies, show basic info
      description = 'Conditions spéciales requises'
      progress = 0
      break
  }

  return {
    progress: Math.round(progress),
    current,
    target,
    description
  }
}

const getFieldDisplayName = (field?: string) => {
  const fieldNames = {
    competences: 'compétences',
    apprentissages: 'apprentissages',
    projets: 'projets',
    bienMaitrise: 'apprentissages bien maîtrisés'
  }
  return fieldNames[field as keyof typeof fieldNames] || field
}

const getRarityColor = (rarity: Trophy['rarity']) => {
  switch (rarity) {
    case 'bronze': return 'border-amber-400 text-amber-400'
    case 'silver': return 'border-gray-400 text-gray-300'
    case 'gold': return 'border-yellow-400 text-yellow-400'
    case 'diamond': return 'border-cyan-400 text-cyan-400'
    case 'legendary': return 'border-purple-400 text-purple-400'
    default: return 'border-gray-400 text-gray-300'
  }
}

const getRarityGlow = (rarity: Trophy['rarity']) => {
  switch (rarity) {
    case 'bronze': return 'shadow-amber-500/25'
    case 'silver': return 'shadow-gray-500/25'
    case 'gold': return 'shadow-yellow-500/25'
    case 'diamond': return 'shadow-cyan-500/25'
    case 'legendary': return 'shadow-purple-500/50'
    default: return 'shadow-gray-500/25'
  }
}

const formatDate = (dateString: string) => {
  const date = new Date(dateString)
  const now = new Date()
  const diffTime = Math.abs(now.getTime() - date.getTime())
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))
  
  if (diffDays === 1) return 'Aujourd\'hui'
  if (diffDays === 2) return 'Hier'
  if (diffDays <= 7) return `Il y a ${diffDays} jours`
  return date.toLocaleDateString('fr-FR')
}
</script>