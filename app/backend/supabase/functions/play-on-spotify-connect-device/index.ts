// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import * as base64 from "https://deno.land/std@0.194.0/encoding/base64.ts";

console.log("Hello from Functions!")

const spotifyClientId = Deno.env.get("SPOTIFY_CLIENT_ID") as string;
const spotifyClientSecret = Deno.env.get("SPOTIFY_CLIENT_SECRET") as string;

serve(async (req) => {
  const { track_id, device_id, provider_refresh_token } = await req.json()
  const data = {
    track_id: track_id,
    device_id: device_id,
    provider_refresh_token: provider_refresh_token,
  }

  fetchSpotifyAccessToken(provider_refresh_token).then((resp) => console.log(resp));

  return new Response(
    JSON.stringify(data),
    { headers: { "Content-Type": "application/json" } },
  )
})

async function fetchSpotifyAccessToken(provider_refresh_token: string) {
  const url = 'https://accounts.spotify.com/api/token';
  const headers = { 
    'Authorization': 'Basic ' + base64.encode(spotifyClientId + ':' + spotifyClientSecret).toString(),
    'Content-Type': 'application/x-www-form-urlencoded',
  };
  const form = new URLSearchParams({
    grant_type: 'refresh_token',
    refresh_token: provider_refresh_token,
  });

  const resp = await fetch(url, {
    method: 'POST',
    headers: headers,
    body: form,
  });

  return await resp.json();
}

// To invoke:
// curl -i --location --request POST 'http://localhost:54321/functions/v1/' \
//   --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
//   --header 'Content-Type: application/json' \
//   --data '{"name":"Functions"}'
