<template>
  <div class="fixed inset-0 z-[110] overflow-y-auto">
    <div class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
      <!-- Background overlay -->
      <div class="fixed inset-0 bg-black/80 backdrop-blur-sm transition-opacity"></div>

      <!-- Modal -->
      <div class="inline-block align-bottom glass-card text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-3xl sm:w-full animate-modal-enter">
        <!-- Header with animated gradient -->
        <div class="bg-gradient-to-r from-blue-600 via-purple-600 to-blue-600 bg-[length:200%_100%] animate-gradient px-8 py-6 text-center">
          <div class="animate-bounce-in">
            <div class="text-6xl mb-4">🎓</div>
            <h2 class="text-3xl font-bold text-white mb-2">Démarrage Rapide</h2>
            <p class="text-blue-100">Voulez-vous importer des exemples pour commencer ?</p>
          </div>
        </div>

        <!-- Content -->
        <div class="px-8 py-8 bg-white dark:bg-gray-800">
          <div class="text-center mb-8">
            <h3 class="text-2xl font-bold text-gray-900 dark:text-white mb-4">
              Importez des exemples pour démarrer rapidement
            </h3>
            <p class="text-gray-600 dark:text-gray-300 leading-relaxed">
              Pour vous aider à comprendre comment structurer votre portfolio BUT, 
              nous pouvons importer des exemples que vous pourrez ensuite modifier selon vos besoins.
            </p>
          </div>

          <!-- What will be imported -->
          <div class="bg-blue-50 dark:bg-blue-900/20 rounded-xl p-6 mb-8">
            <h4 class="text-lg font-semibold text-blue-900 dark:text-blue-100 mb-4 flex items-center">
              <span class="mr-2">📦</span>
              Ce qui sera importé :
            </h4>
            
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div class="text-center">
                <div class="w-12 h-12 bg-blue-500/20 rounded-xl flex items-center justify-center mx-auto mb-3">
                  <span class="text-2xl">🎯</span>
                </div>
                <h5 class="font-semibold text-blue-900 dark:text-blue-100 mb-2">3 Compétences</h5>
                <p class="text-blue-700 dark:text-blue-300 text-sm">
                  Concevoir, Vérifier, Intégrer avec leurs descriptions
                </p>
              </div>
              
              <div class="text-center">
                <div class="w-12 h-12 bg-purple-500/20 rounded-xl flex items-center justify-center mx-auto mb-3">
                  <span class="text-2xl">📚</span>
                </div>
                <h5 class="font-semibold text-blue-900 dark:text-blue-100 mb-2">Apprentissages</h5>
                <p class="text-blue-700 dark:text-blue-300 text-sm">
                  Exemples d'apprentissages critiques avec évaluations
                </p>
              </div>
              
              <div class="text-center">
                <div class="w-12 h-12 bg-green-500/20 rounded-xl flex items-center justify-center mx-auto mb-3">
                  <span class="text-2xl">🚀</span>
                </div>
                <h5 class="font-semibold text-blue-900 dark:text-blue-100 mb-2">1 Projet</h5>
                <p class="text-blue-700 dark:text-blue-300 text-sm">
                  Exemple de projet étudiant structuré
                </p>
              </div>
            </div>
          </div>

          <!-- Benefits -->
          <div class="bg-green-50 dark:bg-green-900/20 rounded-xl p-6 mb-8">
            <h4 class="text-lg font-semibold text-green-900 dark:text-green-100 mb-4 flex items-center">
              <span class="mr-2">✨</span>
              Avantages :
            </h4>
            
            <ul class="space-y-2 text-green-800 dark:text-green-200">
              <li class="flex items-center">
                <span class="text-green-500 mr-2">✓</span>
                Comprenez rapidement la structure d'un portfolio BUT
              </li>
              <li class="flex items-center">
                <span class="text-green-500 mr-2">✓</span>
                Modifiez les exemples selon votre formation
              </li>
              <li class="flex items-center">
                <span class="text-green-500 mr-2">✓</span>
                Gagnez du temps dans la création de votre portfolio
              </li>
              <li class="flex items-center">
                <span class="text-green-500 mr-2">✓</span>
                Voyez des exemples d'argumentaires bien structurés
              </li>
            </ul>
          </div>

          <!-- Action buttons -->
          <div class="flex flex-col sm:flex-row gap-4 justify-center">
            <button 
              @click="importExamples"
              :disabled="importing"
              class="btn-primary text-lg px-8 py-4 disabled:opacity-50"
            >
              <span v-if="importing" class="mr-2">⏳</span>
              <span v-else class="mr-2">📦</span>
              {{ importing ? 'Import en cours...' : 'Importer les exemples' }}
            </button>
            
            <button 
              @click="skipImport"
              class="btn-secondary text-lg px-8 py-4"
            >
              <span class="mr-2">🚀</span>
              Commencer avec un portfolio vide
            </button>
          </div>
          
          <p class="text-center text-gray-500 dark:text-gray-400 text-sm mt-4">
            Vous pourrez toujours supprimer ou modifier ces exemples plus tard
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { competenceService, apprentissageService, projetService, authService } from '../lib/supabase'

const emit = defineEmits(['close', 'imported', 'skipped'])

const importing = ref(false)

const exampleCompetences = [
  {
    id: crypto.randomUUID(),
    title: 'Concevoir',
    subtitle: 'Conception de systèmes',
    description: 'Concevoir l\'architecture matérielle et logicielle d\'un système',
    levels: 3,
    color: 'primary' as const,
    icon: '🎯'
  },
  {
    id: crypto.randomUUID(),
    title: 'Vérifier',
    subtitle: 'Vérification et validation',
    description: 'Vérifier et valider le fonctionnement d\'un système',
    levels: 3,
    color: 'accent' as const,
    icon: '✅'
  },
  {
    id: crypto.randomUUID(),
    title: 'Intégrer',
    subtitle: 'Intégration de systèmes',
    description: 'Intégrer des systèmes et composants dans leur environnement',
    levels: 3,
    color: 'primary' as const,
    icon: '🔧'
  }
]

const generateExampleApprentissages = (competenceIds: { concevoir: string, verifier: string, integrer: string }) => [
  // Concevoir - Niveau 1
  {
    competenceId: competenceIds.concevoir,
    level: 1,
    title: 'Analyse des besoins client',
    description: 'Analyser et comprendre les besoins d\'un client pour un projet technique',
    evaluation: 'Bien Maîtrisé' as const,
    argumentaire: 'J\'ai démontré ma capacité à analyser les besoins clients lors de plusieurs projets. J\'ai mené des entretiens structurés, rédigé des cahiers des charges précis et proposé des solutions techniques adaptées. Ma méthodologie d\'analyse m\'a permis de livrer des projets conformes aux attentes.',
    preuves: []
  },
  // Concevoir - Niveau 2
  {
    competenceId: competenceIds.concevoir,
    level: 2,
    title: 'Conception d\'architecture système',
    description: 'Concevoir l\'architecture globale d\'un système technique complexe',
    evaluation: 'Partiellement Maîtrisé' as const,
    argumentaire: 'J\'ai conçu plusieurs architectures de systèmes lors de mes projets BUT. Je maîtrise les principes de modularité et d\'interfaces, mais je continue à approfondir les aspects de scalabilité et d\'optimisation des performances pour les systèmes complexes.',
    preuves: []
  },
  // Vérifier - Niveau 1
  {
    competenceId: competenceIds.verifier,
    level: 1,
    title: 'Tests unitaires et validation',
    description: 'Mettre en place des tests pour valider le fonctionnement des composants',
    evaluation: 'Bien Maîtrisé' as const,
    argumentaire: 'J\'ai développé une expertise solide en tests unitaires et validation de composants. J\'utilise des frameworks de test appropriés, je conçois des jeux de tests complets et je sais interpréter les résultats pour garantir la qualité du code.',
    preuves: []
  },
  // Intégrer - Niveau 1
  {
    competenceId: competenceIds.integrer,
    level: 1,
    title: 'Intégration de composants',
    description: 'Intégrer différents composants dans un système cohérent',
    evaluation: 'Partiellement Maîtrisé' as const,
    argumentaire: 'J\'ai réalisé plusieurs intégrations de composants avec succès. Je maîtrise les interfaces standards et les protocoles de communication de base. Je continue à développer mes compétences sur les systèmes distribués et les architectures microservices.',
    preuves: []
  }
]

const exampleProjet = {
  titre: 'Système de Monitoring IoT',
  description: 'Développement d\'un système de monitoring pour équipements industriels connectés avec interface web temps réel et alertes intelligentes.',
  icone: '📊',
  niveau: 'Projet de 2ème année',
  duree: '4 mois',
  fonctionnalites: [
    'Interface web responsive',
    'Monitoring temps réel',
    'Système d\'alertes',
    'Base de données historique'
  ],
  technologies: ['Vue.js', 'Node.js', 'IoT', 'WebSockets', 'MongoDB'],
  statut: 'Terminé' as const,
  fichiers: []
}

const importExamples = async () => {
  importing.value = true
  
  try {
    const user = await authService.getCurrentUser()
    if (!user) {
      throw new Error('User not authenticated')
    }

    // Generate unique IDs for this user's competences
    const competenceIds = {
      concevoir: exampleCompetences[0].id,
      verifier: exampleCompetences[1].id,
      integrer: exampleCompetences[2].id
    }

    // Generate apprentissages with the correct competence IDs
    const apprentissagesToImport = generateExampleApprentissages(competenceIds)
    // Import competences
    for (const competence of exampleCompetences) {
      await competenceService.createCompetence(competence)
    }

    // Import apprentissages
    for (const apprentissage of apprentissagesToImport) {
      await apprentissageService.createApprentissage({
        ...apprentissage,
        dateCreation: new Date().toISOString(),
        dateModification: new Date().toISOString(),
        id: ''
      })
    }

    // Import project
    await projetService.createProjet({
      ...exampleProjet,
      dateCreation: new Date().toISOString(),
      id: ''
    })

    emit('imported')
  } catch (error) {
    console.error('Error importing examples:', error)
    alert('Erreur lors de l\'import des exemples. Veuillez réessayer.')
  } finally {
    importing.value = false
  }
}

const skipImport = () => {
  emit('skipped')
}
</script>

<style scoped>
@keyframes modal-enter {
  from {
    opacity: 0;
    transform: scale(0.9) translateY(20px);
  }
  to {
    opacity: 1;
    transform: scale(1) translateY(0);
  }
}

@keyframes bounce-in {
  0% { transform: scale(0.3) rotate(-10deg); opacity: 0; }
  50% { transform: scale(1.05) rotate(5deg); }
  70% { transform: scale(0.9) rotate(-2deg); }
  100% { transform: scale(1) rotate(0deg); opacity: 1; }
}

@keyframes gradient {
  0% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
}

.animate-modal-enter {
  animation: modal-enter 0.5s ease-out;
}

.animate-bounce-in {
  animation: bounce-in 1s ease-out;
}

.animate-gradient {
  animation: gradient 3s ease infinite;
}
</style>