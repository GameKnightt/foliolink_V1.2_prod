<template>
  <div class="fixed inset-0 z-[100] overflow-hidden">
    <!-- Animated background with confetti -->
    <div class="absolute inset-0 bg-black/90 backdrop-blur-sm">
      <!-- Confetti particles -->
      <div 
        v-for="i in 50" 
        :key="i"
        class="absolute w-3 h-3 animate-confetti"
        :style="getConfettiStyle(i)"
      ></div>
    </div>

    <!-- Main modal -->
    <div class="flex items-center justify-center min-h-screen p-4">
      <div class="glass-card max-w-3xl w-full text-center animate-trophy-enter relative overflow-hidden max-h-[85vh] flex flex-col">
        <!-- Animated gradient background -->
        <div class="absolute inset-0 bg-gradient-to-r from-purple-600 via-blue-600 via-green-500 to-yellow-500 bg-[length:400%_100%] animate-rainbow opacity-20"></div>
        
        <!-- Content -->
        <div class="relative z-10 p-4 flex-1 overflow-y-auto">
          <!-- Celebration header -->
          <div class="text-4xl mb-3 animate-bounce-trophy">🎉</div>
          
          <h1 class="text-2xl md:text-3xl font-bold text-white mb-3">
            <span class="gradient-text-animated">Nouveau{{ newTrophies.length > 1 ? 'x' : '' }} Trophée{{ newTrophies.length > 1 ? 's' : '' }} !</span>
          </h1>
          
          <p class="text-gray-200 mb-6">
            Félicitations ! Vous avez débloqué {{ newTrophies.length }} nouveau{{ newTrophies.length > 1 ? 'x' : '' }} trophée{{ newTrophies.length > 1 ? 's' : '' }} !
          </p>

          <!-- Trophies Grid -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-3 mb-6 max-h-64 overflow-y-auto">
            <div 
              v-for="(trophy, index) in newTrophies" 
              :key="trophy.id"
              class="glass-card p-3 border-2 animate-trophy-reveal"
              :class="[getRarityColor(trophy.rarity), getRarityGlow(trophy.rarity)]"
              :style="{ animationDelay: `${index * 0.2}s` }"
            >
              <!-- Trophy Icon with rarity glow -->
              <div class="relative mb-3">
                <div 
                  class="text-3xl animate-trophy-spin"
                  :style="{ animationDelay: `${index * 0.3}s` }"
                >
                  {{ trophy.icon }}
                </div>
                <div 
                  v-if="trophy.rarity === 'legendary'"
                  class="absolute inset-0 animate-ping"
                >
                  <div class="text-3xl opacity-75">{{ trophy.icon }}</div>
                </div>
              </div>
              
              <!-- Trophy Info -->
              <h3 class="text-base font-bold text-white mb-1">{{ trophy.title }}</h3>
              <p class="text-gray-300 text-xs mb-2">{{ trophy.description }}</p>
              
              <!-- Rarity Badge -->
              <div class="inline-flex items-center px-2 py-1 rounded-full text-xs font-bold border mb-1"
                   :class="getRarityColor(trophy.rarity)">
                <span class="mr-1">{{ getRarityIcon(trophy.rarity) }}</span>
                {{ trophy.rarity.toUpperCase() }}
              </div>
              
              <!-- Points -->
              <div class="text-accent-400 font-bold text-xs">
                +{{ trophy.points }} points
              </div>
            </div>
          </div>

          <!-- Total Points Earned -->
          <div class="bg-white/10 rounded-xl p-3 mb-6">
            <div class="text-xl font-bold text-accent-400 mb-1">
              +{{ totalPointsEarned }} points gagnés !
            </div>
            <div class="text-gray-300 text-sm">
              Vous êtes maintenant niveau {{ currentLevel }} avec {{ totalPoints }} points
            </div>
          </div>
        </div>

        <!-- Fixed Close Button -->
        <div class="relative z-10 p-4 border-t border-white/20 bg-black/20 backdrop-blur-sm">
          <button 
            @click="$emit('close')"
            class="btn-primary px-6 py-3 animate-button-appear hover:scale-105 transform transition-all duration-300 w-full"
          >
            <span class="mr-2">✨</span>
            Continuer l'aventure
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { Trophy } from '../composables/useGamification'

const props = defineProps<{
  newTrophies: Trophy[]
  currentLevel: number
  totalPoints: number
}>()

const emit = defineEmits(['close'])

const totalPointsEarned = computed(() => 
  props.newTrophies.reduce((sum, trophy) => sum + trophy.points, 0)
)

const getRarityColor = (rarity: Trophy['rarity']) => {
  switch (rarity) {
    case 'bronze': return 'border-amber-400 bg-amber-400/10 text-amber-400'
    case 'silver': return 'border-gray-400 bg-gray-400/10 text-gray-300'
    case 'gold': return 'border-yellow-400 bg-yellow-400/10 text-yellow-400'
    case 'diamond': return 'border-cyan-400 bg-cyan-400/10 text-cyan-400'
    case 'legendary': return 'border-purple-400 bg-purple-400/10 text-purple-400'
    default: return 'border-gray-400 bg-gray-400/10 text-gray-300'
  }
}

const getRarityGlow = (rarity: Trophy['rarity']) => {
  switch (rarity) {
    case 'bronze': return 'shadow-lg shadow-amber-500/25'
    case 'silver': return 'shadow-lg shadow-gray-500/25'
    case 'gold': return 'shadow-lg shadow-yellow-500/25'
    case 'diamond': return 'shadow-lg shadow-cyan-500/25'
    case 'legendary': return 'shadow-2xl shadow-purple-500/50 animate-pulse'
    default: return 'shadow-lg shadow-gray-500/25'
  }
}

const getRarityIcon = (rarity: Trophy['rarity']) => {
  switch (rarity) {
    case 'bronze': return '🥉'
    case 'silver': return '🥈'
    case 'gold': return '🥇'
    case 'diamond': return '💎'
    case 'legendary': return '👑'
    default: return '🏅'
  }
}

const getConfettiStyle = (index: number) => {
  const colors = ['#facc15', '#3b82f6', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6']
  const color = colors[index % colors.length]
  const delay = Math.random() * 2
  const left = Math.random() * 100
  
  return {
    backgroundColor: color,
    left: left + '%',
    top: '-10px',
    animationDelay: delay + 's',
    borderRadius: Math.random() > 0.5 ? '50%' : '0'
  }
}
</script>

<style scoped>
@keyframes trophy-enter {
  0% {
    opacity: 0;
    transform: scale(0.5) rotate(-10deg);
  }
  50% {
    transform: scale(1.1) rotate(5deg);
  }
  100% {
    opacity: 1;
    transform: scale(1) rotate(0deg);
  }
}

@keyframes trophy-spin {
  0% { transform: rotate(0deg) scale(1); }
  25% { transform: rotate(10deg) scale(1.1); }
  50% { transform: rotate(-5deg) scale(1.05); }
  75% { transform: rotate(5deg) scale(1.1); }
  100% { transform: rotate(0deg) scale(1); }
}

@keyframes trophy-reveal {
  0% {
    opacity: 0;
    transform: translateY(30px) scale(0.8);
  }
  100% {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

@keyframes bounce-trophy {
  0%, 20%, 50%, 80%, 100% {
    transform: translateY(0) rotate(0deg);
  }
  40% {
    transform: translateY(-20px) rotate(10deg);
  }
  60% {
    transform: translateY(-10px) rotate(-5deg);
  }
}

@keyframes rainbow {
  0% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
}

@keyframes confetti {
  0% {
    transform: translateY(-10px) rotate(0deg);
    opacity: 1;
  }
  100% {
    transform: translateY(100vh) rotate(720deg);
    opacity: 0;
  }
}

@keyframes button-appear {
  0% {
    opacity: 0;
    transform: translateY(20px) scale(0.9);
  }
  100% {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

.animate-trophy-enter {
  animation: trophy-enter 1s ease-out;
}

.animate-trophy-spin {
  animation: trophy-spin 2s ease-in-out;
}

.animate-trophy-reveal {
  animation: trophy-reveal 0.8s ease-out both;
}

.animate-bounce-trophy {
  animation: bounce-trophy 2s ease-in-out infinite;
}

.animate-rainbow {
  animation: rainbow 3s ease infinite;
}

.animate-confetti {
  animation: confetti 3s linear infinite;
}

.animate-button-appear {
  animation: button-appear 0.8s ease-out 1.5s both;
}

.gradient-text-animated {
  background: linear-gradient(45deg, #facc15, #3b82f6, #10b981, #f59e0b);
  background-size: 400% 400%;
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  animation: rainbow 2s ease infinite;
}
</style>