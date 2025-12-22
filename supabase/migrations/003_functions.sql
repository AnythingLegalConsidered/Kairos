-- =============================================================================
-- KAIROS - PostgreSQL Functions and Triggers
-- =============================================================================
-- Migration: 003_functions.sql
-- Description: Utility functions and automatic triggers
-- =============================================================================

-- =============================================================================
-- FUNCTION: update_updated_at_column
-- =============================================================================
-- Automatically updates the updated_at timestamp when a row is modified

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to all tables with updated_at column
CREATE TRIGGER update_topics_updated_at
    BEFORE UPDATE ON public.topics
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_articles_updated_at
    BEFORE UPDATE ON public.articles
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_rss_sources_updated_at
    BEFORE UPDATE ON public.rss_sources
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_user_preferences_updated_at
    BEFORE UPDATE ON public.user_preferences
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- =============================================================================
-- FUNCTION: set_article_read_at
-- =============================================================================
-- Automatically sets read_at timestamp when article is marked as read

CREATE OR REPLACE FUNCTION public.set_article_read_at()
RETURNS TRIGGER AS $$
BEGIN
    -- Set read_at when status changes to 'read'
    IF NEW.read_status = 'read' AND (OLD.read_status IS NULL OR OLD.read_status != 'read') THEN
        NEW.read_at = NOW();
    END IF;
    -- Clear read_at if status changes back to 'unread'
    IF NEW.read_status = 'unread' THEN
        NEW.read_at = NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_article_read_at_trigger
    BEFORE UPDATE ON public.articles
    FOR EACH ROW
    EXECUTE FUNCTION public.set_article_read_at();

-- =============================================================================
-- FUNCTION: create_user_preferences
-- =============================================================================
-- Automatically creates default preferences when a new user signs up

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_preferences (user_id)
    VALUES (NEW.id)
    ON CONFLICT (user_id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on auth.users (requires appropriate permissions)
CREATE OR REPLACE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- =============================================================================
-- FUNCTION: get_topic_stats
-- =============================================================================
-- Returns statistics for a specific topic

CREATE OR REPLACE FUNCTION public.get_topic_stats(topic_uuid UUID)
RETURNS TABLE (
    total_articles BIGINT,
    unread_articles BIGINT,
    bookmarked_articles BIGINT,
    avg_relevance NUMERIC,
    positive_sentiment BIGINT,
    neutral_sentiment BIGINT,
    negative_sentiment BIGINT,
    latest_article_date TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(*)::BIGINT AS total_articles,
        COUNT(*) FILTER (WHERE read_status = 'unread')::BIGINT AS unread_articles,
        COUNT(*) FILTER (WHERE bookmarked = true)::BIGINT AS bookmarked_articles,
        ROUND(AVG(relevance_score), 1) AS avg_relevance,
        COUNT(*) FILTER (WHERE sentiment = 'positive')::BIGINT AS positive_sentiment,
        COUNT(*) FILTER (WHERE sentiment = 'neutral')::BIGINT AS neutral_sentiment,
        COUNT(*) FILTER (WHERE sentiment = 'negative')::BIGINT AS negative_sentiment,
        MAX(published_at) AS latest_article_date
    FROM public.articles
    WHERE topic_id = topic_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- FUNCTION: get_user_dashboard_stats
-- =============================================================================
-- Returns dashboard statistics for the current user

CREATE OR REPLACE FUNCTION public.get_user_dashboard_stats()
RETURNS TABLE (
    total_topics BIGINT,
    active_topics BIGINT,
    total_articles BIGINT,
    unread_articles BIGINT,
    bookmarked_articles BIGINT,
    high_relevance_articles BIGINT,
    articles_today BIGINT,
    articles_this_week BIGINT
) AS $$
BEGIN
    RETURN QUERY
    WITH user_topics AS (
        SELECT id FROM public.topics WHERE user_id = auth.uid()
    ),
    user_articles AS (
        SELECT a.* FROM public.articles a
        JOIN user_topics t ON a.topic_id = t.id
    )
    SELECT
        (SELECT COUNT(*) FROM public.topics WHERE user_id = auth.uid())::BIGINT AS total_topics,
        (SELECT COUNT(*) FROM public.topics WHERE user_id = auth.uid() AND active = true)::BIGINT AS active_topics,
        COUNT(*)::BIGINT AS total_articles,
        COUNT(*) FILTER (WHERE read_status = 'unread')::BIGINT AS unread_articles,
        COUNT(*) FILTER (WHERE bookmarked = true)::BIGINT AS bookmarked_articles,
        COUNT(*) FILTER (WHERE relevance_score >= 80)::BIGINT AS high_relevance_articles,
        COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE)::BIGINT AS articles_today,
        COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE - INTERVAL '7 days')::BIGINT AS articles_this_week
    FROM user_articles;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- FUNCTION: search_articles
-- =============================================================================
-- Full-text search across articles for the current user

CREATE OR REPLACE FUNCTION public.search_articles(
    search_query TEXT,
    limit_count INTEGER DEFAULT 50,
    offset_count INTEGER DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    topic_id UUID,
    title TEXT,
    summary TEXT,
    url TEXT,
    source_name VARCHAR,
    published_at TIMESTAMP WITH TIME ZONE,
    relevance_score INTEGER,
    sentiment sentiment_type,
    read_status read_status_type,
    bookmarked BOOLEAN,
    rank REAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id,
        a.topic_id,
        a.title,
        a.summary,
        a.url,
        a.source_name,
        a.published_at,
        a.relevance_score,
        a.sentiment,
        a.read_status,
        a.bookmarked,
        ts_rank(
            to_tsvector('french', coalesce(a.title, '') || ' ' || coalesce(a.summary, '')),
            plainto_tsquery('french', search_query)
        ) AS rank
    FROM public.articles a
    JOIN public.topics t ON a.topic_id = t.id
    WHERE t.user_id = auth.uid()
    AND (
        to_tsvector('french', coalesce(a.title, '') || ' ' || coalesce(a.summary, ''))
        @@ plainto_tsquery('french', search_query)
        OR a.title ILIKE '%' || search_query || '%'
        OR a.summary ILIKE '%' || search_query || '%'
    )
    ORDER BY rank DESC, a.published_at DESC
    LIMIT limit_count
    OFFSET offset_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- FUNCTION: cleanup_old_articles
-- =============================================================================
-- Deletes articles older than specified days (except bookmarked ones)

CREATE OR REPLACE FUNCTION public.cleanup_old_articles(days_to_keep INTEGER DEFAULT 30)
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM public.articles
    WHERE created_at < NOW() - (days_to_keep || ' days')::INTERVAL
    AND bookmarked = false;

    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- FUNCTION: mark_all_as_read
-- =============================================================================
-- Marks all articles in a topic as read

CREATE OR REPLACE FUNCTION public.mark_all_as_read(topic_uuid UUID)
RETURNS INTEGER AS $$
DECLARE
    updated_count INTEGER;
BEGIN
    -- Verify user owns the topic
    IF NOT EXISTS (
        SELECT 1 FROM public.topics
        WHERE id = topic_uuid AND user_id = auth.uid()
    ) THEN
        RAISE EXCEPTION 'Access denied: you do not own this topic';
    END IF;

    UPDATE public.articles
    SET read_status = 'read'
    WHERE topic_id = topic_uuid
    AND read_status = 'unread';

    GET DIAGNOSTICS updated_count = ROW_COUNT;
    RETURN updated_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- FUNCTION: get_active_topics_with_feeds
-- =============================================================================
-- Returns all active topics with their RSS feeds (for n8n workflow)

CREATE OR REPLACE FUNCTION public.get_active_topics_with_feeds()
RETURNS TABLE (
    topic_id UUID,
    topic_name VARCHAR,
    user_id UUID,
    keywords_fr TEXT[],
    keywords_en TEXT[],
    rss_feeds TEXT[]
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.id AS topic_id,
        t.name AS topic_name,
        t.user_id,
        t.keywords_fr,
        t.keywords_en,
        t.rss_feeds
    FROM public.topics t
    WHERE t.active = true
    AND array_length(t.rss_feeds, 1) > 0;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- GRANT EXECUTE PERMISSIONS
-- =============================================================================

GRANT EXECUTE ON FUNCTION public.get_topic_stats(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_dashboard_stats() TO authenticated;
GRANT EXECUTE ON FUNCTION public.search_articles(TEXT, INTEGER, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION public.mark_all_as_read(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_active_topics_with_feeds() TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.cleanup_old_articles(INTEGER) TO service_role;
