-- ============================================
-- KAIROS - Tests Politiques RLS
-- ============================================
--
-- Ce script teste l'isolation des donnees entre utilisateurs
-- Executez-le dans psql ou via un client PostgreSQL
--
-- Prerequis: 2 utilisateurs de test doivent exister dans auth.users
-- ============================================

\echo '============================================'
\echo '   KAIROS - Tests RLS (Row Level Security)'
\echo '============================================'
\echo ''

-- Activer le mode verbose pour voir les erreurs
\set ON_ERROR_STOP on

-- ============================================
-- PREPARATION: Creer des donnees de test
-- ============================================

\echo '[PREP] Creation des donnees de test...'

-- Nettoyer les donnees de test precedentes
DELETE FROM articles WHERE source = 'RLS_TEST';
DELETE FROM topics WHERE topic_name LIKE 'RLS_TEST%';

-- Recuperer les IDs des utilisateurs de test (supposons qu'ils existent)
-- Si vous n'avez pas d'utilisateurs, creez-les d'abord via l'interface

DO $$
DECLARE
    user_a_id uuid;
    user_b_id uuid;
    topic_a_id uuid;
    topic_b_id uuid;
    article_a_id uuid;
    article_b_id uuid;
BEGIN
    -- Essayer de recuperer 2 utilisateurs existants
    SELECT id INTO user_a_id FROM auth.users ORDER BY created_at LIMIT 1;
    SELECT id INTO user_b_id FROM auth.users ORDER BY created_at OFFSET 1 LIMIT 1;

    IF user_a_id IS NULL THEN
        RAISE NOTICE 'ERREUR: Aucun utilisateur trouve. Creez au moins 2 utilisateurs via l''interface.';
        RETURN;
    END IF;

    IF user_b_id IS NULL THEN
        RAISE NOTICE 'ERREUR: Un seul utilisateur trouve. Creez un deuxieme utilisateur.';
        RETURN;
    END IF;

    RAISE NOTICE 'User A ID: %', user_a_id;
    RAISE NOTICE 'User B ID: %', user_b_id;

    -- Creer des topics de test pour chaque utilisateur
    INSERT INTO topics (id, user_id, topic_name, description, active)
    VALUES (gen_random_uuid(), user_a_id, 'RLS_TEST_Topic_A', 'Topic de User A', true)
    RETURNING id INTO topic_a_id;

    INSERT INTO topics (id, user_id, topic_name, description, active)
    VALUES (gen_random_uuid(), user_b_id, 'RLS_TEST_Topic_B', 'Topic de User B', true)
    RETURNING id INTO topic_b_id;

    RAISE NOTICE 'Topic A ID: %', topic_a_id;
    RAISE NOTICE 'Topic B ID: %', topic_b_id;

    -- Creer des articles de test
    INSERT INTO articles (id, user_id, topic_id, title, source, url)
    VALUES (gen_random_uuid(), user_a_id, topic_a_id, 'Article de User A', 'RLS_TEST', 'http://test-a.com')
    RETURNING id INTO article_a_id;

    INSERT INTO articles (id, user_id, topic_id, title, source, url)
    VALUES (gen_random_uuid(), user_b_id, topic_b_id, 'Article de User B', 'RLS_TEST', 'http://test-b.com')
    RETURNING id INTO article_b_id;

    RAISE NOTICE 'Article A ID: %', article_a_id;
    RAISE NOTICE 'Article B ID: %', article_b_id;

    RAISE NOTICE '';
    RAISE NOTICE '[OK] Donnees de test creees avec succes';

END $$;

\echo ''
\echo '============================================'
\echo '   TESTS RLS'
\echo '============================================'
\echo ''

-- ============================================
-- TEST 1: Verification que RLS est active
-- ============================================

\echo '[TEST 1] Verification que RLS est active sur les tables...'

SELECT
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN ('topics', 'articles');

-- ============================================
-- TEST 2: Compter les topics par utilisateur
-- ============================================

\echo ''
\echo '[TEST 2] Verification du nombre de topics de test par utilisateur...'

SELECT
    u.email,
    COUNT(t.id) as nb_topics
FROM auth.users u
LEFT JOIN topics t ON t.user_id = u.id AND t.topic_name LIKE 'RLS_TEST%'
GROUP BY u.id, u.email;

-- ============================================
-- TEST 3: Compter les articles par utilisateur
-- ============================================

\echo ''
\echo '[TEST 3] Verification du nombre d''articles de test par utilisateur...'

SELECT
    u.email,
    COUNT(a.id) as nb_articles
FROM auth.users u
LEFT JOIN articles a ON a.user_id = u.id AND a.source = 'RLS_TEST'
GROUP BY u.id, u.email;

-- ============================================
-- TEST 4: Verification des politiques existantes
-- ============================================

\echo ''
\echo '[TEST 4] Liste des politiques RLS sur topics...'

SELECT
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies
WHERE tablename = 'topics';

\echo ''
\echo '[TEST 5] Liste des politiques RLS sur articles...'

SELECT
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies
WHERE tablename = 'articles';

-- ============================================
-- NETTOYAGE
-- ============================================

\echo ''
\echo '[CLEANUP] Nettoyage des donnees de test...'

DELETE FROM articles WHERE source = 'RLS_TEST';
DELETE FROM topics WHERE topic_name LIKE 'RLS_TEST%';

\echo ''
\echo '============================================'
\echo '   TESTS TERMINES'
\echo '============================================'
\echo ''
\echo 'Pour tester l''isolation complete, utilisez l''interface web:'
\echo '1. Connectez-vous avec User A'
\echo '2. Creez un topic et des articles'
\echo '3. Deconnectez-vous'
\echo '4. Connectez-vous avec User B'
\echo '5. Verifiez que les donnees de User A ne sont pas visibles'
\echo ''
