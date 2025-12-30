-- =============================================================================
-- KAIROS - Seed Data (v0.3.0)
-- =============================================================================
-- Description: Catalogue de 100+ sources RSS (50+ FR, 50+ EN)
-- Usage: Run this after migrations to populate default data
-- =============================================================================

-- =============================================================================
-- RSS SOURCES - Technology (24 sources)
-- =============================================================================

INSERT INTO public.rss_sources (name, url, category, language, description) VALUES

-- English Tech Sources (12)
('Hacker News', 'https://hnrss.org/frontpage', 'technology', 'en', 'Hacker News front page stories'),
('TechCrunch', 'https://techcrunch.com/feed/', 'technology', 'en', 'Technology news and analysis'),
('Ars Technica', 'https://feeds.arstechnica.com/arstechnica/index', 'technology', 'en', 'Technology, science, and culture'),
('The Verge', 'https://www.theverge.com/rss/index.xml', 'technology', 'en', 'Technology, science, art, and culture'),
('Wired', 'https://www.wired.com/feed/rss', 'technology', 'en', 'Technology and culture'),
('MIT Technology Review', 'https://www.technologyreview.com/feed/', 'technology', 'en', 'Emerging technology insights'),
('Engadget', 'https://www.engadget.com/rss.xml', 'technology', 'en', 'Consumer electronics and technology'),
('CNET', 'https://www.cnet.com/rss/news/', 'technology', 'en', 'Tech product reviews and news'),
('ZDNet', 'https://www.zdnet.com/rss.xml', 'technology', 'en', 'Business technology news'),
('VentureBeat', 'https://venturebeat.com/feed/', 'technology', 'en', 'Tech news for decision makers'),
('The Register', 'https://www.theregister.com/headlines.rss', 'technology', 'en', 'IT news and analysis'),
('Gizmodo', 'https://gizmodo.com/rss', 'technology', 'en', 'Technology and science news'),

-- French Tech Sources (12)
('Le Journal du Net', 'https://www.journaldunet.com/rss/', 'technology', 'fr', 'Actualites tech et business'),
('01net', 'https://www.01net.com/rss/info/flux-rss/flux-toutes-les-actualites/', 'technology', 'fr', 'Actualites high-tech'),
('Numerama', 'https://www.numerama.com/feed/', 'technology', 'fr', 'Actualites tech et societe numerique'),
('Frandroid', 'https://www.frandroid.com/feed', 'technology', 'fr', 'Actualites Android et tech'),
('Next INpact', 'https://www.nextinpact.com/rss/news.xml', 'technology', 'fr', 'Actualites informatiques et numeriques'),
('Korben', 'https://korben.info/feed', 'technology', 'fr', 'Actualites geek et tech'),
('Clubic', 'https://www.clubic.com/feed/news.rss', 'technology', 'fr', 'High-tech et informatique'),
('MacGeneration', 'https://www.macgeneration.com/rss', 'technology', 'fr', 'Actualites Apple et Mac'),
('iPhon.fr', 'https://www.iphon.fr/feed', 'technology', 'fr', 'Actualites iPhone et Apple'),
('Presse-citron', 'https://www.presse-citron.net/feed/', 'technology', 'fr', 'Actualites tech et web'),
('Siècle Digital', 'https://siecledigital.fr/feed/', 'technology', 'fr', 'Transformation digitale'),
('Blog du Moderateur', 'https://www.blogdumoderateur.com/feed/', 'technology', 'fr', 'Web, reseaux sociaux et tech'),

-- =============================================================================
-- RSS SOURCES - AI & Machine Learning (14 sources)
-- =============================================================================

-- English AI Sources (10)
('OpenAI Blog', 'https://openai.com/blog/rss/', 'ai_ml', 'en', 'OpenAI research and announcements'),
('Google AI Blog', 'https://blog.google/technology/ai/rss/', 'ai_ml', 'en', 'Google AI research updates'),
('Towards Data Science', 'https://towardsdatascience.com/feed', 'ai_ml', 'en', 'Data science and ML articles'),
('Machine Learning Mastery', 'https://machinelearningmastery.com/feed/', 'ai_ml', 'en', 'ML tutorials and guides'),
('AI News', 'https://www.artificialintelligence-news.com/feed/', 'ai_ml', 'en', 'AI industry news'),
('DeepMind Blog', 'https://deepmind.google/blog/rss.xml', 'ai_ml', 'en', 'DeepMind research updates'),
('Papers With Code', 'https://paperswithcode.com/rss', 'ai_ml', 'en', 'Latest ML papers with code'),
('Distill', 'https://distill.pub/rss.xml', 'ai_ml', 'en', 'Clear explanations of ML'),
('The Gradient', 'https://thegradient.pub/rss/', 'ai_ml', 'en', 'AI research perspectives'),
('Import AI', 'https://importai.substack.com/feed', 'ai_ml', 'en', 'Weekly AI newsletter'),

-- French AI Sources (4)
('ActuIA', 'https://www.actuia.com/feed/', 'ai_ml', 'fr', 'Actualites intelligence artificielle'),
('LeBigData.fr', 'https://www.lebigdata.fr/feed', 'ai_ml', 'fr', 'Big Data et IA'),
('Intelligence Artificielle - Le Monde', 'https://www.lemonde.fr/intelligence-artificielle/rss_full.xml', 'ai_ml', 'fr', 'IA par Le Monde'),
('Data Analytics Post', 'https://dataanalyticspost.com/feed/', 'ai_ml', 'fr', 'Data science et analytics'),

-- =============================================================================
-- RSS SOURCES - Programming (16 sources)
-- =============================================================================

-- English Programming Sources (12)
('Dev.to', 'https://dev.to/feed', 'programming', 'en', 'Developer community articles'),
('CSS-Tricks', 'https://css-tricks.com/feed/', 'programming', 'en', 'Web development tips and tricks'),
('Smashing Magazine', 'https://www.smashingmagazine.com/feed/', 'programming', 'en', 'Web design and development'),
('JavaScript Weekly', 'https://javascriptweekly.com/rss/', 'programming', 'en', 'JavaScript news and articles'),
('Real Python', 'https://realpython.com/atom.xml', 'programming', 'en', 'Python tutorials'),
('Rust Blog', 'https://blog.rust-lang.org/feed.xml', 'programming', 'en', 'Rust language updates'),
('Go Blog', 'https://go.dev/blog/feed.atom', 'programming', 'en', 'Go language updates'),
('InfoQ', 'https://www.infoq.com/rss/', 'programming', 'en', 'Software development news'),
('DZone', 'https://feeds.dzone.com/home', 'programming', 'en', 'Developer tutorials and news'),
('Lobsters', 'https://lobste.rs/rss', 'programming', 'en', 'Computing-focused link aggregator'),
('Changelog', 'https://changelog.com/feed', 'programming', 'en', 'Developer podcasts and news'),
('Hacker Noon', 'https://hackernoon.com/feed', 'programming', 'en', 'Tech and programming stories'),

-- French Programming Sources (4)
('Developpez.com', 'https://www.developpez.com/index/rss', 'programming', 'fr', 'Communaute francophone des developpeurs'),
('Human Coders News', 'https://news.humancoders.com/rss', 'programming', 'fr', 'Actualites developpement'),
('Programmez!', 'https://www.programmez.com/rss.xml', 'programming', 'fr', 'Magazine des developpeurs'),
('Le Blog du Hacker', 'https://www.leblogduhacker.fr/feed/', 'programming', 'fr', 'Tutoriels programmation et securite'),

-- =============================================================================
-- RSS SOURCES - Security (12 sources)
-- =============================================================================

-- English Security Sources (8)
('Krebs on Security', 'https://krebsonsecurity.com/feed/', 'security', 'en', 'Security news and investigation'),
('Schneier on Security', 'https://www.schneier.com/feed/', 'security', 'en', 'Security analysis and commentary'),
('The Hacker News', 'https://feeds.feedburner.com/TheHackersNews', 'security', 'en', 'Cybersecurity news'),
('Dark Reading', 'https://www.darkreading.com/rss.xml', 'security', 'en', 'Enterprise security news'),
('Threatpost', 'https://threatpost.com/feed/', 'security', 'en', 'Security news and analysis'),
('SecurityWeek', 'https://www.securityweek.com/feed/', 'security', 'en', 'Cybersecurity insights'),
('Naked Security', 'https://nakedsecurity.sophos.com/feed/', 'security', 'en', 'Security news by Sophos'),
('BleepingComputer', 'https://www.bleepingcomputer.com/feed/', 'security', 'en', 'Tech support and security'),

-- French Security Sources (4)
('ZATAZ', 'https://www.zataz.com/feed/', 'security', 'fr', 'Actualites cybersecurite'),
('CERT-FR', 'https://www.cert.ssi.gouv.fr/feed/', 'security', 'fr', 'Alertes securite officielles'),
('UnderNews', 'https://www.undernews.fr/feed', 'security', 'fr', 'Actualites securite informatique'),
('NoLimitSecu', 'https://www.nolimitsecu.fr/feed/', 'security', 'fr', 'Podcast securite informatique'),

-- =============================================================================
-- RSS SOURCES - Science (14 sources)
-- =============================================================================

-- English Science Sources (8)
('Nature', 'https://www.nature.com/nature.rss', 'science', 'en', 'Scientific research and news'),
('Science Daily', 'https://www.sciencedaily.com/rss/all.xml', 'science', 'en', 'Science news'),
('Phys.org', 'https://phys.org/rss-feed/', 'science', 'en', 'Physics and technology news'),
('New Scientist', 'https://www.newscientist.com/feed/home/', 'science', 'en', 'Science and technology news'),
('Scientific American', 'https://rss.sciam.com/ScientificAmerican-Global', 'science', 'en', 'Science news and analysis'),
('Quanta Magazine', 'https://www.quantamagazine.org/feed/', 'science', 'en', 'Math and science journalism'),
('Live Science', 'https://www.livescience.com/feeds/all', 'science', 'en', 'Science news and features'),
('Space.com', 'https://www.space.com/feeds/all', 'science', 'en', 'Space and astronomy news'),

-- French Science Sources (6)
('Futura Sciences', 'https://www.futura-sciences.com/rss/actualites.xml', 'science', 'fr', 'Sciences et technologies'),
('Science et Vie', 'https://www.science-et-vie.com/feed', 'science', 'fr', 'Magazine scientifique'),
('Pour la Science', 'https://www.pourlascience.fr/rss/actus.rss', 'science', 'fr', 'Actualites scientifiques'),
('CNRS Le Journal', 'https://lejournal.cnrs.fr/rss', 'science', 'fr', 'Recherche scientifique francaise'),
('La Recherche', 'https://www.larecherche.fr/rss.xml', 'science', 'fr', 'Actualites scientifiques'),
('Cite des Sciences', 'https://www.cite-sciences.fr/rss/', 'science', 'fr', 'Mediation scientifique'),

-- =============================================================================
-- RSS SOURCES - Business (14 sources)
-- =============================================================================

-- English Business Sources (8)
('Bloomberg Technology', 'https://feeds.bloomberg.com/technology/news.rss', 'business', 'en', 'Tech business news'),
('Reuters Technology', 'https://feeds.reuters.com/reuters/technologyNews', 'business', 'en', 'Tech business news'),
('Fortune Tech', 'https://fortune.com/feed/fortune-feeds/?id=3230629', 'business', 'en', 'Tech business analysis'),
('Business Insider Tech', 'https://www.businessinsider.com/tech?IR=C', 'business', 'en', 'Tech industry news'),
('Forbes Tech', 'https://www.forbes.com/tech/feed/', 'business', 'en', 'Technology and business'),
('Harvard Business Review', 'https://hbr.org/feed', 'business', 'en', 'Business insights'),
('Fast Company', 'https://www.fastcompany.com/rss', 'business', 'en', 'Business innovation'),
('Inc.', 'https://www.inc.com/rss', 'business', 'en', 'Entrepreneurship and startups'),

-- French Business Sources (6)
('Les Echos Tech', 'https://www.lesechos.fr/tech-medias/rss.xml', 'business', 'fr', 'Tech et business'),
('BFM Business', 'https://www.bfmtv.com/rss/tech/', 'business', 'fr', 'Actualites economiques tech'),
('Capital', 'https://www.capital.fr/rss', 'business', 'fr', 'Economie et finance'),
('Challenges', 'https://www.challenges.fr/rss.xml', 'business', 'fr', 'Economie et entreprises'),
('L''Usine Digitale', 'https://www.usine-digitale.fr/rss', 'business', 'fr', 'Transformation digitale'),
('La Tribune', 'https://www.latribune.fr/rss/rubriques/technos-medias.html', 'business', 'fr', 'Economie et tech'),

-- =============================================================================
-- RSS SOURCES - Startups (10 sources)
-- =============================================================================

-- English Startup Sources (6)
('Y Combinator Blog', 'https://www.ycombinator.com/blog/rss/', 'startup', 'en', 'YC startup insights'),
('a16z', 'https://a16z.com/feed/', 'startup', 'en', 'Tech and startup insights'),
('First Round Review', 'https://review.firstround.com/feed.xml', 'startup', 'en', 'Startup advice and insights'),
('Techstars Blog', 'https://www.techstars.com/blog/feed/', 'startup', 'en', 'Startup accelerator insights'),
('500 Startups', 'https://500.co/blog/feed/', 'startup', 'en', 'Startup ecosystem news'),
('Both Sides of the Table', 'https://bothsidesofthetable.com/feed', 'startup', 'en', 'VC perspectives'),

-- French Startup Sources (4)
('Maddyness', 'https://www.maddyness.com/feed/', 'startup', 'fr', 'Actualites startups francaises'),
('FrenchWeb', 'https://www.frenchweb.fr/feed', 'startup', 'fr', 'Tech et startups en France'),
('Frenchweb Magazine', 'https://magazine.frenchweb.fr/feed', 'startup', 'fr', 'Analyses startups'),
('Journal du Net Startups', 'https://www.journaldunet.com/ebusiness/rss/', 'startup', 'fr', 'Startups et e-business'),

-- =============================================================================
-- RSS SOURCES - Design (10 sources)
-- =============================================================================

-- English Design Sources (8)
('A List Apart', 'https://alistapart.com/main/feed/', 'design', 'en', 'Web design and development'),
('UX Collective', 'https://uxdesign.cc/feed', 'design', 'en', 'UX design articles'),
('Nielsen Norman Group', 'https://www.nngroup.com/feed/rss/', 'design', 'en', 'UX research and insights'),
('Dribbble Blog', 'https://dribbble.com/stories.rss', 'design', 'en', 'Design inspiration and stories'),
('Designmodo', 'https://designmodo.com/feed/', 'design', 'en', 'Web design resources'),
('Creative Bloq', 'https://www.creativebloq.com/feed', 'design', 'en', 'Art and design inspiration'),
('Webdesigner Depot', 'https://www.webdesignerdepot.com/feed/', 'design', 'en', 'Web design news'),
('UX Planet', 'https://uxplanet.org/feed', 'design', 'en', 'UX design resource'),

-- French Design Sources (2)
('Graphisme.com', 'https://graphisme.com/feed', 'design', 'fr', 'Actualites graphisme'),
('WebdesignerTrends', 'https://www.webdesignertrends.com/feed/', 'design', 'fr', 'Tendances webdesign')

ON CONFLICT (url) DO NOTHING;

-- =============================================================================
-- Verify seed data
-- =============================================================================

DO $$
DECLARE
    source_count INTEGER;
    fr_count INTEGER;
    en_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO source_count FROM public.rss_sources;
    SELECT COUNT(*) INTO fr_count FROM public.rss_sources WHERE language = 'fr';
    SELECT COUNT(*) INTO en_count FROM public.rss_sources WHERE language = 'en';
    RAISE NOTICE 'Seeded % RSS sources (% FR, % EN)', source_count, fr_count, en_count;
END $$;
