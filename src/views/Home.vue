<template>
  <div class="min-h-screen bg-gradient-to-br from-gray-900 via-blue-900 to-gray-900">
    <!-- Hero Section - Authenticated User -->
    <section v-if="isAuthenticated" class="relative min-h-screen flex items-center justify-center overflow-hidden pt-16">
      <!-- Animated Background Elements -->
      <div class="absolute inset-0">
        <div class="absolute top-20 left-10 w-72 h-72 bg-accent-500/10 rounded-full blur-3xl animate-pulse"></div>
        <div class="absolute bottom-20 right-10 w-96 h-96 bg-primary-500/10 rounded-full blur-3xl animate-pulse delay-1000"></div>
        <div class="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-accent-400/5 rounded-full blur-3xl animate-pulse delay-500"></div>
      </div>
      
      <div class="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center z-10">
        <!-- Welcome Badge -->
        <div class="inline-flex items-center glass-card px-6 py-3 mb-8 animate-fade-in">
          <span class="text-accent-400 mr-2">👋</span>
          <span class="text-white font-medium">Bienvenue {{ userProfile?.full_name || 'sur votre portfolio' }}</span>
        </div>

        <!-- User Title -->
        <div class="animate-slide-up">
          <h1 class="text-5xl md:text-7xl font-bold text-white mb-6 leading-tight">
            <span class="gradient-text text-glow">Portfolio de {{ userProfile?.full_name || user?.user_metadata?.full_name || 'Mon Utilisateur' }}</span>
            <br>
            <span class="text-3xl md:text-4xl">{{ userProfile?.formation || 'Portfolio Professionnel' }}</span>
          </h1>
          
          <p class="text-lg text-gray-400 mb-12 max-w-3xl mx-auto leading-relaxed">
            {{ userProfile?.bio || 'Découvrez mes compétences, projets et réalisations professionnelles.' }}
          </p>

          <!-- User Stats -->
          <div class="grid grid-cols-2 md:grid-cols-4 gap-6 max-w-4xl mx-auto mb-16">
            <div class="glass-card p-6 text-center hover:scale-105 transition-all duration-300">
              <div class="text-3xl font-bold gradient-text mb-2">{{ userStats.apprentissages }}</div>
              <div class="text-gray-300 text-sm">Apprentissages</div>
            </div>
            <div class="glass-card p-6 text-center hover:scale-105 transition-all duration-300">
              <div class="text-3xl font-bold gradient-text mb-2">{{ userStats.projets }}</div>
              <div class="text-gray-300 text-sm">Projets</div>
            </div>
            <div class="glass-card p-6 text-center hover:scale-105 transition-all duration-300">
              <div class="text-3xl font-bold gradient-text mb-2">{{ userStats.competencesMaitrisees }}</div>
              <div class="text-gray-300 text-sm">Bien Maîtrisées</div>
            </div>
            <div class="glass-card p-6 text-center hover:scale-105 transition-all duration-300">
              <div class="text-3xl font-bold gradient-text mb-2">{{ userProfile?.annee_etudes || '3' }}</div>
              <div class="text-gray-300 text-sm">Année d'études</div>
            </div>
          </div>

          <!-- User Actions -->
          <div class="flex flex-col sm:flex-row gap-6 justify-center items-center">
            <router-link to="/dashboard" class="btn-primary group text-lg px-10 py-5">
              <span class="mr-2">📊</span>
              Gérer mon portfolio
            </router-link>
            <router-link to="/portfolio" class="btn-secondary group">
              <span class="mr-2">🎓</span>
              Voir mes compétences
            </router-link>
          </div>
        </div>
      </div>
    </section>

    <!-- Hero Section - Non Authenticated -->
    <section v-if="!isAuthenticated" class="relative min-h-screen flex items-center justify-center overflow-hidden pt-16">
      <!-- Animated Background Elements -->
      <div class="absolute inset-0">
        <div class="absolute top-20 left-10 w-72 h-72 bg-accent-500/10 rounded-full blur-3xl animate-pulse"></div>
        <div class="absolute bottom-20 right-10 w-96 h-96 bg-primary-500/10 rounded-full blur-3xl animate-pulse delay-1000"></div>
        <div class="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-accent-400/5 rounded-full blur-3xl animate-pulse delay-500"></div>
      </div>
      
      <div class="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center z-10">
        <!-- Badge -->
        <div class="inline-flex items-center glass-card px-8 py-4 mb-16 animate-fade-in">
          <span class="text-accent-400 mr-2">🚀</span>
          <span class="text-white font-medium text-lg">Le portfolio étudiant en BUT nouvelle génération</span>
        </div>

        <!-- Main Title -->
        <div class="animate-slide-up">
          <h1 class="text-6xl md:text-8xl font-bold text-white mb-6 leading-tight">
            <span class="gradient-text text-glow">
              <span id="typewriter-text" class="typewriter-animated"></span>
            </span>
            <br>
            <span class="text-4xl md:text-5xl">Votre portfolio étudiant digne de votre BUT</span>
          </h1>
          
          <p class="text-lg text-gray-400 mb-12 max-w-4xl mx-auto leading-relaxed">
            Créez votre portfolio étudiant BUT professionnel en quelques minutes. 
            Présentez vos compétences, projets et apprentissages critiques avec un design moderne 
            et des fonctionnalités avancées pour impressionner jury et recruteurs.
          </p>

          <!-- CTA Buttons -->
          <div class="flex flex-col sm:flex-row gap-6 justify-center items-center mb-16 scroll-animate">
            <button 
             @click="openAuthModal"
              class="btn-primary group text-lg px-10 py-5"
            >
              <span class="mr-2">✨</span>
              Créer mon portfolio maintenant
            </button>
            <a href="#demo" class="btn-secondary group">
              <span class="mr-2">👁️</span>
              Voir la démo
            </a>
          </div>

          <!-- Stats Cards -->
          <div class="grid grid-cols-2 md:grid-cols-4 gap-6 max-w-4xl mx-auto scroll-animate">
            <div class="glass-card p-6 text-center hover:scale-105 transition-all duration-300">
              <div class="text-3xl font-bold gradient-text mb-2">BUT</div>
              <div class="text-gray-300 text-sm">Spécialisé BUT</div>
            </div>
            <div class="glass-card p-6 text-center hover:scale-105 transition-all duration-300">
              <div class="text-3xl font-bold gradient-text mb-2">Plan</div>
              <div class="text-gray-300 text-sm">Gratuit</div>
            </div>
            <div class="glass-card p-6 text-center hover:scale-105 transition-all duration-300">
              <div class="text-3xl font-bold gradient-text mb-2">5 min</div>
              <div class="text-gray-300 text-sm">Configuration</div>
            </div>
            <div class="glass-card p-6 text-center hover:scale-105 transition-all duration-300">
              <div class="text-3xl font-bold gradient-text mb-2">IA</div>
              <div class="text-gray-300 text-sm">Intégrée</div>
            </div>
          </div>
        </div>
      </div>

      <!-- Scroll Indicator -->
      <div class="absolute bottom-8 left-1/2 transform -translate-x-1/2 animate-bounce">
        <ChevronDownIcon class="w-6 h-6 text-accent-400" />
      </div>
    </section>

    <!-- Features Section -->
    <section v-if="!isAuthenticated" id="features" class="py-20 relative">
      <div class="absolute inset-0 bg-gradient-to-b from-transparent via-gray-900/50 to-transparent"></div>
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <!-- Badge -->
        <div class="text-center mb-12">
          <div class="inline-flex items-center glass-card px-6 py-3 mb-8">
            <span class="text-accent-400 mr-2">⚡</span>
            <span class="text-white font-medium">Fonctionnalités Puissantes</span>
          </div>
          
          <h2 class="text-4xl md:text-6xl font-bold text-white mb-6">
            Fonctionnalités <span class="gradient-text">Puissantes</span>
          </h2>
          <p class="text-xl text-gray-300 max-w-4xl mx-auto leading-relaxed">
            Des outils modernes et intuitifs pour créer un portfolio BUT professionnel 
            qui vous démarque lors de vos candidatures de stage et d'emploi.
          </p>
        </div>

        <!-- Features Grid -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8 mb-12 scroll-animate">
          <div class="glass-card p-8 text-center hover:scale-105 transition-all duration-500 group">
            <div class="w-16 h-16 bg-gradient-to-r from-purple-400 to-purple-500 rounded-2xl flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform duration-300">
              <span class="text-2xl">🤖</span>
            </div>
            <h3 class="text-xl font-bold text-white mb-4">IA Personnalisée</h3>
            <p class="text-gray-300 text-sm mb-4 leading-relaxed">
              Assistant intelligent pour vous aider à rédiger des argumentaires convaincants 
              adaptés à votre formation et profil étudiant BUT.
            </p>
          </div>

          <div class="glass-card p-8 text-center hover:scale-105 transition-all duration-500 group">
            <div class="w-16 h-16 bg-gradient-to-r from-blue-400 to-blue-500 rounded-2xl flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform duration-300">
              <span class="text-2xl">🔗</span>
            </div>
            <h3 class="text-xl font-bold text-white mb-4">Partage Instantané</h3>
            <p class="text-gray-300 text-sm mb-4 leading-relaxed">
              Partagez votre portfolio avec un lien unique et sécurisé. 
              Maîtres de stage et recruteurs y accèdent directement sans inscription.
            </p>
          </div>

          <div class="glass-card p-8 text-center hover:scale-105 transition-all duration-500 group">
            <div class="w-16 h-16 bg-gradient-to-r from-accent-400 to-accent-500 rounded-2xl flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform duration-300">
              <span class="text-2xl">⚡</span>
            </div>
            <h3 class="text-xl font-bold text-white mb-4">Setup Rapide</h3>
            <p class="text-gray-300 text-sm mb-4 leading-relaxed">
              Créez votre portfolio BUT en 5 minutes avec une interface intuitive 
              et des assistants pour vous guider.
            </p>
          </div>

          <div class="glass-card p-8 text-center hover:scale-105 transition-all duration-500 group">
            <div class="w-16 h-16 bg-gradient-to-r from-accent-400 to-accent-500 rounded-2xl flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform duration-300">
              <span class="text-2xl">🎯</span>
            </div>
            <h3 class="text-xl font-bold text-white mb-4">Conforme BUT</h3>
            <p class="text-gray-300 text-sm mb-4 leading-relaxed">
              Respecte parfaitement le Programme National BUT avec une structure 
              adaptée aux compétences et apprentissages critiques.
            </p>
          </div>
        </div>

        <!-- Action Buttons -->
        <div class="text-center scroll-animate">
          <div class="flex flex-col sm:flex-row gap-4 justify-center">
            <button 
              @click="openAuthModal"
              class="btn-primary"
            >
              <span class="mr-2">🚀</span>
              Créer mon portfolio !
            </button>
            <a href="#demo" class="btn-secondary">
              <span class="mr-2">📱</span>
              Voir la démo
            </a>
          </div>
        </div>
      </div>
    </section>

    <!-- User Projects Section - Authenticated -->
    <section v-if="isAuthenticated && userProjets.length > 0" class="py-20 relative order-2">
      <div class="absolute inset-0 bg-gradient-to-b from-transparent via-blue-900/30 to-transparent"></div>
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div class="text-center mb-12">
          <div class="inline-flex items-center glass-card px-6 py-3 mb-8">
            <span class="text-accent-400 mr-2">🚀</span>
            <span class="text-white font-medium">Mes Projets</span>
          </div>
          
          <h2 class="text-4xl md:text-6xl font-bold text-white mb-6">
            Mes <span class="gradient-text">Réalisations</span>
          </h2>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
          <div 
            v-for="projet in userProjets.slice(0, 4)" 
            :key="projet.id"
            class="glass-card p-8 hover:scale-105 transition-all duration-500 group relative cursor-pointer"
            @click="navigateToProjectDetail(projet)"
          >
            <div class="flex items-start space-x-4 mb-6">
              <div class="w-12 h-12 bg-gradient-to-r from-accent-400 to-accent-500 rounded-xl flex items-center justify-center group-hover:scale-110 transition-transform duration-300">
                <span class="text-xl">{{ projet.icone }}</span>
              </div>
              <div>
                <h3 class="text-xl font-bold text-white mb-2">{{ projet.titre }}</h3>
                <div class="flex flex-wrap gap-2 mb-4">
                  <span 
                    v-for="tech in projet.technologies"
                    :key="tech"
                    class="px-3 py-1 bg-accent-400/20 text-accent-400 rounded-full text-xs"
                  >
                    {{ tech }}
                  </span>
                </div>
              </div>
            </div>
            <p class="text-gray-300 mb-6 leading-relaxed">
              {{ projet.description }}
            </p>
            <div class="flex items-center justify-between">
              <div class="text-sm text-gray-400">{{ projet.niveau }}</div>
            </div>
          </div>
        </div>
        
        <div class="text-center mt-12">
          <router-link to="/projets" class="btn-primary">
            <span class="mr-2">📁</span>
            Voir tous mes projets
          </router-link>
        </div>
      </div>
    </section>

    <!-- User Featured Apprentissages Section - Authenticated -->
    <section v-if="isAuthenticated && featuredApprentissages.length > 0" class="py-20 relative order-3">
      <div class="absolute inset-0 bg-gradient-to-b from-transparent via-purple-900/30 to-transparent"></div>
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div class="text-center mb-12">
          <div class="inline-flex items-center glass-card px-6 py-3 mb-8">
            <span class="text-accent-400 mr-2">⭐</span>
            <span class="text-white font-medium">Apprentissages Vedettes</span>
          </div>
          
          <h2 class="text-4xl md:text-6xl font-bold text-white mb-6">
            Mes <span class="gradient-text">Compétences Clés</span>
          </h2>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <div 
            v-for="featured in featuredApprentissages" 
            :key="featured.id"
            class="glass-card p-8 hover:scale-105 transition-all duration-500 group relative cursor-pointer"
            @click="navigateToApprentissageDetail(featured.apprentissages)"
          >
            <div class="flex items-start justify-between mb-4">
              <div class="flex-1">
                <h3 class="text-xl font-bold text-white mb-2">{{ featured.apprentissages.title }}</h3>
                <EvaluationBadge :evaluation="featured.apprentissages.evaluation" class="mb-4" />
              </div>
              <div class="text-accent-400 text-xl">⭐</div>
            </div>
            
            <p class="text-gray-300 mb-6 leading-relaxed line-clamp-3">
              {{ featured.apprentissages.description }}
            </p>
            
            <div class="text-sm text-gray-400">
              Compétence : {{ getCompetenceTitle(featured.apprentissages.competence_id) }}
            </div>
          </div>
        </div>
        
        <div class="text-center mt-12">
          <router-link to="/portfolio" class="btn-primary">
            <span class="mr-2">🎓</span>
            Voir toutes mes compétences
          </router-link>
        </div>
      </div>
    </section>

    <!-- User Profile Sidebar - Authenticated -->
    <section v-if="isAuthenticated && userProfile" class="py-20 relative order-1">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div class="glass-card p-8 max-w-2xl mx-auto">
          <div class="text-center mb-8">
            <div class="inline-flex items-center glass-card px-6 py-3 mb-8">
              <span class="text-accent-400 mr-2">👤</span>
              <span class="text-white font-medium">À propos de moi</span>
            </div>
          </div>
          
          <div class="flex flex-col items-center space-y-6">
            <!-- Avatar -->
            <div class="relative">
              <div v-if="userProfile.avatar_url" class="w-32 h-32 rounded-full overflow-hidden border-4 border-accent-400/50 hover:scale-110 transition-transform duration-300 cursor-pointer group hover:shadow-2xl hover:shadow-accent-400/25">
                <img :src="userProfile.avatar_url" :alt="userProfile.full_name" class="w-full h-full object-cover" />
              </div>
              <div v-else class="w-32 h-32 bg-gradient-to-r from-accent-400 to-accent-500 rounded-full flex items-center justify-center border-4 border-accent-400/50 hover:scale-110 transition-transform duration-300 cursor-pointer group hover:shadow-2xl hover:shadow-accent-400/25">
                <span class="text-4xl text-gray-900 font-bold">
                  {{ getInitials(userProfile.full_name) }}
                </span>
              </div>
            </div>
            
            <!-- Name and Formation -->
            <div class="text-center">
              <h3 class="text-2xl font-bold text-white mb-1">{{ userProfile?.full_name || 'Nom non renseigné' }}</h3>
              <p class="text-gray-300 text-lg">{{ userProfile?.formation || 'Formation non renseignée' }}</p>
              <p class="text-gray-400">{{ userProfile?.etablissement || 'Établissement non renseigné' }}</p>
              <div v-if="userProfile?.bio" class="mt-3 text-gray-300 text-sm">
                {{ userProfile.bio }}
              </div>
            </div>
            
            <!-- Contact Links -->
            <div class="flex flex-wrap justify-center gap-4">
              <a v-if="userProfile.email" :href="`mailto:${userProfile.email}`" 
                 class="flex items-center space-x-2 glass-card px-4 py-2 hover:bg-white/20 transition-colors">
                <span class="text-accent-400">📧</span>
                <span class="text-white text-sm">Email</span>
              </a>
              
              <a v-if="userProfile.telephone" :href="`tel:${userProfile.telephone}`" 
                 class="flex items-center space-x-2 glass-card px-4 py-2 hover:bg-white/20 transition-colors">
                <span class="text-accent-400">📱</span>
                <span class="text-white text-sm">Téléphone</span>
              </a>
              
              <a v-if="userProfile.linkedin" :href="userProfile.linkedin" target="_blank" rel="noopener noreferrer"
                 class="flex items-center space-x-2 glass-card px-4 py-2 hover:bg-white/20 transition-colors">
                <span class="text-blue-400">💼</span>
                <span class="text-white text-sm">LinkedIn</span>
              </a>
              <a v-if="userProfile.github" :href="userProfile.github" target="_blank" rel="noopener noreferrer"
                 class="flex items-center space-x-2 glass-card px-4 py-2 hover:bg-white/20 transition-colors">
                <span class="text-gray-300">🐙</span>
                <span class="text-white text-sm">GitHub</span>
              </a>
            </div>
          </div>
        </div>
      </div>
    </section>
    <!-- Demo Section -->
    <section v-if="!isAuthenticated" id="demo" class="py-20 relative">
      <div class="absolute inset-0 bg-gradient-to-b from-transparent via-blue-900/30 to-transparent"></div>
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <!-- Badge -->
        <div class="text-center mb-12">
          <div class="inline-flex items-center glass-card px-6 py-3 mb-8">
            <span class="text-accent-400 mr-2">👁️</span>
            <span class="text-white font-medium">Votre Portfolio est unique !</span>
          </div>
          
          <h2 class="text-4xl md:text-6xl font-bold text-white mb-6">
            Votre Portfolio est <span class="gradient-text">unique !</span>
          </h2>
          <p class="text-xl text-gray-300 max-w-4xl mx-auto leading-relaxed">
            Explorez des exemples concrets de compétences en BUT avec leurs apprentissages critiques, 
            évaluations de maîtrise et projets étudiants associés. Voyez comment structurer votre portfolio 
            pour vos soutenances et présentations devant le jury.
          </p>
        </div>

        <!-- Demo Content Grid -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8 mb-12 scroll-animate">
          <!-- Compétences Card -->
          <div class="glass-card p-8 hover:scale-105 transition-all duration-500 group text-center">
            <div class="w-16 h-16 bg-gradient-to-r from-purple-400 to-purple-500 rounded-2xl flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform duration-300">
              <span class="text-2xl">🎯</span>
            </div>
            <h3 class="text-xl font-bold text-white mb-4">Compétences BUT</h3>
            <p class="text-gray-300 leading-relaxed mb-4">
              Compétences spécifiques selon votre spécialité BUT avec leurs niveaux de 
              maîtrise progressifs.
            </p>
            <router-link to="/portfolio" class="text-accent-400 hover:text-accent-300 text-sm font-medium transition-colors">
              Voir les compétences →
            </router-link>
          </div>

          <!-- Apprentissages Card -->
          <div class="glass-card p-8 hover:scale-105 transition-all duration-500 group text-center">
            <div class="w-16 h-16 bg-gradient-to-r from-blue-400 to-blue-500 rounded-2xl flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform duration-300">
              <span class="text-2xl">📚</span>
            </div>
            <h3 class="text-xl font-bold text-white mb-4">Apprentissages Critiques</h3>
            <p class="text-gray-300 leading-relaxed mb-4">
              Exemples d'apprentissages avec évaluations, argumentaires et preuves de 
              maîtrise pour vos soutenances.
            </p>
            <router-link to="/portfolio" class="text-accent-400 hover:text-accent-300 text-sm font-medium transition-colors">
              Voir les apprentissages →
            </router-link>
          </div>

          <!-- Projets Card -->
          <div class="glass-card p-8 hover:scale-105 transition-all duration-500 group text-center">
            <div class="w-16 h-16 bg-gradient-to-r from-green-400 to-green-500 rounded-2xl flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform duration-300">
              <span class="text-2xl">🚀</span>
            </div>
            <h3 class="text-xl font-bold text-white mb-4">Projets Étudiants</h3>
            <p class="text-gray-300 leading-relaxed mb-4">
              Présentez vos projets étudiants avec un design professionnel 
              et une structure adaptée aux exigences BUT.
            </p>
            <router-link to="/projets" class="text-accent-400 hover:text-accent-300 text-sm font-medium transition-colors">
              Voir les projets →
            </router-link>
          </div>
        </div>

        <!-- Example Projects Preview -->
        <div class="text-center mb-8">
          <h3 class="text-2xl font-bold text-white mb-4">Aperçu des Projets Exemples</h3>
          <p class="text-gray-300 mb-8">Voici quelques projets étudiants pour vous donner une idée du rendu final</p>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 scroll-animate">
          <div 
            v-for="projet in exampleProjets.slice(0, 2)" 
            :key="projet.id"
            class="glass-card p-8 hover:scale-105 transition-all duration-500 group relative cursor-pointer"
            @click="navigateToProjectExample(projet)"
          >
            <div class="flex items-start space-x-4 mb-6">
              <div class="w-12 h-12 bg-gradient-to-r from-accent-400 to-accent-500 rounded-xl flex items-center justify-center group-hover:scale-110 transition-transform duration-300">
                <span class="text-xl">{{ projet.icone }}</span>
              </div>
              <div>
                <h3 class="text-xl font-bold text-white mb-2">{{ projet.titre }}</h3>
                <div class="flex flex-wrap gap-2 mb-4">
                  <span 
                    v-for="tech in projet.technologies"
                    :key="tech"
                    class="px-3 py-1 bg-accent-400/20 text-accent-400 rounded-full text-xs"
                  >
                    {{ tech }}
                  </span>
                </div>
              </div>
            </div>
            <p class="text-gray-300 mb-6 leading-relaxed">
              {{ projet.description }}
            </p>
            <div class="flex items-center justify-between">
              <div class="text-sm text-gray-400">{{ projet.niveau }}</div>
            </div>
            
            <!-- Hover overlay -->
            <div class="absolute inset-0 bg-black/20 opacity-0 group-hover:opacity-100 transition-opacity duration-300 rounded-2xl flex items-center justify-center">
              <button 
                @click="openProjectModal(projet)"
                class="btn-primary transform scale-90 group-hover:scale-100 transition-transform duration-300"
              >
                <span class="mr-2">👁️</span>
                Voir détails
              </button>
            </div>
          </div>
        </div>
        
        <!-- Action Button -->
        <div class="text-center mt-12 scroll-animate">
          <button 
           @click="openAuthModal"
            class="btn-primary"
          >
            <span class="mr-2">✨</span>
            Créer mon portfolio maintenant
          </button>
        </div>
      </div>
    </section>

    <!-- Testimonials Section -->
    <section v-if="!isAuthenticated" id="testimonials" class="py-20 relative">
      <div class="absolute inset-0 bg-gradient-to-b from-transparent via-gray-900/50 to-transparent"></div>
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <!-- Badge -->
        <div class="text-center mb-12">
          <div class="inline-flex items-center glass-card px-6 py-3 mb-8">
            <span class="text-accent-400 mr-2">💬</span>
            <span class="text-white font-medium">Témoignages</span>
          </div>
          
          <h2 class="text-4xl md:text-6xl font-bold text-white mb-6">
            Ce que disent les <span class="gradient-text">étudiants</span>
          </h2>
          <p class="text-xl text-gray-300 max-w-4xl mx-auto leading-relaxed">
            Découvrez comment FolioLink a aidé des étudiants en BUT à décrocher leurs stages et emplois.
          </p>
        </div>

        <!-- Testimonials Grid -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8 scroll-animate">
          <div class="glass-card p-8 hover:scale-105 transition-all duration-500">
            <div class="flex items-center mb-4">
              <div class="w-12 h-12 bg-gradient-to-r from-accent-400 to-accent-500 rounded-full flex items-center justify-center mr-4">
                <span class="text-gray-900 font-bold">E</span>
              </div>
              <div>
                <h4 class="font-bold text-white">Eliot</h4>
                <p class="text-gray-400 text-sm">Étudiante en BUT GEII - 3ème année</p>
              </div>
            </div>
            <p class="text-gray-300 leading-relaxed">
              "FolioLink m'a permis de créer mon portfolio en BUT en quelques minutes. 
              J'ai décroché mon stage de fin d'études et impressionné le jury lors de ma soutenance grâce à la présentation claire de mes compétences !"
            </p>
          </div>

          <div class="glass-card p-8 hover:scale-105 transition-all duration-500">
            <div class="flex items-center mb-4">
              <div class="w-12 h-12 bg-gradient-to-r from-accent-400 to-accent-500 rounded-full flex items-center justify-center mr-4">
                <span class="text-gray-900 font-bold">A</span>
              </div>
              <div>
                <h4 class="font-bold text-white">Axel</h4>
                <p class="text-gray-400 text-sm">Étudiant en BUT GEII - 3ème année</p>
              </div>
            </div>
            <p class="text-gray-300 leading-relaxed">
              "Interface intuitive et design moderne. Parfait pour présenter mes projets en BUT 
              et mes apprentissages critiques. Le jury et mon maître de stage ont été très impressionnés !"
            </p>
          </div>

          <div class="glass-card p-8 hover:scale-105 transition-all duration-500">
            <div class="flex items-center mb-4">
              <div class="w-12 h-12 bg-gradient-to-r from-accent-400 to-accent-500 rounded-full flex items-center justify-center mr-4">
                <span class="text-gray-900 font-bold">K</span>
              </div>
              <div>
                <h4 class="font-bold text-white">Kylian</h4>
                <p class="text-gray-400 text-sm">Étudiante en BUT GEII - 3ème année</p>
              </div>
            </div>
            <p class="text-gray-300 leading-relaxed">
              "Exactement ce que je cherchais pour mon BUT GEII ! Un portfolio qui met en valeur mes projets 
              avec un design épuré et professionnel. Parfait pour les soutenances ! Recommandé à tous les étudiants en BUT !"
            </p>
          </div>
        </div>
      </div>
    </section>

    <!-- Contact Section -->
    <section v-if="!isAuthenticated" id="contact" class="py-20 relative">
      <div class="absolute inset-0 bg-gradient-to-b from-transparent via-blue-900/30 to-gray-900"></div>
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <!-- Badge -->
        <div class="text-center mb-12">
          <div class="inline-flex items-center glass-card px-6 py-3 mb-8">
            <span class="text-accent-400 mr-2">🚀</span>
            <span class="text-white font-medium">Prêt à commencer ?</span>
          </div>
          
          <h2 class="text-4xl md:text-6xl font-bold text-white mb-6">
            Révolutionnez votre <span class="gradient-text">portfolio BUT</span>
          </h2>
          <p class="text-xl text-gray-300 max-w-4xl mx-auto leading-relaxed">
            Rejoignez des centaines d'étudiants qui utilisent l'IA personnalisée et le partage public 
            pour décrocher leurs stages et emplois plus rapidement que jamais.
          </p>
        </div>

        <!-- Contact Content -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-12 max-w-6xl mx-auto">
          <!-- Benefits -->
          <div class="glass-card p-8 space-y-6">
            <div class="flex items-center mb-6">
              <div class="w-12 h-12 bg-accent-400 rounded-xl flex items-center justify-center mr-4">
                <span class="text-xl text-gray-900">✨</span>
              </div>
              <h3 class="text-2xl font-bold text-white">Pourquoi FolioLink ?</h3>
            </div>
            
            <div class="space-y-6">
              <div class="flex items-center">
                <div class="w-10 h-10 bg-green-400/20 rounded-lg flex items-center justify-center mr-4">
                  <span class="text-green-400">✓</span>
                </div>
                <div>
                  <div class="text-white font-medium">IA Personnalisée</div>
                  <div class="text-gray-400 text-sm">Argumentaires générés selon votre profil</div>
                </div>
              </div>
              
              <div class="flex items-center">
                <div class="w-10 h-10 bg-green-400/20 rounded-lg flex items-center justify-center mr-4">
                  <span class="text-green-400">✓</span>
                </div>
                <div>
                  <div class="text-white font-medium">Partage Public Unique</div>
                  <div class="text-gray-400 text-sm">Lien direct pour jury et recruteurs</div>
                </div>
              </div>
              
              <div class="flex items-center">
                <div class="w-10 h-10 bg-green-400/20 rounded-lg flex items-center justify-center mr-4">
                  <span class="text-green-400">✓</span>
                </div>
                <div>
                  <div class="text-white font-medium">Plan Gratuit</div>
                  <div class="text-gray-400 text-sm">Portfolio complet sans frais</div>
                </div>
              </div>
              
              <div class="flex items-center">
                <div class="w-10 h-10 bg-green-400/20 rounded-lg flex items-center justify-center mr-4">
                  <span class="text-green-400">✓</span>
                </div>
                <div>
                  <div class="text-white font-medium">Gamification</div>
                  <div class="text-gray-400 text-sm">Trophées et niveaux pour motiver</div>
                </div>
              </div>
            </div>
          </div>

          <!-- CTA Form -->
          <div class="glass-card p-8">
            <div class="flex items-center mb-6">
              <div class="w-12 h-12 bg-accent-400 rounded-xl flex items-center justify-center mr-4">
                <span class="text-xl text-gray-900">⚡</span>
              </div>
              <h3 class="text-2xl font-bold text-white">Créez votre portfolio</h3>
            </div>
            
            <div class="space-y-6">
              <p class="text-gray-300 leading-relaxed">
                Créez votre compte gratuit et découvrez comment l'IA révolutionne la création de portfolios BUT. 
                Argumentaires automatiques + partage public = succès garanti pour vos stages.
              </p>
              
              <button 
               @click="openAuthModal"
                class="w-full btn-primary text-lg py-4"
              >
                <span class="mr-2">👑</span>
                Commencer avec FolioLink Premium (10€)
              </button>
              
              <div class="text-center">
                <p class="text-gray-400 text-sm">
                  Déjà un compte ? 
                  <button 
                   @click="openAuthModal"
                    class="text-accent-400 hover:text-accent-300 transition-colors"
                  >
                    Se connecter
                  </button>
                  <br>
                  <router-link to="/pricing" class="text-accent-400 hover:text-accent-300 transition-colors">
                    Découvrir Premium (10€)
                  </router-link>
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Floating Back to Top Button -->
    <button 
      @click="scrollToTop"
      class="fixed bottom-8 right-8 glass-card p-4 hover:scale-110 transition-all duration-300 z-50"
    >
      <ChevronDownIcon class="w-6 h-6 text-accent-400 transform rotate-180" />
    </button>
    
    <!-- Project Details Modal -->
    <ProjectModal
      v-if="showProjectModal && selectedProject"
      :project="getProjectDetails(selectedProject)"
      @close="closeProjectModal"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, watch, nextTick } from 'vue'
import { ChevronDownIcon } from '@heroicons/vue/24/outline'
import ProjectModal from '../components/ProjectModal.vue'
import EvaluationBadge from '../components/EvaluationBadge.vue'
import { exampleDataService, authService, profileService, projetService, apprentissageService } from '../lib/supabase'
import { featuredApprentissageService, competenceService, supabase } from '../lib/supabase'
import { useAuth } from '../composables/useAuth'
import { useRouter } from 'vue-router'
import { useTheme } from '../composables/useTheme'

const { openAuthModal } = useAuth()
const router = useRouter()
const { applyDefaultTheme } = useTheme()

const showProjectModal = ref(false)
const selectedProject = ref<any>(null)
const exampleProjets = ref<any[]>([])
const isAuthenticated = ref(false)
const userProfile = ref<any>(null)
const userProjets = ref<any[]>([])
const userApprentissages = ref<any[]>([])
const featuredApprentissages = ref<any[]>([])
const competences = ref<any[]>([])
const userStats = ref({
  apprentissages: 0,
  projets: 0,
  competencesMaitrisees: 0
})

// Animation variables as reactive refs
const typewriterTimeout = ref<number | null>(null)
const scrollObserver = ref<IntersectionObserver | null>(null)

onMounted(() => {
  // Ensure default theme is applied on home page
  applyDefaultTheme()
  checkAuthAndLoadData()
})

onUnmounted(() => {
  cleanupAnimations()
})

// Watch for authentication changes to manage animations
watch(isAuthenticated, (newValue) => {
  if (!newValue) {
    // User is not authenticated, setup animations
    nextTick(() => {
      setupScrollAnimations()
      startTypewriterAnimation()
    })
  } else {
    // User is authenticated, cleanup animations
    cleanupAnimations()
  }
}, { immediate: true })

const cleanupAnimations = () => {
  // Clear typewriter timeout
  if (typewriterTimeout.value) {
    clearTimeout(typewriterTimeout.value)
    typewriterTimeout.value = null
  }
  
  // Disconnect scroll observer
  if (scrollObserver.value) {
    scrollObserver.value.disconnect()
    scrollObserver.value = null
  }
}

const startTypewriterAnimation = () => {
  const text = "FolioLink"
  const element = document.getElementById('typewriter-text')
  if (!element) return
  
  // Clear any existing timeout
  if (typewriterTimeout.value) {
    clearTimeout(typewriterTimeout.value)
  }
  
  let currentText = ""
  let isDeleting = false
  let charIndex = 0
  
  const typeSpeed = 150 // Vitesse d'écriture (ms)
  const deleteSpeed = 75 // Vitesse d'effacement (ms)
  const pauseTime = 2000 // Pause avant effacement (ms)
  
  function type() {
    if (!isDeleting) {
      // Mode écriture
      if (charIndex < text.length) {
        currentText += text.charAt(charIndex)
        element.textContent = currentText
        charIndex++
        typewriterTimeout.value = setTimeout(type, typeSpeed)
      } else {
        // Texte complet, attendre puis commencer l'effacement
        typewriterTimeout.value = setTimeout(() => {
          isDeleting = true
          type()
        }, pauseTime)
      }
    } else {
      // Mode effacement
      if (currentText.length > 0) {
        currentText = currentText.slice(0, -1)
        element.textContent = currentText
        typewriterTimeout.value = setTimeout(type, deleteSpeed)
      } else {
        // Texte effacé, recommencer l'écriture
        isDeleting = false
        charIndex = 0
        typewriterTimeout.value = setTimeout(type, typeSpeed)
      }
    }
  }
  
  // Démarrer l'animation après un court délai
  typewriterTimeout.value = setTimeout(type, 1000)
}

const setupScrollAnimations = () => {
  // Disconnect existing observer if any
  if (scrollObserver.value) {
    scrollObserver.value.disconnect()
  }
  
  scrollObserver.value = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add('animate-in')
      }
    })
  }, {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
  })

  // Observer tous les éléments avec la classe scroll-animate
  nextTick(() => {
    const elements = document.querySelectorAll('.scroll-animate')
    elements.forEach(el => {
      if (scrollObserver.value) {
        scrollObserver.value.observe(el)
      }
    })
  })
}

const checkAuthAndLoadData = async () => {
  const user = await authService.getCurrentUser()
  isAuthenticated.value = !!user
  
  if (isAuthenticated.value && user) {
    await loadUserData(user.id)
  } else {
    await loadExampleData()
  }
}

const loadUserData = async (userId: string) => {
  try {
    // Load user profile
    const { data: profile } = await profileService.getProfile(userId)
    if (profile) {
      userProfile.value = profile
    }
    
    // Load user projects
    const { data: projets } = await projetService.getUserProjets(userId)
    if (projets) {
      userProjets.value = projets
    }
    
    // Load user apprentissages
    const { data: apprentissages } = await apprentissageService.getUserApprentissages(userId)
    if (apprentissages) {
      userApprentissages.value = apprentissages
    }
    
    // Load featured apprentissages
    const { data: featured } = await featuredApprentissageService.getFeaturedApprentissages(userId)
    if (featured) {
      featuredApprentissages.value = featured
    }
    
    // Load competences for titles
    const { data: userCompetences } = await competenceService.getCompetences()
    if (userCompetences) {
      competences.value = userCompetences
    }
    
    // Calculate stats
    userStats.value = {
      apprentissages: userApprentissages.value.length,
      projets: userProjets.value.length,
      competencesMaitrisees: userApprentissages.value.filter(a => a.evaluation === 'Bien Maîtrisé').length
    }
  } catch (error) {
    console.error('Error loading user data:', error)
  }
}
const loadExampleData = async () => {
  try {
    const { data } = await exampleDataService.getExampleProjets()
    if (data && data.length > 0) {
      exampleProjets.value = data
    } else {
      // Fallback data if no example projects exist
      exampleProjets.value = [
        {
          id: 'demo-1',
          titre: 'Système de Contrôle Automatisé',
          description: 'Conception et développement d\'un système de contrôle automatisé pour une ligne de production industrielle.',
          icone: '⚙️',
          niveau: 'Projet de 2ème année',
          duree: '6 mois',
          technologies: ['Automatisme', 'PLC', 'SCADA', 'Supervision'],
          fonctionnalites: ['Programmation automate', 'Interface SCADA', 'Communication Modbus'],
          statut: 'Terminé',
          created_at: new Date().toISOString()
        },
        {
          id: 'demo-2',
          titre: 'Interface de Supervision IoT',
          description: 'Développement d\'une interface web moderne pour la supervision en temps réel d\'équipements industriels connectés.',
          icone: '📱',
          niveau: 'Projet de 3ème année',
          duree: '4 mois',
          technologies: ['IoT', 'Vue.js', 'Data Viz', 'Real-time'],
          fonctionnalites: ['Frontend Vue.js', 'Backend Node.js', 'WebSockets temps réel'],
          statut: 'Terminé',
          created_at: new Date().toISOString()
        }
      ]
    }
  } catch (error) {
    console.error('Error loading example data:', error)
    exampleProjets.value = []
  }
}

const openProjectModal = (project: any) => {
  selectedProject.value = project
  showProjectModal.value = true
}

const closeProjectModal = () => {
  showProjectModal.value = false
  selectedProject.value = null
}

const getProjectDetails = (project: any) => {
  return {
    id: project.id,
    title: project.titre,
    description: project.description,
    technologies: project.technologies || [],
    objectifs: ['Démonstration des capacités de FolioLink'],
    realisations: project.fonctionnalites || [],
    competences: ['Exemple de compétences'],
    duree: project.duree,
    niveau: project.niveau,
    fichiers: []
  }
}

const scrollToTop = () => {
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

const getInitials = (name: string) => {
  if (!name) return '??'
  return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)
}

const getCompetenceTitle = (competenceId: string) => {
  const competence = competences.value.find(c => c.id === competenceId)
  return competence?.title || 'Compétence'
}

// Navigation methods for clickable items
const navigateToProjectDetail = (projet: any) => {
  // Navigate to projects page and open the specific project
  router.push({
    path: '/projets',
    query: { project: projet.id }
  })
}

const navigateToApprentissageDetail = (apprentissage: any) => {
  // Navigate to portfolio page and open the specific apprentissage
  router.push({
    path: '/portfolio',
    query: { 
      competence: apprentissage.competence_id,
      apprentissage: apprentissage.id 
    }
  })
}

const navigateToProjectExample = (projet: any) => {
  // Navigate to projects page to see examples
  router.push('/projets')
}

const getBackgroundStyle = () => {
  if (!isAuthenticated.value || !userBackground.value) return {}
  
  switch (userBackground.value.type) {
    case 'image':
      return userBackground.value.url ? {
        backgroundImage: `url(${userBackground.value.url})`,
        backgroundSize: 'cover',
        backgroundPosition: 'center',
        backgroundAttachment: 'fixed'
      } : {}
    
    case 'gradient':
      return userBackground.value.settings?.gradient ? {
        background: userBackground.value.settings.gradient
      } : {}
    
    case 'solid':
      return userBackground.value.settings?.color ? {
        backgroundColor: userBackground.value.settings.color
      } : {}
    
    default:
      return {} // Keep default gradient from CSS classes
  }
}
</script>

<style scoped>
/* Animation du curseur clignotant */
.typewriter-animated::after {
  content: '|';
  color: #facc15;
  animation: blink 1s infinite;
  margin-left: 2px;
}

@keyframes blink {
  0%, 50% { opacity: 1; }
  51%, 100% { opacity: 0; }
}

/* Animations au scroll */
.scroll-animate {
  opacity: 0;
  transform: translateY(30px);
  transition: all 0.8s ease-out;
}

.scroll-animate.animate-in {
  opacity: 1;
  transform: translateY(0);
}

/* Délais pour effet cascade */
.scroll-animate:nth-child(1) { transition-delay: 0.1s; }
.scroll-animate:nth-child(2) { transition-delay: 0.2s; }
.scroll-animate:nth-child(3) { transition-delay: 0.3s; }
.scroll-animate:nth-child(4) { transition-delay: 0.4s; }

@keyframes float {
  0%, 100% { transform: translateY(0px) rotate(0deg); }
  33% { transform: translateY(-10px) rotate(1deg); }
  66% { transform: translateY(5px) rotate(-1deg); }
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes slideUp {
  from { opacity: 0; transform: translateY(40px); }
  to { opacity: 1; transform: translateY(0); }
}

.animate-fade-in {
  animation: fadeIn 0.8s ease-out;
}

.animate-slide-up {
  animation: slideUp 1s ease-out 0.2s both;
}

/* Enhanced CTA animation */
@keyframes pulse-cta {
  0%, 100% {
    transform: scale(1);
    box-shadow: 0 0 0 0 rgba(250, 204, 21, 0.4);
  }
  50% {
    transform: scale(1.02);
    box-shadow: 0 0 0 10px rgba(250, 204, 21, 0);
  }
}

.animate-pulse-cta {
  animation: pulse-cta 2s infinite;
}
</style>