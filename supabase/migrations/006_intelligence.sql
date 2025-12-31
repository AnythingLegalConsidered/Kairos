-- =============================================================================
-- KAIROS - Intelligence Avancee (v0.4.0) - Fixed
-- =============================================================================

-- Drop existing objects if they exist
DROP TRIGGER IF EXISTS update_tag_preferences_on_read ON public.articles;
DROP FUNCTION IF EXISTS public.trigger_update_tag_preferences();
DROP FUNCTION IF EXISTS public.get_articles_with_trends(UUID, INTEGER, INTEGER);
DROP FUNCTION IF EXISTS public.get_personalized_score(INTEGER, TEXT[]);
DROP FUNCTION IF EXISTS public.get_user_top_tags(INTEGER);
DROP FUNCTION IF EXISTS public.update_tag_preferences(UUID);
DROP FUNCTION IF EXISTS public.get_similar_articles(UUID, INTEGER);
DROP FUNCTION IF EXISTS public.get_trending_tags(INTEGER, INTEGER);
DROP TABLE IF EXISTS public.user_tag_preferences;

-- =============================================================================
-- TABLE: user_tag_preferences
-- =============================================================================

CREATE TABLE public.user_tag_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    tag TEXT NOT NULL,
    read_count INTEGER DEFAULT 1,
    last_read_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT user_tag_preferences_unique UNIQUE(user_id, tag)
);

-- Indexes
CREATE INDEX idx_user_tag_preferences_user_id ON public.user_tag_preferences(user_id);
CREATE INDEX idx_user_tag_preferences_tag ON public.user_tag_preferences(tag);

-- RLS
ALTER TABLE public.user_tag_preferences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own tag preferences"
    ON public.user_tag_preferences FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own tag preferences"
    ON public.user_tag_preferences FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own tag preferences"
    ON public.user_tag_preferences FOR UPDATE
    USING (auth.uid() = user_id);

-- =============================================================================
-- ALTER TABLE: articles - Add highlights column
-- =============================================================================

ALTER TABLE public.articles
ADD COLUMN IF NOT EXISTS highlights JSONB DEFAULT '[]';

-- =============================================================================
-- FUNCTION: get_trending_tags
-- =============================================================================

CREATE OR REPLACE FUNCTION public.get_trending_tags(
    hours_window INTEGER DEFAULT 24,
    min_occurrences INTEGER DEFAULT 3
)
RETURNS TABLE (
    tag TEXT,
    occurrence_count BIGINT,
    source_count BIGINT,
    is_trending BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    WITH article_tags AS (
        SELECT
            unnest(a.tags) AS tag,
            a.source,
            a.topic_id
        FROM public.articles a
        JOIN public.topics t ON a.topic_id = t.id
        WHERE t.user_id = auth.uid()
        AND a.created_at >= NOW() - (hours_window || ' hours')::INTERVAL
    ),
    tag_stats AS (
        SELECT
            at.tag,
            COUNT(*) AS occurrence_count,
            COUNT(DISTINCT at.source) AS source_count
        FROM article_tags at
        WHERE at.tag IS NOT NULL AND at.tag != ''
        GROUP BY at.tag
    )
    SELECT
        ts.tag,
        ts.occurrence_count,
        ts.source_count,
        (ts.occurrence_count >= min_occurrences AND ts.source_count >= 2) AS is_trending
    FROM tag_stats ts
    WHERE ts.occurrence_count >= 2
    ORDER BY ts.occurrence_count DESC, ts.source_count DESC
    LIMIT 20;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- FUNCTION: get_similar_articles
-- =============================================================================

CREATE OR REPLACE FUNCTION public.get_similar_articles(
    article_uuid UUID,
    limit_count INTEGER DEFAULT 5
)
RETURNS TABLE (
    id UUID,
    topic_id UUID,
    title TEXT,
    summary TEXT,
    url TEXT,
    source VARCHAR,
    published_at TIMESTAMP WITH TIME ZONE,
    relevance_score INTEGER,
    tags TEXT[],
    similarity_score INTEGER,
    common_tags TEXT[]
) AS $$
DECLARE
    source_tags TEXT[];
    source_source VARCHAR;
    source_topic_user_id UUID;
BEGIN
    -- Get the source article info
    SELECT a.tags, a.source, t.user_id
    INTO source_tags, source_source, source_topic_user_id
    FROM public.articles a
    JOIN public.topics t ON a.topic_id = t.id
    WHERE a.id = article_uuid AND t.user_id = auth.uid();

    IF source_topic_user_id IS NULL THEN
        RETURN;
    END IF;

    RETURN QUERY
    SELECT
        a.id,
        a.topic_id,
        a.title,
        a.summary,
        a.url,
        a.source,
        a.published_at,
        a.relevance_score,
        a.tags,
        (
            COALESCE(array_length(
                ARRAY(SELECT unnest(a.tags) INTERSECT SELECT unnest(source_tags)),
                1
            ), 0) * 2
            +
            CASE WHEN a.source = source_source THEN 1 ELSE 0 END
        )::INTEGER AS similarity_score,
        ARRAY(SELECT unnest(a.tags) INTERSECT SELECT unnest(source_tags)) AS common_tags
    FROM public.articles a
    JOIN public.topics t ON a.topic_id = t.id
    WHERE t.user_id = auth.uid()
    AND a.id != article_uuid
    AND a.tags IS NOT NULL
    AND array_length(a.tags, 1) > 0
    AND (
        COALESCE(array_length(
            ARRAY(SELECT unnest(a.tags) INTERSECT SELECT unnest(source_tags)),
            1
        ), 0) * 2
        +
        CASE WHEN a.source = source_source THEN 1 ELSE 0 END
    ) > 0
    ORDER BY (
        COALESCE(array_length(
            ARRAY(SELECT unnest(a.tags) INTERSECT SELECT unnest(source_tags)),
            1
        ), 0) * 2
        +
        CASE WHEN a.source = source_source THEN 1 ELSE 0 END
    ) DESC, a.published_at DESC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- FUNCTION: update_tag_preferences
-- =============================================================================

CREATE OR REPLACE FUNCTION public.update_tag_preferences(article_uuid UUID)
RETURNS void AS $$
DECLARE
    article_tags TEXT[];
    article_topic_user_id UUID;
    tag TEXT;
BEGIN
    SELECT a.tags, t.user_id
    INTO article_tags, article_topic_user_id
    FROM public.articles a
    JOIN public.topics t ON a.topic_id = t.id
    WHERE a.id = article_uuid;

    IF article_topic_user_id IS NULL OR article_topic_user_id != auth.uid() THEN
        RETURN;
    END IF;

    IF article_tags IS NOT NULL THEN
        FOREACH tag IN ARRAY article_tags
        LOOP
            IF tag IS NOT NULL AND tag != '' THEN
                INSERT INTO public.user_tag_preferences (user_id, tag, read_count, last_read_at)
                VALUES (auth.uid(), tag, 1, NOW())
                ON CONFLICT (user_id, tag)
                DO UPDATE SET
                    read_count = user_tag_preferences.read_count + 1,
                    last_read_at = NOW();
            END IF;
        END LOOP;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- FUNCTION: get_user_top_tags
-- =============================================================================

CREATE OR REPLACE FUNCTION public.get_user_top_tags(limit_count INTEGER DEFAULT 10)
RETURNS TABLE (
    tag TEXT,
    read_count INTEGER,
    last_read_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        utp.tag,
        utp.read_count,
        utp.last_read_at
    FROM public.user_tag_preferences utp
    WHERE utp.user_id = auth.uid()
    ORDER BY utp.read_count DESC, utp.last_read_at DESC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- FUNCTION: get_personalized_score
-- =============================================================================

CREATE OR REPLACE FUNCTION public.get_personalized_score(
    base_score INTEGER,
    article_tags TEXT[]
)
RETURNS INTEGER AS $$
DECLARE
    boost INTEGER := 0;
    user_top_tags TEXT[];
    common_count INTEGER;
BEGIN
    SELECT ARRAY_AGG(tag) INTO user_top_tags
    FROM (
        SELECT tag FROM public.user_tag_preferences
        WHERE user_id = auth.uid()
        ORDER BY read_count DESC
        LIMIT 20
    ) t;

    IF user_top_tags IS NULL OR article_tags IS NULL THEN
        RETURN base_score;
    END IF;

    SELECT COUNT(*) INTO common_count
    FROM (
        SELECT unnest(article_tags) INTERSECT SELECT unnest(user_top_tags)
    ) x;

    boost := LEAST(common_count * 5, 15);
    RETURN LEAST(base_score + boost, 100);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- TRIGGER: Auto-update tag preferences when article is marked as read
-- =============================================================================

CREATE OR REPLACE FUNCTION public.trigger_update_tag_preferences()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.read_status = 'read' AND (OLD.read_status IS NULL OR OLD.read_status != 'read') THEN
        PERFORM public.update_tag_preferences(NEW.id);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER update_tag_preferences_on_read
    AFTER UPDATE ON public.articles
    FOR EACH ROW
    EXECUTE FUNCTION public.trigger_update_tag_preferences();

-- =============================================================================
-- GRANT PERMISSIONS
-- =============================================================================

GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_tag_preferences TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_trending_tags(INTEGER, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_similar_articles(UUID, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_tag_preferences(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_top_tags(INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_personalized_score(INTEGER, TEXT[]) TO authenticated;

-- Success message
SELECT 'Migration 006_intelligence applied successfully' AS status;
