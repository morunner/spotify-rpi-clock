import 'package:supabase_flutter/supabase_flutter.dart';

class SpotifyClient {
  SpotifyClient() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      onAuthStateChangedListeHandler(data);
    });
  }

  final _base_address = 'https://api.spotify.com';
  String _access_token = '';
  bool _signed_in = false;

  login() async {
    await Supabase.instance.client.auth.signInWithOAuth(Provider.spotify);
  }

  onAuthStateChangedListeHandler(data) {
    if (data.event == AuthChangeEvent.signedIn ||
        data.event == AuthChangeEvent.tokenRefreshed) {
      _access_token = data.session!.accessToken;
      _signed_in = true;
    } else if (data.event == AuthChangeEvent.signedOut) {
      _access_token = '';
      _signed_in = false;
    }
  }

  isSignedIn() {
    return _signed_in;
  }
}
