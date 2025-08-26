export interface Product {
  id: string
  priceId: string
  name: string
  description: string
  mode: 'payment' | 'subscription'
  price: number
  currency: string
}

export const products: Product[] = [
  {
    id: 'prod_SmebYlToZMGwI2',
    priceId: 'price_1Rr5HoE8Jc63ARkXGRkGgZe4',
    name: 'FolioLink - Premium',
    description: 'Upgrade to FolioLink Premium the Portfolio Builder for Bachelor student!',
    mode: 'payment',
    price: 10.00,
    currency: 'EUR'
  }
]

export const getProductById = (id: string): Product | undefined => {
  return products.find(product => product.id === id)
}

export const getProductByPriceId = (priceId: string): Product | undefined => {
  return products.find(product => product.priceId === priceId)
}