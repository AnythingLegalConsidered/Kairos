-- File: supabase/migrations/007_kanban_reading.sql
-- Purpose: Add 'reading' status for Kanban view (v0.5.0)
-- Dependencies: 001_initial_schema.sql (read_status_type enum)
-- Author: Claude Code
-- Date: 2024-12-31

-- ============================================
-- 1. ADD 'reading' TO read_status_type ENUM
-- ============================================

-- Note: ALTER TYPE ADD VALUE cannot be in a transaction block
-- This must be run separately or with COMMIT before
ALTER TYPE read_status_type ADD VALUE IF NOT EXISTS 'reading' AFTER 'unread';

-- ============================================
-- 2. INDEX FOR KANBAN PERFORMANCE
-- ============================================

-- Index for efficient Kanban column queries
CREATE INDEX IF NOT EXISTS idx_articles_kanban
ON public.articles(topic_id, read_status, relevance_score DESC);

-- ============================================
-- 3. FUNCTION: Move article to status
-- ============================================

CREATE OR REPLACE FUNCTION move_article_status(
    article_id UUID,
    new_status read_status_type
)
RETURNS BOOLEAN AS $$
DECLARE
    article_owner UUID;
BEGIN
    -- Get article's topic owner
    SELECT t.user_id INTO article_owner
    FROM public.articles a
    JOIN public.topics t ON a.topic_id = t.id
    WHERE a.id = article_id;

    -- Check ownership
    IF article_owner IS NULL OR article_owner != auth.uid() THEN
        RETURN FALSE;
    END IF;

    -- Update status
    UPDATE public.articles
    SET
        read_status = new_status,
        read_at = CASE
            WHEN new_status IN ('read', 'archived') THEN NOW()
            ELSE read_at
        END,
        updated_at = NOW()
    WHERE id = article_id;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 4. FUNCTION: Get articles by status (for Kanban)
-- ============================================

CREATE OR REPLACE FUNCTION get_kanban_articles(
    p_topic_id UUID DEFAULT NULL,
    p_limit INTEGER DEFAULT 50
)
RETURNS TABLE (
    id UUID,
    title TEXT,
    source_name VARCHAR(200),
    summary TEXT,
    url TEXT,
    relevance_score INTEGER,
    read_status read_status_type,
    bookmarked BOOLEAN,
    tags TEXT[],
    published_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id,
        a.title,
        a.source_name,
        a.summary,
        a.url,
        a.relevance_score,
        a.read_status,
        a.bookmarked,
        a.tags,
        a.published_at,
        a.created_at
    FROM public.articles a
    JOIN public.topics t ON a.topic_id = t.id
    WHERE t.user_id = auth.uid()
      AND (p_topic_id IS NULL OR a.topic_id = p_topic_id)
    ORDER BY
        CASE a.read_status
            WHEN 'unread' THEN 1
            WHEN 'reading' THEN 2
            WHEN 'read' THEN 3
            WHEN 'archived' THEN 4
        END,
        a.relevance_score DESC NULLS LAST,
        a.published_at DESC NULLS LAST
    LIMIT p_limit * 4; -- 4 columns
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 5. COMMENTS
-- ============================================

COMMENT ON FUNCTION move_article_status IS 'Moves an article to a new read status (for Kanban drag & drop)';
COMMENT ON FUNCTION get_kanban_articles IS 'Gets articles organized for Kanban view';
