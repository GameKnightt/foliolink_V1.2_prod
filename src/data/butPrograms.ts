export interface ButProgram {
  id: string
  name: string
  fullName: string
  pdfUrl: string
  category: 'production' | 'services'
}

export const butPrograms: ButProgram[] = [
  // SECTEUR PRODUCTION
  {
    id: 'chimie',
    name: 'Chimie',
    fullName: 'Chimie',
    pdfUrl: 'https://cache.media.education.gouv.fr/file/SP4-MESRI-26-5-2022/12/2/spe617_annexe4_1426122.pdf',
    category: 'production'
  },
  {
    id: 'gb',
    name: 'GB',
    fullName: 'Génie Biologique',
    pdfUrl: 'https://cache.media.education.gouv.fr/file/SP4-MESRI-26-5-2022/12/4/spe617_annexe5_1426124.pdf',
    category: 'production'
  },
  {
    id: 'gcgp',
    name: 'GCGP',
    fullName: 'Génie Chimique - Génie des Procédés',
    pdfUrl: 'https://cache.media.education.gouv.fr/file/SP4-MESRI-26-5-2022/12/6/spe617_annexe6_1426126.pdf',
    category: 'production'
  },
  {
    id: 'gccd',
    name: 'GCCD',
    fullName: 'Génie Civil - Construction Durable',
    pdfUrl: 'https://cache.media.education.gouv.fr/file/SP4-MESRI-26-5-2022/12/8/spe617_annexe7_1426128.pdf',
    category: 'production'
  },
  {
    id: 'geii',
    name: 'GEII',
    fullName: 'Génie Électrique et Informatique Industrielle',
    pdfUrl: 'https://cache.media.education.gouv.fr/file/SP4-MESRI-26-5-2022/13/0/spe617_annexe8_1426130.pdf',
    category: 'production'
  },
  {
    id: 'gim',
    name: 'GIM',
    fullName: 'Génie Industriel et Maintenance',
    pdfUrl: 'https://cache.media.education.gouv.fr/file/SP4-MESRI-26-5-2022/13/2/spe617_annexe9_1426132.pdf',
    category: 'production'
  },
  {
    id: 'gmp',
    name: 'GMP',
    fullName: 'Génie Mécanique et Productique',
    pdfUrl: 'https://cache.media.education.gouv.fr/file/SP4-MESRI-26-5-2022/13/4/spe617_annexe10_1426134.pdf',
    category: 'production'
  },
  {
    id: 'hse',
    name: 'HSE',
    fullName: 'Hygiène, Sécurité, Environnement',
    pdfUrl: 'https://cache.media.education.gouv.fr/file/SP4-MESRI-26-5-2022/14/2/spe617_annexe13_1426142.pdf',
    category: 'production'
  },
  {
    id: 'mp',
    name: 'MP',
    fullName: 'Mesures Physiques',
    pdfUrl: 'https://cache.media.education.gouv.fr/file/SP4-MESRI-26-5-2022/15/0/spe617_annexe17_1426150.pdf',
    category: 'production'
  },
  {
    id: 'mt2e',
    name: 'MT2E',
    fullName: 'Métiers de la Transition et de l\'Efficacité Énergétiques',
    pdfUrl: 'https://cache.media.education.gouv.fr/file/SP4-MESRI-26-5-2022/15/2/spe617_annexe18_1426152.pdf',
    category: 'production'
  },
  {
    id: 'sgm',
    name: 'SGM',
    fullName: 'Science et Génie des Matériaux',
    pdfUrl: 'https://cache.media.education.gouv.fr/file/SP4-MESRI-26-5-2022/16/2/spe617_annexe23_1426162.pdf',
    category: 'production'
  },

  // SECTEUR SERVICES
  {
    id: 'gaco',
    name: 'GACO',
    fullName: 'Gestion Administrative et Commerciale des Organisations',
    pdfUrl: 'https://cache.media.education.gouv.fr/file/SP4-MESRI-26-5-2022/13/8/spe617_annexe11_1426138.pdf',
    category: 'services'
  },
  {
    id: 'gea',
    name: 'GEA',
    fullName: 'Gestion des Entreprises et des Administrations',
    pdfUrl: 'https://cache.media.education.gouv.fr/file/SP4-MESRI-26-5-2022/14/0/spe617_annexe12_1426140.pdf',
    category: 'services'
  },
  {
    id: 'info-com',
    name: 'Info-Com',
    fullName: 'Information-Communication',
    pdfUrl: 'https://cache.media.education.gouv.fr/file/SP4-MESRI-26-5-2022/14/4/spe617_annexe14_1426144.pdf',
    category: 'services'
  },
  {
    id: 'informatique',
    name: 'Informatique',
    fullName: 'Informatique',
    pdfUrl: 'https://cache.media.education.gouv.fr/file/SP4-MESRI-26-5-2022/14/6/spe617_annexe15_1426146.pdf',
    category: 'services'
  },
  {
    id: 'mlt',
    name: 'MLT',
    fullName: 'Management de la Logistique et des Transports',
    pdfUrl: 'https://cache.media.education.gouv.fr/file/SP4-MESRI-26-5-2022/14/8/spe617_annexe16_1426148.pdf',
    category: 'services'
  },
  {
    id: 'mmi',
    name: 'MMI',
    fullName: 'Métiers du Multimédia et de l\'Internet',
    pdfUrl: 'https://cache.media.education.gouv.fr/file/SP4-MESRI-26-5-2022/15/4/spe617_annexe19_1426154.pdf',
    category: 'services'
  },
  {
    id: 'pec',
    name: 'PEC',
    fullName: 'Packaging, Emballage et Conditionnement',
    pdfUrl: 'https://cache.media.education.gouv.fr/file/SP4-MESRI-26-5-2022/15/6/spe617_annexe20_1426156.pdf',
    category: 'services'
  },
  {
    id: 'qlio',
    name: 'QLIO',
    fullName: 'Qualité, Logistique Industrielle et Organisation',
    pdfUrl: 'https://cache.media.education.gouv.fr/file/SP4-MESRI-26-5-2022/15/8/spe617_annexe21_1426158.pdf',
    category: 'services'
  },
  {
    id: 'rt',
    name: 'RT',
    fullName: 'Réseaux et Télécommunications',
    pdfUrl: 'https://cache.media.education.gouv.fr/file/SP4-MESRI-26-5-2022/16/0/spe617_annexe22_1426160.pdf',
    category: 'services'
  },
  {
    id: 'stid',
    name: 'STID',
    fullName: 'Statistique et Informatique Décisionnelle',
    pdfUrl: 'https://cache.media.education.gouv.fr/file/SP4-MESRI-26-5-2022/16/4/spe617_annexe24_1426164.pdf',
    category: 'services'
  },
  {
    id: 'tc',
    name: 'TC',
    fullName: 'Techniques de Commercialisation',
    pdfUrl: 'https://cache.media.education.gouv.fr/file/SP4-MESRI-26-5-2022/16/6/spe617_annexe25_1426166.pdf',
    category: 'services'
  }
]

export const butCategories = [
  {
    id: 'production',
    name: 'Production',
    icon: '⚙️',
    description: 'Secteur de la production industrielle'
  },
  {
    id: 'services',
    name: 'Services',
    icon: '💼',
    description: 'Secteur des services'
  }
]

export const getButByCategory = (category: string) => {
  return butPrograms.filter(but => but.category === category)
}

export const getButById = (id: string) => {
  return butPrograms.find(but => but.id === id)
}

export const searchBut = (query: string) => {
  const searchTerm = query.toLowerCase()
  return butPrograms.filter(but => 
    but.name.toLowerCase().includes(searchTerm) ||
    but.fullName.toLowerCase().includes(searchTerm)
  )
}