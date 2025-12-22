-- =============================================================================
-- KAIROS - Notification Logs Table
-- =============================================================================
-- Migration: 004_notification_logs.sql
-- Description: Table for tracking notification history (used by n8n workflows)
-- =============================================================================

-- =============================================================================
-- TABLE: notification_logs
-- =============================================================================
-- Logs all notifications sent by the system

CREATE TABLE IF NOT EXISTS public.notification_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Notification type
    type VARCHAR(50) NOT NULL,  -- 'daily_digest', 'urgent_alert', 'weekly_summary'

    -- Recipient (optional - for user-specific notifications)
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,

    -- Notification details
    articles_count INTEGER DEFAULT 0,
    subject TEXT,

    -- Status
    success BOOLEAN DEFAULT true,
    error_message TEXT,

    -- Timestamps
    sent_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for notification_logs
CREATE INDEX idx_notification_logs_type ON public.notification_logs(type);
CREATE INDEX idx_notification_logs_user_id ON public.notification_logs(user_id);
CREATE INDEX idx_notification_logs_sent_at ON public.notification_logs(sent_at DESC);
CREATE INDEX idx_notification_logs_success ON public.notification_logs(success);

-- =============================================================================
-- RLS POLICIES FOR: notification_logs
-- =============================================================================

ALTER TABLE public.notification_logs ENABLE ROW LEVEL SECURITY;

-- SELECT: Users can view their own notification logs
CREATE POLICY "Users can view their own notification logs"
    ON public.notification_logs
    FOR SELECT
    USING (user_id = auth.uid() OR user_id IS NULL);

-- INSERT: Service role can insert notification logs (via n8n)
CREATE POLICY "Service role can insert notification logs"
    ON public.notification_logs
    FOR INSERT
    WITH CHECK (auth.jwt()->>'role' = 'service_role');

-- DELETE: Service role can delete old logs
CREATE POLICY "Service role can delete notification logs"
    ON public.notification_logs
    FOR DELETE
    USING (auth.jwt()->>'role' = 'service_role');

-- =============================================================================
-- GRANT PERMISSIONS
-- =============================================================================

GRANT SELECT ON public.notification_logs TO authenticated;
GRANT ALL ON public.notification_logs TO service_role;

-- =============================================================================
-- COMMENTS
-- =============================================================================

COMMENT ON TABLE public.notification_logs IS 'Logs of all notifications sent by the system';
COMMENT ON COLUMN public.notification_logs.type IS 'Type of notification: daily_digest, urgent_alert, weekly_summary';
