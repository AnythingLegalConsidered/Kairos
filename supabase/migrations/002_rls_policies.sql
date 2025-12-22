-- =============================================================================
-- KAIROS - Row Level Security Policies
-- =============================================================================
-- Migration: 002_rls_policies.sql
-- Description: Configures RLS for secure multi-tenant data isolation
-- =============================================================================

-- =============================================================================
-- ENABLE RLS ON ALL TABLES
-- =============================================================================

ALTER TABLE public.topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rss_sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;

-- =============================================================================
-- POLICIES FOR: topics
-- =============================================================================
-- Users can only see and manage their own topics

-- SELECT: Users can read their own topics
CREATE POLICY "Users can view their own topics"
    ON public.topics
    FOR SELECT
    USING (auth.uid() = user_id);

-- INSERT: Users can create topics for themselves
CREATE POLICY "Users can create their own topics"
    ON public.topics
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- UPDATE: Users can update their own topics
CREATE POLICY "Users can update their own topics"
    ON public.topics
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- DELETE: Users can delete their own topics
CREATE POLICY "Users can delete their own topics"
    ON public.topics
    FOR DELETE
    USING (auth.uid() = user_id);

-- =============================================================================
-- POLICIES FOR: articles
-- =============================================================================
-- Users can only see articles from their own topics

-- SELECT: Users can read articles from their topics
CREATE POLICY "Users can view articles from their topics"
    ON public.articles
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.topics
            WHERE topics.id = articles.topic_id
            AND topics.user_id = auth.uid()
        )
    );

-- INSERT: System/service role can insert articles (via n8n)
-- Regular users cannot insert articles directly
CREATE POLICY "Service role can insert articles"
    ON public.articles
    FOR INSERT
    WITH CHECK (
        -- Allow if user owns the topic
        EXISTS (
            SELECT 1 FROM public.topics
            WHERE topics.id = articles.topic_id
            AND topics.user_id = auth.uid()
        )
        -- OR if using service role (for n8n workflows)
        OR auth.jwt()->>'role' = 'service_role'
    );

-- UPDATE: Users can update articles from their topics (mark as read, bookmark, etc.)
CREATE POLICY "Users can update articles from their topics"
    ON public.articles
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.topics
            WHERE topics.id = articles.topic_id
            AND topics.user_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.topics
            WHERE topics.id = articles.topic_id
            AND topics.user_id = auth.uid()
        )
    );

-- DELETE: Users can delete articles from their topics
CREATE POLICY "Users can delete articles from their topics"
    ON public.articles
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.topics
            WHERE topics.id = articles.topic_id
            AND topics.user_id = auth.uid()
        )
    );

-- =============================================================================
-- POLICIES FOR: rss_sources
-- =============================================================================
-- RSS sources are public (read-only for all authenticated users)
-- Only admins/service role can modify them

-- SELECT: All authenticated users can read RSS sources
CREATE POLICY "Authenticated users can view RSS sources"
    ON public.rss_sources
    FOR SELECT
    TO authenticated
    USING (true);

-- INSERT: Only service role can insert RSS sources
CREATE POLICY "Service role can insert RSS sources"
    ON public.rss_sources
    FOR INSERT
    WITH CHECK (auth.jwt()->>'role' = 'service_role');

-- UPDATE: Only service role can update RSS sources
CREATE POLICY "Service role can update RSS sources"
    ON public.rss_sources
    FOR UPDATE
    USING (auth.jwt()->>'role' = 'service_role')
    WITH CHECK (auth.jwt()->>'role' = 'service_role');

-- DELETE: Only service role can delete RSS sources
CREATE POLICY "Service role can delete RSS sources"
    ON public.rss_sources
    FOR DELETE
    USING (auth.jwt()->>'role' = 'service_role');

-- =============================================================================
-- POLICIES FOR: user_preferences
-- =============================================================================
-- Users can only access their own preferences

-- SELECT: Users can read their own preferences
CREATE POLICY "Users can view their own preferences"
    ON public.user_preferences
    FOR SELECT
    USING (auth.uid() = user_id);

-- INSERT: Users can create their own preferences
CREATE POLICY "Users can create their own preferences"
    ON public.user_preferences
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- UPDATE: Users can update their own preferences
CREATE POLICY "Users can update their own preferences"
    ON public.user_preferences
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- DELETE: Users can delete their own preferences
CREATE POLICY "Users can delete their own preferences"
    ON public.user_preferences
    FOR DELETE
    USING (auth.uid() = user_id);

-- =============================================================================
-- GRANT PERMISSIONS
-- =============================================================================

-- Grant usage on public schema
GRANT USAGE ON SCHEMA public TO anon, authenticated;

-- Grant permissions on tables
GRANT SELECT ON public.rss_sources TO anon, authenticated;
GRANT ALL ON public.topics TO authenticated;
GRANT ALL ON public.articles TO authenticated;
GRANT ALL ON public.user_preferences TO authenticated;

-- Grant permissions on sequences (for auto-generated IDs if any)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;
