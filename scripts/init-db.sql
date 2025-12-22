-- =============================================================================
-- KAIROS - Database Initialization Script
-- =============================================================================
-- Compatible avec Supabase self-hosted (PostgreSQL 15)
-- Utilise gen_random_uuid() au lieu de uuid_generate_v4()
-- =============================================================================

-- =============================================================================
-- TABLE: topics
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.topics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    -- Topic information (topic_name pour compatibilite frontend)
    topic_name VARCHAR(100) NOT NULL,
    description TEXT,

    -- RSS feeds to monitor
    rss_feeds TEXT[] DEFAULT '{}',

    -- Status
    active BOOLEAN DEFAULT true,

    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_topics_user_id ON public.topics(user_id);
CREATE INDEX IF NOT EXISTS idx_topics_active ON public.topics(active) WHERE active = true;

-- =============================================================================
-- TABLE: articles
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.articles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    topic_id UUID NOT NULL REFERENCES public.topics(id) ON DELETE CASCADE,

    -- Article content
    title TEXT NOT NULL,
    summary TEXT,
    content TEXT,
    source VARCHAR(200),
    url TEXT NOT NULL,

    -- Dates
    published_date TIMESTAMP WITH TIME ZONE,

    -- AI analysis (score 1-5 pour compatibilite frontend)
    relevance_score INTEGER CHECK (relevance_score >= 1 AND relevance_score <= 5),
    sentiment VARCHAR(20) DEFAULT 'neutral',
    tags TEXT[] DEFAULT '{}',

    -- User interaction
    read_status BOOLEAN DEFAULT false,
    bookmarked BOOLEAN DEFAULT false,

    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Prevent duplicates
    CONSTRAINT articles_unique_url_per_topic UNIQUE (topic_id, url)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_articles_user_id ON public.articles(user_id);
CREATE INDEX IF NOT EXISTS idx_articles_topic_id ON public.articles(topic_id);
CREATE INDEX IF NOT EXISTS idx_articles_created_at ON public.articles(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_articles_read_status ON public.articles(read_status);
CREATE INDEX IF NOT EXISTS idx_articles_bookmarked ON public.articles(bookmarked) WHERE bookmarked = true;

-- =============================================================================
-- TABLE: rss_sources (catalogue global)
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.rss_sources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(200) NOT NULL,
    url TEXT NOT NULL UNIQUE,
    category VARCHAR(50),
    language VARCHAR(5) DEFAULT 'fr',
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================================================
-- TABLE: user_preferences
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.user_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    theme VARCHAR(20) DEFAULT 'light',
    articles_per_page INTEGER DEFAULT 20,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================================================
-- ROW LEVEL SECURITY (RLS)
-- =============================================================================

-- Enable RLS
ALTER TABLE public.topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;

-- Topics policies
DROP POLICY IF EXISTS "Users can view own topics" ON public.topics;
CREATE POLICY "Users can view own topics" ON public.topics
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own topics" ON public.topics;
CREATE POLICY "Users can insert own topics" ON public.topics
    FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own topics" ON public.topics;
CREATE POLICY "Users can update own topics" ON public.topics
    FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own topics" ON public.topics;
CREATE POLICY "Users can delete own topics" ON public.topics
    FOR DELETE USING (auth.uid() = user_id);

-- Articles policies
DROP POLICY IF EXISTS "Users can view own articles" ON public.articles;
CREATE POLICY "Users can view own articles" ON public.articles
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own articles" ON public.articles;
CREATE POLICY "Users can insert own articles" ON public.articles
    FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own articles" ON public.articles;
CREATE POLICY "Users can update own articles" ON public.articles
    FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own articles" ON public.articles;
CREATE POLICY "Users can delete own articles" ON public.articles
    FOR DELETE USING (auth.uid() = user_id);

-- User preferences policies
DROP POLICY IF EXISTS "Users can view own preferences" ON public.user_preferences;
CREATE POLICY "Users can view own preferences" ON public.user_preferences
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own preferences" ON public.user_preferences;
CREATE POLICY "Users can insert own preferences" ON public.user_preferences
    FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own preferences" ON public.user_preferences;
CREATE POLICY "Users can update own preferences" ON public.user_preferences
    FOR UPDATE USING (auth.uid() = user_id);

-- RSS sources - public read access
ALTER TABLE public.rss_sources ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view rss sources" ON public.rss_sources;
CREATE POLICY "Anyone can view rss sources" ON public.rss_sources
    FOR SELECT USING (true);

-- =============================================================================
-- GRANT permissions to authenticated users
-- =============================================================================

GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON public.topics TO anon, authenticated;
GRANT ALL ON public.articles TO anon, authenticated;
GRANT ALL ON public.user_preferences TO anon, authenticated;
GRANT SELECT ON public.rss_sources TO anon, authenticated;

-- =============================================================================
-- Seed data: RSS sources
-- =============================================================================

INSERT INTO public.rss_sources (name, url, category, language) VALUES
    -- Presse FR
    ('Le Monde', 'https://www.lemonde.fr/rss/une.xml', 'press', 'fr'),
    ('Libération', 'https://www.liberation.fr/arc/outboundfeeds/rss-all/collection/accueil-702/?outputType=xml', 'press', 'fr'),
    ('Le Figaro', 'https://www.lefigaro.fr/rss/figaro_actualites.xml', 'press', 'fr'),

    -- Tech FR
    ('01net', 'https://www.01net.com/rss/info/flux-rss/flux-toutes-les-actualites/', 'tech', 'fr'),
    ('Numerama', 'https://www.numerama.com/feed/', 'tech', 'fr'),
    ('Next INpact', 'https://www.nextinpact.com/rss/news.xml', 'tech', 'fr'),

    -- Tech EN
    ('TechCrunch', 'https://techcrunch.com/feed/', 'tech', 'en'),
    ('The Verge', 'https://www.theverge.com/rss/index.xml', 'tech', 'en'),
    ('Ars Technica', 'https://feeds.arstechnica.com/arstechnica/index', 'tech', 'en'),
    ('Hacker News', 'https://hnrss.org/frontpage', 'tech', 'en'),

    -- Science
    ('Futura Sciences', 'https://www.futura-sciences.com/rss/actualites.xml', 'science', 'fr'),
    ('Science Daily', 'https://www.sciencedaily.com/rss/all.xml', 'science', 'en')
ON CONFLICT (url) DO NOTHING;

-- =============================================================================
-- Done
-- =============================================================================

SELECT 'Database initialized successfully!' as status;
