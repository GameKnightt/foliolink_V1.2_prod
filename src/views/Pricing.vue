<template>
  <div class="pt-16 min-h-screen bg-gradient-to-br from-gray-900 via-blue-900 to-gray-900">
    <!-- Hero Section -->
    <section class="relative py-20 overflow-hidden">
      <!-- Animated Background Elements -->
      <div class="absolute inset-0">
        <div class="absolute top-20 left-10 w-72 h-72 bg-accent-500/10 rounded-full blur-3xl animate-pulse"></div>
        <div class="absolute bottom-20 right-10 w-96 h-96 bg-primary-500/10 rounded-full blur-3xl animate-pulse delay-1000"></div>
      </div>
      
      <div class="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center z-10">
        <!-- Badge -->
        <div class="inline-flex items-center glass-card px-6 py-3 mb-8 animate-fade-in">
          <span class="text-accent-400 mr-2">💎</span>
          <span class="text-white font-medium">Choisissez votre plan</span>
        </div>

        <!-- Launch Offer Banner -->
        <div class="max-w-4xl mx-auto mb-20">
          <div class="bg-gradient-to-r from-red-500 to-red-600 text-white p-6 rounded-2xl shadow-2xl relative overflow-hidden animate-pulse" v-if="isAuthenticated">
            <div class="text-center">
              <div class="text-3xl font-bold mb-2">🚀 FOLIOLINK PREMIUM 👑</div>
              <div class="text-xl mb-2">Portfolio BUT Premium à <span class="font-bold">10€</span> <span class="line-through text-red-200 ml-2">20€</span></div>
              <div class="text-lg opacity-90">🔥 Offre limitée : -50% de réduction !</div>
            </div>
          </div>
          <div class="bg-gradient-to-r from-red-500 to-red-600 text-white p-6 rounded-2xl shadow-2xl relative overflow-hidden animate-pulse" v-else>
            <div class="text-center">
              <div class="text-3xl font-bold mb-2">🚀 FOLIOLINK PREMIUM 👑</div>
              <div class="text-xl mb-2">Portfolio BUT Premium à <span class="font-bold">10€</span></div>
              <div class="text-lg opacity-90">Paiement unique - Accès à vie !</div>
            </div>
          </div>
        </div>

        <!-- Main Title -->
        <div class="animate-slide-up">
          <h1 class="text-5xl md:text-7xl font-bold text-white mb-6 leading-tight">
            Votre Portfolio BUT <span class="gradient-text text-glow">Sans Limites</span>
          </h1>
          
          <p class="text-xl md:text-2xl text-gray-300 mb-12 max-w-4xl mx-auto leading-relaxed">
            Commencez gratuitement et débloquez tout le potentiel de votre portfolio étudiant avec Premium
          </p>
        </div>
      </div>
    </section>

    <!-- Pricing Cards Section -->
    <section id="pricing-cards" class="py-20 relative">
      <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        
        <!-- Pricing Toggle (if needed for future subscriptions) -->
        <div class="text-center mb-12">
          <div class="inline-flex items-center glass-card px-4 py-2">
            <span class="text-white font-medium">💰 Paiement unique - Pas d'abonnement</span>
          </div>
        </div>

        <!-- Pricing Cards Grid -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 max-w-5xl mx-auto">
          
          <!-- Free Plan -->
          <div class="glass-card p-8 hover:scale-105 transition-all duration-500 relative">
            <div class="text-center mb-8">
              <div class="w-16 h-16 bg-gradient-to-r from-blue-400 to-blue-500 rounded-2xl flex items-center justify-center mx-auto mb-4">
                <span class="text-2xl">🆓</span>
              </div>
              <h3 class="text-3xl font-bold text-white mb-2">Gratuit</h3>
              <div class="text-5xl font-bold gradient-text mb-2">0€</div>
              <p class="text-gray-300">Pour toujours</p>
            </div>

            <!-- Free Features -->
            <div class="space-y-4 mb-8">
              <div class="flex items-center space-x-3">
                <div class="w-6 h-6 bg-green-500/20 rounded-full flex items-center justify-center">
                  <span class="text-green-400 text-sm">✓</span>
                </div>
                <span class="text-gray-300">Portfolio étudiant BUT complet</span>
              </div>
              
              <div class="flex items-center space-x-3">
                <div class="w-6 h-6 bg-green-500/20 rounded-full flex items-center justify-center">
                  <span class="text-green-400 text-sm">✓</span>
                </div>
                <span class="text-gray-300">Jusqu'à 3 compétences</span>
              </div>
              
              <div class="flex items-center space-x-3">
                <div class="w-6 h-6 bg-green-500/20 rounded-full flex items-center justify-center">
                  <span class="text-green-400 text-sm">✓</span>
                </div>
                <span class="text-gray-300">Jusqu'à 5 apprentissages critiques</span>
              </div>
              
              <div class="flex items-center space-x-3">
                <div class="w-6 h-6 bg-green-500/20 rounded-full flex items-center justify-center">
                  <span class="text-green-400 text-sm">✓</span>
                </div>
                <span class="text-gray-300">Jusqu'à 3 projets</span>
              </div>
              
              <div class="flex items-center space-x-3">
                <div class="w-6 h-6 bg-green-500/20 rounded-full flex items-center justify-center">
                  <span class="text-green-400 text-sm">✓</span>
                </div>
                <span class="text-gray-300">Partage de portfolio personnalisé</span>
              </div>
              
              <div class="flex items-center space-x-3">
                <div class="w-6 h-6 bg-green-500/20 rounded-full flex items-center justify-center">
                  <span class="text-green-400 text-sm">✓</span>
                </div>
                <span class="text-gray-300">Système de gamification</span>
              </div>
              
              <div class="flex items-center space-x-3">
                <div class="w-6 h-6 bg-green-500/20 rounded-full flex items-center justify-center">
                  <span class="text-green-400 text-sm">✓</span>
                </div>
                <span class="text-gray-300">Support communautaire</span>
              </div>
            </div>

            <!-- Free CTA -->
            <button 
              @click="handleFreeSignup"
              class="w-full btn-secondary text-lg py-4"
            >
              <span class="mr-2">🚀</span>
              {{ isAuthenticated ? 'Votre plan actuel' : 'Commencer gratuitement' }}
            </button>
          </div>

          <!-- Premium Plan -->
          <div class="glass-card p-8 hover:scale-105 transition-all duration-500 relative border-2 border-yellow-400 shadow-2xl shadow-yellow-400/20">
            <!-- Discount Badge in Corner -->
            <div class="absolute -top-3 -right-3 bg-red-500 text-white text-sm px-3 py-1 rounded-full font-bold animate-pulse shadow-lg z-10">
              -50%
            </div>
            
            <div class="text-center mb-8">
              <div class="w-16 h-16 bg-gradient-to-r from-yellow-400 to-yellow-500 rounded-2xl flex items-center justify-center mx-auto mb-4">
                <span class="text-2xl text-gray-900">👑</span>
              </div>
              <span class="text-gray-300">Découvrir Premium</span>
              <h3 class="text-3xl font-bold text-white mb-2">FolioLink Premium</h3>
              <div class="space-y-2">
                <div class="flex items-center justify-center space-x-3">
                  <div class="text-5xl font-bold text-yellow-400">10€</div>
                  <div class="text-2xl text-gray-400 line-through">20€</div>
                </div>
              </div>
              <p class="text-gray-300">Paiement unique - À vie</p>
              <div class="inline-flex items-center glass-card px-3 py-1 mt-2">
                <span class="text-yellow-400 text-sm font-medium">💰 Pas d'abonnement</span>
              </div>
            </div>

            <!-- Premium Features -->
            <div class="space-y-4 mb-8">
              <div class="flex items-center space-x-3">
                <div class="w-6 h-6 bg-yellow-400/30 rounded-full flex items-center justify-center">
                  <span class="text-yellow-400 text-sm">✓</span>
                </div>
                <span class="text-white font-medium">Tout du plan Gratuit +</span>
              </div>
              
              <div class="flex items-center space-x-3">
                <div class="w-6 h-6 bg-yellow-400/30 rounded-full flex items-center justify-center">
                  <span class="text-yellow-400 text-sm">✓</span>
                </div>
                <span class="text-gray-300"><strong>Rédaction IA personnalisé</strong> - Génération automatique d'argumentaires</span>
              </div>
              
              <div class="flex items-center space-x-3">
                <div class="w-6 h-6 bg-yellow-400/30 rounded-full flex items-center justify-center">
                  <span class="text-yellow-400 text-sm">✓</span>
                </div>
                <span class="text-gray-300"><strong>Partage public du portfolio avec lien personnalisé</strong></span>
              </div>
              
              <div class="flex items-center space-x-3">
                <div class="w-6 h-6 bg-yellow-400/30 rounded-full flex items-center justify-center">
                  <span class="text-yellow-400 text-sm">✓</span>
                </div>
                <span class="text-gray-300"><strong>Thèmes et personnalisation avancés</strong></span>
              </div>
              
              <div class="flex items-center space-x-3">
                <div class="w-6 h-6 bg-yellow-400/30 rounded-full flex items-center justify-center">
                  <span class="text-yellow-400 text-sm">∞</span>
                </div>
                <span class="text-gray-300"><strong>Contenu illimité</strong> - Compétences, apprentissages et projets sans limite</span>
              </div>
              
              <div class="flex items-center space-x-3">
                <div class="w-6 h-6 bg-yellow-400/30 rounded-full flex items-center justify-center">
                  <span class="text-yellow-400 text-sm">📊</span>
                </div>
                <span class="text-gray-300">Export Excel professionnel</span>
              </div>
              
              <div class="flex items-center space-x-3">
                <div class="w-6 h-6 bg-yellow-400/30 rounded-full flex items-center justify-center">
                  <span class="text-yellow-400 text-sm">🏆</span>
                </div>
                <span class="text-gray-300"><strong>Système de gamification</strong> - Trophées et niveaux pour motiver</span>
              </div>
              
              <div class="flex items-center space-x-3">
                <div class="w-6 h-6 bg-yellow-400/30 rounded-full flex items-center justify-center">
                  <span class="text-yellow-400 text-sm">✨</span>
                </div>
                <span class="text-gray-300"><strong>Et plus encore</strong></span>
              </div>
            </div>

            <!-- Premium CTA -->
            <button 
              @click="handlePremiumPurchase"
              :disabled="loading"
              class="w-full bg-gradient-to-r from-yellow-500 to-yellow-600 hover:from-yellow-600 hover:to-yellow-700 text-gray-900 font-semibold text-lg py-4 rounded-xl transition-all duration-300 hover:shadow-2xl hover:shadow-yellow-500/25 hover:scale-105 active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <span v-if="loading" class="mr-2">⏳</span>
              <span v-else class="mr-2">👑</span>
              {{ loading ? 'Redirection vers Stripe...' : (isAuthenticated ? 'Acheter FolioLink Premium (10€)' : 'Commencer avec FolioLink Premium (10€)') }}
            </button>
          </div>
        </div>


        <!-- FAQ Section -->
        <div class="mt-20 max-w-4xl mx-auto">
          <h2 class="text-3xl font-bold text-white mb-8 text-center">Questions Fréquentes</h2>
          
          <div class="space-y-6">
            <div class="glass-card p-6">
              <h3 class="text-xl font-semibold text-white mb-3">Pourquoi un paiement unique et pas un abonnement ?</h3>
              <p class="text-gray-300">
                Nous croyons que les étudiants ne devraient pas payer des frais récurrents pour l'IA et le partage public. 
                Avec FolioLink Premium à 10€, vous payez une seule fois et gardez l'IA illimitée à vie !
              </p>
            </div>
            
            <div class="glass-card p-6">
              <h3 class="text-xl font-semibold text-white mb-3">Comment fonctionne l'assistant IA personnalisé ?</h3>
              <p class="text-gray-300">
                Le modèle IA Mistral-Medium (🐓Cocorico !) analyse votre profil (formation BUT, établissement, année d'études) pour générer des argumentaires 
                )
                personnalisés et convaincants pour vos apprentissages critiques. Plus besoin de passer des heures à rédiger !
              </p>
            </div>
            
            <div class="glass-card p-6">
              <h3 class="text-xl font-semibold text-white mb-3">Comment fonctionne le partage public avec lien personnalisé ?</h3>
              <p class="text-gray-300">
                Créez votre lien personnalisé (ex: foliolink.fr/votre-nom) pour partager votre portfolio avec maîtres de stage, 
                jury ou recruteurs. Contrôlez entièrement la visibilité et désactivez quand vous voulez.
              </p>
            </div>
            
            <div class="glass-card p-6">
              <h3 class="text-xl font-semibold text-white mb-3">Qu'est-ce que le système de gamification ?</h3>
              <p class="text-gray-300">
                Débloquez des trophées et montez de niveau en enrichissant votre portfolio ! Le système vous motive 
                à compléter vos apprentissages et projets avec des récompenses et un suivi de progression.
              </p>
            </div>
            
            <div class="glass-card p-6">
              <h3 class="text-xl font-semibold text-white mb-3">Y a-t-il une garantie de remboursement ?</h3>
              <p class="text-gray-300">
                Oui ! Nous offrons une garantie satisfait ou remboursé de 30 jours. 
                Si vous n'êtes pas satisfait, contactez-nous pour un remboursement complet.
              </p>
            </div>
          </div>
        </div>

        <!-- Final CTA -->
        <div class="text-center mt-16">
          <div class="glass-card p-8 max-w-2xl mx-auto">
            <h2 class="text-3xl font-bold text-white mb-4">Prêt à révolutionner votre portfolio BUT ?</h2>
            <p class="text-gray-300 mb-8">
              Rejoignez des centaines d'étudiants qui utilisent l'IA personnalisée, le partage public et la gamification 
              pour créer des portfolios BUT exceptionnels et décrocher leurs stages plus rapidement.
            </p>
            
            <div class="flex flex-col sm:flex-row gap-4 justify-center">
              <button 
                @click="handlePremiumPurchase"
                :disabled="loading"
                class="btn-primary text-lg px-8 py-4"
              >
                <span class="mr-2">👑</span>
                {{ isAuthenticated ? 'Acheter FolioLink Premium (10€)' : 'Commencer avec FolioLink Premium (10€)' }}
              </button>
              
              <button 
                v-if="!isAuthenticated"
                @click="handleFreeSignup"
                class="btn-secondary text-lg px-8 py-4"
              >
                <span class="mr-2">🆓</span>
                Plan Gratuit
              </button>
            </div>
            
            <p class="text-gray-400 text-sm mt-4">
              🤖 IA incluse • 🔗 Partage public • 💳 Paiement sécurisé • 🛡️ Garantie 30 jours
            </p>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { stripeService } from '../lib/stripe'
import { getProductById } from '../stripe-config'
import { authService, supabase } from '../lib/supabase'
import { useAuth } from '../composables/useAuth'

const { openAuthModal } = useAuth()
const isAuthenticated = ref(false)
const loading = ref(false)
const userAccountInfo = ref<any>(null)

onMounted(async () => {
  const user = await authService.getCurrentUser()
  isAuthenticated.value = !!user
  
  if (isAuthenticated.value) {
    await loadUserAccountInfo()
  }
  
  // Auto-scroll to pricing section if coming from a link
  setTimeout(() => {
    const pricingSection = document.getElementById('pricing-cards')
    if (pricingSection) {
      pricingSection.scrollIntoView({ 
        behavior: 'smooth',
        block: 'start'
      })
    }
  }, 500)
})

const loadUserAccountInfo = async () => {
  try {
    // Check if user has premium status by checking stripe_orders for completed payments
    const user = await authService.getCurrentUser()
    if (!user) return
    
    const { data: orders, error } = await supabase
      .from('stripe_orders')
      .select('*')
      .eq('status', 'completed')
      .limit(1)
    
    if (!error && orders && orders.length > 0) {
      userAccountInfo.value = {
        is_premium: true,
        premium_since: orders[0].created_at
      }
    } else {
      userAccountInfo.value = {
        is_premium: false,
        premium_since: null
      }
    }
  } catch (error) {
    console.warn('Error loading user account info:', error)
    // Fallback to free account
    userAccountInfo.value = {
      is_premium: false,
      premium_since: null
    }
  }
}

const handleFreeSignup = () => {
  if (!isAuthenticated.value) {
    openAuthModal()
  }
  // Si déjà connecté, l'utilisateur est déjà sur le plan gratuit
}

const handlePremiumPurchase = async () => {
  if (!isAuthenticated.value) {
    openAuthModal()
    return
  }
  
  // Vérifier si l'utilisateur est déjà premium
  if (userAccountInfo.value?.is_premium) {
    return
  }
  
  loading.value = true
  
  try {
    const product = getProductById('prod_SmebYlToZMGwI2')
    if (!product) {
      throw new Error('Product not found')
    }
    
    const { url } = await stripeService.createCheckoutSession({
      priceId: product.priceId,
      mode: product.mode,
      successUrl: `${window.location.origin}/success?session_id={CHECKOUT_SESSION_ID}`,
      cancelUrl: window.location.href
    })
    
    // Redirect to Stripe Checkout
    window.location.href = url
  } catch (err: any) {
    console.error('Error creating checkout session:', err)
    alert('Erreur lors de la redirection vers Stripe. Veuillez réessayer.')
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
/* Custom pulsing animation for discount badge */
@keyframes pulse-glow {
  0%, 100% {
    transform: scale(1);
    box-shadow: 0 0 0 0 rgba(239, 68, 68, 0.7);
  }
  50% {
    transform: scale(1.05);
    box-shadow: 0 0 0 10px rgba(239, 68, 68, 0);
  }
}

.animate-pulse-glow {
  animation: pulse-glow 2s infinite;
}

/* Enhanced golden border with glow effect */
.border-yellow-400 {
  border-color: #facc15;
  box-shadow: 0 0 20px rgba(250, 204, 21, 0.3);
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
</style>