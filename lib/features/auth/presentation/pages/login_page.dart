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

// ── Brand greens — same in both modes (intentional brand color) ───────────────
const _primaryGreen = Color(0xFF00450D);
const _buttonStart = Color(0xFF00450D);
const _buttonEnd = Color(0xFF1B5E20);

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    // Theme-aware colors
    final textColor = isDark ? AppColors.darkTextPrimary : _primaryGreen;
    final subtitleColor = isDark
        ? AppColors.darkTextSecondary
        : const Color(0xFF41493E).withValues(alpha: 0.7);
    final labelColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF41493E);
    final fieldBg = isDark ? AppColors.darkFieldBg : const Color(0xFFE3E2E0);
    final hintColor = isDark ? AppColors.darkTextHint : const Color(0xFF9E9E9E);
    final dividerColor = isDark
        ? AppColors.darkDivider
        : const Color(0xFF41493E).withValues(alpha: 0.15);
    final orTextColor = isDark
        ? AppColors.darkTextSecondary
        : const Color(0xFF41493E).withValues(alpha: 0.5);
    final googleBtnBg = isDark ? AppColors.darkSurfaceVariant : Colors.white;
    final googleBtnBorder = isDark
        ? AppColors.darkDivider
        : const Color(0xFF41493E).withValues(alpha: 0.2);
    final googleTextColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF41493E);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.home);
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 48),

                  // ── PLANTLERS wordmark ──────────────────────────────────
                  Text(
                    'PLANTLERS',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: textColor,
                      letterSpacing: 3,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Welcome Back + leaf ─────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome Back',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 36,
                          fontWeight: FontWeight.w400,
                          color: textColor,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Image.asset(
                        'assets/images/auth/login/leaf.png',
                        height: 36,
                        width: 36,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ── Subtitle ────────────────────────────────────────────
                  Text(
                    'Continue your plant journey',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: subtitleColor,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ── Email field ─────────────────────────────────────────
                  _FieldLabel(label: 'EMAIL', color: labelColor),
                  const SizedBox(height: 6),
                  _AuthTextField(
                    controller: _emailController,
                    hint: 'hello@botanical.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    textInputAction: TextInputAction.next,
                    fieldBg: fieldBg,
                    hintColor: hintColor,
                    textColor: labelColor,
                  ),

                  const SizedBox(height: 16),

                  // ── Password field ──────────────────────────────────────
                  _FieldLabel(label: 'PASSWORD', color: labelColor),
                  const SizedBox(height: 6),
                  _AuthTextField(
                    controller: _passwordController,
                    hint: '••••••••',
                    isPassword: true,
                    validator: Validators.password,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _onLoginPressed(),
                    fieldBg: fieldBg,
                    hintColor: hintColor,
                    textColor: labelColor,
                  ),

                  const SizedBox(height: 8),

                  // ── Forgot password ─────────────────────────────────────
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => context.push(AppRoutes.forgotPassword),
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.primaryLight : _primaryGreen,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Login button ────────────────────────────────────────
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return _GradientButton(
                        label: 'Login',
                        isLoading: isLoading,
                        onTap: isLoading ? null : _onLoginPressed,
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // ── OR divider ──────────────────────────────────────────
                  _OrDivider(
                    dividerColor: dividerColor,
                    textColor: orTextColor,
                  ),

                  const SizedBox(height: 24),

                  // ── Google button ───────────────────────────────────────
                  _GoogleButton(
                    bgColor: googleBtnBg,
                    borderColor: googleBtnBorder,
                    textColor: googleTextColor,
                  ),

                  const SizedBox(height: 32),

                  // ── Sign up link ────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'New to Plantlers? ',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: subtitleColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.signup),
                        child: Text(
                          'Create an account',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: isDark ? AppColors.primaryLight : _primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ── Auth text field ───────────────────────────────────────────────────────────
class _AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final void Function(String)? onSubmitted;
  final Color fieldBg;
  final Color hintColor;
  final Color textColor;

  const _AuthTextField({
    required this.controller,
    required this.hint,
    required this.fieldBg,
    required this.hintColor,
    required this.textColor,
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
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
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

// ── Gradient login button — brand green, same in both modes ───────────────────
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

  const _GoogleButton({
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Row(
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
    );
  }
}
