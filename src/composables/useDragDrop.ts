import { ref, nextTick } from 'vue'
import { apprentissageService, apprentissageCategoryService } from '../lib/supabase'

export interface DragData {
  type: 'apprentissage' | 'category'
  id: string
  sourceCompetenceId: string
  sourceLevel: number
  sourceCategoryId?: string
  sourceIndex: number
  data: any
}

export interface DropZone {
  type: 'competence-level' | 'category' | 'apprentissage-list'
  competenceId: string
  level: number
  categoryId?: string
  targetIndex?: number
}

export function useDragDrop() {
  // État du drag and drop
  const isDragging = ref(false)
  const dragData = ref<DragData | null>(null)
  const dragPreview = ref<HTMLElement | null>(null)
  const dropZones = ref<Map<string, DropZone>>(new Map())
  const activeDropZone = ref<string | null>(null)
  const dragOffset = ref({ x: 0, y: 0 })
  
  // État de sauvegarde
  const isSaving = ref(false)
  const saveError = ref('')
  const saveSuccess = ref('')

  /**
   * Initialise le drag d'un élément
   */
  const startDrag = (
    event: DragEvent,
    type: 'apprentissage' | 'category',
    id: string,
    competenceId: string,
    level: number,
    data: any,
    categoryId?: string,
    index: number = 0
  ) => {
    if (!event.dataTransfer) return

    console.log('🎯 Starting drag:', { type, id, competenceId, level, categoryId, index })

    // Configurer le drag
    event.dataTransfer.effectAllowed = 'move'
    event.dataTransfer.setData('text/plain', id)

    // Stocker les données de drag
    dragData.value = {
      type,
      id,
      sourceCompetenceId: competenceId,
      sourceLevel: level,
      sourceCategoryId: categoryId,
      sourceIndex: index,
      data
    }

    isDragging.value = true

    // Créer un aperçu personnalisé
    createDragPreview(event, data, type)

    // Calculer l'offset pour un positionnement précis
    const rect = (event.target as HTMLElement).getBoundingClientRect()
    dragOffset.value = {
      x: event.clientX - rect.left,
      y: event.clientY - rect.top
    }

    // Ajouter les classes CSS pour le feedback visuel
    document.body.classList.add('dragging')
    
    // Marquer l'élément source
    const sourceElement = event.target as HTMLElement
    sourceElement.classList.add('drag-source')
  }

  /**
   * Crée un aperçu personnalisé pour le drag
   */
  const createDragPreview = (event: DragEvent, data: any, type: string) => {
    const preview = document.createElement('div')
    preview.className = 'drag-preview glass-card p-4 max-w-xs shadow-2xl border-2 border-accent-400'
    
    const icon = type === 'category' ? '📁' : '📚'
    const title = data.title || data.titre || 'Élément'
    
    preview.innerHTML = `
      <div class="flex items-center space-x-3">
        <div class="text-2xl">${icon}</div>
        <div>
          <div class="text-white font-semibold text-sm">${title}</div>
          <div class="text-gray-300 text-xs">${type === 'category' ? 'Apprentissage Critique' : 'Apprentissage'}</div>
        </div>
      </div>
    `
    
    // Positionner l'aperçu hors écran
    preview.style.position = 'absolute'
    preview.style.top = '-1000px'
    preview.style.left = '-1000px'
    preview.style.zIndex = '9999'
    
    document.body.appendChild(preview)
    dragPreview.value = preview
    
    // Utiliser l'aperçu personnalisé
    if (event.dataTransfer) {
      event.dataTransfer.setDragImage(preview, dragOffset.value.x, dragOffset.value.y)
    }
  }

  /**
   * Gère l'entrée dans une zone de drop
   */
  const handleDragEnter = (event: DragEvent, dropZoneId: string) => {
    event.preventDefault()
    
    if (!isDragging.value || !dragData.value) return

    const dropZone = dropZones.value.get(dropZoneId)
    if (!dropZone || !canDrop(dragData.value, dropZone)) return

    activeDropZone.value = dropZoneId
    
    // Ajouter la classe CSS pour le feedback visuel
    const element = event.currentTarget as HTMLElement
    element.classList.add('drop-zone-active')
    
    console.log('📥 Drag enter valid drop zone:', dropZoneId)
  }

  /**
   * Gère la sortie d'une zone de drop
   */
  const handleDragLeave = (event: DragEvent, dropZoneId: string) => {
    // Vérifier si on quitte vraiment la zone (pas juste un enfant)
    const element = event.currentTarget as HTMLElement
    const rect = element.getBoundingClientRect()
    const x = event.clientX
    const y = event.clientY
    
    if (x < rect.left || x > rect.right || y < rect.top || y > rect.bottom) {
      element.classList.remove('drop-zone-active')
      
      if (activeDropZone.value === dropZoneId) {
        activeDropZone.value = null
      }
    }
  }

  /**
   * Gère le survol d'une zone de drop
   */
  const handleDragOver = (event: DragEvent, dropZoneId: string) => {
    event.preventDefault()
    
    if (!isDragging.value || !dragData.value) return

    const dropZone = dropZones.value.get(dropZoneId)
    if (!dropZone || !canDrop(dragData.value, dropZone)) {
      event.dataTransfer!.dropEffect = 'none'
      return
    }

    event.dataTransfer!.dropEffect = 'move'
  }

  /**
   * Gère le drop d'un élément
   */
  const handleDrop = async (event: DragEvent, dropZoneId: string) => {
    event.preventDefault()
    
    if (!isDragging.value || !dragData.value) return

    const dropZone = dropZones.value.get(dropZoneId)
    if (!dropZone || !canDrop(dragData.value, dropZone)) {
      console.warn('❌ Invalid drop operation')
      return
    }

    console.log('📦 Dropping:', { dragData: dragData.value, dropZone })

    // Nettoyer l'interface immédiatement
    cleanupDrag()

    // Effectuer le déplacement
    await performMove(dragData.value, dropZone)
  }

  /**
   * Vérifie si un drop est autorisé
   */
  const canDrop = (drag: DragData, drop: DropZone): boolean => {
    // Ne peut pas se déposer sur soi-même
    if (drag.type === 'category' && drop.type === 'category' && drag.id === drop.categoryId) {
      return false
    }

    // Règles de déplacement pour les apprentissages critiques
    if (drag.type === 'category') {
      // Peut se déposer sur n'importe quel niveau de compétence
      return drop.type === 'competence-level'
    }

    // Règles de déplacement pour les apprentissages
    if (drag.type === 'apprentissage') {
      // Peut se déposer dans une catégorie ou directement dans un niveau
      return drop.type === 'category' || drop.type === 'competence-level'
    }

    return false
  }

  /**
   * Effectue le déplacement et met à jour la base de données
   */
  const performMove = async (drag: DragData, drop: DropZone) => {
    isSaving.value = true
    saveError.value = ''
    saveSuccess.value = ''

    try {
      if (drag.type === 'category') {
        await moveCategoryToLevel(drag, drop)
      } else if (drag.type === 'apprentissage') {
        await moveApprentissageToCategory(drag, drop)
      }

      saveSuccess.value = 'Déplacement effectué avec succès'
      setTimeout(() => { saveSuccess.value = '' }, 3000)

    } catch (error: any) {
      console.error('❌ Error during move operation:', error)
      saveError.value = error.message || 'Erreur lors du déplacement'
      setTimeout(() => { saveError.value = '' }, 5000)
    } finally {
      isSaving.value = false
    }
  }

  /**
   * Déplace un apprentissage critique vers un autre niveau
   */
  const moveCategoryToLevel = async (drag: DragData, drop: DropZone) => {
    console.log('🔄 Moving category to level:', { 
      categoryId: drag.id, 
      newCompetenceId: drop.competenceId, 
      newLevel: drop.level 
    })

    // Mettre à jour l'apprentissage critique
    const { error } = await apprentissageCategoryService.updateCategory(drag.id, {
      competence_id: drop.competenceId,
      level: drop.level,
      title: drag.data.title,
      description: drag.data.description
    })

    if (error) {
      throw new Error('Impossible de déplacer l\'apprentissage critique')
    }

    // Émettre l'événement pour mettre à jour l'interface
    window.dispatchEvent(new CustomEvent('category-moved', {
      detail: { categoryId: drag.id, newCompetenceId: drop.competenceId, newLevel: drop.level }
    }))
  }

  /**
   * Déplace un apprentissage vers un autre apprentissage critique
   */
  const moveApprentissageToCategory = async (drag: DragData, drop: DropZone) => {
    console.log('🔄 Moving apprentissage to category:', { 
      apprentissageId: drag.id, 
      newCompetenceId: drop.competenceId, 
      newLevel: drop.level,
      newCategoryId: drop.categoryId 
    })

    // Mettre à jour l'apprentissage
    const updateData = {
      competence_id: drop.competenceId,
      level: drop.level,
      title: drag.data.title,
      description: drag.data.description,
      evaluation: drag.data.evaluation,
      argumentaire: drag.data.argumentaire,
      category_id: drop.categoryId || null
    }

    const { error } = await apprentissageService.updateApprentissage(drag.id, updateData)

    if (error) {
      throw new Error('Impossible de déplacer l\'apprentissage')
    }

    // Émettre l'événement pour mettre à jour l'interface
    window.dispatchEvent(new CustomEvent('apprentissage-moved', {
      detail: { 
        apprentissageId: drag.id, 
        newCompetenceId: drop.competenceId, 
        newLevel: drop.level,
        newCategoryId: drop.categoryId 
      }
    }))
  }

  /**
   * Enregistre une zone de drop
   */
  const registerDropZone = (
    id: string, 
    type: DropZone['type'], 
    competenceId: string, 
    level: number, 
    categoryId?: string
  ) => {
    dropZones.value.set(id, {
      type,
      competenceId,
      level,
      categoryId
    })
  }

  /**
   * Supprime une zone de drop
   */
  const unregisterDropZone = (id: string) => {
    dropZones.value.delete(id)
  }

  /**
   * Nettoie l'état du drag
   */
  const cleanupDrag = () => {
    isDragging.value = false
    dragData.value = null
    activeDropZone.value = null
    
    // Nettoyer les classes CSS
    document.body.classList.remove('dragging')
    document.querySelectorAll('.drag-source').forEach(el => {
      el.classList.remove('drag-source')
    })
    document.querySelectorAll('.drop-zone-active').forEach(el => {
      el.classList.remove('drop-zone-active')
    })

    // Supprimer l'aperçu
    if (dragPreview.value) {
      document.body.removeChild(dragPreview.value)
      dragPreview.value = null
    }
  }

  /**
   * Gère la fin du drag (succès ou échec)
   */
  const handleDragEnd = (event: DragEvent) => {
    console.log('🏁 Drag ended')
    cleanupDrag()
  }

  /**
   * Annule le drag en cours
   */
  const cancelDrag = () => {
    console.log('❌ Drag cancelled')
    cleanupDrag()
  }

  return {
    // État
    isDragging,
    dragData,
    activeDropZone,
    isSaving,
    saveError,
    saveSuccess,

    // Méthodes principales
    startDrag,
    handleDragEnter,
    handleDragLeave,
    handleDragOver,
    handleDrop,
    handleDragEnd,
    cancelDrag,

    // Gestion des zones de drop
    registerDropZone,
    unregisterDropZone,

    // Utilitaires
    canDrop,
    cleanupDrag
  }
}