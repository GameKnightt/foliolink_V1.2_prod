<template>
  <div 
    class="card-glass p-8 hover:scale-105 transition-all duration-300 cursor-pointer group"
    @click="$emit('click')"
  >
    <div class="flex items-start space-x-4 mb-6">
      <div 
        class="w-12 h-12 rounded-xl flex items-center justify-center text-2xl transition-transform duration-200 group-hover:scale-110"
        :class="competence.color === 'primary' ? 'bg-gradient-primary' : 'bg-gradient-accent'"
      >
        {{ competence.icon }}
      </div>
      <div class="flex-1">
        <h3 class="text-2xl font-bold text-gray-900 dark:text-white mb-2">
          {{ competence.title }}
        </h3>
        <p class="text-gray-600 dark:text-gray-300 font-medium">
          {{ competence.subtitle }}
        </p>
      </div>
    </div>
    
    <p class="text-gray-600 dark:text-gray-400 mb-6 leading-relaxed">
      {{ competence.description }}
    </p>
    
    <div class="flex items-center justify-between">
      <div class="flex items-center space-x-2">
        <span class="text-sm text-gray-500 dark:text-gray-400">Niveaux :</span>
        <div class="flex space-x-1">
          <div 
            v-for="level in competence.levels" 
            :key="level"
            class="w-2 h-2 rounded-full"
            :class="competence.color === 'primary' ? 'bg-primary-400' : 'bg-accent-400'"
          ></div>
        </div>
      </div>
      
      <div class="flex items-center text-primary-600 dark:text-primary-400 group-hover:translate-x-1 transition-transform duration-200">
        <span class="text-sm font-medium mr-1">Explorer</span>
        <ArrowRightIcon class="w-4 h-4" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ArrowRightIcon } from '@heroicons/vue/24/outline'
import type { Competence } from '../data/portfolio'

defineProps<{
  competence: Competence
}>()

defineEmits(['click'])
</script>