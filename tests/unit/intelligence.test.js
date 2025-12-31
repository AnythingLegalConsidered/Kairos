// tests/unit/intelligence.test.js
// Purpose: Unit tests for KairosIntelligence module
// Coverage: trending, similar articles, personalized scoring, rendering

import { describe, it, expect, beforeEach, vi } from 'vitest';
import fs from 'fs';
import path from 'path';

describe('KairosIntelligence', () => {
  let KairosIntelligence;
  let mockSupabase;

  beforeEach(() => {
    // Clean DOM
    document.body.innerHTML = '';

    // Load intelligence.js
    const code = fs.readFileSync(
      path.join(process.cwd(), 'web', 'intelligence.js'),
      'utf-8'
    );
    eval(code);

    KairosIntelligence = window.KairosIntelligence;

    // Mock Supabase client
    mockSupabase = {
      rpc: vi.fn()
    };
  });

  describe('isArticleTrending', () => {
    it('should return true if article has trending tag', () => {
      KairosIntelligence.trendingTags = [
        { tag: 'AI', is_trending: true },
        { tag: 'React', is_trending: true }
      ];

      expect(KairosIntelligence.isArticleTrending(['AI', 'JavaScript'])).toBe(true);
    });

    it('should return false if no trending tags match', () => {
      KairosIntelligence.trendingTags = [
        { tag: 'AI', is_trending: true }
      ];

      expect(KairosIntelligence.isArticleTrending(['JavaScript', 'Node'])).toBe(false);
    });

    it('should return false for empty article tags', () => {
      KairosIntelligence.trendingTags = [{ tag: 'AI', is_trending: true }];

      expect(KairosIntelligence.isArticleTrending([])).toBe(false);
      expect(KairosIntelligence.isArticleTrending(null)).toBe(false);
    });
  });

  describe('getTrendingBadge', () => {
    it('should return trending badge HTML when article is trending', () => {
      KairosIntelligence.trendingTags = [{ tag: 'AI', is_trending: true }];

      const badge = KairosIntelligence.getTrendingBadge(['AI']);
      expect(badge).toContain('trending-badge');
      expect(badge).toContain('Trending');
    });

    it('should return empty string when article is not trending', () => {
      KairosIntelligence.trendingTags = [{ tag: 'AI', is_trending: true }];

      const badge = KairosIntelligence.getTrendingBadge(['JavaScript']);
      expect(badge).toBe('');
    });
  });

  describe('getPersonalizedScore', () => {
    beforeEach(() => {
      KairosIntelligence.userTopTags = [
        { tag: 'AI' },
        { tag: 'React' },
        { tag: 'TypeScript' }
      ];
    });

    it('should boost score when article tags match user preferences', () => {
      const baseScore = 70;
      const score = KairosIntelligence.getPersonalizedScore(baseScore, ['AI', 'React']);

      expect(score).toBe(80); // 70 + 5 + 5 = 80
    });

    it('should cap boost at 15 points', () => {
      const baseScore = 70;
      const score = KairosIntelligence.getPersonalizedScore(baseScore, ['AI', 'React', 'TypeScript', 'Node']);

      expect(score).toBe(85); // 70 + 15 (capped) = 85
    });

    it('should not exceed 100', () => {
      const baseScore = 95;
      const score = KairosIntelligence.getPersonalizedScore(baseScore, ['AI', 'React', 'TypeScript']);

      expect(score).toBe(100);
    });

    it('should return base score if no matching tags', () => {
      const baseScore = 70;
      const score = KairosIntelligence.getPersonalizedScore(baseScore, ['Python', 'Django']);

      expect(score).toBe(70);
    });

    it('should return base score if no user tags', () => {
      KairosIntelligence.userTopTags = [];
      const score = KairosIntelligence.getPersonalizedScore(70, ['AI']);

      expect(score).toBe(70);
    });

    it('should return base score if no article tags', () => {
      const score = KairosIntelligence.getPersonalizedScore(70, null);
      expect(score).toBe(70);

      const score2 = KairosIntelligence.getPersonalizedScore(70, []);
      expect(score2).toBe(70);
    });
  });

  describe('renderTrendingWidget', () => {
    it('should render empty state when no trending tags', () => {
      KairosIntelligence.trendingTags = [];

      const html = KairosIntelligence.renderTrendingWidget();
      expect(html).toContain('trending-empty');
      expect(html).toContain('Pas de tendance');
    });

    it('should render trending tags', () => {
      KairosIntelligence.trendingTags = [
        { tag: 'AI', occurrence_count: 10, is_trending: true },
        { tag: 'React', occurrence_count: 8, is_trending: true }
      ];

      const html = KairosIntelligence.renderTrendingWidget();
      expect(html).toContain('trending-tags');
      expect(html).toContain('#AI');
      expect(html).toContain('#React');
      expect(html).toContain('10');
    });

    it('should limit to 8 tags', () => {
      KairosIntelligence.trendingTags = Array(10).fill(null).map((_, i) => ({
        tag: `tag${i}`,
        occurrence_count: 10 - i,
        is_trending: true
      }));

      const html = KairosIntelligence.renderTrendingWidget();
      // Match class="trending-tag" (with quotes) to avoid matching trending-tags container
      const matches = html.match(/class="trending-tag"/g) || [];
      expect(matches.length).toBeLessThanOrEqual(8);
    });
  });

  describe('renderSimilarArticles', () => {
    it('should return empty string for no articles', () => {
      expect(KairosIntelligence.renderSimilarArticles(null)).toBe('');
      expect(KairosIntelligence.renderSimilarArticles([])).toBe('');
    });

    it('should render similar articles list', () => {
      const articles = [
        {
          id: '123',
          title: 'Test Article',
          source_name: 'TechCrunch',
          common_tags: ['AI', 'ML']
        }
      ];

      const html = KairosIntelligence.renderSimilarArticles(articles);
      expect(html).toContain('similar-articles-section');
      expect(html).toContain('Test Article');
      expect(html).toContain('TechCrunch');
      expect(html).toContain('article-detail.html?id=123');
    });

    it('should limit common tags to 3', () => {
      const articles = [
        {
          id: '123',
          title: 'Test',
          source_name: 'Source',
          common_tags: ['Tag1', 'Tag2', 'Tag3', 'Tag4', 'Tag5']
        }
      ];

      const html = KairosIntelligence.renderSimilarArticles(articles);
      const tagMatches = html.match(/similar-tag/g) || [];
      expect(tagMatches.length).toBe(3);
    });
  });

  describe('renderHighlights', () => {
    it('should return empty string for no highlights', () => {
      expect(KairosIntelligence.renderHighlights(null)).toBe('');
      expect(KairosIntelligence.renderHighlights([])).toBe('');
    });

    it('should render highlights list', () => {
      const highlights = [
        'Key point 1',
        'Key point 2'
      ];

      const html = KairosIntelligence.renderHighlights(highlights);
      expect(html).toContain('highlights-section');
      expect(html).toContain('Points cles');
      expect(html).toContain('Key point 1');
      expect(html).toContain('Key point 2');
    });
  });

  describe('loadTrendingTags', () => {
    it('should load trending tags from Supabase', async () => {
      mockSupabase.rpc.mockResolvedValue({
        data: [
          { tag: 'AI', occurrence_count: 10, is_trending: true },
          { tag: 'React', occurrence_count: 5, is_trending: false }
        ],
        error: null
      });

      KairosIntelligence.supabase = mockSupabase;
      await KairosIntelligence.loadTrendingTags();

      expect(mockSupabase.rpc).toHaveBeenCalledWith('get_trending_tags', {
        hours_window: 24,
        min_occurrences: 3
      });

      // Only trending tags should be stored
      expect(KairosIntelligence.trendingTags).toHaveLength(1);
      expect(KairosIntelligence.trendingTags[0].tag).toBe('AI');
    });

    it('should handle errors gracefully', async () => {
      mockSupabase.rpc.mockResolvedValue({
        data: null,
        error: { message: 'Database error' }
      });

      KairosIntelligence.supabase = mockSupabase;
      await KairosIntelligence.loadTrendingTags();

      expect(KairosIntelligence.trendingTags).toEqual([]);
    });
  });

  describe('getSimilarArticles', () => {
    it('should fetch similar articles from Supabase', async () => {
      const mockArticles = [
        { id: '1', title: 'Similar 1' },
        { id: '2', title: 'Similar 2' }
      ];

      mockSupabase.rpc.mockResolvedValue({
        data: mockArticles,
        error: null
      });

      KairosIntelligence.supabase = mockSupabase;
      const result = await KairosIntelligence.getSimilarArticles('test-id', 5);

      expect(mockSupabase.rpc).toHaveBeenCalledWith('get_similar_articles', {
        article_uuid: 'test-id',
        limit_count: 5
      });

      expect(result).toEqual(mockArticles);
    });

    it('should return empty array on error', async () => {
      mockSupabase.rpc.mockResolvedValue({
        data: null,
        error: { message: 'Error' }
      });

      KairosIntelligence.supabase = mockSupabase;
      const result = await KairosIntelligence.getSimilarArticles('test-id');

      expect(result).toEqual([]);
    });
  });
});
