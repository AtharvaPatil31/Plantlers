import 'dart:async' show unawaited;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_routes.dart';
import '../bloc/onboarding_bloc.dart';

// ── Slide data ───────────────────────────────────────────────────────────────
class _Slide {
  final String image;
  final String title;
  final String description;

  const _Slide({
    required this.image,
    required this.title,
    required this.description,
  });
}

const _slides = [
  _Slide(
    image: 'assets/images/onboarding/onboarding_1.png',
    title: 'Nature at Your\nDoorstep',
    description:
        'Freshly nurtured, packed with care.\nYour journey to a greener home starts here.',
  ),
  _Slide(
    image: 'assets/images/onboarding/onboarding_2.png',
    title: 'Greens for every\ncorner',
    description: 'From small desks to big spaces,\nwe\'ve got you covered.',
  ),
  _Slide(
    image: 'assets/images/onboarding/onboarding_3.png',
    title: 'Your Plants,\nYour Story',
    description: 'Join 4,200+ happy plant parents and\ngrow your space today.',
  ),
];

// ── Colors ───────────────────────────────────────────────────────────────────
const _textGreen = Color(0xFF00450D);
const _buttonStart = Color(0xFF00450D);
const _buttonEnd = Color(0xFF1B5E20);
const _bgColor = Color(0xFFFAFAF5);
const _dotInactive = Color(0xFFCCCCCC);

// ── Page ─────────────────────────────────────────────────────────────────────
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OnboardingBloc>(),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  final _pageController = PageController();
  int _currentPage = 0;
  int _timerGeneration = 0;
  String _pendingRoute = AppRoutes.signup;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    unawaited(_startAutoAdvance(_timerGeneration));
  }

  Future<void> _startAutoAdvance(int generation) async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted || generation != _timerGeneration) return;
    if (_currentPage < _slides.length - 1) {
      unawaited(_pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      ));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (index >= _slides.length) return;
    setState(() => _currentPage = index);
    _timerGeneration++;
    unawaited(_startAutoAdvance(_timerGeneration));
  }

  void _onGetStarted() {
    _pendingRoute = AppRoutes.signup;
    context.read<OnboardingBloc>().add(const OnboardingCompleted());
  }

  void _onLogin() {
    _pendingRoute = AppRoutes.login;
    context.read<OnboardingBloc>().add(const OnboardingCompleted());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final imageHeight = size.height * 0.58;
    final isLast = _currentPage == _slides.length - 1;

    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingSuccess) context.go(_pendingRoute);
      },
      child: Scaffold(
        backgroundColor: _bgColor,
        body: Stack(
          children: [
            // ── Swipeable slides ──────────────────────────────────────────
            PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              itemCount: _slides.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (_, index) => _SlidePage(
                slide: _slides[index],
                imageHeight: imageHeight,
              ),
            ),

            // ── Dots — pinned, hidden on last slide ───────────────────────
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: isLast ? 0.0 : 1.0,
                child: Center(
                  child: _DotIndicator(
                    currentPage: _currentPage,
                    totalPages: _slides.length,
                  ),
                ),
              ),
            ),

            // ── Buttons — slide up on last screen ─────────────────────────
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: isLast ? 32 : -120,
              left: 24,
              right: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _GradientButton(
                    label: 'Get Started',
                    onTap: _onGetStarted,
                  ),
                  const SizedBox(height: 12),
                  _OutlinedButton(
                    label: 'Login',
                    onTap: _onLogin,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Single slide ──────────────────────────────────────────────────────────────
class _SlidePage extends StatelessWidget {
  final _Slide slide;
  final double imageHeight;

  const _SlidePage({required this.slide, required this.imageHeight});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Solid bg
        const Positioned.fill(child: ColoredBox(color: _bgColor)),

        // Photo
        Positioned(
          top: 0, left: 0, right: 0,
          height: imageHeight,
          child: Image.asset(
            slide.image,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),

        // White fade at bottom of image
        Positioned(
          top: imageHeight * 0.6,
          left: 0, right: 0,
          height: imageHeight * 0.4,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, _bgColor],
              ),
            ),
          ),
        ),

        // Text content
        Positioned(
          top: imageHeight * 0.92,
          left: 24, right: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 20, height: 1.5, color: _textGreen),
                  const SizedBox(width: 8),
                  Text(
                    'PLANTLERS',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _textGreen,
                      letterSpacing: 2.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                slide.title,
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 48,
                  fontWeight: FontWeight.w400,
                  color: _textGreen,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                slide.description,
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: _textGreen.withValues(alpha: 0.75),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Dot indicator ─────────────────────────────────────────────────────────────
class _DotIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const _DotIndicator({required this.currentPage, required this.totalPages});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalPages, (i) {
        final isActive = i == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: isActive ? _textGreen : _dotInactive,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ── Gradient button ───────────────────────────────────────────────────────────
class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GradientButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [_buttonStart, _buttonEnd],
          ),
          borderRadius: BorderRadius.circular(50),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

// ── Outlined button ───────────────────────────────────────────────────────────
class _OutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OutlinedButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: _textGreen, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _textGreen,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
