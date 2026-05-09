import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Initialise Supabase ───────────────────────────────────────────────────
  // Replace the two values below with your own from:
  // Supabase Dashboard → Settings → API
  await Supabase.initialize(
    url: 'https://lihhwudmkombxpwofazv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxpaGh3dWRta29tYnhwd29mYXp2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgzMTk0NzIsImV4cCI6MjA5Mzg5NTQ3Mn0.tBz5HJRgpIEQqCXvmgtcaIHgtCzkRa_Fgg4-xVjdCzA',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      autoRefreshToken: true,
    ),
  );

  await initDependencies();
  runApp(const App());
}
