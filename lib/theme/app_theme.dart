import 'package:flutter/material.dart';

/// Soft Editorial Pastel & Jet-Black Pill Design System (inspired by the reference photo).
/// Features:
/// - Warm alabaster/stone background (`#EDEAE4` -> `#E6E2EC`)
/// - Jet-black active pills & action circles (`#16151A`)
/// - Soft Lavender (`#CBC3DC` / `#DDD7EA`), Rose Mauve (`#D8B4C2` / `#E9D2DB`),
///   Warm Sand (`#E8DFD5`), and Crisp White (`#FFFFFF`) cards with 28px rounded corners
/// - Big editorial headings & oversized stat numerals (`72%`, `24`, `10`)
class AppTokens {
  // Core Editorial Palette (from the inspiration photo)
  static const Color jetBlack = Color(0xFF16151A);
  static const Color onJetBlack = Color(0xFFFFFFFF);

  static const Color pastelLavender = Color(0xFFCBC3DC);
  static const Color pastelLavenderLight = Color(0xFFDFD9EC);
  static const Color pastelLavenderDeep = Color(0xFF8C7AAE);

  static const Color pastelRose = Color(0xFFD9B6C4);
  static const Color pastelRoseLight = Color(0xFFEAD4DD);
  static const Color pastelRoseDeep = Color(0xFF9F6E82);

  static const Color pastelSand = Color(0xFFE6DDD2);
  static const Color pastelMint = Color(0xFFCDE2D9);

  // Semantic accents
  static const Color accent = Color(0xFFFFD54A);
  static const Color onAccent = Color(0xFF16151A);
  static const Color charcoal = Color(0xFF16151A);
  static const Color onCharcoal = Color(0xFFFFFFFF);
  static const Color charcoalMuted = Color(0xFF7B7888);

  static const Color success = Color(0xFF288B54);
  static const Color warning = Color(0xFFD98A12);
  static const Color error = Color(0xFFC93B4B);
  static const Color neutralGrey = Color(0xFF7D7A87);

  // Light Mode (Default — Editorial Warm Alabaster + Lavender/Rose/White Cards + Jet-Black Pills)
  static const Color lightPrimary = Color(0xFF16151A);
  static const Color lightPrimaryDeep = Color(0xFF2D2A37);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryTint = Color(0xFFDFD9EC);
  static const Color lightOnPrimaryTint = Color(0xFF16151A);
  static const Color lightBgStart = Color(0xFFEDEBE6);
  static const Color lightBgEnd = Color(0xFFE5E0EC);
  static const Color lightSurface = Color(0xFFF9F8F6);
  static const Color lightSurfaceSubtle = Color(0xFFEFEDE8);
  static const Color lightOnSurface = Color(0xFF16151A);
  static const Color lightOnSurfaceSecondary = Color(0xFF6B6876);
  static const Color lightBorder = Color(0xFFDDD8D0);
  static const Color lightIconBtn = Color(0xFFFFFFFF);
  static const Color lightSuccessTint = Color(0xFFD9EFE3);
  static const Color lightOnSuccessTint = Color(0xFF165B34);
  static const Color lightWarningTint = Color(0xFFF6E7CE);
  static const Color lightOnWarningTint = Color(0xFF6E4400);
  static const Color lightErrorTint = Color(0xFFF7DCDF);
  static const Color lightOnErrorTint = Color(0xFF8C1E2B);
  static const Color lightNeutralTint = Color(0xFFE9E6DF);
  static const Color lightOnNeutralTint = Color(0xFF3E3C46);

  // Dark Mode (Velvet Slate + Muted Lavender/Rose Tints)
  static const Color darkPrimary = Color(0xFFD6CEEE);
  static const Color darkPrimaryDeep = Color(0xFF9C8DC4);
  static const Color darkOnPrimary = Color(0xFF16151A);
  static const Color darkPrimaryTint = Color(0xFF2E2A3C);
  static const Color darkOnPrimaryTint = Color(0xFFEDE8FA);
  static const Color darkBgStart = Color(0xFF14131A);
  static const Color darkBgEnd = Color(0xFF1E1B29);
  static const Color darkSurface = Color(0xFF201E2B);
  static const Color darkSurfaceSubtle = Color(0xFF292636);
  static const Color darkOnSurface = Color(0xFFF5F3FA);
  static const Color darkOnSurfaceSecondary = Color(0xFFA8A4B8);
  static const Color darkBorder = Color(0xFF353144);
  static const Color darkIconBtn = Color(0xFF2B2838);
  static const Color darkSuccessTint = Color(0xFF1A3528);
  static const Color darkOnSuccessTint = Color(0xFF8CE5B1);
  static const Color darkWarningTint = Color(0xFF362B19);
  static const Color darkOnWarningTint = Color(0xFFFFD584);
  static const Color darkErrorTint = Color(0xFF3A1E24);
  static const Color darkOnErrorTint = Color(0xFFFFA3AD);
  static const Color darkNeutralTint = Color(0xFF2C2938);
  static const Color darkOnNeutralTint = Color(0xFFC8C4D6);

  // Spacing tokens
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double pagePad = 16;

  // Border Radius tokens (generous 24-28px rounded editorial cards)
  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 24;
  static const double radiusXl = 28;

  // Editorial pastel avatar palettes
  static const List<List<Color>> avatarGradients = [
    [Color(0xFF8C7AAE), Color(0xFF6B5894)],
    [Color(0xFFB57C92), Color(0xFF94586F)],
    [Color(0xFF6F8FAF), Color(0xFF4F6F8F)],
    [Color(0xFF6A9C89), Color(0xFF4B7D6A)],
    [Color(0xFFC28D6B), Color(0xFF9E6B4B)],
    [Color(0xFF8E7CC3), Color(0xFFB085B8)],
  ];

  static List<Color> gradientForName(String name) {
    final hash = name.codeUnits.fold<int>(0, (a, b) => a + b);
    return avatarGradients[hash % avatarGradients.length];
  }

  /// Cycles through the photo's signature pastel card fills (Lavender, Rose Mauve, Soft Sand/Cream).
  static Color editorialCardColor(int index, {required bool isDark}) {
    if (isDark) {
      return switch (index % 3) {
        0 => const Color(0xFF2D283E), // Dark Lavender
        1 => const Color(0xFF362732), // Dark Rose Mauve
        _ => const Color(0xFF252331), // Dark Warm Slate
      };
    }
    return switch (index % 3) {
      0 => pastelLavender, // Soft Lavender (#CBC3DC)
      1 => pastelRose, // Soft Rose Mauve (#D9B6C4)
      _ => const Color(0xFFFFFFFF), // Crisp White
    };
  }

  static Color editorialCardSubtle(int index, {required bool isDark}) {
    if (isDark) {
      return Colors.white.withValues(alpha: 0.07);
    }
    return switch (index % 3) {
      0 => pastelLavenderLight, // Lighter inner box (#DFD9EC)
      1 => pastelRoseLight, // Lighter inner box (#EAD4DD)
      _ => const Color(0xFFF2EFE9), // Soft Alabaster inner box
    };
  }
}

/// Theme-aware helper colors.
class AppPalette {
  final bool isDark;
  const AppPalette(this.isDark);

  factory AppPalette.of(BuildContext context) =>
      AppPalette(Theme.of(context).brightness == Brightness.dark);

  Color get primary => isDark ? AppTokens.darkPrimary : AppTokens.lightPrimary;
  Color get primaryDeep => isDark ? AppTokens.darkPrimaryDeep : AppTokens.lightPrimaryDeep;
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
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [bgStart, bgEnd],
      );

  /// Signature Lavender Hero gradient matching the photo's "Spatial Aptitude" card.
  LinearGradient get heroGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? const [Color(0xFF38304F), Color(0xFF28223A)]
            : const [Color(0xFFC9C0DC), Color(0xFFDAD3E8)],
      );

  Color get onHero => isDark ? Colors.white : AppTokens.jetBlack;
  Color get onHeroSecondary =>
      isDark ? Colors.white.withValues(alpha: 0.78) : const Color(0xFF4A4656);

  List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.25)
              : const Color(0xFF16151A).withValues(alpha: 0.05),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
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
      secondary: AppTokens.pastelRose,
      onSecondary: AppTokens.jetBlack,
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
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
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
        fillColor: p.isDark ? p.surfaceSubtle : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        labelStyle: TextStyle(color: p.onSurfaceSecondary, fontSize: 13.5),
        hintStyle: TextStyle(color: p.onSurfaceSecondary.withValues(alpha: 0.75), fontSize: 13.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: p.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: p.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: p.primary, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.isDark ? p.neutralTint : Colors.white.withValues(alpha: 0.75),
        selectedColor: p.primary,
        side: BorderSide(color: p.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        labelStyle: TextStyle(
          color: p.onSurface,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, letterSpacing: 0.1),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.onSurface,
          backgroundColor: p.isDark ? Colors.transparent : Colors.white.withValues(alpha: 0.6),
          side: BorderSide(color: p.onSurface.withValues(alpha: 0.25)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: p.isDark ? p.surface : Colors.white.withValues(alpha: 0.92),
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppTokens.jetBlack,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? p.onSurface : p.onSurfaceSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? Colors.white : p.onSurfaceSecondary,
            size: 21,
          );
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
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppTokens.jetBlack,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13.5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

/// TeamUp logo with jet-black & lavender overlapping circles.
class TeamUpLogo extends StatelessWidget {
  final double size;
  const TeamUpLogo({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    final radius = size * 0.34;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTokens.jetBlack,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: AppTokens.jetBlack.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const CustomPaint(
        painter: _LogoPainter(),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 44.0;
    final r = 10.0 * scale;
    final leftPaint = Paint()..color = AppTokens.pastelLavender;
    final rightPaint = Paint()..color = AppTokens.pastelRose;

    canvas.drawCircle(Offset(17.0 * scale, 22.0 * scale), r, leftPaint);
    canvas.drawCircle(Offset(27.0 * scale, 22.0 * scale), r, rightPaint);
  }

  @override
  bool shouldRepaint(covariant _LogoPainter oldDelegate) => false;
}

/// Soft pastel gradient avatar matching the circular portraits in the inspiration image.
class GradientAvatar extends StatelessWidget {
  final String name;
  final String initials;
  final double radius;
  const GradientAvatar({
    super.key,
    required this.name,
    required this.initials,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final pair = AppTokens.gradientForName(name);
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: pair,
        ),
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: radius * 0.65,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

/// Editorial Oversized Stat Badge (`72%`, `95%`) inspired by the "Your progress 72%"
/// and "Pages 24 / Videos 10" typography in the reference photo.
class MatchScoreRing extends StatelessWidget {
  final int score;
  final double size;
  final String? subtitle;
  const MatchScoreRing({
    super.key,
    required this.score,
    this.size = 54,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: p.isDark ? Colors.black.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$score%',
            style: TextStyle(
              fontSize: 22,
              height: 1.05,
              letterSpacing: -0.8,
              fontWeight: FontWeight.w800,
              color: p.onSurface,
            ),
          ),
          Text(
            subtitle ?? 'Match',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: p.onSurfaceSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
