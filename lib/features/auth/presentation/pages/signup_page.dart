import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';

// ── Brand greens ──────────────────────────────────────────────────────────────
const _primaryGreen = Color(0xFF00450D);
const _buttonStart = Color(0xFF00450D);
const _buttonEnd = Color(0xFF1B5E20);

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: const _SignupView(),
    );
  }
}

class _SignupView extends StatefulWidget {
  const _SignupView();

  @override
  State<_SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<_SignupView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  // Password strength: 0–3
  int _passwordStrength = 0;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordStrength);
  }

  void _updatePasswordStrength() {
    final p = _passwordController.text;
    int strength = 0;
    if (p.length >= 8) strength++;
    if (p.contains(RegExp(r'[A-Z]'))) strength++;
    if (p.contains(RegExp(r'[0-9]'))) strength++;
    if (p.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) strength++;
    setState(() => _passwordStrength = strength.clamp(0, 3));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.removeListener(_updatePasswordStrength);
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _onCreateAccountPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthRegisterRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              name: _nameController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    final textColor = isDark ? AppColors.darkTextPrimary : _primaryGreen;
    final subtitleColor =
        isDark ? AppColors.darkTextSecondary : const Color(0xFF41493E).withValues(alpha: 0.7);
    // Labels always use brand green regardless of mode
    final labelColor = isDark ? Colors.white : _primaryGreen;
    final fieldBg = isDark ? AppColors.darkFieldBg : const Color(0xFFE3E2E0);
    final hintColor = isDark ? AppColors.darkTextHint : const Color(0xFF9E9E9E);
    // Field border: #00450D at 50% opacity in light, white 50% in dark
    final fieldBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.5)
        : _primaryGreen.withValues(alpha: 0.5);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated || state is AuthGoogleAuthenticated) {
          context.go(AppRoutes.home);
        } else if (state is AuthEmailConfirmationRequired) {
          // Replace signup form with confirmation screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) =>
                  _EmailConfirmationPage(email: state.email),
            ),
          );
        } else if (state is AuthFailure) {
          context.showSnackBar(state.message, isError: true);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // ── Back button ───────────────────────────────────
                  _BackButton(
                    onTap: () => context.pop(),
                    isDark: isDark,
                  ),

                  const SizedBox(height: 20),

                  // ── Logo mark ───────────────────────────────────────
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _primaryGreen,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryGreen.withValues(alpha: 0.30),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          'assets/ic_plantlers_new_logo/applogo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Title ─────────────────────────────────────────
                  Text(
                    'Welcome,\nPlant Parent',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                      color: textColor,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Subtitle ──────────────────────────────────────
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: subtitleColor,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: 'Start your plant journey today, with '),
                        TextSpan(
                          text: 'Plantlers',
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: isDark ? AppColors.primaryLight : _primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Google button ─────────────────────────────────
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return _GoogleButton(
                        bgColor: isDark ? AppColors.darkSurfaceVariant : Colors.white,
                        borderColor: isDark
                            ? AppColors.darkDivider
                            : const Color(0xFF41493E).withValues(alpha: 0.2),
                        textColor: isDark
                            ? AppColors.darkTextPrimary
                            : const Color(0xFF41493E),
                        isLoading: isLoading,
                        onTap: isLoading
                            ? null
                            : () => context
                                .read<AuthBloc>()
                                .add(const AuthGoogleSignInRequested()),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // ── OR divider ────────────────────────────────────
                  _OrDivider(
                    dividerColor: isDark
                        ? AppColors.darkDivider
                        : const Color(0xFF41493E).withValues(alpha: 0.15),
                    textColor: isDark
                        ? AppColors.darkTextSecondary
                        : const Color(0xFF41493E).withValues(alpha: 0.5),
                  ),

                  const SizedBox(height: 16),

                  // ── Full Name ─────────────────────────────────────
                  _FieldLabel(label: 'Full Name', color: labelColor),
                  const SizedBox(height: 5),
                  _AuthTextField(
                    controller: _nameController,
                    hint: 'Evelyn Green',
                    validator: Validators.name,
                    textInputAction: TextInputAction.next,
                    fieldBg: fieldBg,
                    hintColor: hintColor,
                    textColor: labelColor,
                    borderColor: fieldBorderColor,
                  ),

                  const SizedBox(height: 12),

                  // ── Email ─────────────────────────────────────────
                  _FieldLabel(label: 'Email', color: labelColor),
                  const SizedBox(height: 5),
                  _AuthTextField(
                    controller: _emailController,
                    hint: 'evelyn@botany.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    textInputAction: TextInputAction.next,
                    fieldBg: fieldBg,
                    hintColor: hintColor,
                    textColor: labelColor,
                    borderColor: fieldBorderColor,
                  ),

                  const SizedBox(height: 12),

                  // ── Password ──────────────────────────────────────
                  _FieldLabel(label: 'Password', color: labelColor),
                  const SizedBox(height: 5),
                  _AuthTextField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    hint: '••••••••',
                    isPassword: true,
                    validator: Validators.password,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _onCreateAccountPressed(),
                    fieldBg: fieldBg,
                    hintColor: hintColor,
                    textColor: labelColor,
                    borderColor: fieldBorderColor,
                  ),

                  // Strength bar — always visible
                  const SizedBox(height: 8),
                  _PasswordStrengthBar(
                    strength: _passwordStrength,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 24),

                  // ── Create Account button ─────────────────────────
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return _GradientButton(
                        label: 'Create Account',
                        isLoading: isLoading,
                        onTap: isLoading ? null : _onCreateAccountPressed,
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // ── Log in link ───────────────────────────────────
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Already have an account?  ',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: subtitleColor,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Text(
                            'Log in',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.primaryLight
                                  : _primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Password strength bar ─────────────────────────────────────────────────────
class _PasswordStrengthBar extends StatelessWidget {
  final int strength; // 0–3
  final bool isDark;

  const _PasswordStrengthBar({required this.strength, required this.isDark});

  Color _segmentColor(int index) {
    if (strength == 0) return isDark ? AppColors.darkFieldBg : const Color(0xFFE3E2E0);
    if (index >= strength) return isDark ? AppColors.darkFieldBg : const Color(0xFFE3E2E0);
    if (strength == 1) return const Color(0xFFEA4335); // weak — red
    if (strength == 2) return const Color(0xFFFBBC05); // medium — yellow
    return _primaryGreen; // strong — green
  }

  String get _label {
    switch (strength) {
      case 0:
        return '';
      case 1:
        return 'WEAK PASSWORD';
      case 2:
        return 'MEDIUM PASSWORD';
      default:
        return 'STRONG PASSWORD';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 3 segments
        Row(
          children: List.generate(3, (i) {
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 3,
                margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                decoration: BoxDecoration(
                  color: _segmentColor(i),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (strength > 0)
              Text(
                _label,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _segmentColor(0),
                  letterSpacing: 0.5,
                ),
              )
            else
              const SizedBox.shrink(),
            Text(
              'At least 8 characters',
              style: GoogleFonts.dmSans(
                fontSize: 10,
                color: isDark ? AppColors.darkTextHint : const Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Field label ───────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  final Color color;

  const _FieldLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}

// ── Auth text field ───────────────────────────────────────────────────────────
class _AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hint;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final void Function(String)? onSubmitted;
  final Color fieldBg;
  final Color hintColor;
  final Color textColor;
  final Color borderColor;

  const _AuthTextField({
    required this.controller,
    required this.hint,
    required this.fieldBg,
    required this.hintColor,
    required this.textColor,
    required this.borderColor,
    this.focusNode,
    this.isPassword = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  @override
  State<_AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<_AuthTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final focusBorderColor = isDark ? AppColors.primaryLight : _primaryGreen;

    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      obscureText: widget.isPassword && _obscure,
      style: GoogleFonts.dmSans(fontSize: 15, color: widget.textColor),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: GoogleFonts.dmSans(fontSize: 15, color: widget.hintColor),
        filled: true,
        fillColor: widget.fieldBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: widget.borderColor, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: widget.borderColor, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: focusBorderColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: widget.textColor.withValues(alpha: 0.5),
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
      ),
    );
  }
}

// ── Gradient button ───────────────────────────────────────────────────────────
class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  const _GradientButton({
    required this.label,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_buttonStart, _buttonEnd],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}


// ── OR divider ────────────────────────────────────────────────────────────────
class _OrDivider extends StatelessWidget {
  final Color dividerColor;
  final Color textColor;

  const _OrDivider({required this.dividerColor, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: dividerColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: dividerColor)),
      ],
    );
  }
}

// ── Google button ─────────────────────────────────────────────────────────────
class _GoogleButton extends StatelessWidget {
  final Color bgColor;
  final Color borderColor;
  final Color textColor;
  final bool isLoading;
  final VoidCallback? onTap;

  const _GoogleButton({
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: _primaryGreen,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/images/auth/login/google.svg',
                    width: 22,
                    height: 22,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Continue with Google',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Back button ───────────────────────────────────────────────────────────────
class _BackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isDark;

  const _BackButton({this.onTap, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    final dark = isDark;
    return GestureDetector(
      onTap: onTap ?? () {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: dark
              ? AppColors.darkSurfaceVariant
              : const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: dark ? AppColors.darkTextPrimary : _primaryGreen,
        ),
      ),
    );
  }
}

// ── Email Confirmation Screen ─────────────────────────────────────────────────
// Shown after signup when Supabase requires email confirmation.
class _EmailConfirmationPage extends StatelessWidget {
  final String email;
  const _EmailConfirmationPage({required this.email});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final textColor = isDark ? AppColors.darkTextPrimary : _primaryGreen;
    final subtitleColor = isDark
        ? AppColors.darkTextSecondary
        : const Color(0xFF41493E).withValues(alpha: 0.7);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Envelope icon ───────────────────────────────────────
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: _primaryGreen.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 44,
                  color: _primaryGreen,
                ),
              ),

              const SizedBox(height: 28),

              // ── Title ───────────────────────────────────────────────
              Text(
                'Check your email',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // ── Body ────────────────────────────────────────────────
              Text(
                'We sent a confirmation link to',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  color: subtitleColor,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 4),

              Text(
                email,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Click the link in the email to activate your account, then come back and log in.',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: subtitleColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 36),

              // ── Go to Login button ───────────────────────────────────
              GestureDetector(
                onTap: () => context.go(AppRoutes.login),
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [_buttonStart, _buttonEnd],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Go to Login',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Resend hint ──────────────────────────────────────────
              Text(
                "Didn't receive it? Check your spam folder.",
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: subtitleColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
