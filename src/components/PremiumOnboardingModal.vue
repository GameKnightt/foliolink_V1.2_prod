<template>
  <div class="fixed inset-0 z-[100] overflow-y-auto">
    <div class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
      <!-- Background overlay -->
      <div class="fixed inset-0 bg-black/80 backdrop-blur-sm transition-opacity"></div>

      <!-- Modal -->
      <div class="inline-block align-bottom glass-card text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-2xl sm:w-full animate-modal-enter">
        <!-- Header with animated gradient -->
        <div class="bg-gradient-to-r from-purple-600 via-blue-600 to-purple-600 bg-[length:200%_100%] animate-gradient px-8 py-6 text-center">
          <div class="animate-bounce-in">
            <div class="text-6xl mb-4">🎉</div>
            <h2 class="text-3xl font-bold text-white mb-2">Bienvenue sur FolioLink !</h2>
            <p class="text-purple-100">Choisissez votre formule pour commencer</p>
          </div>
        </div>

        <!-- Content -->
        <div class="px-8 py-8 bg-white dark:bg-gray-800">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Free Plan -->
            <div class="border-2 border-gray-200 dark:border-gray-600 rounded-xl p-6 hover:border-blue-400 transition-all duration-300 cursor-pointer group" @click="chooseFree">
              <div class="text-center">
                <div class="w-16 h-16 bg-blue-100 dark:bg-blue-900 rounded-full flex items-center justify-center mx-auto mb-4 group-hover:scale-110 transition-transform">
                  <span class="text-3xl">🆓</span>
                </div>
                <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-2">Gratuit</h3>
                <div class="text-3xl font-bold text-blue-600 mb-2">0€</div>
                <p class="text-gray-600 dark:text-gray-300 text-sm mb-4">Pour toujours</p>
                
                <ul class="text-left space-y-2 text-sm text-gray-600 dark:text-gray-300">
                  <li class="flex items-center"><span class="text-green-500 mr-2">✓</span>Portfolio BUT complet</li>
                  <li class="flex items-center"><span class="text-green-500 mr-2">✓</span>Jusqu'à 3 compétences</li>
                  <li class="flex items-center"><span class="text-green-500 mr-2">✓</span>Jusqu'à 5 apprentissages critiques</li>
                  <li class="flex items-center"><span class="text-green-500 mr-2">✓</span>Jusqu'à 3 projets</li>
                </ul>
                
                <button class="w-full mt-6 bg-blue-600 hover:bg-blue-700 text-white font-semibold py-3 rounded-lg transition-colors">
                  Commencer gratuitement
                </button>
              </div>
            </div>

            <!-- Premium Plan -->
            <div class="border-2 border-yellow-400 rounded-xl p-6 hover:border-yellow-500 transition-all duration-300 cursor-pointer group relative overflow-hidden shadow-lg shadow-yellow-400/20" @click="choosePremium">
              <!-- Animated background -->
              <div class="absolute inset-0 bg-gradient-to-r from-yellow-500/10 to-orange-500/10 animate-pulse"></div>
              
              <!-- Discount badge -->
              <div class="absolute -top-2 -right-2 bg-red-500 text-white px-3 py-1 rounded-full text-xs font-bold animate-pulse-glow">
                -50%
              </div>
              
              <div class="relative z-10 text-center">
                <div class="w-16 h-16 bg-gradient-to-r from-yellow-400 to-orange-400 rounded-full flex items-center justify-center mx-auto mb-4 group-hover:scale-110 transition-transform">
                  <span class="text-3xl">👑</span>
                </div>
                <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-2">FolioLink Premium</h3>
                <div class="mb-2">
                  <div class="flex items-center justify-center space-x-2">
                    <div class="text-3xl font-bold text-yellow-600">10€</div>
                    <div class="text-xl text-gray-400 line-through">20€</div>
                  </div>
                </div>
                <p class="text-gray-600 dark:text-gray-300 text-sm mb-4">Paiement unique - À vie</p>
                
                <ul class="text-left space-y-2 text-sm text-gray-600 dark:text-gray-300">
                  <li class="flex items-center"><span class="text-yellow-500 mr-2">✓</span>Tout du plan Gratuit +</li>
                  <li class="flex items-center"><span class="text-yellow-500 mr-2">✓</span>Compétences illimitées</li>
                  <li class="flex items-center"><span class="text-yellow-500 mr-2">✓</span>Apprentissages illimités</li>
                  <li class="flex items-center"><span class="text-yellow-500 mr-2">✓</span>Projets illimités</li>
                  <li class="flex items-center"><span class="text-yellow-500 mr-2">✓</span>Export Excel professionnel</li>
                </ul>
                
                <button 
                  :disabled="loading"
                  class="w-full mt-6 bg-gradient-to-r from-yellow-500 to-orange-500 hover:from-yellow-600 hover:to-orange-600 text-white font-semibold py-3 rounded-lg transition-all duration-300 disabled:opacity-50 transform hover:scale-105"
                >
                  <span v-if="loading">⏳ Redirection vers Stripe...</span>
                  <span v-else>🚀 Acheter FolioLink Premium (10€)</span>
                </button>
              </div>
            </div>
          </div>
          
          <!-- Skip option -->
          <div class="text-center mt-8">
            <button 
              @click="skipOnboarding"
              class="text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200 text-sm transition-colors"
            >
              Je choisirai plus tard
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { stripeService } from '../lib/stripe'
import { getProductById } from '../stripe-config'

const emit = defineEmits(['close', 'free-selected', 'premium-purchased'])

const loading = ref(false)

const chooseFree = () => {
  emit('free-selected')
  emit('close')
}

const choosePremium = async () => {
  loading.value = true
  
  try {
    const product = getProductById('prod_SmebYlToZMGwI2')
    if (!product) {
      throw new Error('Product not found')
    }
    
    const { url } = await stripeService.createCheckoutSession({
      priceId: product.priceId,
      mode: product.mode,
      successUrl: `${window.location.origin}/success?session_id={CHECKOUT_SESSION_ID}&onboarding=true`,
      cancelUrl: `${window.location.origin}/dashboard`
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

const skipOnboarding = () => {
  emit('close')
}
</script>

<style scoped>
/* Discount badge pulsing animation */
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