import 'package:flutter/material.dart';

/// TeamUp Stitch Design System tokens & palette (Light + Dark mode).
/// Derived directly from the teammate's `stitch_teamup_student_teammate_finder` design spec.
class AppTokens {
  // Brand & Semantic Accents
  static const Color accent = Color(0xFFFFD54A);
  static const Color onAccent = Color(0xFF1B1A22);
  static const Color charcoal = Color(0xFF1F1E26);
  static const Color onCharcoal = Color(0xFFFFFFFF);
  static const Color charcoalMuted = Color(0xFFA8A5B8);

  static const Color success = Color(0xFF2E9E5B);
  static const Color warning = Color(0xFFF2A516);
  static const Color error = Color(0xFFD64545);
  static const Color neutralGrey = Color(0xFF8A8896);

  // Light Mode Palette
  static const Color lightPrimary = Color(0xFF5B4BDB);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryTint = Color(0xFFEDEAFE);
  static const Color lightOnPrimaryTint = Color(0xFF422EC2);
  static const Color lightBgStart = Color(0xFFEFEBFA);
  static const Color lightBgEnd = Color(0xFFFFF8E6);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSubtle = Color(0xFFF7F5FC);
  static const Color lightOnSurface = Color(0xFF1B1A22);
  static const Color lightOnSurfaceSecondary = Color(0xFF6B6878);
  static const Color lightBorder = Color(0xFFE5E0ED);
  static const Color lightIconBtn = Color(0xFFFFFFFF);
  static const Color lightSuccessTint = Color(0xFFE6F6EC);
  static const Color lightOnSuccessTint = Color(0xFF1D6B3C);
  static const Color lightWarningTint = Color(0xFFFEF5E2);
  static const Color lightOnWarningTint = Color(0xFF8F5B00);
  static const Color lightErrorTint = Color(0xFFFDECEC);
  static const Color lightOnErrorTint = Color(0xFF9E2A2A);
  static const Color lightNeutralTint = Color(0xFFF0EFF4);
  static const Color lightOnNeutralTint = Color(0xFF575563);

  // Dark Mode Palette
  static const Color darkPrimary = Color(0xFFA99BFF);
  static const Color darkOnPrimary = Color(0xFF1A124A);
  static const Color darkPrimaryTint = Color(0xFF282442);
  static const Color darkOnPrimaryTint = Color(0xFFC6C0FF);
  static const Color darkBgStart = Color(0xFF12111A);
  static const Color darkBgEnd = Color(0xFF1A1730);
  static const Color darkSurface = Color(0xFF1C1B24);
  static const Color darkSurfaceSubtle = Color(0xFF242230);
  static const Color darkOnSurface = Color(0xFFF2F0FA);
  static const Color darkOnSurfaceSecondary = Color(0xFFA8A5B8);
  static const Color darkBorder = Color(0xFF2C2A38);
  static const Color darkIconBtn = Color(0xFF262433);
  static const Color darkSuccessTint = Color(0xFF182E22);
  static const Color darkOnSuccessTint = Color(0xFF7CE0A3);
  static const Color darkWarningTint = Color(0xFF302615);
  static const Color darkOnWarningTint = Color(0xFFFFD17A);
  static const Color darkErrorTint = Color(0xFF331B1E);
  static const Color darkOnErrorTint = Color(0xFFFF9B9B);
  static const Color darkNeutralTint = Color(0xFF282730);
  static const Color darkOnNeutralTint = Color(0xFFB8B5C4);

  // Spacing tokens
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double pagePad = 16;

  // Border Radius tokens
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
}

/// Theme-aware helper colors so widgets adapt seamlessly between Light and Dark mode.
class AppPalette {
  final bool isDark;
  const AppPalette(this.isDark);

  factory AppPalette.of(BuildContext context) =>
      AppPalette(Theme.of(context).brightness == Brightness.dark);

  Color get primary => isDark ? AppTokens.darkPrimary : AppTokens.lightPrimary;
  Color get onPrimary => isDark ? AppTokens.darkOnPrimary : AppTokens.lightOnPrimary;
  Color get primaryTint => isDark ? AppTokens.darkPrimaryTint : AppTokens.lightPrimaryTint;
  Color get onPrimaryTint => isDark ? AppTokens.darkOnPrimaryTint : AppTokens.lightOnPrimaryTint;

  Color get bgStart => isDark ? AppTokens.darkBgStart : AppTokens.lightBgStart;
  Color get bgEnd => isDark ? AppTokens.darkBgEnd : AppTokens.lightBgEnd;

  Color get surface => isDark ? AppTokens.darkSurface : AppTokens.lightSurface;
  Color get surfaceSubtle => isDark ? AppTokens.darkSurfaceSubtle : AppTokens.lightSurfaceSubtle;
  Color get onSurface => isDark ? AppTokens.darkOnSurface : AppTokens.lightOnSurface;
  Color get onSurfaceSecondary =>
      isDark ? AppTokens.darkOnSurfaceSecondary : AppTokens.lightOnSurfaceSecondary;

  Color get border => isDark ? AppTokens.darkBorder : AppTokens.lightBorder;
  Color get iconBtn => isDark ? AppTokens.darkIconBtn : AppTokens.lightIconBtn;

  Color get successTint => isDark ? AppTokens.darkSuccessTint : AppTokens.lightSuccessTint;
  Color get onSuccessTint => isDark ? AppTokens.darkOnSuccessTint : AppTokens.lightOnSuccessTint;

  Color get warningTint => isDark ? AppTokens.darkWarningTint : AppTokens.lightWarningTint;
  Color get onWarningTint => isDark ? AppTokens.darkOnWarningTint : AppTokens.lightOnWarningTint;

  Color get errorTint => isDark ? AppTokens.darkErrorTint : AppTokens.lightErrorTint;
  Color get onErrorTint => isDark ? AppTokens.darkOnErrorTint : AppTokens.lightOnErrorTint;

  Color get neutralTint => isDark ? AppTokens.darkNeutralTint : AppTokens.lightNeutralTint;
  Color get onNeutralTint => isDark ? AppTokens.darkOnNeutralTint : AppTokens.lightOnNeutralTint;

  LinearGradient get backgroundGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [bgStart, bgEnd],
      );
}

class AppTheme {
  static ThemeData light() => _build(const AppPalette(false), Brightness.light);
  static ThemeData dark() => _build(const AppPalette(true), Brightness.dark);

  static ThemeData _build(AppPalette p, Brightness brightness) {
    final cs = ColorScheme(
      brightness: brightness,
      primary: p.primary,
      onPrimary: p.onPrimary,
      primaryContainer: p.primaryTint,
      onPrimaryContainer: p.onPrimaryTint,
      secondary: AppTokens.accent,
      onSecondary: AppTokens.onAccent,
      secondaryContainer: p.warningTint,
      onSecondaryContainer: p.onWarningTint,
      tertiary: AppTokens.success,
      onTertiary: Colors.white,
      tertiaryContainer: p.successTint,
      onTertiaryContainer: p.onSuccessTint,
      error: AppTokens.error,
      onError: Colors.white,
      errorContainer: p.errorTint,
      onErrorContainer: p.onErrorTint,
      surface: p.surface,
      onSurface: p.onSurface,
      surfaceContainerHighest: p.surfaceSubtle,
      onSurfaceVariant: p.onSurfaceSecondary,
      outline: p.border,
      outlineVariant: p.border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: cs,
      scaffoldBackgroundColor: p.bgStart,
      dividerColor: p.border,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: p.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: p.onSurface),
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          side: BorderSide(color: p.border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surfaceSubtle,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        labelStyle: TextStyle(color: p.onSurfaceSecondary, fontSize: 13.5),
        hintStyle: TextStyle(color: p.onSurfaceSecondary.withValues(alpha: 0.75), fontSize: 13.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: BorderSide(color: p.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: BorderSide(color: p.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: BorderSide(color: p.primary, width: 1.6),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.neutralTint,
        selectedColor: p.primaryTint,
        side: BorderSide(color: p.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        labelStyle: TextStyle(
          color: p.onSurface,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.onSurface,
          side: BorderSide(color: p.border),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          ),
          textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: p.primaryTint,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? p.primary : p.onSurfaceSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconStyleCompat.icon(selected ? p.primary : p.onSurfaceSecondary);
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusXl),
          side: BorderSide(color: p.border),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppTokens.charcoal,
        contentTextStyle: const TextStyle(color: AppTokens.onCharcoal, fontSize: 13.5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        ),
      ),
    );
  }
}

class IconStyleCompat {
  static IconThemeData icon(Color c) => IconThemeData(color: c, size: 22);
}

/// Custom TeamUp overlapping-circles logo from the Stitch `code.html` SVG:
/// `<circle cx="17" cy="22" r="10"/>` (on-primary) + `<circle cx="27" cy="22" r="10"/>` (accent #FFD54A)
/// inside a rounded-xl primary container.
class TeamUpLogo extends StatelessWidget {
  final double size;
  const TeamUpLogo({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final radius = size * 0.30;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: p.primary,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: p.primary.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _LogoPainter(leftCircleColor: p.onPrimary),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final Color leftCircleColor;
  const _LogoPainter({required this.leftCircleColor});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 44.0;
    final r = 10.0 * scale;
    final leftPaint = Paint()..color = leftCircleColor.withValues(alpha: 0.95);
    final rightPaint = Paint()..color = AppTokens.accent.withValues(alpha: 0.90);

    canvas.drawCircle(Offset(17.0 * scale, 22.0 * scale), r, leftPaint);
    canvas.drawCircle(Offset(27.0 * scale, 22.0 * scale), r, rightPaint);
  }

  @override
  bool shouldRepaint(covariant _LogoPainter oldDelegate) =>
      oldDelegate.leftCircleColor != leftCircleColor;
}
