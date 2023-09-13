// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import * as base64 from "https://deno.land/std@0.194.0/encoding/base64.ts";

const spotifyClientId = Deno.env.get("SPOTIFY_CLIENT_ID") as string;
const spotifyClientSecret = Deno.env.get("SPOTIFY_CLIENT_SECRET") as string;

serve(async (req) => {
  const { track_id, device_id, provider_refresh_token } = await req.json()
  const data = {
    track_id: track_id,
    device_id: device_id,
    provider_refresh_token: provider_refresh_token,
  }
  const provider_access_token = await fetchSpotifyAccessToken(provider_refresh_token);
  await playOnSpotify(track_id, device_id, provider_access_token);

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

  const data = await resp.json();
  return data['access_token'];
}

async function getContextUriOffsetFromTrackId(track_id: string, provider_access_token: string) {
  const url = `https://api.spotify.com/v1/tracks/${track_id}`;
  const headers = {
    'Content-Type': 'application/json',
    "Authorization": 'Bearer ' + provider_access_token,
  };
  const resp = await fetch(url, {
    headers: headers,
  });
  const data = await resp.json();
  
  return { context_uri: data['album']['uri'], offset: data['track_number']-1 };
}

async function playOnSpotify(track_id: string, device_id: string, provider_access_token: string) {
  const url = 'https://api.spotify.com/v1/me/player/play';
  const headers = {
    'Content-Type': 'application/json',
    "Authorization": 'Bearer ' + provider_access_token,
  };
  const { context_uri, offset } = await getContextUriOffsetFromTrackId(track_id, provider_access_token);
  const position_ms = 0;
  const body = {
    context_uri: context_uri,
    offset: { position: offset },
    position_ms: position_ms.toString(),
  };
  const resp = await fetch(url + `/?device_id=${device_id}`, {
    method: 'PUT',
    headers: headers,
    body: JSON.stringify(body),
  });
}