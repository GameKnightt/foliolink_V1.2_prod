<template>
  <div class="pt-16 min-h-screen bg-gray-50 dark:bg-gray-900">
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <!-- Header -->
      <div class="text-center mb-12">
        <h1 class="text-4xl md:text-5xl font-bold text-gray-900 dark:text-white mb-6">
          Conditions d'<span class="text-gradient">Utilisation</span>
        </h1>
        <p class="text-xl text-gray-600 dark:text-gray-300">
          Dernière mise à jour : {{ new Date().toLocaleDateString('fr-FR') }}
        </p>
      </div>

      <!-- Content -->
      <div class="card p-8 prose prose-lg max-w-none dark:prose-invert">
        <h2>1. Présentation du Service</h2>
        <p>
          FolioLink est une plateforme gratuite dédiée aux étudiants en Bachelor Universitaire de Technologie (BUT) 
          pour créer et gérer leur portfolio étudiant. Le service permet de présenter les compétences, projets et 
          apprentissages critiques dans le cadre de la formation BUT.
        </p>

        <h2>2. Acceptation des Conditions</h2>
        <p>
          En utilisant FolioLink, vous acceptez pleinement et sans réserve les présentes conditions d'utilisation. 
          Si vous n'acceptez pas ces conditions, vous ne devez pas utiliser le service.
        </p>

        <h2>3. Éligibilité</h2>
        <p>
          FolioLink est destiné aux étudiants en formation BUT, aux diplômés BUT et aux professionnels de l'éducation 
          accompagnant ces étudiants. Vous devez être âgé d'au moins 16 ans pour utiliser ce service.
        </p>

        <h2>4. Création de Compte</h2>
        <p>
          Pour utiliser FolioLink, vous devez créer un compte en fournissant des informations exactes et complètes. 
          Vous êtes responsable de :
        </p>
        <ul>
          <li>La confidentialité de vos identifiants de connexion</li>
          <li>Toutes les activités effectuées sous votre compte</li>
          <li>La mise à jour de vos informations personnelles</li>
          <li>Nous signaler immédiatement tout usage non autorisé de votre compte</li>
        </ul>

        <h2>5. Utilisation du Service</h2>
        <h3>5.1 Utilisation Autorisée</h3>
        <p>Vous pouvez utiliser FolioLink pour :</p>
        <ul>
          <li>Créer et gérer votre portfolio étudiant BUT</li>
          <li>Présenter vos compétences et apprentissages critiques</li>
          <li>Documenter vos projets étudiants</li>
          <li>Partager votre portfolio avec des maîtres de stage, tuteurs ou employeurs</li>
        </ul>

        <h3>5.2 Utilisation Interdite</h3>
        <p>Il est strictement interdit de :</p>
        <ul>
          <li>Utiliser le service à des fins commerciales sans autorisation</li>
          <li>Publier du contenu illégal, offensant ou inapproprié</li>
          <li>Usurper l'identité d'une autre personne</li>
          <li>Tenter de compromettre la sécurité du service</li>
          <li>Utiliser des robots ou scripts automatisés</li>
          <li>Copier ou reproduire le contenu d'autres utilisateurs sans permission</li>
        </ul>

        <h2>6. Contenu Utilisateur</h2>
        <h3>6.1 Propriété du Contenu</h3>
        <p>
          Vous conservez tous les droits de propriété intellectuelle sur le contenu que vous publiez 
          (projets, descriptions, documents). FolioLink ne revendique aucun droit de propriété sur votre contenu.
        </p>

        <h3>6.2 Licence d'Utilisation</h3>
        <p>
          En publiant du contenu sur FolioLink, vous accordez à la plateforme une licence non exclusive 
          pour héberger, afficher et distribuer votre contenu dans le cadre du service.
        </p>

        <h3>6.3 Responsabilité du Contenu</h3>
        <p>
          Vous êtes seul responsable du contenu que vous publiez. Vous garantissez que votre contenu :
        </p>
        <ul>
          <li>Ne viole aucun droit de propriété intellectuelle</li>
          <li>Est exact et non trompeur</li>
          <li>Respecte les lois en vigueur</li>
          <li>Ne contient pas de virus ou code malveillant</li>
        </ul>

        <h2>7. Gratuité du Service</h2>
        <p>
          FolioLink est actuellement gratuit pour tous les étudiants BUT. Nous nous réservons le droit 
          d'introduire des fonctionnalités payantes à l'avenir, mais les fonctionnalités de base 
          resteront gratuites pour les étudiants.
        </p>

        <h2>8. Disponibilité du Service</h2>
        <p>
          Nous nous efforçons de maintenir FolioLink disponible 24h/24 et 7j/7, mais nous ne pouvons 
          garantir une disponibilité ininterrompue. Le service peut être temporairement indisponible 
          pour maintenance ou en cas de force majeure.
        </p>

        <h2>9. Modification du Service</h2>
        <p>
          Nous nous réservons le droit de modifier, suspendre ou interrompre tout ou partie du service 
          à tout moment, avec ou sans préavis. Nous nous efforcerons de vous informer des modifications 
          importantes à l'avance.
        </p>

        <h2>10. Résiliation</h2>
        <h3>10.1 Résiliation par l'Utilisateur</h3>
        <p>
          Vous pouvez supprimer votre compte à tout moment depuis les paramètres de votre profil. 
          La suppression entraîne la perte définitive de toutes vos données.
        </p>

        <h3>10.2 Résiliation par FolioLink</h3>
        <p>
          Nous pouvons suspendre ou supprimer votre compte en cas de violation des présentes conditions, 
          avec un préavis de 30 jours sauf en cas de violation grave.
        </p>

        <h2>11. Limitation de Responsabilité</h2>
        <p>
          FolioLink est fourni "en l'état" sans garantie d'aucune sorte. Nous ne sommes pas responsables :
        </p>
        <ul>
          <li>Des dommages directs ou indirects liés à l'utilisation du service</li>
          <li>De la perte de données due à des problèmes techniques</li>
          <li>Des conséquences de l'utilisation de votre portfolio par des tiers</li>
          <li>Des interruptions de service</li>
        </ul>

        <h2>12. Protection des Données</h2>
        <p>
          Le traitement de vos données personnelles est régi par notre 
          <router-link to="/privacy-policy" class="text-primary-600 hover:text-primary-700">
            Politique de Confidentialité
          </router-link>, 
          qui fait partie intégrante des présentes conditions.
        </p>

        <h2>13. Propriété Intellectuelle</h2>
        <p>
          FolioLink, son logo, son design et ses fonctionnalités sont protégés par les droits de propriété 
          intellectuelle. Vous ne pouvez pas reproduire, modifier ou distribuer ces éléments sans autorisation.
        </p>

        <h2>14. Droit Applicable</h2>
        <p>
          Les présentes conditions sont régies par le droit français. Tout litige sera soumis à la 
          compétence exclusive des tribunaux français.
        </p>

        <h2>15. Modifications des Conditions</h2>
        <p>
          Nous pouvons modifier ces conditions à tout moment. Les modifications importantes vous seront 
          notifiées par email ou via la plateforme. L'utilisation continue du service après notification 
          vaut acceptation des nouvelles conditions.
        </p>

        <h2>16. Contact</h2>
        <p>
          Pour toute question concernant ces conditions d'utilisation, vous pouvez nous contacter à :
        </p>
        <ul>
          <li>Email : contact@foliolink.fr</li>
          <li>Adresse : Saint-Herblain, 44800, FRANCE</li>
        </ul>

        <div class="mt-12 p-6 bg-primary-50 dark:bg-primary-900/20 rounded-lg">
          <h3 class="text-lg font-semibold text-primary-900 dark:text-primary-100 mb-2">
            📚 Spécial Étudiants BUT
          </h3>
          <p class="text-primary-800 dark:text-primary-200">
            FolioLink est conçu spécifiquement pour accompagner votre parcours BUT. Nous comprenons 
            les enjeux de votre formation et nous engageons à maintenir un service adapté à vos besoins 
            étudiants, notamment pour vos stages, alternances et recherche d'emploi.
          </p>
        </div>
      </div>

      <!-- Navigation -->
      <div class="mt-12 text-center">
        <router-link to="/" class="btn-primary mr-4">
          Retour à l'accueil
        </router-link>
        <router-link to="/privacy-policy" class="btn-secondary">
          Politique de confidentialité
        </router-link>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// Component logic if needed
</script>

<style scoped>
.prose h2 {
  @apply text-2xl font-bold text-gray-900 dark:text-white mt-8 mb-4;
}

.prose h3 {
  @apply text-xl font-semibold text-gray-800 dark:text-gray-200 mt-6 mb-3;
}

.prose p {
  @apply text-gray-700 dark:text-gray-300 mb-4 leading-relaxed;
}

.prose ul {
  @apply text-gray-700 dark:text-gray-300 mb-4 pl-6;
}

.prose li {
  @apply mb-2;
}
</style>