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
        <div class="bg-blue-50 dark:bg-blue-900/50 px-6 py-4 border-b border-blue-200 dark:border-blue-700">
          <div class="flex items-center">
            <div class="flex-shrink-0">
              <LockClosedIcon class="h-6 w-6 text-blue-600 dark:text-blue-400" />
            </div>
            <div class="ml-3">
              <h3 class="text-lg font-medium text-blue-800 dark:text-blue-200">
                Connexion Requise
              </h3>
            </div>
          </div>
        </div>

        <!-- Content -->
        <div class="px-6 py-4 bg-white dark:bg-gray-800">
          <p class="text-gray-600 dark:text-gray-300 mb-4">
            Vous devez être connecté pour créer un nouveau projet. 
            Connectez-vous ou créez un compte gratuit pour accéder à toutes les fonctionnalités de votre portfolio BUT.
          </p>
          <div class="bg-accent-50 dark:bg-accent-900/20 p-3 rounded-lg">
            <p class="text-accent-800 dark:text-accent-200 text-sm">
              ✨ Créez votre compte gratuitement et commencez à construire votre portfolio étudiant dès maintenant !
            </p>
          </div>
        </div>

        <!-- Footer -->
        <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4 border-t border-gray-200 dark:border-gray-600 flex justify-end space-x-3">
          <button 
            @click="$emit('close')"
            class="btn-secondary"
          >
            Annuler
          </button>
          <button 
            @click="$emit('login')"
            class="btn-primary"
          >
            <span class="mr-2">🔑</span>
            Se connecter
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { LockClosedIcon } from '@heroicons/vue/24/outline'

defineEmits(['close', 'login'])
</script>