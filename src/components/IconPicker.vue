<template>
  <div class="space-y-4">
    <!-- Search -->
    <div class="relative">
      <MagnifyingGlassIcon class="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-400" />
      <input
        v-model="searchTerm"
        type="text"
        placeholder="Rechercher une icône..."
        class="w-full pl-10 pr-4 py-2 text-sm border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-accent-400 focus:border-accent-400"
      />
    </div>

    <!-- Categories -->
    <div class="flex flex-wrap gap-2">
      <button
        v-for="category in categories"
        :key="category.name"
        @click="selectedCategory = category.name"
        class="px-3 py-1 text-xs rounded-full transition-colors"
        :class="selectedCategory === category.name 
          ? 'bg-accent-400 text-gray-900' 
          : 'bg-gray-200 dark:bg-gray-600 text-gray-700 dark:text-gray-300 hover:bg-gray-300 dark:hover:bg-gray-500'"
      >
        {{ category.label }}
      </button>
    </div>

    <!-- Icons Grid -->
    <div class="grid grid-cols-8 gap-2 max-h-64 overflow-y-auto">
      <button
        v-for="icon in filteredIcons"
        :key="icon"
        type="button"
        @click="$emit('select', icon)"
        class="w-10 h-10 rounded-lg border-2 transition-all duration-200 flex items-center justify-center text-xl hover:scale-110"
        :class="modelValue === icon 
          ? 'border-accent-400 bg-accent-400/20' 
          : 'border-gray-300 dark:border-gray-600 hover:border-accent-400'"
      >
        {{ icon }}
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { MagnifyingGlassIcon } from '@heroicons/vue/24/outline'

defineProps<{
  modelValue: string
}>()

defineEmits(['select'])

const searchTerm = ref('')
const selectedCategory = ref('all')

const categories = [
  { name: 'all', label: 'Tous' },
  { name: 'tech', label: 'Technologie' },
  { name: 'education', label: 'Éducation' },
  { name: 'business', label: 'Business' },
  { name: 'science', label: 'Science' },
  { name: 'tools', label: 'Outils' },
  { name: 'communication', label: 'Communication' },
  { name: 'transport', label: 'Transport' },
  { name: 'nature', label: 'Nature' }
]

const iconsByCategory = {
  tech: ['💻', '📱', '🖥️', '⌨️', '🖱️', '💾', '💿', '📀', '🔌', '🔋', '📡', '📺', '📻', '🎮', '🕹️', '📷', '📹', '🎥', '📞', '☎️', '📠', '🔍', '💡', '🔦', '🏮', '🪔', '🕯️', '🧯', '🛢️', '💸', '💳', '💎', '⚖️', '🔧', '🔨', '⛏️', '🛠️', '⚙️', '🔩', '⚗️', '🧪', '🧬', '🔬', '🔭', '📡', '🛰️', '🚀', '🛸', '🌐', '💫', '⭐', '🌟', '✨', '⚡', '🔥', '💥'],
  education: ['📚', '📖', '📝', '✏️', '✒️', '🖊️', '🖋️', '🖍️', '📄', '📃', '📑', '📊', '📈', '📉', '🗂️', '📂', '📁', '🗃️', '🗄️', '📋', '📌', '📍', '📎', '🖇️', '📐', '📏', '🧮', '🔖', '🏷️', '📦', '📫', '📪', '📬', '📭', '📮', '🗳️', '✉️', '📧', '📨', '📩', '📤', '📥', '📜', '📃', '📄', '📰', '🗞️', '📑', '🔖', '🏷️', '💼', '👨‍🎓', '👩‍🎓', '🎓', '🏫', '🏤', '🏛️'],
  business: ['💼', '👔', '💰', '💵', '💴', '💶', '💷', '💸', '💳', '🧾', '💹', '📊', '📈', '📉', '💱', '💲', '🏦', '🏧', '💎', '⚖️', '📋', '📌', '📍', '🗂️', '📂', '📁', '🗃️', '🗄️', '📊', '📈', '📉', '💹', '📱', '☎️', '📞', '📠', '📧', '📨', '📩', '📤', '📥', '📮', '🗳️', '✉️', '📜', '📃', '📄', '📰', '🗞️', '📑'],
  science: ['🔬', '🧪', '🧬', '⚗️', '🔭', '📡', '🛰️', '🚀', '🛸', '🌐', '🌍', '🌎', '🌏', '🌕', '🌖', '🌗', '🌘', '🌑', '🌒', '🌓', '🌔', '☀️', '🌤️', '⛅', '🌦️', '🌧️', '⛈️', '🌩️', '🌨️', '❄️', '☃️', '⛄', '🌬️', '💨', '🌪️', '🌫️', '☔', '💧', '💦', '🌊', '⚡', '🔥', '💥', '☄️', '💫', '⭐', '🌟', '✨', '🌠', '🔆', '☀️', '🌞'],
  tools: ['🔧', '🔨', '⛏️', '🛠️', '⚙️', '🔩', '⚗️', '🧪', '🔬', '🔭', '📡', '🔌', '🔋', '💡', '🔦', '🏮', '🪔', '🕯️', '🧯', '🛢️', '⛽', '🚰', '🚿', '🛁', '🚽', '🧻', '🧽', '🧴', '🧷', '🧹', '🧺', '🪣', '🧊', '🧂', '🔪', '🍴', '🥄', '🍽️', '🥢', '⚖️', '🧮', '📏', '📐', '✂️', '🗃️', '🗄️', '🗑️', '🔒', '🔓', '🔑', '🗝️', '🔐', '🛡️'],
  communication: ['📱', '☎️', '📞', '📠', '📧', '📨', '📩', '📤', '📥', '📮', '🗳️', '✉️', '📜', '📃', '📄', '📰', '🗞️', '📑', '🔖', '🏷️', '📋', '📌', '📍', '🗂️', '📂', '📁', '🗃️', '🗄️', '📊', '📈', '📉', '💹', '📺', '📻', '📢', '📣', '📯', '🔔', '🔕', '🎵', '🎶', '🎼', '🎹', '🥁', '🎷', '🎺', '🎸', '🪕', '🎻', '🎤', '🎧', '📻', '🎙️'],
  transport: ['🚗', '🚕', '🚙', '🚌', '🚎', '🏎️', '🚓', '🚑', '🚒', '🚐', '🛻', '🚚', '🚛', '🚜', '🏍️', '🛵', '🚲', '🛴', '🛹', '🛼', '🚁', '🛩️', '✈️', '🛫', '🛬', '🪂', '💺', '🚀', '🛸', '🚉', '🚊', '🚝', '🚞', '🚋', '🚃', '🚋', '🚆', '🚄', '🚅', '🚈', '🚂', '🚖', '🚘', '🚍', '🚔', '🚨', '🚥', '🚦', '🛑', '🚧', '⚓', '⛵', '🛶', '🚤', '🛥️', '🛳️', '⛴️', '🚢'],
  nature: ['🌱', '🌿', '☘️', '🍀', '🎍', '🎋', '🍃', '🍂', '🍁', '🍄', '🌾', '💐', '🌷', '🌹', '🥀', '🌺', '🌸', '🌼', '🌻', '🌞', '🌝', '🌛', '🌜', '🌚', '🌕', '🌖', '🌗', '🌘', '🌑', '🌒', '🌓', '🌔', '🌙', '⭐', '🌟', '💫', '✨', '☄️', '☀️', '🌤️', '⛅', '🌦️', '🌧️', '⛈️', '🌩️', '🌨️', '❄️', '☃️', '⛄', '🌬️', '💨', '🌪️', '🌫️', '☔', '💧', '💦', '🌊']
}

const allIcons = Object.values(iconsByCategory).flat()

const filteredIcons = computed(() => {
  let icons = selectedCategory.value === 'all' 
    ? allIcons 
    : iconsByCategory[selectedCategory.value] || []
  
  if (searchTerm.value) {
    // Enhanced search functionality
    const term = searchTerm.value.toLowerCase()
    
    // Search by category keywords
    if (term.includes('tech') || term.includes('ordinateur') || term.includes('computer') || term.includes('code') || term.includes('web')) {
      icons = iconsByCategory.tech
    } else if (term.includes('education') || term.includes('école') || term.includes('school') || term.includes('étude') || term.includes('livre')) {
      icons = iconsByCategory.education
    } else if (term.includes('business') || term.includes('travail') || term.includes('work') || term.includes('argent') || term.includes('money')) {
      icons = iconsByCategory.business
    } else if (term.includes('science') || term.includes('recherche') || term.includes('research') || term.includes('labo') || term.includes('expérience')) {
      icons = iconsByCategory.science
    } else if (term.includes('outil') || term.includes('tool') || term.includes('clé') || term.includes('marteau')) {
      icons = iconsByCategory.tools
    } else if (term.includes('communication') || term.includes('message') || term.includes('téléphone') || term.includes('mail')) {
      icons = iconsByCategory.communication
    } else if (term.includes('transport') || term.includes('voiture') || term.includes('car') || term.includes('avion') || term.includes('train')) {
      icons = iconsByCategory.transport
    } else if (term.includes('nature') || term.includes('plante') || term.includes('plant') || term.includes('fleur') || term.includes('arbre')) {
      icons = iconsByCategory.nature
    } else {
      // If no category match, search through all icons (this could be enhanced with icon descriptions)
      icons = allIcons
    }
  }
  
  return icons
})
</script>