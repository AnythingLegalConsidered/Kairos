// intelligence.js - Kairos v0.4.0 Intelligence Avancee
// Fonctionnalites: Tendances, Articles similaires, Highlights, Scoring personnalise

const KairosIntelligence = {
    trendingTags: [],
    userTopTags: [],

    // Initialisation
    async init(supabaseClient) {
        this.supabase = supabaseClient;
        await this.loadTrendingTags();
        await this.loadUserTopTags();
    },

    // Charger les tags tendance (24h)
    async loadTrendingTags() {
        try {
            const { data, error } = await this.supabase.rpc('get_trending_tags', {
                hours_window: 24,
                min_occurrences: 3
            });

            if (error) {
                console.warn('[Kairos Intelligence] Trending tags not available:', error.message);
                this.trendingTags = [];
                return;
            }

            this.trendingTags = (data || []).filter(t => t.is_trending);
            console.log('[Kairos Intelligence] Loaded trending tags:', this.trendingTags.length);
        } catch (e) {
            console.warn('[Kairos Intelligence] Error loading trending tags:', e);
            this.trendingTags = [];
        }
    },

    // Charger les tags preferes de l'utilisateur
    async loadUserTopTags() {
        try {
            const { data, error } = await this.supabase.rpc('get_user_top_tags', {
                limit_count: 20
            });

            if (error) {
                console.warn('[Kairos Intelligence] User tags not available:', error.message);
                this.userTopTags = [];
                return;
            }

            this.userTopTags = data || [];
            console.log('[Kairos Intelligence] Loaded user top tags:', this.userTopTags.length);
        } catch (e) {
            console.warn('[Kairos Intelligence] Error loading user tags:', e);
            this.userTopTags = [];
        }
    },

    // Generer le HTML du widget de tendances
    renderTrendingWidget() {
        if (this.trendingTags.length === 0) {
            return `
                <div class="trending-widget" id="trendingWidget">
                    <div class="trending-header">
                        <span>Tendances (24h)</span>
                    </div>
                    <div class="trending-empty">Pas de tendance detectee pour le moment</div>
                </div>
            `;
        }

        const tagsHtml = this.trendingTags.slice(0, 8).map(t => `
            <span class="trending-tag" onclick="filterByTag('${t.tag.replace(/'/g, "\\'")}')">
                #${t.tag}
                <span class="trend-count">${t.occurrence_count}</span>
            </span>
        `).join('');

        return `
            <div class="trending-widget" id="trendingWidget">
                <div class="trending-header">
                    <span>Tendances (24h)</span>
                </div>
                <div class="trending-tags">
                    ${tagsHtml}
                </div>
            </div>
        `;
    },

    // Verifier si un article est trending
    isArticleTrending(articleTags) {
        if (!articleTags || articleTags.length === 0) return false;
        const trendingTagNames = this.trendingTags.map(t => t.tag);
        return articleTags.some(tag => trendingTagNames.includes(tag));
    },

    // Generer le badge trending pour un article
    getTrendingBadge(articleTags) {
        if (this.isArticleTrending(articleTags)) {
            return '<span class="trending-badge">Trending</span>';
        }
        return '';
    },

    // Calculer le score personnalise
    getPersonalizedScore(baseScore, articleTags) {
        if (!articleTags || articleTags.length === 0) return baseScore;
        if (this.userTopTags.length === 0) return baseScore;

        const userTagNames = this.userTopTags.map(t => t.tag);
        let boost = 0;

        articleTags.forEach(tag => {
            if (userTagNames.includes(tag)) {
                boost += 5;
            }
        });

        // Max boost de 15 points
        boost = Math.min(boost, 15);
        return Math.min(baseScore + boost, 100);
    },

    // Charger les articles similaires
    async getSimilarArticles(articleId, limit = 5) {
        try {
            const { data, error } = await this.supabase.rpc('get_similar_articles', {
                article_uuid: articleId,
                limit_count: limit
            });

            if (error) {
                console.warn('[Kairos Intelligence] Similar articles not available:', error.message);
                return [];
            }

            return data || [];
        } catch (e) {
            console.warn('[Kairos Intelligence] Error loading similar articles:', e);
            return [];
        }
    },

    // Generer le HTML des articles similaires
    renderSimilarArticles(articles) {
        if (!articles || articles.length === 0) {
            return '';
        }

        const articlesHtml = articles.map(article => {
            const commonTags = article.common_tags || [];
            const tagsHtml = commonTags.slice(0, 3).map(t => `<span class="similar-tag">${t}</span>`).join('');

            return `
                <a href="article-detail.html?id=${article.id}" class="similar-article-item">
                    <div class="similar-article-title">${article.title}</div>
                    <div class="similar-article-meta">
                        <span class="similar-source">${article.source_name || 'Source'}</span>
                        ${tagsHtml}
                    </div>
                </a>
            `;
        }).join('');

        return `
            <div class="similar-articles-section">
                <h3>Articles similaires</h3>
                <div class="similar-articles-list">
                    ${articlesHtml}
                </div>
            </div>
        `;
    },

    // Generer le HTML des highlights
    renderHighlights(highlights) {
        if (!highlights || highlights.length === 0) {
            return '';
        }

        const highlightsHtml = highlights.map(h => `
            <li class="highlight-item">${h}</li>
        `).join('');

        return `
            <div class="highlights-section">
                <h3>Points cles</h3>
                <ul class="highlights-list">
                    ${highlightsHtml}
                </ul>
            </div>
        `;
    }
};

// Export pour utilisation globale
window.KairosIntelligence = KairosIntelligence;
