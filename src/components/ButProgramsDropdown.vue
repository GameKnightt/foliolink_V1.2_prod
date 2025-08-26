<template>
  <div class="relative" ref="dropdownRef">
    <!-- Trigger Button -->
    <button
      @click="toggleDropdown"
      class="flex items-center justify-center space-x-2 glass-card px-6 py-3 hover:bg-white/20 transition-all duration-300 group w-full sm:w-auto h-12"
      :class="{ 'bg-white/20': isOpen }"
    >
      <span class="text-xl">🎓</span>
      <span class="text-white font-medium text-sm whitespace-nowrap">Programmes BUT</span>
      <ChevronDownIcon 
        class="w-4 h-4 text-gray-300 transition-transform duration-300"
        :class="{ 'rotate-180': isOpen }"
      />
    </button>

    <!-- Dropdown Menu -->
    <div 
      v-if="isOpen"
      class="absolute top-full left-0 sm:right-0 sm:left-auto mt-2 w-80 max-w-[90vw] glass-card rounded-xl shadow-2xl border border-white/20 z-50 animate-dropdown-enter"
    >
      <!-- Header -->
      <div class="px-4 py-3 border-b border-white/20">
        <h3 class="text-white font-semibold text-sm flex items-center">
          <span class="mr-2">📚</span>
          Programmes Nationaux BUT
        </h3>
        <p class="text-gray-300 text-xs mt-1">Cliquez pour ouvrir le programme officiel</p>
      </div>

      <!-- Search -->
      <div class="p-3 border-b border-white/20">
        <div class="relative">
          <MagnifyingGlassIcon class="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-400" />
          <input
            v-model="searchTerm"
            type="text"
            placeholder="Rechercher un BUT..."
            class="w-full pl-10 pr-4 py-2 bg-white/5 border border-white/10 rounded-lg text-white placeholder-gray-400 focus:ring-2 focus:ring-accent-400 focus:border-accent-400 transition-colors text-sm"
          />
        </div>
      </div>

      <!-- Categories and Programs -->
      <div class="max-h-96 overflow-y-auto">
        <div v-if="searchTerm" class="p-2">
          <!-- Search Results -->
          <div v-if="searchResults.length > 0" class="space-y-1">
            <button
              v-for="but in searchResults"
              :key="but.id"
              @click="openProgram(but)"
              class="w-full text-left px-3 py-2 rounded-lg hover:bg-white/10 transition-colors group"
            >
              <div class="flex items-center justify-between">
                <div class="flex-1">
                  <div class="text-white font-medium text-sm">{{ but.name }}</div>
                  <div class="text-gray-300 text-xs line-clamp-1">{{ but.fullName }}</div>
                </div>
                <div class="text-gray-400 group-hover:text-accent-400 transition-colors">
                  <ArrowTopRightOnSquareIcon class="w-4 h-4" />
                </div>
              </div>
            </button>
          </div>
          <div v-else class="text-center py-4">
            <div class="text-gray-400 text-sm">Aucun BUT trouvé</div>
          </div>
        </div>

        <div v-else>
          <!-- Categories -->
          <div v-for="category in butCategories" :key="category.id" class="border-b border-white/10 last:border-b-0">
            <!-- Category Header -->
            <div class="px-4 py-3 bg-white/5">
              <h4 class="text-white font-medium text-sm flex items-center">
                <span class="mr-2">{{ category.icon }}</span>
                {{ category.name }}
                <span class="ml-2 text-xs text-gray-400">({{ getButByCategory(category.id).length }})</span>
              </h4>
            </div>

            <!-- BUT Programs in Category -->
            <div class="p-2 space-y-1">
              <button
                v-for="but in getButByCategory(category.id)"
                :key="but.id"
                @click="openProgram(but)"
                class="w-full text-left px-3 py-2 rounded-lg hover:bg-white/10 transition-colors group"
              >
                <div class="flex items-center justify-between">
                  <div class="flex-1">
                    <div class="text-white font-medium text-sm">{{ but.name }}</div>
                    <div class="text-gray-300 text-xs line-clamp-2">{{ but.fullName }}</div>
                  </div>
                  <div class="text-gray-400 group-hover:text-accent-400 transition-colors">
                    <ArrowTopRightOnSquareIcon class="w-4 h-4" />
                  </div>
                </div>
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Footer -->
      <div class="px-4 py-3 border-t border-white/20 bg-white/5">
        <p class="text-gray-400 text-xs text-center">
          📄 Programmes officiels du Ministère de l'Enseignement Supérieur
        </p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { ChevronDownIcon, MagnifyingGlassIcon, ArrowTopRightOnSquareIcon } from '@heroicons/vue/24/outline'
import { butPrograms, butCategories, getButByCategory, searchBut, type ButProgram } from '../data/butPrograms'

const isOpen = ref(false)
const searchTerm = ref('')
const dropdownRef = ref<HTMLElement>()

const searchResults = computed(() => {
  if (!searchTerm.value) return []
  return searchBut(searchTerm.value)
})

const toggleDropdown = () => {
  isOpen.value = !isOpen.value
  if (isOpen.value) {
    searchTerm.value = ''
  }
}

const closeDropdown = () => {
  isOpen.value = false
  searchTerm.value = ''
}

const openProgram = (but: ButProgram) => {
  // Open PDF in new tab
  window.open(but.pdfUrl, '_blank', 'noopener,noreferrer')
  closeDropdown()
  
  // Optional: Track analytics
  console.log(`Opened BUT program: ${but.name} - ${but.fullName}`)
}

// Close dropdown when clicking outside
const handleClickOutside = (event: Event) => {
  if (dropdownRef.value && !dropdownRef.value.contains(event.target as Node)) {
    closeDropdown()
  }
}

// Close dropdown on Escape key
const handleKeydown = (event: KeyboardEvent) => {
  if (event.key === 'Escape' && isOpen.value) {
    closeDropdown()
  }
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
  document.addEventListener('keydown', handleKeydown)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
  document.removeEventListener('keydown', handleKeydown)
})
</script>

<style scoped>
@keyframes dropdown-enter {
  from {
    opacity: 0;
    transform: translateY(-10px) scale(0.95);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

.animate-dropdown-enter {
  animation: dropdown-enter 0.2s ease-out;
}

.line-clamp-1 {
  display: -webkit-box;
  -webkit-line-clamp: 1;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>