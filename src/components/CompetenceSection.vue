<template>
  <div :id="`competence-${competence.id}`" class="card p-8">
    <!-- Header -->
    <div class="flex items-start justify-between mb-8 cursor-pointer" @click="toggleCompetenceCollapse">
      <div class="flex items-start space-x-4">
        <div 
          class="w-16 h-16 rounded-2xl flex items-center justify-center text-3xl"
          :class="competence.color === 'primary' ? 'bg-gradient-primary' : 'bg-gradient-accent'"
        >
          {{ competence.icon }}
        </div>
        <div>
          <h2 class="text-3xl font-bold text-gray-900 dark:text-white mb-2">
            {{ competence.title }}
            <button 
              class="ml-3 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 transition-colors"
              @click.stop="toggleCompetenceCollapse"
            >
              <ChevronDownIcon 
                class="w-6 h-6 transition-transform duration-300"
                :class="{ 'rotate-180': isCompetenceCollapsed }"
              />
            </button>
          </h2>
          <p class="text-xl text-gray-600 dark:text-gray-300 mb-3">
            {{ competence.subtitle }}
          </p>
          <p class="text-gray-600 dark:text-gray-400 leading-relaxed max-w-3xl">
            {{ competence.description }}
          </p>
        </div>
      </div>
      <div v-if="isAuthenticated" class="flex items-center space-x-2 ml-4">
        <button 
          @click="$emit('edit-competence', competence)"
          @click.stop
          class="p-2 text-gray-400 hover:text-primary-600 dark:hover:text-primary-400 transition-colors"
          title="Modifier la compétence"
        >
          <PencilIcon class="w-5 h-5" />
        </button>
        <button 
          @click="$emit('delete-competence', competence.id)"
          @click.stop
          class="p-2 text-gray-400 hover:text-red-600 dark:hover:text-red-400 transition-colors"
          title="Supprimer la compétence"
        >
          <TrashIcon class="w-5 h-5" />
        </button>
      </div>
    </div>

    <!-- Levels -->
    <div 
      v-show="!isCompetenceCollapsed"
      class="space-y-8 transition-all duration-300 ease-in-out"
    >
      <div 
        v-for="level in getAllLevels(competence.levels)" 
        :key="level"
        class="border-l-4 border-primary-300 dark:border-primary-600 pl-6"
      >
        <div class="flex items-center justify-between mb-4 cursor-pointer" @click="toggleLevelCollapse(level)">
          <h3 class="text-xl font-semibold text-gray-900 dark:text-white">
            Niveau {{ level }}
            <button 
              class="ml-2 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 transition-colors"
              @click.stop="toggleLevelCollapse(level)"
            >
              <ChevronDownIcon 
                class="w-5 h-5 transition-transform duration-300"
                :class="{ 'rotate-180': isLevelCollapsed(level) }"
              />
            </button>
          </h3>
          <!-- Mobile Action Menu for Level Actions -->
          <MobileActionMenu v-if="isAuthenticated" title="Actions" icon="➕" @click.stop>
            <!-- Desktop Buttons -->
            <template #desktop-buttons>
              <!-- Add Apprentissage Critique Button (creates category) -->
              <button 
                @click="$emit('add-category', competence.id, level)"
                @click.stop
                class="btn-secondary text-sm px-4 py-2 flex items-center space-x-2 relative group transition-all duration-300 hover:scale-105"
                title="Créer un apprentissage critique"
              >
                <PlusIcon class="w-4 h-4" />
                <span>Ajouter un apprentissage critique</span>
              </button>
              
              <!-- Add Apprentissage Button (creates individual apprentissage) -->
              <slot name="add-button" :competence-id="competence.id" :level="level">
                <button 
                  @click="$emit('add-apprentissage', competence.id, level)"
                  @click.stop
                  class="btn-secondary text-sm px-4 py-2 flex items-center space-x-2 relative group transition-all duration-300 hover:scale-105"
                  :class="{ 
                    'opacity-60 cursor-not-allowed filter blur-[1px] pointer-events-none': !canCreateApprentissage,
                    'hover:shadow-lg': canCreateApprentissage
                  }"
                  title="Ajouter un apprentissage"
                >
                  <div v-if="!canCreateApprentissage" class="absolute -top-2 -right-2 w-6 h-6 bg-red-500 rounded-full flex items-center justify-center shadow-lg z-10 animate-pulse">
                    <span class="text-white text-xs">🔒</span>
                  </div>
                  <div v-if="!canCreateApprentissage" class="absolute inset-0 bg-gray-900/20 backdrop-blur-[1px] rounded-xl"></div>
                  <FolderPlusIcon class="w-4 h-4" />
                  <span>Ajouter un apprentissage détaillé</span>
                </button>
              </slot>
            </template>
            
            <!-- Mobile Buttons -->
            <template #mobile-buttons>
              <!-- Add Apprentissage Critique Button Mobile -->
              <button 
                @click="$emit('add-category', competence.id, level)"
                @click.stop
                class="w-full btn-secondary h-12 px-4 text-sm font-semibold flex items-center justify-center space-x-2"
              >
                <PlusIcon class="w-4 h-4" />
                <span>Ajouter un apprentissage critique</span>
              </button>
              
              <!-- Add Apprentissage Button Mobile -->
              <button 
                @click="$emit('add-apprentissage', competence.id, level)"
                @click.stop
                class="w-full btn-secondary h-12 px-4 text-sm font-semibold flex items-center justify-center space-x-2 relative group"
                :class="{ 
                  'opacity-60 cursor-not-allowed filter blur-[1px]': !canCreateApprentissage
                }"
              >
                <div v-if="!canCreateApprentissage" class="absolute -top-2 -right-2 w-6 h-6 bg-red-500 rounded-full flex items-center justify-center shadow-lg z-10">
                  <span class="text-white text-xs">🔒</span>
                </div>
                <FolderPlusIcon class="w-4 h-4" />
                <span>Ajouter un apprentissage détaillé</span>
              </button>
            </template>
          </MobileActionMenu>
          
          <!-- Non-authenticated user message -->
          <div v-else class="text-right">
            <p class="text-gray-500 dark:text-gray-400 text-sm">
              Connectez-vous pour ajouter des apprentissages
            </p>
          </div>
        </div>

        <!-- Categories and Apprentissages for this level -->
        <div 
          v-show="!isLevelCollapsed(level)"
          class="space-y-6 transition-all duration-300 ease-in-out"
        >
          <!-- Categories -->
          <div 
            v-for="category in getCategoriesForLevel(competence.id, level)"
            :key="category.id"
            class="bg-white/5 dark:bg-gray-700/30 rounded-xl p-6 border border-white/10 dark:border-gray-600/30 relative group"
            @contextmenu="handleCategoryRightClick($event, competence.id, level, category.id)"
          >
            <!-- Category Header -->
            <div class="flex items-center justify-between mb-4 cursor-pointer" @click="toggleCategoryCollapse(category.id)">
              <div class="flex items-center space-x-3">
                <div class="w-8 h-8 bg-accent-400/20 rounded-lg flex items-center justify-center">
                  <FolderIcon class="w-5 h-5 text-accent-400" />
                </div>
                <div>
                  <h4 class="text-lg font-semibold text-gray-900 dark:text-white">{{ category.title }}</h4>
                  <p v-if="category.description" class="text-sm text-gray-600 dark:text-gray-400">{{ category.description }}</p>
                </div>
                <button 
                  class="ml-2 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 transition-colors"
                  @click.stop="toggleCategoryCollapse(category.id)"
                >
                  <ChevronDownIcon 
                    class="w-4 h-4 transition-transform duration-300"
                    :class="{ 'rotate-180': isCategoryCollapsed(category.id) }"
                  />
                </button>
              </div>
              
              <!-- Category Actions -->
              <div v-if="isAuthenticated" class="flex items-center space-x-2">
                <!-- Add Apprentissage to Category Button -->
                <button 
                  @click="$emit('add-apprentissage', competence.id, level, category.id)"
                  @click.stop
                  class="p-1 text-gray-400 hover:text-accent-400 transition-colors relative group"
                  :class="{ 
                    'opacity-60 cursor-not-allowed filter blur-[1px]': !canCreateApprentissage
                  }"
                  title="Ajouter un apprentissage à cette catégorie"
                >
                  <div v-if="!canCreateApprentissage" class="absolute -top-1 -right-1 w-4 h-4 bg-red-500 rounded-full flex items-center justify-center shadow-lg z-10">
                    <span class="text-white text-xs">🔒</span>
                  </div>
                  <PlusIcon class="w-4 h-4" />
                </button>
                <button 
                  @click="$emit('edit-category', category)"
                  @click.stop
                  class="p-1 text-gray-400 hover:text-primary-600 dark:hover:text-primary-400 transition-colors"
                  title="Modifier la catégorie"
                >
                  <PencilIcon class="w-4 h-4" />
                </button>
                <button 
                  @click="$emit('delete-category', category.id)"
                  @click.stop
                  class="p-1 text-gray-400 hover:text-red-600 dark:hover:text-red-400 transition-colors"
                  title="Supprimer la catégorie"
                >
                  <TrashIcon class="w-4 h-4" />
                </button>
              </div>
            </div>
            
            <!-- Quick Add Button (visible on hover) -->
            <div 
              v-if="isAuthenticated && !isCategoryCollapsed(category.id)"
              class="absolute top-2 right-16 opacity-0 group-hover:opacity-100 transition-all duration-300"
            >
              <button 
                @click="$emit('add-apprentissage', competence.id, level, category.id)"
                @click.stop
                class="bg-accent-500 hover:bg-accent-600 text-white p-2 rounded-lg shadow-lg transition-all duration-300 hover:scale-105 flex items-center space-x-1"
                :class="{ 
                  'opacity-60 cursor-not-allowed filter blur-[1px]': !canCreateApprentissage
                }"
                title="Ajouter rapidement un apprentissage"
              >
                <div v-if="!canCreateApprentissage" class="absolute -top-1 -right-1 w-4 h-4 bg-red-500 rounded-full flex items-center justify-center shadow-lg z-10">
                  <span class="text-white text-xs">🔒</span>
                </div>
                <PlusIcon class="w-4 h-4" />
                <span class="text-xs font-medium">Ajouter</span>
              </button>
            </div>
            
            <!-- Apprentissages in this category -->
            <div 
              v-show="!isCategoryCollapsed(category.id)"
              class="grid grid-cols-1 lg:grid-cols-2 gap-4 transition-all duration-300 ease-in-out"
            >
              <ApprentissageCard
                v-for="apprentissage in getApprentissagesForCategory(category.id)"
                :key="apprentissage.id"
                :apprentissage="apprentissage"
                :is-featured="isFeatured(apprentissage.id)"
                @edit="$emit('edit-apprentissage', $event)"
                @delete="$emit('delete-apprentissage', $event)"
                @view="$emit('view-apprentissage', $event)"
                @open-project="$emit('open-project', $event)"
                @toggle-featured="$emit('toggle-featured', $event)"
              >
                <template #action-buttons>
                  <slot name="apprentissage-actions" :apprentissage="apprentissage">
                    <button
                      v-if="isAuthenticated" 
                      @click="$emit('edit-apprentissage', apprentissage)"
                      @click.stop
                      class="p-1 text-gray-400 hover:text-primary-600 dark:hover:text-primary-400 opacity-0 group-hover:opacity-100 transition-opacity"
                      title="Modifier"
                    >
                      <PencilIcon class="w-4 h-4" />
                    </button>
                    <button 
                      v-if="isAuthenticated"
                      @click="$emit('toggle-featured', apprentissage)"
                      @click.stop
                      class="p-1 transition-opacity"
                      :class="isFeatured(apprentissage.id) ? 'text-accent-400 opacity-100' : 'text-gray-400 hover:text-accent-400 opacity-0 group-hover:opacity-100'"
                      :title="isFeatured(apprentissage.id) ? 'Retirer des vedettes' : 'Épingler en vedette'"
                    >
                      <span class="text-sm">{{ isFeatured(apprentissage.id) ? '⭐' : '☆' }}</span>
                    </button>
                    <button
                      v-if="isAuthenticated" 
                      @click="$emit('delete-apprentissage', apprentissage.id)"
                      @click.stop
                      class="p-1 text-gray-400 hover:text-red-600 dark:hover:text-red-400 opacity-0 group-hover:opacity-100 transition-opacity"
                      title="Supprimer"
                    >
                      <TrashIcon class="w-4 h-4" />
                    </button>
                  </slot>
                </template>
              </ApprentissageCard>
            </div>
            
            <!-- Empty category state -->
            <div 
              v-if="getApprentissagesForCategory(category.id).length === 0 && !isCategoryCollapsed(category.id)"
              class="text-center py-8 text-gray-500 dark:text-gray-400"
            >
              <FolderIcon class="w-8 h-8 mx-auto mb-2 opacity-50" />
              <p class="text-sm">Aucun apprentissage dans cette catégorie</p>
              <button 
                v-if="isAuthenticated"
                @click="$emit('add-apprentissage', competence.id, level, category.id)"
                class="mt-3 text-accent-400 hover:text-accent-300 text-sm transition-colors"
                :class="{ 
                  'opacity-60 cursor-not-allowed': !canCreateApprentissage
                }"
              >
                <PlusIcon class="w-4 h-4 inline mr-1" />
                Ajouter un apprentissage
              </button>
            </div>
          </div>
          
          <!-- Uncategorized Apprentissages -->
          <div 
            v-if="getUncategorizedApprentissages(competence.id, level).length > 0 && !isLevelCollapsed(level)"
            class="bg-gray-50/5 dark:bg-gray-800/30 rounded-xl p-6 border border-gray-200/20 dark:border-gray-700/30"
          >
            <div class="flex items-center space-x-3 mb-4">
              <div class="w-8 h-8 bg-gray-400/20 rounded-lg flex items-center justify-center">
                <DocumentTextIcon class="w-5 h-5 text-gray-400" />
              </div>
              <div>
                <h4 class="text-lg font-semibold text-gray-900 dark:text-white">Apprentissages détaillés situés dans aucun apprentissage critique</h4>
              </div>
            </div>
            
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
              <ApprentissageCard
                v-for="apprentissage in getUncategorizedApprentissages(competence.id, level)"
                :key="apprentissage.id"
                :apprentissage="apprentissage"
                :is-featured="isFeatured(apprentissage.id)"
                @edit="$emit('edit-apprentissage', $event)"
                @delete="$emit('delete-apprentissage', $event)"
                @view="$emit('view-apprentissage', $event)"
                @open-project="$emit('open-project', $event)"
                @toggle-featured="$emit('toggle-featured', $event)"
              >
                <template #action-buttons>
                  <slot name="apprentissage-actions" :apprentissage="apprentissage">
                    <button
                      v-if="isAuthenticated" 
                      @click="$emit('edit-apprentissage', apprentissage)"
                      @click.stop
                      class="p-1 text-gray-400 hover:text-primary-600 dark:hover:text-primary-400 opacity-0 group-hover:opacity-100 transition-opacity"
                      title="Modifier"
                    >
                      <PencilIcon class="w-4 h-4" />
                    </button>
                    <button 
                      v-if="isAuthenticated"
                      @click="$emit('toggle-featured', apprentissage)"
                      @click.stop
                      class="p-1 transition-opacity"
                      :class="isFeatured(apprentissage.id) ? 'text-accent-400 opacity-100' : 'text-gray-400 hover:text-accent-400 opacity-0 group-hover:opacity-100'"
                      :title="isFeatured(apprentissage.id) ? 'Retirer des vedettes' : 'Épingler en vedette'"
                    >
                      <span class="text-sm">{{ isFeatured(apprentissage.id) ? '⭐' : '☆' }}</span>
                    </button>
                    <button
                      v-if="isAuthenticated" 
                      @click="$emit('delete-apprentissage', apprentissage.id)"
                      @click.stop
                      class="p-1 text-gray-400 hover:text-red-600 dark:hover:text-red-400 opacity-0 group-hover:opacity-100 transition-opacity"
                      title="Supprimer"
                    >
                      <TrashIcon class="w-4 h-4" />
                    </button>
                  </slot>
                </template>
              </ApprentissageCard>
            </div>
          </div>
          
          <!-- Direct Apprentissages (for non-authenticated users) -->
          <div 
            v-if="getDirectApprentissagesForLevel(competence.id, level).length > 0 && !isLevelCollapsed(level)"
            class="grid grid-cols-1 lg:grid-cols-2 gap-4"
          >
            <ApprentissageCard
              v-for="apprentissage in getDirectApprentissagesForLevel(competence.id, level)"
              :key="apprentissage.id"
              :apprentissage="apprentissage"
              :is-featured="isFeatured(apprentissage.id)"
              @edit="$emit('edit-apprentissage', $event)"
              @delete="$emit('delete-apprentissage', $event)"
              @view="$emit('view-apprentissage', $event)"
              @open-project="$emit('open-project', $event)"
              @toggle-featured="$emit('toggle-featured', $event)"
            >
              <template #action-buttons>
                <slot name="apprentissage-actions" :apprentissage="apprentissage">
                  <button
                    v-if="isAuthenticated" 
                    @click="$emit('edit-apprentissage', apprentissage)"
                    @click.stop
                    class="p-1 text-gray-400 hover:text-primary-600 dark:hover:text-primary-400 opacity-0 group-hover:opacity-100 transition-opacity"
                    title="Modifier"
                  >
                    <PencilIcon class="w-4 h-4" />
                  </button>
                  <button 
                    v-if="isAuthenticated"
                    @click="$emit('toggle-featured', apprentissage)"
                    @click.stop
                    class="p-1 transition-opacity"
                    :class="isFeatured(apprentissage.id) ? 'text-accent-400 opacity-100' : 'text-gray-400 hover:text-accent-400 opacity-0 group-hover:opacity-100'"
                    :title="isFeatured(apprentissage.id) ? 'Retirer des vedettes' : 'Épingler en vedette'"
                  >
                    <span class="text-sm">{{ isFeatured(apprentissage.id) ? '⭐' : '☆' }}</span>
                  </button>
                  <button
                    v-if="isAuthenticated" 
                    @click="$emit('delete-apprentissage', apprentissage.id)"
                    @click.stop
                    class="p-1 text-gray-400 hover:text-red-600 dark:hover:text-red-400 opacity-0 group-hover:opacity-100 transition-opacity"
                    title="Supprimer"
                  >
                    <TrashIcon class="w-4 h-4" />
                  </button>
                </slot>
              </template>
            </ApprentissageCard>
          </div>

          <!-- Empty state -->
          <div 
            v-if="getAllApprentissagesForLevel(competence.id, level).length === 0 && isAuthenticated && !isLevelCollapsed(level)"
            class="text-center py-12 text-gray-500 dark:text-gray-400"
          >
            <AcademicCapIcon class="w-12 h-12 mx-auto mb-4 opacity-50" />
            <p>Aucun apprentissage critique pour ce niveau</p>
            <p class="text-sm">Cliquez sur "Ajouter un apprentissage critique" pour commencer</p>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Context Menu -->
    <div 
      v-if="showContextMenu"
      class="fixed z-50 bg-white dark:bg-gray-800 rounded-lg shadow-xl border border-gray-200 dark:border-gray-600 py-2 min-w-48"
      :style="{ top: contextMenuPosition.y + 'px', left: contextMenuPosition.x + 'px' }"
      @click="hideContextMenu"
    >
      <button 
        @click="handleContextMenuAction"
        class="w-full text-left px-4 py-2 text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors flex items-center space-x-2"
        :class="{ 
          'opacity-60 cursor-not-allowed': !canCreateApprentissage
        }"
      >
        <PlusIcon class="w-4 h-4" />
        <span>Ajouter un apprentissage détaillé</span>
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { PlusIcon, AcademicCapIcon, PencilIcon, TrashIcon, FolderPlusIcon, FolderIcon, DocumentTextIcon, ChevronDownIcon } from '@heroicons/vue/24/outline'
import ApprentissageCard from './ApprentissageCard.vue'
import type { Competence, Apprentissage } from '../data/portfolio'
import { authService } from '../lib/supabase'
import MobileActionMenu from './MobileActionMenu.vue'
import { ref, onMounted, computed } from 'vue'

const props = defineProps<{
  competence: Competence
  apprentissages: Apprentissage[]
  featuredApprentissages?: string[]
  userLimits?: any
  categories?: any[]
  isAuthenticated: boolean
}>()

const canCreateApprentissage = computed(() => {
  if (!props.userLimits) return true
  if (props.userLimits.isPremium) return true
  return props.userLimits.current.apprentissages < props.userLimits.limits.apprentissages
})

const isAuthenticated = ref(false)

// Collapse state management
const isCompetenceCollapsed = ref(false)
const collapsedLevels = ref<Set<number>>(new Set())
const collapsedCategories = ref<Set<string>>(new Set())

// Context menu state
const showContextMenu = ref(false)
const contextMenuPosition = ref({ x: 0, y: 0 })
const contextMenuData = ref<{ competenceId: string, level: number, categoryId?: string } | null>(null)

onMounted(async () => {
  const user = await authService.getCurrentUser()
  isAuthenticated.value = !!user
  
  // Load collapse state from localStorage
  loadCollapseState()
  
  // Add global click listener to hide context menu
  document.addEventListener('click', hideContextMenu)
  document.addEventListener('contextmenu', hideContextMenu)
})

// Cleanup event listeners
import { onUnmounted } from 'vue'
onUnmounted(() => {
  document.removeEventListener('click', hideContextMenu)
  document.removeEventListener('contextmenu', hideContextMenu)
})

// Fonction pour générer tous les niveaux de 1 jusqu'au maximum
const getAllLevels = (maxLevels: number) => {
  const levels = []
  for (let i = 1; i <= maxLevels; i++) {
    levels.push(i)
  }
  return levels
}

const emit = defineEmits([
  'add-apprentissage', 
  'edit-apprentissage', 
  'delete-apprentissage', 
  'view-apprentissage', 
  'open-project', 
  'edit-competence', 
  'delete-competence', 
  'toggle-featured', 
  'show-premium-notification',
  'add-category',
  'edit-category',
  'delete-category'
])

const isFeatured = (apprentissageId: string) => {
  return props.featuredApprentissages?.includes(apprentissageId) || false
}

// Collapse management functions
const toggleCompetenceCollapse = () => {
  isCompetenceCollapsed.value = !isCompetenceCollapsed.value
  saveCollapseState()
}

const toggleLevelCollapse = (level: number) => {
  if (collapsedLevels.value.has(level)) {
    collapsedLevels.value.delete(level)
  } else {
    collapsedLevels.value.add(level)
  }
  saveCollapseState()
}

const toggleCategoryCollapse = (categoryId: string) => {
  if (collapsedCategories.value.has(categoryId)) {
    collapsedCategories.value.delete(categoryId)
  } else {
    collapsedCategories.value.add(categoryId)
  }
  saveCollapseState()
}

const isLevelCollapsed = (level: number) => {
  return collapsedLevels.value.has(level)
}

const isCategoryCollapsed = (categoryId: string) => {
  return collapsedCategories.value.has(categoryId)
}

const saveCollapseState = () => {
  const state = {
    competence: isCompetenceCollapsed.value,
    levels: Array.from(collapsedLevels.value),
    categories: Array.from(collapsedCategories.value)
  }
  localStorage.setItem(`collapse-state-${props.competence.id}`, JSON.stringify(state))
}

const loadCollapseState = () => {
  try {
    const saved = localStorage.getItem(`collapse-state-${props.competence.id}`)
    if (saved) {
      const state = JSON.parse(saved)
      isCompetenceCollapsed.value = state.competence || false
      collapsedLevels.value = new Set(state.levels || [])
      collapsedCategories.value = new Set(state.categories || [])
    }
  } catch (error) {
    console.error('Error loading collapse state:', error)
  }
}

// Context menu functions
const handleCategoryRightClick = (event: MouseEvent, competenceId: string, level: number, categoryId: string) => {
  if (!isAuthenticated.value) return
  
  event.preventDefault()
  contextMenuPosition.value = { x: event.clientX, y: event.clientY }
  contextMenuData.value = { competenceId, level, categoryId }
  showContextMenu.value = true
}

const hideContextMenu = () => {
  showContextMenu.value = false
  contextMenuData.value = null
}

const handleContextMenuAction = () => {
  if (contextMenuData.value && canCreateApprentissage.value) {
    emit('add-apprentissage', 
      contextMenuData.value.competenceId, 
      contextMenuData.value.level, 
      contextMenuData.value.categoryId
    )
  }
  hideContextMenu()
}

// Helper functions for categories
const getCategoriesForLevel = (competenceId: string, level: number) => {
  if (!props.categories) return []
  return props.categories.filter(cat => 
    cat.competence_id === competenceId && cat.level === level
  ).sort((a, b) => (a.order_index || 0) - (b.order_index || 0))
}

const getApprentissagesForCategory = (categoryId: string) => {
  return props.apprentissages.filter(app => app.categoryId === categoryId)
}

const getUncategorizedApprentissages = (competenceId: string, level: number) => {
  return props.apprentissages.filter(app => 
    app.competenceId === competenceId && 
    app.level === level && 
    !app.categoryId
  )
}

// New function to get apprentissages for display (direct for non-authenticated, uncategorized for authenticated)
const getDirectApprentissagesForLevel = (competenceId: string, level: number) => {
  if (isAuthenticated.value) {
    // For authenticated users, only show uncategorized apprentissages here
    return []
  } else {
    // For non-authenticated users, show all apprentissages for this level directly
    return props.apprentissages.filter(app => 
      app.competenceId === competenceId && app.level === level
    )
  }
}

const getAllApprentissagesForLevel = (competenceId: string, level: number) => {
  return props.apprentissages.filter(app => 
    app.competenceId === competenceId && app.level === level
  )
}
</script>