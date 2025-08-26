<template>
  <div class="fixed inset-0 z-50 overflow-y-auto">
    <div class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
      <!-- Background overlay -->
      <div 
        class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity backdrop-blur-sm"
        @click.self="$emit('close')"
      ></div>

      <!-- Modal -->
      <div class="inline-block align-bottom glass-card text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-4xl sm:w-full max-h-[90vh] overflow-y-auto">
        <!-- Header -->
        <div class="bg-white/10 dark:bg-gray-800/50 px-6 py-4 border-b border-white/20 dark:border-gray-600/30">
          <div class="flex items-center justify-between">
            <h3 class="text-lg font-semibold text-white">
              Mon Profil
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
        <div class="px-6 py-6 max-h-[70vh] overflow-y-auto">
          <form @submit.prevent="handleSubmit" class="space-y-6">
            <!-- Profile Picture -->
            <div class="text-center">
              <div class="relative inline-block">
                <div v-if="form.avatarUrl" class="w-24 h-24 rounded-full overflow-hidden mx-auto mb-4 border-4 border-accent-400/50">
                  <img :src="form.avatarUrl" :alt="form.fullName" class="w-full h-full object-cover" />
                </div>
                <div v-else class="w-24 h-24 bg-gradient-to-r from-accent-400 to-accent-500 rounded-full flex items-center justify-center mx-auto mb-4 border-4 border-accent-400/50">
                  <span class="text-2xl text-gray-900 font-bold">
                    {{ getInitials(form.fullName) }}
                  </span>
                </div>
                <input
                  ref="fileInput"
                  type="file"
                  accept="image/jpeg,image/png"
                  @change="handleFileUpload"
                  class="hidden"
                />
              </div>
              <button 
                type="button"
                @click="$refs.fileInput.click()"
                :disabled="uploading"
                class="text-accent-400 hover:text-accent-300 text-sm transition-colors"
              >
                {{ uploading ? 'Upload...' : 'Changer la photo' }}
              </button>
              <p class="text-xs text-gray-400 mt-1">JPG/PNG max 5MB</p>
            </div>

            <!-- Personal Information -->
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
              <div>
                <label class="block text-sm font-medium text-gray-300 mb-2">
                  Nom complet
                </label>
                <div class="relative">
                <input
                  v-model="form.fullName"
                  type="text"
                  maxlength="100"
                  class="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-400 focus:ring-2 focus:ring-accent-400 focus:border-accent-400 transition-colors backdrop-blur-xl"
                  placeholder="Votre nom complet"
                />
                <div class="absolute right-3 top-1/2 transform -translate-y-1/2 text-xs text-gray-400">
                  {{ form.fullName.length }}/100
                </div>
                </div>
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-300 mb-2">
                  Email
                </label>
                <div class="flex flex-col sm:flex-row space-y-2 sm:space-y-0 sm:space-x-2">
                  <input
                    v-model="form.email"
                    type="email"
                    class="flex-1 px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-400 focus:ring-2 focus:ring-accent-400 focus:border-accent-400 transition-colors backdrop-blur-xl w-full sm:w-auto"
                    placeholder="votre@email.com"
                  />
                  <button
                    type="button"
                    @click="requestEmailChange"
                    :disabled="emailChangeLoading"
                    class="px-4 py-3 bg-accent-500 hover:bg-accent-600 text-gray-900 font-semibold rounded-xl transition-all duration-300 disabled:opacity-50 whitespace-nowrap"
                  >
                    {{ emailChangeLoading ? '...' : 'Changer' }}
                  </button>
                </div>
                <p class="text-xs text-gray-400 mt-1">Un email de confirmation sera envoyé</p>
              </div>
            </div>

            <!-- Password Change Section -->
            <div class="space-y-4">
              <h4 class="text-lg font-semibold text-white">Sécurité du Compte</h4>
              
              <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-gray-300 mb-2">
                    Nouveau mot de passe
                  </label>
                  <input
                    v-model="form.newPassword"
                    type="password"
                    minlength="12"
                    class="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-400 focus:ring-2 focus:ring-accent-400 focus:border-accent-400 transition-colors backdrop-blur-xl"
                    placeholder="Nouveau mot de passe (min. 12 caractères)"
                  />
                </div>

                <div>
                  <label class="block text-sm font-medium text-gray-300 mb-2">
                    Confirmer le mot de passe
                  </label>
                  <input
                    v-model="form.confirmPassword"
                    type="password"
                    minlength="12"
                    class="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-400 focus:ring-2 focus:ring-accent-400 focus:border-accent-400 transition-colors backdrop-blur-xl"
                    placeholder="Confirmer le mot de passe"
                  />
                </div>
              </div>

              <div class="flex flex-col sm:flex-row space-y-2 sm:space-y-0 sm:space-x-3">
                <button
                  type="button"
                  @click="updatePassword"
                  :disabled="passwordChangeLoading || !form.newPassword || form.newPassword !== form.confirmPassword"
                  class="btn-secondary disabled:opacity-50 disabled:cursor-not-allowed flex-1 sm:flex-none"
                >
                  {{ passwordChangeLoading ? 'Mise à jour...' : 'Changer le mot de passe' }}
                </button>
                
                <button
                  type="button"
                  @click="resetPassword"
                  :disabled="resetPasswordLoading"
                  class="text-accent-400 hover:text-accent-300 text-sm transition-colors disabled:opacity-50 text-center sm:text-left"
                >
                  {{ resetPasswordLoading ? 'Envoi...' : 'Mot de passe oublié ?' }}
                </button>
              </div>
            </div>
            <!-- Professional Information -->
            <div class="space-y-4">
              <h4 class="text-lg font-semibold text-white">Informations Professionnelles</h4>
              
              <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-gray-300 mb-2">
                    Formation
                  </label>
                  <div class="relative">
                  <input
                    v-model="form.formation"
                    type="text"
                    maxlength="100"
                    class="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-400 focus:ring-2 focus:ring-accent-400 focus:border-accent-400 transition-colors backdrop-blur-xl"
                   placeholder="Votre BUT + Votre Parcours"
                  />
                  <div class="absolute right-3 top-1/2 transform -translate-y-1/2 text-xs text-gray-400">
                    {{ form.formation.length }}/100
                  </div>
                  </div>
                </div>

                <div>
                  <label class="block text-sm font-medium text-gray-300 mb-2">
                    Année d'études
                  </label>
                  <select
                    v-model="form.anneeEtudes"
                    class="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white focus:ring-2 focus:ring-accent-400 focus:border-accent-400 transition-colors backdrop-blur-xl appearance-none cursor-pointer select-dark"
                  >
                    <option value="1">1ère année</option>
                    <option value="2">2ème année</option>
                    <option value="3">3ème année</option>
                  </select>
                </div>
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-300 mb-2">
                  Établissement
                </label>
                <div class="relative">
                <input
                  v-model="form.etablissement"
                  type="text"
                  maxlength="100"
                  class="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-400 focus:ring-2 focus:ring-accent-400 focus:border-accent-400 transition-colors backdrop-blur-xl"
                  placeholder="Nom de votre établissement"
                />
                <div class="absolute right-3 top-1/2 transform -translate-y-1/2 text-xs text-gray-400">
                  {{ form.etablissement.length }}/100
                </div>
                </div>
              </div>
            </div>

            <!-- Contact Information -->
            <div class="space-y-4">
              <h4 class="text-lg font-semibold text-white">Informations de Contact</h4>
              
              <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-gray-300 mb-2">
                    Téléphone
                  </label>
                  <input
                    v-model="form.telephone"
                    type="tel"
                    class="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-400 focus:ring-2 focus:ring-accent-400 focus:border-accent-400 transition-colors backdrop-blur-xl"
                    placeholder="+33 6 12 34 56 78"
                  />
                </div>

                <div>
                  <label class="block text-sm font-medium text-gray-300 mb-2">
                    LinkedIn
                  </label>
                  <input
                    v-model="form.linkedin"
                    type="url"
                    class="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-400 focus:ring-2 focus:ring-accent-400 focus:border-accent-400 transition-colors backdrop-blur-xl"
                    placeholder="https://linkedin.com/in/votre-profil"
                  />
                </div>
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-300 mb-2">
                  GitHub
                </label>
                <input
                  v-model="form.github"
                  type="url"
                  class="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-400 focus:ring-2 focus:ring-accent-400 focus:border-accent-400 transition-colors backdrop-blur-xl"
                  placeholder="https://github.com/votre-username"
                />
              </div>
            </div>

            <!-- Bio -->
            <div>
              <label class="block text-sm font-medium text-gray-300 mb-2">
                Présentation personnelle
              </label>
              <div class="relative">
              <textarea
                v-model="form.bio"
                rows="4"
                maxlength="500"
                class="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-400 focus:ring-2 focus:ring-accent-400 focus:border-accent-400 transition-colors backdrop-blur-xl resize-none"
                placeholder="Présentez-vous en quelques lignes..."
              ></textarea>
              <div class="absolute right-3 bottom-3 text-xs text-gray-400">
                {{ form.bio.length }}/500
              </div>
              </div>
            </div>

            <!-- Public Portfolio Settings Info -->
            <div class="bg-blue-500/10 border border-blue-400/30 rounded-lg p-4">
              <div class="flex items-center mb-2">
                <span class="text-blue-400 mr-2">🌐</span>
                <h4 class="text-white font-medium">Partage Public</h4>
              </div>
              <p class="text-blue-200 text-sm mb-3">
                Configurez le partage public de votre portfolio depuis la section "Partage Public" du Dashboard.
              </p>
              <div class="text-xs text-blue-300">
                💡 Créez un lien personnalisé pour partager votre portfolio avec des employeurs ou maîtres de stage
              </div>
            </div>
            
            <!-- Theme Customization -->
            <div>
              <ThemeSwitcher />
            </div>
            
            <!-- Background Customization -->
            <div>
              <BackgroundCustomizer ref="backgroundCustomizerRef" :isPremium="isPremium" />
            </div>
            
            <!-- Error/Success Messages -->
            <div v-if="error" class="p-3 bg-red-500/20 border border-red-500/30 rounded-lg">
              <p class="text-red-200 text-sm">{{ error }}</p>
            </div>

            <div v-if="success" class="p-3 bg-green-500/20 border border-green-500/30 rounded-lg">
              <p class="text-green-200 text-sm">{{ success }}</p>
            </div>
          </form>
        </div>

        <!-- Footer -->
        <div class="bg-white/10 dark:bg-gray-800/50 px-6 py-4 border-t border-white/20 dark:border-gray-600/30 flex flex-col sm:flex-row justify-end space-y-2 sm:space-y-0 sm:space-x-3">
          <button 
            @click="$emit('close')"
            class="btn-secondary order-2 sm:order-1"
          >
            Annuler
          </button>
          <button 
            @click="handleSubmit"
            :disabled="loading"
            class="btn-primary disabled:opacity-50 disabled:cursor-not-allowed order-1 sm:order-2"
          >
            <span v-if="loading" class="mr-2">⏳</span>
            <span v-else class="mr-2">💾</span>
            {{ loading ? 'Sauvegarde...' : 'Sauvegarder' }}
          </button>
        </div>
      </div>
    </div>
  </div>

  <!-- Success Modal -->
  <SuccessModal
    v-if="showSuccessModal"
    :title="successModalData.title"
    :message="successModalData.message"
    @close="closeSuccessModal"
  />
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { XMarkIcon } from '@heroicons/vue/24/outline'
import { profileService, authService, storageService, supabase, type User } from '../lib/supabase'
import SuccessModal from './SuccessModal.vue'
import ThemeSwitcher from './ThemeSwitcher.vue'
import BackgroundCustomizer from './BackgroundCustomizer.vue'

const props = defineProps<{
  user: User | null
  isPremium?: boolean
}>()

const emit = defineEmits(['save', 'close'])

const loading = ref(false)
const emailChangeLoading = ref(false)
const passwordChangeLoading = ref(false)
const resetPasswordLoading = ref(false)
const uploading = ref(false)
const error = ref('')
const success = ref('')
const showSuccessModal = ref(false)
const successModalData = ref({ title: '', message: '' })

// Ref pour accéder aux données du BackgroundCustomizer
const backgroundCustomizerRef = ref<any>(null)

const form = ref({
  fullName: '',
  email: '',
  avatarUrl: '',
  newPassword: '',
  confirmPassword: '',
  formation: 'BUT GEII - Parcours AII',
  anneeEtudes: '3',
  etablissement: '',
  telephone: '',
  linkedin: '',
  github: '',
  bio: '',
})

onMounted(() => {
  if (props.user) {
    form.value.fullName = props.user.user_metadata?.full_name || ''
    form.value.email = props.user.email || ''
    
    // Charger le profil complet depuis la base de données
    loadProfile()
  }
})

const getInitials = (name: string) => {
  if (!name) return '??'
  return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)
}

const handleFileUpload = async (event: Event) => {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]
  
  if (!file || !props.user) return
  
  // Validation
  if (!['image/jpeg', 'image/png'].includes(file.type)) {
    error.value = 'Format non supporté. Utilisez JPG ou PNG.'
    return
  }
  
  if (file.size > 5 * 1024 * 1024) {
    error.value = 'Fichier trop volumineux. Maximum 5MB.'
    return
  }
  
  uploading.value = true
  error.value = ''
  
  try {
    const { data, error: uploadError } = await storageService.uploadAvatar(props.user.id, file)
    
    if (uploadError) {
      error.value = uploadError.message
    } else if (data) {
      form.value.avatarUrl = data.url
      success.value = 'Photo de profil mise à jour !'
    }
  } catch (err) {
    error.value = 'Erreur lors de l\'upload de l\'image'
  } finally {
    uploading.value = false
  }
}
const loadProfile = async () => {
  if (props.user) {
    console.log('Loading profile for user:', props.user.id)
    
    // D'abord, initialiser avec les données utilisateur de base
    form.value.email = props.user.email || ''
    form.value.fullName = props.user.user_metadata?.full_name || ''
    
    const { data, error } = await profileService.getProfile(props.user.id)
    console.log('Profile loaded from database:', { data, error })
    if (data && !error) {
      form.value = {
        fullName: data.full_name || props.user.user_metadata?.full_name || '',
        email: data.email || props.user.email || '',
        avatarUrl: data.avatar_url || '',
        formation: data.formation || '',
        anneeEtudes: data.annee_etudes || '3',
        etablissement: data.etablissement || '',
        telephone: data.telephone || '',
        linkedin: data.linkedin || '',
        github: data.github || '',
        bio: data.bio || '',
        newPassword: '',
        confirmPassword: ''
      }
      
      console.log('Form populated with profile data:', form.value)
    } else {
      console.warn('No profile data found or error occurred:', error)
      // Garder les données de base de l'utilisateur même si pas de profil en DB
      form.value.email = props.user.email || ''
      form.value.fullName = props.user.user_metadata?.full_name || ''
    }
  }
}

const requestEmailChange = async () => {
  if (!form.value.email || form.value.email === props.user?.email) {
    error.value = 'Veuillez saisir un nouvel email différent'
    return
  }

  emailChangeLoading.value = true
  error.value = ''
  success.value = ''

  try {
    const { error: updateError } = await authService.updateEmail(form.value.email)
    
    if (updateError) {
      error.value = updateError.message
    } else {
      success.value = 'Un email de confirmation a été envoyé à votre nouvelle adresse'
    }
  } catch (err) {
    error.value = 'Erreur lors de la demande de changement d\'email'
  } finally {
    emailChangeLoading.value = false
  }
}

const updatePassword = async () => {
  if (!form.value.newPassword || form.value.newPassword !== form.value.confirmPassword) {
    error.value = 'Les mots de passe ne correspondent pas'
    return
  }

  if (form.value.newPassword.length < 12) {
    error.value = 'Le mot de passe doit contenir au moins 12 caractères'
    return
  }

  // Enhanced password validation
  const hasUpperCase = /[A-Z]/.test(form.value.newPassword)
  const hasLowerCase = /[a-z]/.test(form.value.newPassword)
  const hasNumbers = /\d/.test(form.value.newPassword)
  const hasSpecialChar = /[!@#$%^&*(),.?":{}|<>]/.test(form.value.newPassword)

  if (!hasUpperCase || !hasLowerCase || !hasNumbers || !hasSpecialChar) {
    error.value = 'Le mot de passe doit contenir au moins une majuscule, une minuscule, un chiffre et un caractère spécial'
    return
  }

  passwordChangeLoading.value = true
  error.value = ''
  success.value = ''

  try {
    const { error: updateError } = await authService.updatePassword(form.value.newPassword)
    
    if (updateError) {
      error.value = 'Erreur lors de la mise à jour du mot de passe'
    } else {
      success.value = 'Mot de passe mis à jour avec succès'
      form.value.newPassword = ''
      form.value.confirmPassword = ''
    }
  } catch (err) {
    error.value = 'Erreur lors de la mise à jour du mot de passe'
  } finally {
    passwordChangeLoading.value = false
  }
}

const resetPassword = async () => {
  if (!props.user?.email) {
    error.value = 'Email utilisateur non disponible'
    return
  }

  resetPasswordLoading.value = true
  error.value = ''
  success.value = ''

  try {
    const { error: resetError } = await authService.resetPassword(props.user.email)
    
    if (resetError) {
      error.value = resetError.message
    } else {
      success.value = 'Un email de réinitialisation a été envoyé'
    }
  } catch (err) {
    error.value = 'Erreur lors de l\'envoi de l\'email de réinitialisation'
  } finally {
    resetPasswordLoading.value = false
  }
}
const handleSubmit = async () => {
  // Ne pas traiter la soumission si on est en train de sauvegarder
  if (loading.value) return
  
  // Clear any previous messages
  error.value = ''
  success.value = ''
  
  // Validation de sécurité côté client
  if (form.value.fullName && form.value.fullName.length > 100) {
    error.value = 'Le nom complet ne peut pas dépasser 100 caractères'
    return
  }
  
  if (form.value.bio && form.value.bio.length > 1000) {
    error.value = 'La bio ne peut pas dépasser 1000 caractères'
    return
  }
  
  // Validation côté client
  if (!form.value.fullName.trim()) {
    error.value = 'Le nom complet est requis'
    return
  }
  
  if (!form.value.email.trim()) {
    error.value = 'L\'email est requis'
    return
  }
  
  loading.value = true

  try {
    if (props.user) {
      console.log('Submitting profile update:', {
        userId: props.user.id,
        formData: form.value
      })
      
      // Prepare all update data including background settings
      const updateData = {
        email: form.value.email.trim() || null,
        full_name: form.value.fullName.trim() || null,
        avatar_url: form.value.avatarUrl,
        formation: form.value.formation.trim() || null,
        annee_etudes: form.value.anneeEtudes || null,
        etablissement: form.value.etablissement.trim() || null,
        telephone: form.value.telephone.trim() || null,
        linkedin: form.value.linkedin.trim() || null,
        github: form.value.github.trim() || null,
        bio: form.value.bio.trim() || null,
        // Include background settings from BackgroundCustomizer
        background_type: backgroundCustomizerRef.value?.getSelectedType() || 'default',
        background_url: backgroundCustomizerRef.value?.getCurrentImageUrl() || null,
        background_settings: backgroundCustomizerRef.value?.getBackgroundSettings() || {}
      }
      
      console.log('Sending update data:', updateData)
      
      const { data: updatedProfile, error: updateError } = await profileService.updateProfile(props.user.id, updateData)
      
      if (updateError) {
        console.error('Profile update failed:', updateError)
        error.value = updateError.message
      } else {
        console.log('Profile update successful, updated data:', updatedProfile)
        
        // Mettre à jour également la table users pour synchroniser le nom
        try {
          const { error: userUpdateError } = await supabase
            .from('users')
            .update({
              full_name: form.value.fullName.trim(),
              email: form.value.email.trim()
            })
            .eq('id', props.user.id)
          
          if (userUpdateError) {
            console.warn('Warning: Could not update users table:', userUpdateError)
          } else {
            console.log('Users table updated successfully')
          }
        } catch (userError) {
          console.warn('Warning: Exception updating users table:', userError)
        }
        
        // Attendre un peu pour que la base de données soit mise à jour
        await new Promise(resolve => setTimeout(resolve, 1000))
        
        // Vérifier que les données ont bien été sauvegardées
        const { data: verificationData, error: verificationError } = await profileService.getProfile(props.user.id)
        console.log('Verification after save:', { verificationData, verificationError })
        
        // Émettre les données mises à jour avec le nom complet
        emit('save', verificationData || updatedProfile || updateData)
        
        // Afficher un message de succès simple
        success.value = 'Informations de profil sauvegardées avec succès !'
        
        // Fermer le modal après succès
        setTimeout(() => {
          emit('close')
        }, 1500)
      }
    }
  } catch (err) {
    console.error('Profile update exception:', err)
    error.value = 'Erreur lors de la mise à jour du profil'
  } finally {
    loading.value = false
  }
}

const closeSuccessModal = () => {
  showSuccessModal.value = false
  emit('close')
}
</script>