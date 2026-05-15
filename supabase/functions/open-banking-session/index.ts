import { corsHeaders, jsonResponse, readJson } from "../_shared/http.ts";

type OpenBankingSessionRequest = {
  family_id?: string;
  return_path?: string;
  scope?: string[];
};

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const body = await readJson<OpenBankingSessionRequest>(request);
  const provider = Deno.env.get("OPEN_BANKING_PROVIDER") ?? "";
  const clientId = Deno.env.get("OPEN_BANKING_CLIENT_ID") ?? "";
  const redirectUri = Deno.env.get("OPEN_BANKING_REDIRECT_URI") ?? "";
  const authorizationUrl = Deno.env.get("OPEN_BANKING_AUTHORIZATION_URL") ?? "";

  const missing = [
    ["OPEN_BANKING_PROVIDER", provider],
    ["OPEN_BANKING_CLIENT_ID", clientId],
    ["OPEN_BANKING_REDIRECT_URI", redirectUri],
    ["OPEN_BANKING_AUTHORIZATION_URL", authorizationUrl],
  ]
    .filter(([, value]) => !value)
    .map(([key]) => key);

  if (missing.length > 0) {
    return jsonResponse(
      {
        configured: false,
        error: "open_banking_provider_not_configured",
        required_secrets: missing,
      },
      409,
    );
  }

  const state = crypto.randomUUID();
  const url = new URL(authorizationUrl);
  url.searchParams.set("client_id", clientId);
  url.searchParams.set("redirect_uri", redirectUri);
  url.searchParams.set("response_type", "code");
  url.searchParams.set("state", state);
  url.searchParams.set("scope", (body.scope ?? ["accounts", "transactions"]).join(" "));

  return jsonResponse({
    configured: true,
    provider,
    family_id: body.family_id,
    state,
    authorization_url: url.toString(),
    return_path: body.return_path ?? "/visionary/banking",
  });
});
