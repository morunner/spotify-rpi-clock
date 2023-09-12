import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Authenticator extends ChangeNotifier {
  Authenticator() {
    authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        signedIn = true;
        await updateSpotifyTokens();
      } else if (event == AuthChangeEvent.signedOut) {
        signedIn = false;
      }
      notifyListeners();
    });
  }

  bool signedIn = false;

  final supabaseAuth = Supabase.instance.client.auth;

  late StreamSubscription<AuthState> authSubscription;

  login(Provider provider, String scopes) async {
    await supabaseAuth.signInWithOAuth(provider, scopes: scopes);
  }

  logout() async {
    await supabaseAuth.signOut();
  }

  isSessionExpired() {
    return supabaseAuth.currentSession!.isExpired;
  }

  isSignedIn() {
    return signedIn;
  }

  updateSpotifyTokens() async {
    if (supabaseAuth.currentSession.isDefinedAndNotNull) {
      final data = {
        'id': supabaseAuth.currentSession!.user.id,
        'provider_token': supabaseAuth.currentSession!.providerToken,
        'provider_refresh_token':
            supabaseAuth.currentSession!.providerRefreshToken,
      };
      await Supabase.instance.client.from('profiles').upsert(data);
    }
  }
}
