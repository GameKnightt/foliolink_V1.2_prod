<template>
  <div class="pt-16 min-h-screen bg-gray-50 dark:bg-gray-900">
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <!-- Header -->
      <div class="text-center mb-12">
        <h1 class="text-4xl md:text-5xl font-bold text-gray-900 dark:text-white mb-6">
          Politique de <span class="text-gradient">Confidentialité</span>
        </h1>
        <p class="text-xl text-gray-600 dark:text-gray-300">
          Dernière mise à jour : {{ new Date().toLocaleDateString('fr-FR') }}
        </p>
      </div>

      <!-- Content -->
      <div class="card p-8 prose prose-lg max-w-none dark:prose-invert">
        <h2>1. Introduction</h2>
        <p>
          FolioLink s'engage à protéger la confidentialité et la sécurité de vos données personnelles. 
          Cette politique explique comment nous collectons, utilisons, stockons et protégeons vos informations 
          dans le cadre de votre utilisation de notre plateforme de portfolio étudiant BUT.
        </p>

        <h2>2. Responsable du Traitement</h2>
        <p>
          Le responsable du traitement des données personnelles est :
        </p>
        <ul>
          <li>Nom : FolioLink</li>
          <li>Email : contact@foliolink.fr</li>
          <li>Adresse : Saint-Herblain, 44800, FRANCE</li>
        </ul>

        <h2>3. Données Collectées</h2>
        <h3>3.1 Données d'Inscription</h3>
        <p>Lors de la création de votre compte, nous collectons :</p>
        <ul>
          <li>Nom complet</li>
          <li>Adresse email</li>
          <li>Mot de passe (chiffré)</li>
          <li>Formation BUT suivie</li>
          <li>Année d'études</li>
          <li>Établissement</li>
        </ul>

        <h3>3.2 Données de Profil</h3>
        <p>Vous pouvez volontairement renseigner :</p>
        <ul>
          <li>Numéro de téléphone</li>
          <li>Profils LinkedIn et GitHub</li>
          <li>Présentation personnelle</li>
          <li>Photo de profil</li>
        </ul>

        <h3>3.3 Données de Portfolio</h3>
        <p>Dans le cadre de votre portfolio, vous créez :</p>
        <ul>
          <li>Descriptions de projets étudiants</li>
          <li>Apprentissages critiques</li>
          <li>Évaluations de compétences</li>
          <li>Fichiers et liens vers vos réalisations</li>
          <li>Argumentaires de maîtrise</li>
        </ul>

        <h3>3.4 Données Techniques</h3>
        <p>Nous collectons automatiquement :</p>
        <ul>
          <li>Adresse IP</li>
          <li>Type de navigateur et version</li>
          <li>Système d'exploitation</li>
          <li>Pages visitées et temps passé</li>
          <li>Date et heure de connexion</li>
        </ul>

        <h2>4. Finalités du Traitement</h2>
        <h3>4.1 Fourniture du Service</h3>
        <ul>
          <li>Création et gestion de votre compte</li>
          <li>Hébergement de votre portfolio étudiant</li>
          <li>Sauvegarde de vos données</li>
          <li>Support technique</li>
        </ul>

        <h3>4.2 Amélioration du Service</h3>
        <ul>
          <li>Analyse d'utilisation pour améliorer l'expérience</li>
          <li>Développement de nouvelles fonctionnalités</li>
          <li>Résolution de bugs et problèmes techniques</li>
        </ul>

        <h3>4.3 Communication</h3>
        <ul>
          <li>Notifications importantes sur le service</li>
          <li>Mises à jour de sécurité</li>
          <li>Réponses à vos demandes de support</li>
        </ul>

        <h2>5. Base Légale du Traitement</h2>
        <p>Nos traitements de données personnelles sont fondés sur :</p>
        <ul>
          <li><strong>Contrat</strong> : Exécution du service FolioLink</li>
          <li><strong>Consentement</strong> : Données optionnelles du profil</li>
          <li><strong>Intérêt légitime</strong> : Amélioration du service et sécurité</li>
          <li><strong>Obligation légale</strong> : Conservation pour obligations comptables</li>
        </ul>

        <h2>6. Partage des Données</h2>
        <h3>6.1 Principe de Non-Partage</h3>
        <p>
          Nous ne vendons, ne louons, ni ne partageons vos données personnelles avec des tiers 
          à des fins commerciales.
        </p>

        <h3>6.2 Partage Autorisé</h3>
        <p>Vos données peuvent être partagées uniquement dans les cas suivants :</p>
        <ul>
          <li><strong>Avec votre consentement explicite</strong> : Partage de portfolio avec employeurs</li>
          <li><strong>Prestataires techniques</strong> : Hébergement sécurisé (Supabase)</li>
          <li><strong>Obligations légales</strong> : Réquisitions judiciaires</li>
          <li><strong>Protection des droits</strong> : Prévention de fraudes ou abus</li>
        </ul>

        <h3>6.3 Transferts Internationaux</h3>
        <p>
          Nos données sont hébergées par Supabase (États-Unis) avec des garanties de protection 
          conformes au RGPD (clauses contractuelles types).
        </p>

        <h2>7. Sécurité des Données</h2>
        <h3>7.1 Mesures Techniques</h3>
        <ul>
          <li>Chiffrement des données en transit (HTTPS/TLS)</li>
          <li>Chiffrement des mots de passe (bcrypt)</li>
          <li>Authentification sécurisée</li>
          <li>Sauvegardes automatiques chiffrées</li>
          <li>Surveillance des accès</li>
        </ul>

        <h3>7.2 Mesures Organisationnelles</h3>
        <ul>
          <li>Accès limité aux données (principe du moindre privilège)</li>
          <li>Formation du personnel à la protection des données</li>
          <li>Procédures de réponse aux incidents</li>
          <li>Audits de sécurité réguliers</li>
        </ul>

        <h2>8. Conservation des Données</h2>
        <h3>8.1 Durées de Conservation</h3>
        <ul>
          <li><strong>Compte actif</strong> : Tant que le compte existe</li>
          <li><strong>Compte supprimé</strong> : 30 jours (sauvegarde de sécurité)</li>
          <li><strong>Données techniques</strong> : 12 mois maximum</li>
          <li><strong>Données comptables</strong> : 10 ans (obligation légale)</li>
        </ul>

        <h3>8.2 Suppression Automatique</h3>
        <p>
          Les comptes inactifs depuis plus de 3 ans font l'objet d'une notification 
          avant suppression automatique.
        </p>

        <h2>9. Vos Droits</h2>
        <p>Conformément au RGPD, vous disposez des droits suivants :</p>

        <h3>9.1 Droit d'Accès</h3>
        <p>Obtenir une copie de toutes vos données personnelles.</p>

        <h3>9.2 Droit de Rectification</h3>
        <p>Corriger ou mettre à jour vos données inexactes ou incomplètes.</p>

        <h3>9.3 Droit à l'Effacement</h3>
        <p>Demander la suppression de vos données dans certaines conditions.</p>

        <h3>9.4 Droit à la Limitation</h3>
        <p>Limiter le traitement de vos données dans certains cas.</p>

        <h3>9.5 Droit à la Portabilité</h3>
        <p>Récupérer vos données dans un format structuré et lisible.</p>

        <h3>9.6 Droit d'Opposition</h3>
        <p>Vous opposer au traitement de vos données pour des raisons légitimes.</p>

        <h3>9.7 Exercice des Droits</h3>
        <p>
          Pour exercer vos droits, contactez-nous à : privacy@foliolink.fr
          <br>
          Nous répondrons dans un délai maximum de 30 jours.
        </p>

        <h2>10. Cookies et Technologies Similaires</h2>
        <h3>10.1 Cookies Utilisés</h3>
        <ul>
          <li><strong>Cookies essentiels</strong> : Fonctionnement du service (session, authentification)</li>
          <li><strong>Cookies de préférences</strong> : Thème sombre/clair, langue</li>
          <li><strong>Cookies analytiques</strong> : Mesure d'audience anonymisée</li>
        </ul>

        <h3>10.2 Gestion des Cookies</h3>
        <p>
          Vous pouvez configurer votre navigateur pour refuser les cookies, mais cela peut 
          affecter le fonctionnement du service.
        </p>

        <h2>11. Mineurs</h2>
        <p>
          FolioLink peut être utilisé par des étudiants mineurs (16-18 ans) dans le cadre 
          de leur formation BUT. Pour les mineurs de moins de 16 ans, le consentement 
          parental est requis.
        </p>

        <h2>12. Modifications de la Politique</h2>
        <p>
          Cette politique peut être modifiée pour refléter les évolutions du service ou 
          de la réglementation. Les modifications importantes vous seront notifiées par 
          email avec un préavis de 30 jours.
        </p>

        <h2>13. Réclamations</h2>
        <p>
          Si vous estimez que vos droits ne sont pas respectés, vous pouvez déposer 
          une réclamation auprès de la CNIL :
        </p>
        <ul>
          <li>Site web : www.cnil.fr</li>
          <li>Adresse : 3 Place de Fontenoy - TSA 80715 - 75334 PARIS CEDEX 07</li>
          <li>Téléphone : 01 53 73 22 22</li>
        </ul>

        <h2>14. Contact</h2>
        <p>
          Pour toute question concernant cette politique de confidentialité :
        </p>
        <ul>
          <li>Email : contact@foliolink.fr</li>
        </ul>

        <div class="mt-12 p-6 bg-green-50 dark:bg-green-900/20 rounded-lg">
          <h3 class="text-lg font-semibold text-green-900 dark:text-green-100 mb-2">
            🔒 Engagement FolioLink
          </h3>
          <p class="text-green-800 dark:text-green-200">
            Nous nous engageons à protéger vos données étudiantes avec le plus haut niveau de sécurité. 
            Votre portfolio BUT contient des informations précieuses pour votre avenir professionnel, 
            et nous en sommes les gardiens responsables.
          </p>
        </div>

        <div class="mt-6 p-6 bg-blue-50 dark:bg-blue-900/20 rounded-lg">
          <h3 class="text-lg font-semibold text-blue-900 dark:text-blue-100 mb-2">
            📚 Spécial Étudiants BUT
          </h3>
          <p class="text-blue-800 dark:text-blue-200">
            Vos projets étudiants, apprentissages critiques et évaluations de compétences sont 
            strictement confidentiels. Seuls vous et les personnes que vous autorisez explicitement 
            (maîtres de stage, tuteurs, employeurs) peuvent y accéder.
          </p>
        </div>
      </div>

      <!-- Navigation -->
      <div class="mt-12 text-center">
        <router-link to="/" class="btn-primary mr-4">
          Retour à l'accueil
        </router-link>
        <router-link to="/terms-of-service" class="btn-secondary">
          Conditions d'utilisation
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