<template>
  <div id="app" class="dark min-h-screen transition-all duration-700 ease-in-out">
    <Navbar
      v-if="shouldShowNavbar"
      @open-auth="showAuthModal = true"
      @logout="handleLogout"
      :is-authenticated="isAuthenticated"
      :is-premium="isPremium"
    />
    <router-view @logout="handleLogout" />
    <Footer />

    <!-- Auth Modal -->
    <AuthModal
      v-if="showAuthModal"
      @close="showAuthModal = false"
      @success="handleAuthSuccess"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import Navbar from './components/Navbar.vue'
import Footer from './components/Footer.vue'
import AuthModal from './components/AuthModal.vue'
import { authService, profileService, supabase, type User } from './lib/supabase'
import { useAuth } from './composables/useAuth'
import { useTheme } from './composables/useTheme'

const router = useRouter()
const route = useRoute()
const { showAuthModal, closeAuthModal } = useAuth()
const { loadUserTheme, resetToDefaultTheme } = useTheme()

const shouldShowNavbar = computed(() => {
  // Only show the main Navbar if the current route is NOT the public portfolio route (/:slug)
  // The public portfolio route is defined as { path: '/:slug', component: PublicPortfolio }
  // We check if the first matched route's path is '/:slug'
  return route.matched.length > 0 && route.matched[0].path !== '/:slug'
})

const isAuthenticated = ref(false)
const currentUser = ref<User | null>(null)
const isPremium = ref(false)


const handleAuthSuccess = (user: User) => {
  currentUser.value = user
  isAuthenticated.value = true
  checkPremiumStatus(user.id)
  closeAuthModal()
  
  // Redirect to dashboard after successful login
  setTimeout(() => {
    router.push('/dashboard')
  }, 500)
}

const handleLogout = async () => {
  try {
    // Immediate UI state cleanup
    currentUser.value = null
    isAuthenticated.value = false
    isPremium.value = false
    
    // Reset theme to default
    resetToDefaultTheme()
    
    // Force immediate redirect to home page
    window.location.href = '/'
    
    // Sign out from Supabase in background (don't await)
    authService.signOut().catch(error => {
      console.error('Background logout error:', error)
    })
    
  } catch (error) {
    console.error('Logout error:', error)
    // Force cleanup even on error
    currentUser.value = null
    isAuthenticated.value = false
    isPremium.value = false
    resetToDefaultTheme()
    window.location.href = '/'
  }
}
// Check authentication status on app load
onMounted(() => {
  // Check if user is already authenticated
  checkAuthStatus()
  
  // Load user theme
  loadUserTheme()
  
  // Listen for auth state changes
  authService.onAuthStateChange((event, session) => {
    if (event === 'SIGNED_IN' && session?.user) {
      // Only update if not already set (avoid overriding immediate logout state)
      if (!isAuthenticated.value) {
      currentUser.value = session.user as User
      isAuthenticated.value = true
      }
      
      // Load user theme when signed in
      loadUserTheme()
      
      // Ensure profile exists
      if (profileService) {
        profileService.createOrUpdateProfile(session.user.id, {
          email: session.user.email || '',
          full_name: session.user.user_metadata?.full_name || '',
          formation: 'BUT GEII - Parcours AII',
          annee_etudes: '3'
        }).catch(async (error) => {
          console.error('Profile creation error:', error)
          
          // Check if user was deleted from database (foreign key constraint violation)
          if (error.code === '23503' || 
              (error.message && error.message.includes('foreign key constraint')) ||
              (error.details && error.details.includes('Key is not present in table "users"'))) {
            
            console.log('User deleted from database, signing out...')
            
            // Clear invalid session
            await authService.signOut()
            currentUser.value = null
            isAuthenticated.value = false
            
            // Redirect to home
            if (route.path !== '/') {
              router.push('/')
            }
          }
        })
      } else {
        console.warn('profileService is not available during auth state change')
      }
      
    } else if (event === 'SIGNED_OUT') {
      // Only update if not already cleared (avoid race conditions)
      if (isAuthenticated.value) {
        // Immediately redirect to home
        router.push('/')
        
        // Then clear state
        currentUser.value = null
        isAuthenticated.value = false
        isPremium.value = false
      }
    }
  })
})

const checkAuthStatus = async () => {
  const user = await authService.getCurrentUser()
  if (user) {
    currentUser.value = user as User
    isAuthenticated.value = true
    await checkPremiumStatus(user.id)
  } else {
    // Ensure we're not authenticated if no user
    currentUser.value = null
    isAuthenticated.value = false
    isPremium.value = false
  }
}

const checkPremiumStatus = async (userId: string) => {
  try {
    const { data: orders } = await supabase
      .from('stripe_orders')
      .select('*')
      .eq('status', 'completed')
      .limit(1)
    
    isPremium.value = !!(orders && orders.length > 0)
  } catch (error) {
    console.error('Error checking premium status:', error)
    isPremium.value = false
  }
}

// Protect dashboard route
watch(() => route.path, (newPath) => {
  // Only redirect if we're sure the user is not authenticated
  // Wait for auth check to complete before redirecting
  if (newPath === '/dashboard') {
    // Give time for auth state to be determined
    setTimeout(() => {
      if (!isAuthenticated.value) {
        router.push('/')
        closeAuthModal()
        setTimeout(() => {
          showAuthModal.value = true
        }, 100)
      }
    }, 500) // Wait 500ms for auth state to be determined
  }
})
</script>
