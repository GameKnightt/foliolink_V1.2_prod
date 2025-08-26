import { ref, computed, watch } from 'vue'
import { authService, premiumService, supabase } from '../lib/supabase'

interface UserLimits {
  isPremium: boolean
  limits: {
    competences: number
    apprentissages: number
    projets: number
  }
  current: {
    competences: number
    apprentissages: number
    projets: number
  }
}

export function useUserLimits() {
  const userLimits = ref<UserLimits | null>(null)
  const loading = ref(false)
  const initialLoading = ref(true)
  const listeners = ref(new Set<() => void>())

  const loadUserLimits = async () => {
    if (!initialLoading.value) {
      loading.value = true
    }
    try {
      const user = await authService.getCurrentUser()
      if (!user) {
        userLimits.value = null
        return
      }

      const userId = user.id
      
      // Check premium status first for faster loading
      const { data: orders } = await supabase
        .from('stripe_orders')
        .select('*')
        .eq('status', 'completed')
        .limit(1)
      
      const isPremium = !!(orders && orders.length > 0)
      
      // Get current counts
      const [apprentissagesResult, projetsResult, competencesResult] = await Promise.all([
        premiumService.getUserApprentissagesCount(userId),
        premiumService.getUserProjetsCount(userId),
        premiumService.getUserCompetencesCount(userId)
      ])
      
      userLimits.value = {
        isPremium,
        limits: {
          competences: 3,
          apprentissages: 5,
          projets: 3
        },
        current: {
          competences: competencesResult,
          apprentissages: apprentissagesResult,
          projets: projetsResult
        }
      }
    } catch (error) {
      console.error('Error loading user limits:', error)
      // Set default values to avoid blocking UI
      userLimits.value = {
        isPremium: false,
        limits: { competences: 3, apprentissages: 5, projets: 3 },
        current: { competences: 0, apprentissages: 0, projets: 0 }
      }
    } finally {
      loading.value = false
      initialLoading.value = false
    }
  }

  const canCreate = computed(() => {
    if (!userLimits.value) return { competences: false, apprentissages: false, projets: false }
    
    if (userLimits.value.isPremium) {
      return { competences: true, apprentissages: true, projets: true }
    }
    
    return {
      competences: userLimits.value.current.competences < userLimits.value.limits.competences,
      apprentissages: userLimits.value.current.apprentissages < userLimits.value.limits.apprentissages,
      projets: userLimits.value.current.projets < userLimits.value.limits.projets
    }
  })

  const incrementCount = (type: 'competences' | 'apprentissages' | 'projets') => {
    if (userLimits.value) {
      userLimits.value.current[type]++
      // Notify all listeners of the update
      listeners.value.forEach(listener => listener())
    }
  }

  const incrementCountBy = (type: 'competences' | 'apprentissages' | 'projets', amount: number) => {
    if (userLimits.value) {
      userLimits.value.current[type] += amount
      // Notify all listeners of the update
      listeners.value.forEach(listener => listener())
    }
  }

  const decrementCount = (type: 'competences' | 'apprentissages' | 'projets') => {
    if (userLimits.value && userLimits.value.current[type] > 0) {
      userLimits.value.current[type]--
      // Notify all listeners of the update
      listeners.value.forEach(listener => listener())
    }
  }

  const decrementCountBy = (type: 'competences' | 'apprentissages' | 'projets', amount: number) => {
    if (userLimits.value) {
      userLimits.value.current[type] = Math.max(0, userLimits.value.current[type] - amount)
      // Notify all listeners of the update
      listeners.value.forEach(listener => listener())
    }
  }
  const checkLimit = (type: 'competences' | 'apprentissages' | 'projets'): boolean => {
    if (!userLimits.value) return false
    if (userLimits.value.isPremium) return true
    return userLimits.value.current[type] < userLimits.value.limits[type]
  }

  const getLimitInfo = (type: 'competences' | 'apprentissages' | 'projets') => {
    if (!userLimits.value) return { current: 0, max: 0, canCreate: false }
    
    return {
      current: userLimits.value.current[type],
      max: userLimits.value.limits[type],
      canCreate: userLimits.value.isPremium || userLimits.value.current[type] < userLimits.value.limits[type]
    }
  }

  const addListener = (listener: () => void) => {
    listeners.value.add(listener)
    return () => listeners.value.delete(listener)
  }
  return {
    userLimits,
    loading,
    loadUserLimits,
    canCreate,
    incrementCount,
    incrementCountBy,
    decrementCount,
    decrementCountBy,
    checkLimit,
    getLimitInfo,
    addListener
  }
}

export function usePremiumLimits() {
  return useUserLimits()
}