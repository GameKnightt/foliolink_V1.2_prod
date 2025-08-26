<template>
  <div class="inline-flex items-center space-x-2">
    <!-- Counter Badge -->
    <div 
      class="px-3 py-1 rounded-full text-sm font-medium transition-all duration-300"
      :class="getCounterClasses"
    >
      <span class="flex items-center space-x-1">
        <span>{{ current }}/{{ max }}</span>
        <span v-if="type === 'competences'">🎯</span>
        <span v-else-if="type === 'apprentissages'">📚</span>
        <span v-else-if="type === 'projets'">🚀</span>
      </span>
    </div>
    
    <!-- Warning icon when near limit -->
    <div 
      v-if="!isPremium && current >= max * 0.8" 
      class="w-5 h-5 text-yellow-500 animate-pulse"
      :title="current >= max ? 'Limite atteinte' : 'Proche de la limite'"
    >
      <span v-if="current >= max">🔒</span>
      <span v-else>⚠️</span>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  type: 'competences' | 'apprentissages' | 'projets'
  current: number
  max: number
  isPremium: boolean
}>()

const getCounterClasses = computed(() => {
  if (props.isPremium) {
    return 'bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200 border border-blue-200 dark:border-blue-700'
  }
  
  const percentage = props.current / props.max
  
  if (percentage >= 1) {
    return 'bg-red-100 dark:bg-red-900 text-red-800 dark:text-red-200 border border-red-200 dark:border-red-700 animate-pulse'
  } else if (percentage >= 0.8) {
    return 'bg-yellow-100 dark:bg-yellow-900 text-yellow-800 dark:text-yellow-200 border border-yellow-200 dark:border-yellow-700'
  } else {
    return 'bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200 border border-blue-200 dark:border-blue-700'
  }
})
</script>

<style scoped>
</style>