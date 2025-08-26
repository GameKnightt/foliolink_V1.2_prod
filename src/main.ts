import { createApp } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'
import { createHead } from '@vueuse/head'
import './style.css'
import App from './App.vue'
import Home from './views/Home.vue'
import Portfolio from './views/Portfolio.vue'
import Projets from './views/Projets.vue'
import Dashboard from './views/Dashboard.vue'
import AuthCallback from './views/AuthCallback.vue'
import ResetPassword from './views/ResetPassword.vue'
import Success from './views/Success.vue'
import Pricing from './views/Pricing.vue'
import TermsOfService from './views/TermsOfService.vue'
import PrivacyPolicy from './views/PrivacyPolicy.vue'
import LegalNotice from './views/LegalNotice.vue'
import PublicPortfolio from './views/PublicPortfolio.vue'

const routes = [
  { path: '/', component: Home },
  { path: '/portfolio', component: Portfolio },
  { path: '/projets', component: Projets },
  { path: '/dashboard', component: Dashboard },
  { path: '/auth/callback', component: AuthCallback },
  { path: '/reset-password', component: ResetPassword },
  { path: '/success', component: Success },
  { path: '/pricing', component: Pricing },
  { path: '/terms-of-service', component: TermsOfService },
  { path: '/privacy-policy', component: PrivacyPolicy },
  { path: '/legal-notice', component: LegalNotice },
  // Public portfolio route - must be last to avoid conflicts
  { path: '/:slug', component: PublicPortfolio, props: true },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior(to, from, savedPosition) {
    // Si l'utilisateur utilise le bouton retour/avancer du navigateur
    if (savedPosition) {
      return savedPosition
    }
    // Sinon, toujours aller en haut de la page
    return { top: 0, behavior: 'smooth' }
  }
})

const app = createApp(App)
const head = createHead()

app.use(router)
app.use(head)
app.mount('#app')