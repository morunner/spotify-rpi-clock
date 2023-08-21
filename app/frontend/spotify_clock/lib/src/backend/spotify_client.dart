import 'package:spotify_clock/src/backend/api_caller.dart';
import 'package:spotify_clock/src/backend/track.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SpotifyClient {
  SpotifyClient();

  final apiCaller = ApiCaller();

  login() async {
    await Supabase.instance.client.auth.signInWithOAuth(Provider.spotify);
  }

  getAlbumUrl(String album_id) async {
    Map<String, dynamic> response = await apiCaller
        .getFromUrl('https://api.spotify.com/v1/albums/$album_id');
    String album_url = response['images'][0]['url'].toString();
    return album_url;
  }

  Future<List<Track>> getTracksList(String name, int limit) async {
    Map<String, dynamic> response = await apiCaller.getFromUrl(
        'https://api.spotify.com/v1/search?q=$name&type=track&limit=$limit');
    List<Track> tracks = [];
    for (var track in response['tracks']['items']) {
      Track t = Track(
        name: track['name'],
        artist: track['artists'][0]['name'],
        album: track['album']['name'],
        id: track['id'],
        playbackUri: track['uri'],
        coverUrl: track['album']['images'][0]['url'],
      );
      tracks.add(t);
    }
    return tracks;
  }
}