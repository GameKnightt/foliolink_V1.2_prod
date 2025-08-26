<template>
  <div class="glass-card p-6 hover:scale-105 transition-all duration-300 group">
    <div class="text-center">
      <!-- Product Icon -->
      <div class="w-16 h-16 bg-gradient-to-r from-accent-400 to-accent-500 rounded-2xl flex items-center justify-center mx-auto mb-4 group-hover:scale-110 transition-transform duration-300">
        <span class="text-2xl">👑</span>
      </div>
      
      <!-- Product Name -->
      <h3 class="text-2xl font-bold text-white mb-2">FolioLink Premium</h3>
      
      <!-- Product Description -->
      <p class="text-gray-300 mb-6 leading-relaxed">{{ product.description }}</p>
      
      <!-- Price -->
      <div class="mb-6">
        <div class="text-4xl font-bold gradient-text mb-2">
          {{ formatPrice(product.price, product.currency) }}
        </div>
        <div class="text-gray-400 text-sm">
          {{ product.mode === 'subscription' ? 'par mois' : 'paiement unique' }}
        </div>
      </div>
      
      <!-- Purchase Button -->
      <button 
        @click="handlePurchase"
        :disabled="loading"
        class="w-full bg-gradient-to-r from-yellow-500 to-yellow-600 hover:from-yellow-600 hover:to-yellow-700 text-gray-900 font-semibold py-4 rounded-xl transition-all duration-300 hover:shadow-2xl hover:shadow-yellow-500/25 hover:scale-105 active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed"
      >
        <span v-if="loading" class="mr-2">⏳</span>
        <span v-else class="mr-2">👑</span>
        {{ loading ? 'Redirection vers Stripe...' : 'Acheter FolioLink Premium (10€)' }}
      </button>
      
      <!-- Error Message -->
      <div v-if="error" class="mt-4 p-3 bg-red-500/20 border border-red-500/30 rounded-lg">
        <p class="text-red-200 text-sm">{{ error }}</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { stripeService } from '../lib/stripe'
import type { Product } from '../stripe-config'

const props = defineProps<{
  product: Product
}>()

const loading = ref(false)
const error = ref('')

const handlePurchase = async () => {
  loading.value = true
  error.value = ''
  
  try {
    const { url } = await stripeService.createCheckoutSession({
      priceId: props.product.priceId,
      mode: props.product.mode,
      successUrl: `${window.location.origin}/success?session_id={CHECKOUT_SESSION_ID}`,
      cancelUrl: window.location.href
    })
    
    // Redirect to Stripe Checkout
    window.location.href = url
  } catch (err: any) {
    console.error('Error creating checkout session:', err)
    error.value = err.message || 'Erreur lors de la création de la session de paiement'
  } finally {
    loading.value = false
  }
}

const formatPrice = (price: number, currency: string) => {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: currency.toUpperCase(),
  }).format(price)
}
</script>