import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/forgot_password_bloc.dart';

// ── Brand colors ──────────────────────────────────────────────────────────────
const _green = Color(0xFF00450D);
const _greenLight = Color(0xFF1B5E20);
const _tagBg = Color(0xFF00450D);

// ── Entry point — provides BLoC and routes between the 3 sub-screens ──────────
class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ForgotPasswordBloc>(),
      child: const _ForgotPasswordFlow(),
    );
  }
}

class _ForgotPasswordFlow extends StatelessWidget {
  const _ForgotPasswordFlow();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
      listener: (context, state) {
        if (state is ForgotPasswordSuccess) {
          context.showSnackBar('Password updated! Please log in.');
          context.go(AppRoutes.login);
        } else if (state is ForgotPasswordFailure) {
          context.showSnackBar(state.message, isError: true);
        }
      },
      builder: (context, state) {
        if (state is ForgotPasswordOtpSent) {
          return _VerifyOtpScreen(email: state.email);
        }
        if (state is ForgotPasswordOtpVerified) {
          return _ResetPasswordScreen(email: state.email, otp: state.otp);
        }
        return const _SendOtpScreen();
      },
    );
  }
}

// ── Screen 1: Send OTP ────────────────────────────────────────────────────────
class _SendOtpScreen extends StatefulWidget {
  const _SendOtpScreen();

  @override
  State<_SendOtpScreen> createState() => _SendOtpScreenState();
}

class _SendOtpScreenState extends State<_SendOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSendOtp() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ForgotPasswordBloc>().add(
            ForgotPasswordSendOtpRequested(email: _emailController.text.trim()),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final textColor = isDark ? Colors.white : _green;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF41493E).withValues(alpha: 0.7);
    final labelColor = isDark ? Colors.white : _green;
    final fieldBg = isDark ? AppColors.darkFieldBg : const Color(0xFFE3E2E0);
    final hintColor = isDark ? AppColors.darkTextHint : const Color(0xFF9E9E9E);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.5) : _green.withValues(alpha: 0.5);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                // ── Back button ─────────────────────────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: _BackButton(),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _green,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: _green.withValues(alpha: 0.30),
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
                const SizedBox(height: 40),
                Text(
                  'Reset Password',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 36, fontWeight: FontWeight.w400,
                    color: textColor, height: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Enter your email to receive\nyour OTP',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 15, color: subtitleColor, height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('EMAIL',
                    style: GoogleFonts.dmSans(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: labelColor, letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                _FpTextField(
                  controller: _emailController,
                  hint: 'name@example.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  fieldBg: fieldBg, hintColor: hintColor,
                  textColor: labelColor, borderColor: borderColor,
                  suffixIcon: Icon(Icons.alternate_email, size: 18,
                    color: hintColor),
                ),
                const SizedBox(height: 32),
                BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
                  builder: (context, state) {
                    final isLoading = state is ForgotPasswordLoading;
                    return _FpButton(
                      label: 'SEND OTP  →',
                      isLoading: isLoading,
                      onTap: isLoading ? null : _onSendOtp,
                    );
                  },
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh_rounded, size: 16,
                        color: isDark ? AppColors.primaryLight : _green),
                      const SizedBox(width: 6),
                      Text('Contact Support',
                        style: GoogleFonts.dmSans(
                          fontSize: 14, fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.primaryLight : _green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Screen 2: Verify OTP ──────────────────────────────────────────────────────
class _VerifyOtpScreen extends StatefulWidget {
  final String email;
  const _VerifyOtpScreen({required this.email});

  @override
  State<_VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<_VerifyOtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(5, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(5, (_) => FocusNode());

  int _secondsLeft = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _onVerify() {
    if (_otp.length == 5) {
      context.read<ForgotPasswordBloc>().add(
            ForgotPasswordVerifyOtpRequested(email: widget.email, otp: _otp),
          );
    } else {
      context.showSnackBar('Please enter the complete OTP.', isError: true);
    }
  }

  void _onResend() {
    if (_secondsLeft == 0) {
      context.read<ForgotPasswordBloc>().add(
            ForgotPasswordSendOtpRequested(email: widget.email),
          );
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final textColor = isDark ? Colors.white : _green;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF41493E).withValues(alpha: 0.7);
    final boxBg = isDark ? AppColors.darkFieldBg : const Color(0xFFE3E2E0);
    final boxBorder = isDark ? Colors.white.withValues(alpha: 0.3) : _green.withValues(alpha: 0.3);
    final canResend = _secondsLeft == 0;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const _BackButton(),
              const SizedBox(height: 24),
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _green,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: _green.withValues(alpha: 0.30),
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
              const SizedBox(height: 16),
              // Security check tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: _tagBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('SECURITY CHECK',
                  style: GoogleFonts.dmSans(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    color: Colors.white, letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Verify Your Number',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 34, fontWeight: FontWeight.w400,
                  color: textColor, height: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "We've sent a code to your phone to\nensure it's really you.",
                style: GoogleFonts.dmSans(fontSize: 15, color: subtitleColor, height: 1.5),
              ),
              const SizedBox(height: 40),
              // OTP boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (i) {
                  return SizedBox(
                    width: 52,
                    height: 56,
                    child: TextFormField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 22, color: textColor,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: boxBg,
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: boxBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: boxBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.primaryLight : _green,
                            width: 1.5,
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        if (val.isNotEmpty && i < 4) {
                          _focusNodes[i + 1].requestFocus();
                        } else if (val.isEmpty && i > 0) {
                          _focusNodes[i - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 28),
              Center(
                child: Column(
                  children: [
                    Text(
                      canResend ? '' : 'RESEND IN 00:${_secondsLeft.toString().padLeft(2, '0')}',
                      style: GoogleFonts.dmSans(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: subtitleColor, letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: _onResend,
                      child: Text('Resend Code',
                        style: GoogleFonts.dmSans(
                          fontSize: 14, fontWeight: FontWeight.w600,
                          color: canResend
                              ? (isDark ? AppColors.primaryLight : _green)
                              : subtitleColor,
                          decoration: canResend ? TextDecoration.underline : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
                builder: (context, state) {
                  final isLoading = state is ForgotPasswordLoading;
                  return _FpButton(
                    label: 'VERIFY  →',
                    isLoading: isLoading,
                    onTap: isLoading ? null : _onVerify,
                  );
                },
              ),
              const SizedBox(height: 32),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.dmSans(fontSize: 13, color: subtitleColor),
                    children: [
                      const TextSpan(text: 'Having trouble? '),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {},
                          child: Text('Contact our curator support',
                            style: GoogleFonts.dmSans(
                              fontSize: 13, fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.primaryLight : _green,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Center(
                child: Text(
                  '© 2024 PLANTLERS BOTANICAL ATELIER\nPRIVACY   TERMS',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 10, color: subtitleColor, letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Screen 3: Create New Password ─────────────────────────────────────────────
class _ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;
  const _ResetPasswordScreen({required this.email, required this.otp});

  @override
  State<_ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<_ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  int _strength = 0;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updateStrength);
  }

  void _updateStrength() {
    final p = _passwordController.text;
    int s = 0;
    if (p.length >= 8) s++;
    if (p.contains(RegExp(r'[A-Z]'))) s++;
    if (p.contains(RegExp(r'[0-9]'))) s++;
    if (p.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) s++;
    setState(() => _strength = s.clamp(0, 3));
  }

  @override
  void dispose() {
    _passwordController.removeListener(_updateStrength);
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onUpdatePassword() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ForgotPasswordBloc>().add(
            ForgotPasswordResetRequested(
              email: widget.email,
              otp: widget.otp,
              newPassword: _passwordController.text,
            ),
          );
    }
  }

  Color _strengthColor(int index) {
    if (_strength == 0 || index >= _strength) {
      return context.isDarkMode ? AppColors.darkFieldBg : const Color(0xFFE3E2E0);
    }
    if (_strength == 1) return const Color(0xFFEA4335);
    if (_strength == 2) return const Color(0xFFFBBC05);
    return _green;
  }

  String get _strengthLabel {
    switch (_strength) {
      case 1: return 'WEAK';
      case 2: return 'MEDIUM';
      case 3: return 'STRONG';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final textColor = isDark ? Colors.white : _green;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF41493E).withValues(alpha: 0.7);
    final labelColor = isDark ? Colors.white : _green;
    final fieldBg = isDark ? AppColors.darkFieldBg : const Color(0xFFE3E2E0);
    final hintColor = isDark ? AppColors.darkTextHint : const Color(0xFF9E9E9E);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.5) : _green.withValues(alpha: 0.5);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const _BackButton(),
                const SizedBox(height: 24),
                // Security tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: _tagBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('SECURITY',
                    style: GoogleFonts.dmSans(
                      fontSize: 10, fontWeight: FontWeight.w700,
                      color: Colors.white, letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Create New\nPassword',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 36, fontWeight: FontWeight.w400,
                    color: textColor, height: 1.15,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Set a secure password for your account to\nprotect your botanical collection.',
                  style: GoogleFonts.dmSans(fontSize: 14, color: subtitleColor, height: 1.5),
                ),
                const SizedBox(height: 32),
                // New password
                Text('NEW PASSWORD',
                  style: GoogleFonts.dmSans(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: labelColor, letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                _FpTextField(
                  controller: _passwordController,
                  hint: '••••••••',
                  isPassword: true,
                  validator: Validators.password,
                  fieldBg: fieldBg, hintColor: hintColor,
                  textColor: labelColor, borderColor: borderColor,
                ),
                const SizedBox(height: 10),
                // Strength bar
                Row(
                  children: List.generate(3, (i) => Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 3,
                      margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                      decoration: BoxDecoration(
                        color: _strengthColor(i),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  )),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('STRENGTH',
                      style: GoogleFonts.dmSans(
                        fontSize: 10, fontWeight: FontWeight.w600,
                        color: subtitleColor, letterSpacing: 0.8,
                      ),
                    ),
                    if (_strength > 0)
                      Text(_strengthLabel,
                        style: GoogleFonts.dmSans(
                          fontSize: 10, fontWeight: FontWeight.w700,
                          color: _strengthColor(0),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _CheckItem(
                      label: '8+ Characters',
                      met: _passwordController.text.length >= 8,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 16),
                    _CheckItem(
                      label: 'Special Symbol',
                      met: _passwordController.text.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]')),
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Confirm password
                Text('CONFIRM PASSWORD',
                  style: GoogleFonts.dmSans(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: labelColor, letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                _FpTextField(
                  controller: _confirmController,
                  hint: '••••••••',
                  isPassword: true,
                  validator: (v) => Validators.confirmPassword(v, _passwordController.text),
                  fieldBg: fieldBg, hintColor: hintColor,
                  textColor: labelColor, borderColor: borderColor,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _onUpdatePassword(),
                ),
                const SizedBox(height: 32),
                BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
                  builder: (context, state) {
                    final isLoading = state is ForgotPasswordLoading;
                    return _FpButton(
                      label: 'Update Password',
                      isLoading: isLoading,
                      onTap: isLoading ? null : _onUpdatePassword,
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Requirement check item ────────────────────────────────────────────────────
class _CheckItem extends StatelessWidget {
  final String label;
  final bool met;
  final bool isDark;

  const _CheckItem({required this.label, required this.met, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = met ? _green : (isDark ? AppColors.darkTextHint : const Color(0xFF9E9E9E));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            met ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 14,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
          style: GoogleFonts.dmSans(fontSize: 11, color: color),
        ),
      ],
    );
  }
}

// ── Shared text field ─────────────────────────────────────────────────────────
class _FpTextField extends StatefulWidget {
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
  final Color borderColor;
  final Widget? suffixIcon;

  const _FpTextField({
    required this.controller,
    required this.hint,
    required this.fieldBg,
    required this.hintColor,
    required this.textColor,
    required this.borderColor,
    this.isPassword = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.suffixIcon,
  });

  @override
  State<_FpTextField> createState() => _FpTextFieldState();
}

class _FpTextFieldState extends State<_FpTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final focusColor = isDark ? AppColors.primaryLight : _green;

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
          borderSide: BorderSide(color: widget.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: widget.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: focusColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
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
            : widget.suffixIcon,
      ),
    );
  }
}

// ── Shared gradient button ────────────────────────────────────────────────────
class _FpButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  const _FpButton({required this.label, this.onTap, this.isLoading = false});

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
            colors: [_green, _greenLight],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : Text(label,
                style: GoogleFonts.dmSans(
                  fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white,
                ),
              ),
      ),
    );
  }
}

// ── Back button — used on all forgot-password sub-screens ────────────────────
class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return GestureDetector(
      onTap: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          context.go(AppRoutes.login);
        }
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurfaceVariant
              : const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: isDark ? AppColors.darkTextPrimary : _green,
        ),
      ),
    );
  }
}
