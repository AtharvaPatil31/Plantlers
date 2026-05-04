import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'app.dart';
import 'core/di/injection_container.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // google_sign_in v7 requires serverClientId (the web OAuth client ID from
  // google-services.json, client_type: 3) so Android can exchange tokens.
  await GoogleSignIn.instance.initialize(
    serverClientId:
        '325199277423-anbbs0sp8gs01pduumr5ptljdj784dd9.apps.googleusercontent.com',
  );
  await initDependencies();
  runApp(const App());
}
