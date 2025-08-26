<template>
  <div class="fixed inset-0 z-50 overflow-y-auto">
    <div class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
      <!-- Background overlay -->
      <div 
        class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity backdrop-blur-sm"
        @click="$emit('cancel')"
      ></div>

      <!-- Modal -->
      <div class="inline-block align-bottom bg-white dark:bg-gray-800 rounded-2xl text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-md sm:w-full">
        <!-- Header -->
        <div class="bg-red-50 dark:bg-red-900/50 px-6 py-4 border-b border-red-200 dark:border-red-700">
          <div class="flex items-center">
            <div class="flex-shrink-0">
              <ExclamationTriangleIcon class="h-6 w-6 text-red-600 dark:text-red-400" />
            </div>
            <div class="ml-3">
              <h3 class="text-lg font-medium text-red-800 dark:text-red-200">
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
        </div>

        <!-- Footer -->
        <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4 border-t border-gray-200 dark:border-gray-600 flex justify-end space-x-3">
          <button 
            @click="$emit('cancel')"
            class="btn-secondary"
          >
            Annuler
          </button>
          <button 
            @click="$emit('confirm')"
            class="bg-red-600 hover:bg-red-700 text-white font-semibold px-6 py-2 rounded-xl transition-all duration-300 hover:shadow-lg"
          >
            Supprimer
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ExclamationTriangleIcon } from '@heroicons/vue/24/outline'

defineProps<{
  title: string
  message: string
}>()

defineEmits(['confirm', 'cancel'])
</script>