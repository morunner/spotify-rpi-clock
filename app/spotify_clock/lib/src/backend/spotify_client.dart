import 'package:spotify_clock/src/backend/api_caller.dart';
import 'package:spotify_clock/src/data/device.dart';
import 'package:spotify_clock/src/data/track.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SpotifyClient {
  SpotifyClient();

  String spotifyApiBaseUrl = 'api.spotify.com';

  final apiCaller = ApiCaller();

  login() async {
    const scopes = 'user-read-playback-state';
    await Supabase.instance.client.auth
        .signInWithOAuth(Provider.spotify, scopes: scopes);
  }

  getAlbumUrl(String albumId) async {
    final uri = Uri.https(spotifyApiBaseUrl, '/v1/albums/$albumId');

    Map<String, dynamic> response = await apiCaller.getFromUrl(uri);
    String albumUrl = response['images'][0]['url'].toString();
    return albumUrl;
  }

  getTrack(String trackId) async {
    final uri = Uri.https(spotifyApiBaseUrl, '/v1/tracks/$trackId');

    Map<String, dynamic> response = await apiCaller.getFromUrl(uri);
    return Track(
      spotifyId: response['id'],
      title: response['name'],
      artist: response['artists'][0]['name'],
      album: response['album']['name'],
      coverUrl: response['album']['images'][0]['url'],
      playbackUri: response['uri'],
    );
  }

  Future<List<Track>> getTracksList(String name, int limit) async {
    final params = {
      'q': name,
      'type': 'track',
      'limit': limit.toString(),
    };

    final uri = Uri.https(spotifyApiBaseUrl, '/v1/search', params);

    Map<String, dynamic> response = await apiCaller.getFromUrl(uri);

    List<Track> tracks = [];
    for (var track in response['tracks']['items']) {
      Track t = Track(
        spotifyId: track['id'],
        title: track['name'],
        artist: track['artists'][0]['name'],
        album: track['album']['name'],
        playbackUri: track['uri'],
        coverUrl: track['album']['images'][0]['url'],
      );
      tracks.add(t);
    }
    return tracks;
  }

  Future<List<Device>> getAvailableDevices() async {
    final uri = Uri.https(spotifyApiBaseUrl, '/v1/me/player/devices');

    Map<String, dynamic> response = await apiCaller.getFromUrl(uri);
    List<Device> availableDevices = [];

    for (var device in response['devices']) {
      Device d = Device(
          spotifyId: device['id'],
          name: device['name'],
          volumePercent: device['volume_percent']);
      availableDevices.add(d);
    }
    return availableDevices;
  }
}
