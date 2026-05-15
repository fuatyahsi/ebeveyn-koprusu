import { corsHeaders, jsonResponse, readJson } from "../_shared/http.ts";

type CreateCallTokenRequest = {
  channel_name?: string;
  uid?: string;
};

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const body = await readJson<CreateCallTokenRequest>(request);
  const provider = Deno.env.get("RTC_PROVIDER") ?? "";
  const agoraAppId = Deno.env.get("AGORA_APP_ID") ?? "";
  const agoraCertificate = Deno.env.get("AGORA_APP_CERTIFICATE") ?? "";
  const twilioSid = Deno.env.get("TWILIO_ACCOUNT_SID") ?? "";
  const twilioKeySid = Deno.env.get("TWILIO_API_KEY_SID") ?? "";
  const twilioKeySecret = Deno.env.get("TWILIO_API_KEY_SECRET") ?? "";

  if (provider === "mock") {
    return jsonResponse({
      provider,
      channel_name: body.channel_name ?? crypto.randomUUID(),
      uid: body.uid ?? "local-user",
      token: `mock.${crypto.randomUUID()}`,
      expires_in: 3600,
    });
  }

  if (
    !provider ||
    (provider === "agora" && (!agoraAppId || !agoraCertificate)) ||
    (provider === "twilio" && (!twilioSid || !twilioKeySid || !twilioKeySecret))
  ) {
    return jsonResponse(
      {
        error: "rtc_provider_not_configured",
        required_secrets: [
          "RTC_PROVIDER",
          "AGORA_APP_ID",
          "AGORA_APP_CERTIFICATE",
          "TWILIO_ACCOUNT_SID",
          "TWILIO_API_KEY_SID",
          "TWILIO_API_KEY_SECRET",
        ],
      },
      409,
    );
  }

  return jsonResponse(
    {
      error: "provider_token_builder_pending",
      provider,
      note:
        "Provider account is configured. Add the official Agora/Twilio token builder before enabling live calls.",
    },
    501,
  );
});
