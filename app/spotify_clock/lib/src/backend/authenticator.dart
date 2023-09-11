import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Authenticator extends ChangeNotifier {
  Authenticator() {
    authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        signedIn = true;
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
}
