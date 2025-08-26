import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables')
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

export interface User {
  id: string
  email?: string
  user_metadata?: {
    full_name?: string
    name?: string
    avatar_url?: string
  }
  email_confirmed_at?: string
}

// Auth Service
export const authService = {
  async getCurrentUser(): Promise<User | null> {
    try {
      const { data: { user } } = await supabase.auth.getUser()
      return user as User | null
      // Check for stale session errors
      if (error && (
        error.message?.includes('User not found') ||
        error.message?.includes('user_not_found') ||
        error.message?.includes('invalid_grant') ||
        error.message?.includes('JWT') ||
        error.status === 403
      )) {
        console.warn('Stale session detected, signing out:', error.message)
        await this.signOut()
        return null
      }
      
      if (error) {
        console.error('Error getting current user:', error)
        return null
      }
      
    } catch (error) {
      console.error('Error getting current user:', error)
      // Also handle network errors that might indicate session issues
      await this.signOut()
      return null
    }
  },

  async signUp(email: string, password: string, fullName: string) {
    return await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          full_name: fullName
        }
      }
    })
  },

  async signIn(email: string, password: string) {
    return await supabase.auth.signInWithPassword({
      email,
      password
    })
  },

  async signOut() {
    try {
      // Clear all local storage
      localStorage.clear()
      
      // Clear session storage
      sessionStorage.clear()
      
      // Sign out from Supabase
      const { error } = await supabase.auth.signOut()
      
      if (error) {
        console.warn('Supabase signOut error (non-blocking):', error)
      }
      
      return { error: null }
    } catch (networkError) {
      // In case of network error, force local cleanup
      console.warn('Network error during signOut, clearing local session:', networkError)
      
      // Force clear local session
      localStorage.clear()
      sessionStorage.clear()
      
      return { error: null }
    }
  },

  async signInWithOAuth(provider: 'google' | 'discord') {
    return await supabase.auth.signInWithOAuth({
      provider,
      options: {
        redirectTo: `${window.location.origin}/auth/callback`
      }
    })
  },

  async resetPassword(email: string) {
    return await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/reset-password`
    })
  },

  async updatePassword(newPassword: string) {
    return await supabase.auth.updateUser({
      password: newPassword
    })
  },

  async updateEmail(newEmail: string) {
    return await supabase.auth.updateUser({
      email: newEmail
    })
  },

  onAuthStateChange(callback: (event: string, session: any) => void) {
    return supabase.auth.onAuthStateChange(callback)
  }
}

// Profile Service
export const profileService = {
  async getProfile(userId: string) {
    return await supabase
      .from('profiles')
      .select('*')
      .eq('id', userId)
      .single()
  },

  async createOrUpdateProfile(userId: string, profileData: any) {
    return await supabase
      .from('profiles')
      .upsert({
        id: userId,
        ...profileData,
        updated_at: new Date().toISOString()
      })
      .select()
      .single()
  },

  async updateProfile(userId: string, profileData: any) {
    console.log('ProfileService.updateProfile called with:', { userId, profileData })
    
    const { data, error } = await supabase
      .from('profiles')
      .update({
        ...profileData,
        updated_at: new Date().toISOString()
      })
      .eq('id', userId)
      .select()
      .single()
    
    console.log('Profile update result:', { data, error })
    
    if (error) {
      console.error('Profile update failed:', error)
      return { data: null, error }
    }
    
    // Vérifier que les données ont bien été mises à jour
    const { data: verificationData, error: verificationError } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', userId)
      .single()
    
    console.log('Profile verification after update:', { verificationData, verificationError })
    
    return { data: verificationData || data, error: verificationError }
  },

  async updateOnboardingStatus(userId: string, completed: boolean) {
    return await supabase
      .from('profiles')
      .update({ onboarding_completed: completed })
      .eq('id', userId)
  }
}

// Competence Service
export const competenceService = {
  async getCompetences() {
    const user = await authService.getCurrentUser()
    if (!user) {
      // Return example competences for non-authenticated users
      return await supabase
        .from('example_competences')
        .select('*')
    }
    
    return await supabase
      .from('competences')
      .select('*')
      .or(`user_id.eq.${user.id},user_id.is.null`)
      .order('created_at', { ascending: true })
  },

  async createCompetence(competence: any) {
    const user = await authService.getCurrentUser()
    if (!user) throw new Error('User not authenticated')

    return await supabase
      .from('competences')
      .insert({
        id: competence.id,
        title: competence.title,
        subtitle: competence.subtitle,
        description: competence.description,
        levels: competence.levels,
        color: competence.color,
        icon: competence.icon,
        user_id: user.id
      })
      .select()
      .single()
  },

  async updateCompetence(competenceId: string, competence: any) {
    const user = await authService.getCurrentUser()
    if (!user) throw new Error('User not authenticated')

    return await supabase
      .from('competences')
      .update({
        title: competence.title,
        subtitle: competence.subtitle,
        description: competence.description,
        levels: competence.levels,
        color: competence.color,
        icon: competence.icon
      })
      .eq('id', competenceId)
      .eq('user_id', user.id)
      .select()
      .single()
  },

  async deleteCompetence(competenceId: string) {
    const user = await authService.getCurrentUser()
    if (!user) throw new Error('User not authenticated')

    return await supabase
      .from('competences')
      .delete()
      .eq('id', competenceId)
      .eq('user_id', user.id)
  }
}

// Apprentissage Service
export const apprentissageService = {
  async getUserApprentissages(userId: string) {
    return await supabase
      .from('apprentissages')
      .select(`
        *,
        preuves (*)
      `)
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
  },

  async createApprentissage(apprentissage: any) {
    const user = await authService.getCurrentUser()
    if (!user) throw new Error('User not authenticated')

    // Create apprentissage first
    const { data: newApprentissage, error: apprentissageError } = await supabase
      .from('apprentissages')
      .insert({
        user_id: user.id,
        competence_id: apprentissage.competenceId,
        level: apprentissage.level,
        title: apprentissage.title,
        description: apprentissage.description,
        evaluation: apprentissage.evaluation,
        argumentaire: apprentissage.argumentaire,
        category_id: apprentissage.categoryId
      })
      .select()
      .single()

    if (apprentissageError || !newApprentissage) {
      return { data: null, error: apprentissageError }
    }

    // Create preuves if any
    if (apprentissage.preuves && apprentissage.preuves.length > 0) {
      const preuvesData = apprentissage.preuves.map((preuve: any) => ({
        apprentissage_id: newApprentissage.id,
        titre: preuve.titre,
        type: preuve.type,
        url: preuve.url,
        projet_id: preuve.projetId || null
      }))

      const { error: preuvesError } = await supabase
        .from('preuves')
        .insert(preuvesData)

      if (preuvesError) {
        console.error('Error creating preuves:', preuvesError)
      }
    }

    return { data: newApprentissage, error: null }
  },

  async updateApprentissage(apprentissageId: string, apprentissage: any) {
    const user = await authService.getCurrentUser()
    if (!user) throw new Error('User not authenticated')

    // Update apprentissage
    const { data: updatedApprentissage, error: apprentissageError } = await supabase
      .from('apprentissages')
      .update({
        competence_id: apprentissage.competence_id,
        level: apprentissage.level,
        title: apprentissage.title,
        description: apprentissage.description || '',
        evaluation: apprentissage.evaluation,
        argumentaire: apprentissage.argumentaire || '',
        category_id: apprentissage.category_id
      })
      .eq('id', apprentissageId)
      .eq('user_id', user.id)
      .select()
      .single()

    if (apprentissageError) {
      return { data: null, error: apprentissageError }
    }

    // Delete existing preuves
    await supabase
      .from('preuves')
      .delete()
      .eq('apprentissage_id', apprentissageId)

    // Create new preuves if any
    if (apprentissage.preuves && apprentissage.preuves.length > 0) {
      const preuvesData = apprentissage.preuves.map((preuve: any) => ({
        apprentissage_id: apprentissageId,
        titre: preuve.titre,
        type: preuve.type,
        url: preuve.url,
        projet_id: preuve.projetId || null
      }))

      const { error: preuvesError } = await supabase
        .from('preuves')
        .insert(preuvesData)

      if (preuvesError) {
        console.error('Error updating preuves:', preuvesError)
      }
    }

    return { data: updatedApprentissage, error: null }
  },

  async deleteApprentissage(apprentissageId: string) {
    const user = await authService.getCurrentUser()
    if (!user) throw new Error('User not authenticated')

    return await supabase
      .from('apprentissages')
      .delete()
      .eq('id', apprentissageId)
      .eq('user_id', user.id)
  },

  async deleteApprentissagesByCompetence(competenceId: string) {
    const user = await authService.getCurrentUser()
    if (!user) throw new Error('User not authenticated')

    return await supabase
      .from('apprentissages')
      .delete()
      .eq('competence_id', competenceId)
      .eq('user_id', user.id)
  }
}

// Projet Service
export const projetService = {
  async getUserProjets(userId: string) {
    console.log('Loading projects for user:', userId)
    
    return await supabase
      .from('projets')
      .select(`
        *,
        fichiers_projets (*)
      `)
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
  },

  async createProjet(projet: any) {
    const user = await authService.getCurrentUser()
    if (!user) throw new Error('User not authenticated')

    console.log('Creating project with data:', projet)
    
    // Create project first
    const { data: newProjet, error: projetError } = await supabase
      .from('projets')
      .insert({
        user_id: user.id,
        titre: projet.titre,
        description: projet.description,
        icone: projet.icone,
        niveau: projet.niveau,
        duree: projet.duree,
        fonctionnalites: projet.fonctionnalites,
        technologies: projet.technologies,
        statut: projet.statut
      })
      .select()
      .single()

    console.log('Project creation result:', { newProjet, projetError })
    
    if (projetError || !newProjet) {
      console.error('Failed to create project:', projetError)
      return { data: null, error: projetError }
    }

    // Create fichiers if any
    if (projet.fichiers && projet.fichiers.length > 0) {
      console.log('Creating fichiers for project:', newProjet.id, projet.fichiers)
      
      const fichiersData = projet.fichiers.map((fichier: any) => ({
        projet_id: newProjet.id,
        nom: fichier.nom,
        type: fichier.type,
        url: fichier.url
      }))

      const { data: createdFichiers, error: fichiersError } = await supabase
        .from('fichiers_projets')
        .insert(fichiersData)
        .select()

      if (fichiersError) {
        console.error('Error creating fichiers:', fichiersError)
      } else {
        console.log('Fichiers created successfully:', createdFichiers)
        // Attach fichiers to the project data
        newProjet.fichiers_projets = createdFichiers
      }
    }

    return { data: newProjet, error: null }
  },

  async updateProjet(projetId: string, projet: any) {
    const user = await authService.getCurrentUser()
    if (!user) throw new Error('User not authenticated')

    // Update project
    const { data: updatedProjet, error: projetError } = await supabase
      .from('projets')
      .update({
        titre: projet.titre,
        description: projet.description,
        icone: projet.icone,
        niveau: projet.niveau,
        duree: projet.duree,
        fonctionnalites: projet.fonctionnalites,
        technologies: projet.technologies,
        statut: projet.statut
      })
      .eq('id', projetId)
      .eq('user_id', user.id)
      .select()
      .single()

    if (projetError) {
      return { data: null, error: projetError }
    }

    // Delete existing fichiers
    await supabase
      .from('fichiers_projets')
      .delete()
      .eq('projet_id', projetId)

    // Create new fichiers if any
    if (projet.fichiers && projet.fichiers.length > 0) {
      const fichiersData = projet.fichiers.map((fichier: any) => ({
        projet_id: projetId,
        nom: fichier.nom,
        type: fichier.type,
        url: fichier.url
      }))

      const { error: fichiersError } = await supabase
        .from('fichiers_projets')
        .insert(fichiersData)

      if (fichiersError) {
        console.error('Error updating fichiers:', fichiersError)
      }
    }

    return { data: updatedProjet, error: null }
  },

  async deleteProjet(projetId: string) {
    const user = await authService.getCurrentUser()
    if (!user) throw new Error('User not authenticated')

    return await supabase
      .from('projets')
      .delete()
      .eq('id', projetId)
      .eq('user_id', user.id)
  }
}

// Example Data Service
export const exampleDataService = {
  async getExampleCompetences() {
    return await supabase
      .from('example_competences')
      .select('*')
      .order('created_at', { ascending: true })
  },

  async getExampleApprentissages() {
    return await supabase
      .from('example_apprentissages')
      .select(`
        *,
        example_preuves (*)
      `)
      .order('created_at', { ascending: false })
  },

  async getExampleProjets() {
    return await supabase
      .from('example_projets')
      .select(`
        *,
        example_fichiers_projets (*)
      `)
      .order('created_at', { ascending: false })
  }
}

// Featured Apprentissage Service
export const featuredApprentissageService = {
  async getFeaturedApprentissages(userId: string) {
    return await supabase
      .from('featured_apprentissages')
      .select(`
        *,
        apprentissages (*)
      `)
      .eq('user_id', userId)
      .order('priority_order', { ascending: true })
  },

  async addFeaturedApprentissage(userId: string, apprentissageId: string, priority: number) {
    return await supabase
      .from('featured_apprentissages')
      .insert({
        user_id: userId,
        apprentissage_id: apprentissageId,
        priority_order: priority
      })
  },

  async removeFeaturedApprentissage(userId: string, apprentissageId: string) {
    return await supabase
      .from('featured_apprentissages')
      .delete()
      .eq('user_id', userId)
      .eq('apprentissage_id', apprentissageId)
  }
}

// AI Service
export const aiService = {
  async generateArgument(apprentissage: any, competence: any, profile: any) {
    const user = await authService.getCurrentUser()
    if (!user) throw new Error('User not authenticated')

    const { data: { session } } = await supabase.auth.getSession()
    if (!session) throw new Error('No active session')

    const response = await fetch(`${import.meta.env.VITE_SUPABASE_URL}/functions/v1/generate-argument`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${session.access_token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        apprentissage,
        competence,
        profile
      })
    })

    if (!response.ok) {
      const errorData = await response.json()
      console.error('AI service error:', errorData)
      throw new Error(errorData.error || 'Erreur lors de la génération de l\'argumentaire')
    }

    const result = await response.json()
    console.log('AI service response:', result)
    return { data: result, error: null }
  }
}

// Storage Service
export const storageService = {
  async uploadAvatar(userId: string, file: File) {
    const fileExt = file.name.split('.').pop()
    const fileName = `avatar-${userId}-${Date.now()}.${fileExt}`
    const filePath = `${userId}/${fileName}`

    const { data, error } = await supabase.storage
      .from('avatars')
      .upload(filePath, file, {
        cacheControl: '3600',
        upsert: true
      })

    if (error) {
      return { data: null, error }
    }

    const { data: { publicUrl } } = supabase.storage
      .from('avatars')
      .getPublicUrl(filePath)

    return { data: { url: publicUrl }, error: null }
  }
}

// Background Service
export const backgroundService = {
  async uploadBackground(userId: string, file: File) {
    const fileExt = file.name.split('.').pop()
    const fileName = `background-${userId}-${Date.now()}.${fileExt}`
    const filePath = `${userId}/${fileName}`

    const { data, error } = await supabase.storage
      .from('backgrounds')
      .upload(filePath, file, {
        cacheControl: '3600',
        upsert: true
      })

    if (error) {
      return { data: null, error }
    }

    const { data: { publicUrl } } = supabase.storage
      .from('backgrounds')
      .getPublicUrl(filePath)

    return { data: { url: publicUrl }, error: null }
  },

  async updateProfileBackground(userId: string, backgroundData: any) {
    return await supabase
      .from('profiles')
      .update(backgroundData)
      .eq('id', userId)
  }
}

// Premium Service
export const premiumService = {
  async getUserCompetencesCount(userId: string): Promise<number> {
    const { count } = await supabase
      .from('competences')
      .select('*', { count: 'exact', head: true })
      .eq('user_id', userId)
    
    return count || 0
  },

  async getUserApprentissagesCount(userId: string): Promise<number> {
    const { count } = await supabase
      .from('apprentissages')
      .select('*', { count: 'exact', head: true })
      .eq('user_id', userId)
    
    return count || 0
  },

  async getUserProjetsCount(userId: string): Promise<number> {
    const { count } = await supabase
      .from('projets')
      .select('*', { count: 'exact', head: true })
      .eq('user_id', userId)
    
    return count || 0
  }
}

// Public Portfolio Service
export const publicPortfolioService = {
  async getPublicPortfolio(slug: string) {
    // Get profile by public slug
    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('*')
      .eq('public_slug', slug)
      .eq('is_public', true)
      .single()

    if (profileError || !profile) {
      return { data: null, error: { message: 'Portfolio non trouvé ou privé' } }
    }

    // Get user's competences
    const { data: competences } = await supabase
      .from('competences')
      .select('*')
      .or(`user_id.eq.${profile.id},user_id.is.null`)
      .order('created_at', { ascending: true })

    // Get user's apprentissages with preuves
    const { data: apprentissages } = await supabase
      .from('apprentissages')
      .select(`
        *,
        preuves (*)
      `)
      .eq('user_id', profile.id)
      .order('created_at', { ascending: false })

    // Get user's projets
    const { data: projets } = await supabase
      .from('projets')
      .select(`
        *,
        fichiers_projets (*)
      `)
      .eq('user_id', profile.id)
      .order('created_at', { ascending: false })

    // Get featured apprentissages
    const { data: featured } = await supabase
      .from('featured_apprentissages')
      .select(`
        *,
        apprentissages (
          *,
          preuves (*)
        )
      `)
      .eq('user_id', profile.id)
      .order('priority_order', { ascending: true })

    return {
      data: {
        profile,
        competences: competences || [],
        apprentissages: apprentissages || [],
        projets: projets || [],
        featured: featured || []
      },
      error: null
    }
  },

  async checkSlugAvailability(slug: string) {
    // Check if slug is reserved
    const { data: reserved } = await supabase
      .from('reserved_slugs')
      .select('slug')
      .eq('slug', slug)
      .single()

    if (reserved) {
      return { available: false }
    }

    // Check if slug is already taken
    const { data: existing } = await supabase
      .from('profiles')
      .select('public_slug')
      .eq('public_slug', slug)
      .single()

    return { available: !existing }
  },

  async updatePublicSlug(userId: string, slug: string) {
    return await supabase
      .from('profiles')
      .update({ public_slug: slug })
      .eq('id', userId)
      .select()
      .single()
  },

  async updatePortfolioVisibility(userId: string, isPublic: boolean) {
    return await supabase
      .from('profiles')
      .update({ is_public: isPublic })
      .eq('id', userId)
  }
}

// Apprentissage Category Service
export const apprentissageCategoryService = {
  async getUserCategories(userId: string) {
    return await supabase
      .from('apprentissage_categories')
      .select('*')
      .eq('user_id', userId)
      .order('competence_id', { ascending: true })
      .order('level', { ascending: true })
      .order('order_index', { ascending: true })
  },

  async createCategory(categoryData: any) {
    const user = await authService.getCurrentUser()
    if (!user) throw new Error('User not authenticated')

    return await supabase
      .from('apprentissage_categories')
      .insert({
        user_id: user.id,
        competence_id: categoryData.competenceId,
        level: categoryData.level,
        title: categoryData.title,
        description: categoryData.description
      })
      .select()
      .single()
  },

  async updateCategory(categoryId: string, categoryData: any) {
    const user = await authService.getCurrentUser()
    if (!user) throw new Error('User not authenticated')

    return await supabase
      .from('apprentissage_categories')
      .update({
        title: categoryData.title,
        description: categoryData.description || ''
      })
      .eq('id', categoryId)
      .eq('user_id', user.id)
      .select()
      .single()
  },

  async deleteCategory(categoryId: string) {
    const user = await authService.getCurrentUser()
    if (!user) throw new Error('User not authenticated')

    return await supabase
      .from('apprentissage_categories')
      .delete()
      .eq('id', categoryId)
      .eq('user_id', user.id)
  }
}

export { supabase as default }