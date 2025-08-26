<template>
  <div v-if="subscription" class="glass-card p-4">
    <div class="flex items-center justify-between">
      <div class="flex items-center space-x-3">
        <div class="w-8 h-8 bg-gradient-to-r from-accent-400 to-accent-500 rounded-full flex items-center justify-center">
          <span class="text-gray-900 text-sm font-bold">💳</span>
        </div>
        <div>
          <p class="text-white font-medium text-sm">{{ getSubscriptionStatusText() }}</p>
          <p v-if="subscription.price_id" class="text-gray-300 text-xs">{{ getProductName() }}</p>
        </div>
      </div>
      
      <div v-if="subscription.subscription_status === 'active'" class="text-right">
        <p class="text-green-400 text-xs font-medium">Actif</p>
        <p v-if="subscription.current_period_end" class="text-gray-400 text-xs">
          Jusqu'au {{ formatDate(subscription.current_period_end) }}
        </p>
      </div>
      
      <div v-else-if="subscription.subscription_status === 'not_started'" class="text-right">
        <p class="text-gray-400 text-xs">Aucun abonnement</p>
      </div>
      
      <div v-else class="text-right">
        <p class="text-yellow-400 text-xs font-medium">{{ subscription.subscription_status }}</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { stripeService, type SubscriptionData } from '../lib/stripe'
import { getProductByPriceId } from '../stripe-config'

const subscription = ref<SubscriptionData | null>(null)
const loading = ref(true)

onMounted(async () => {
  try {
    subscription.value = await stripeService.getUserSubscription()
  } catch (error) {
    console.error('Error loading subscription:', error)
  } finally {
    loading.value = false
  }
})

const getSubscriptionStatusText = () => {
  if (!subscription.value) return 'Chargement...'
  
  switch (subscription.value.subscription_status) {
    case 'active':
      return 'Abonnement actif'
    case 'not_started':
      return 'Aucun abonnement'
    case 'canceled':
      return 'Abonnement annulé'
    case 'past_due':
      return 'Paiement en retard'
    case 'incomplete':
      return 'Paiement incomplet'
    case 'trialing':
      return 'Période d\'essai'
    default:
      return subscription.value.subscription_status || 'Statut inconnu'
  }
}

const getProductName = () => {
  if (!subscription.value?.price_id) return ''
  
  const product = getProductByPriceId(subscription.value.price_id)
  return product?.name || 'FolioLink Premium'
}

const formatDate = (timestamp: number) => {
  return new Date(timestamp * 1000).toLocaleDateString('fr-FR')
}
</script>