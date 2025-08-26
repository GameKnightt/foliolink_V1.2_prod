<template>
  <div 
    v-if="show"
    class="fixed top-20 right-4 z-50 transform transition-all duration-300 ease-in-out"
    :class="show ? 'translate-x-0 opacity-100' : 'translate-x-full opacity-0'"
  >
    <div class="glass-card p-4 max-w-sm shadow-2xl border border-red-400/30">
      <div class="flex items-center space-x-3">
        <div class="flex-shrink-0">
          <div class="w-8 h-8 bg-blue-500/20 rounded-full flex items-center justify-center">
            <span class="text-blue-400 text-lg">🔒</span>
          </div>
        </div>
        <div class="flex-1">
          <p class="text-white font-medium text-sm">{{ title }}</p>
          <p class="text-gray-300 text-xs mt-1">{{ message }}</p>
        </div>
        <button 
          @click="close"
          class="text-gray-400 hover:text-gray-200 transition-colors"
        >
          <span class="text-lg">×</span>
        </button>
      </div>
      
      <!-- Progress bar -->
      <div class="mt-3 w-full bg-gray-700 rounded-full h-1">
        <div 
          class="bg-blue-400 h-1 rounded-full transition-all duration-100 ease-linear"
          :style="{ width: `${progress}%` }"
        ></div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'

const props = defineProps<{
  title: string
  message: string
  duration?: number
}>()

const emit = defineEmits(['close'])

const show = ref(false)
const progress = ref(100)
const interval = ref<NodeJS.Timeout | null>(null)
const timeout = ref<NodeJS.Timeout | null>(null)

const duration = props.duration || 5000

onMounted(() => {
  // Show the notification with animation
  setTimeout(() => {
    show.value = true
  }, 100)
  
  // Start progress bar animation
  const progressStep = 100 / (duration / 100)
  interval.value = setInterval(() => {
    progress.value -= progressStep
    if (progress.value <= 0) {
      close()
    }
  }, 100)
  
  // Auto close after duration
  timeout.value = setTimeout(() => {
    close()
  }, duration)
})

onUnmounted(() => {
  if (interval.value) {
    clearInterval(interval.value)
  }
  if (timeout.value) {
    clearTimeout(timeout.value)
  }
})

const close = () => {
  show.value = false
  if (interval.value) {
    clearInterval(interval.value)
  }
  if (timeout.value) {
    clearTimeout(timeout.value)
  }
  
  // Wait for animation to complete before emitting close
  setTimeout(() => {
    emit('close')
  }, 300)
}
</script>