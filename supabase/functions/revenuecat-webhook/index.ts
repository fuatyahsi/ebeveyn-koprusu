import { corsHeaders, jsonResponse, readJson } from "../_shared/http.ts";
import { serviceClient } from "../_shared/supabase.ts";

type RevenueCatPayload = {
  event?: {
    app_user_id?: string;
    entitlement_ids?: string[];
    product_id?: string;
    type?: string;
    expiration_at_ms?: number;
    purchased_at_ms?: number;
  };
};

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const secret = Deno.env.get("REVENUECAT_WEBHOOK_SECRET");
  const received = request.headers.get("x-revenuecat-signature");
  if (secret && received !== secret) {
    return jsonResponse({ error: "invalid_signature" }, 401);
  }

  const payload = await readJson<RevenueCatPayload>(request);
  const event = payload.event ?? {};
  const userId = event.app_user_id;
  const entitlement = event.entitlement_ids?.[0] ?? "plus_access";

  if (!userId) {
    return jsonResponse({ error: "missing_app_user_id" }, 400);
  }

  const status = mapStatus(event.type);
  const supabase = serviceClient();
  const { error } = await supabase.from("subscriptions").insert({
    user_id: userId,
    provider: "revenuecat",
    entitlement,
    status,
    product_id: event.product_id,
    current_period_start: event.purchased_at_ms
      ? new Date(event.purchased_at_ms).toISOString()
      : null,
    current_period_end: event.expiration_at_ms
      ? new Date(event.expiration_at_ms).toISOString()
      : null,
    raw_payload: payload,
  });

  if (error) {
    return jsonResponse({ error: error.message }, 500);
  }

  return jsonResponse({ ok: true, entitlement, status });
});

function mapStatus(type?: string): string {
  switch (type) {
    case "INITIAL_PURCHASE":
    case "RENEWAL":
    case "PRODUCT_CHANGE":
      return "active";
    case "CANCELLATION":
      return "cancelled";
    case "EXPIRATION":
      return "expired";
    case "BILLING_ISSUE":
      return "past_due";
    default:
      return "unknown";
  }
}
