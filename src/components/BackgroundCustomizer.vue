<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <h4 class="text-lg font-semibold text-white">Arrière-plan du Portfolio</h4>
      <div v-if="saving" class="text-accent-400 text-sm">
        <span class="animate-spin mr-1">⏳</span>
        Sauvegarde...
      </div>
    </div>
    
    <p class="text-gray-300 text-sm">
      Personnalisez l'arrière-plan de votre portfolio public.
    </p>
    
    <!-- Background Type Selection -->
    <div class="space-y-4">
      <label class="block text-sm font-medium text-gray-300">Type d'arrière-plan</label>
      <div class="grid grid-cols-2 md:grid-cols-4 gap-3">
        <button
          v-for="type in backgroundTypes"
          :key="type.value"
          type="button"
          @click.stop="selectType(type.value)"
          :disabled="saving"
          class="p-3 rounded-lg border-2 transition-all duration-300 hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed text-center"
          :class="[
            selectedType === type.value 
              ? 'border-accent-400 bg-accent-400/10' 
              : 'border-white/20 bg-white/5 hover:border-accent-400/50'
          ]"
        >
          <div class="text-2xl mb-1">{{ type.icon }}</div>
          <div class="text-white text-sm font-medium">{{ type.label }}</div>
        </button>
      </div>
    </div>

    <!-- Image Upload Section -->
    <div v-if="selectedType === 'image'" class="space-y-4">
      <label class="block text-sm font-medium text-gray-300">Image personnalisée</label>
      
      <!-- Current Image Preview -->
      <div v-if="currentImageUrl" class="relative">
        <div class="w-full h-32 rounded-lg overflow-hidden border border-white/20">
          <img 
            :src="currentImageUrl" 
            alt="Arrière-plan actuel" 
            class="w-full h-full object-cover"
          />
        </div>
        <button 
          type="button"
          @click.stop="removeImage"
          :disabled="saving"
          class="absolute top-2 right-2 bg-red-500 hover:bg-red-600 text-white p-1 rounded text-xs transition-colors disabled:opacity-50"
        >
          ✕
        </button>
      </div>
      
      <!-- Upload Area -->
      <div class="border-2 border-dashed border-white/20 rounded-lg p-6 text-center">
        <input
          ref="fileInputRef"
          type="file"
          accept="image/jpeg,image/png,image/webp"
          @change="handleImageUpload"
          class="hidden"
        />
        
        <div class="space-y-3">
          <div class="text-4xl">📸</div>
          <button 
            type="button"
            @click.stop="triggerFileInput"
            :disabled="uploading || saving"
            class="btn-primary disabled:opacity-50"
          >
            <span v-if="uploading" class="mr-2">⏳</span>
            <span v-else class="mr-2">📁</span>
            {{ uploading ? 'Upload...' : 'Choisir une image' }}
          </button>
          <p class="text-gray-400 text-xs">
            JPG, PNG ou WebP • Maximum 5MB
          </p>
        </div>
      </div>
    </div>

    <!-- Gradient Selection -->
    <div v-if="selectedType === 'gradient'" class="space-y-4">
      <label class="block text-sm font-medium text-gray-300">Dégradé prédéfini</label>
      <div class="grid grid-cols-2 md:grid-cols-3 gap-3">
        <button
          v-for="gradient in gradientOptions"
          :key="gradient.name"
          type="button"
          @click.stop="selectGradient(gradient.value)"
          :disabled="saving"
          class="h-16 rounded-lg border-2 transition-all duration-300 hover:scale-105 disabled:opacity-50"
          :class="[
            selectedGradient === gradient.value
              ? 'border-accent-400'
              : 'border-white/20 hover:border-accent-400/50'
          ]"
          :style="{ background: gradient.value }"
        >
          <div v-if="selectedGradient === gradient.value" class="w-full h-full flex items-center justify-center">
            <span class="text-white text-lg drop-shadow-lg">✓</span>
          </div>
        </button>
      </div>
    </div>

    <!-- Solid Color Selection -->
    <div v-if="selectedType === 'solid'" class="space-y-4">
      <label class="block text-sm font-medium text-gray-300">Couleur unie</label>
      <div class="grid grid-cols-5 md:grid-cols-8 gap-2">
        <button
          v-for="color in colorOptions"
          :key="color.name"
          type="button"
          @click.stop="selectColor(color.value)"
          :disabled="saving"
          class="w-10 h-10 rounded-lg border-2 transition-all duration-300 hover:scale-105 disabled:opacity-50"
          :class="[
            selectedColor === color.value
              ? 'border-accent-400'
              : 'border-white/20 hover:border-accent-400/50'
          ]"
          :style="{ backgroundColor: color.value }"
        >
          <div v-if="selectedColor === color.value" class="w-full h-full flex items-center justify-center">
            <span class="text-white text-sm drop-shadow-lg">✓</span>
          </div>
        </button>
      </div>
    </div>

    <!-- Preview -->
    <div class="bg-white/5 border border-white/10 rounded-lg p-4">
      <div class="flex items-center space-x-3 mb-3">
        <span class="text-xl">👁️</span>
        <h5 class="text-white font-medium">Aperçu</h5>
      </div>
      <div 
        class="w-full h-24 rounded-lg border border-white/20 relative overflow-hidden"
        :style="previewStyle"
      >
        <div class="absolute inset-0 flex items-center justify-center bg-black/20">
          <span class="text-white text-sm font-medium drop-shadow-lg">Votre Portfolio</span>
        </div>
      </div>
    </div>

    <!-- Messages -->
    <div v-if="errorMessage" class="p-3 bg-red-500/20 border border-red-500/30 rounded-lg">
      <p class="text-red-200 text-sm">{{ errorMessage }}</p>
    </div>

    <div v-if="successMessage" class="p-3 bg-green-500/20 border border-green-500/30 rounded-lg">
      <p class="text-green-200 text-sm">{{ successMessage }}</p>
    </div>

    <!-- Save Button -->
    <div class="bg-blue-50 dark:bg-blue-900/20 rounded-lg p-4">
      <div class="flex items-center mb-2">
        <span class="text-blue-400 mr-2">💡</span>
        <h5 class="text-blue-900 dark:text-blue-100 font-medium text-sm">Information</h5>
      </div>
      <p class="text-blue-800 dark:text-blue-200 text-sm">
        Les modifications d'arrière-plan seront sauvegardées avec le reste de votre profil 
        lorsque vous cliquerez sur "Sauvegarder" en bas de la fenêtre.
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { backgroundService, authService, profileService } from '../lib/supabase'

// Props
defineProps<{
  isPremium?: boolean
}>()

// State
const saving = ref(false)
const uploading = ref(false)
const errorMessage = ref('')
const successMessage = ref('')

// Form data
const selectedType = ref<'default' | 'image' | 'gradient' | 'solid'>('default')
const currentImageUrl = ref('')
const selectedGradient = ref('')
const selectedColor = ref('')

// Original values for comparison
const originalType = ref<'default' | 'image' | 'gradient' | 'solid'>('default')
const originalImageUrl = ref('')
const originalGradient = ref('')
const originalColor = ref('')

// File input ref
const fileInputRef = ref<HTMLInputElement>()

// Options
const backgroundTypes = [
  { value: 'default', label: 'Défaut', icon: '🌌' },
  { value: 'image', label: 'Image', icon: '🖼️' },
  { value: 'gradient', label: 'Dégradé', icon: '🌈' },
  { value: 'solid', label: 'Couleur', icon: '🎨' }
]

const gradientOptions = [
  { name: 'Océan', value: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)' },
  { name: 'Coucher', value: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)' },
  { name: 'Forêt', value: 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)' },
  { name: 'Aurore', value: 'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)' },
  { name: 'Mystique', value: 'linear-gradient(135deg, #fa709a 0%, #fee140 100%)' },
  { name: 'Pro', value: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)' }
]

const colorOptions = [
  { name: 'Bleu', value: '#1e3a8a' },
  { name: 'Violet', value: '#7c3aed' },
  { name: 'Vert', value: '#059669' },
  { name: 'Rouge', value: '#dc2626' },
  { name: 'Orange', value: '#ea580c' },
  { name: 'Rose', value: '#e11d48' },
  { name: 'Indigo', value: '#4f46e5' },
  { name: 'Teal', value: '#0d9488' },
  { name: 'Gris', value: '#374151' },
  { name: 'Noir', value: '#111827' }
]

// Computed
const hasChanges = computed(() => {
  return selectedType.value !== originalType.value ||
         currentImageUrl.value !== originalImageUrl.value ||
         selectedGradient.value !== originalGradient.value ||
         selectedColor.value !== originalColor.value
})

const previewStyle = computed(() => {
  switch (selectedType.value) {
    case 'image':
      return currentImageUrl.value 
        ? { backgroundImage: `url(${currentImageUrl.value})`, backgroundSize: 'cover', backgroundPosition: 'center' }
        : { background: 'linear-gradient(135deg, #1f2937 0%, #111827 100%)' }
    
    case 'gradient':
      return selectedGradient.value 
        ? { background: selectedGradient.value }
        : { background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)' }
    
    case 'solid':
      return selectedColor.value 
        ? { backgroundColor: selectedColor.value }
        : { backgroundColor: '#1e3a8a' }
    
    default:
      return { background: 'linear-gradient(135deg, #1f2937 0%, #111827 100%)' }
  }
})

// Methods
onMounted(async () => {
  await loadCurrentSettings()
})

const loadCurrentSettings = async () => {
  try {
    const user = await authService.getCurrentUser()
    if (!user) return

    const { data: profile } = await profileService.getProfile(user.id)
    if (profile) {
      selectedType.value = profile.background_type || 'default'
      currentImageUrl.value = profile.background_url || ''
      
      if (profile.background_settings) {
        selectedGradient.value = profile.background_settings.gradient || ''
        selectedColor.value = profile.background_settings.color || ''
      }
      
      // Save original values
      originalType.value = selectedType.value
      originalImageUrl.value = currentImageUrl.value
      originalGradient.value = selectedGradient.value
      originalColor.value = selectedColor.value
    }
  } catch (error) {
    console.error('Error loading background settings:', error)
  }
}

const selectType = (type: 'default' | 'image' | 'gradient' | 'solid') => {
  clearMessages()
  selectedType.value = type
  
  // Reset other selections when changing type
  if (type !== 'image') {
    currentImageUrl.value = ''
  }
  if (type !== 'gradient') {
    selectedGradient.value = ''
  }
  if (type !== 'solid') {
    selectedColor.value = ''
  }
}

const selectGradient = (gradient: string) => {
  clearMessages()
  selectedGradient.value = gradient
}

const selectColor = (color: string) => {
  clearMessages()
  selectedColor.value = color
}

const triggerFileInput = () => {
  if (fileInputRef.value) {
    fileInputRef.value.click()
  }
}

const handleImageUpload = async (event: Event) => {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]
  
  if (!file) return
  
  // Validation
  if (!['image/jpeg', 'image/png', 'image/webp'].includes(file.type)) {
    errorMessage.value = 'Format non supporté. Utilisez JPG, PNG ou WebP.'
    return
  }
  
  if (file.size > 5 * 1024 * 1024) {
    errorMessage.value = 'Fichier trop volumineux. Maximum 5MB.'
    return
  }
  
  uploading.value = true
  clearMessages()
  
  try {
    const user = await authService.getCurrentUser()
    if (!user) throw new Error('Utilisateur non connecté')

    const { data, error: uploadError } = await backgroundService.uploadBackground(user.id, file)
    
    if (uploadError) {
      errorMessage.value = uploadError.message
    } else if (data) {
      currentImageUrl.value = data.url
      successMessage.value = 'Image uploadée avec succès !'
      setTimeout(() => { successMessage.value = '' }, 3000)
    }
  } catch (error: any) {
    errorMessage.value = error.message || 'Erreur lors de l\'upload'
  } finally {
    uploading.value = false
  }
}

const removeImage = () => {
  currentImageUrl.value = ''
  selectedType.value = 'default'
  clearMessages()
}

const saveBackground = async () => {
  if (!hasChanges.value) {
    errorMessage.value = 'Aucune modification à sauvegarder'
    return
  }
  
  saving.value = true
  clearMessages()
  
  try {
    const user = await authService.getCurrentUser()
    if (!user) throw new Error('Utilisateur non connecté')

    // Prepare background data
    const backgroundData = {
      background_type: selectedType.value,
      background_url: selectedType.value === 'image' ? currentImageUrl.value : null,
      background_settings: {}
    }
    
    if (selectedType.value === 'gradient' && selectedGradient.value) {
      backgroundData.background_settings = { gradient: selectedGradient.value }
    } else if (selectedType.value === 'solid' && selectedColor.value) {
      backgroundData.background_settings = { color: selectedColor.value }
    }

    const { error: updateError } = await backgroundService.updateProfileBackground(user.id, backgroundData)

    if (updateError) {
      errorMessage.value = updateError.message || 'Erreur lors de la sauvegarde'
    } else {
      successMessage.value = 'Arrière-plan sauvegardé avec succès !'
      
      // Update original values
      originalType.value = selectedType.value
      originalImageUrl.value = currentImageUrl.value
      originalGradient.value = selectedGradient.value
      originalColor.value = selectedColor.value
      
      // Force reload of the page to apply background changes immediately
      setTimeout(() => {
        window.location.reload()
      }, 1500)
      
      // Clear success message after 3 seconds
      setTimeout(() => { successMessage.value = '' }, 3000)
    }
  } catch (error: any) {
    errorMessage.value = error.message || 'Erreur lors de la sauvegarde'
  } finally {
    saving.value = false
  }
}

const clearMessages = () => {
  errorMessage.value = ''
  successMessage.value = ''
}

// Expose methods for parent component
const getSelectedType = () => selectedType.value
const getCurrentImageUrl = () => currentImageUrl.value
const getBackgroundSettings = () => {
  const settings: any = {}
  if (selectedType.value === 'gradient' && selectedGradient.value) {
    settings.gradient = selectedGradient.value
  } else if (selectedType.value === 'solid' && selectedColor.value) {
    settings.color = selectedColor.value
  }
  return settings
}

// Expose methods to parent
defineExpose({
  getSelectedType,
  getCurrentImageUrl,
  getBackgroundSettings,
  saveBackground
})
</script>