import 'jsr:@supabase/functions-js/edge-runtime.d.ts'
import { createClient } from 'npm:@supabase/supabase-js@2.49.1'

// =============================================================================
// CONFIGURATION & INITIALIZATION
// =============================================================================

const supabase = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
)

const OPENAI_API_KEY = Deno.env.get('OPENAI_API_KEY')
const OPENAI_API_URL = 'https://api.openai.com/v1/chat/completions'

// CORS headers for all responses
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
}

// =============================================================================
// TYPE DEFINITIONS
// =============================================================================

interface ApprentissageData {
  title: string
  description: string
  evaluation: 'Bien Maîtrisé' | 'Partiellement Maîtrisé' | 'Pas Maîtrisé'
  competenceId: string
  level: number
}

interface CompetenceData {
  title: string
  subtitle: string
  description: string
}

interface ProfileData {
  full_name: string
  formation: string
  etablissement?: string
  annee_etudes: string
  bio?: string
}

interface ArgumentRequest {
  apprentissage: ApprentissageData
  competence: CompetenceData
  profile: ProfileData
}

interface OpenAIResponse {
  choices: Array<{
    message: {
      content: string
    }
  }>
}

// =============================================================================
// UTILITY FUNCTIONS
// =============================================================================

/**
 * Creates a standardized response with CORS headers
 */
function createResponse(data: any, status: number = 200): Response {
  return new Response(
    JSON.stringify(data),
    {
      status,
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json',
      },
    }
  )
}

/**
 * Sanitizes and validates input data to prevent injection attacks
 */
function sanitizeInput(input: string, maxLength: number = 1000): string {
  if (!input || typeof input !== 'string') {
    return ''
  }
  
  return input
    .trim()
    .replace(/[<>]/g, '') // Remove potential HTML tags
    .replace(/[^\w\s\-\.\,\'\"\(\)\[\]àâäéèêëïîôöùûüÿç]/g, '') // Keep only safe characters + French accents
    .substring(0, maxLength)
}

/**
 * Validates the request payload structure and content
 */
function validateRequestData(data: any): { isValid: boolean; error?: string; sanitized?: ArgumentRequest } {
  try {
    // Check required top-level properties
    if (!data.apprentissage || !data.competence || !data.profile) {
      return { isValid: false, error: 'Missing required data sections' }
    }

    // Validate and sanitize apprentissage data
    const apprentissage = data.apprentissage
    if (!apprentissage.title || !apprentissage.description || !apprentissage.evaluation) {
      return { isValid: false, error: 'Missing required apprentissage fields' }
    }

    const validEvaluations = ['Bien Maîtrisé', 'Partiellement Maîtrisé', 'Pas Maîtrisé']
    if (!validEvaluations.includes(apprentissage.evaluation)) {
      return { isValid: false, error: 'Invalid evaluation value' }
    }

    // Validate and sanitize competence data
    const competence = data.competence
    if (!competence.title || !competence.subtitle || !competence.description) {
      return { isValid: false, error: 'Missing required competence fields' }
    }

    // Validate and sanitize profile data
    const profile = data.profile
    if (!profile.full_name || !profile.formation || !profile.annee_etudes) {
      return { isValid: false, error: 'Missing required profile fields' }
    }

    // Create sanitized request object
    const sanitizedRequest: ArgumentRequest = {
      apprentissage: {
        title: sanitizeInput(apprentissage.title, 100),
        description: sanitizeInput(apprentissage.description, 1000),
        evaluation: apprentissage.evaluation,
        competenceId: sanitizeInput(apprentissage.competenceId, 50),
        level: Math.max(1, Math.min(5, parseInt(apprentissage.level) || 1))
      },
      competence: {
        title: sanitizeInput(competence.title, 100),
        subtitle: sanitizeInput(competence.subtitle, 200),
        description: sanitizeInput(competence.description, 500)
      },
      profile: {
        full_name: sanitizeInput(profile.full_name, 100),
        formation: sanitizeInput(profile.formation, 100),
        etablissement: sanitizeInput(profile.etablissement || '', 100),
        annee_etudes: sanitizeInput(profile.annee_etudes, 10),
        bio: sanitizeInput(profile.bio || '', 500)
      }
    }

    return { isValid: true, sanitized: sanitizedRequest }
  } catch (error) {
    console.error('Validation error:', error)
    return { isValid: false, error: 'Invalid request format' }
  }
}

/**
 * Builds the AI prompt for argumentative text generation
 */
function buildArgumentPrompt(data: ArgumentRequest): string {
  const { apprentissage, competence, profile } = data

  return `Tu es un assistant pédagogique spécialisé dans l'accompagnement des étudiants en BUT (Bachelor Universitaire de Technologie). Tu aides les étudiants à rédiger des argumentaires convaincants pour leurs apprentissages critiques.

CONTEXTE ÉTUDIANT :
- Nom : ${profile.full_name}
- Formation : ${profile.formation}
- Année d'études : ${profile.annee_etudes}
- Établissement : ${profile.etablissement || 'Non renseigné'}
- Profil : ${profile.bio || 'Non renseigné'}

COMPÉTENCE BUT :
- Titre : ${competence.title}
- Sous-titre : ${competence.subtitle}
- Description : ${competence.description}

APPRENTISSAGE CRITIQUE À ARGUMENTER :
- Titre : ${apprentissage.title}
- Description : ${apprentissage.description}
- Niveau : ${apprentissage.level}
- Évaluation de maîtrise : ${apprentissage.evaluation}

MISSION :
Rédige un argumentaire convaincant et professionnel pour justifier l'évaluation "${apprentissage.evaluation}" de cet apprentissage critique.

L'argumentaire doit :
1. Être adapté au niveau BUT et au contexte de formation de l'étudiant
2. Justifier concrètement pourquoi l'évaluation "${apprentissage.evaluation}" est appropriée
3. Mentionner des exemples concrets liés à la formation ${profile.formation}
4. Utiliser un vocabulaire technique approprié au domaine
5. Être structuré et professionnel pour une présentation devant un jury
6. Faire environ 150-250 mots MAXIMUM (très important pour respecter les limites de l'interface)

L'argumentaire doit convaincre un jury académique que l'étudiant maîtrise effectivement cette compétence au niveau indiqué.

Réponds uniquement avec l'argumentaire, sans introduction ni conclusion supplémentaire.`
}

/**
 * Checks and updates rate limiting for the user
 */
async function checkRateLimit(userId: string): Promise<{ allowed: boolean; error?: string }> {
  try {
    const oneHourAgo = new Date(Date.now() - 3600000).toISOString()
    
    const { data: rateLimitData } = await supabase
      .from('user_rate_limits')
      .select('request_count, last_request')
      .eq('user_id', userId)
      .eq('endpoint', 'generate-argument')
      .gte('last_request', oneHourAgo)
      .maybeSingle()

    const currentCount = rateLimitData?.request_count || 0
    const maxRequests = 10 // 10 requests per hour

    if (currentCount >= maxRequests) {
      return { 
        allowed: false, 
        error: `Rate limit exceeded. You can make ${maxRequests} requests per hour. Please try again later.` 
      }
    }

    // Update rate limit counter
    await supabase
      .from('user_rate_limits')
      .upsert({
        user_id: userId,
        endpoint: 'generate-argument',
        request_count: currentCount + 1,
        last_request: new Date().toISOString()
      }, {
        onConflict: 'user_id,endpoint'
      })

    return { allowed: true }
  } catch (error) {
    console.error('Rate limit check error:', error)
    return { allowed: true } // Allow request if rate limit check fails
  }
}

/**
 * Calls OpenAI API to generate argumentative text
 */
async function generateWithOpenAI(prompt: string): Promise<{ success: boolean; content?: string; error?: string }> {
  try {
    console.log('Calling OpenAI API with gpt-4o-mini model...')
    
    const response = await fetch(OPENAI_API_URL, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${OPENAI_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-4o-mini',
        messages: [
          {
            role: 'user',
            content: prompt
          }
        ],
        max_tokens: 500,
        temperature: 0.7
      }),
    })

    if (!response.ok) {
      const errorData = await response.json()
      console.error('OpenAI API error response:', errorData)
      
      // Handle specific OpenAI errors
      if (response.status === 429) {
        return { success: false, error: 'AI service is currently busy. Please try again in a moment.' }
      } else if (response.status === 401) {
        return { success: false, error: 'AI service authentication failed.' }
      } else {
        return { success: false, error: 'AI service temporarily unavailable.' }
      }
    }

    const data: OpenAIResponse = await response.json()
    const generatedContent = data.choices[0]?.message?.content

    if (!generatedContent) {
      console.error('No content generated by OpenAI')
      return { success: false, error: 'Unable to generate content. Please try again.' }
    }

    console.log('OpenAI API call successful, content generated')
    return { success: true, content: generatedContent.trim() }

  } catch (error) {
    console.error('OpenAI API call failed:', error)
    return { success: false, error: 'AI service connection failed. Please try again.' }
  }
}

// =============================================================================
// MAIN EDGE FUNCTION HANDLER
// =============================================================================

Deno.serve(async (req: Request) => {
  console.log(`[${new Date().toISOString()}] ${req.method} request received`)

  try {
    // Handle CORS preflight
    if (req.method === 'OPTIONS') {
      console.log('Handling CORS preflight request')
      return new Response(null, {
        status: 200,
        headers: corsHeaders,
      })
    }

    // Only allow POST requests
    if (req.method !== 'POST') {
      console.log(`Method ${req.method} not allowed`)
      return createResponse({ error: 'Method not allowed' }, 405)
    }

    // Validate environment configuration
    if (!OPENAI_API_KEY) {
      console.error('CRITICAL: OpenAI API key not configured')
      return createResponse({ error: 'AI service configuration error' }, 500)
    }

    if (!OPENAI_API_KEY.startsWith('sk-')) {
      console.error('CRITICAL: Invalid OpenAI API key format')
      return createResponse({ error: 'AI service configuration error' }, 500)
    }

    // Authenticate user
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      console.log('Missing authorization header')
      return createResponse({ error: 'Authorization header required' }, 401)
    }

    const token = authHeader.replace('Bearer ', '')
    const { data: { user }, error: authError } = await supabase.auth.getUser(token)

    if (authError || !user) {
      console.log('Authentication failed:', authError?.message)
      return createResponse({ error: 'Invalid authentication' }, 401)
    }

    console.log(`Authenticated user: ${user.id}`)

    // Check rate limiting
    const rateLimitResult = await checkRateLimit(user.id)
    if (!rateLimitResult.allowed) {
      console.log(`Rate limit exceeded for user: ${user.id}`)
      return createResponse({ error: rateLimitResult.error }, 429)
    }

    // Parse and validate request body
    let requestData: ArgumentRequest
    try {
      const rawData = await req.json()
      const validation = validateRequestData(rawData)
      
      if (!validation.isValid) {
        console.log('Request validation failed:', validation.error)
        return createResponse({ error: validation.error }, 400)
      }
      
      requestData = validation.sanitized!
      console.log('Request data validated and sanitized successfully')
    } catch (parseError) {
      console.error('JSON parsing error:', parseError)
      return createResponse({ error: 'Invalid JSON format' }, 400)
    }

    // Generate AI prompt
    const prompt = buildArgumentPrompt(requestData)
    console.log('AI prompt generated, length:', prompt.length)

    // Call OpenAI API
    const aiResult = await generateWithOpenAI(prompt)
    
    if (!aiResult.success) {
      console.error('AI generation failed:', aiResult.error)
      return createResponse({ error: aiResult.error }, 500)
    }

    // Sanitize AI response
    const sanitizedArgument = sanitizeInput(aiResult.content!, 1500)
    
    if (!sanitizedArgument) {
      console.error('AI generated empty content')
      throw new Error('Unable to generate meaningful content. Please try again.')
    }

    console.log(`Successfully generated argument (${sanitizedArgument.length} characters)`)

    // Log successful generation for monitoring
    await supabase
      .from('security_logs')
      .insert({
        user_id: user.id,
        event_type: 'ai_argument_generated',
        event_data: {
          competence_id: requestData.apprentissage.competenceId,
          level: requestData.apprentissage.level,
          evaluation: requestData.apprentissage.evaluation,
          content_length: sanitizedArgument.length
        },
        ip_address: req.headers.get('x-forwarded-for') || 'unknown',
        user_agent: req.headers.get('user-agent') || 'unknown'
      })

    // Return successful response
    return createResponse({
      argument: sanitizedArgument,
      success: true,
      metadata: {
        length: sanitizedArgument.length,
        model: 'gpt-4o-mini',
        timestamp: new Date().toISOString()
      }
    })

  } catch (error: any) {
    console.error('Unexpected error in Edge Function:', error)
    
    // Log critical errors for monitoring
    try {
      await supabase
        .from('security_logs')
        .insert({
          event_type: 'edge_function_error',
          event_data: {
            function_name: 'generate-argument',
            error_message: error.message,
            error_stack: error.stack
          },
          ip_address: req.headers.get('x-forwarded-for') || 'unknown'
        })
    } catch (logError) {
      console.warn('Failed to log error:', logError)
    }

    return createResponse({ 
      error: 'Internal server error',
      timestamp: new Date().toISOString()
    }, 500)
  }
})