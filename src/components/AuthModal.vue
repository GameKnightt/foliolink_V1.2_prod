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
        <div class="bg-white/10 dark:bg-gray-800/50 px-6 py-4 border-b border-white/20 dark:border-gray-600/30">
          <div class="flex items-center justify-between">
            <h3 class="text-lg font-semibold text-white">
              {{ isLogin ? 'Connexion' : 'Inscription' }}
            </h3>
            <button 
              @click="$emit('close')"
              class="text-gray-400 hover:text-gray-200 transition-colors"
            >
              <XMarkIcon class="w-6 h-6" />
            </button>
          </div>
        </div>

        <!-- Content -->
        <div class="px-6 py-6">
          <form @submit.prevent="handleSubmit" class="space-y-4">
            <!-- Full Name (only for signup) -->
            <div v-if="!isLogin">
              <label class="block text-sm font-medium text-gray-300 mb-2">
                Nom complet
              </label>
              <input
                v-model="form.fullName"
                type="text"
                required
                class="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-400 focus:ring-2 focus:ring-accent-400 focus:border-accent-400 transition-colors backdrop-blur-xl"
                placeholder="Votre nom complet"
              />
            </div>

            <!-- Email -->
            <div>
              <label class="block text-sm font-medium text-gray-300 mb-2">
                Email
              </label>
              <input
                v-model="form.email"
                type="email"
                required
                class="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-400 focus:ring-2 focus:ring-accent-400 focus:border-accent-400 transition-colors backdrop-blur-xl"
                placeholder="votre@email.com"
              />
            </div>

            <!-- Password -->
            <div>
              <label class="block text-sm font-medium text-gray-300 mb-2">
                Mot de passe
              </label>
              <div class="relative">
                <input
                  v-model="form.password"
                  :type="showPassword ? 'text' : 'password'"
                  required
                  minlength="12"
                  class="w-full px-4 py-3 pr-12 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-400 focus:ring-2 focus:ring-accent-400 focus:border-accent-400 transition-colors backdrop-blur-xl"
                  placeholder="••••••••"
                />
                <button
                  type="button"
                  @click="showPassword = !showPassword"
                  class="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-200 transition-colors"
                  :aria-label="showPassword ? 'Masquer le mot de passe' : 'Afficher le mot de passe'"
                >
                  <EyeIcon v-if="!showPassword" class="w-5 h-5" />
                  <EyeSlashIcon v-else class="w-5 h-5" />
                </button>
              </div>
              
              <!-- Forgot Password -->
              <div v-if="isLogin" class="text-center">
                <button 
                  type="button"
                  @click="handleForgotPassword"
                  :disabled="forgotPasswordLoading"
                  class="text-accent-400 hover:text-accent-300 text-sm transition-colors disabled:opacity-50"
                >
                  {{ forgotPasswordLoading ? 'Envoi en cours...' : 'Mot de passe oublié ?' }}
                </button>
              </div>
              <p class="text-xs text-gray-400 mt-1">Le mot de passe doit contenir au moins 12 caractères</p>
            </div>

            <!-- Error Message -->
            <div v-if="error" class="p-3 bg-red-500/20 border border-red-500/30 rounded-lg">
              <p class="text-red-200 text-sm">{{ error }}</p>
            </div>

            <!-- Success Message -->
            <div v-if="success" class="p-3 bg-green-500/20 border border-green-500/30 rounded-lg">
              <p class="text-green-200 text-sm">{{ success }}</p>
            </div>

            <!-- Submit Button -->
            <button 
              type="submit"
              :disabled="loading"
              class="w-full btn-primary disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <span v-if="loading" class="mr-2">⏳</span>
              <span v-else class="mr-2">{{ isLogin ? '🔑' : '✨' }}</span>
              {{ loading ? 'Chargement...' : (isLogin ? 'Se connecter' : 'S\'inscrire') }}
            </button>

            <!-- OAuth Divider -->
            <div class="relative my-6">
              <div class="absolute inset-0 flex items-center">
                <div class="w-full border-t border-white/20"></div>
              </div>
              <div class="relative flex justify-center text-sm">
                <span class="px-2 bg-gray-800 text-gray-400">ou</span>
              </div>
            </div>

            <!-- OAuth Buttons -->
            <div class="space-y-3">
              <!-- Google OAuth Button -->
              <button 
                type="button"
                @click="handleOAuthSignIn('google')"
                :disabled="loading"
                class="w-full flex items-center justify-center px-4 py-3 bg-white hover:bg-gray-50 text-gray-900 font-medium rounded-xl transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed border border-gray-300"
              >
                <!-- Google Logo SVG -->
                <svg class="w-5 h-5 mr-3" viewBox="0 0 24 24">
                  <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                  <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                  <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                  <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
                </svg>
                <span v-if="loading">Connexion...</span>
                <span v-else>Continuer avec Google</span>
              </button>

              <!-- Discord OAuth Button -->
              <button 
                type="button"
                @click="handleOAuthSignIn('discord')"
                :disabled="loading"
                class="w-full flex items-center justify-center px-4 py-3 bg-[#5865F2] hover:bg-[#4752C4] text-white font-medium rounded-xl transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <!-- Discord Logo SVG -->
                <svg class="w-5 h-5 mr-3 fill-current" viewBox="0 0 24 24">
                  <path d="M20.317 4.37a19.791 19.791 0 0 0-4.885-1.515a.074.074 0 0 0-.079.037c-.21.375-.444.864-.608 1.25a18.27 18.27 0 0 0-5.487 0a12.64 12.64 0 0 0-.617-1.25a.077.077 0 0 0-.079-.037A19.736 19.736 0 0 0 3.677 4.37a.07.07 0 0 0-.032.027C.533 9.046-.32 13.58.099 18.057a.082.082 0 0 0 .031.057a19.9 19.9 0 0 0 5.993 3.03a.078.078 0 0 0 .084-.028a14.09 14.09 0 0 0 1.226-1.994a.076.076 0 0 0-.041-.106a13.107 13.107 0 0 1-1.872-.892a.077.077 0 0 1-.008-.128a10.2 10.2 0 0 0 .372-.292a.074.074 0 0 1 .077-.01c3.928 1.793 8.18 1.793 12.062 0a.074.074 0 0 1 .078.01c.12.098.246.198.373.292a.077.077 0 0 1-.006.127a12.299 12.299 0 0 1-1.873.892a.077.077 0 0 0-.041.107c.36.698.772 1.362 1.225 1.993a.076.076 0 0 0 .084.028a19.839 19.839 0 0 0 6.002-3.03a.077.077 0 0 0 .032-.054c.5-5.177-.838-9.674-3.549-13.66a.061.061 0 0 0-.031-.03zM8.02 15.33c-1.183 0-2.157-1.085-2.157-2.419c0-1.333.956-2.419 2.157-2.419c1.21 0 2.176 1.096 2.157 2.42c0 1.333-.956 2.418-2.157 2.418zm7.975 0c-1.183 0-2.157-1.085-2.157-2.419c0-1.333.955-2.419 2.157-2.419c1.21 0 2.176 1.096 2.157 2.42c0 1.333-.946 2.418-2.157 2.418z"/>
                </svg>
                <span v-if="loading">Connexion...</span>
                <span v-else>Continuer avec Discord</span>
              </button>
            </div>
            <!-- Toggle Mode -->
            <div class="text-center">
              <button 
                type="button"
                @click="toggleMode"
                class="text-accent-400 hover:text-accent-300 text-sm transition-colors"
              >
                {{ isLogin ? 'Pas encore de compte ? S\'inscrire' : 'Déjà un compte ? Se connecter' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
    
    <!-- Forgot Password Success Modal -->
    <SuccessModal
      v-if="showForgotPasswordSuccess"
      title="Email envoyé !"
      message="Un email de réinitialisation a été envoyé à votre adresse. Vérifiez votre boîte mail et suivez les instructions."
      @close="showForgotPasswordSuccess = false"
    />
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { XMarkIcon, EyeIcon, EyeSlashIcon } from '@heroicons/vue/24/outline'
import { authService } from '../lib/supabase'
import SuccessModal from './SuccessModal.vue'

const emit = defineEmits(['close', 'success'])

const isLogin = ref(true)
const loading = ref(false)
const forgotPasswordLoading = ref(false)
const error = ref('')
const success = ref('')
const showPassword = ref(false)
const showForgotPasswordSuccess = ref(false)

const form = ref({
  email: '',
  password: '',
  fullName: ''
})

const toggleMode = () => {
  isLogin.value = !isLogin.value
  error.value = ''
  success.value = ''
  form.value = { email: '', password: '', fullName: '' }
  showPassword.value = false
}

const handleForgotPassword = async () => {
  if (!form.value.email) {
    error.value = 'Veuillez saisir votre adresse email'
    return
  }

  forgotPasswordLoading.value = true
  error.value = ''
  success.value = ''

  try {
    const { error: resetError } = await authService.resetPassword(form.value.email)
    
    if (resetError) {
      error.value = resetError.message
    } else {
      showForgotPasswordSuccess.value = true
    }
  } catch (err) {
    error.value = 'Erreur lors de l\'envoi de l\'email de réinitialisation'
  } finally {
    forgotPasswordLoading.value = false
  }
}
const handleOAuthSignIn = async (provider: 'google' | 'discord') => {
  loading.value = true
  error.value = ''
  success.value = ''

  try {
    const { error: authError } = await authService.signInWithOAuth(provider)
    
    if (authError) {
      console.error(`${provider} OAuth error:`, authError)
      error.value = `Erreur de connexion avec ${provider === 'google' ? 'Google' : 'Discord'}. Veuillez réessayer.`
    } else {
      // Close the modal immediately on successful OAuth initiation
      // The user will be redirected to the OAuth provider
      success.value = `Redirection vers ${provider === 'google' ? 'Google' : 'Discord'}...`
      
      // Close modal after a short delay to show success message
      setTimeout(() => {
        emit('close')
      }, 1000)
    }
  } catch (err) {
    console.error(`${provider} OAuth error:`, err)
    error.value = `Erreur de connexion avec ${provider === 'google' ? 'Google' : 'Discord'}`
  } finally {
    loading.value = false
  }
}
const handleSubmit = async () => {
  loading.value = true
  error.value = ''
  success.value = ''

  // Client-side validation
  if (!form.value.email || !form.value.password) {
    error.value = 'Tous les champs sont requis'
    loading.value = false
    return
  }

  // Email validation
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  if (!emailRegex.test(form.value.email)) {
    error.value = 'Format d\'email invalide'
    loading.value = false
    return
  }

  // Password validation
  if (form.value.password.length < 12) {
    error.value = 'Le mot de passe doit contenir au moins 12 caractères'
    loading.value = false
    return
  }

  if (!isLogin.value && (!form.value.fullName || form.value.fullName.trim().length < 2)) {
    error.value = 'Le nom complet est requis (minimum 2 caractères)'
    loading.value = false
    return
  }

  try {
    if (isLogin.value) {
      // Connexion
      const { data, error: authError } = await authService.signIn(form.value.email, form.value.password)
      
      if (authError) {
        // Sanitized error messages - don't expose system details
        error.value = 'Identifiants incorrects ou compte non confirmé'
      } else {
        success.value = 'Connexion réussie !'
        setTimeout(() => {
          emit('success', data.user)
        }, 1000)
      }
    } else {
      // Inscription
      const { data, error: authError } = await authService.signUp(
        form.value.email, 
        form.value.password, 
        form.value.fullName
      )
      
      if (authError) {
        // Sanitized error messages
        error.value = 'Erreur lors de l\'inscription. Vérifiez vos informations.'
      } else {
        // Vérifier si l'utilisateur a été créé mais non confirmé
        if (data.user && !data.user.email_confirmed_at) {
          success.value = 'Inscription réussie ! Un email de confirmation a été envoyé. Vérifiez votre boîte mail et cliquez sur le lien pour activer votre compte.'
        } else if (data.user && data.user.email_confirmed_at) {
          // Si l'email est déjà confirmé (ne devrait pas arriver)
          success.value = 'Compte créé et confirmé ! Vous pouvez maintenant vous connecter.'
        } else {
          success.value = 'Inscription réussie ! Vérifiez votre email pour confirmer votre compte.'
        }
        
        setTimeout(() => {
          // Basculer vers le mode connexion après inscription
          isLogin.value = true
          form.value = { email: form.value.email, password: '', fullName: '' }
          success.value = ''
        }, 3000)
      }
    }
  } catch (err) {
    // Don't log sensitive errors to console in production
    error.value = 'Service temporairement indisponible'
  } finally {
    loading.value = false
  }
}
</script>