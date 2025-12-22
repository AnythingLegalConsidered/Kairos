// =============================================================================
// KAIROS - Edge Function: Cleanup Old Articles
// =============================================================================
// Description: Removes old articles to keep the database clean
// Endpoint: POST /functions/v1/cleanup-articles
// Schedule: Can be triggered via cron or manually
// =============================================================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface CleanupPayload {
  days_to_keep?: number;     // Default: 30 days
  dry_run?: boolean;         // If true, only report what would be deleted
  include_bookmarked?: boolean;  // Default: false (preserve bookmarked articles)
}

interface CleanupResult {
  success: boolean;
  dry_run: boolean;
  articles_deleted: number;
  articles_archived: number;
  space_freed_estimate: string;
  details: {
    by_topic: Record<string, number>;
    oldest_deleted?: string;
    newest_deleted?: string;
  };
}

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Verify authorization (only service role or admin should call this)
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "Missing authorization header" }),
        { headers: corsHeaders, status: 401 }
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    // Parse request body
    let payload: CleanupPayload = {};
    if (req.method === "POST") {
      try {
        payload = await req.json();
      } catch {
        // Empty body is OK, use defaults
      }
    }

    const daysToKeep = payload.days_to_keep || 30;
    const dryRun = payload.dry_run || false;
    const includeBookmarked = payload.include_bookmarked || false;

    // Initialize Supabase client with service role
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Calculate cutoff date
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - daysToKeep);
    const cutoffISO = cutoffDate.toISOString();

    // First, get statistics about what will be deleted
    let countQuery = supabase
      .from("articles")
      .select("id, topic_id, created_at, bookmarked", { count: "exact" })
      .lt("created_at", cutoffISO);

    if (!includeBookmarked) {
      countQuery = countQuery.eq("bookmarked", false);
    }

    const { data: articlesToDelete, count, error: countError } = await countQuery;

    if (countError) {
      throw new Error(`Failed to count articles: ${countError.message}`);
    }

    // Calculate by-topic breakdown
    const byTopic: Record<string, number> = {};
    let oldestDate: string | undefined;
    let newestDate: string | undefined;

    if (articlesToDelete) {
      for (const article of articlesToDelete) {
        const topicId = article.topic_id;
        byTopic[topicId] = (byTopic[topicId] || 0) + 1;

        if (!oldestDate || article.created_at < oldestDate) {
          oldestDate = article.created_at;
        }
        if (!newestDate || article.created_at > newestDate) {
          newestDate = article.created_at;
        }
      }
    }

    // Estimate space freed (rough estimate: ~2KB per article average)
    const estimatedBytes = (count || 0) * 2048;
    const spaceFreeEstimate = estimatedBytes > 1048576
      ? `${(estimatedBytes / 1048576).toFixed(2)} MB`
      : `${(estimatedBytes / 1024).toFixed(2)} KB`;

    // If dry run, just return the statistics
    if (dryRun) {
      const result: CleanupResult = {
        success: true,
        dry_run: true,
        articles_deleted: 0,
        articles_archived: 0,
        space_freed_estimate: spaceFreeEstimate,
        details: {
          by_topic: byTopic,
          oldest_deleted: oldestDate,
          newest_deleted: newestDate,
        },
      };

      return new Response(
        JSON.stringify({
          ...result,
          message: `DRY RUN: Would delete ${count} articles older than ${daysToKeep} days`,
          would_delete: count,
        }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 200,
        }
      );
    }

    // Perform actual deletion
    let deleteQuery = supabase
      .from("articles")
      .delete()
      .lt("created_at", cutoffISO);

    if (!includeBookmarked) {
      deleteQuery = deleteQuery.eq("bookmarked", false);
    }

    const { error: deleteError } = await deleteQuery;

    if (deleteError) {
      throw new Error(`Failed to delete articles: ${deleteError.message}`);
    }

    // Log the cleanup action
    console.log(`Cleanup completed: Deleted ${count} articles older than ${daysToKeep} days`);

    const result: CleanupResult = {
      success: true,
      dry_run: false,
      articles_deleted: count || 0,
      articles_archived: 0,  // Future: implement archiving
      space_freed_estimate: spaceFreeEstimate,
      details: {
        by_topic: byTopic,
        oldest_deleted: oldestDate,
        newest_deleted: newestDate,
      },
    };

    return new Response(
      JSON.stringify({
        ...result,
        message: `Successfully deleted ${count} articles older than ${daysToKeep} days`,
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      }
    );
  } catch (error) {
    console.error("Error in cleanup-articles:", error);

    return new Response(
      JSON.stringify({
        success: false,
        error: error.message,
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 500,
      }
    );
  }
});
