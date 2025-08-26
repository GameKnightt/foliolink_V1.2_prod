<template>
  <div class="pt-16 min-h-screen bg-gradient-to-br from-gray-900 via-blue-900 to-gray-900 flex items-center justify-center">
    <div class="max-w-md mx-auto px-4">
      <div class="glass-card p-8 text-center">
        <div v-if="loading" class="space-y-4">
          <div class="w-16 h-16 bg-gradient-to-r from-accent-400 to-accent-500 rounded-full flex items-center justify-center mx-auto animate-pulse">
            <span class="text-2xl">⏳</span>
          </div>
          <h2 class="text-2xl font-bold text-white">Authentification en cours...</h2>
          <p class="text-gray-300">Finalisation de votre connexion, veuillez patienter.</p>
        </div>

        <div v-else-if="success" class="space-y-4">
          <div class="w-16 h-16 bg-gradient-to-r from-green-400 to-green-500 rounded-full flex items-center justify-center mx-auto">
            <span class="text-2xl">✅</span>
          </div>
          <h2 class="text-2xl font-bold text-white">Connexion réussie !</h2>
          <p class="text-gray-300">Vous êtes maintenant connecté. Redirection vers votre dashboard...</p>
        </div>

        <div v-else-if="error" class="space-y-4">
          <div class="w-16 h-16 bg-gradient-to-r from-red-400 to-red-500 rounded-full flex items-center justify-center mx-auto">
            <span class="text-2xl">❌</span>
          </div>
          <h2 class="text-2xl font-bold text-white">Erreur d'authentification</h2>
          <p class="text-gray-300 mb-4">{{ error }}</p>
          <router-link to="/" class="btn-primary">
            Retour à l'accueil
          </router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { supabase, profileService } from '../lib/supabase'

const router = useRouter()
const loading = ref(true)
const success = ref(false)
const error = ref('')

onMounted(async () => {
  try {
    // Récupérer les paramètres de l'URL
    const urlParams = new URLSearchParams(window.location.search)
    const hashParams = new URLSearchParams(window.location.hash.substring(1))
    const accessToken = urlParams.get('access_token')
    const refreshToken = urlParams.get('refresh_token')
    const type = urlParams.get('type')
    
    // For OAuth providers, tokens might be in hash instead of query params
    const hashAccessToken = hashParams.get('access_token')
    const hashRefreshToken = hashParams.get('refresh_token')
    
    // Use tokens from either source
    const finalAccessToken = accessToken || hashAccessToken
    const finalRefreshToken = refreshToken || hashRefreshToken

    if (type === 'signup' && finalAccessToken && finalRefreshToken) {
      // Confirmer l'inscription
      const { data, error: authError } = await supabase.auth.setSession({
        access_token: finalAccessToken,
        refresh_token: finalRefreshToken
      })

      if (authError) {
        throw authError
      }

      if (data.user) {
        // Attendre un peu pour s'assurer que l'utilisateur est bien créé dans la base
        await new Promise(resolve => setTimeout(resolve, 2000))
        
        // Créer ou mettre à jour le profil utilisateur
        try {
          const profileData = {
            email: data.user.email,
            full_name: data.user.user_metadata?.full_name || data.user.user_metadata?.name || '',
            avatar_url: data.user.user_metadata?.avatar_url || null,
            onboarding_completed: false
          }
          
          await profileService.createOrUpdateProfile(data.user.id, profileData)
        } catch (profileError) {
          console.warn('Erreur lors de la création du profil:', profileError)
          // Ne pas faire échouer l'authentification si la création du profil échoue
        }
        
        success.value = true
        // Rediriger vers le dashboard après 2 secondes
        setTimeout(() => {
          router.push('/dashboard')
        }, 2000)
      }
    } else if (type === 'recovery' && finalAccessToken && finalRefreshToken) {
      // Récupération de mot de passe - rediriger vers la page de reset
      const { error: sessionError } = await supabase.auth.setSession({
        access_token: finalAccessToken,
        refresh_token: finalRefreshToken
      })

      if (sessionError) {
        throw sessionError
      }

      // Rediriger vers la page de reset password
      router.push('/reset-password')
    } else if (finalAccessToken && finalRefreshToken) {
      // Connexion OAuth (Google, Discord, etc.) - This is the main fix
      const { data, error: authError } = await supabase.auth.setSession({
        access_token: finalAccessToken,
        refresh_token: finalRefreshToken
      })

      if (authError) {
        throw authError
      }
      
      if (data.user) {
        // Attendre un peu pour s'assurer que l'utilisateur est bien créé
        await new Promise(resolve => setTimeout(resolve, 2000))
        
        // Vérifier si le profil existe, sinon le créer
        try {
          const { data: existingProfile } = await profileService.getProfile(data.user.id)
          
          if (!existingProfile) {
            const profileData = {
              email: data.user.email,
              full_name: data.user.user_metadata?.full_name || data.user.user_metadata?.name || '',
              avatar_url: data.user.user_metadata?.avatar_url || null,
              onboarding_completed: false
            }
            
            await profileService.createOrUpdateProfile(data.user.id, profileData)
          }
        } catch (profileError) {
          console.warn('Erreur lors de la gestion du profil:', profileError)
        }
        
        success.value = true
        setTimeout(() => {
          router.push('/dashboard')
        }, 2000)
      }
    } else if (window.location.hash.includes('access_token') || window.location.search.includes('access_token')) {
      // Handle OAuth callback without explicit type parameter
      // This often happens with Google/Discord OAuth
      try {
        // Let Supabase handle the OAuth callback automatically
        const { data, error: authError } = await supabase.auth.getSession()
        
        if (authError) {
          throw authError
        }
        
        if (data.session && data.session.user) {
          // Wait a bit to ensure user is properly created
          await new Promise(resolve => setTimeout(resolve, 2000))
          
          // Check if profile exists, create if needed
          try {
            const { data: existingProfile } = await profileService.getProfile(data.session.user.id)
            
            if (!existingProfile) {
              const profileData = {
                email: data.session.user.email,
                full_name: data.session.user.user_metadata?.full_name || data.session.user.user_metadata?.name || '',
                avatar_url: data.session.user.user_metadata?.avatar_url || null,
                onboarding_completed: false
              }
              
              await profileService.createOrUpdateProfile(data.session.user.id, profileData)
            }
          } catch (profileError) {
            console.warn('Erreur lors de la gestion du profil:', profileError)
          }
          
          success.value = true
          setTimeout(() => {
            router.push('/dashboard')
          }, 2000)
        } else {
          throw new Error('Session utilisateur non trouvée après OAuth')
        }
      } catch (oauthError) {
        console.error('Erreur OAuth:', oauthError)
        throw new Error('Erreur lors de la connexion OAuth')
      }
    } else {
      // Only throw error if we're sure this isn't a valid OAuth callback
      const hasAnyAuthParams = finalAccessToken || finalRefreshToken || 
                              window.location.hash.includes('access_token') || 
                              window.location.search.includes('code')
      
      if (!hasAnyAuthParams) {
        throw new Error('Paramètres de confirmation manquants ou invalides')
      } else {
        // Wait a moment and check if Supabase handled the OAuth automatically
        await new Promise(resolve => setTimeout(resolve, 1000))
        const { data } = await supabase.auth.getSession()
        
        if (data.session && data.session.user) {
          success.value = true
          setTimeout(() => {
            router.push('/dashboard')
          }, 1000)
        } else {
          throw new Error('Échec de la connexion OAuth')
        }
      }
    }
  } catch (err: any) {
    console.error('Erreur lors de la confirmation:', err)
    error.value = err.message || 'Une erreur est survenue lors de la confirmation'
  } finally {
    loading.value = false
  }
})
</script>