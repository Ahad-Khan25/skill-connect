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
        backgroundColor: p.isDark ? p.neutralTint : Colors.white.withValues(alpha: 0.78),
        selectedColor: AppTokens.jetBlack,
        checkmarkColor: Colors.white,
        side: BorderSide(color: p.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
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

/// SkillConnect 5-Node Glowing Constellation Logo (exact reproduction of uploaded Image 1).
/// - 5 connected nodes: 2 glowing gold/amber nodes on top/right + 3 indigo/violet nodes on left/bottom
/// - All 10 interconnecting edges with a violet-to-gold gradient
class TeamUpLogo extends StatelessWidget {
  final double size;
  const TeamUpLogo({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const CustomPaint(
        painter: _SkillConnectConstellationPainter(),
      ),
    );
  }
}

/// Exact "SkillConnect" two-tone wordmark ("Skill" in white/dark, "Connect" in #635BFF)
/// + optional "Bridging talents, building futures." tagline.
class SkillConnectWordmark extends StatelessWidget {
  final double fontSize;
  final bool showTagline;
  final bool forceDarkCanvas;
  const SkillConnectWordmark({
    super.key,
    this.fontSize = 30,
    this.showTagline = true,
    this.forceDarkCanvas = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final skillColor = forceDarkCanvas ? Colors.white : p.onSurface;
    final subColor = forceDarkCanvas ? const Color(0xFF9E9BB0) : p.onSurfaceSecondary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              height: 1.15,
            ),
            children: [
              TextSpan(text: 'Skill', style: TextStyle(color: skillColor)),
              const TextSpan(text: 'Connect', style: TextStyle(color: Color(0xFF635BFF))),
            ],
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 6),
          Text(
            'Bridging talents, building futures.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize * 0.42,
              fontWeight: FontWeight.w400,
              color: subColor,
            ),
          ),
        ],
      ],
    );
  }
}

class _SkillConnectConstellationPainter extends CustomPainter {
  const _SkillConnectConstellationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 5 node positions matching the uploaded SkillConnect constellation icon:
    // 0: Top-Left (indigo-violet)
    // 1: Top-Center-Right (gold glowing)
    // 2: Far-Right (gold glowing)
    // 3: Bottom-Center (deep purple)
    // 4: Bottom-Left (deep purple)
    final nodes = <Offset>[
      Offset(w * 0.20, h * 0.30),
      Offset(w * 0.56, h * 0.14),
      Offset(w * 0.84, h * 0.50),
      Offset(w * 0.56, h * 0.86),
      Offset(w * 0.20, h * 0.72),
    ];

    const purple = Color(0xFF5D52F2);
    const deepPurple = Color(0xFF473EB8);
    const gold = Color(0xFFF7BE32);

    final nodeColors = <Color>[purple, gold, gold, deepPurple, deepPurple];
    final isGold = <bool>[false, true, true, false, false];

    // Draw all 10 interconnecting edges (complete K5 graph) with gradient lines
    final strokeW = (w * 0.055).clamp(1.6, 5.5);
    for (var i = 0; i < nodes.length; i++) {
      for (var j = i + 1; j < nodes.length; j++) {
        final p1 = nodes[i];
        final p2 = nodes[j];
        final edgePaint = Paint()
          ..strokeWidth = strokeW
          ..strokeCap = StrokeCap.round
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [nodeColors[i], nodeColors[j]],
          ).createShader(Rect.fromPoints(p1, p2));
        canvas.drawLine(p1, p2, edgePaint);
      }
    }

    // Draw soft ambient glow behind the 2 gold nodes & 3 purple nodes
    final nodeRadius = (w * 0.105).clamp(3.0, 14.0);
    for (var i = 0; i < nodes.length; i++) {
      final center = nodes[i];
      final glowColor = isGold[i] ? gold : purple;
      final glowPaint = Paint()
        ..color = glowColor.withValues(alpha: isGold[i] ? 0.38 : 0.22)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, nodeRadius * 1.1);
      canvas.drawCircle(center, nodeRadius * 1.45, glowPaint);

      final fillPaint = Paint()
        ..shader = RadialGradient(
          colors: isGold[i]
              ? const [Color(0xFFFFDF70), Color(0xFFF4B41A)]
              : const [Color(0xFF7B72FF), Color(0xFF493EC4)],
        ).createShader(Rect.fromCircle(center: center, radius: nodeRadius));
      canvas.drawCircle(center, nodeRadius, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SkillConnectConstellationPainter oldDelegate) => false;
}

/// Collaborative Team Illustration from Image 2 (isometric glowing ring of students
/// with laptops, code screens, chat bubbles & puzzle pieces).
class SkillConnectHeroIllustration extends StatelessWidget {
  final double height;
  const SkillConnectHeroIllustration({super.key, this.height = 190});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: height * 1.25,
      child: CustomPaint(
        painter: _HeroCollaborationPainter(),
      ),
    );
  }
}

class _HeroCollaborationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 6;
    final rx = size.width * 0.40;
    final ry = size.height * 0.28;

    // 1. Glowing isometric collaboration orbit rings
    final orbitRect = Rect.fromCenter(center: Offset(cx, cy + 10), width: rx * 2.1, height: ry * 1.9);
    final glowOrbit = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = const Color(0xFF635BFF).withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawOval(orbitRect, glowOrbit);

    final mainOrbit = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = const Color(0xFF8C84FF).withValues(alpha: 0.55);
    canvas.drawOval(orbitRect, mainOrbit);

    // Golden accent arc at bottom
    final goldArc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = const Color(0xFFF7BE32).withValues(alpha: 0.75);
    canvas.drawArc(orbitRect, 0.3, 1.8, false, goldArc);

    // 2. Floating code window on top-left & dashboard window on top-right
    _drawFloatingScreen(
      canvas,
      Offset(cx - rx * 0.85, cy - ry * 0.95),
      const Size(46, 34),
      const Color(0xFF4F46E5),
      const Color(0xFFA5B4FC),
    );
    _drawFloatingScreen(
      canvas,
      Offset(cx + rx * 0.55, cy - ry * 0.95),
      const Size(48, 34),
      const Color(0xFF3B82F6),
      const Color(0xFF86EFAC),
    );

    // 3. Floating chat bubbles (mint green & gold)
    _drawChatBubble(canvas, Offset(cx - 24, cy - ry * 1.25), const Color(0xFF6EE7B7));
    _drawChatBubble(canvas, Offset(cx + 22, cy - ry * 1.05), const Color(0xFFFBBF24));

    // 4. Five team members collaborating around the ring
    _drawTeammateNode(canvas, Offset(cx - rx * 0.55, cy - ry * 0.35), const Color(0xFF7C69FF), hasLaptop: false);
    _drawTeammateNode(canvas, Offset(cx + rx * 0.58, cy - ry * 0.32), const Color(0xFFF59E0B), hasLaptop: false);
    _drawTeammateNode(canvas, Offset(cx + 4, cy + 2), const Color(0xFFA78BFA), hasLaptop: false);
    _drawTeammateNode(canvas, Offset(cx - rx * 0.52, cy + ry * 0.55), const Color(0xFF635BFF), hasLaptop: true);
    _drawTeammateNode(canvas, Offset(cx + rx * 0.50, cy + ry * 0.55), const Color(0xFF34D399), hasLaptop: true);

    // 5. Golden puzzle pieces at bottom center
    final puzzlePaint1 = Paint()..color = const Color(0xFFF7BE32);
    final puzzlePaint2 = Paint()..color = const Color(0xFF635BFF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + 10, cy + ry * 0.95), width: 16, height: 11),
        const Radius.circular(3),
      ),
      puzzlePaint1,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 8, cy + ry * 1.02), width: 16, height: 11),
        const Radius.circular(3),
      ),
      puzzlePaint2,
    );
  }

  void _drawFloatingScreen(Canvas canvas, Offset topLeft, Size s, Color bg, Color line) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(topLeft.dx, topLeft.dy, s.width, s.height),
      const Radius.circular(6),
    );
    canvas.drawRRect(rect, Paint()..color = bg.withValues(alpha: 0.85));
    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.35),
    );
    final lp = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = line;
    canvas.drawLine(Offset(topLeft.dx + 8, topLeft.dy + 10), Offset(topLeft.dx + s.width - 12, topLeft.dy + 10), lp);
    canvas.drawLine(Offset(topLeft.dx + 8, topLeft.dy + 17), Offset(topLeft.dx + s.width - 18, topLeft.dy + 17), lp);
    canvas.drawLine(Offset(topLeft.dx + 8, topLeft.dy + 24), Offset(topLeft.dx + s.width - 8, topLeft.dy + 24), lp);
  }

  void _drawChatBubble(Canvas canvas, Offset center, Color color) {
    final r = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 26, height: 16),
      const Radius.circular(5),
    );
    canvas.drawRRect(r, Paint()..color = color);
    final lineP = Paint()
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF16151A).withValues(alpha: 0.65);
    canvas.drawLine(Offset(center.dx - 7, center.dy - 2), Offset(center.dx + 7, center.dy - 2), lineP);
    canvas.drawLine(Offset(center.dx - 7, center.dy + 3), Offset(center.dx + 3, center.dy + 3), lineP);
  }

  void _drawTeammateNode(Canvas canvas, Offset pos, Color shirtColor, {required bool hasLaptop}) {
    // Glowing platform disc
    canvas.drawOval(
      Rect.fromCenter(center: Offset(pos.dx, pos.dy + 16), width: 34, height: 12),
      Paint()..color = shirtColor.withValues(alpha: 0.30),
    );
    // Torso
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(pos.dx, pos.dy + 5), width: 20, height: 18),
        const Radius.circular(7),
      ),
      Paint()..color = shirtColor,
    );
    // Head
    canvas.drawCircle(
      Offset(pos.dx, pos.dy - 9),
      6.5,
      Paint()..color = const Color(0xFFFDE2C8),
    );
    // Hair
    canvas.drawArc(
      Rect.fromCircle(center: Offset(pos.dx, pos.dy - 10), radius: 6.8),
      3.14,
      3.14,
      true,
      Paint()..color = const Color(0xFF1E1B2E),
    );
    if (hasLaptop) {
      final lapRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(pos.dx + (pos.dx < 100 ? 13 : -13), pos.dy + 2), width: 18, height: 13),
        const Radius.circular(3),
      );
      canvas.drawRRect(lapRect, Paint()..color = Colors.white);
      canvas.drawRRect(
        lapRect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = const Color(0xFF635BFF),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HeroCollaborationPainter oldDelegate) => false;
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
