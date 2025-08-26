<template>
  <div class="pt-16 min-h-screen bg-gray-50 dark:bg-gray-900">
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <!-- Header -->
      <div class="text-center mb-12">
        <h1 class="text-4xl md:text-5xl font-bold text-gray-900 dark:text-white mb-6">
          Mentions <span class="text-gradient">Légales</span>
        </h1>
        <p class="text-xl text-gray-600 dark:text-gray-300">
          Informations légales et éditoriales
        </p>
      </div>

      <!-- Content -->
      <div class="card p-8 prose prose-lg max-w-none dark:prose-invert">
        <h2>1. Éditeur du Site</h2>
        <p>
          Le site web FolioLink est édité par :
        </p>
        <ul>
          <li><strong>Nom :</strong> FolioLink</li>
          <li><strong>Forme juridique :</strong> Auto-entrepreneur</li>
          <li><strong>Adresse :</strong> Saint-Herblain, 44800, FRANCE</li>
          <li><strong>Email :</strong> contact@foliolink.fr</li>
          <li><strong>Directeur de publication :</strong> Alexy LESAULNIER</li>
        </ul>

        <h2>2. Hébergement</h2>
        <p>
          Le site FolioLink est hébergé par :
        </p>
        <ul>
          <li><strong>Netlify, Inc.</strong></li>
          <li><strong>Adresse :</strong> 44 Montgomery Street, Suite 300, San Francisco, CA 94104, États-Unis</li>
          <li><strong>Site web : www.foliolink.fr</strong> </li>
        </ul>

        <h3>2.1 Base de Données</h3>
        <p>
          Les données sont hébergées par :
        </p>
        <ul>
          <li><strong>Supabase, Inc.</strong></li>
          <li><strong>Adresse :</strong> 970 Toa Payoh North #07-04, Singapore 318992</li>
        </ul>

        <h3>2.2 Nom de Domaine</h3>
        <p>
          Le nom de domaine est hébergé par :
        </p>
        <ul>
          <li><strong>Hostinger International Ltd.</strong></li>
          <li><strong>Adresse :</strong> 61 Lordou Vironos Street, 6023 Larnaca, Chypre</li>
          <li><strong>Site web :</strong> www.hostinger.fr</li>
        </ul>

        <h2>3. Propriété Intellectuelle</h2>
        <h3>3.1 Droits d'Auteur</h3>
        <p>
          L'ensemble du site FolioLink (structure, design, textes, images, logos) est protégé par le droit d'auteur. 
          Toute reproduction, même partielle, est interdite sans autorisation préalable écrite.
        </p>

        <h3>3.2 Marques</h3>
        <p>
          "FolioLink" est une marque déposée. L'utilisation de cette marque sans autorisation est interdite.
        </p>

        <h3>3.3 Contenu Utilisateur</h3>
        <p>
          Les utilisateurs conservent tous les droits de propriété intellectuelle sur le contenu qu'ils publient 
          (portfolios, projets, descriptions). FolioLink ne revendique aucun droit sur ce contenu.
        </p>

        <h2>4. Responsabilité</h2>
        <h3>4.1 Contenu du Site</h3>
        <p>
          FolioLink s'efforce de fournir des informations exactes et à jour, mais ne peut garantir 
          l'exactitude, la complétude ou l'actualité des informations diffusées.
        </p>

        <h3>4.2 Disponibilité du Service</h3>
        <p>
          FolioLink ne peut être tenu responsable des interruptions de service, qu'elles soient 
          programmées ou non, ni des conséquences de ces interruptions.
        </p>

        <h3>4.3 Liens Externes</h3>
        <p>
          Le site peut contenir des liens vers des sites externes. FolioLink n'est pas responsable 
          du contenu de ces sites tiers.
        </p>

        <h2>5. Données Personnelles</h2>
        <p>
          Le traitement des données personnelles est régi par notre 
          <router-link to="/privacy-policy" class="text-primary-600 hover:text-primary-700">
            Politique de Confidentialité
          </router-link>, 
          conforme au Règlement Général sur la Protection des Données (RGPD).
        </p>

        <h3>5.1 Responsable du Traitement</h3>
        <ul>
          <li><strong>Responsable :</strong> FolioLink</li>
          <li><strong>Contact DPO :</strong> contact@foliolink.fr</li>
          <li><strong>Finalité :</strong> Fourniture du service de portfolio étudiant</li>
        </ul>

        <h2>6. Cookies</h2>
        <p>
          Le site utilise des cookies techniques nécessaires au fonctionnement du service :
        </p>
        <ul>
          <li><strong>Cookies de session :</strong> Authentification et navigation</li>
          <li><strong>Cookies de préférences :</strong> Thème, langue</li>
          <li><strong>Cookies analytiques :</strong> Mesure d'audience anonymisée</li>
        </ul>

        <h2>7. Droit Applicable</h2>
        <p>
          Les présentes mentions légales sont soumises au droit français. 
          En cas de litige, les tribunaux français seront seuls compétents.
        </p>

        <h2>8. Médiation</h2>
        <p>
          En cas de litige, une solution amiable sera recherchée avant toute action judiciaire. 
          Vous pouvez recourir à la médiation de la consommation via la plateforme officielle : 
          <a href="https://www.economie.gouv.fr/mediation-conso" target="_blank" rel="noopener noreferrer">
            www.economie.gouv.fr/mediation-conso
          </a>
        </p>

        <h2>9. Accessibilité</h2>
        <p>
          FolioLink s'efforce de rendre son site accessible à tous les utilisateurs, 
          conformément aux standards d'accessibilité web (WCAG 2.1).
        </p>

        <h2>10. Contact</h2>
        <p>
          Pour toute question concernant ces mentions légales :
        </p>
        <ul>
          <li><strong>Email :</strong> contact@foliolink.fr</li>
          <li><strong>Adresse :</strong> Saint-Herblain, 44800, FRANCE</li>
        </ul>

        <div class="mt-12 p-6 bg-blue-50 dark:bg-blue-900/20 rounded-lg">
          <h3 class="text-lg font-semibold text-blue-900 dark:text-blue-100 mb-2">
            📚 Service Étudiant
          </h3>
          <p class="text-blue-800 dark:text-blue-200">
            FolioLink est un service dédié aux étudiants en Bachelor Universitaire de Technologie (BUT). 
            Nous nous engageons à respecter la réglementation française et européenne en matière de 
            protection des données étudiantes et de services numériques éducatifs.
          </p>
        </div>

        <div class="mt-6 p-6 bg-green-50 dark:bg-green-900/20 rounded-lg">
          <h3 class="text-lg font-semibold text-green-900 dark:text-green-100 mb-2">
            🌱 Engagement Environnemental
          </h3>
          <p class="text-green-800 dark:text-green-200">
            FolioLink utilise des infrastructures cloud optimisées pour réduire son empreinte carbone. 
            Nos serveurs fonctionnent avec de l'énergie renouvelable et nous optimisons constamment 
            les performances pour minimiser la consommation énergétique.
          </p>
        </div>
      </div>

      <!-- Navigation -->
      <div class="mt-12 text-center">
        <router-link to="/" class="btn-primary mr-4">
          Retour à l'accueil
        </router-link>
        <div class="flex flex-col sm:flex-row gap-4 justify-center mt-4">
          <router-link to="/terms-of-service" class="btn-secondary">
            Conditions d'utilisation
          </router-link>
          <router-link to="/privacy-policy" class="btn-secondary">
            Politique de confidentialité
          </router-link>
        </div>
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

.prose strong {
  @apply text-gray-900 dark:text-white;
}
</style>