<template>
  <div v-if="showTour" class="fixed inset-0 z-[100]">
    <!-- Overlay avec découpe pour l'élément ciblé -->
    <div class="absolute inset-0">
      <!-- Overlay sombre partout sauf sur l'élément ciblé -->
      <div 
        v-if="currentStep && targetElement"
        class="absolute inset-0"
        :style="overlayMaskStyle"
      ></div>
      <!-- Fallback overlay si pas d'élément ciblé -->
      <div 
        v-else
        class="absolute inset-0 bg-black/60 backdrop-blur-sm"
      ></div>
    </div>
    
    <!-- Spotlight sur l'élément ciblé -->
    <div 
      v-if="currentStep && targetElement"
      class="absolute border-4 border-accent-400 rounded-lg shadow-2xl shadow-accent-400/50 transition-all duration-200 ease-out z-10"
      :style="spotlightStyle"
    ></div>
    
    <!-- Bulle d'indication -->
    <div 
      v-if="currentStep && targetElement"
      class="absolute glass-card p-4 max-w-xs shadow-2xl transition-all duration-200 ease-out"
      :style="bubbleStyle"
    >
      <!-- Flèche pointant vers l'élément -->
      <div 
        class="absolute w-4 h-4 bg-white/10 border border-white/20 transform rotate-45"
        :style="arrowStyle"
      ></div>
      
      <!-- Contenu de la bulle -->
      <div class="relative z-10">
        <!-- En-tête avec numéro d'étape -->
        <div class="flex items-center justify-between mb-4">
          <div class="flex items-center space-x-2">
            <div class="w-8 h-8 bg-accent-400 rounded-full flex items-center justify-center">
              <span class="text-gray-900 font-bold text-sm">{{ currentStepIndex + 1 }}</span>
            </div>
            <span class="text-gray-300 text-sm">{{ currentStepIndex + 1 }} / {{ steps.length }}</span>
          </div>
          <button 
            @click="skipTour"
            class="text-gray-400 hover:text-gray-200 text-sm transition-colors"
          >
            Passer (Échap)
          </button>
        </div>
        
        <!-- Titre et description -->
        <h3 class="text-lg font-bold text-white mb-2">{{ currentStep.title }}</h3>
        <p class="text-gray-300 leading-relaxed mb-4 text-sm">{{ currentStep.description }}</p>
        
        <!-- Boutons de navigation -->
        <div class="flex justify-between items-center">
          <button 
            v-if="currentStepIndex > 0"
            @click="prevStep"
            class="btn-secondary text-xs px-3 py-1"
          >
            Précédent
          </button>
          <div v-else></div>
          
          <div class="flex space-x-2">
            <button 
              v-if="currentStepIndex < steps.length - 1"
              @click="nextStep"
              class="btn-primary text-xs px-3 py-1"
            >
              Suivant (Entrée)
            </button>
            <button 
              v-else
              @click="finishTour"
              class="btn-primary text-xs px-3 py-1"
            >
              Terminer (Entrée)
            </button>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Indicateurs de progression -->
    <div class="absolute bottom-8 left-1/2 transform -translate-x-1/2">
      <div class="flex space-x-2">
        <div 
          v-for="(step, index) in steps" 
          :key="index"
          class="w-2 h-2 rounded-full transition-all duration-300"
          :class="index === currentStepIndex ? 'bg-accent-400' : 'bg-white/30'"
        ></div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, nextTick, watch } from 'vue'

interface OnboardingStep {
  targetId: string
  title: string
  description: string
  position: 'top' | 'bottom' | 'left' | 'right'
}

const props = defineProps<{
  steps: OnboardingStep[]
  show: boolean
}>()

const emit = defineEmits(['onboarding-finished', 'onboarding-skipped'])

const showTour = ref(false)
const currentStepIndex = ref(0)
const navigationDirection = ref<'next' | 'prev' | 'start'>('start')
const targetElement = ref<HTMLElement | null>(null)
const isInitialized = ref(false)
const scrollPosition = ref({ x: 0, y: 0 })

const currentStep = computed(() => props.steps[currentStepIndex.value])

const spotlightStyle = computed(() => {
  if (!targetElement.value) return {}
  
  const rect = targetElement.value.getBoundingClientRect()
  const padding = 8
  return {
    top: `${rect.top - padding}px`,
    left: `${rect.left - padding}px`,
    width: `${rect.width + (padding * 2)}px`,
    height: `${rect.height + (padding * 2)}px`,
  }
})

const bubbleStyle = computed(() => {
  if (!targetElement.value || !currentStep.value) return {}
  
  const rect = targetElement.value.getBoundingClientRect()
  const bubbleWidth = 320 // max-w-xs = 20rem = 320px
  const bubbleHeight = 200 // estimation réduite
  
  let top = 0
  let left = 0
  
  // TOUJOURS positionner à gauche de l'élément ciblé
  top = rect.top + (rect.height / 2) - (bubbleHeight / 2)
  left = rect.left - bubbleWidth - 30
  
  // FORCER la position à gauche même si pas assez de place
  // Si vraiment pas de place, ajuster mais rester à gauche
  if (left < 20) {
    left = 20 // Minimum 20px du bord gauche
    // Ajuster la position verticale si nécessaire
    if (rect.top < bubbleHeight / 2) {
      top = rect.bottom + 20 // Positionner en dessous si pas de place au-dessus
    }
  }
  
  // Ajustements pour rester dans les limites de l'écran
  const padding = 20
  // Ne pas dépasser la largeur d'écran mais privilégier la gauche
  left = Math.max(padding, Math.min(left, Math.max(padding, window.innerWidth - bubbleWidth - padding)))
  top = Math.max(padding, Math.min(top, window.innerHeight - bubbleHeight - padding))
  
  return {
    top: `${top}px`,
    left: `${left}px`,
  }
})

const arrowStyle = computed(() => {
  if (!currentStep.value) return {}
  
  const arrowSize = 8
  const rect = targetElement.value?.getBoundingClientRect()
  if (!rect) return {}
  
  const bubbleWidth = 320
  const bubbleLeft = rect.left - bubbleWidth - 30
  // TOUJOURS considérer qu'on est à gauche maintenant
  const isOnLeft = true
  
  let arrowPosition = {}
  
  if (isOnLeft) {
    // Bulle à gauche, flèche vers la droite
    arrowPosition = {
      right: `-${arrowSize}px`,
      top: '50%',
      transform: 'translateY(-50%) rotate(45deg)',
    }
  } else {
    // Bulle à droite, flèche vers la gauche
    arrowPosition = {
      left: `-${arrowSize}px`,
      top: '50%',
      transform: 'translateY(-50%) rotate(45deg)',
    }
  }
  
  return arrowPosition
})

const overlayMaskStyle = computed(() => {
  if (!targetElement.value) return {}
  
  const rect = targetElement.value.getBoundingClientRect()
  const padding = 8
  
  // Créer un masque CSS qui découpe la zone de l'élément ciblé
  const clipPath = `polygon(
    0% 0%, 
    0% 100%, 
    ${rect.left - padding}px 100%, 
    ${rect.left - padding}px ${rect.top - padding}px, 
    ${rect.right + padding}px ${rect.top - padding}px, 
    ${rect.right + padding}px ${rect.bottom + padding}px, 
    ${rect.left - padding}px ${rect.bottom + padding}px, 
    ${rect.left - padding}px 100%, 
    100% 100%, 
    100% 0%
  )`
  
  return {
    background: 'rgba(0, 0, 0, 0.6)',
    backdropFilter: 'blur(2px)',
    clipPath: clipPath,
    WebkitClipPath: clipPath
  }
})

const updateTargetElement = async () => {
  if (!currentStep.value) return
  
  console.log('Looking for element:', currentStep.value.targetId)
  await nextTick()
  const element = document.getElementById(currentStep.value.targetId)
  console.log('Found element:', element)
  if (element) {
    // Scroll vers l'élément avec une animation fluide
    scrollToElement(element)
  } else {
    console.warn('Element not found:', currentStep.value.targetId)
  }
}

// Fonction pour scroller vers un élément de manière fluide
const scrollToElement = (element: HTMLElement) => {
  const rect = element.getBoundingClientRect()
  const windowHeight = window.innerHeight
  const margin = 100 // Marge de sécurité
  
  // Vérifier si l'élément est complètement visible
  const isCompletelyVisible = (
    rect.top >= margin && 
    rect.bottom <= windowHeight - margin
  )
  
  console.log('Element visibility check:', {
    elementId: element.id,
    rect: { top: rect.top, bottom: rect.bottom, height: rect.height },
    windowHeight,
    isCompletelyVisible
  })
  
  if (isCompletelyVisible) {
    // L'élément est déjà complètement visible, pas besoin de scroller
    console.log('Element already visible, no scroll needed')
    targetElement.value = element
    return
  }
  
  // L'élément n'est pas complètement visible, on doit scroller
  const elementTop = rect.top + window.pageYOffset
  const elementHeight = rect.height
  
  // Calculer la position optimale pour centrer l'élément
  const optimalScrollTop = elementTop - (windowHeight / 2) + (elementHeight / 2)
  
  console.log('Scrolling to element:', {
    elementId: element.id,
    currentScrollTop: window.pageYOffset,
    optimalScrollTop: Math.max(0, optimalScrollTop)
  })
  
  // Scroll fluide vers la position optimale
  window.scrollTo({
    top: Math.max(0, optimalScrollTop),
    behavior: 'smooth'
  })
  
  // Attendre que le scroll soit terminé avant de continuer
  setTimeout(() => {
    // Forcer une mise à jour des positions après le scroll
    targetElement.value = element
  }, 500)
}

const nextStep = async () => {
  if (currentStepIndex.value < props.steps.length - 1) {
    navigationDirection.value = 'next'
    currentStepIndex.value++
    await updateTargetElement()
  }
}

const prevStep = async () => {
  if (currentStepIndex.value > 0) {
    navigationDirection.value = 'prev'
    currentStepIndex.value--
    await updateTargetElement()
  }
}

const skipTour = () => {
  showTour.value = false
  enableScroll()
  
  // Remove keyboard event listener
  if (isInitialized.value) {
    console.log('Removing keyboard event listener (skip)')
    document.removeEventListener('keydown', handleKeydown)
    isInitialized.value = false
  }
  
  emit('onboarding-skipped')
}

const finishTour = () => {
  showTour.value = false
  enableScroll()
  
  // Remove keyboard event listener
  if (isInitialized.value) {
    console.log('Removing keyboard event listener (finish)')
    document.removeEventListener('keydown', handleKeydown)
    isInitialized.value = false
  }
  
  // Créer l'effet de confettis et le message d'encouragement
  createCelebrationEffect()
  
  // Émettre l'événement après un court délai
  setTimeout(() => {
    emit('onboarding-finished')
  }, 500)
}

const createCelebrationEffect = () => {
  // Créer l'effet de confettis
  createConfettiEffect()
  
  // Créer le message d'encouragement
  createEncouragementMessage()
}

// Fonction pour créer l'effet de confettis
const createConfettiEffect = () => {
  const colors = ['#facc15', '#3b82f6', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6']
  const confettiCount = 50
  
  for (let i = 0; i < confettiCount; i++) {
    setTimeout(() => {
      const confetti = document.createElement('div')
      confetti.style.position = 'fixed'
      confetti.style.left = Math.random() * 100 + 'vw'
      confetti.style.top = '-10px'
      confetti.style.width = '10px'
      confetti.style.height = '10px'
      confetti.style.backgroundColor = colors[Math.floor(Math.random() * colors.length)]
      confetti.style.borderRadius = '50%'
      confetti.style.zIndex = '9999'
      confetti.style.pointerEvents = 'none'
      confetti.style.animation = `confetti-fall ${2 + Math.random() * 3}s linear forwards`
      
      document.body.appendChild(confetti)
      
      // Supprimer l'élément après l'animation
      setTimeout(() => {
        if (confetti.parentNode) {
          confetti.parentNode.removeChild(confetti)
        }
      }, 5000)
    }, i * 50) // Décalage pour créer un effet de cascade
  }
}

// Fonction pour créer le message d'encouragement
const createEncouragementMessage = () => {
  const messages = [
    "🎉 Félicitations ! Vous maîtrisez maintenant FolioLink !",
    "🚀 Parfait ! Vous êtes prêt à créer un portfolio BUT exceptionnel !",
    "✨ Bravo ! Vous connaissez maintenant toutes les fonctionnalités !",
    "🎯 Excellent ! Votre portfolio BUT va impressionner jury et recruteurs !",
    "🏆 Super ! Vous êtes maintenant un expert FolioLink !"
  ]
  
  const randomMessage = messages[Math.floor(Math.random() * messages.length)]
  
  // Créer l'élément de notification
  const notification = document.createElement('div')
  notification.className = 'fixed top-20 left-1/2 transform -translate-x-1/2 z-[200] glass-card p-6 max-w-md shadow-2xl border border-green-400/30 animate-celebration-popup'
  notification.innerHTML = `
    <div class="text-center">
      <div class="text-4xl mb-3 animate-bounce">🎉</div>
      <p class="text-white font-bold text-lg mb-2">Onboarding Terminé !</p>
      <p class="text-green-200 text-sm">${randomMessage}</p>
    </div>
    <div class="mt-4 w-full bg-gray-700 rounded-full h-1">
      <div class="bg-green-400 h-1 rounded-full transition-all duration-100 ease-linear celebration-progress" style="width: 100%"></div>
    </div>
  `
  
  document.body.appendChild(notification)
  
  // Animer la barre de progression
  const progressBar = notification.querySelector('.celebration-progress') as HTMLElement
  if (progressBar) {
    let width = 100
    const interval = setInterval(() => {
      width -= 100 / 40 // 4 seconds = 40 intervals of 100ms
      progressBar.style.width = `${Math.max(0, width)}%`
      if (width <= 0) {
        clearInterval(interval)
        notification.remove()
      }
    }, 100)
  }
  
  // Auto remove after 4 seconds
  setTimeout(() => {
    if (notification.parentNode) {
      notification.remove()
    }
  }, 4000)
}
const handleKeydown = (event: KeyboardEvent) => {
  if (!showTour.value) return
  
  console.log('Onboarding keydown:', event.key, 'Current step:', currentStepIndex.value)
  
  // Empêcher le scroll utilisateur avec les flèches et autres touches
  if (['ArrowUp', 'ArrowDown', 'PageUp', 'PageDown', 'Home', 'End', 'Space'].includes(event.key)) {
    event.preventDefault()
  }
  
  switch (event.key) {
    case 'Escape':
      event.preventDefault()
      console.log('Escape pressed - skipping tour')
      skipTour()
      break
    case 'Enter':
      event.preventDefault()
      console.log('Enter pressed - advancing tour')
      if (currentStepIndex.value < props.steps.length - 1) {
        console.log('Going to next step')
        nextStep()
      } else {
        console.log('Finishing tour')
        finishTour()
      }
      break
    case 'ArrowRight':
      event.preventDefault()
      console.log('Arrow right pressed')
      if (currentStepIndex.value < props.steps.length - 1) {
        nextStep()
      }
      break
    case 'ArrowLeft':
      event.preventDefault()
      console.log('Arrow left pressed')
      if (currentStepIndex.value > 0) {
        prevStep()
      }
      break
  }
}

// Fonctions pour bloquer/débloquer le scroll
const disableScroll = () => {
  // Sauvegarder la position actuelle
  scrollPosition.value = {
    x: window.pageXOffset || document.documentElement.scrollLeft,
    y: window.pageYOffset || document.documentElement.scrollTop
  }
  
  // Bloquer le scroll utilisateur mais permettre le scroll programmatique
  document.body.style.overflow = 'hidden'
  // Ne pas fixer la position pour permettre le scroll programmatique
}

const enableScroll = () => {
  // Restaurer le scroll
  document.body.style.overflow = ''
}

// Watcher pour démarrer/arrêter le tour
const startTour = async () => {
  console.log('StartTour called:', { show: props.show, stepsLength: props.steps.length })
  if (props.show && props.steps.length > 0) {
    showTour.value = true
    currentStepIndex.value = 0
    navigationDirection.value = 'start'
    disableScroll()
    
    // Add keyboard event listener
    if (!isInitialized.value) {
      console.log('Adding keyboard event listener')
      document.addEventListener('keydown', handleKeydown)
      isInitialized.value = true
    }
    
    // Remonter en haut de la page au début de l'onboarding seulement si nécessaire
    if (window.pageYOffset > 100) {
      console.log('Scrolling to top for onboarding start')
      window.scrollTo({ top: 0, behavior: 'smooth' })
      // Attendre que le scroll soit terminé
      await new Promise(resolve => setTimeout(resolve, 500))
    }
    
    await updateTargetElement()
    console.log('Tour started, showTour:', showTour.value)
  }
}
// Watcher pour réagir aux changements de la prop show
watch(() => props.show, (newValue) => {
  console.log('Show prop changed:', newValue)
  if (newValue) {
    startTour()
  } else {
    // Clean up when tour is hidden
    showTour.value = false
    enableScroll()
    if (isInitialized.value) {
      document.removeEventListener('keydown', handleKeydown)
      isInitialized.value = false
    }
  }
}, { immediate: true })

onMounted(() => {
  console.log('OnboardingTour mounted')
})

onUnmounted(() => {
  console.log('OnboardingTour unmounted')
  // Clean up keyboard event listener
  if (isInitialized.value) {
    document.removeEventListener('keydown', handleKeydown)
    isInitialized.value = false
  }
  enableScroll()
})

// Exposer les méthodes pour contrôle externe
defineExpose({
  startTour,
  skipTour,
  finishTour
})
</script>

<style scoped>
/* Animations personnalisées */
.glass-card {
  animation: slideIn 0.3s ease-out;
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: scale(0.9) translateY(10px);
  }
  to {
    opacity: 1;
    transform: scale(1) translateY(0);
  }
}

/* Effet de pulsation sur le spotlight */
.border-accent-400 {
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% {
    box-shadow: 0 0 0 0 rgba(250, 204, 21, 0.4);
  }
  50% {
    box-shadow: 0 0 0 10px rgba(250, 204, 21, 0);
  }
}

/* Animation des confettis */
@keyframes confetti-fall {
  0% {
    transform: translateY(-10px) rotate(0deg);
    opacity: 1;
  }
  100% {
    transform: translateY(100vh) rotate(720deg);
    opacity: 0;
  }
}

@keyframes celebration-popup {
  0% {
    opacity: 0;
    transform: translateX(-50%) translateY(-20px) scale(0.9);
  }
  10% {
    opacity: 1;
    transform: translateX(-50%) translateY(0) scale(1.05);
  }
  20% {
    transform: translateX(-50%) translateY(0) scale(1);
  }
  100% {
    opacity: 1;
    transform: translateX(-50%) translateY(0) scale(1);
  }
}

.animate-celebration-popup {
  animation: celebration-popup 0.6s ease-out;
}
</style>