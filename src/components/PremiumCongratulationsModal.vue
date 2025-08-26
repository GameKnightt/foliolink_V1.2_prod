<template>
  <div class="fixed inset-0 z-[110] overflow-hidden">
    <!-- Animated background with particles -->
    <div class="absolute inset-0 bg-black/90 backdrop-blur-sm">
      <!-- Floating particles -->
      <div 
        v-for="i in 20" 
        :key="i"
        class="absolute w-2 h-2 bg-gradient-to-r from-yellow-400 to-orange-400 rounded-full animate-float"
        :style="getParticleStyle(i)"
      ></div>
    </div>

    <!-- Main modal -->
    <div class="flex items-center justify-center min-h-screen p-4">
      <div class="glass-card max-w-2xl w-full text-center animate-celebration-enter relative overflow-hidden">
        <!-- Animated gradient background -->
        <div class="absolute inset-0 bg-gradient-to-r from-purple-600 via-blue-600 via-green-500 to-yellow-500 bg-[length:400%_100%] animate-rainbow opacity-20"></div>
        
        <!-- Content -->
        <div class="relative z-10 p-12">
          <!-- Animated crown -->
          <div class="text-8xl mb-6 animate-crown-bounce">👑</div>
          
          <!-- Main title with typewriter effect -->
          <h1 class="text-4xl md:text-5xl font-bold text-white mb-4">
            <span class="gradient-text-animated">Félicitations !</span>
          </h1>
          
          <!-- Subtitle -->
          <h2 class="text-2xl font-semibold text-gray-200 mb-6 animate-slide-up-delayed">
            Vous êtes maintenant Premium ! 🎉
          </h2>
          
          <!-- Thank you message -->
          <div class="bg-white/10 rounded-2xl p-6 mb-8 animate-fade-in-delayed">
            <p class="text-lg text-gray-200 leading-relaxed mb-4">
              <strong class="text-yellow-400">Merci pour votre achat Premium !</strong>
            </p>
            <p class="text-gray-300 leading-relaxed">
              Grâce à votre soutien, nous allons pouvoir continuer à développer la plateforme, 
              ajouter de nouvelles fonctionnalités et offrir la meilleure expérience possible 
              aux étudiants en BUT.
            </p>
          </div>
          
          <!-- Features unlocked -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8 animate-features-appear">
            <div class="bg-green-500/20 border border-green-400/30 rounded-lg p-4">
              <div class="text-green-400 text-2xl mb-2">🚀</div>
              <h3 class="text-white font-semibold mb-1">Fonctionnalités débloquées</h3>
              <p class="text-green-200 text-sm">Compétences, projets et apprentissages illimités</p>
            </div>
            <div class="bg-blue-500/20 border border-blue-400/30 rounded-lg p-4">
              <div class="text-blue-400 text-2xl mb-2">📊</div>
              <h3 class="text-white font-semibold mb-1">Export Excel</h3>
              <p class="text-blue-200 text-sm">Exportez votre portfolio au format professionnel</p>
            </div>
          </div>
          
          <!-- Support link -->
          <div class="bg-purple-500/20 border border-purple-400/30 rounded-xl p-6 mb-8 animate-support-appear">
            <h3 class="text-xl font-bold text-white mb-3 flex items-center justify-center">
              <span class="mr-2">💬</span>
              Support FolioLink Premium
            </h3>
            <p class="text-gray-300 mb-4">
              En tant qu'utilisateur Premium, vous avez accès au support prioritaire. Proposez des améliorations, signalez des bugs ou suggérez de nouvelles fonctionnalités.
            </p>
            <a 
              href="mailto:support@foliolink.fr?subject=Support%20Premium%20-%20Suggestion"
              target="_blank"
              rel="noopener noreferrer"
              class="inline-flex items-center bg-purple-600 hover:bg-purple-700 text-white font-semibold px-6 py-3 rounded-lg transition-all duration-300 hover:scale-105"
            >
              <span class="mr-2">📝</span>
              Contacter le Support Premium
            </a>
          </div>
          
          <!-- Close button -->
          <button 
            @click="$emit('close')"
            class="btn-primary text-lg px-8 py-4 animate-button-appear hover:scale-105 transform transition-all duration-300"
          >
            <span class="mr-2">✨</span>
            Commencer avec Premium
          </button>
        </div>
        
        <!-- Confetti effect -->
        <div class="absolute inset-0 pointer-events-none">
          <div 
            v-for="i in 30" 
            :key="`confetti-${i}`"
            class="absolute w-3 h-3 animate-confetti"
            :style="getConfettiStyle(i)"
          ></div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'

defineEmits(['close'])

const getParticleStyle = (index: number) => {
  const delay = Math.random() * 3
  const duration = 3 + Math.random() * 2
  return {
    left: Math.random() * 100 + '%',
    top: Math.random() * 100 + '%',
    animationDelay: delay + 's',
    animationDuration: duration + 's'
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

onMounted(() => {
  // Play celebration sound if available
  try {
    const audio = new Audio('data:audio/wav;base64,UklGRnoGAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQoGAACBhYqFbF1fdJivrJBhNjVgodDbq2EcBj+a2/LDciUFLIHO8tiJNwgZaLvt559NEAxQp+PwtmMcBjiR1/LMeSwFJHfH8N2QQAoUXrTp66hVFApGn+DyvmwhBSuBzvLZiTYIG2m98OScTgwOUarm7blmGgU7k9n1unEiBC13yO/eizEIHWq+8+OWT')
    audio.volume = 0.3
    audio.play().catch(() => {
      // Ignore audio errors
    })
  } catch (error) {
    // Ignore audio errors
  }
})
</script>

<style scoped>
@keyframes celebration-enter {
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

@keyframes crown-bounce {
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

@keyframes slide-up-delayed {
  0% {
    opacity: 0;
    transform: translateY(30px);
  }
  100% {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes fade-in-delayed {
  0% {
    opacity: 0;
    transform: translateY(20px);
  }
  100% {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes features-appear {
  0% {
    opacity: 0;
    transform: scale(0.8);
  }
  100% {
    opacity: 1;
    transform: scale(1);
  }
}

@keyframes support-appear {
  0% {
    opacity: 0;
    transform: translateX(-20px);
  }
  100% {
    opacity: 1;
    transform: translateX(0);
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

@keyframes float {
  0%, 100% {
    transform: translateY(0px) rotate(0deg);
  }
  50% {
    transform: translateY(-20px) rotate(180deg);
  }
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

.animate-celebration-enter {
  animation: celebration-enter 1s ease-out;
}

.animate-crown-bounce {
  animation: crown-bounce 2s ease-in-out infinite;
}

.animate-rainbow {
  animation: rainbow 3s ease infinite;
}

.animate-slide-up-delayed {
  animation: slide-up-delayed 0.8s ease-out 0.3s both;
}

.animate-fade-in-delayed {
  animation: fade-in-delayed 0.8s ease-out 0.6s both;
}

.animate-features-appear {
  animation: features-appear 0.8s ease-out 0.9s both;
}

.animate-support-appear {
  animation: support-appear 0.8s ease-out 1.2s both;
}

.animate-button-appear {
  animation: button-appear 0.8s ease-out 1.5s both;
}

.animate-float {
  animation: float 3s ease-in-out infinite;
}

.animate-confetti {
  animation: confetti 3s linear infinite;
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