-- =============================================================================
-- KAIROS - Initial Database Schema
-- =============================================================================
-- Migration: 001_initial_schema.sql
-- Description: Creates the core tables for the Kairos platform
-- =============================================================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";  -- For text search optimization

-- =============================================================================
-- ENUM TYPES
-- =============================================================================

-- Sentiment analysis results
CREATE TYPE sentiment_type AS ENUM ('positive', 'neutral', 'negative');

-- Article read status
CREATE TYPE read_status_type AS ENUM ('unread', 'read', 'archived');

-- RSS source categories
CREATE TYPE source_category AS ENUM (
    'technology',
    'science',
    'business',
    'security',
    'ai_ml',
    'programming',
    'design',
    'startup',
    'other'
);

-- =============================================================================
-- TABLE: topics
-- =============================================================================
-- User-defined topics for monitoring specific subjects

CREATE TABLE IF NOT EXISTS public.topics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    -- Topic information
    name VARCHAR(100) NOT NULL,
    description TEXT,

    -- Keywords for filtering/scoring articles
    keywords_fr TEXT[] DEFAULT '{}',  -- French keywords
    keywords_en TEXT[] DEFAULT '{}',  -- English keywords

    -- RSS feeds to monitor for this topic
    rss_feeds TEXT[] DEFAULT '{}',

    -- Status
    active BOOLEAN DEFAULT true,

    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Constraints
    CONSTRAINT topics_name_length CHECK (char_length(name) >= 2)
);

-- Indexes for topics
CREATE INDEX idx_topics_user_id ON public.topics(user_id);
CREATE INDEX idx_topics_active ON public.topics(active) WHERE active = true;
CREATE INDEX idx_topics_created_at ON public.topics(created_at DESC);

-- =============================================================================
-- TABLE: rss_sources
-- =============================================================================
-- Global catalog of RSS sources available to all users

CREATE TABLE IF NOT EXISTS public.rss_sources (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Source information
    name VARCHAR(200) NOT NULL,
    url TEXT NOT NULL UNIQUE,
    description TEXT,

    -- Categorization
    category source_category DEFAULT 'other',
    language VARCHAR(5) DEFAULT 'en',  -- ISO 639-1 code (fr, en, etc.)

    -- Status
    active BOOLEAN DEFAULT true,

    -- Metadata
    last_fetched_at TIMESTAMP WITH TIME ZONE,
    fetch_error_count INTEGER DEFAULT 0,

    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for rss_sources
CREATE INDEX idx_rss_sources_category ON public.rss_sources(category);
CREATE INDEX idx_rss_sources_language ON public.rss_sources(language);
CREATE INDEX idx_rss_sources_active ON public.rss_sources(active) WHERE active = true;

-- =============================================================================
-- TABLE: articles
-- =============================================================================
-- Articles fetched from RSS feeds and processed by AI

CREATE TABLE IF NOT EXISTS public.articles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    topic_id UUID NOT NULL REFERENCES public.topics(id) ON DELETE CASCADE,

    -- Source information
    source_url TEXT,  -- URL of the RSS feed
    source VARCHAR(200),  -- Name of the source

    -- Article content
    title TEXT NOT NULL,
    content TEXT,  -- Full article content (if available)
    summary TEXT,  -- AI-generated summary
    url TEXT NOT NULL,  -- Link to original article
    image_url TEXT,  -- Featured image
    author VARCHAR(200),

    -- Dates
    published_at TIMESTAMP WITH TIME ZONE,

    -- AI analysis results
    relevance_score INTEGER CHECK (relevance_score >= 0 AND relevance_score <= 100),
    sentiment sentiment_type DEFAULT 'neutral',
    tags TEXT[] DEFAULT '{}',  -- AI-generated tags

    -- User interaction
    read_status read_status_type DEFAULT 'unread',
    bookmarked BOOLEAN DEFAULT false,
    user_notes TEXT,

    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    read_at TIMESTAMP WITH TIME ZONE,

    -- Prevent duplicate articles per topic
    CONSTRAINT articles_unique_url_per_topic UNIQUE (topic_id, url)
);

-- Indexes for articles
CREATE INDEX idx_articles_topic_id ON public.articles(topic_id);
CREATE INDEX idx_articles_published_at ON public.articles(published_at DESC);
CREATE INDEX idx_articles_relevance_score ON public.articles(relevance_score DESC);
CREATE INDEX idx_articles_read_status ON public.articles(read_status);
CREATE INDEX idx_articles_bookmarked ON public.articles(bookmarked) WHERE bookmarked = true;
CREATE INDEX idx_articles_created_at ON public.articles(created_at DESC);
CREATE INDEX idx_articles_sentiment ON public.articles(sentiment);

-- Full-text search index on title and summary
CREATE INDEX idx_articles_title_fts ON public.articles USING gin(to_tsvector('french', coalesce(title, '')));
CREATE INDEX idx_articles_summary_fts ON public.articles USING gin(to_tsvector('french', coalesce(summary, '')));

-- =============================================================================
-- TABLE: user_preferences
-- =============================================================================
-- User-specific settings and preferences

CREATE TABLE IF NOT EXISTS public.user_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,

    -- Display preferences
    theme VARCHAR(20) DEFAULT 'light',  -- 'light', 'dark', 'system'
    articles_per_page INTEGER DEFAULT 20,
    default_sort VARCHAR(50) DEFAULT 'published_at_desc',

    -- Notification preferences
    email_digest BOOLEAN DEFAULT false,
    email_digest_frequency VARCHAR(20) DEFAULT 'daily',  -- 'daily', 'weekly'
    notify_high_relevance BOOLEAN DEFAULT true,
    high_relevance_threshold INTEGER DEFAULT 80,

    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for user_preferences
CREATE INDEX idx_user_preferences_user_id ON public.user_preferences(user_id);

-- =============================================================================
-- COMMENTS
-- =============================================================================

COMMENT ON TABLE public.topics IS 'User-defined topics for monitoring specific subjects via RSS feeds';
COMMENT ON TABLE public.rss_sources IS 'Global catalog of available RSS sources';
COMMENT ON TABLE public.articles IS 'Articles fetched from RSS feeds with AI analysis';
COMMENT ON TABLE public.user_preferences IS 'User-specific settings and preferences';

COMMENT ON COLUMN public.articles.relevance_score IS 'AI-calculated relevance score from 0-100';
COMMENT ON COLUMN public.articles.sentiment IS 'AI-analyzed sentiment of the article';
COMMENT ON COLUMN public.topics.keywords_fr IS 'French keywords for content filtering';
COMMENT ON COLUMN public.topics.keywords_en IS 'English keywords for content filtering';
