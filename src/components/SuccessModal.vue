<template>
  <div class="fixed inset-0 z-50 overflow-y-auto">
    <div class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
      <!-- Background overlay -->
      <div 
        class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity backdrop-blur-sm"
        @click="$emit('close')"
      ></div>

      <!-- Modal -->
      <div class="inline-block align-bottom glass-card text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-md sm:w-full">
        <!-- Header -->
        <div class="bg-green-50 dark:bg-green-900/50 px-6 py-4 border-b border-green-200 dark:border-green-700">
          <div class="flex items-center">
            <div class="flex-shrink-0">
              <CheckCircleIcon class="h-6 w-6 text-green-600 dark:text-green-400" />
            </div>
            <div class="ml-3">
              <h3 class="text-lg font-medium text-green-800 dark:text-green-200">
                {{ title }}
              </h3>
            </div>
          </div>
        </div>

        <!-- Content -->
        <div class="px-6 py-4 bg-white dark:bg-gray-800">
          <p class="text-gray-600 dark:text-gray-300">
            {{ message }}
          </p>
          <div v-if="showPremiumActivation" class="mt-4 p-3 bg-accent-50 dark:bg-accent-900/20 rounded-lg">
            <div class="flex items-center text-accent-800 dark:text-accent-200">
              <span class="mr-2">👑</span>
              <span class="text-sm font-medium">Votre compte Premium a été activé avec succès !</span>
            </div>
          </div>
        </div>

        <!-- Footer -->
        <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4 border-t border-gray-200 dark:border-gray-600 flex justify-end">
          <button 
            @click="$emit('close')"
            class="btn-primary"
          >
            Parfait !
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { CheckCircleIcon } from '@heroicons/vue/24/outline'

defineProps<{
  title: string
  message: string
  showPremiumActivation?: boolean
}>()

defineEmits(['close'])
</script>