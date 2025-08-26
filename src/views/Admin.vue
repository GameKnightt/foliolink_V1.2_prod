<template>
  <div class="pt-16 min-h-screen bg-gray-50 dark:bg-gray-900">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <!-- Header -->
      <div class="text-center mb-12">
        <h1 class="text-4xl md:text-5xl font-bold text-gray-900 dark:text-white mb-6">
          <span class="text-gradient">Administration</span>
        </h1>
        <p class="text-xl text-gray-600 dark:text-gray-300 max-w-3xl mx-auto">
          Gestion des apprentissages critiques et maintenance du portfolio
        </p>
      </div>

      <!-- Stats Cards -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <div class="card p-6 text-center">
          <div class="text-3xl font-bold text-primary-600 dark:text-primary-400 mb-2">
            {{ totalApprentissages }}
          </div>
          <div class="text-gray-600 dark:text-gray-300">
            Apprentissages Critiques
          </div>
        </div>
        
        <div class="card p-6 text-center">
          <div class="text-3xl font-bold text-green-600 dark:text-green-400 mb-2">
            {{ projets.length }}
          </div>
          <div class="text-gray-600 dark:text-gray-300">
            Projets
          </div>
        </div>
        
        <div class="card p-6 text-center">
          <div class="text-3xl font-bold text-accent-600 dark:text-accent-400 mb-2">
            {{ maitriseStats.bienMaitrise }}
          </div>
          <div class="text-gray-600 dark:text-gray-300">
            Bien Maîtrisé
          </div>
        </div>
        
        <div class="card p-6 text-center">
          <div class="text-3xl font-bold text-yellow-600 dark:text-yellow-400 mb-2">
            {{ maitriseStats.partiellement }}
          </div>
          <div class="text-gray-600 dark:text-gray-300">
            Partiellement Maîtrisé
          </div>
        </div>
      </div>

      <!-- Actions -->
      <div class="card p-6 mb-8">
        <h2 class="text-2xl font-semibold text-gray-900 dark:text-white mb-6">Actions Rapides</h2>
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
          <button 
            @click="openProjetModal"
            class="btn-primary flex items-center justify-center space-x-2"
          >
            <PlusIcon class="w-5 h-5" />
            <span>Nouveau Projet</span>
          </button>
          
          <button 
            @click="exportData"
            class="btn-primary flex items-center justify-center space-x-2"
          >
            <ArrowDownTrayIcon class="w-5 h-5" />
            <span>Exporter les Données</span>
          </button>
          
          <button 
            @click="generateReport"
            class="btn-secondary flex items-center justify-center space-x-2"
          >
            <DocumentTextIcon class="w-5 h-5" />
            <span>Générer un Rapport</span>
          </button>
          
          <button 
            @click="backupData"
            class="btn-secondary flex items-center justify-center space-x-2"
          >
            <CloudArrowUpIcon class="w-5 h-5" />
            <span>Sauvegarder</span>
          </button>
        </div>
      </div>

      <!-- Apprentissages List -->
      <div class="card p-6">
        <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-6">
          <h2 class="text-2xl font-semibold text-gray-900 dark:text-white mb-4 sm:mb-0">
            Gestion des Apprentissages
          </h2>
          <button 
            @click="openAddModal"
            class="btn-primary flex items-center space-x-2"
          >
            <PlusIcon class="w-5 h-5" />
            <span>Nouvel Apprentissage</span>
          </button>
        </div>

        <!-- Filters -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
          <div class="relative">
            <MagnifyingGlassIcon class="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              v-model="searchTerm"
              type="text"
              placeholder="Rechercher..."
              class="input-field pl-10"
            />
          </div>
          
          <select v-model="filterCompetence" class="input-field">
            <option value="">Toutes les compétences</option>
            <option v-for="comp in competences" :key="comp.id" :value="comp.id">
              {{ comp.title }}
            </option>
          </select>
          
          <select v-model="filterEvaluation" class="input-field">
            <option value="">Toutes les évaluations</option>
            <option value="Bien Maîtrisé">Bien Maîtrisé</option>
            <option value="Partiellement Maîtrisé">Partiellement Maîtrisé</option>
            <option value="Pas Maîtrisé">Pas Maîtrisé</option>
          </select>
        </div>

        <!-- Apprentissages Table -->
        <div class="overflow-x-auto">
          <table class="w-full">
            <thead>
              <tr class="border-b border-gray-200 dark:border-gray-700">
                <th class="text-left py-3 px-4 font-semibold text-gray-900 dark:text-white">Titre</th>
                <th class="text-left py-3 px-4 font-semibold text-gray-900 dark:text-white">Compétence</th>
                <th class="text-left py-3 px-4 font-semibold text-gray-900 dark:text-white">Niveau</th>
                <th class="text-left py-3 px-4 font-semibold text-gray-900 dark:text-white">Évaluation</th>
                <th class="text-left py-3 px-4 font-semibold text-gray-900 dark:text-white">Modifié</th>
                <th class="text-left py-3 px-4 font-semibold text-gray-900 dark:text-white">Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr 
                v-for="apprentissage in filteredApprentissages" 
                :key="apprentissage.id"
                class="border-b border-gray-100 dark:border-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700/50"
              >
                <td class="py-3 px-4">
                  <div class="font-medium text-gray-900 dark:text-white">{{ apprentissage.title }}</div>
                  <div class="text-sm text-gray-500 dark:text-gray-400 line-clamp-2">{{ apprentissage.description }}</div>
                </td>
                <td class="py-3 px-4 text-gray-600 dark:text-gray-300">
                  {{ getCompetenceTitle(apprentissage.competenceId) }}
                </td>
                <td class="py-3 px-4">
                  <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-primary-100 text-primary-800 dark:bg-primary-900 dark:text-primary-200">
                    Niveau {{ apprentissage.level }}
                  </span>
                </td>
                <td class="py-3 px-4">
                  <EvaluationBadge :evaluation="apprentissage.evaluation" />
                </td>
                <td class="py-3 px-4 text-gray-600 dark:text-gray-300 text-sm">
                  {{ formatDate(apprentissage.dateModification) }}
                </td>
                <td class="py-3 px-4">
                  <div class="flex space-x-2">
                    <button 
                      @click="openEditModal(apprentissage)"
                      class="p-1 text-gray-400 hover:text-primary-600 dark:hover:text-primary-400"
                      title="Modifier"
                    >
                      <PencilIcon class="w-4 h-4" />
                    </button>
                    <button 
                      @click="deleteApprentissage(apprentissage.id)"
                      class="p-1 text-gray-400 hover:text-red-600 dark:hover:text-red-400"
                      title="Supprimer"
                    >
                      <TrashIcon class="w-4 h-4" />
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Add/Edit Modal -->
      <ApprentissageModal
        v-if="showModal"
        :apprentissage="selectedApprentissage"
        :competences="competences"
        :projets="projets"
        @save="saveApprentissage"
        @close="closeModal"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { 
  PlusIcon, 
  MagnifyingGlassIcon, 
  PencilIcon, 
  TrashIcon,
  ArrowDownTrayIcon,
  DocumentTextIcon,
  CloudArrowUpIcon
} from '@heroicons/vue/24/outline'
import ApprentissageModal from '../components/ApprentissageModal.vue'
import EvaluationBadge from '../components/EvaluationBadge.vue'
import ProjetModal from '../components/ProjetModal.vue'
import { competencesData, apprentissagesData, projetsData, type Competence, type Apprentissage, type Projet } from '../data/portfolio'

const searchTerm = ref('')
const filterCompetence = ref('')
const filterEvaluation = ref('')
const showModal = ref(false)
const selectedApprentissage = ref<Apprentissage | null>(null)
const showProjetModal = ref(false)
const selectedProjet = ref<Projet | null>(null)
const competences = ref<Competence[]>(competencesData)
const apprentissages = ref<Apprentissage[]>(apprentissagesData)
const projets = ref<Projet[]>(projetsData)

const totalApprentissages = computed(() => apprentissages.value.length)

const maitriseStats = computed(() => {
  const stats = { bienMaitrise: 0, partiellement: 0, pasMaitrise: 0 }
  apprentissages.value.forEach(app => {
    switch (app.evaluation) {
      case 'Bien Maîtrisé': stats.bienMaitrise++; break
      case 'Partiellement Maîtrisé': stats.partiellement++; break
      case 'Pas Maîtrisé': stats.pasMaitrise++; break
    }
  })
  return stats
})

const filteredApprentissages = computed(() => {
  return apprentissages.value.filter(app => {
    const matchesSearch = !searchTerm.value || 
      app.title.toLowerCase().includes(searchTerm.value.toLowerCase()) ||
      app.description.toLowerCase().includes(searchTerm.value.toLowerCase()) ||
      app.argumentaire.toLowerCase().includes(searchTerm.value.toLowerCase())
    
    const matchesCompetence = !filterCompetence.value || app.competenceId === filterCompetence.value
    const matchesEvaluation = !filterEvaluation.value || app.evaluation === filterEvaluation.value
    
    return matchesSearch && matchesCompetence && matchesEvaluation
  })
})

const getCompetenceTitle = (competenceId: string) => {
  const competence = competences.value.find(c => c.id === competenceId)
  return competence?.title || ''
}

const formatDate = (dateString: string) => {
  return new Date(dateString).toLocaleDateString('fr-FR')
}

const openAddModal = () => {
  selectedApprentissage.value = {
    id: '',
    competenceId: competences.value[0].id,
    level: 1,
    title: '',
    description: '',
    evaluation: 'Pas Maîtrisé',
    argumentaire: '',
    preuves: [],
    dateCreation: new Date().toISOString(),
    dateModification: new Date().toISOString()
  }
  showModal.value = true
}

const openEditModal = (apprentissage: Apprentissage) => {
  selectedApprentissage.value = { ...apprentissage }
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  selectedApprentissage.value = null
}

const openProjetModal = () => {
  selectedProjet.value = null
  showProjetModal.value = true
}

const closeProjetModal = () => {
  showProjetModal.value = false
  selectedProjet.value = null
}

const saveProjet = (projet: Projet) => {
  if (projet.id) {
    const index = projets.value.findIndex(p => p.id === projet.id)
    if (index !== -1) {
      projets.value[index] = projet
    }
  } else {
    projet.id = Date.now().toString()
    projet.dateCreation = new Date().toISOString()
    projets.value.push(projet)
  }
  closeProjetModal()
}

const saveApprentissage = (apprentissage: Apprentissage) => {
  if (apprentissage.id) {
    const index = apprentissages.value.findIndex(a => a.id === apprentissage.id)
    if (index !== -1) {
      apprentissage.dateModification = new Date().toISOString()
      apprentissages.value[index] = apprentissage
    }
  } else {
    apprentissage.id = Date.now().toString()
    apprentissage.dateCreation = new Date().toISOString()
    apprentissage.dateModification = new Date().toISOString()
    apprentissages.value.push(apprentissage)
  }
  closeModal()
}

const deleteApprentissage = (id: string) => {
  if (confirm('Êtes-vous sûr de vouloir supprimer cet apprentissage critique ?')) {
    const index = apprentissages.value.findIndex(a => a.id === id)
    if (index !== -1) {
      apprentissages.value.splice(index, 1)
    }
  }
}

const exportData = () => {
  const data = {
    competences: competences.value,
    apprentissages: apprentissages.value,
    projets: projets.value
  }
  const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `portfolio-geii-${new Date().toISOString().split('T')[0]}.json`
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
}

const generateReport = () => {
  alert('Fonctionnalité de génération de rapport en développement')
}

const backupData = () => {
  alert('Fonctionnalité de sauvegarde en développement')
}
</script>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>