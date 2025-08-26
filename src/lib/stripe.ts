import { supabase } from './supabase'

export interface CheckoutSessionRequest {
  priceId: string
  mode: 'payment' | 'subscription'
  successUrl?: string
  cancelUrl?: string
}

export interface CheckoutSessionResponse {
  sessionId: string
  url: string
}

export interface SubscriptionData {
  customer_id: string
  subscription_id: string | null
  subscription_status: string
  price_id: string | null
  current_period_start: number | null
  current_period_end: number | null
  cancel_at_period_end: boolean
  payment_method_brand: string | null
  payment_method_last4: string | null
}

export interface OrderData {
  customer_id: string
  order_id: number
  checkout_session_id: string
  payment_intent_id: string
  amount_subtotal: number
  amount_total: number
  currency: string
  payment_status: string
  order_status: string
  order_date: string
}

export const stripeService = {
  async createCheckoutSession(request: CheckoutSessionRequest): Promise<CheckoutSessionResponse> {
    const { data: { session }, error: sessionError } = await supabase.auth.getSession()
    
    if (sessionError || !session?.access_token) {
      throw new Error('User not authenticated')
    }

    const defaultSuccessUrl = `${window.location.origin}/success?session_id={CHECKOUT_SESSION_ID}`
    const defaultCancelUrl = `${window.location.origin}/`

    const response = await fetch(`${import.meta.env.VITE_SUPABASE_URL}/functions/v1/stripe-checkout`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${session.access_token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        price_id: request.priceId,
        mode: request.mode,
        success_url: request.successUrl || defaultSuccessUrl,
        cancel_url: request.cancelUrl || defaultCancelUrl,
      }),
    })

    if (!response.ok) {
      const errorData = await response.json()
      throw new Error(errorData.error || 'Failed to create checkout session')
    }

    return await response.json()
  },

  async getUserSubscription(): Promise<SubscriptionData | null> {
    const { data, error } = await supabase
      .from('stripe_user_subscriptions')
      .select('*')
      .maybeSingle()

    if (error) {
      console.error('Error fetching subscription:', error)
      return null
    }

    return data
  },

  async getUserOrders(): Promise<OrderData[]> {
    const { data, error } = await supabase
      .from('stripe_user_orders')
      .select('*')
      .order('order_date', { ascending: false })

    if (error) {
      console.error('Error fetching orders:', error)
      return []
    }

    return data || []
  },

  async redirectToCheckout(sessionId: string): Promise<void> {
    // For now, we'll redirect to the Stripe checkout URL
    // In a real implementation, you might want to use Stripe.js
    const checkoutUrl = `https://checkout.stripe.com/pay/${sessionId}`
    window.location.href = checkoutUrl
  }
}