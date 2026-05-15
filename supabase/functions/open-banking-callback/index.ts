import { corsHeaders, jsonResponse, readJson } from "../_shared/http.ts";

type OpenBankingCallbackRequest = {
  code?: string;
  state?: string;
  error?: string;
};

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const body = request.method === "GET"
    ? Object.fromEntries(new URL(request.url).searchParams.entries())
    : await readJson<OpenBankingCallbackRequest>(request);

  if (body.error) {
    return jsonResponse({ ok: false, error: body.error }, 400);
  }

  const tokenUrl = Deno.env.get("OPEN_BANKING_TOKEN_URL") ?? "";
  const clientSecret = Deno.env.get("OPEN_BANKING_CLIENT_SECRET") ?? "";
  if (!tokenUrl || !clientSecret) {
    return jsonResponse(
      {
        ok: false,
        error: "open_banking_token_exchange_not_configured",
        required_secrets: [
          "OPEN_BANKING_TOKEN_URL",
          "OPEN_BANKING_CLIENT_SECRET",
        ],
      },
      409,
    );
  }

  return jsonResponse({
    ok: true,
    state: body.state,
    code_received: Boolean(body.code),
    next: "exchange_code_with_provider_specific_contract",
  });
});
