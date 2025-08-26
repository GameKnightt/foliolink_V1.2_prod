import { ref } from 'vue'

// État global pour le modal d'authentification
const showAuthModal = ref(false)

export function useAuth() {
  const openAuthModal = () => {
    showAuthModal.value = true
  }

  const closeAuthModal = () => {
    showAuthModal.value = false
  }

  return {
    showAuthModal,
    openAuthModal,
    closeAuthModal
  }
}