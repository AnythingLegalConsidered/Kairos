-- =============================================================================
-- KAIROS - Seed Data
-- =============================================================================
-- Description: Initial data for RSS sources catalog
-- Usage: Run this after migrations to populate default data
-- =============================================================================

-- =============================================================================
-- RSS SOURCES - Technology
-- =============================================================================

INSERT INTO public.rss_sources (name, url, category, language, description) VALUES

-- English Tech Sources
('Hacker News', 'https://hnrss.org/frontpage', 'technology', 'en', 'Hacker News front page stories'),
('TechCrunch', 'https://techcrunch.com/feed/', 'technology', 'en', 'Technology news and analysis'),
('Ars Technica', 'https://feeds.arstechnica.com/arstechnica/index', 'technology', 'en', 'Technology, science, and culture'),
('The Verge', 'https://www.theverge.com/rss/index.xml', 'technology', 'en', 'Technology, science, art, and culture'),
('Wired', 'https://www.wired.com/feed/rss', 'technology', 'en', 'Technology and culture'),
('MIT Technology Review', 'https://www.technologyreview.com/feed/', 'technology', 'en', 'Emerging technology insights'),

-- French Tech Sources
('Le Journal du Net', 'https://www.journaldunet.com/rss/', 'technology', 'fr', 'Actualités tech et business'),
('01net', 'https://www.01net.com/rss/info/flux-rss/flux-toutes-les-actualites/', 'technology', 'fr', 'Actualités high-tech'),
('Numerama', 'https://www.numerama.com/feed/', 'technology', 'fr', 'Actualités tech et société numérique'),
('Frandroid', 'https://www.frandroid.com/feed', 'technology', 'fr', 'Actualités Android et tech'),

-- =============================================================================
-- RSS SOURCES - AI & Machine Learning
-- =============================================================================

('OpenAI Blog', 'https://openai.com/blog/rss/', 'ai_ml', 'en', 'OpenAI research and announcements'),
('Google AI Blog', 'https://blog.google/technology/ai/rss/', 'ai_ml', 'en', 'Google AI research updates'),
('Towards Data Science', 'https://towardsdatascience.com/feed', 'ai_ml', 'en', 'Data science and ML articles'),
('Machine Learning Mastery', 'https://machinelearningmastery.com/feed/', 'ai_ml', 'en', 'ML tutorials and guides'),
('AI News', 'https://www.artificialintelligence-news.com/feed/', 'ai_ml', 'en', 'AI industry news'),
('DeepMind Blog', 'https://deepmind.google/blog/rss.xml', 'ai_ml', 'en', 'DeepMind research updates'),

-- =============================================================================
-- RSS SOURCES - Programming
-- =============================================================================

('Dev.to', 'https://dev.to/feed', 'programming', 'en', 'Developer community articles'),
('CSS-Tricks', 'https://css-tricks.com/feed/', 'programming', 'en', 'Web development tips and tricks'),
('Smashing Magazine', 'https://www.smashingmagazine.com/feed/', 'programming', 'en', 'Web design and development'),
('JavaScript Weekly', 'https://javascriptweekly.com/rss/', 'programming', 'en', 'JavaScript news and articles'),
('Python Weekly', 'https://us2.campaign-archive.com/feed?u=e2e180baf855ac797ef407fc7&id=9e26887fc5', 'programming', 'en', 'Python news and tutorials'),
('Real Python', 'https://realpython.com/atom.xml', 'programming', 'en', 'Python tutorials'),
('Rust Blog', 'https://blog.rust-lang.org/feed.xml', 'programming', 'en', 'Rust language updates'),
('Go Blog', 'https://go.dev/blog/feed.atom', 'programming', 'en', 'Go language updates'),

-- =============================================================================
-- RSS SOURCES - Security
-- =============================================================================

('Krebs on Security', 'https://krebsonsecurity.com/feed/', 'security', 'en', 'Security news and investigation'),
('Schneier on Security', 'https://www.schneier.com/feed/', 'security', 'en', 'Security analysis and commentary'),
('The Hacker News', 'https://feeds.feedburner.com/TheHackersNews', 'security', 'en', 'Cybersecurity news'),
('Dark Reading', 'https://www.darkreading.com/rss.xml', 'security', 'en', 'Enterprise security news'),
('ZATAZ', 'https://www.zataz.com/feed/', 'security', 'fr', 'Actualités cybersécurité'),

-- =============================================================================
-- RSS SOURCES - Science
-- =============================================================================

('Nature', 'https://www.nature.com/nature.rss', 'science', 'en', 'Scientific research and news'),
('Science Daily', 'https://www.sciencedaily.com/rss/all.xml', 'science', 'en', 'Science news'),
('Phys.org', 'https://phys.org/rss-feed/', 'science', 'en', 'Physics and technology news'),
('New Scientist', 'https://www.newscientist.com/feed/home/', 'science', 'en', 'Science and technology news'),
('Futura Sciences', 'https://www.futura-sciences.com/rss/actualites.xml', 'science', 'fr', 'Sciences et technologies'),

-- =============================================================================
-- RSS SOURCES - Startups & Business
-- =============================================================================

('Y Combinator Blog', 'https://www.ycombinator.com/blog/rss/', 'startup', 'en', 'YC startup insights'),
('a]6z', 'https://a16z.com/feed/', 'startup', 'en', 'Tech and startup insights'),
('First Round Review', 'https://review.firstround.com/feed.xml', 'startup', 'en', 'Startup advice and insights'),
('Maddyness', 'https://www.maddyness.com/feed/', 'startup', 'fr', 'Actualités startups françaises'),
('FrenchWeb', 'https://www.frenchweb.fr/feed', 'startup', 'fr', 'Tech et startups en France'),

-- =============================================================================
-- RSS SOURCES - Design
-- =============================================================================

('A List Apart', 'https://alistapart.com/main/feed/', 'design', 'en', 'Web design and development'),
('UX Collective', 'https://uxdesign.cc/feed', 'design', 'en', 'UX design articles'),
('Nielsen Norman Group', 'https://www.nngroup.com/feed/rss/', 'design', 'en', 'UX research and insights'),
('Dribbble Blog', 'https://dribbble.com/stories.rss', 'design', 'en', 'Design inspiration and stories')

ON CONFLICT (url) DO NOTHING;

-- =============================================================================
-- Verify seed data
-- =============================================================================

DO $$
DECLARE
    source_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO source_count FROM public.rss_sources;
    RAISE NOTICE 'Seeded % RSS sources', source_count;
END $$;
