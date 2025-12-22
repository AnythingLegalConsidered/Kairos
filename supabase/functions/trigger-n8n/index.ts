// =============================================================================
// KAIROS - Edge Function: Trigger n8n Workflow
// =============================================================================
// Description: Webhook to trigger n8n RSS processing workflow
// Endpoint: POST /functions/v1/trigger-n8n
// =============================================================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface TriggerPayload {
  topic_id?: string;  // Optional: trigger for specific topic
  force?: boolean;    // Optional: force refresh even if recently fetched
}

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Get environment variables
    const n8nWebhookUrl = Deno.env.get("N8N_WEBHOOK_URL");
    const n8nApiKey = Deno.env.get("N8N_API_KEY");
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!n8nWebhookUrl) {
      throw new Error("N8N_WEBHOOK_URL not configured");
    }

    // Parse request body
    let payload: TriggerPayload = {};
    if (req.method === "POST") {
      try {
        payload = await req.json();
      } catch {
        // Empty body is OK
      }
    }

    // Initialize Supabase client
    const supabase = createClient(supabaseUrl!, supabaseServiceKey!);

    // Get topics to process
    let query = supabase
      .from("topics")
      .select("id, name, user_id, keywords_fr, keywords_en, rss_feeds")
      .eq("active", true);

    if (payload.topic_id) {
      query = query.eq("id", payload.topic_id);
    }

    const { data: topics, error: topicsError } = await query;

    if (topicsError) {
      throw new Error(`Failed to fetch topics: ${topicsError.message}`);
    }

    if (!topics || topics.length === 0) {
      return new Response(
        JSON.stringify({
          success: true,
          message: "No active topics to process",
          topics_count: 0,
        }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 200,
        }
      );
    }

    // Trigger n8n webhook
    const n8nResponse = await fetch(n8nWebhookUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        ...(n8nApiKey && { "X-N8N-API-KEY": n8nApiKey }),
      },
      body: JSON.stringify({
        topics: topics,
        triggered_at: new Date().toISOString(),
        force: payload.force || false,
      }),
    });

    if (!n8nResponse.ok) {
      const errorText = await n8nResponse.text();
      throw new Error(`n8n webhook failed: ${n8nResponse.status} - ${errorText}`);
    }

    const n8nResult = await n8nResponse.json().catch(() => ({}));

    return new Response(
      JSON.stringify({
        success: true,
        message: `Triggered processing for ${topics.length} topic(s)`,
        topics_count: topics.length,
        n8n_response: n8nResult,
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      }
    );
  } catch (error) {
    console.error("Error in trigger-n8n:", error);

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
