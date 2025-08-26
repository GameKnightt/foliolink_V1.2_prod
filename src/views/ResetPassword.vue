<template>
  <div class="pt-16 min-h-screen bg-gradient-to-br from-gray-900 via-blue-900 to-gray-900 flex items-center justify-center">
    <div class="max-w-md mx-auto px-4">
      <div class="glass-card p-8">
        <div class="text-center mb-8">
          <div class="w-16 h-16 bg-gradient-to-r from-accent-400 to-accent-500 rounded-full flex items-center justify-center mx-auto mb-4">
            <span class="text-2xl">🔑</span>
          </div>
          <h2 class="text-2xl font-bold text-white mb-2">Nouveau mot de passe</h2>
          <p class="text-gray-300">Saisissez votre nouveau mot de passe</p>
        </div>

        <form @submit.prevent="handleResetPassword" class="space-y-6">
          <div>
            <label class="block text-sm font-medium text-gray-300 mb-2">
              Nouveau mot de passe
            </label>
            <input
              v-model="newPassword"
              type="password"
              required
              minlength="10"
              class="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-400 focus:ring-2 focus:ring-accent-400 focus:border-accent-400 transition-colors backdrop-blur-xl"
              placeholder="Nouveau mot de passe (min. 10 caractères)"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-300 mb-2">
              Confirmer le mot de passe
            </label>
            <input
              v-model="confirmPassword"
              type="password"
              required
              minlength="10"
              class="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-400 focus:ring-2 focus:ring-accent-400 focus:border-accent-400 transition-colors backdrop-blur-xl"
              placeholder="Confirmer le mot de passe"
            />
          </div>

          <!-- Error Message -->
          <div v-if="error" class="p-3 bg-red-500/20 border border-red-500/30 rounded-lg">
            <p class="text-red-200 text-sm">{{ error }}</p>
          </div>

          <!-- Success Message -->
          <div v-if="success" class="p-3 bg-green-500/20 border border-green-500/30 rounded-lg">
            <p class="text-green-200 text-sm">{{ success }}</p>
          </div>

          <button 
            type="submit"
            :disabled="loading || !newPassword || newPassword !== confirmPassword"
            class="w-full btn-primary disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <span v-if="loading" class="mr-2">⏳</span>
            <span v-else class="mr-2">🔑</span>
            {{ loading ? 'Mise à jour...' : 'Mettre à jour le mot de passe' }}
          </button>

          <div class="text-center">
            <router-link to="/" class="text-accent-400 hover:text-accent-300 text-sm transition-colors">
              Retour à l'accueil
            </router-link>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { authService } from '../lib/supabase'

const router = useRouter()
const loading = ref(false)
const error = ref('')
const success = ref('')
const newPassword = ref('')
const confirmPassword = ref('')

const handleResetPassword = async () => {
  if (newPassword.value !== confirmPassword.value) {
    error.value = 'Les mots de passe ne correspondent pas'
    return
  }

  if (newPassword.value.length < 10) {
    error.value = 'Le mot de passe doit contenir au moins 10 caractères'
    return
  }

  loading.value = true
  error.value = ''
  success.value = ''

  try {
    const { error: updateError } = await authService.updatePassword(newPassword.value)
    
    if (updateError) {
      error.value = updateError.message
    } else {
      success.value = 'Mot de passe mis à jour avec succès ! Redirection...'
      
      // Rediriger vers le dashboard après 2 secondes
      setTimeout(() => {
        router.push('/dashboard')
      }, 2000)
    }
  } catch (err: any) {
    error.value = 'Erreur lors de la mise à jour du mot de passe'
  } finally {
    loading.value = false
  }
}
</script>