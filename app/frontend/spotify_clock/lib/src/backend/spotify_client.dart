import 'dart:developer';

import 'package:spotify_clock/src/backend/api_caller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SpotifyClient {
  SpotifyClient();

  final apiCaller = ApiCaller();

  login() async {
    await Supabase.instance.client.auth.signInWithOAuth(Provider.spotify);
  }

  getAlbumUrl(String album_id) async {
    String album_url = await apiCaller
        .getFromUrl('https://api.spotify.com/v1/albums/$album_id');
    log(album_url);
  }
}
