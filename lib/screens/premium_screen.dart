import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:relax_mindfulness/providers/app_state.dart';
import 'package:relax_mindfulness/theme/app_theme.dart';

// ─── Premium Features List ────────────────────────────────────────────────────
const _premiumFeatures = [
  ('🧘', 'All 14 Guided Sessions', 'Healing, Sleep, Focus & Comfort'),
  ('🌙', 'All 8 Sleep Stories', 'Narrated bedtime journeys'),
  ('🎵', 'Full 78-Track Sound Library', 'Every ambient sound, no limits'),
  ('🎚️', 'Unlimited Sound Presets', 'Save custom ambient mixes'),
  ('📊', 'Advanced Progress Stats', 'Weekly charts & mood trends'),
  ('🔔', 'Daily Reminders', 'Build your meditation habit'),
  ('🌈', 'All 4 App Themes', 'Claymorphic, Forest, Lavender & more'),
  ('✨', 'AI Mood Recommendations', 'Personalised session picks'),
];

// ─── Plans ────────────────────────────────────────────────────────────────────
const _monthlyPrice = '\$6.99';
const _yearlyPrice = '\$39.99';
const _yearlyMonthly = '\$3.33';

// ─── PremiumScreen ────────────────────────────────────────────────────────────
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen>
    with TickerProviderStateMixin {
  bool _yearlySelected = true; // default to best-value yearly
  bool _isPurchasing = false;

  late final AnimationController _glowCtrl;
  late final AnimationController _floatCtrl;
  late final Animation<double> _glowAnim;
  late final Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
    _floatAnim = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (state.isPremium) return _buildAlreadyPremium(context, state);

        return CupertinoPageScaffold(
          backgroundColor: bgDark,
          child: Stack(
            children: [
              // Animated gradient background
              _buildBackground(),
              // Main content
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        _buildHeader(context),
                        const SizedBox(height: 24),
                        _buildLotusHero(),
                        const SizedBox(height: 28),
                        _buildTrialBanner(state),
                        const SizedBox(height: 24),
                        _buildFeaturesGrid(),
                        const SizedBox(height: 28),
                        _buildPlanSelector(),
                        const SizedBox(height: 20),
                        _buildCTAButton(context, state),
                        const SizedBox(height: 12),
                        _buildRestoreRow(context, state),
                        const SizedBox(height: 12),
                        _buildLegalText(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Background ─────────────────────────────────────────────────────────────
  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.5),
              radius: 1.4,
              colors: [
                tealPrimary.withOpacity(0.18 * _glowAnim.value),
                purpleAccent.withOpacity(0.10 * _glowAnim.value),
                bgDark,
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: CupertinoColors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CupertinoColors.white.withOpacity(0.15)),
            ),
            child: const Icon(CupertinoIcons.xmark, color: CupertinoColors.white, size: 20),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8C00)]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: CupertinoColors.systemYellow.withOpacity(0.4), blurRadius: 12)],
          ),
          child: const Row(
            children: [
              Icon(CupertinoIcons.star_fill, color: CupertinoColors.white, size: 16),
              SizedBox(width: 5),
              Text('PREMIUM', style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              )),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Lotus Hero ──────────────────────────────────────────────────────────────
  Widget _buildLotusHero() {
    return AnimatedBuilder(
      animation: _floatAnim,
      builder: (_, __) {
        return Transform.translate(
          offset: Offset(0, _floatAnim.value),
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _glowAnim,
                builder: (_, __) => Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(colors: [
                      Color(0x552DD4BF),
                      Color(0x00050D15),
                    ]),
                    boxShadow: [
                      BoxShadow(
                        color: tealPrimary.withOpacity(0.5 * _glowAnim.value),
                        blurRadius: 40 * _glowAnim.value,
                        spreadRadius: 10 * _glowAnim.value,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🪷', style: TextStyle(fontSize: 64)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sanctuary Premium',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: CupertinoColors.white,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your complete daily calm companion\n— unlimited, forever.',
                style: TextStyle(
                  fontSize: 15,
                  color: CupertinoColors.white.withOpacity(0.6),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Trial Banner ────────────────────────────────────────────────────────────
  Widget _buildTrialBanner(AppState state) {
    if (state.trialActive) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            tealPrimary.withOpacity(0.2),
            mintAccent.withOpacity(0.1),
          ]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tealPrimary.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            const Text('⏳', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Free Trial Active',
                    style: TextStyle(color: tealPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
                  Text('${state.trialDaysLeft} days remaining — upgrade before it ends',
                    style: TextStyle(color: CupertinoColors.white.withOpacity(0.7), fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          const Color(0xFFFFD700).withOpacity(0.12),
          const Color(0xFFFF8C00).withOpacity(0.06),
        ]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Text('🎁', style: TextStyle(fontSize: 26)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('7-Day Free Trial',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  )),
                Text('Full access. Cancel anytime. No charge today.',
                  style: TextStyle(color: CupertinoColors.white.withOpacity(0.65), fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Features Grid ───────────────────────────────────────────────────────────
  Widget _buildFeaturesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Everything in Premium', style: TextStyle(
          color: CupertinoColors.white.withOpacity(0.9),
          fontSize: 17,
          fontWeight: FontWeight.w700,
        )),
        const SizedBox(height: 14),
        ...List.generate(_premiumFeatures.length, (i) {
          final (emoji, title, subtitle) = _premiumFeatures[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: CupertinoColors.white.withOpacity(0.08)),
                  ),
                  child: Row(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: const TextStyle(
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            )),
                            Text(subtitle, style: TextStyle(
                              color: CupertinoColors.white.withOpacity(0.55),
                              fontSize: 12,
                            )),
                          ],
                        ),
                      ),
                      const Icon(CupertinoIcons.checkmark_circle_fill, color: tealPrimary, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ─── Plan Selector ───────────────────────────────────────────────────────────
  Widget _buildPlanSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choose your plan', style: TextStyle(
          color: CupertinoColors.white.withOpacity(0.9),
          fontSize: 17,
          fontWeight: FontWeight.w700,
        )),
        const SizedBox(height: 14),
        CupertinoListSection.insetGrouped(
          backgroundColor: CupertinoColors.transparent,
          margin: EdgeInsets.zero,
          decoration: BoxDecoration(
            color: CupertinoColors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: CupertinoColors.white.withOpacity(0.12)),
          ),
          children: [
            _buildPlanTile(
              isSelected: _yearlySelected,
              label: 'Yearly',
              badge: '🔥 Best Value — Save 60%',
              price: _yearlyPrice,
              sub: '$_yearlyMonthly / month, billed annually',
              onTap: () => setState(() => _yearlySelected = true),
            ),
            _buildPlanTile(
              isSelected: !_yearlySelected,
              label: 'Monthly',
              badge: null,
              price: _monthlyPrice,
              sub: 'Per month, billed monthly',
              onTap: () => setState(() => _yearlySelected = false),
            ),
          ]
        ),
      ],
    );
  }

  Widget _buildPlanTile({
    required bool isSelected,
    required String label,
    required String? badge,
    required String price,
    required String sub,
    required VoidCallback onTap,
  }) {
    return CupertinoListTile(
      backgroundColor: isSelected ? tealPrimary.withOpacity(0.18) : CupertinoColors.transparent,
      onTap: onTap,
      leading: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 22, height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? tealPrimary : CupertinoColors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: isSelected
            ? Center(
                child: Container(
                  width: 10, height: 10,
                  decoration: const BoxDecoration(
                    color: tealPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            : null,
      ),
      title: Row(
        children: [
          Text(label, style: const TextStyle(
            color: CupertinoColors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          )),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [tealPrimary, mintAccent]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(badge,
                style: const TextStyle(
                  color: CupertinoColors.black,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                )),
            ),
          ],
        ],
      ),
      subtitle: Text(sub, style: TextStyle(
        color: CupertinoColors.white.withOpacity(0.5),
        fontSize: 11,
      )),
      trailing: Text(price, style: const TextStyle(
        color: CupertinoColors.white,
        fontWeight: FontWeight.w800,
        fontSize: 18,
      )),
    );
  }

  // ─── CTA Button ──────────────────────────────────────────────────────────────
  Widget _buildCTAButton(BuildContext context, AppState state) {
    final trialText = state.trialActive
        ? 'Upgrade Now'
        : 'Start 7-Day Free Trial';

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: _isPurchasing ? null : () => _handlePurchase(context, state),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 58,
        decoration: BoxDecoration(
          gradient: _isPurchasing
              ? const LinearGradient(colors: [CupertinoColors.systemGrey, CupertinoColors.systemGrey2])
              : const LinearGradient(
                  colors: [tealPrimary, mintAccent],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: _isPurchasing ? [] : [
            BoxShadow(
              color: tealPrimary.withOpacity(0.45),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: _isPurchasing
              ? const SizedBox(
                  width: 24, height: 24,
                  child: CupertinoActivityIndicator(
                    color: CupertinoColors.white,
                    radius: 12,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(CupertinoIcons.lock_open_fill, color: CupertinoColors.black, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      trialText,
                      style: const TextStyle(
                        color: CupertinoColors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _handlePurchase(BuildContext context, AppState state) async {
    setState(() => _isPurchasing = true);
    
    try {
      if (_yearlySelected) {
        await Purchases.purchaseProduct('premium_yearly');
      } else {
        await Purchases.purchaseProduct('premium_monthly');
      }
      
      // BUG FIX: always grant full premium after successful RevenueCat charge
      // Previously, non-trial users were incorrectly dropped into startFreeTrial()
      await state.purchasePremium();

      if (mounted) {
        _showSuccessSheet(context, 'Welcome to Premium! 🪷');
      }
    } catch (e) {
      debugPrint("Purchase Error: $e");
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Purchase Failed'),
            content: Text(e.toString()),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(ctx),
              )
            ],
          )
        );
      }
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  void _showSuccessSheet(BuildContext context, String title) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0A1F1C), Color(0xFF050D15)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: tealPrimary.withOpacity(0.3)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              )),
              const SizedBox(height: 8),
              Text(
                'You now have full access to all sessions,\nsleep stories, sounds & features.',
                style: TextStyle(color: CupertinoColors.white.withOpacity(0.6), height: 1.5, decoration: TextDecoration.none, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.of(context)
                  ..pop()
                  ..pop(),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [tealPrimary, mintAccent]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('Start Exploring 🌿',
                      style: TextStyle(
                        color: CupertinoColors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      )),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Restore Row ─────────────────────────────────────────────────────────────
  Widget _buildRestoreRow(BuildContext context, AppState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            await state.restorePurchase();
            if (!mounted) return;
            
            showCupertinoDialog(
              context: context,
              builder: (ctx) => CupertinoAlertDialog(
                title: Text(state.isPremium ? '✅ Restored' : 'Notice'),
                content: Text(state.isPremium ? 'Purchase restored successfully!' : 'No previous purchase found.'),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('OK'),
                    onPressed: () => Navigator.pop(ctx),
                  )
                ]
              )
            );
          },
          child: Text('Restore Purchase',
            style: TextStyle(color: CupertinoColors.white.withOpacity(0.45), fontSize: 13)),
        ),
        Text('  ·  ', style: TextStyle(color: CupertinoColors.white.withOpacity(0.25))),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {},
          child: Text('Privacy Policy',
            style: TextStyle(color: CupertinoColors.white.withOpacity(0.45), fontSize: 13)),
        ),
        Text('  ·  ', style: TextStyle(color: CupertinoColors.white.withOpacity(0.25))),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {},
          child: Text('Terms',
            style: TextStyle(color: CupertinoColors.white.withOpacity(0.45), fontSize: 13)),
        ),
      ],
    );
  }

  // ─── Legal Text ──────────────────────────────────────────────────────────────
  Widget _buildLegalText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        'Subscription auto-renews unless cancelled 24 hours before the end of the '
        'current period. Cancel anytime in your App Store / Play Store settings. '
        'Free trial converts to paid plan after 7 days.',
        style: TextStyle(
          color: CupertinoColors.white.withOpacity(0.3),
          fontSize: 10,
          height: 1.6,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ─── Already Premium State ──────────────────────────────────────────────────
  Widget _buildAlreadyPremium(BuildContext context, AppState state) {
    return CupertinoPageScaffold(
      backgroundColor: bgDark,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🪷', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 20),
              const Text('You\'re Premium! 🌟',
                style: TextStyle(color: CupertinoColors.white, fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Text(
                'Thank you for supporting Sanctuary.\nYou have full access to everything. 🌿',
                style: TextStyle(color: CupertinoColors.white.withOpacity(0.6), fontSize: 15, height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.of(context).pop(),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [tealPrimary, mintAccent]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('Continue Meditating 🧘',
                      style: TextStyle(
                        color: CupertinoColors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      )),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CupertinoButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Back', style: TextStyle(color: CupertinoColors.white.withOpacity(0.4))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
