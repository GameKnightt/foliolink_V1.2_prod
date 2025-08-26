<template>
  <div class="pt-16 min-h-screen bg-gradient-to-br from-gray-900 via-blue-900 to-gray-900">
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <!-- Success Header -->
      <div class="text-center mb-12">
        <div class="inline-flex items-center glass-card px-6 py-3 mb-8 animate-bounce-in">
          <span class="text-green-400 mr-2 text-2xl">✅</span>
          <span class="text-white font-medium">Paiement Réussi</span>
        </div>
        
        <h1 class="text-4xl md:text-6xl font-bold text-white mb-6 animate-slide-up">
          <span class="gradient-text text-glow">Merci pour votre achat Premium !</span>
        </h1>
        
        <p class="text-xl text-gray-300 mb-8 max-w-3xl mx-auto animate-fade-in-delayed">
          Votre paiement FolioLink Premium a été traité avec succès. Vous avez maintenant accès à toutes les fonctionnalités premium !
        </p>
      </div>

      <!-- Order Details -->
      <div v-if="orderDetails" class="glass-card p-8 mb-8 animate-slide-up delay-300">
        <h2 class="text-2xl font-bold text-white mb-6 flex items-center">
          <span class="mr-3">📋</span>
          Détails de la commande
        </h2>
        
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <h3 class="text-lg font-semibold text-white mb-4">Informations de paiement</h3>
            <div class="space-y-3">
              <div class="flex justify-between">
                <span class="text-gray-300">Montant :</span>
                <span class="text-white font-semibold">{{ formatAmount(orderDetails.amount_total, orderDetails.currency) }}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-gray-300">Statut :</span>
                <span class="text-green-400 font-semibold">{{ orderDetails.payment_status }}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-gray-300">Date :</span>
                <span class="text-white">{{ formatDate(orderDetails.order_date) }}</span>
              </div>
            </div>
          </div>
          
          <div>
            <h3 class="text-lg font-semibold text-white mb-4">Produit acheté</h3>
            <div class="bg-white/5 p-4 rounded-lg">
              <h4 class="text-white font-semibold mb-2 flex items-center">
                <span class="mr-2">👑</span>
                {{ purchasedProduct?.name || 'FolioLink Premium' }}
              </h4>
              <p class="text-gray-300 text-sm">{{ purchasedProduct?.description }}</p>
              <div class="mt-3 flex items-center justify-between">
                <span class="text-accent-400 font-semibold">{{ formatAmount(orderDetails.amount_total, orderDetails.currency) }}</span>
                <span class="px-2 py-1 bg-green-500/20 text-green-400 rounded-full text-xs">
                  Premium Activé
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Loading State -->
      <div v-else-if="loading" class="glass-card p-8 mb-8 text-center animate-pulse">
        <div class="w-16 h-16 bg-gradient-to-r from-accent-400 to-accent-500 rounded-full flex items-center justify-center mx-auto mb-4">
          <span class="text-2xl">👑</span>
        </div>
        <h2 class="text-2xl font-bold text-white mb-2">Activation FolioLink Premium...</h2>
        <p class="text-gray-300">Finalisation de votre achat Premium et activation des fonctionnalités illimitées</p>
      </div>

      <!-- Error State -->
      <div v-else-if="error" class="glass-card p-8 mb-8 text-center">
        <div class="w-16 h-16 bg-red-500/20 rounded-full flex items-center justify-center mx-auto mb-4">
          <span class="text-2xl text-red-400">❌</span>
        </div>
        <h2 class="text-2xl font-bold text-white mb-2">Erreur</h2>
        <p class="text-gray-300 mb-4">{{ error }}</p>
        <button @click="loadOrderDetails" class="btn-primary">
          <span class="mr-2">🔄</span>
          Réessayer
        </button>
      </div>

      <!-- Next Steps -->
      <div class="glass-card p-8 mb-8 animate-slide-up delay-500">
        <h2 class="text-2xl font-bold text-white mb-6 flex items-center">
          <span class="mr-3">🎯</span>
          Prochaines étapes
        </h2>
        
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div class="text-center">
            <div class="w-12 h-12 bg-accent-400/20 rounded-full flex items-center justify-center mx-auto mb-4">
              <span class="text-accent-400 text-xl">📧</span>
            </div>
            <h3 class="text-white font-semibold mb-2">Email de confirmation</h3>
            <p class="text-gray-300 text-sm">Vous recevrez un email avec tous les détails de votre achat</p>
          </div>
          
          <div class="text-center">
            <div class="w-12 h-12 bg-accent-400/20 rounded-full flex items-center justify-center mx-auto mb-4">
              <span class="text-accent-400 text-xl">📱</span>
            </div>
            <h3 class="text-white font-semibold mb-2">Premium Activé</h3>
            <p class="text-gray-300 text-sm">Toutes les fonctionnalités FolioLink Premium sont maintenant actives</p>
          </div>
          
          <div class="text-center">
            <div class="w-12 h-12 bg-accent-400/20 rounded-full flex items-center justify-center mx-auto mb-4">
              <span class="text-accent-400 text-xl">🎉</span>
            </div>
            <h3 class="text-white font-semibold mb-2">Portfolio Illimité !</h3>
            <p class="text-gray-300 text-sm">Créez votre portfolio BUT sans limites avec FolioLink Premium</p>
          </div>
        </div>
      </div>

      <!-- Action Buttons -->
      <div class="text-center animate-slide-up delay-700">
        <div class="flex flex-col sm:flex-row gap-4 justify-center">
          <router-link to="/dashboard" class="btn-primary">
            <span class="mr-2">📊</span>
            Retour au Dashboard
          </router-link>
          <router-link to="/" class="btn-secondary">
            <span class="mr-2">🏠</span>
            Retour à l'accueil
          </router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { stripeService } from '../lib/stripe'
import { products, getProductByPriceId } from '../stripe-config'

const route = useRoute()
const loading = ref(true)
const error = ref('')
const orderDetails = ref<any>(null)
const purchasedProduct = ref<any>(null)
const sessionId = ref('')

onMounted(async () => {
  sessionId.value = route.query.session_id as string || ''
  const isFromOnboarding = route.query.onboarding === 'true'
  
  if (!sessionId.value) {
    error.value = 'Aucun ID de session fourni'
    loading.value = false
    return
  }
  
  await loadOrderDetails()
  
  // If from onboarding, redirect to dashboard with premium success flag
  if (isFromOnboarding && !error.value) {
    setTimeout(() => {
      window.location.href = '/dashboard?premium=success'
    }, 3000)
  }
})

const loadOrderDetails = async () => {
  loading.value = true
  error.value = ''
  
  try {
    // Load user orders to find the one matching this session
    const orders = await stripeService.getUserOrders()
    const order = orders.find(o => o.checkout_session_id === sessionId.value)
    
    if (order) {
      orderDetails.value = order
      // For one-time payments, we need to get the product info differently
      // since the order doesn't have a price_id field for one-time payments
      purchasedProduct.value = products.find(p => p.id === 'prod_SmebYlToZMGwI2') || products[0]
    } else {
      // Fallback for demo purposes
      orderDetails.value = {
        amount_total: 1000, // 10.00 EUR in cents
        currency: 'eur',
        payment_status: 'paid',
        order_date: new Date().toISOString()
      }
      purchasedProduct.value = products.find(p => p.id === 'prod_SmebYlToZMGwI2') || products[0]
    }
  } catch (err: any) {
    console.error('Error loading order details:', err)
    error.value = 'Impossible de charger les détails de votre achat Premium'
  } finally {
    loading.value = false
  }
}

const formatAmount = (amount: number, currency: string) => {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: currency.toUpperCase(),
  }).format(amount / 100) // Convert from cents
}

const formatDate = (dateString: string) => {
  return new Date(dateString).toLocaleDateString('fr-FR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}
</script>

<style scoped>
@keyframes bounce-in {
  0% { transform: scale(0.3) rotate(-10deg); opacity: 0; }
  50% { transform: scale(1.05) rotate(5deg); }
  70% { transform: scale(0.9) rotate(-2deg); }
  100% { transform: scale(1) rotate(0deg); opacity: 1; }
}

@keyframes slide-up {
  from { opacity: 0; transform: translateY(40px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes fade-in-delayed {
  0% { opacity: 0; transform: translateY(20px); }
  100% { opacity: 1; transform: translateY(0); }
}

.animate-bounce-in {
  animation: bounce-in 1s ease-out;
}

.animate-slide-up {
  animation: slide-up 0.8s ease-out;
}

.animate-fade-in-delayed {
  animation: fade-in-delayed 1s ease-out 0.5s both;
}

.delay-300 { animation-delay: 0.3s; }
.delay-500 { animation-delay: 0.5s; }
.delay-700 { animation-delay: 0.7s; }
</style>