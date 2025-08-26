<template>
  <div class="inline-flex items-center space-x-2">
    <!-- Level Badge -->
    <div 
      class="relative px-3 py-1 rounded-full border-2 transition-all duration-300"
      :class="getLevelClasses"
    >
      <div class="flex items-center space-x-2">
        <div class="w-6 h-6 bg-gradient-to-r from-accent-400 to-accent-500 rounded-full flex items-center justify-center">
          <span class="text-gray-900 font-bold text-xs">{{ level }}</span>
        </div>
        <span class="text-white font-medium text-sm">Niveau {{ level }}</span>
      </div>
      
      <!-- Glow effect for high levels -->
      <div 
        v-if="level >= 5"
        class="absolute inset-0 rounded-full animate-pulse opacity-50"
        :class="getGlowClass"
      ></div>
    </div>
    
    <!-- Points Display -->
    <div class="text-accent-400 font-medium text-sm">
      {{ points }} pts
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  level: number
  points: number
}>()

const getLevelClasses = computed(() => {
  if (props.level >= 8) return 'border-purple-400 bg-purple-400/10'
  if (props.level >= 6) return 'border-yellow-400 bg-yellow-400/10'
  if (props.level >= 4) return 'border-blue-400 bg-blue-400/10'
  if (props.level >= 2) return 'border-green-400 bg-green-400/10'
  return 'border-gray-400 bg-gray-400/10'
})

const getGlowClass = computed(() => {
  if (props.level >= 8) return 'bg-purple-400/20'
  if (props.level >= 6) return 'bg-yellow-400/20'
  return 'bg-blue-400/20'
})
</script>