<template>
  <div class="relative" ref="menuRef">
    <!-- Mobile Menu Button (visible only on mobile) -->
    <button
      @click="toggleMenu"
      class="md:hidden glass-card px-4 py-3 hover:bg-white/20 transition-all duration-300 group w-full flex items-center justify-between"
      :class="{ 'bg-white/20': isOpen }"
    >
      <div class="flex items-center space-x-2">
        <span class="text-xl">{{ icon }}</span>
        <span class="text-white font-medium">{{ title }}</span>
      </div>
      <svg 
        class="w-5 h-5 text-gray-300 transition-transform duration-300"
        :class="{ 'rotate-180': isOpen }"
        fill="none" 
        stroke="currentColor" 
        viewBox="0 0 24 24"
      >
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
      </svg>
    </button>

    <!-- Desktop Buttons (visible only on desktop) -->
    <div class="hidden md:flex items-center space-x-3">
      <slot name="desktop-buttons"></slot>
    </div>

    <!-- Mobile Dropdown Menu -->
    <div 
      v-if="isOpen"
      class="md:hidden absolute top-full left-0 right-0 mt-2 glass-card rounded-xl shadow-2xl border border-white/20 z-50 animate-dropdown-enter"
    >
      <div class="p-3 space-y-2">
        <slot name="mobile-buttons"></slot>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'

defineProps<{
  title: string
  icon: string
}>()

const isOpen = ref(false)
const menuRef = ref<HTMLElement>()

const toggleMenu = () => {
  isOpen.value = !isOpen.value
}

const closeMenu = () => {
  isOpen.value = false
}

// Close menu when clicking outside
const handleClickOutside = (event: Event) => {
  if (menuRef.value && !menuRef.value.contains(event.target as Node)) {
    closeMenu()
  }
}

// Close menu on Escape key
const handleKeydown = (event: KeyboardEvent) => {
  if (event.key === 'Escape' && isOpen.value) {
    closeMenu()
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
</style>