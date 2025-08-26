<template>
  <footer class="bg-white dark:bg-gray-800 border-t border-gray-200 dark:border-gray-700">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
        <!-- About -->
        <div>
          <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">FolioLink</h3>
          <div class="space-y-2 text-gray-600 dark:text-gray-400">
            <p>Portfolio Builder étudiant en BUT</p>
            <p>Compétences & apprentissages critiques</p>
            <p>Spécialement conçu pour les étudiants</p>
          </div>
        </div>

        <!-- Navigation -->
        <div>
          <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">Navigation</h3>
          <div class="space-y-2">
            <router-link to="/" class="block text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400 transition-colors">
              Accueil
            </router-link>
            <router-link to="/portfolio" class="block text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400 transition-colors">
              Exemple Portfolio
            </router-link>
            <router-link to="/projets" class="block text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400 transition-colors">
              Exemples Projets
            </router-link>
            <router-link to="/pricing" class="block text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400 transition-colors">
              Premium
            </router-link>
            <a href="https://discord.gg/vkPFcr3EnY" target="_blank" rel="noopener noreferrer" class="block text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400 transition-colors flex items-center">
              <span class="mr-2">💬</span>
              Discord Communauté
            </a>
          </div>
        </div>

        <!-- Legal -->
        <div>
          <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">Légal</h3>
          <div class="space-y-2 text-gray-600 dark:text-gray-400">
            <router-link to="/legal-notice" class="block hover:text-primary-600 dark:hover:text-primary-400 transition-colors">Mentions légales</router-link>
            <router-link to="/terms-of-service" class="block hover:text-primary-600 dark:hover:text-primary-400 transition-colors">Conditions d'utilisation</router-link>
            <router-link to="/privacy-policy" class="block hover:text-primary-600 dark:hover:text-primary-400 transition-colors">Politique de confidentialité</router-link>
            <p class="text-sm mt-4">© {{ new Date().getFullYear() }} FolioLink</p>
          </div>
        </div>
      </div>
    </div>
  </footer>
</template>