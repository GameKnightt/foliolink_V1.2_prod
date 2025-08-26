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
        <div class="bg-amber-50 dark:bg-amber-900/50 px-6 py-4 border-b border-amber-200 dark:border-amber-700">
          <div class="flex items-center">
            <div class="flex-shrink-0">
              <ExclamationTriangleIcon class="h-6 w-6 text-amber-600 dark:text-amber-400" />
            </div>
            <div class="ml-3">
              <h3 class="text-lg font-medium text-amber-800 dark:text-amber-200">
                Limite d'épinglage atteinte
              </h3>
            </div>
          </div>
        </div>

        <!-- Content -->
        <div class="px-6 py-4 bg-white dark:bg-gray-800">
          <p class="text-gray-600 dark:text-gray-300">
            Vous ne pouvez épingler que 3 apprentissages maximum.
          </p>
          <p class="text-gray-500 dark:text-gray-400 text-sm mt-2">
            Retirez un apprentissage épinglé pour en ajouter un nouveau.
          </p>
        </div>

        <!-- Footer -->
        <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4 border-t border-gray-200 dark:border-gray-600 flex justify-end">
          <button 
            @click="$emit('close')"
            class="btn-primary"
          >
            Compris
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ExclamationTriangleIcon } from '@heroicons/vue/24/outline'

defineEmits(['close'])
</script>