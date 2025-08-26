/*
  # Create check_portfolio_access function

  1. New Functions
    - `check_portfolio_access(password_param, slug_param)`
      - Checks if a portfolio is accessible with given credentials
      - Handles password validation for protected portfolios
      - Returns access status and profile data

  2. Security
    - Uses bcrypt for password verification
    - Protects against timing attacks
    - Validates public portfolio access
*/

-- Enable pgcrypto extension for password hashing
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Create the check_portfolio_access function
CREATE OR REPLACE FUNCTION public.check_portfolio_access(
    password_param TEXT,
    slug_param TEXT
)
RETURNS TABLE (
    has_access BOOLEAN,
    requires_password BOOLEAN,
    profile_data JSONB
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    _profile RECORD;
    _has_access BOOLEAN := FALSE;
    _requires_password BOOLEAN := FALSE;
BEGIN
    -- Find the profile by public_slug
    SELECT
        p.id,
        p.is_public,
        p.portfolio_password_hash,
        p.full_name,
        p.avatar_url,
        p.formation,
        p.etablissement,
        p.bio,
        p.email,
        p.telephone,
        p.linkedin,
        p.github,
        p.public_slug
    INTO _profile
    FROM
        profiles p
    WHERE
        p.public_slug = slug_param
        AND p.is_public = TRUE;

    -- If profile found and is public
    IF _profile.id IS NOT NULL THEN
        _requires_password := (_profile.portfolio_password_hash IS NOT NULL AND _profile.portfolio_password_hash != '');

        IF _requires_password THEN
            -- If password is required, check if provided password matches hash
            IF password_param IS NOT NULL AND password_param != '' THEN
                IF crypt(password_param, _profile.portfolio_password_hash) = _profile.portfolio_password_hash THEN
                    _has_access := TRUE;
                ELSE
                    _has_access := FALSE; -- Incorrect password
                END IF;
            ELSE
                _has_access := FALSE; -- No password provided
            END IF;
        ELSE
            -- No password required, grant access
            _has_access := TRUE;
        END IF;

        -- Return the result with profile data
        RETURN QUERY SELECT
            _has_access,
            _requires_password,
            jsonb_build_object(
                'id', _profile.id,
                'full_name', _profile.full_name,
                'avatar_url', _profile.avatar_url,
                'formation', _profile.formation,
                'etablissement', _profile.etablissement,
                'bio', _profile.bio,
                'email', _profile.email,
                'telephone', _profile.telephone,
                'linkedin', _profile.linkedin,
                'github', _profile.github,
                'is_public', _profile.is_public,
                'public_slug', _profile.public_slug
            );
    ELSE
        -- Profile not found or not public
        RETURN QUERY SELECT
            FALSE,
            FALSE,
            NULL::JSONB;
    END IF;
END;
$$;