import * as XLSX from 'xlsx'
import type { Competence, Apprentissage, Projet } from '../data/portfolio'

export interface ExportData {
  profile: {
    full_name: string
    formation: string
    etablissement: string
    email: string
    bio?: string
  }
  competences: Competence[]
  apprentissages: Apprentissage[]
  projets: Projet[]
  categories?: Array<{
    id: string
    title: string
    description?: string
    competence_id: string
    level: number
  }>
}

export class ExcelExporter {
  private workbook: XLSX.WorkBook
  private data: ExportData

  constructor(data: ExportData) {
    this.workbook = XLSX.utils.book_new()
    this.data = data
  }

  /**
   * Récupère le nom de la catégorie à partir de son ID
   */
  private getCategoryName(categoryId?: string): string {
    if (!categoryId) return 'Non catégorisé'
    
    // Chercher dans les données de catégories si disponibles
    if (this.data.categories && Array.isArray(this.data.categories)) {
      const category = this.data.categories.find(cat => cat.id === categoryId)
      if (category) {
        console.log('Category found:', category.title, 'for ID:', categoryId)
        return category.title
      } else {
        console.log('Category not found for ID:', categoryId, 'Available categories:', this.data.categories.map(c => ({ id: c.id, title: c.title })))
      }
    }
    
    console.log('No categories data available or categoryId not found:', categoryId)
    return 'Non catégorisé'
  }

  /**
   * Génère et télécharge le fichier Excel complet
   */
  public async exportToExcel(): Promise<void> {
    try {
      // Créer toutes les feuilles
      this.createSummarySheet()
      this.createCompetenceSheets()
      this.createProjectsSheet()
      
      // Générer le nom du fichier avec la date
      const fileName = this.generateFileName()
      
      // Télécharger le fichier
      XLSX.writeFile(this.workbook, fileName)
      
      console.log('✅ Export Excel généré avec succès:', fileName)
    } catch (error) {
      console.error('❌ Erreur lors de l\'export Excel:', error)
      throw new Error('Impossible de générer le fichier Excel. Veuillez réessayer.')
    }
  }

  /**
   * Crée la feuille de sommaire avec vue d'ensemble
   */
  private createSummarySheet(): void {
    const ws = XLSX.utils.aoa_to_sheet([])
    
    // En-tête principal
    this.addMergedCell(ws, 'A1:E1', `Portfolio de ${this.data.profile.full_name}`, {
      font: { bold: true, size: 16 },
      fill: { fgColor: { rgb: '1F4E79' } },
      color: { rgb: 'FFFFFF' },
      alignment: { horizontal: 'center' }
    })
    
    // Informations personnelles
    this.addMergedCell(ws, 'A3:E3', 'Informations Personnelles', {
      font: { bold: true, size: 14 },
      fill: { fgColor: { rgb: '4472C4' } },
      color: { rgb: 'FFFFFF' }
    })
    
    const personalInfo = [
      ['Formation:', this.data.profile.formation],
      ['Établissement:', this.data.profile.etablissement],
      ['Email:', this.data.profile.email],
      ['Bio:', this.data.profile.bio || 'Non renseignée']
    ]
    
    personalInfo.forEach((row, index) => {
      XLSX.utils.sheet_add_aoa(ws, [row], { origin: `A${4 + index}` })
    })
    
    // Statistiques générales
    this.addMergedCell(ws, 'A9:E9', 'Statistiques du Portfolio', {
      font: { bold: true, size: 14 },
      fill: { fgColor: { rgb: '4472C4' } },
      color: { rgb: 'FFFFFF' }
    })
    
    const stats = this.calculateStats()
    const statsData = [
      ['Nombre de compétences:', stats.competences],
      ['Nombre d\'apprentissages:', stats.apprentissages],
      ['Nombre de projets:', stats.projets],
      ['Apprentissages bien maîtrisés:', stats.bienMaitrise],
      ['Taux de maîtrise:', `${stats.tauxMaitrise}%`]
    ]
    
    statsData.forEach((row, index) => {
      XLSX.utils.sheet_add_aoa(ws, [row], { origin: `A${10 + index}` })
    })
    
    // Index des compétences avec liens
    this.addMergedCell(ws, 'A16:E16', 'Index des Compétences', {
      font: { bold: true, size: 14 },
      fill: { fgColor: { rgb: '4472C4' } },
      color: { rgb: 'FFFFFF' }
    })
    
    // En-têtes de l'index
    const indexHeaders = ['Compétence', 'Niveaux', 'Apprentissages', 'Bien Maîtrisés', 'Feuille']
    XLSX.utils.sheet_add_aoa(ws, [indexHeaders], { origin: 'A17' })
    
    // Données de l'index
    this.data.competences.forEach((competence, index) => {
      const competenceApprentissages = this.data.apprentissages.filter(a => a.competenceId === competence.id)
      const bienMaitrises = competenceApprentissages.filter(a => a.evaluation === 'Bien Maîtrisé').length
      const sheetName = this.sanitizeSheetName(competence.title)
      
      const rowData = [
        competence.title,
        competence.levels,
        competenceApprentissages.length,
        bienMaitrises,
        sheetName
      ]
      
      XLSX.utils.sheet_add_aoa(ws, [rowData], { origin: `A${18 + index}` })
    })
    
    // Ajuster les largeurs de colonnes
    ws['!cols'] = [
      { width: 25 }, // Colonne A
      { width: 30 }, // Colonne B
      { width: 15 }, // Colonne C
      { width: 15 }, // Colonne D
      { width: 20 }  // Colonne E
    ]
    
    // Ajouter la feuille au classeur
    XLSX.utils.book_append_sheet(this.workbook, ws, 'Sommaire')
  }

  /**
   * Crée une feuille pour chaque compétence
   */
  private createCompetenceSheets(): void {
    this.data.competences.forEach(competence => {
      const ws = XLSX.utils.aoa_to_sheet([])
      const sheetName = this.sanitizeSheetName(competence.title)
      
      // En-tête de la compétence
      this.addMergedCell(ws, 'A1:F1', `${competence.icon} ${competence.title}`, {
        font: { bold: true, size: 16 },
        fill: { fgColor: { rgb: '1F4E79' } },
        color: { rgb: 'FFFFFF' },
        alignment: { horizontal: 'center' }
      })
      
      // Sous-titre et description
      this.addMergedCell(ws, 'A2:F2', competence.subtitle, {
        font: { bold: true, size: 12 },
        fill: { fgColor: { rgb: '4472C4' } },
        color: { rgb: 'FFFFFF' },
        alignment: { horizontal: 'center' }
      })
      
      this.addMergedCell(ws, 'A3:F3', competence.description, {
        font: { italic: true },
        alignment: { wrapText: true }
      })
      
      // Apprentissages par niveau
      let currentRow = 5
      
      for (let level = 1; level <= competence.levels; level++) {
        const levelApprentissages = this.data.apprentissages.filter(
          a => a.competenceId === competence.id && a.level === level
        )
        
        if (levelApprentissages.length > 0) {
          // Titre du niveau
          this.addMergedCell(ws, `A${currentRow}:F${currentRow}`, `Niveau ${level}`, {
            font: { bold: true, size: 14 },
            fill: { fgColor: { rgb: '70AD47' } },
            color: { rgb: 'FFFFFF' }
          })
          currentRow++
          
          // En-têtes des apprentissages
          const headers = ['Titre', 'Description', 'Catégorie', 'Évaluation', 'Argumentaire', 'Preuves', 'Date']
          XLSX.utils.sheet_add_aoa(ws, [headers], { origin: `A${currentRow}` })
          currentRow++
          
          // Données des apprentissages
          levelApprentissages.forEach(apprentissage => {
            const preuves = apprentissage.preuves.map(p => `${p.titre} (${p.type})`).join('; ')
            const categoryName = this.getCategoryName(apprentissage.categoryId)
            
            console.log('Processing apprentissage:', {
              title: apprentissage.title,
              categoryId: apprentissage.categoryId,
              resolvedCategoryName: categoryName
            })
            
            const rowData = [
              apprentissage.title,
              apprentissage.description,
              categoryName,
              apprentissage.evaluation,
              apprentissage.argumentaire,
              preuves || 'Aucune preuve',
              new Date(apprentissage.dateCreation).toLocaleDateString('fr-FR')
            ]
            
            XLSX.utils.sheet_add_aoa(ws, [rowData], { origin: `A${currentRow}` })
            currentRow++
          })
          
          currentRow++ // Espace entre les niveaux
        }
      }
      
      // Ajuster les largeurs de colonnes
      ws['!cols'] = [
        { width: 25 }, // Titre
        { width: 40 }, // Description
        { width: 20 }, // Catégorie
        { width: 20 }, // Évaluation
        { width: 50 }, // Argumentaire
        { width: 30 }, // Preuves
        { width: 12 }  // Date
      ]
      
      // Ajouter la feuille au classeur
      XLSX.utils.book_append_sheet(this.workbook, ws, sheetName)
    })
  }

  /**
   * Crée la feuille des projets
   */
  private createProjectsSheet(): void {
    const ws = XLSX.utils.aoa_to_sheet([])
    
    // En-tête principal
    this.addMergedCell(ws, 'A1:H1', '🚀 Mes Projets', {
      font: { bold: true, size: 16 },
      fill: { fgColor: { rgb: '1F4E79' } },
      color: { rgb: 'FFFFFF' },
      alignment: { horizontal: 'center' }
    })
    
    // En-têtes des colonnes
    const headers = [
      'Titre', 'Description', 'Niveau', 'Durée', 
      'Technologies', 'Fonctionnalités', 'Statut', 'Date de création'
    ]
    XLSX.utils.sheet_add_aoa(ws, [headers], { origin: 'A3' })
    
    // Données des projets
    this.data.projets.forEach((projet, index) => {
      const technologies = projet.technologies.join(', ')
      const fonctionnalites = projet.fonctionnalites.join('; ')
      
      const rowData = [
        `${projet.icone} ${projet.titre}`,
        projet.description,
        projet.niveau,
        projet.duree,
        technologies,
        fonctionnalites,
        projet.statut,
        new Date(projet.dateCreation).toLocaleDateString('fr-FR')
      ]
      
      XLSX.utils.sheet_add_aoa(ws, [rowData], { origin: `A${4 + index}` })
      
      // Alternance de couleurs pour les lignes
      if (index % 2 === 1) {
        for (let col = 0; col < 8; col++) {
          const cellRef = XLSX.utils.encode_cell({ r: 3 + index, c: col })
          if (!ws[cellRef]) ws[cellRef] = { t: 's', v: '' }
          ws[cellRef].s = {
            fill: { fgColor: { rgb: 'F2F2F2' } }
          }
        }
      }
    })
    
    // Ajuster les largeurs de colonnes
    ws['!cols'] = [
      { width: 25 }, // Titre
      { width: 50 }, // Description
      { width: 20 }, // Niveau
      { width: 15 }, // Durée
      { width: 30 }, // Technologies
      { width: 40 }, // Fonctionnalités
      { width: 15 }, // Statut
      { width: 12 }  // Date
    ]
    
    // Ajouter la feuille au classeur
    XLSX.utils.book_append_sheet(this.workbook, ws, 'Projets')
  }

  /**
   * Ajoute une cellule fusionnée avec style
   */
  private addMergedCell(
    ws: XLSX.WorkSheet, 
    range: string, 
    value: string, 
    style: any = {}
  ): void {
    const [start, end] = range.split(':')
    const startCell = XLSX.utils.decode_cell(start)
    
    // Ajouter la valeur à la cellule de départ
    XLSX.utils.sheet_add_aoa(ws, [[value]], { origin: start })
    
    // Ajouter le style si fourni
    if (Object.keys(style).length > 0) {
      const cellRef = start
      if (!ws[cellRef]) ws[cellRef] = { t: 's', v: value }
      ws[cellRef].s = style
    }
    
    // Ajouter la fusion de cellules
    if (!ws['!merges']) ws['!merges'] = []
    ws['!merges'].push(XLSX.utils.decode_range(range))
  }

  /**
   * Calcule les statistiques du portfolio
   */
  private calculateStats() {
    const bienMaitrise = this.data.apprentissages.filter(a => a.evaluation === 'Bien Maîtrisé').length
    const tauxMaitrise = this.data.apprentissages.length > 0 
      ? Math.round((bienMaitrise / this.data.apprentissages.length) * 100)
      : 0
    
    return {
      competences: this.data.competences.length,
      apprentissages: this.data.apprentissages.length,
      projets: this.data.projets.length,
      bienMaitrise,
      tauxMaitrise
    }
  }

  /**
   * Nettoie le nom de feuille pour Excel (max 31 caractères, caractères interdits)
   */
  private sanitizeSheetName(name: string): string {
    // Caractères interdits dans les noms de feuilles Excel
    const forbiddenChars = /[\\\/\*\?\[\]:]/g
    
    // Remplacer les caractères interdits et limiter à 31 caractères
    return name
      .replace(forbiddenChars, '_')
      .substring(0, 31)
      .trim()
  }

  /**
   * Génère le nom du fichier avec timestamp
   */
  private generateFileName(): string {
    const date = new Date()
    const timestamp = date.toISOString().split('T')[0] // YYYY-MM-DD
    const userName = this.data.profile.full_name.replace(/[^a-zA-Z0-9]/g, '_')
    
    return `Portfolio_${userName}_${timestamp}.xlsx`
  }

  async generateArgumentWithAI = async () => {
    if (!isPremium.value) {
      aiError.value = 'La génération d\'argumentaire par IA est réservée aux utilisateurs Premium. Achetez Premium pour débloquer cette fonctionnalité.'
      return
    }

    if (!userProfile.value) {
      aiError.value = 'Profil utilisateur non disponible'
      return
    }

    if (!form.value.title || !form.value.description || !form.value.competenceId) {
      aiError.value = 'Veuillez remplir le titre, la description et sélectionner une compétence avant de générer l\'argumentaire'
      return
    }

    // Check character limit before AI generation
    const remainingChars = 1500 - form.value.argumentaire.length
    if (remainingChars < 200) {
      aiError.value = 'Pas assez d\'espace restant pour générer un argumentaire (minimum 200 caractères requis)'
      return
    }
  }
}

/**
 * Fonction utilitaire pour exporter le portfolio
 */
export async function exportPortfolioToExcel(data: ExportData): Promise<void> {
  try {
    const exporter = new ExcelExporter(data)
    await exporter.exportToExcel()
  } catch (error) {
    console.error('Erreur lors de l\'export Excel:', error)
    throw error
  }
}

/**
 * Fonction pour préparer les données d'export depuis l'état de l'application
 */
export function prepareExportData(
  profile: any,
  competences: Competence[],
  apprentissages: Apprentissage[],
  projets: Projet[],
  categories?: any[]
): ExportData {
  return {
    profile: {
      full_name: profile?.full_name || 'Utilisateur',
      formation: profile?.formation || 'Formation non renseignée',
      etablissement: profile?.etablissement || 'Établissement non renseigné',
      email: profile?.email || 'Email non renseigné',
      bio: profile?.bio
    },
    competences,
    apprentissages,
    projets,
    categories: categories || []
  }
}