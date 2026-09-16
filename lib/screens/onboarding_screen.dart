import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relax_mindfulness/providers/app_state.dart';
import 'package:relax_mindfulness/components/night_sky_illustrations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _starAnimCtrl;
  int _currentPage = 0;

  // Controllers for Sign In
  final _loginEmailCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();

  // Controllers for Sign Up
  final _regFirstCtrl = TextEditingController();
  final _regLastCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _starAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _starAnimCtrl.dispose();
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    _regFirstCtrl.dispose();
    _regLastCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPassCtrl.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    HapticFeedback.lightImpact();
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _completeAuth() {
    HapticFeedback.mediumImpact();
    context.read<AppState>().completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117), // Deep Obsidian Night Sky
      body: Stack(
        children: [
          // 🌌 Animated Twinkling Starry Night Sky Canvas
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _starAnimCtrl,
              builder: (context, _) {
                return CustomPaint(
                  painter: StarrySkyPainter(animationValue: _starAnimCtrl.value),
                );
              },
            ),
          ),

          // ── Top Header with Back Button & Skip Action ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 36,
                      onPressed: () => _goToPage(_currentPage - 1),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                        child: const Icon(CupertinoIcons.chevron_left, color: Colors.white, size: 20),
                      ),
                    )
                  else
                    const SizedBox(width: 36),

                  // 1-Tap Guest Skip Button
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 32,
                    onPressed: _completeAuth,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.8),
                      ),
                      child: Text(
                        'Skip',
                        style: GoogleFonts.outfit(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFCBD5E1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── 3-Screen PageView ──
          Positioned.fill(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              physics: const ClampingScrollPhysics(),
              children: [
                _buildWelcomePage(),
                _buildSignInPage(),
                _buildCreateAccountPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ── 1. Screen 1: Welcome / Master Your Mind with Ease ───────────────────────
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildWelcomePage() {
    return Column(
      children: [
        const SizedBox(height: 70),

        // 🌙 Glowing Crescent Moon & Hanging Lantern
        const Expanded(
          flex: 5,
          child: Center(
            child: CrescentMoonLanternIllustration(),
          ),
        ),

        // ── Bottom Dark Rounded Card ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(28, 30, 28, 42),
          decoration: const BoxDecoration(
            color: Color(0xFF161922),
            borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 30,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Master Your Mind\nwith Ease',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Manage your ambient sounds, guided breath, and sleep journeys all in one peaceful place.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 13.5,
                  color: const Color(0xFF94A3B8),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),

              // 🚀 Gradient "Get Started ↗" Pill Button
              _PurpleGradientButton(
                label: 'Get Started',
                hasTrailingArrow: true,
                onPressed: () => _goToPage(1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ── 2. Screen 2: Sign In / Your Journey Continues Here ──────────────────────
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSignInPage() {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: IntrinsicHeight(
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Top Title
              Text(
                'Your Journey\nContinues Here',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),

              // 🧘 Meditating Persona on Glowing Golden Cushion
              const JourneyMeditationIllustration(),

              const Spacer(),

              // ── Bottom Dark Rounded Sheet ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 38),
                decoration: const BoxDecoration(
                  color: Color(0xFF161922),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 30,
                      offset: Offset(0, -8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sign in',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Email Field
                    _DarkInputField(
                      controller: _loginEmailCtrl,
                      hintText: 'Email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),

                    // Password Field
                    _DarkInputField(
                      controller: _loginPassCtrl,
                      hintText: 'Password',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 10),

                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showInfoDialog('Password Reset', 'A reset link has been sent to your email.');
                        },
                        child: Text(
                          'Forgot password?',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Log In Button
                    _PurpleGradientButton(
                      label: 'Log In',
                      onPressed: _completeAuth,
                    ),
                    const SizedBox(height: 16),

                    // Switch to Sign Up
                    Center(
                      child: GestureDetector(
                        onTap: () => _goToPage(2),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF94A3B8)),
                            children: const [
                              TextSpan(text: "Don't have an account? "),
                              TextSpan(
                                text: 'Sign Up',
                                style: TextStyle(
                                  color: Color(0xFFC084FC),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ── 3. Screen 3: Create Account ─────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildCreateAccountPage() {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: IntrinsicHeight(
          child: Column(
            children: [
              const SizedBox(height: 55),

              // ☀️ Glowing Sleeping Sun with Night Mask
              const SleepingSunIllustration(),
              const SizedBox(height: 10),

              const Spacer(),

              // ── Bottom Dark Rounded Sheet ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 36),
                decoration: const BoxDecoration(
                  color: Color(0xFF161922),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 30,
                      offset: Offset(0, -8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Account',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // First & Last Name
                    Row(
                      children: [
                        Expanded(
                          child: _DarkInputField(
                            controller: _regFirstCtrl,
                            hintText: 'First Name',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DarkInputField(
                            controller: _regLastCtrl,
                            hintText: 'Last Name',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Email Field
                    _DarkInputField(
                      controller: _regEmailCtrl,
                      hintText: 'Email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),

                    // Password Field
                    _DarkInputField(
                      controller: _regPassCtrl,
                      hintText: 'Password',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 20),

                    // Sign Up Button
                    _PurpleGradientButton(
                      label: 'Sign Up',
                      onPressed: _completeAuth,
                    ),
                    const SizedBox(height: 14),

                    // Terms disclaimer
                    Center(
                      child: Text(
                        'By creating an account you agree to our Terms of Use and Privacy Policy',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                          height: 1.35,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Switch to Sign In
                    Center(
                      child: GestureDetector(
                        onTap: () => _goToPage(1),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF94A3B8)),
                            children: const [
                              TextSpan(text: 'Already have an account? '),
                              TextSpan(
                                text: 'Log In',
                                style: TextStyle(
                                  color: Color(0xFFC084FC),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(String title, String message) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable Dark Input Pill Field ───────────────────────────────────────────
class _DarkInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;

  const _DarkInputField({
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF222634),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 0.8),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: GoogleFonts.outfit(
          fontSize: 14,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: GoogleFonts.outfit(
            fontSize: 14,
            color: const Color(0xFF64748B),
          ),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: const Color(0xFF94A3B8), size: 19)
              : null,
        ),
      ),
    );
  }
}

// ─── Reusable Purple / Lavender Gradient Button with Arrow ────────────────────
class _PurpleGradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool hasTrailingArrow;

  const _PurpleGradientButton({
    required this.label,
    required this.onPressed,
    this.hasTrailingArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF7C3AED), // Vivid Purple
            Color(0xFFA855F7), // Light Lavender
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.4),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: () {
            HapticFeedback.mediumImpact();
            onPressed();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                if (hasTrailingArrow) ...[
                  const SizedBox(width: 10),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_outward_rounded,
                      size: 15,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
