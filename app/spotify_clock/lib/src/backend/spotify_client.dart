import 'package:spotify_clock/src/backend/api_caller.dart';
import 'package:spotify_clock/src/data/track.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SpotifyClient {
  SpotifyClient();

  final apiCaller = ApiCaller();

  login() async {
    await Supabase.instance.client.auth.signInWithOAuth(Provider.spotify);
  }

  getAlbumUrl(String albumId) async {
    final uri = Uri.https('api.spotify.com', '/v1/albums/$albumId');

    Map<String, dynamic> response = await apiCaller.getFromUrl(uri);
    String albumUrl = response['images'][0]['url'].toString();
    return albumUrl;
  }

  Future<List<Track>> getTracksList(String name, int limit) async {
    final params = {
      'q': name,
      'type': 'track',
      'limit': limit.toString(),
    };

    final uri = Uri.https('api.spotify.com', '/v1/search', params);

    Map<String, dynamic> response = await apiCaller.getFromUrl(uri);
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
