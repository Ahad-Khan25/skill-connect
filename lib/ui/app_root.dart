// TeamUp – Modern, Responsive, Mobile-First Stitch Design System UI (`lib/ui/app_root.dart`)
// Designed for zero-overflow across 320px-430px mobile phones & desktop/tablet viewports:
//  - Glowing Hero headers, Gradient Avatars, Circular 0-100% Match Score Rings
//  - Interactive Student Detail Bottom Sheet (tap any card to view full portfolio, experience, skills & match breakdown)
//  - Top "+ Project" button & Side Drawer Project Switcher (switching active project dynamically updates Smart Matches!)
//  - "How Smart Match Works" interactive formula explainer modal (great for competition judges!)
//  - Open Teams Board ("Join Open Team" with % Skill Fit ring, green skill match pills & 1-tap Apply)
//  - Personal Profile Setup (University, Dept, Semester, Work Experience, Bio, Skills, Interests, Availability)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/state.dart';
import '../theme/app_theme.dart';

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  // Default to Light Mode to match the uploaded reference photo's Soft Editorial
  // Alabaster + Pastel Lavender/Rose + Jet-Black Pill aesthetic.
  ThemeMode _themeMode = ThemeMode.light;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1300), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeamUp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode,
      home: _Gate(
        showSplash: _showSplash,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

/// Decorative background with subtle ambient glow orbs + Stitch gradient.
class _StitchGradientBackground extends StatelessWidget {
  final Widget child;
  const _StitchGradientBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(gradient: p.backgroundGradient),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -70,
            child: IgnorePointer(
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      p.primary.withValues(alpha: p.isDark ? 0.16 : 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: IgnorePointer(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTokens.accent.withValues(alpha: p.isDark ? 0.08 : 0.14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

/// Constrains content width on large screens while keeping 100% fluid width on mobile phones.
class _ResponsiveContainer extends StatelessWidget {
  final Widget child;
  const _ResponsiveContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: child,
      ),
    );
  }
}

// ============================================================================
// 0. STITCH SPLASH SCREEN (Direct port of teammate's `code.html`)
// ============================================================================
class _StitchSplashScreen extends StatelessWidget {
  const _StitchSplashScreen();

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Scaffold(
      body: _StitchGradientBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.pagePad,
                  vertical: AppTokens.xxl,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 32),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const TeamUpLogo(size: 84),
                        const SizedBox(height: AppTokens.lg),
                        Text(
                          'TeamUp',
                          style: TextStyle(
                            fontSize: 34,
                            height: 40 / 34,
                            letterSpacing: -0.6,
                            fontWeight: FontWeight.w800,
                            color: p.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Find the right teammates.',
                          style: TextStyle(
                            fontSize: 14.5,
                            color: p.onSurfaceSecondary,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppTokens.lg),
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          backgroundColor: p.primaryTint,
                          valueColor: AlwaysStoppedAnimation<Color>(p.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Gate extends StatelessWidget {
  final bool showSplash;
  final VoidCallback onToggleTheme;
  const _Gate({required this.showSplash, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final profile = context.watch<ProfileController>();

    if (showSplash || auth.status == AuthStatus.unknown) {
      return const _StitchSplashScreen();
    }
    if (auth.status == AuthStatus.signedOut) {
      return _AuthScreen(onToggleTheme: onToggleTheme);
    }
    return switch (profile.state) {
      LoadState.loading when profile.me == null => const _StitchSplashScreen(),
      LoadState.error when profile.me == null => Scaffold(
          body: _StitchGradientBackground(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 48, color: AppTokens.error),
                        const SizedBox(height: 12),
                        Text(
                          profile.error ?? 'Failed to load profile',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: profile.refresh,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: context.read<AuthController>().signOut,
                          child: const Text('Sign out'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      _ when !profile.hasProfile => _ProfileEditorScreen(
          isInitialSetup: true,
          onToggleTheme: onToggleTheme,
        ),
      _ => _HomeShell(onToggleTheme: onToggleTheme),
    };
  }
}

// ============================================================================
// 1. AUTH SCREEN (Polished Hero + Quick Demo Hint + Theme Switcher)
// ============================================================================
class _AuthScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const _AuthScreen({required this.onToggleTheme});
  @override
  State<_AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<_AuthScreen> {
  bool _isSignUp = false;
  final _name = TextEditingController(text: 'Ahad Khan');
  final _email = TextEditingController(text: 'demo@teamup.app');
  final _pass = TextEditingController(text: 'password123');

  Future<void> _submit() async {
    final auth = context.read<AuthController>();
    final err = _isSignUp
        ? await auth.signUp(_name.text, _email.text, _pass.text)
        : await auth.signIn(_email.text, _pass.text);
    if (err != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final p = AppPalette.of(context);
    return Scaffold(
      body: _StitchGradientBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: p.primaryTint,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_rounded, size: 14, color: p.primary),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    'University Teammate Finder',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: p.onPrimaryTint,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          tooltip: 'Toggle Light / Dark Theme',
                          onPressed: widget.onToggleTheme,
                          style: IconButton.styleFrom(backgroundColor: p.iconBtn),
                          icon: Icon(
                            p.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                            color: p.isDark ? AppTokens.accent : p.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const TeamUpLogo(size: 76),
                    const SizedBox(height: 14),
                    Text(
                      'TeamUp',
                      style: TextStyle(
                        fontSize: 32,
                        letterSpacing: -0.6,
                        fontWeight: FontWeight.w800,
                        color: p.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Match by skills, build balanced FYP & semester teams.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13.5, color: p.onSurfaceSecondary),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      decoration: BoxDecoration(
                        color: p.surface,
                        borderRadius: BorderRadius.circular(AppTokens.radiusXl),
                        border: Border.all(color: p.border),
                        boxShadow: p.cardShadow,
                      ),
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: p.surfaceSubtle,
                              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                              border: Border.all(color: p.border),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _AuthTabBtn(
                                    label: 'Sign In',
                                    selected: !_isSignUp,
                                    onTap: () => setState(() => _isSignUp = false),
                                  ),
                                ),
                                Expanded(
                                  child: _AuthTabBtn(
                                    label: 'Create Account',
                                    selected: _isSignUp,
                                    onTap: () => setState(() => _isSignUp = true),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          if (_isSignUp) ...[
                            TextField(
                              controller: _name,
                              decoration: const InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: Icon(Icons.person_outline_rounded),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          TextField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'University Email',
                              prefixIcon: Icon(Icons.alternate_email_rounded),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _pass,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password (min 6 chars)',
                              prefixIcon: Icon(Icons.lock_outline_rounded),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              color: p.primaryTint.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.auto_awesome_rounded, size: 16, color: p.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _isSignUp
                                        ? 'Step 1: Set up your personal skills, university & experience.\nStep 2: Create projects or apply to open teams inside!'
                                        : 'Demo ready: Tap Sign In to explore 18 student profiles, 2 active projects, 5 open teams & 3 requests.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: p.onPrimaryTint,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          FilledButton.icon(
                            onPressed: auth.busy ? null : _submit,
                            icon: auth.busy
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: p.onPrimary,
                                    ),
                                  )
                                : Icon(
                                    _isSignUp
                                        ? Icons.arrow_forward_rounded
                                        : Icons.login_rounded,
                                    size: 18,
                                  ),
                            label: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(_isSignUp ? 'Continue to Profile Setup' : 'Sign In to TeamUp'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthTabBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _AuthTabBtn({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? p.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? p.onPrimary : p.onSurfaceSecondary,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 2. HOME SHELL (Responsive Mobile Header + Side Drawer + 5 Bottom Nav Tabs)
// ============================================================================
class _HomeShell extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const _HomeShell({required this.onToggleTheme});
  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final req = context.watch<RequestsController>();
    final disc = context.watch<DiscoverController>();
    final profile = context.watch<ProfileController>();
    final tc = context.watch<TeamController>();
    final p = AppPalette.of(context);
    final isOffline = disc.offline || profile.offline || req.offline;
    final me = profile.me;
    final screenW = MediaQuery.sizeOf(context).width;
    final isCompactPhone = screenW < 380;

    final pages = [
      const _MatchesTab(),
      const _DiscoverTab(),
      const _ProjectsAndJoinTeamsTab(),
      const _RequestsTab(),
      _ProfileTab(onToggleTheme: widget.onToggleTheme),
    ];

    return Scaffold(
      drawer: Drawer(
        backgroundColor: p.surface,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (me != null)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: p.heroGradient,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GradientAvatar(name: me.name, initials: me.initials, radius: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  me.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${me.university} • Sem ${me.semester}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  me.department,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Colors.white.withValues(alpha: 0.75),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showCreateProjectDialog(context);
                  },
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                  label: const Text('Add New Project'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                child: Text(
                  'MY PROJECTS (SWITCH ACTIVE MATCHING)',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: p.onSurfaceSecondary,
                  ),
                ),
              ),
              if (tc.myTeams.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No projects created yet. Tap "Add New Project" above to post a Semester Project or FYP and get tailored teammate matches!',
                    style: TextStyle(fontSize: 12.5, color: p.onSurfaceSecondary),
                  ),
                )
              else
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      for (final t in tc.myTeams)
                        ListTile(
                          selected: tc.team?.id == t.id,
                          leading: Icon(
                            tc.team?.id == t.id
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_off_rounded,
                            color: tc.team?.id == t.id ? p.primary : p.onSurfaceSecondary,
                          ),
                          onTap: () {
                            tc.selectActiveTeam(t.id);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Active project switched to "${t.title}" — Smart Matches updated!',
                                ),
                              ),
                            );
                          },
                          title: Text(
                            t.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                          ),
                          subtitle: Text(
                            '${t.projectType} • ${t.openRoles.length} open role(s)',
                            style: TextStyle(fontSize: 11.5, color: p.onSurfaceSecondary),
                          ),
                        ),
                    ],
                  ),
                ),
              if (tc.myTeams.isEmpty) const Spacer(),
              Divider(color: p.border, height: 1),
              ListTile(
                dense: true,
                leading: const Icon(Icons.calculate_outlined),
                title: const Text('How Smart Match Scoring Works'),
                onTap: () {
                  Navigator.pop(context);
                  _showMatchFormulaSheet(context);
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit My Profile'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _ProfileEditorScreen(
                        isInitialSetup: false,
                        onToggleTheme: widget.onToggleTheme,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                dense: true,
                leading: Icon(p.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                title: Text(p.isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode'),
                onTap: widget.onToggleTheme,
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.logout_rounded, color: AppTokens.error),
                title: const Text('Sign Out', style: TextStyle(color: AppTokens.error)),
                onTap: () {
                  Navigator.pop(context);
                  context.read<AuthController>().signOut();
                },
              ),
            ],
          ),
        ),
      ),
      body: _StitchGradientBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Hero Editorial Header (matches "Hello, Anna / Your Custom Syllabus" + white circular action buttons)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Builder(
                          builder: (ctx) => GestureDetector(
                            onTap: () => Scaffold.of(ctx).openDrawer(),
                            child: me != null
                                ? GradientAvatar(name: me.name, initials: me.initials, radius: 20)
                                : const TeamUpLogo(size: 38),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                me != null ? 'Hello, ${me.name.split(' ').first}' : 'TeamUp',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: p.onSurfaceSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                [
                                  'Smart Matches',
                                  'Discover Students',
                                  'Projects & Teams',
                                  'Team Requests',
                                  'My Profile',
                                ][_tab],
                                style: TextStyle(
                                  fontSize: isCompactPhone ? 21 : 24,
                                  height: 1.15,
                                  fontWeight: FontWeight.w800,
                                  color: p.onSurface,
                                  letterSpacing: -0.6,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Jet-Black "+ New Project" pill button (like the '+' & black pills in the photo)
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTokens.jetBlack,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: isCompactPhone ? 10 : 14,
                              vertical: 8,
                            ),
                            minimumSize: const Size(0, 38),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => _showCreateProjectDialog(context),
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: Text(
                            isCompactPhone ? 'New' : 'New Project',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // White circular icon button (matches top-right circle buttons in photo)
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: p.iconBtn,
                            shape: BoxShape.circle,
                            border: Border.all(color: p.border),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            tooltip: 'Toggle Light / Dark Mode',
                            onPressed: widget.onToggleTheme,
                            icon: Icon(
                              p.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                              size: 18,
                              color: p.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Builder(
                          builder: (ctx) => Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: p.iconBtn,
                              shape: BoxShape.circle,
                              border: Border.all(color: p.border),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              tooltip: 'Projects & Menu',
                              onPressed: () => Scaffold.of(ctx).openDrawer(),
                              icon: Icon(Icons.more_horiz_rounded, size: 19, color: p.onSurface),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isOffline)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                    color: p.warningTint,
                    borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                    border: Border.all(color: AppTokens.warning.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off_rounded, size: 14, color: p.onWarningTint),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Offline mode — showing saved local data',
                          style: TextStyle(
                            color: p.onWarningTint,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: _ResponsiveContainer(child: pages[_tab]),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: p.border)),
        ),
        child: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(Icons.auto_awesome_rounded),
              label: 'Matches',
            ),
            const NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore_rounded),
              label: 'Discover',
            ),
            const NavigationDestination(
              icon: Icon(Icons.workspaces_outline),
              selectedIcon: Icon(Icons.workspaces_rounded),
              label: 'Projects',
            ),
            NavigationDestination(
              icon: Badge(
                backgroundColor: AppTokens.accent,
                textColor: AppTokens.onAccent,
                isLabelVisible: req.pendingReceivedCount > 0,
                label: Text(
                  '${req.pendingReceivedCount}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                child: const Icon(Icons.mail_outline_rounded),
              ),
              selectedIcon: Badge(
                backgroundColor: AppTokens.accent,
                textColor: AppTokens.onAccent,
                isLabelVisible: req.pendingReceivedCount > 0,
                label: Text(
                  '${req.pendingReceivedCount}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                child: const Icon(Icons.mail_rounded),
              ),
              label: 'Requests',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TAB 1: SMART MATCH (Hero Project Card + Skill Gap + Circular Score Ring Cards)
// ============================================================================
class _MatchesTab extends StatelessWidget {
  const _MatchesTab();

  @override
  Widget build(BuildContext context) {
    final mc = context.watch<MatchController>();
    final req = context.watch<RequestsController>();
    final tc = context.watch<TeamController>();
    final p = AppPalette.of(context);

    if (mc.state == LoadState.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (mc.state == LoadState.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mc.error ?? 'Error loading matches'),
            const SizedBox(height: 8),
            FilledButton(onPressed: mc.refresh, child: const Text('Retry')),
          ],
        ),
      );
    }

    final gap = mc.skillGap;
    final activeTeam = tc.team;

    return RefreshIndicator(
      onRefresh: mc.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
        itemCount: mc.matches.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Editorial Pastel Lavender Hero Card (inspired by "Spatial Aptitude" card in photo)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: p.heroGradient,
                    borderRadius: BorderRadius.circular(AppTokens.radiusXl),
                    boxShadow: p.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Text(
                            'ACTIVE PROJECT MATCHING',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              letterSpacing: 0.6,
                              color: p.onHeroSecondary,
                            ),
                          ),
                          InkWell(
                            onTap: () => _showMatchFormulaSheet(context),
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: p.isDark ? 0.14 : 0.65),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'How Score Works',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: p.onHero,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (tc.myTeams.isEmpty)
                        Text(
                          'Matching on your personal profile. Tap "+ New Project" above to create a Semester Project or FYP with specific required skills!',
                          style: TextStyle(
                            fontSize: 13,
                            color: p.onHero,
                            height: 1.35,
                          ),
                        )
                      else ...[
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final t in tc.myTeams)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                    onTap: () => tc.selectActiveTeam(t.id),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 140),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: activeTeam?.id == t.id
                                            ? AppTokens.jetBlack
                                            : Colors.white.withValues(alpha: p.isDark ? 0.14 : 0.65),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        '${t.title} (${t.projectType})',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: activeTeam?.id == t.id
                                              ? Colors.white
                                              : p.onHero,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (activeTeam != null) ...[
                          const SizedBox(height: 12),
                          // Inner translucent stat box like "Pages 24 / Videos 10" in the photo
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: p.isDark ? 0.08 : 0.55),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (activeTeam.description.isNotEmpty) ...[
                                  Text(
                                    activeTeam.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: p.onHeroSecondary,
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                                Wrap(
                                  spacing: 22,
                                  runSpacing: 8,
                                  crossAxisAlignment: WrapCrossAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Candidates', style: TextStyle(fontSize: 11, color: p.onHeroSecondary)),
                                        Text(
                                          '${mc.matches.length}',
                                          style: TextStyle(
                                            fontSize: 26,
                                            height: 1.1,
                                            fontWeight: FontWeight.w800,
                                            color: p.onHero,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Open Roles', style: TextStyle(fontSize: 11, color: p.onHeroSecondary)),
                                        Text(
                                          '${activeTeam.openRoles.length}',
                                          style: TextStyle(
                                            fontSize: 26,
                                            height: 1.1,
                                            fontWeight: FontWeight.w800,
                                            color: p.onHero,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Skill Gap', style: TextStyle(fontSize: 11, color: p.onHeroSecondary)),
                                        Text(
                                          '${gap.length}',
                                          style: TextStyle(
                                            fontSize: 26,
                                            height: 1.1,
                                            fontWeight: FontWeight.w800,
                                            color: p.onHero,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),

                // Skill Gap Banner
                if (gap.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: p.isDark ? p.warningTint : Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: p.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Missing Skills for ${activeTeam != null ? '"${activeTeam.title}"' : 'Your Team'} (${gap.length} needed):',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                            color: p.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: gap
                              .map((s) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: p.isDark ? p.surface : AppTokens.pastelRoseLight,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      s,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: p.onSurface,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }

          final m = mc.matches[index - 1];
          final student = m.profile;
          final hasPending = req.hasPendingTo(student.id);
          final rank = index;
          final cardBg = AppTokens.editorialCardColor(index - 1, isDark: p.isDark);
          final innerBg = AppTokens.editorialCardSubtle(index - 1, isDark: p.isDark);

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(AppTokens.radiusXl),
                boxShadow: p.cardShadow,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppTokens.radiusXl),
                onTap: () => _showStudentDetailSheet(context, student, m),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row: Avatar + Name/University/Dept + Big Editorial Percentage (72% style)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GradientAvatar(name: student.name, initials: student.initials, radius: 23),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      student.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 17,
                                        letterSpacing: -0.3,
                                        color: p.onSurface,
                                      ),
                                    ),
                                    if (rank <= 3)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppTokens.jetBlack,
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          '#$rank Top Match',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    _MetaPill(icon: Icons.account_balance_rounded, text: student.university),
                                    _MetaPill(
                                      icon: Icons.school_rounded,
                                      text: '${kDepartmentShort[student.department] ?? student.department} • Sem ${student.semester}',
                                    ),
                                    _MetaPill(icon: Icons.folder_special_rounded, text: student.projectType),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          MatchScoreRing(score: m.score, size: 52, subtitle: 'Match'),
                        ],
                      ),

                      if (student.workExperience.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: innerBg,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.work_outline_rounded, size: 15, color: p.onSurface),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  student.workExperience,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: p.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      if (student.bio.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          student.bio,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, color: p.onSurface.withValues(alpha: 0.78), height: 1.35),
                        ),
                      ],

                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: student.skills.map((s) {
                          final matched = m.matchedSkills.contains(s);
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                            decoration: BoxDecoration(
                              color: matched
                                  ? AppTokens.jetBlack
                                  : Colors.white.withValues(alpha: p.isDark ? 0.1 : 0.7),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              matched ? '✓ $s' : s,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: matched ? FontWeight.w700 : FontWeight.w600,
                                color: matched ? Colors.white : p.onSurface,
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      if (m.reasons.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: innerBg,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'WHY YOU MATCH',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10.5,
                                  letterSpacing: 0.5,
                                  color: p.onSurfaceSecondary,
                                ),
                              ),
                              const SizedBox(height: 5),
                              for (final r in m.reasons)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 3),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.check_circle_rounded, size: 14, color: p.onSurface),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          r,
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: p.onSurface),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Text(
                            'Free: ${student.availability.join(', ')}',
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: p.onSurfaceSecondary),
                          ),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () => _showStudentDetailSheet(context, student, m),
                                child: const Text('Profile', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                              ),
                              FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppTokens.jetBlack,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: hasPending
                                    ? null
                                    : () => _showSendRequestDialog(context, student),
                                icon: Icon(
                                  hasPending ? Icons.hourglass_top_rounded : Icons.north_east_rounded,
                                  size: 15,
                                ),
                                label: Text(
                                  hasPending
                                      ? 'Pending'
                                      : (activeTeam != null ? 'Invite' : 'Connect'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: p.surfaceSubtle,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: p.border),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: p.onSurfaceSecondary,
        ),
      ),
    );
  }
}

// ============================================================================
// TAB 2: DISCOVER + SEARCH + 5 FILTERS (University, Department, Semester, Skill, Project Type)
// ============================================================================
class _DiscoverTab extends StatelessWidget {
  const _DiscoverTab();

  @override
  Widget build(BuildContext context) {
    final dc = context.watch<DiscoverController>();
    final mc = context.watch<MatchController>();
    final req = context.watch<RequestsController>();
    final p = AppPalette.of(context);
    final f = dc.filters;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: dc.setQuery,
                  decoration: InputDecoration(
                    hintText: 'Search by name, university, or skill...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: dc.query.isNotEmpty
                        ? IconButton(
                            onPressed: () => dc.setQuery(''),
                            icon: const Icon(Icons.clear_rounded),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<SortOption>(
                tooltip: 'Sort students',
                initialValue: dc.sort,
                onSelected: dc.setSort,
                itemBuilder: (_) => const [
                  PopupMenuItem(value: SortOption.bestMatch, child: Text('Sort: Best Match')),
                  PopupMenuItem(value: SortOption.name, child: Text('Sort: Name (A–Z)')),
                  PopupMenuItem(value: SortOption.semester, child: Text('Sort: Semester')),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: p.surface,
                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                    border: Border.all(color: p.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sort_rounded, size: 18, color: p.primary),
                      const SizedBox(width: 5),
                      Text(
                        switch (dc.sort) {
                          SortOption.bestMatch => 'Match',
                          SortOption.name => 'A–Z',
                          SortOption.semester => 'Sem',
                        },
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            children: [
              _FilterDropdown<String>(
                label: f.university ?? 'University',
                active: f.university != null,
                items: kUniversities,
                onSelected: (v) => dc.setFilters(
                  v == null ? f.copyWith(clearUniversity: true) : f.copyWith(university: v),
                ),
              ),
              const SizedBox(width: 8),
              _FilterDropdown<String>(
                label: f.department ?? 'Department',
                active: f.department != null,
                items: kDepartments,
                onSelected: (v) => dc.setFilters(
                  v == null ? f.copyWith(clearDepartment: true) : f.copyWith(department: v),
                ),
              ),
              const SizedBox(width: 8),
              _FilterDropdown<int>(
                label: f.semester != null ? 'Sem ${f.semester}' : 'Semester',
                active: f.semester != null,
                items: kSemesters,
                onSelected: (v) => dc.setFilters(
                  v == null ? f.copyWith(clearSemester: true) : f.copyWith(semester: v),
                ),
              ),
              const SizedBox(width: 8),
              _FilterDropdown<String>(
                label: f.skill ?? 'Skill',
                active: f.skill != null,
                items: kSkills,
                onSelected: (v) => dc.setFilters(
                  v == null ? f.copyWith(clearSkill: true) : f.copyWith(skill: v),
                ),
              ),
              const SizedBox(width: 8),
              _FilterDropdown<String>(
                label: f.projectType ?? 'Project Type',
                active: f.projectType != null,
                items: kProjectTypes,
                onSelected: (v) => dc.setFilters(
                  v == null ? f.copyWith(clearProjectType: true) : f.copyWith(projectType: v),
                ),
              ),
              if (dc.hasActiveFilters) ...[
                const SizedBox(width: 8),
                ActionChip(
                  avatar: const Icon(Icons.close_rounded, size: 15),
                  label: const Text('Reset'),
                  onPressed: dc.clearFilters,
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 8,
            runSpacing: 2,
            children: [
              Text(
                'Showing ${dc.results.length} student(s)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: p.onSurfaceSecondary),
              ),
              Text(
                'Tap any card for details',
                style: TextStyle(fontSize: 11.5, color: p.onSurfaceSecondary),
              ),
            ],
          ),
        ),
        Expanded(
          child: switch (dc.state) {
            LoadState.loading => const Center(child: CircularProgressIndicator()),
            LoadState.error => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(dc.error ?? 'Failed to load students'),
                    const SizedBox(height: 8),
                    FilledButton(onPressed: dc.refresh, child: const Text('Retry')),
                  ],
                ),
              ),
            LoadState.empty => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off_rounded, size: 48, color: p.onSurfaceSecondary),
                      const SizedBox(height: 8),
                      const Text('No students match your current search or filters.'),
                      if (dc.hasActiveFilters) ...[
                        const SizedBox(height: 8),
                        OutlinedButton(onPressed: dc.clearFilters, child: const Text('Clear all filters')),
                      ],
                    ],
                  ),
                ),
              ),
            LoadState.ready => ListView.builder(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
                itemCount: dc.results.length,
                itemBuilder: (context, i) {
                  final student = dc.results[i];
                  final match = mc.matchFor(student.id);
                  final hasPending = req.hasPendingTo(student.id);
                  final cardBg = AppTokens.editorialCardColor(i, isDark: p.isDark);
                  final innerBg = AppTokens.editorialCardSubtle(i, isDark: p.isDark);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(AppTokens.radiusXl),
                        boxShadow: p.cardShadow,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppTokens.radiusXl),
                        onTap: () => _showStudentDetailSheet(context, student, match),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GradientAvatar(name: student.name, initials: student.initials, radius: 22),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          student.name,
                                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                        ),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          children: [
                                            _MetaPill(icon: Icons.account_balance_rounded, text: student.university),
                                            _MetaPill(
                                              icon: Icons.school_rounded,
                                              text: '${kDepartmentShort[student.department] ?? student.department} • Sem ${student.semester}',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (match != null)
                                    MatchScoreRing(score: match.score, size: 46),
                                ],
                              ),
                              if (student.workExperience.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: innerBg,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    'Experience: ${student.workExperience}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: p.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                              if (student.bio.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  student.bio,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12.5, color: p.onSurface.withValues(alpha: 0.78)),
                                ),
                              ],
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 5,
                                runSpacing: 5,
                                children: student.skills
                                    .map((s) => Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: p.isDark ? 0.1 : 0.7),
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            s,
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: p.onSurface),
                                          ),
                                        ))
                                    .toList(),
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppTokens.jetBlack,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: hasPending
                                      ? null
                                      : () => _showSendRequestDialog(context, student),
                                  icon: Icon(
                                    hasPending
                                        ? Icons.hourglass_top_rounded
                                        : Icons.north_east_rounded,
                                    size: 15,
                                  ),
                                  label: Text(hasPending ? 'Request Pending' : 'Connect'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          },
        ),
      ],
    );
  }
}

class _FilterDropdown<T extends Object> extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.active,
    required this.items,
    required this.onSelected,
  });
  final String label;
  final bool active;
  final List<T> items;
  final ValueChanged<T?> onSelected;

  static const Object _kClearSentinel = Object();

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return PopupMenuButton<Object>(
      onSelected: (val) {
        if (identical(val, _kClearSentinel)) {
          onSelected(null);
        } else {
          onSelected(val as T);
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem<Object>(
          value: _kClearSentinel,
          child: Row(
            children: [
              Icon(Icons.clear_rounded, size: 16, color: p.primary),
              const SizedBox(width: 6),
              const Text('Any (clear)', style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        for (final item in items)
          PopupMenuItem<Object>(
            value: item,
            child: Text('$item'),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: active ? p.primaryTint : p.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: active ? p.primary : p.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? p.onPrimaryTint : p.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            if (active)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelected(null),
                child: Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Icon(
                    Icons.cancel_rounded,
                    size: 15,
                    color: p.onPrimaryTint,
                  ),
                ),
              )
            else
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: p.onSurfaceSecondary,
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TAB 3: PROJECTS & OPEN TEAMS (3 Sub-Screens!)
//   1) "My Projects" — projects I created; tap any project to open the full
//      Project Details Screen (edit project details, view/remove team members,
//      set active for Smart Match, or disband).
//   2) "Joined Projects" — projects of other people that I have joined; tap to
//      see project details, team lead, and my assigned role & responsibilities!
//   3) "Join Open Team" — browse public teams looking for skills & apply.
// ============================================================================
class _ProjectsAndJoinTeamsTab extends StatelessWidget {
  const _ProjectsAndJoinTeamsTab();

  @override
  Widget build(BuildContext context) {
    final tc = context.watch<TeamController>();
    final p = AppPalette.of(context);
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: p.isDark ? p.surface : Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(999),
            ),
            child: TabBar(
              isScrollable: false,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppTokens.jetBlack,
                borderRadius: BorderRadius.circular(999),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: p.onSurface,
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
              tabs: [
                Tab(text: 'My Projects (${tc.ownedTeams.length})'),
                Tab(text: 'Joined (${tc.joinedTeams.length})'),
                Tab(text: 'Open Teams (${tc.openTeams.length})'),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _MyProjectsList(),
                _JoinedProjectsList(),
                _OpenTeamsBoard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OpenTeamsBoard extends StatefulWidget {
  const _OpenTeamsBoard();
  @override
  State<_OpenTeamsBoard> createState() => _OpenTeamsBoardState();
}

class _OpenTeamsBoardState extends State<_OpenTeamsBoard> {
  String? _filterSkill;
  String? _filterType;

  @override
  Widget build(BuildContext context) {
    final tc = context.watch<TeamController>();
    final mc = context.watch<MatchController>();
    final rc = context.watch<RequestsController>();
    final me = context.watch<ProfileController>().me;
    final p = AppPalette.of(context);

    var teams = tc.openTeams.where((t) {
      if (_filterType != null && t.projectType != _filterType) return false;
      if (_filterSkill != null &&
          !t.requiredSkills.contains(_filterSkill) &&
          !t.openRoles.any((r) => (kRoleSkills[r] ?? const []).contains(_filterSkill))) {
        return false;
      }
      return true;
    }).toList();

    teams.sort((a, b) => mc.teamFitScore(b).compareTo(mc.teamFitScore(a)));

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 4),
          child: Row(
            children: [
              Text(
                'Filter open teams:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: p.onSurfaceSecondary),
              ),
              const SizedBox(width: 8),
              _FilterDropdown<String>(
                label: _filterSkill ?? 'Required Skill',
                active: _filterSkill != null,
                items: kSkills,
                onSelected: (v) => setState(() => _filterSkill = v),
              ),
              const SizedBox(width: 8),
              _FilterDropdown<String>(
                label: _filterType ?? 'Project Type',
                active: _filterType != null,
                items: kProjectTypes,
                onSelected: (v) => setState(() => _filterType = v),
              ),
              if (_filterSkill != null || _filterType != null) ...[
                const SizedBox(width: 8),
                ActionChip(
                  label: const Text('Clear'),
                  onPressed: () => setState(() {
                    _filterSkill = null;
                    _filterType = null;
                  }),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: teams.isEmpty
              ? const Center(child: Text('No open teams match those filters right now.'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
                  itemCount: teams.length,
                  itemBuilder: (context, i) {
                    final t = teams[i];
                    final owner = t.owner?.profile ?? t.members.firstOrNull?.profile;
                    final fit = mc.teamFitScore(t);
                    final applied = rc.hasPendingForTeam(t.id) ||
                        (owner != null && rc.hasPendingTo(owner.id));
                    final mySkills = me?.skills.toSet() ?? const <String>{};

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: p.surface,
                          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                          border: Border.all(color: p.border),
                          boxShadow: p.cardShadow,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: p.heroGradient,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.workspaces_rounded, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.title,
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                      ),
                                      const SizedBox(height: 3),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: [
                                          _MetaPill(icon: Icons.folder_special_rounded, text: t.projectType),
                                          if (owner != null)
                                            _MetaPill(
                                              icon: Icons.person_outline_rounded,
                                              text: '${owner.name} • ${owner.university}',
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                MatchScoreRing(score: fit, size: 50, subtitle: 'FIT'),
                              ],
                            ),
                            if (t.description.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                t.description,
                                style: TextStyle(fontSize: 13, color: p.onSurface, height: 1.38),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Text(
                              'OPEN ROLES NEEDED',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 10.5,
                                letterSpacing: 0.5,
                                color: p.onSurfaceSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: t.openRoles
                                  .map((r) => Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: p.warningTint,
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.person_search_rounded, size: 13, color: p.onWarningTint),
                                            const SizedBox(width: 4),
                                            Text(
                                              r,
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w700,
                                                color: p.onWarningTint,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            ),
                            if (t.requiredSkills.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                'SKILLS THEY NEED (GREEN = YOU HAVE IT)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10.5,
                                  letterSpacing: 0.5,
                                  color: p.onSurfaceSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: t.requiredSkills.map((s) {
                                  final hasIt = mySkills.contains(s);
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: hasIt ? p.successTint : p.neutralTint,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      s,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: hasIt ? FontWeight.w700 : FontWeight.w500,
                                        color: hasIt ? p.onSuccessTint : p.onNeutralTint,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                            const SizedBox(height: 14),
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Text(
                                  'Members (${t.members.length}): ${t.members.map((m) => m.profile.name.split(' ').first).join(', ')}',
                                  style: TextStyle(fontSize: 12, color: p.onSurfaceSecondary),
                                ),
                                FilledButton.icon(
                                  onPressed: applied ? null : () => _showApplyToTeamDialog(context, t),
                                  icon: Icon(
                                    applied ? Icons.check_rounded : Icons.how_to_reg_rounded,
                                    size: 16,
                                  ),
                                  label: Text(applied ? 'Application Sent' : 'Apply to Join Team'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _MyProjectsList extends StatelessWidget {
  const _MyProjectsList();

  @override
  Widget build(BuildContext context) {
    final tc = context.watch<TeamController>();
    final p = AppPalette.of(context);
    final owned = tc.ownedTeams;

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: p.heroGradient,
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
            boxShadow: p.cardShadow,
          ),
          child: Row(
            children: [
              const Icon(Icons.rocket_launch_rounded, color: AppTokens.accent, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Created Projects',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap any project card below to view full details, edit project requirements, or manage/remove team members.',
                      style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.88)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppTokens.accent,
                  foregroundColor: AppTokens.onAccent,
                ),
                onPressed: () => _showCreateProjectDialog(context),
                child: const Text('+ Add'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (owned.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(
                'You haven\'t created any projects yet.\nTap "+ Add" above to create your first Semester Project or FYP!',
                textAlign: TextAlign.center,
                style: TextStyle(color: p.onSurfaceSecondary),
              ),
            ),
          ),
        for (final team in owned)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                border: Border.all(
                  color: tc.team?.id == team.id ? p.primary : p.border,
                  width: tc.team?.id == team.id ? 2 : 1,
                ),
                boxShadow: p.cardShadow,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => _ProjectDetailScreen(projectId: team.id)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                team.title,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16.5),
                              ),
                              Text(
                                '${team.projectType} • ${team.members.length} member(s) • ${team.openRoles.length} open role(s)',
                                style: TextStyle(fontSize: 12.5, color: p.onSurfaceSecondary),
                              ),
                            ],
                          ),
                          if (tc.team?.id == team.id)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: p.successTint,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Active for Matching',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: p.onSuccessTint,
                                ),
                              ),
                            )
                          else
                            OutlinedButton(
                              onPressed: () => tc.selectActiveTeam(team.id),
                              child: const Text('Use for Matching'),
                            ),
                        ],
                      ),
                      if (team.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          team.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: p.onSurface, fontSize: 13),
                        ),
                      ],
                      if (team.requiredSkills.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: team.requiredSkills
                              .map((s) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: p.neutralTint,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(s, style: TextStyle(fontSize: 11, color: p.onNeutralTint)),
                                  ))
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Divider(color: p.border, height: 1),
                      const SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Text(
                            'Members: ${team.members.map((m) => m.profile.name.split(' ').first).join(', ')}',
                            style: TextStyle(fontSize: 12, color: p.onSurfaceSecondary),
                          ),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => _showEditProjectDialog(context, team),
                                icon: const Icon(Icons.edit_outlined, size: 15),
                                label: const Text('Edit'),
                              ),
                              FilledButton.tonalIcon(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => _ProjectDetailScreen(projectId: team.id),
                                  ),
                                ),
                                icon: const Icon(Icons.open_in_new_rounded, size: 15),
                                label: const Text('Manage Team'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Screen/Tab showing projects created by other students that I have joined,
/// along with my assigned role & specific responsibilities to perform.
class _JoinedProjectsList extends StatelessWidget {
  const _JoinedProjectsList();

  @override
  Widget build(BuildContext context) {
    final tc = context.watch<TeamController>();
    final p = AppPalette.of(context);
    final joined = tc.joinedTeams;

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: p.primaryTint,
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
            border: Border.all(color: p.primary.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Icon(Icons.assignment_ind_rounded, color: p.onPrimaryTint, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Projects I Have Joined & My Responsibilities',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: p.onPrimaryTint,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap any joined project below to view your assigned role, checklist of responsibilities, and teammates.',
                      style: TextStyle(fontSize: 12, color: p.onPrimaryTint.withValues(alpha: 0.9)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (joined.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(
                'You haven\'t joined another student\'s project yet.\nBrowse "Open Teams" to apply or accept an invitation in Requests!',
                textAlign: TextAlign.center,
                style: TextStyle(color: p.onSurfaceSecondary),
              ),
            ),
          ),
        for (final team in joined)
          Builder(
            builder: (context) {
              final myRole = tc.myRoleIn(team);
              final owner = team.owner?.profile;
              final duties = kRoleResponsibilities[myRole] ?? kRoleResponsibilities['Member']!;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: p.surface,
                    borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                    border: Border.all(color: p.border),
                    boxShadow: p.cardShadow,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => _ProjectDetailScreen(projectId: team.id)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    team.title,
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                  ),
                                  Text(
                                    '${team.projectType} • Project Lead: ${owner?.name ?? 'Student'}',
                                    style: TextStyle(fontSize: 12, color: p.onSurfaceSecondary),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: p.successTint,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'My Role: $myRole',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: p.onSuccessTint,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (team.description.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(team.description, style: TextStyle(fontSize: 13, color: p.onSurface)),
                          ],
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: p.surfaceSubtle,
                              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                              border: Border.all(color: p.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'MY RESPONSIBILITIES AS ${myRole.toUpperCase()}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10.5,
                                    letterSpacing: 0.5,
                                    color: p.primary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                for (final d in duties)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.task_alt_rounded, size: 15, color: p.onSuccessTint),
                                        const SizedBox(width: 7),
                                        Expanded(
                                          child: Text(d, style: const TextStyle(fontSize: 12.5)),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Text(
                                'Team (${team.members.length}): ${team.members.map((m) => m.profile.name.split(' ').first).join(', ')}',
                                style: TextStyle(fontSize: 12, color: p.onSurfaceSecondary),
                              ),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(foregroundColor: AppTokens.error),
                                    onPressed: () => _confirmLeaveTeam(context, team),
                                    child: const Text('Leave Project'),
                                  ),
                                  FilledButton.tonalIcon(
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => _ProjectDetailScreen(projectId: team.id),
                                      ),
                                    ),
                                    icon: const Icon(Icons.visibility_outlined, size: 15),
                                    label: const Text('Full Details'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

/// Dedicated Full-Screen Project Details view when a user clicks on any of
/// their created or joined projects:
///  - Shows project title, type, description, required skills & domain tags
///  - If I own the project: "Edit Project Details" button + "Remove Member" button next to each member
///  - Shows my assigned role & interactive responsibilities checklist
class _ProjectDetailScreen extends StatefulWidget {
  final String projectId;
  const _ProjectDetailScreen({required this.projectId});

  @override
  State<_ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<_ProjectDetailScreen> {
  final Set<int> _completedTasks = {0};

  @override
  Widget build(BuildContext context) {
    final tc = context.watch<TeamController>();
    final p = AppPalette.of(context);
    final team = tc.myTeams.where((t) => t.id == widget.projectId).firstOrNull;

    if (team == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Project Details')),
        body: const Center(child: Text('Project no longer exists.')),
      );
    }

    final myRole = tc.myRoleIn(team);
    final duties = kRoleResponsibilities[myRole] ?? kRoleResponsibilities['Member']!;

    return Scaffold(
      appBar: AppBar(
        title: Text(team.title, overflow: TextOverflow.ellipsis),
        actions: [
          if (team.iAmOwner)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton.tonalIcon(
                onPressed: () => _showEditProjectDialog(context, team),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit Project'),
              ),
            ),
        ],
      ),
      body: _StitchGradientBackground(
        child: _ResponsiveContainer(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Project Hero Banner
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: p.heroGradient,
                  borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                  boxShadow: p.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTokens.accent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            team.projectType,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 11.5,
                              color: AppTokens.onAccent,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Your Role: $myRole',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      team.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 21,
                        color: Colors.white,
                      ),
                    ),
                    if (team.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        team.description,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.4,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (tc.team?.id != team.id)
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTokens.accent,
                              foregroundColor: AppTokens.onAccent,
                            ),
                            onPressed: () {
                              tc.selectActiveTeam(team.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Smart Match is now ranking candidates for "${team.title}"!'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                            label: const Text('Set as Active for Smart Match'),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded, size: 15, color: AppTokens.accent),
                                SizedBox(width: 6),
                                Text(
                                  'Currently Active for Smart Match',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // My Role & Responsibilities Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                  border: Border.all(color: p.border),
                  boxShadow: p.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.assignment_turned_in_rounded, size: 18, color: p.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'MY RESPONSIBILITIES ($myRole)',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              letterSpacing: 0.4,
                              color: p.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap tasks to track your progress on this project:',
                      style: TextStyle(fontSize: 12, color: p.onSurfaceSecondary),
                    ),
                    const SizedBox(height: 8),
                    for (var i = 0; i < duties.length; i++)
                      CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        value: _completedTasks.contains(i),
                        onChanged: (v) => setState(() {
                          if (v == true) {
                            _completedTasks.add(i);
                          } else {
                            _completedTasks.remove(i);
                          }
                        }),
                        title: Text(
                          duties[i],
                          style: TextStyle(
                            fontSize: 13,
                            decoration: _completedTasks.contains(i) ? TextDecoration.lineThrough : null,
                            color: _completedTasks.contains(i) ? p.onSurfaceSecondary : p.onSurface,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Team Members Card (with Remove Member option for project owner)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                  border: Border.all(color: p.border),
                  boxShadow: p.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TEAM MEMBERS (${team.members.length})',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            letterSpacing: 0.4,
                            color: p.onSurfaceSecondary,
                          ),
                        ),
                        if (team.iAmOwner)
                          Text(
                            'Tap person-remove icon to remove a member',
                            style: TextStyle(fontSize: 11, color: p.onSurfaceSecondary),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (final m in team.members)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            GradientAvatar(
                              name: m.profile.name,
                              initials: m.profile.initials,
                              radius: 19,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${m.profile.name}${m.profile.isMe ? ' (You)' : ''}',
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                  ),
                                  Text(
                                    '${m.profile.university} • ${m.profile.department} (Sem ${m.profile.semester})',
                                    style: TextStyle(fontSize: 11.5, color: p.onSurfaceSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: m.isOwner ? p.primaryTint : p.neutralTint,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                m.role,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: m.isOwner ? p.onPrimaryTint : p.onNeutralTint,
                                ),
                              ),
                            ),
                            if (team.iAmOwner && !m.isOwner && !m.profile.isMe) ...[
                              const SizedBox(width: 4),
                              IconButton(
                                tooltip: 'Remove ${m.profile.name} from project',
                                icon: const Icon(Icons.person_remove_outlined, color: AppTokens.error, size: 20),
                                onPressed: tc.busy ? null : () => _confirmRemoveMember(context, team, m),
                              ),
                            ],
                          ],
                        ),
                      ),
                    const Divider(height: 20),
                    Text(
                      'OPEN ROLES & REQUIRED SKILLS',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                        letterSpacing: 0.4,
                        color: p.onSurfaceSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (team.openRoles.isEmpty)
                      Text('All roles filled!', style: TextStyle(color: p.onSuccessTint, fontSize: 12.5))
                    else
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: team.openRoles
                            .map((r) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: p.warningTint,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    'Open Role: $r',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: p.onWarningTint,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    if (team.requiredSkills.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: team.requiredSkills
                            .map((s) => Chip(label: Text(s), visualDensity: VisualDensity.compact))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (team.iAmOwner)
                    FilledButton.tonalIcon(
                      onPressed: () => _showEditProjectDialog(context, team),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit Project Details'),
                    ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTokens.error,
                      side: BorderSide(color: AppTokens.error.withValues(alpha: 0.5)),
                    ),
                    onPressed: tc.busy
                        ? null
                        : () async {
                            await _confirmLeaveTeam(context, team);
                            if (context.mounted &&
                                !context.read<TeamController>().myTeams.any((t) => t.id == team.id)) {
                              Navigator.of(context).pop();
                            }
                          },
                    icon: const Icon(Icons.exit_to_app_rounded, size: 16),
                    label: Text(team.iAmOwner ? 'Disband Project' : 'Leave Project'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// TAB 4: REQUESTS (Received & Sent/Applications tabs, Accept / Reject / Cancel)
// ============================================================================
class _RequestsTab extends StatelessWidget {
  const _RequestsTab();

  @override
  Widget build(BuildContext context) {
    final rc = context.watch<RequestsController>();
    final p = AppPalette.of(context);

    if (rc.state == LoadState.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (rc.state == LoadState.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(rc.error ?? 'Error loading requests'),
            const SizedBox(height: 8),
            FilledButton(onPressed: rc.refresh, child: const Text('Retry')),
          ],
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: p.isDark ? p.surface : Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(999),
            ),
            child: TabBar(
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppTokens.jetBlack,
                borderRadius: BorderRadius.circular(999),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: p.onSurface,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
              tabs: [
                Tab(text: 'Received (${rc.received.length})'),
                Tab(text: 'Sent & Applied (${rc.sent.length})'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _RequestList(requests: rc.received, isReceived: true),
                _RequestList(requests: rc.sent, isReceived: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestList extends StatelessWidget {
  const _RequestList({required this.requests, required this.isReceived});
  final List<TeamRequest> requests;
  final bool isReceived;

  @override
  Widget build(BuildContext context) {
    final rc = context.watch<RequestsController>();
    final p = AppPalette.of(context);
    if (requests.isEmpty) {
      return Center(
        child: Text(
          isReceived ? 'No received requests yet.' : 'No sent requests or team applications yet.',
          style: TextStyle(color: p.onSurfaceSecondary),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
      itemCount: requests.length,
      itemBuilder: (context, i) {
        final r = requests[i];
        final other = r.other;
        final busy = rc.isBusy(r.id);
        final (bg, fg) = switch (r.status) {
          RequestStatus.pending => (p.warningTint, p.onWarningTint),
          RequestStatus.accepted => (p.successTint, p.onSuccessTint),
          RequestStatus.rejected => (p.errorTint, p.onErrorTint),
          RequestStatus.cancelled => (p.neutralTint, p.onNeutralTint),
        };

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(AppTokens.radiusLg),
              border: Border.all(color: p.border),
              boxShadow: p.cardShadow,
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GradientAvatar(name: other.name, initials: other.initials, radius: 21),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(other.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                          Text(
                            '${other.university} • ${kDepartmentShort[other.department] ?? other.department} • Sem ${other.semester}',
                            style: TextStyle(fontSize: 12, color: p.onSurfaceSecondary),
                          ),
                          if (r.teamTitle != null)
                            Text(
                              'Project: ${r.teamTitle}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: p.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        r.status.name.toUpperCase(),
                        style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 10.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: p.surfaceSubtle,
                    borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  ),
                  child: Text(
                    '"${r.message}"',
                    style: TextStyle(fontStyle: FontStyle.italic, color: p.onSurface, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: other.skills
                      .map((s) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              color: p.neutralTint,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(s, style: TextStyle(fontSize: 11, color: p.onNeutralTint)),
                          ))
                      .toList(),
                ),
                if (r.status == RequestStatus.pending) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 8,
                    runSpacing: 8,
                    children: isReceived
                        ? [
                            OutlinedButton(
                              onPressed: busy
                                  ? null
                                  : () async {
                                      final err = await rc.reject(r.id);
                                      if (err != null && context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(content: Text(err)));
                                      }
                                    },
                              child: const Text('Reject'),
                            ),
                            FilledButton.icon(
                              onPressed: busy
                                  ? null
                                  : () async {
                                      final err = await rc.accept(r.id);
                                      if (err != null && context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(content: Text(err)));
                                      } else if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Accepted ${other.name} into your project team!'),
                                          ),
                                        );
                                      }
                                    },
                              icon: const Icon(Icons.check_rounded, size: 16),
                              label: const Text('Accept'),
                            ),
                          ]
                        : [
                            OutlinedButton.icon(
                              onPressed: busy ? null : () => _confirmCancelRequest(context, r),
                              icon: const Icon(Icons.close_rounded, size: 16),
                              label: const Text('Cancel Request'),
                            ),
                          ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// TAB 5: PROFILE + COMPLETENESS METER + EDITABLE PERSONAL DETAILS
// ============================================================================
class _ProfileTab extends StatelessWidget {
  final VoidCallback onToggleTheme;
  const _ProfileTab({required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    final pc = context.watch<ProfileController>();
    final tc = context.watch<TeamController>();
    final p = AppPalette.of(context);
    final me = pc.me;
    if (me == null) {
      return _ProfileEditorScreen(isInitialSetup: true, onToggleTheme: onToggleTheme);
    }

    final pct = (pc.completeness * 100).round();
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
      children: [
        // Editorial Lavender + White Floating Progress Card (inspired by "Your progress 72%" in photo)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: p.heroGradient,
            borderRadius: BorderRadius.circular(AppTokens.radiusXl),
            boxShadow: p.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GradientAvatar(name: me.name, initials: me.initials, radius: 30),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          me.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 21,
                            letterSpacing: -0.4,
                            color: p.onHero,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${me.university} • ${me.department}',
                          style: TextStyle(color: p.onHeroSecondary, fontSize: 13),
                        ),
                        Text(
                          'Semester ${me.semester} • ${tc.ownedTeams.length} Owned • ${tc.joinedTeams.length} Joined',
                          style: TextStyle(color: p.onHeroSecondary, fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTokens.jetBlack,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => _ProfileEditorScreen(
                          isInitialSetup: false,
                          onToggleTheme: onToggleTheme,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // White floating card with huge "72%" style numeral
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: p.isDark ? p.surface : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your progress',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: p.onSurfaceSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$pct%',
                            style: TextStyle(
                              fontSize: 36,
                              height: 1.05,
                              letterSpacing: -1.2,
                              fontWeight: FontWeight.w800,
                              color: p.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            pc.missingFields.isEmpty
                                ? 'Profile is 100% complete & ready for Smart Match.'
                                : 'Add to reach 100%: ${pc.missingFields.join(', ')}',
                            style: TextStyle(fontSize: 11.5, color: p.onSurfaceSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: p.border),
                      ),
                      child: Icon(
                        pc.missingFields.isEmpty ? Icons.verified_rounded : Icons.lock_open_rounded,
                        size: 20,
                        color: p.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
            border: Border.all(color: p.border),
            boxShadow: p.cardShadow,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (me.workExperience.isNotEmpty) ...[
                Text(
                  'WORK EXPERIENCE & ACHIEVEMENTS',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: p.onSurfaceSecondary),
                ),
                const SizedBox(height: 6),
                Text(me.workExperience, style: const TextStyle(fontSize: 13.5, height: 1.4)),
                const SizedBox(height: 16),
              ],
              if (me.bio.isNotEmpty) ...[
                Text(
                  'ABOUT ME / BIO',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: p.onSurfaceSecondary),
                ),
                const SizedBox(height: 6),
                Text(me.bio, style: const TextStyle(fontSize: 13.5, height: 1.4)),
                const SizedBox(height: 16),
              ],
              Text(
                'MY TECHNICAL & SOFT SKILLS',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: p.onSurfaceSecondary),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: me.skills
                    .map((s) => Chip(label: Text(s), visualDensity: VisualDensity.compact))
                    .toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'INTERESTS & DOMAINS',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: p.onSurfaceSecondary),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: me.interests
                    .map((s) => Chip(label: Text(s), visualDensity: VisualDensity.compact))
                    .toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'WEEKLY AVAILABILITY',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: p.onSurfaceSecondary),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: me.availability
                    .map((s) => Chip(label: Text(s), visualDensity: VisualDensity.compact))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileEditorScreen extends StatefulWidget {
  final bool isInitialSetup;
  final VoidCallback? onToggleTheme;
  const _ProfileEditorScreen({required this.isInitialSetup, this.onToggleTheme});
  @override
  State<_ProfileEditorScreen> createState() => _ProfileEditorScreenState();
}

class _ProfileEditorScreenState extends State<_ProfileEditorScreen> {
  late final TextEditingController _name;
  late final TextEditingController _workExp;
  late final TextEditingController _bio;
  late String _uni;
  late String _dept;
  late int _sem;
  late Set<String> _skills;
  late Set<String> _interests;
  late Set<String> _avail;

  @override
  void initState() {
    super.initState();
    final me = context.read<ProfileController>().me;
    final auth = context.read<AuthController>();
    _name = TextEditingController(text: me?.name ?? auth.signUpName ?? '');
    _workExp = TextEditingController(text: me?.workExperience ?? '');
    _bio = TextEditingController(text: me?.bio ?? '');
    _uni = (me != null && kUniversities.contains(me.university)) ? me.university : kUniversities.first;
    _dept = me?.department ?? kDepartments.first;
    _sem = me?.semester ?? 7;
    _skills = {...?me?.skills};
    _interests = {...?me?.interests};
    _avail = {...?me?.availability};
  }

  Future<void> _save() async {
    final pc = context.read<ProfileController>();
    final prev = pc.me;
    final err = await pc.save(Profile(
      name: _name.text,
      university: _uni,
      department: _dept,
      semester: _sem,
      projectType: prev?.projectType ?? 'FYP',
      skillsNeeded: prev?.skillsNeeded ?? [],
      workExperience: _workExp.text,
      bio: _bio.text,
      skills: _skills.toList(),
      interests: _interests.toList(),
      availability: _avail.toList(),
    ));
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved! Add your projects anytime from the "+ New Project" button.'),
        ),
      );
      if (!widget.isInitialSetup) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.watch<ProfileController>().saving;
    final p = AppPalette.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isInitialSetup ? 'Set Up Student Profile' : 'Edit My Profile'),
        actions: [
          if (widget.onToggleTheme != null)
            IconButton(
              onPressed: widget.onToggleTheme,
              icon: Icon(p.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            ),
          if (widget.isInitialSetup)
            IconButton(
              onPressed: context.read<AuthController>().signOut,
              icon: const Icon(Icons.logout_rounded),
            ),
        ],
      ),
      body: _StitchGradientBackground(
        child: _ResponsiveContainer(
          child: ListView(
            padding: const EdgeInsets.all(AppTokens.pagePad),
            children: [
              if (widget.isInitialSetup)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: p.heroGradient,
                    borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                  ),
                  child: const Text(
                    'Welcome to TeamUp! Enter your academic details, skills & work experience below. '
                    'Once your profile is created, you can add Semester Projects or FYPs from the top bar or side menu!',
                    style: TextStyle(fontSize: 12.5, color: Colors.white, height: 1.38),
                  ),
                ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTokens.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _name,
                        decoration: const InputDecoration(
                          labelText: 'Full Name *',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _uni,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'University / Campus *',
                          prefixIcon: Icon(Icons.account_balance_rounded),
                        ),
                        items: kUniversities
                            .map((u) => DropdownMenuItem(value: u, child: Text(u, overflow: TextOverflow.ellipsis)))
                            .toList(),
                        onChanged: (v) => setState(() => _uni = v ?? _uni),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _dept,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Department *',
                          prefixIcon: Icon(Icons.school_outlined),
                        ),
                        items: kDepartments
                            .map((d) => DropdownMenuItem(value: d, child: Text(d, overflow: TextOverflow.ellipsis)))
                            .toList(),
                        onChanged: (v) => setState(() => _dept = v ?? _dept),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: _sem,
                        decoration: const InputDecoration(
                          labelText: 'Current Semester *',
                          prefixIcon: Icon(Icons.calendar_today_rounded),
                        ),
                        items: kSemesters
                            .map((s) => DropdownMenuItem(value: s, child: Text('Semester $s')))
                            .toList(),
                        onChanged: (v) => setState(() => _sem = v ?? _sem),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _workExp,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Work Experience / Internships / Past Projects',
                          hintText: 'e.g. 3-month Flutter Intern at Systems Ltd; shipped 2 Play Store apps...',
                          prefixIcon: Icon(Icons.work_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _bio,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Short Bio / About Me',
                          hintText: 'What kind of teammate are you?',
                          prefixIcon: Icon(Icons.info_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _ChipSection(
                        title: 'My Technical & Soft Skills (pick at least 1) *',
                        options: kSkills,
                        selected: _skills,
                        onChanged: () => setState(() {}),
                      ),
                      const SizedBox(height: 14),
                      _ChipSection(
                        title: 'My Interests & Domains (pick at least 1) *',
                        options: kInterests,
                        selected: _interests,
                        onChanged: () => setState(() {}),
                      ),
                      const SizedBox(height: 14),
                      _ChipSection(
                        title: 'Weekly Availability (pick at least 1) *',
                        options: kAvailability,
                        selected: _avail,
                        onChanged: () => setState(() {}),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: saving ? null : _save,
                        icon: const Icon(Icons.save_rounded),
                        label: Text(
                          saving
                              ? 'Saving...'
                              : (widget.isInitialSetup ? 'Save Profile & Enter TeamUp' : 'Save Changes'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipSection extends StatelessWidget {
  const _ChipSection({
    required this.title,
    required this.options,
    required this.selected,
    required this.onChanged,
  });
  final String title;
  final List<String> options;
  final Set<String> selected;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: options.map((o) {
            final isSel = selected.contains(o);
            return FilterChip(
              label: Text(
                o,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                  color: isSel ? p.onPrimaryTint : p.onSurface,
                ),
              ),
              selected: isSel,
              onSelected: (v) {
                if (v) {
                  selected.add(o);
                } else {
                  selected.remove(o);
                }
                onChanged();
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ============================================================================
// MODALS & BOTTOM SHEETS:
//  1) Student Portfolio & Match Breakdown Sheet (tap any student card)
//  2) "How Smart Match Works" Formula Sheet (for competition judges)
//  3) Create New Project Dialog
//  4) Apply to Join Open Team Dialog
//  5) Send Request Dialog & Confirmation Dialogs
// ============================================================================
Future<void> _showStudentDetailSheet(
  BuildContext context,
  Profile student,
  MatchResult? match,
) async {
  final p = AppPalette.of(context);
  final hasPending = context.read<RequestsController>().hasPendingTo(student.id);

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollCtrl) => ListView(
        controller: scrollCtrl,
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: p.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Row(
            children: [
              GradientAvatar(name: student.name, initials: student.initials, radius: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 19),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${student.university} • ${student.department}',
                      style: TextStyle(fontSize: 13, color: p.onSurfaceSecondary),
                    ),
                    Text(
                      'Semester ${student.semester} • ${student.projectType}',
                      style: TextStyle(fontSize: 12.5, color: p.onSurfaceSecondary),
                    ),
                  ],
                ),
              ),
              if (match != null)
                MatchScoreRing(score: match.score, size: 56, subtitle: 'MATCH'),
            ],
          ),
          if (student.workExperience.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'WORK EXPERIENCE & PROJECTS',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: p.onSurfaceSecondary),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: p.surfaceSubtle,
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                border: Border.all(color: p.border),
              ),
              child: Text(student.workExperience, style: const TextStyle(fontSize: 13.5, height: 1.4)),
            ),
          ],
          if (student.bio.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'BIO',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: p.onSurfaceSecondary),
            ),
            const SizedBox(height: 4),
            Text(student.bio, style: const TextStyle(fontSize: 13.5, height: 1.4)),
          ],
          if (match != null && match.reasons.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'WHY YOU MATCH (${match.score}%)',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: p.onSurfaceSecondary),
            ),
            const SizedBox(height: 6),
            for (final r in match.reasons)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, size: 15, color: p.onSuccessTint),
                    const SizedBox(width: 8),
                    Expanded(child: Text(r, style: const TextStyle(fontSize: 13))),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 16),
          Text(
            'TECHNICAL & SOFT SKILLS',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: p.onSurfaceSecondary),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: student.skills
                .map((s) => Chip(label: Text(s), visualDensity: VisualDensity.compact))
                .toList(),
          ),
          const SizedBox(height: 14),
          Text(
            'INTERESTS & AVAILABILITY',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: p.onSurfaceSecondary),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ...student.interests.map((i) => Chip(label: Text(i), visualDensity: VisualDensity.compact)),
              ...student.availability.map(
                (a) => Chip(
                  avatar: const Icon(Icons.schedule_rounded, size: 14),
                  label: Text(a),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: hasPending
                ? null
                : () {
                    Navigator.pop(ctx);
                    _showSendRequestDialog(context, student);
                  },
            icon: Icon(hasPending ? Icons.hourglass_top_rounded : Icons.send_rounded),
            label: Text(hasPending ? 'Request Already Pending' : 'Send Team Invitation'),
          ),
        ],
      ),
    ),
  );
}

Future<void> _showMatchFormulaSheet(BuildContext context) async {
  final p = AppPalette.of(context);
  const rows = [
    ('Skill Fit', '40 pts', 'Overlap between candidate skills & your active project\'s required skills + open roles'),
    ('Shared Interests', '25 pts', 'Jaccard similarity (∩ ÷ ∪) between project domains & student interests'),
    ('Project Type', '15 pts', 'Same project type (FYP or Semester Project)'),
    ('Availability', '10 pts', 'Overlapping weekly slots ("Flexible" matches every schedule)'),
    ('Semester Closeness', '10 pts', 'Same semester = 10 pts, ±1 semester = 6 pts, otherwise = 2 pts'),
  ];
  await showModalBottomSheet<void>(
    context: context,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: p.primary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'How Smart Match Scoring Works (0–100%)',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Deterministic, unit-tested formula that recalculates dynamically whenever you switch your active project:',
            style: TextStyle(fontSize: 12.5, color: p.onSurfaceSecondary),
          ),
          const SizedBox(height: 12),
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 58,
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    decoration: BoxDecoration(
                      color: p.primaryTint,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      r.$2,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                        color: p.onPrimaryTint,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.$1, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        Text(r.$3, style: TextStyle(fontSize: 12, color: p.onSurfaceSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Got it'),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> _showCreateProjectDialog(BuildContext context) async {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  String projectType = 'FYP';
  final Set<String> roles = {'Developer', 'Designer'};
  final Set<String> reqSkills = {'Flutter', 'Figma'};
  final Set<String> domains = {'AI', 'Mobile Apps'};

  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        title: const Text('Add a New Project'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Project Title *',
                    hintText: 'e.g. Smart Campus Attendance & AI Tutor',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: projectType,
                  decoration: const InputDecoration(labelText: 'Project Type *'),
                  items: kProjectTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setDialogState(() => projectType = v ?? projectType),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Project Description & Goals',
                    hintText: 'Describe what you are building and what kind of teammates you need...',
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Open Roles Needed:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: kRoles
                      .map((r) => FilterChip(
                            label: Text(r, style: const TextStyle(fontSize: 12)),
                            selected: roles.contains(r),
                            onSelected: (sel) => setDialogState(() {
                              if (sel) {
                                roles.add(r);
                              } else {
                                roles.remove(r);
                              }
                            }),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Specific Skills Needed for This Project (drives Smart Match):',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: kSkills
                      .map((s) => FilterChip(
                            label: Text(s, style: const TextStyle(fontSize: 11.5)),
                            selected: reqSkills.contains(s),
                            onSelected: (sel) => setDialogState(() {
                              if (sel) {
                                reqSkills.add(s);
                              } else {
                                reqSkills.remove(s);
                              }
                            }),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 14),
                const Text('Project Domains / Interests:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: kInterests
                      .map((d) => FilterChip(
                            label: Text(d, style: const TextStyle(fontSize: 11.5)),
                            selected: domains.contains(d),
                            onSelected: (sel) => setDialogState(() {
                              if (sel) {
                                domains.add(d);
                              } else {
                                domains.remove(d);
                              }
                            }),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton.icon(
            onPressed: () async {
              final err = await context.read<TeamController>().create(
                    titleCtrl.text,
                    projectType,
                    roles.toList(),
                    description: descCtrl.text,
                    requiredSkills: reqSkills.toList(),
                    domainTags: domains.toList(),
                  );
              if (!ctx.mounted) return;
              if (err != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
              } else {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Project "${titleCtrl.text.trim()}" created! Smart Matches are now tailored to this project.',
                    ),
                  ),
                );
              }
            },
            icon: const Icon(Icons.check_rounded),
            label: const Text('Create Project'),
          ),
        ],
      ),
    ),
  );
}

Future<void> _showApplyToTeamDialog(BuildContext context, Team team) async {
  final me = context.read<ProfileController>().me;
  final mySkillsText = (me != null && me.skills.isNotEmpty) ? me.skills.take(3).join(', ') : 'relevant skills';
  final msgCtrl = TextEditingController(
    text: 'Hi! I\'d love to join "${team.title}". I can contribute with $mySkillsText.',
  );
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Apply to Join "${team.title}"'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Open roles: ${team.openRoles.join(', ')}', style: const TextStyle(fontSize: 12.5)),
          const SizedBox(height: 10),
          TextField(
            controller: msgCtrl,
            maxLines: 3,
            maxLength: kMaxRequestMessage,
            decoration: const InputDecoration(labelText: 'Application pitch / message'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton.icon(
          onPressed: () async {
            final err = await context.read<RequestsController>().applyToTeam(team, msgCtrl.text);
            if (!ctx.mounted) return;
            if (err != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
            } else {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Application sent to "${team.title}"! Check the Requests tab.')),
              );
            }
          },
          icon: const Icon(Icons.send_rounded, size: 16),
          label: const Text('Submit Application'),
        ),
      ],
    ),
  );
}

Future<void> _showSendRequestDialog(BuildContext context, Profile target) async {
  final activeTeam = context.read<TeamController>().team;
  final msgCtrl = TextEditingController(
    text: activeTeam != null
        ? 'Hi ${target.name.split(' ').first}! We\'re building "${activeTeam.title}" (${activeTeam.projectType}) and your skills are a great fit. Want to join?'
        : 'Hi ${target.name.split(' ').first}! Your skills are a great fit for my project. Want to team up?',
  );
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Invite ${target.name}'),
      content: TextField(
        controller: msgCtrl,
        maxLines: 3,
        maxLength: kMaxRequestMessage,
        decoration: const InputDecoration(labelText: 'Short message'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(
          onPressed: () async {
            final err = await context.read<RequestsController>().send(target.id, msgCtrl.text);
            if (!ctx.mounted) return;
            if (err != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
            } else {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Request sent to ${target.name}!')),
              );
            }
          },
          child: const Text('Send'),
        ),
      ],
    ),
  );
}

Future<void> _confirmCancelRequest(BuildContext context, TeamRequest r) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Cancel Request?'),
      content: Text('Are you sure you want to cancel your request to ${r.to.name}?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep')),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Yes, Cancel'),
        ),
      ],
    ),
  );
  if (ok == true && context.mounted) {
    final err = await context.read<RequestsController>().cancel(r.id);
    if (err != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }
}

Future<void> _showEditProjectDialog(BuildContext context, Team team) async {
  final titleCtrl = TextEditingController(text: team.title);
  final descCtrl = TextEditingController(text: team.description);
  String projectType = kProjectTypes.contains(team.projectType) ? team.projectType : 'FYP';
  final Set<String> roles = {...team.openRoles};
  final Set<String> reqSkills = {...team.requiredSkills};
  final Set<String> domains = {...team.domainTags};

  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        title: const Text('Edit Project Details'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Project Title *'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: projectType,
                  decoration: const InputDecoration(labelText: 'Project Type *'),
                  items: kProjectTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setDialogState(() => projectType = v ?? projectType),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Project Description & Goals'),
                ),
                const SizedBox(height: 14),
                const Text('Open Roles Needed:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: kRoles
                      .map((r) => FilterChip(
                            label: Text(r, style: const TextStyle(fontSize: 12)),
                            selected: roles.contains(r),
                            onSelected: (sel) => setDialogState(() {
                              if (sel) {
                                roles.add(r);
                              } else {
                                roles.remove(r);
                              }
                            }),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Specific Skills Needed for This Project:',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: kSkills
                      .map((s) => FilterChip(
                            label: Text(s, style: const TextStyle(fontSize: 11.5)),
                            selected: reqSkills.contains(s),
                            onSelected: (sel) => setDialogState(() {
                              if (sel) {
                                reqSkills.add(s);
                              } else {
                                reqSkills.remove(s);
                              }
                            }),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 14),
                const Text('Project Domains / Interests:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: kInterests
                      .map((d) => FilterChip(
                            label: Text(d, style: const TextStyle(fontSize: 11.5)),
                            selected: domains.contains(d),
                            onSelected: (sel) => setDialogState(() {
                              if (sel) {
                                domains.add(d);
                              } else {
                                domains.remove(d);
                              }
                            }),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton.icon(
            onPressed: () async {
              final err = await context.read<TeamController>().updateProject(
                    team.id,
                    title: titleCtrl.text,
                    description: descCtrl.text,
                    projectType: projectType,
                    rolesNeeded: roles.toList(),
                    requiredSkills: reqSkills.toList(),
                    domainTags: domains.toList(),
                  );
              if (!ctx.mounted) return;
              if (err != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
              } else {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Project details updated & matches refreshed!')),
                );
              }
            },
            icon: const Icon(Icons.save_rounded),
            label: const Text('Save Changes'),
          ),
        ],
      ),
    ),
  );
}

Future<void> _confirmRemoveMember(BuildContext context, Team team, TeamMember member) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Remove Team Member?'),
      content: Text(
        'Remove ${member.profile.name} (${member.role}) from "${team.title}"? Their role will re-open for new candidates.',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppTokens.error),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Remove Member'),
        ),
      ],
    ),
  );
  if (ok == true && context.mounted) {
    final err = await context.read<TeamController>().removeMember(team.id, member.profile.id);
    if (err != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed ${member.profile.name} and re-opened ${member.role}.')),
      );
    }
  }
}

Future<void> _confirmLeaveTeam(BuildContext context, Team team) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(team.iAmOwner ? 'Disband Project?' : 'Leave Team?'),
      content: Text(
        team.iAmOwner
            ? 'You are the owner of "${team.title}". Leaving will delete/disband this project for all members. Continue?'
            : 'Are you sure you want to leave "${team.title}"?',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Stay')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppTokens.error),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(team.iAmOwner ? 'Disband' : 'Leave'),
        ),
      ],
    ),
  );
  if (ok == true && context.mounted) {
    final err = await context.read<TeamController>().leave(team.id);
    if (err != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }
}
