import { ref, computed } from 'vue'
import { authService, supabase } from '../lib/supabase'

export interface Trophy {
  id: string
  title: string
  description: string
  icon: string
  category: 'competences' | 'apprentissages' | 'projets' | 'portfolio' | 'social' | 'premium'
  requirement: {
    type: 'count' | 'percentage' | 'streak' | 'special'
    target: number
    field?: string
  }
  rarity: 'bronze' | 'silver' | 'gold' | 'diamond' | 'legendary'
  points: number
  unlockedAt?: string
}

export interface UserStats {
  competences: number
  apprentissages: number
  projets: number
  bienMaitrise: number
  portfolioViews: number
  daysActive: number
  streak: number
  totalPoints: number
  level: number
}

const trophies: Trophy[] = [
  // Trophées Compétences
  {
    id: 'first_competence',
    title: 'Premier Pas',
    description: 'Créer votre première compétence BUT',
    icon: '🎯',
    category: 'competences',
    requirement: { type: 'count', target: 1, field: 'competences' },
    rarity: 'bronze',
    points: 50
  },
  {
    id: 'competence_master',
    title: 'Maître des Compétences',
    description: 'Créer 5 compétences BUT',
    icon: '🏆',
    category: 'competences',
    requirement: { type: 'count', target: 5, field: 'competences' },
    rarity: 'gold',
    points: 300
  },
  {
    id: 'competence_legend',
    title: 'Légende BUT',
    description: 'Créer 10 compétences BUT',
    icon: '👑',
    category: 'competences',
    requirement: { type: 'count', target: 10, field: 'competences' },
    rarity: 'legendary',
    points: 1000
  },

  // Trophées Apprentissages
  {
    id: 'first_apprentissage',
    title: 'Apprenti Critique',
    description: 'Créer votre premier apprentissage critique',
    icon: '📚',
    category: 'apprentissages',
    requirement: { type: 'count', target: 1, field: 'apprentissages' },
    rarity: 'bronze',
    points: 30
  },
  {
    id: 'apprentissage_collector',
    title: 'Collectionneur d\'Apprentissages',
    description: 'Créer 10 apprentissages critiques',
    icon: '📖',
    category: 'apprentissages',
    requirement: { type: 'count', target: 10, field: 'apprentissages' },
    rarity: 'silver',
    points: 200
  },
  {
    id: 'apprentissage_master',
    title: 'Maître Apprenti',
    description: 'Créer 25 apprentissages critiques',
    icon: '🎓',
    category: 'apprentissages',
    requirement: { type: 'count', target: 25, field: 'apprentissages' },
    rarity: 'gold',
    points: 500
  },
  {
    id: 'apprentissage_legend',
    title: 'Sage BUT',
    description: 'Créer 50 apprentissages critiques',
    icon: '🧙‍♂️',
    category: 'apprentissages',
    requirement: { type: 'count', target: 50, field: 'apprentissages' },
    rarity: 'legendary',
    points: 1500
  },

  // Trophées Projets
  {
    id: 'first_project',
    title: 'Innovateur',
    description: 'Créer votre premier projet',
    icon: '🚀',
    category: 'projets',
    requirement: { type: 'count', target: 1, field: 'projets' },
    rarity: 'bronze',
    points: 40
  },
  {
    id: 'project_builder',
    title: 'Bâtisseur',
    description: 'Créer 5 projets',
    icon: '🏗️',
    category: 'projets',
    requirement: { type: 'count', target: 5, field: 'projets' },
    rarity: 'silver',
    points: 250
  },
  {
    id: 'project_architect',
    title: 'Architecte',
    description: 'Créer 10 projets',
    icon: '🏛️',
    category: 'projets',
    requirement: { type: 'count', target: 10, field: 'projets' },
    rarity: 'gold',
    points: 600
  },

  // Trophées Maîtrise
  {
    id: 'first_mastery',
    title: 'Première Maîtrise',
    description: 'Obtenir votre première évaluation "Bien Maîtrisé"',
    icon: '⭐',
    category: 'portfolio',
    requirement: { type: 'count', target: 1, field: 'bienMaitrise' },
    rarity: 'bronze',
    points: 60
  },
  {
    id: 'mastery_expert',
    title: 'Expert BUT',
    description: 'Obtenir 10 évaluations "Bien Maîtrisé"',
    icon: '🌟',
    category: 'portfolio',
    requirement: { type: 'count', target: 10, field: 'bienMaitrise' },
    rarity: 'silver',
    points: 400
  },
  {
    id: 'mastery_perfectionist',
    title: 'Perfectionniste',
    description: 'Avoir 80% d\'apprentissages "Bien Maîtrisé"',
    icon: '💎',
    category: 'portfolio',
    requirement: { type: 'percentage', target: 80, field: 'bienMaitrise' },
    rarity: 'gold',
    points: 800
  },
  {
    id: 'mastery_legend',
    title: 'Légende de la Maîtrise',
    description: 'Avoir 95% d\'apprentissages "Bien Maîtrisé"',
    icon: '👑',
    category: 'portfolio',
    requirement: { type: 'percentage', target: 95, field: 'bienMaitrise' },
    rarity: 'legendary',
    points: 2000
  },

  // Trophées Spéciaux
  {
    id: 'portfolio_complete',
    title: 'Portfolio Complet',
    description: 'Avoir au moins 3 compétences, 10 apprentissages et 3 projets',
    icon: '🎖️',
    category: 'portfolio',
    requirement: { type: 'special', target: 1 },
    rarity: 'gold',
    points: 500
  },
  {
    id: 'early_adopter',
    title: 'Pionnier FolioLink',
    description: 'Parmi les 100 premiers acheteurs Premium de FolioLink',
    icon: '🌟',
    category: 'premium',
    requirement: { type: 'special', target: 1 },
    rarity: 'diamond',
    points: 2000
  },
  {
    id: 'premium_supporter',
    title: 'Supporter Premium',
    description: 'Soutenir FolioLink avec un achat Premium',
    icon: '💎',
    category: 'premium',
    requirement: { type: 'special', target: 1 },
    rarity: 'diamond',
    points: 1500
  },
  {
    id: 'portfolio_sharer',
    title: 'Ambassadeur',
    description: 'Activer le partage public de votre portfolio',
    icon: '🌐',
    category: 'social',
    requirement: { type: 'special', target: 1 },
    rarity: 'silver',
    points: 200
  },

  // Trophées Créativité
  {
    id: 'creative_writer',
    title: 'Écrivain Créatif',
    description: 'Rédiger plus de 5000 caractères d\'argumentaires',
    icon: '✍️',
    category: 'portfolio',
    requirement: { type: 'count', target: 5000, field: 'totalCharacters' },
    rarity: 'silver',
    points: 300
  },
  {
    id: 'tech_enthusiast',
    title: 'Passionné de Tech',
    description: 'Utiliser plus de 20 technologies différentes',
    icon: '💻',
    category: 'projets',
    requirement: { type: 'count', target: 20, field: 'uniqueTechnologies' },
    rarity: 'gold',
    points: 400
  }
]

export function useGamification() {
  const userTrophies = ref<Trophy[]>([])
  const userStats = ref<UserStats>({
    competences: 0,
    apprentissages: 0,
    projets: 0,
    bienMaitrise: 0,
    portfolioViews: 0,
    daysActive: 0,
    streak: 0,
    totalPoints: 0,
    level: 1
  })
  const newTrophies = ref<Trophy[]>([])
  const showTrophyModal = ref(false)

  const availableTrophies = computed(() => trophies)
  
  const unlockedTrophies = computed(() => 
    userTrophies.value.filter(t => t.unlockedAt)
  )
  
  const lockedTrophies = computed(() => 
    trophies.filter(t => !userTrophies.value.find(ut => ut.id === t.id))
  )

  const getTrophyProgress = async (trophy: Trophy) => {
    if (userTrophies.value.find(t => t.id === trophy.id)) {
      return { progress: 100, isUnlocked: true, remaining: 0, description: 'Trophée débloqué !' }
    }

    let current = 0
    let target = trophy.requirement.target
    let remaining = 0
    let description = ''

    switch (trophy.requirement.type) {
      case 'count':
        current = userStats.value[trophy.requirement.field as keyof UserStats] as number || 0
        remaining = Math.max(0, target - current)
        description = remaining > 0 
          ? `Il vous reste ${remaining} ${getFieldDisplayName(trophy.requirement.field)} à créer`
          : 'Prêt à être débloqué !'
        break

      case 'percentage':
        if (trophy.requirement.field === 'bienMaitrise') {
          const percentage = userStats.value.apprentissages > 0 
            ? (userStats.value.bienMaitrise / userStats.value.apprentissages) * 100 
            : 0
          current = percentage
          remaining = Math.max(0, target - percentage)
          description = remaining > 0
            ? `Il vous faut ${remaining.toFixed(1)}% d'apprentissages "Bien Maîtrisé" en plus`
            : 'Prêt à être débloqué !'
        }
        break

      case 'special':
        const specialProgress = await getSpecialTrophyProgress(trophy.id)
        current = specialProgress.current
        target = specialProgress.target
        remaining = specialProgress.remaining
        description = specialProgress.description
        break
    }

    const progress = target > 0 ? Math.min(100, (current / target) * 100) : 0
    
    return {
      progress: Math.round(progress),
      isUnlocked: false,
      current,
      target,
      remaining,
      description
    }
  }

  const getFieldDisplayName = (field?: string) => {
    const fieldNames = {
      competences: 'compétences',
      apprentissages: 'apprentissages',
      projets: 'projets',
      bienMaitrise: 'apprentissages bien maîtrisés',
      totalCharacters: 'caractères',
      uniqueTechnologies: 'technologies différentes'
    }
    return fieldNames[field as keyof typeof fieldNames] || field
  }

  const getSpecialTrophyProgress = async (trophyId: string) => {
    switch (trophyId) {
      case 'portfolio_complete':
        const competencesNeeded = Math.max(0, 3 - userStats.value.competences)
        const apprentissagesNeeded = Math.max(0, 10 - userStats.value.apprentissages)
        const projetsNeeded = Math.max(0, 3 - userStats.value.projets)
        const totalNeeded = competencesNeeded + apprentissagesNeeded + projetsNeeded
        
        if (totalNeeded === 0) {
          return { current: 1, target: 1, remaining: 0, description: 'Prêt à être débloqué !' }
        }
        
        const requirements = []
        if (competencesNeeded > 0) requirements.push(`${competencesNeeded} compétences`)
        if (apprentissagesNeeded > 0) requirements.push(`${apprentissagesNeeded} apprentissages`)
        if (projetsNeeded > 0) requirements.push(`${projetsNeeded} projets`)
        
        return {
          current: 0,
          target: 1,
          remaining: 1,
          description: `Il vous manque : ${requirements.join(', ')}`
        }

      case 'early_adopter':
        // Check if user is among first 100 premium buyers
        const premiumOrderNumber = await getPremiumOrderNumber()
        if (premiumOrderNumber > 0 && premiumOrderNumber <= 100) {
          return {
            current: 1,
            target: 1,
            remaining: 0,
            description: `Vous êtes le ${premiumOrderNumber}e acheteur Premium ! Trophée débloqué !`
          }
        } else if (premiumOrderNumber > 100) {
          return {
            current: 0,
            target: 1,
            remaining: 1,
            description: `Réservé aux 100 premiers acheteurs Premium (vous êtes le ${premiumOrderNumber}e)`
          }
        } else {
          return {
            current: 0,
            target: 1,
            remaining: 1,
            description: 'Achetez Premium pour rejoindre les 100 premiers pionniers'
          }
        }

      case 'premium_supporter':
        return {
          current: 0,
          target: 1,
          remaining: 1,
          description: 'Achetez FolioLink Premium pour débloquer ce trophée'
        }

      case 'portfolio_sharer':
        return {
          current: 0,
          target: 1,
          remaining: 1,
          description: 'Activez le partage public de votre portfolio'
        }

      case 'creative_writer':
        const currentChars = userStats.value.totalCharacters || 0
        const charsNeeded = Math.max(0, 5000 - currentChars)
        return {
          current: currentChars,
          target: 5000,
          remaining: charsNeeded,
          description: charsNeeded > 0 
            ? `Écrivez encore ${charsNeeded} caractères dans vos argumentaires`
            : 'Prêt à être débloqué !'
        }

      case 'tech_enthusiast':
        const currentTechs = userStats.value.uniqueTechnologies || 0
        const techsNeeded = Math.max(0, 20 - currentTechs)
        return {
          current: currentTechs,
          target: 20,
          remaining: techsNeeded,
          description: techsNeeded > 0 
            ? `Utilisez encore ${techsNeeded} technologies différentes dans vos projets`
            : 'Prêt à être débloqué !'
        }

      default:
        return { current: 0, target: 1, remaining: 1, description: 'Conditions spéciales requises' }
    }
  }

  const currentLevel = computed(() => {
    const points = userStats.value.totalPoints
    if (points < 100) return 1
    if (points < 300) return 2
    if (points < 600) return 3
    if (points < 1000) return 4
    if (points < 1500) return 5
    if (points < 2500) return 6
    if (points < 4000) return 7
    if (points < 6000) return 8
    if (points < 9000) return 9
    return 10
  })

  const nextLevelPoints = computed(() => {
    const levels = [0, 100, 300, 600, 1000, 1500, 2500, 4000, 6000, 9000, 15000]
    const currentLevelIndex = currentLevel.value - 1
    return levels[currentLevelIndex + 1] || 15000
  })

  const progressToNextLevel = computed(() => {
    const levels = [0, 100, 300, 600, 1000, 1500, 2500, 4000, 6000, 9000, 15000]
    const currentLevelIndex = currentLevel.value - 1
    const currentLevelPoints = levels[currentLevelIndex] || 0
    const nextLevel = levels[currentLevelIndex + 1] || 15000
    const progress = ((userStats.value.totalPoints - currentLevelPoints) / (nextLevel - currentLevelPoints)) * 100
    return Math.min(100, Math.max(0, progress))
  })

  const loadUserStats = async () => {
    try {
      const user = await authService.getCurrentUser()
      if (!user) return

      // Charger les statistiques depuis la base de données
      const [competencesResult, apprentissagesResult, projetsResult] = await Promise.all([
        supabase.from('competences').select('*', { count: 'exact' }).eq('user_id', user.id),
        supabase.from('apprentissages').select('*').eq('user_id', user.id),
        supabase.from('projets').select('*', { count: 'exact' }).eq('user_id', user.id)
      ])

      const apprentissages = apprentissagesResult.data || []
      const bienMaitrise = apprentissages.filter(a => a.evaluation === 'Bien Maîtrisé').length

      // Calculer les statistiques avancées
      const totalCharacters = apprentissages.reduce((sum, a) => sum + (a.argumentaire?.length || 0), 0)
      const uniqueTechnologies = new Set()
      
      if (projetsResult.data) {
        projetsResult.data.forEach(p => {
          if (p.technologies) {
            p.technologies.forEach(tech => uniqueTechnologies.add(tech))
          }
        })
      }

      userStats.value = {
        competences: competencesResult.count || 0,
        apprentissages: apprentissages.length,
        projets: projetsResult.count || 0,
        bienMaitrise,
        portfolioViews: 0, // À implémenter plus tard
        daysActive: 0, // À implémenter plus tard
        streak: 0, // À implémenter plus tard
        totalPoints: 0, // Sera calculé après vérification des trophées
        level: 1,
        totalCharacters,
        uniqueTechnologies: uniqueTechnologies.size
      }

      // Vérifier les trophées débloqués
      await checkTrophies()
    } catch (error) {
      console.error('Error loading user stats:', error)
    }
  }

  const checkTrophies = async () => {
    const user = await authService.getCurrentUser()
    if (!user) return

    // Charger les trophées existants
    const { data: existingTrophies } = await supabase
      .from('user_trophies')
      .select('*')
      .eq('user_id', user.id)

    userTrophies.value = existingTrophies?.map(t => ({
      ...trophies.find(trophy => trophy.id === t.trophy_id)!,
      unlockedAt: t.unlocked_at
    })) || []

    // Vérifier les nouveaux trophées
    const newlyUnlocked: Trophy[] = []

    for (const trophy of trophies) {
      const alreadyUnlocked = userTrophies.value.find(t => t.id === trophy.id)
      if (alreadyUnlocked) continue

      let isUnlocked = false

      switch (trophy.requirement.type) {
        case 'count':
          const fieldValue = userStats.value[trophy.requirement.field as keyof UserStats] as number
          isUnlocked = fieldValue >= trophy.requirement.target
          break

        case 'percentage':
          if (trophy.requirement.field === 'bienMaitrise') {
            const percentage = userStats.value.apprentissages > 0 
              ? (userStats.value.bienMaitrise / userStats.value.apprentissages) * 100 
              : 0
            isUnlocked = percentage >= trophy.requirement.target
          }
          break

        case 'special':
          isUnlocked = await checkSpecialTrophy(trophy.id)
          break
      }

      if (isUnlocked) {
        // Sauvegarder le trophée
        await supabase.from('user_trophies').insert({
          user_id: user.id,
          trophy_id: trophy.id,
          unlocked_at: new Date().toISOString()
        })

        const unlockedTrophy = { ...trophy, unlockedAt: new Date().toISOString() }
        userTrophies.value.push(unlockedTrophy)
        newlyUnlocked.push(unlockedTrophy)
      }
    }

    // Calculer les points totaux
    userStats.value.totalPoints = userTrophies.value.reduce((sum, t) => sum + t.points, 0)
    userStats.value.level = currentLevel.value

    // Afficher les nouveaux trophées
    if (newlyUnlocked.length > 0) {
      newTrophies.value = newlyUnlocked
      showTrophyModal.value = true
    }
  }

  const checkSpecialTrophy = async (trophyId: string): Promise<boolean> => {
    const user = await authService.getCurrentUser()
    if (!user) return false

    switch (trophyId) {
      case 'portfolio_complete':
        return userStats.value.competences >= 3 && 
               userStats.value.apprentissages >= 10 && 
               userStats.value.projets >= 3

      case 'early_adopter':
        // Vérifier si l'utilisateur est parmi les 100 premiers acheteurs Premium
        const { data: userOrder } = await supabase
          .from('stripe_orders')
          .select('created_at')
          .eq('status', 'completed')
          .limit(1)
        
        if (userOrder && userOrder.length > 0) {
          // Compter combien d'acheteurs Premium il y a eu avant cet utilisateur
          const { count } = await supabase
            .from('stripe_orders')
            .select('*', { count: 'exact', head: true })
            .eq('status', 'completed')
            .lte('created_at', userOrder[0].created_at)
          
          return (count || 0) <= 100
        }
        return false

      case 'premium_supporter':
        // Vérifier si l'utilisateur a acheté Premium
        const { data: orders } = await supabase
          .from('stripe_orders')
          .select('*')
          .eq('status', 'completed')
          .limit(1)
        return !!(orders && orders.length > 0)

      case 'portfolio_sharer':
        // Vérifier si le portfolio public est activé
        const { data: profileData } = await supabase
          .from('profiles')
          .select('is_public')
          .eq('id', user.id)
          .single()
        return profileData?.is_public || false

      default:
        return false
    }
  }

  const getRarityColor = (rarity: Trophy['rarity']) => {
    switch (rarity) {
      case 'bronze': return 'text-amber-600 bg-amber-100 dark:bg-amber-900 border-amber-300'
      case 'silver': return 'text-gray-600 bg-gray-100 dark:bg-gray-800 border-gray-300'
      case 'gold': return 'text-yellow-600 bg-yellow-100 dark:bg-yellow-900 border-yellow-300'
      case 'diamond': return 'text-cyan-600 bg-cyan-100 dark:bg-cyan-900 border-cyan-300'
      case 'legendary': return 'text-purple-600 bg-purple-100 dark:bg-purple-900 border-purple-300'
      default: return 'text-gray-600 bg-gray-100 dark:bg-gray-800 border-gray-300'
    }
  }

  const getRarityGlow = (rarity: Trophy['rarity']) => {
    switch (rarity) {
      case 'bronze': return 'shadow-amber-500/25'
      case 'silver': return 'shadow-gray-500/25'
      case 'gold': return 'shadow-yellow-500/25'
      case 'diamond': return 'shadow-cyan-500/25'
      case 'legendary': return 'shadow-purple-500/25 animate-pulse'
      default: return 'shadow-gray-500/25'
    }
  }

  const closeTrophyModal = () => {
    showTrophyModal.value = false
    newTrophies.value = []
  }

  return {
    userTrophies,
    userStats,
    newTrophies,
    showTrophyModal,
    availableTrophies,
    unlockedTrophies,
    lockedTrophies,
    currentLevel,
    nextLevelPoints,
    progressToNextLevel,
    loadUserStats,
    checkTrophies,
    getRarityColor,
    getRarityGlow,
    closeTrophyModal,
    getTrophyProgress
  }
}