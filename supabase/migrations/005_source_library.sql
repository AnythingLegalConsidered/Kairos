-- =============================================================================
-- KAIROS - Source Library (v0.3.0)
-- =============================================================================
-- Migration: 005_source_library.sql
-- Description: Add favorites and source suggestions functionality
-- =============================================================================

-- =============================================================================
-- TABLE: user_favorite_sources
-- =============================================================================
-- Allows users to mark sources as favorites for quick access

CREATE TABLE IF NOT EXISTS public.user_favorite_sources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    source_id UUID NOT NULL REFERENCES public.rss_sources(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Each user can only favorite a source once
    CONSTRAINT unique_user_source_favorite UNIQUE (user_id, source_id)
);

-- Indexes
CREATE INDEX idx_user_favorite_sources_user_id ON public.user_favorite_sources(user_id);
CREATE INDEX idx_user_favorite_sources_source_id ON public.user_favorite_sources(source_id);

-- RLS Policies
ALTER TABLE public.user_favorite_sources ENABLE ROW LEVEL SECURITY;

-- Users can only see their own favorites
CREATE POLICY "Users can view own favorites"
    ON public.user_favorite_sources
    FOR SELECT
    USING (auth.uid() = user_id);

-- Users can add their own favorites
CREATE POLICY "Users can add own favorites"
    ON public.user_favorite_sources
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Users can remove their own favorites
CREATE POLICY "Users can delete own favorites"
    ON public.user_favorite_sources
    FOR DELETE
    USING (auth.uid() = user_id);

-- =============================================================================
-- FUNCTION: suggest_sources
-- =============================================================================
-- Suggests sources based on keywords matching name, description, or category

CREATE OR REPLACE FUNCTION suggest_sources(
    keywords TEXT[],
    lang VARCHAR(5) DEFAULT NULL,
    max_results INTEGER DEFAULT 10
) RETURNS SETOF rss_sources AS $$
BEGIN
    RETURN QUERY
    SELECT rs.*
    FROM rss_sources rs
    WHERE rs.active = true
      AND (lang IS NULL OR rs.language = lang)
      AND (
          -- Match against name
          rs.name ILIKE ANY(SELECT '%' || k || '%' FROM unnest(keywords) k)
          -- Match against description
          OR rs.description ILIKE ANY(SELECT '%' || k || '%' FROM unnest(keywords) k)
          -- Match against category
          OR rs.category::text ILIKE ANY(SELECT '%' || k || '%' FROM unnest(keywords) k)
      )
    ORDER BY
        -- Prioritize exact category matches
        CASE WHEN rs.category::text ILIKE ANY(SELECT '%' || k || '%' FROM unnest(keywords) k)
             THEN 0 ELSE 1 END,
        rs.name
    LIMIT max_results;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- FUNCTION: get_sources_by_category
-- =============================================================================
-- Returns all sources grouped by category with counts

CREATE OR REPLACE FUNCTION get_sources_by_category(
    lang VARCHAR(5) DEFAULT NULL
) RETURNS TABLE (
    category source_category,
    source_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT rs.category, COUNT(*) as source_count
    FROM rss_sources rs
    WHERE rs.active = true
      AND (lang IS NULL OR rs.language = lang)
    GROUP BY rs.category
    ORDER BY source_count DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- FUNCTION: get_user_favorite_sources
-- =============================================================================
-- Returns user's favorite sources with full source details

CREATE OR REPLACE FUNCTION get_user_favorite_sources(p_user_id UUID)
RETURNS SETOF rss_sources AS $$
BEGIN
    RETURN QUERY
    SELECT rs.*
    FROM rss_sources rs
    INNER JOIN user_favorite_sources ufs ON rs.id = ufs.source_id
    WHERE ufs.user_id = p_user_id
      AND rs.active = true
    ORDER BY rs.name;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- FUNCTION: toggle_favorite_source
-- =============================================================================
-- Toggles a source as favorite (add if not exists, remove if exists)

CREATE OR REPLACE FUNCTION toggle_favorite_source(
    p_user_id UUID,
    p_source_id UUID
) RETURNS BOOLEAN AS $$
DECLARE
    v_exists BOOLEAN;
BEGIN
    -- Check if favorite exists
    SELECT EXISTS(
        SELECT 1 FROM user_favorite_sources
        WHERE user_id = p_user_id AND source_id = p_source_id
    ) INTO v_exists;

    IF v_exists THEN
        -- Remove favorite
        DELETE FROM user_favorite_sources
        WHERE user_id = p_user_id AND source_id = p_source_id;
        RETURN FALSE; -- Returns false = not favorited anymore
    ELSE
        -- Add favorite
        INSERT INTO user_favorite_sources (user_id, source_id)
        VALUES (p_user_id, p_source_id);
        RETURN TRUE; -- Returns true = now favorited
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- COMMENTS
-- =============================================================================

COMMENT ON TABLE public.user_favorite_sources IS 'User favorite RSS sources for quick access';
COMMENT ON FUNCTION suggest_sources IS 'Suggests RSS sources based on keyword matching';
COMMENT ON FUNCTION get_sources_by_category IS 'Returns source counts by category';
COMMENT ON FUNCTION get_user_favorite_sources IS 'Returns user favorite sources with details';
COMMENT ON FUNCTION toggle_favorite_source IS 'Toggles source favorite status for a user';
