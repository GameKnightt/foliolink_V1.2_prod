<template>
  <span 
    class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium"
    :class="badgeClasses"
  >
    <div 
      class="w-2 h-2 rounded-full mr-2"
      :class="dotClasses"
    ></div>
    {{ evaluation }}
  </span>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  evaluation: 'Bien Maîtrisé' | 'Partiellement Maîtrisé' | 'Pas Maîtrisé'
}>()

const badgeClasses = computed(() => {
  switch (props.evaluation) {
    case 'Bien Maîtrisé':
      return 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200'
    case 'Partiellement Maîtrisé':
      return 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200'
    case 'Pas Maîtrisé':
      return 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200'
    default:
      return 'bg-gray-100 text-gray-800 dark:bg-gray-900 dark:text-gray-200'
  }
})

const dotClasses = computed(() => {
  switch (props.evaluation) {
    case 'Bien Maîtrisé':
      return 'bg-green-500'
    case 'Partiellement Maîtrisé':
      return 'bg-yellow-500'
    case 'Pas Maîtrisé':
      return 'bg-red-500'
    default:
      return 'bg-gray-500'
  }
})
</script>