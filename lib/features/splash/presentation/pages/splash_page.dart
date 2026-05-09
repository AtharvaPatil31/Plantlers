import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/storage_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const Color _gradientCenter = Color(0xFF1B5E20);
  static const Color _gradientEdge = Color(0xFF00450D);

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final storageService = sl<StorageService>();

    // Onboarding check
    if (!storageService.isOnboardingDone) {
      context.go(AppRoutes.onboarding);
      return;
    }

    // Auth check — use Supabase session, not SharedPreferences
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _gradientEdge,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.85,
            colors: [_gradientCenter, _gradientEdge],
            stops: [0.0, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'PLANTLERS',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 60,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  letterSpacing: 2,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 16),
              const _TaglineRow(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaglineRow extends StatelessWidget {
  const _TaglineRow();

  @override
  Widget build(BuildContext context) {
    const lineColor = Color(0x99FFFFFF);
    const lineWidth = 28.0;
    const lineThickness = 0.8;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(width: lineWidth, height: lineThickness, color: lineColor),
        const SizedBox(width: 10),
        Text(
          'GROW YOUR SPACE',
          style: GoogleFonts.dmSans(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: Colors.white,
            letterSpacing: 3.5,
            height: 1.0,
          ),
        ),
        const SizedBox(width: 10),
        Container(width: lineWidth, height: lineThickness, color: lineColor),
      ],
    );
  }
}
