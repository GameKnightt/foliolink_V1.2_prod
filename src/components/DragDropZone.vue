<!-- 
  Composant de zone de drop réutilisable
  Gère l'affichage visuel et les interactions pour les zones de dépôt
-->
<template>
  <div
    :id="zoneId"
    class="drag-drop-zone transition-all duration-300 ease-in-out"
    :class="[
      baseClasses,
      {
        'drop-zone-valid': isDragging && canAcceptDrop,
        'drop-zone-invalid': isDragging && !canAcceptDrop,
        'drop-zone-active': isActive,
        'drop-zone-highlight': showHighlight
      }
    ]"
    @dragenter="handleDragEnter"
    @dragleave="handleDragLeave"
    @dragover="handleDragOver"
    @drop="handleDrop"
  >
    <!-- Indicateur visuel de zone de drop -->
    <div 
      v-if="isDragging && canAcceptDrop"
      class="drop-indicator absolute inset-0 pointer-events-none"
    >
      <!-- Animation de bordure -->
      <div class="absolute inset-0 border-2 border-dashed border-accent-400 rounded-lg animate-pulse"></div>
      
      <!-- Icône centrale -->
      <div class="absolute inset-0 flex items-center justify-center">
        <div class="bg-accent-400/20 backdrop-blur-sm rounded-full p-3">
          <span class="text-accent-400 text-2xl">{{ getDropIcon() }}</span>
        </div>
      </div>
      
      <!-- Message d'aide -->
      <div class="absolute bottom-2 left-2 right-2">
        <div class="bg-black/60 backdrop-blur-sm rounded-lg px-3 py-1">
          <p class="text-white text-xs text-center font-medium">
            {{ getDropMessage() }}
          </p>
        </div>
      </div>
    </div>

    <!-- Contenu de la zone -->
    <slot></slot>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, onUnmounted } from 'vue'
import { useDragDrop } from '../composables/useDragDrop'

const props = defineProps<{
  zoneId: string
  type: 'competence-level' | 'category' | 'apprentissage-list'
  competenceId: string
  level: number
  categoryId?: string
  baseClasses?: string
  acceptTypes?: ('apprentissage' | 'category')[]
}>()

const {
  isDragging,
  dragData,
  activeDropZone,
  registerDropZone,
  unregisterDropZone,
  handleDragEnter: dragEnter,
  handleDragLeave: dragLeave,
  handleDragOver: dragOver,
  handleDrop: drop,
  canDrop
} = useDragDrop()

// Computed properties
const isActive = computed(() => activeDropZone.value === props.zoneId)

const canAcceptDrop = computed(() => {
  if (!dragData.value) return false
  
  // Vérifier les types acceptés
  const acceptTypes = props.acceptTypes || ['apprentissage', 'category']
  if (!acceptTypes.includes(dragData.value.type)) return false

  // Vérifier avec la logique métier
  const dropZone = {
    type: props.type,
    competenceId: props.competenceId,
    level: props.level,
    categoryId: props.categoryId
  }
  
  return canDrop(dragData.value, dropZone)
})

const showHighlight = computed(() => {
  return isDragging.value && canAcceptDrop.value && !isActive.value
})

// Event handlers
const handleDragEnter = (event: DragEvent) => {
  dragEnter(event, props.zoneId)
}

const handleDragLeave = (event: DragEvent) => {
  dragLeave(event, props.zoneId)
}

const handleDragOver = (event: DragEvent) => {
  dragOver(event, props.zoneId)
}

const handleDrop = (event: DragEvent) => {
  drop(event, props.zoneId)
}

// Helper methods
const getDropIcon = () => {
  if (!dragData.value) return '📦'
  
  switch (props.type) {
    case 'competence-level':
      return dragData.value.type === 'category' ? '📁' : '📚'
    case 'category':
      return '📚'
    default:
      return '📦'
  }
}

const getDropMessage = () => {
  if (!dragData.value) return 'Déposer ici'
  
  switch (props.type) {
    case 'competence-level':
      return dragData.value.type === 'category' 
        ? 'Déplacer l\'apprentissage critique ici'
        : 'Déplacer l\'apprentissage ici'
    case 'category':
      return 'Ajouter à cet apprentissage critique'
    default:
      return 'Déposer ici'
  }
}

// Lifecycle
onMounted(() => {
  registerDropZone(
    props.zoneId,
    props.type,
    props.competenceId,
    props.level,
    props.categoryId
  )
})

onUnmounted(() => {
  unregisterDropZone(props.zoneId)
})
</script>

<style scoped>
.drag-drop-zone {
  position: relative;
  min-height: 60px;
}

.drop-zone-valid {
  background-color: rgba(250, 204, 21, 0.1);
  border-color: rgba(250, 204, 21, 0.3);
}

.drop-zone-invalid {
  background-color: rgba(239, 68, 68, 0.1);
  border-color: rgba(239, 68, 68, 0.3);
}

.drop-zone-active {
  background-color: rgba(250, 204, 21, 0.2);
  border-color: rgba(250, 204, 21, 0.5);
  transform: scale(1.02);
  box-shadow: 0 0 20px rgba(250, 204, 21, 0.3);
}

.drop-zone-highlight {
  border: 2px dashed rgba(250, 204, 21, 0.5);
}

.drop-indicator {
  z-index: 10;
}
</style>