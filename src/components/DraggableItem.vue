<!-- 
  Composant d'élément draggable réutilisable
  Gère le drag d'apprentissages et d'apprentissages critiques
-->
<template>
  <div
    :draggable="isDraggable"
    class="draggable-item transition-all duration-200 ease-in-out"
    :class="[
      baseClasses,
      {
        'dragging': isDragSource,
        'drag-disabled': !isDraggable,
        'drag-hover': isHovering && isDraggable
      }
    ]"
    @dragstart="handleDragStart"
    @dragend="handleDragEnd"
    @mouseenter="isHovering = true"
    @mouseleave="isHovering = false"
  >
    <!-- Indicateur de drag -->
    <div 
      v-if="isDraggable"
      class="drag-handle absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity duration-200 cursor-grab active:cursor-grabbing"
      :class="{ 'opacity-100': isHovering }"
    >
      <div class="bg-white/10 backdrop-blur-sm rounded-lg p-2">
        <svg class="w-4 h-4 text-gray-400" fill="currentColor" viewBox="0 0 24 24">
          <path d="M8 6a2 2 0 1 1-4 0 2 2 0 0 1 4 0zM8 12a2 2 0 1 1-4 0 2 2 0 0 1 4 0zM8 18a2 2 0 1 1-4 0 2 2 0 0 1 4 0zM14 6a2 2 0 1 1-4 0 2 2 0 0 1 4 0zM14 12a2 2 0 1 1-4 0 2 2 0 0 1 4 0zM14 18a2 2 0 1 1-4 0 2 2 0 0 1 4 0zM20 6a2 2 0 1 1-4 0 2 2 0 0 1 4 0zM20 12a2 2 0 1 1-4 0 2 2 0 0 1 4 0zM20 18a2 2 0 1 1-4 0 2 2 0 0 1 4 0z"/>
        </svg>
      </div>
    </div>

    <!-- Badge de type d'élément -->
    <div 
      v-if="showTypeBadge"
      class="absolute top-2 left-2 px-2 py-1 rounded-full text-xs font-medium"
      :class="typeBadgeClasses"
    >
      {{ getTypeBadgeText() }}
    </div>

    <!-- Contenu de l'élément -->
    <slot></slot>

    <!-- Overlay de drag -->
    <div 
      v-if="isDragSource"
      class="absolute inset-0 bg-accent-400/20 border-2 border-accent-400 rounded-lg pointer-events-none"
    >
      <div class="absolute inset-0 flex items-center justify-center">
        <div class="bg-black/60 backdrop-blur-sm rounded-lg px-3 py-1">
          <p class="text-white text-sm font-medium">Déplacement en cours...</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useDragDrop } from '../composables/useDragDrop'

const props = defineProps<{
  itemId: string
  itemType: 'apprentissage' | 'category'
  competenceId: string
  level: number
  categoryId?: string
  data: any
  index?: number
  isDraggable?: boolean
  baseClasses?: string
  showTypeBadge?: boolean
}>()

const {
  isDragging,
  dragData,
  startDrag,
  handleDragEnd: dragEnd
} = useDragDrop()

// État local
const isHovering = ref(false)

// Computed properties
const isDragSource = computed(() => {
  return isDragging.value && dragData.value?.id === props.itemId
})

const typeBadgeClasses = computed(() => {
  return props.itemType === 'category'
    ? 'bg-blue-500/20 text-blue-400 border border-blue-400/30'
    : 'bg-green-500/20 text-green-400 border border-green-400/30'
})

// Event handlers
const handleDragStart = (event: DragEvent) => {
  if (!props.isDraggable) {
    event.preventDefault()
    return
  }

  console.log('🎯 Drag start for:', props.itemType, props.itemId)

  startDrag(
    event,
    props.itemType,
    props.itemId,
    props.competenceId,
    props.level,
    props.data,
    props.categoryId,
    props.index || 0
  )
}

const handleDragEnd = (event: DragEvent) => {
  dragEnd(event)
  isHovering.value = false
}

// Helper methods
const getTypeBadgeText = () => {
  return props.itemType === 'category' ? 'Critique' : 'Apprentissage'
}
</script>

<style scoped>
.draggable-item {
  position: relative;
}

.draggable-item[draggable="true"] {
  cursor: grab;
}

.draggable-item[draggable="true"]:active {
  cursor: grabbing;
}

.dragging {
  opacity: 0.5;
  transform: rotate(2deg);
  z-index: 1000;
}

.drag-disabled {
  cursor: not-allowed;
  opacity: 0.6;
}

.drag-hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

/* Animation pour le feedback visuel */
@keyframes drag-pulse {
  0%, 100% {
    box-shadow: 0 0 0 0 rgba(250, 204, 21, 0.4);
  }
  50% {
    box-shadow: 0 0 0 10px rgba(250, 204, 21, 0);
  }
}

.drop-zone-active {
  animation: drag-pulse 2s infinite;
}
</style>