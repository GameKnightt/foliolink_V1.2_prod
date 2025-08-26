import { ref, watch } from 'vue'
import { profileService, authService } from '../lib/supabase'

const currentTheme = ref('dark')
const isLoading = ref(false)
const isUserLoggedIn = ref(false)

const availableThemes = [
  { 
    name: 'dark', 
    label: 'Sombre', 
    icon: '🌙',
    description: 'Thème sombre classique'
  },
  { 
    name: 'light', 
    label: 'Clair', 
    icon: '☀️',
    description: 'Thème clair et lumineux'
  },
  { 
    name: 'blue', 
    label: 'Bleu', 
    icon: '🌊',
    description: 'Thème bleu océan'
  },
  { 
    name: 'green', 
    label: 'Vert', 
    icon: '🌿',
    description: 'Thème vert nature'
  },
  { 
    name: 'purple', 
    label: 'Violet', 
    icon: '🔮',
    description: 'Thème violet mystique'
  },
  { 
    name: 'orange', 
    label: 'Orange', 
    icon: '🔥',
    description: 'Thème orange chaleureux'
  }
]

export function useTheme() {
  const applyTheme = (themeName: string) => {
    const htmlElement = document.documentElement
    
    // Remove all existing theme classes
    availableThemes.forEach(theme => {
      htmlElement.classList.remove(`theme-${theme.name}`)
    })
    
    // Add new theme class (except for dark which is the default)
    if (themeName !== 'dark') {
      htmlElement.classList.add(`theme-${themeName}`)
    }
    
    // Handle Tailwind's dark mode class
    if (themeName === 'light') {
      htmlElement.classList.remove('dark')
    } else {
      htmlElement.classList.add('dark')
    }
    
    currentTheme.value = themeName
    
    // Only store in localStorage if user is logged in
    if (isUserLoggedIn.value) {
      localStorage.setItem('user-theme', themeName)
    }
    
    // Force a repaint to ensure theme is applied immediately
    document.body.style.display = 'none'
    document.body.offsetHeight // Trigger reflow
    document.body.style.display = ''
  }

  const applyDefaultTheme = () => {
    // Always apply dark theme for non-authenticated users
    applyTheme('dark')
    // Clear any stored user theme
    localStorage.removeItem('user-theme')
  }

  const saveTheme = async (themeName: string) => {
    const user = await authService.getCurrentUser()
    if (user) {
      isUserLoggedIn.value = true
      try {
        isLoading.value = true
        await profileService.updateProfile(user.id, { theme: themeName })
        console.log(`Thème '${themeName}' sauvegardé pour l'utilisateur ${user.id}`)
      } catch (error) {
        console.error('Erreur lors de la sauvegarde du thème:', error)
        // Fallback to localStorage if database save fails
        localStorage.setItem('user-theme', themeName)
      } finally {
        isLoading.value = false
      }
    } else {
      // For non-authenticated users, don't save theme changes
      isUserLoggedIn.value = false
      console.log('Thème non sauvegardé : utilisateur non connecté')
    }
  }

  const loadUserTheme = async () => {
    const user = await authService.getCurrentUser()
    
    if (user) {
      isUserLoggedIn.value = true
      try {
        const { data: profile } = await profileService.getProfile(user.id)
        if (profile && profile.theme) {
          applyTheme(profile.theme)
          return
        }
      } catch (error) {
        console.error('Erreur lors du chargement du thème utilisateur:', error)
      }
      
      // Fallback to localStorage for authenticated users
      const savedTheme = localStorage.getItem('user-theme')
      if (savedTheme && availableThemes.some(t => t.name === savedTheme)) {
        applyTheme(savedTheme)
      } else {
        // Default theme for authenticated users
        applyTheme('dark')
      }
    } else {
      // For non-authenticated users, always use default theme
      isUserLoggedIn.value = false
      applyDefaultTheme()
    }
  }

  const changeTheme = async (themeName: string) => {
    if (!availableThemes.some(t => t.name === themeName)) {
      console.error(`Thème '${themeName}' non disponible`)
      return
    }
    
    // Only allow theme changes for authenticated users
    const user = await authService.getCurrentUser()
    if (!user) {
      console.log('Changement de thème refusé : utilisateur non connecté')
      return
    }
    
    applyTheme(themeName)
    await saveTheme(themeName)
  }

  const resetToDefaultTheme = () => {
    isUserLoggedIn.value = false
    applyDefaultTheme()
  }

  const getThemeInfo = (themeName: string) => {
    return availableThemes.find(t => t.name === themeName)
  }

  return {
    currentTheme,
    availableThemes,
    isLoading,
    isUserLoggedIn,
    applyTheme,
    applyDefaultTheme,
    saveTheme,
    loadUserTheme,
    changeTheme,
    resetToDefaultTheme,
    getThemeInfo
  }
}