// TeamUp – Integrated Stitch Design System Frontend (`lib/ui/app_root.dart`)
// Integrates the teammate's Stitch UI tokens, Dark/Light palettes, gradient backdrop,
// overlapping-circle logo & splash screen with all backend controllers and every required button/flow:
//  - Splash screen (exact Stitch layout: gradient bg, w-20 h-20 rounded-xl logo with overlapping circles,
//    "TeamUp", "Find the right teammates.", dual-ring spinner)
//  - Auth screen (Sign In / Sign Up toggle, validation, Light/Dark theme switch)
//  - Initial Profile Setup (University, Department, Semester, Work Experience, Bio,
//    My Skills, Interests, Availability — NO project requirements asked during initial profile creation!)
//  - Editable Profile anytime + Profile Completeness meter + missing field hints
//  - Top AppBar "+ New Project" button & Side Drawer project switcher
//    (add multiple Semester Projects / FYPs with Title, Project Type, Project Description,
//    Open Roles, Required Skills & Domains — switching active project dynamically updates Smart Matches!)
//  - Smart Matches tab with active project selector, Skill Gap banner, 0-100% score pills,
//    human-readable reasons on every card, work experience & one-tap Invite / Send Request
//  - Discover tab with search (name/university/skill), 5 filters (University, Department,
//    Semester, Skill, Project Type), Sort menu (Best Match, Name, Semester) & Clear Filters
//  - Projects & Open Teams tab:
//      (1) "Join an Open Team" board (browse teams posted by students, see required skills
//          highlighted in green when you have them, see your % Skill Fit & Apply to Join Team)
//      (2) "My Projects & Teams" (manage members, open roles, switch active project, create new project,
//          or leave/disband with confirmation dialog)
//  - Requests tab (Received & Sent/Applications tabs, Pending badge count, Accept/Reject/Cancel with confirmation)
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
  // Default to Dark mode as specified in `<html lang="en" class="dark">` of the teammate's Stitch design,
  // with an instant Light/Dark toggle button in the top bar.
  ThemeMode _themeMode = ThemeMode.dark;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), () {
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

/// Gradient background wrapper matching `bg-gradient-to-b from-light-bg-start to-light-bg-end dark:from-dark-bg-start dark:to-dark-bg-end`.
class _StitchGradientBackground extends StatelessWidget {
  final Widget child;
  const _StitchGradientBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(gradient: p.backgroundGradient),
      child: child,
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
                        const TeamUpLogo(size: 80),
                        const SizedBox(height: AppTokens.lg),
                        Text(
                          'TeamUp',
                          style: TextStyle(
                            fontSize: 32,
                            height: 38 / 32,
                            letterSpacing: -0.5,
                            fontWeight: FontWeight.w300,
                            color: p.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppTokens.xs),
                        Text(
                          'Find the right teammates.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 20 / 14,
                            fontWeight: FontWeight.w400,
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
                          strokeWidth: 2.4,
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
// 1. AUTH SCREEN (Stitch Design System Card + Theme Switcher)
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
                padding: const EdgeInsets.all(AppTokens.xl),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton.filledTonal(
                        tooltip: 'Toggle Light / Dark Theme',
                        onPressed: widget.onToggleTheme,
                        style: IconButton.styleFrom(backgroundColor: p.iconBtn),
                        icon: Icon(
                          p.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                          color: p.isDark ? AppTokens.accent : p.primary,
                        ),
                      ),
                    ),
                    const TeamUpLogo(size: 72),
                    const SizedBox(height: AppTokens.md),
                    Text(
                      'TeamUp',
                      style: TextStyle(
                        fontSize: 32,
                        height: 38 / 32,
                        letterSpacing: -0.5,
                        fontWeight: FontWeight.w300,
                        color: p.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Find the right teammates.',
                      style: TextStyle(fontSize: 14, color: p.onSurfaceSecondary),
                    ),
                    const SizedBox(height: AppTokens.xl),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTokens.xl),
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
                                      label: 'Sign Up',
                                      selected: _isSignUp,
                                      onTap: () => setState(() => _isSignUp = true),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppTokens.lg),
                            if (_isSignUp) ...[
                              TextField(
                                controller: _name,
                                decoration: const InputDecoration(
                                  labelText: 'Full Name',
                                  prefixIcon: Icon(Icons.person_outline_rounded),
                                ),
                              ),
                              const SizedBox(height: AppTokens.md),
                            ],
                            TextField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'University Email',
                                prefixIcon: Icon(Icons.alternate_email_rounded),
                              ),
                            ),
                            const SizedBox(height: AppTokens.md),
                            TextField(
                              controller: _pass,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Password (min 6 chars)',
                                prefixIcon: Icon(Icons.lock_outline_rounded),
                              ),
                            ),
                            if (_isSignUp)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: p.primaryTint,
                                    borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                                  ),
                                  child: Text(
                                    'Step 1: Create account & personal profile (University, Dept, Semester, Skills & Work Experience).\nStep 2: Add your projects or apply to open teams inside the app!',
                                    style: TextStyle(fontSize: 12, color: p.onPrimaryTint, height: 1.35),
                                  ),
                                ),
                              ),
                            const SizedBox(height: AppTokens.lg),
                            FilledButton(
                              onPressed: auth.busy ? null : _submit,
                              child: auth.busy
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: p.onPrimary,
                                      ),
                                    )
                                  : Text(_isSignUp ? 'Continue to Profile Setup' : 'Sign In'),
                            ),
                          ],
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
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? p.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: selected ? p.onPrimary : p.onSurfaceSecondary,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 2. HOME SHELL (Side Drawer for Projects + Top Bar "+ New Project" + 5 Tabs)
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
                  padding: const EdgeInsets.all(AppTokens.lg),
                  decoration: BoxDecoration(
                    color: p.primaryTint,
                    border: Border(bottom: BorderSide(color: p.border)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: p.primary,
                        foregroundColor: p.onPrimary,
                        child: Text(me.initials, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              me.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: p.onPrimaryTint,
                              ),
                            ),
                            Text(
                              '${me.university} • ${me.department}',
                              style: TextStyle(fontSize: 12, color: p.onPrimaryTint.withValues(alpha: 0.85)),
                            ),
                            Text(
                              'Semester ${me.semester}',
                              style: TextStyle(fontSize: 12, color: p.onPrimaryTint.withValues(alpha: 0.85)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showCreateProjectDialog(context);
                  },
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: const Text('Add New Project'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  'MY PROJECTS (SWITCH ACTIVE MATCHING)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
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
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                          ),
                          subtitle: Text(
                            '${t.projectType} • ${t.openRoles.length} open role(s)',
                            style: TextStyle(fontSize: 12, color: p.onSurfaceSecondary),
                          ),
                        ),
                    ],
                  ),
                ),
              if (tc.myTeams.isEmpty) const Spacer(),
              Divider(color: p.border, height: 1),
              ListTile(
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
                leading: const Icon(Icons.group_add_outlined),
                title: const Text('Browse & Join Open Teams'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _tab = 2);
                },
              ),
              ListTile(
                leading: Icon(p.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                title: Text(p.isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode'),
                onTap: widget.onToggleTheme,
              ),
              ListTile(
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
              // Stitch Header Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 12, 4),
                child: Row(
                  children: [
                    Builder(
                      builder: (ctx) => IconButton(
                        tooltip: 'Projects & Menu',
                        onPressed: () => Scaffold.of(ctx).openDrawer(),
                        icon: const Icon(Icons.menu_rounded),
                      ),
                    ),
                    const TeamUpLogo(size: 32),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        [
                          'Smart Matches',
                          'Discover',
                          'Projects & Teams',
                          'Requests',
                          'My Profile',
                        ][_tab],
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: p.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    FilledButton.tonalIcon(
                      style: FilledButton.styleFrom(
                        backgroundColor: p.primaryTint,
                        foregroundColor: p.onPrimaryTint,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () => _showCreateProjectDialog(context),
                      icon: const Icon(Icons.add_rounded, size: 17),
                      label: const Text('Project', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      tooltip: 'Toggle Light / Dark Mode',
                      onPressed: widget.onToggleTheme,
                      icon: Icon(
                        p.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        size: 20,
                        color: p.isDark ? AppTokens.accent : p.primary,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Edit Profile',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => _ProfileEditorScreen(
                            isInitialSetup: false,
                            onToggleTheme: widget.onToggleTheme,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.manage_accounts_outlined, size: 21),
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
                      Icon(Icons.wifi_off_rounded, size: 15, color: p.onWarningTint),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Offline mode — showing cached data',
                          style: TextStyle(
                            color: p.onWarningTint,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(child: pages[_tab]),
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
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: const Icon(Icons.mail_outline_rounded),
              ),
              selectedIcon: Badge(
                backgroundColor: AppTokens.accent,
                textColor: AppTokens.onAccent,
                isLabelVisible: req.pendingReceivedCount > 0,
                label: Text(
                  '${req.pendingReceivedCount}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
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
// TAB 1: SMART MATCH (Dynamic per-project matching + Active Project Switcher)
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
        padding: const EdgeInsets.all(AppTokens.pagePad),
        itemCount: mc.matches.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Active Project Switcher Card
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: p.primaryTint,
                    borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                    border: Border.all(color: p.primary.withValues(alpha: 0.35)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.tune_rounded, size: 18, color: p.onPrimaryTint),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Active Project for Smart Match',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                                color: p.onPrimaryTint,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: p.onPrimaryTint,
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () => _showCreateProjectDialog(context),
                            icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                            label: const Text('New Project', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (tc.myTeams.isEmpty)
                        Text(
                          'Matching on your general profile. Tap "New Project" to add a Semester Project or FYP with its own description & required skills!',
                          style: TextStyle(fontSize: 12.5, color: p.onPrimaryTint.withValues(alpha: 0.9)),
                        )
                      else ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            for (final t in tc.myTeams)
                              ChoiceChip(
                                label: Text('${t.title} (${t.projectType})'),
                                selected: activeTeam?.id == t.id,
                                onSelected: (_) => tc.selectActiveTeam(t.id),
                              ),
                          ],
                        ),
                        if (activeTeam != null && activeTeam.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            activeTeam.description,
                            style: TextStyle(fontSize: 12.5, color: p.onPrimaryTint.withValues(alpha: 0.9)),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),

                // Skill Gap Banner
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: gap.isEmpty ? p.successTint : p.warningTint,
                    borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                    border: Border.all(
                      color: (gap.isEmpty ? AppTokens.success : AppTokens.warning).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            gap.isEmpty ? Icons.verified_rounded : Icons.insights_rounded,
                            size: 18,
                            color: gap.isEmpty ? p.onSuccessTint : p.onWarningTint,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              gap.isEmpty
                                  ? 'All needed skills are covered by your current team!'
                                  : 'Skill Gap for ${activeTeam != null ? '"${activeTeam.title}"' : 'Your Profile'} (${gap.length} uncovered):',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: gap.isEmpty ? p.onSuccessTint : p.onWarningTint,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (gap.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: gap
                              .map((s) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: p.surface.withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      s,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: p.onWarningTint,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          }

          final m = mc.matches[index - 1];
          final student = m.profile;
          final hasPending = req.hasPendingTo(student.id);
          final isHigh = m.score >= 70;
          final isMed = m.score >= 45;
          final badgeBg = isHigh ? p.successTint : (isMed ? p.warningTint : p.neutralTint);
          final badgeFg = isHigh ? p.onSuccessTint : (isMed ? p.onWarningTint : p.onNeutralTint);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: p.primaryTint,
                          foregroundColor: p.onPrimaryTint,
                          child: Text(student.initials, style: const TextStyle(fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: p.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${student.university} • ${student.department} • Sem ${student.semester}',
                                style: TextStyle(fontSize: 12.5, color: p.onSurfaceSecondary),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${m.score}% Match',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: badgeFg,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (student.workExperience.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: p.surfaceSubtle,
                          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                          border: Border.all(color: p.border),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.work_outline_rounded, size: 15, color: p.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                student.workExperience,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
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
                        style: TextStyle(fontSize: 13.5, color: p.onSurfaceSecondary, height: 1.35),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: student.skills.map((s) {
                        final matched = m.matchedSkills.contains(s);
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: matched ? p.successTint : p.neutralTint,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: matched ? AppTokens.success.withValues(alpha: 0.45) : p.border,
                            ),
                          ),
                          child: Text(
                            s,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: matched ? FontWeight.w700 : FontWeight.w500,
                              color: matched ? p.onSuccessTint : p.onNeutralTint,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    if (m.reasons.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Divider(color: p.border, height: 1),
                      const SizedBox(height: 10),
                      Text(
                        'WHY YOU MATCH',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          letterSpacing: 0.5,
                          color: p.onSurfaceSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      for (final r in m.reasons)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle_rounded, size: 15, color: p.onSuccessTint),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  r,
                                  style: TextStyle(fontSize: 12.5, color: p.onSurface),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Free: ${student.availability.join(', ')}',
                          style: TextStyle(fontSize: 11.5, color: p.onSurfaceSecondary),
                        ),
                        FilledButton.icon(
                          onPressed: hasPending ? null : () => _showSendRequestDialog(context, student),
                          icon: Icon(
                            hasPending ? Icons.hourglass_top_rounded : Icons.send_rounded,
                            size: 16,
                          ),
                          label: Text(
                            hasPending
                                ? 'Pending'
                                : (activeTeam != null ? 'Invite to Project' : 'Send Request'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
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
                    children: [
                      Icon(Icons.sort_rounded, size: 18, color: p.primary),
                      const SizedBox(width: 6),
                      Text(
                        switch (dc.sort) {
                          SortOption.bestMatch => 'Match',
                          SortOption.name => 'A–Z',
                          SortOption.semester => 'Sem',
                        },
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                  label: const Text('Reset Filters'),
                  onPressed: dc.clearFilters,
                ),
              ],
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
                padding: const EdgeInsets.all(AppTokens.pagePad),
                itemCount: dc.results.length,
                itemBuilder: (context, i) {
                  final student = dc.results[i];
                  final match = mc.matchFor(student.id);
                  final hasPending = req.hasPendingTo(student.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: p.primaryTint,
                                  foregroundColor: p.onPrimaryTint,
                                  child: Text(student.initials, style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student.name,
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5),
                                      ),
                                      Text(
                                        '${student.university} • ${student.department} • Sem ${student.semester}',
                                        style: TextStyle(fontSize: 12, color: p.onSurfaceSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                if (match != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: p.primaryTint,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '${match.score}%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: p.onPrimaryTint,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (student.workExperience.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Experience: ${student.workExperience}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: p.onSurface,
                                ),
                              ),
                            ],
                            if (student.bio.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                student.bio,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12.5, color: p.onSurfaceSecondary),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Wrap(
                                    spacing: 5,
                                    runSpacing: 5,
                                    children: student.skills
                                        .map((s) => Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: p.neutralTint,
                                                borderRadius: BorderRadius.circular(999),
                                              ),
                                              child: Text(
                                                s,
                                                style: TextStyle(fontSize: 11, color: p.onNeutralTint),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FilledButton.tonalIcon(
                                  onPressed: hasPending
                                      ? null
                                      : () => _showSendRequestDialog(context, student),
                                  icon: Icon(
                                    hasPending ? Icons.hourglass_top_rounded : Icons.person_add_alt_1_rounded,
                                    size: 16,
                                  ),
                                  label: Text(hasPending ? 'Pending' : 'Connect'),
                                ),
                              ],
                            ),
                          ],
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

class _FilterDropdown<T> extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return PopupMenuButton<T?>(
      onSelected: onSelected,
      itemBuilder: (_) => [
        const PopupMenuItem(value: null, child: Text('Any (clear)')),
        for (final item in items) PopupMenuItem(value: item, child: Text('$item')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: active ? p.onPrimaryTint : p.onSurfaceSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TAB 3: PROJECTS & OPEN TEAMS
//   Sub-tab A: "Join an Open Team" (browse teams needing skills & apply!)
//   Sub-tab B: "My Projects & Teams" (view/switch/add multiple projects)
// ============================================================================
class _ProjectsAndJoinTeamsTab extends StatelessWidget {
  const _ProjectsAndJoinTeamsTab();

  @override
  Widget build(BuildContext context) {
    final tc = context.watch<TeamController>();
    final p = AppPalette.of(context);
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              border: Border.all(color: p.border),
            ),
            child: TabBar(
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: p.primaryTint,
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              ),
              labelColor: p.onPrimaryTint,
              unselectedLabelColor: p.onSurfaceSecondary,
              tabs: [
                Tab(text: 'Join Open Team (${tc.openTeams.length})'),
                Tab(text: 'My Projects (${tc.myTeams.length})'),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _OpenTeamsBoard(),
                _MyProjectsList(),
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
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
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
                  padding: const EdgeInsets.all(AppTokens.pagePad),
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
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppTokens.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: p.primaryTint,
                                      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                                    ),
                                    child: Icon(Icons.workspaces_rounded, color: p.onPrimaryTint),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          t.title,
                                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${t.projectType} • Lead: ${owner?.name ?? 'Student'} (${owner?.university ?? 'COMSATS'})',
                                          style: TextStyle(fontSize: 12, color: p.onSurfaceSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: fit >= 60 ? p.successTint : p.primaryTint,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '$fit% Fit',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11.5,
                                        color: fit >= 60 ? p.onSuccessTint : p.onPrimaryTint,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (t.description.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(
                                  t.description,
                                  style: TextStyle(fontSize: 13.5, color: p.onSurface, height: 1.35),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Text(
                                'OPEN ROLES NEEDED',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  letterSpacing: 0.4,
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
                                              Icon(Icons.person_search_rounded, size: 14, color: p.onWarningTint),
                                              const SizedBox(width: 4),
                                              Text(
                                                r,
                                                style: TextStyle(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w600,
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
                                  'REQUIRED SKILLS (GREEN = YOU HAVE THIS SKILL)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                    letterSpacing: 0.4,
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Members: ${t.members.map((m) => m.profile.name.split(' ').first).join(', ')}',
                                      style: TextStyle(fontSize: 12, color: p.onSurfaceSecondary),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  FilledButton.icon(
                                    onPressed: applied ? null : () => _showApplyToTeamDialog(context, t),
                                    icon: Icon(
                                      applied ? Icons.check_rounded : Icons.how_to_reg_rounded,
                                      size: 16,
                                    ),
                                    label: Text(applied ? 'Applied' : 'Apply to Join'),
                                  ),
                                ],
                              ),
                            ],
                          ),
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

    return ListView(
      padding: const EdgeInsets.all(AppTokens.pagePad),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: p.primaryTint,
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
            border: Border.all(color: p.primary.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Icon(Icons.rocket_launch_rounded, color: p.onPrimaryTint),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create a Semester Project or FYP',
                      style: TextStyle(fontWeight: FontWeight.w700, color: p.onPrimaryTint),
                    ),
                    Text(
                      'Add project description, roles & required skills. Smart Match ranks candidates for whichever project you select!',
                      style: TextStyle(fontSize: 12, color: p.onPrimaryTint.withValues(alpha: 0.9)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => _showCreateProjectDialog(context),
                child: const Text('+ Add'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (tc.myTeams.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(
                'You haven\'t created or joined any projects yet.\nTap "+ Add" above or apply to an open team!',
                textAlign: TextAlign.center,
                style: TextStyle(color: p.onSurfaceSecondary),
              ),
            ),
          ),
        for (final team in tc.myTeams)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                side: BorderSide(
                  color: tc.team?.id == team.id ? p.primary : p.border,
                  width: tc.team?.id == team.id ? 2 : 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                team.title,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16.5),
                              ),
                              Text(
                                '${team.projectType} • ${team.members.length} member(s)',
                                style: TextStyle(fontSize: 12.5, color: p.onSurfaceSecondary),
                              ),
                            ],
                          ),
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
                      Text(team.description, style: TextStyle(color: p.onSurface, fontSize: 13.5)),
                    ],
                    if (team.requiredSkills.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        'REQUIRED PROJECT SKILLS',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: p.onSurfaceSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
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
                                  child: Text(s, style: TextStyle(fontSize: 11.5, color: p.onNeutralTint)),
                                ))
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Divider(color: p.border, height: 1),
                    const SizedBox(height: 10),
                    Text(
                      'TEAM MEMBERS',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: p.onSurfaceSecondary),
                    ),
                    for (final m in team.members)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: p.primaryTint,
                          foregroundColor: p.onPrimaryTint,
                          child: Text(m.profile.initials, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(
                          '${m.profile.name}${m.profile.isMe ? ' (You)' : ''}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text('${m.profile.university} • ${m.profile.department}'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: m.isOwner ? p.primaryTint : p.neutralTint,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            m.role,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: m.isOwner ? p.onPrimaryTint : p.onNeutralTint,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 6),
                    Text(
                      'OPEN ROLES NEEDED',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: p.onSurfaceSecondary),
                    ),
                    const SizedBox(height: 6),
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
                                    r,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: p.onWarningTint,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTokens.error,
                          side: BorderSide(color: AppTokens.error.withValues(alpha: 0.5)),
                        ),
                        onPressed: tc.busy ? null : () => _confirmLeaveTeam(context, team),
                        icon: const Icon(Icons.exit_to_app_rounded, size: 16),
                        label: Text(team.iAmOwner ? 'Disband Project' : 'Leave Team'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
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
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              border: Border.all(color: p.border),
            ),
            child: TabBar(
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: p.primaryTint,
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              ),
              labelColor: p.onPrimaryTint,
              unselectedLabelColor: p.onSurfaceSecondary,
              tabs: [
                Tab(text: 'Received (${rc.received.length})'),
                Tab(text: 'Sent & Applications (${rc.sent.length})'),
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
      padding: const EdgeInsets.all(AppTokens.pagePad),
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
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: p.primaryTint,
                        foregroundColor: p.onPrimaryTint,
                        child: Text(other.initials, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(other.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text(
                              '${other.university} • ${other.department} • Sem ${other.semester}',
                              style: TextStyle(fontSize: 12, color: p.onSurfaceSecondary),
                            ),
                            if (r.teamTitle != null)
                              Text(
                                'Team: ${r.teamTitle}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
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
                          style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 11),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
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
                              const SizedBox(width: 8),
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
    final p = AppPalette.of(context);
    final me = pc.me;
    if (me == null) {
      return _ProfileEditorScreen(isInitialSetup: true, onToggleTheme: onToggleTheme);
    }

    final pct = (pc.completeness * 100).round();
    return ListView(
      padding: const EdgeInsets.all(AppTokens.pagePad),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTokens.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: p.primaryTint,
                      foregroundColor: p.onPrimaryTint,
                      child: Text(me.initials, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(me.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                          Text(
                            '${me.university} • ${me.department}',
                            style: TextStyle(color: p.onSurfaceSecondary, fontSize: 13),
                          ),
                          Text(
                            'Semester ${me.semester}',
                            style: TextStyle(color: p.onSurfaceSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Profile Completeness', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(
                            '$pct%',
                            style: TextStyle(fontWeight: FontWeight.w700, color: p.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: pc.completeness,
                          minHeight: 8,
                          backgroundColor: p.primaryTint,
                          valueColor: AlwaysStoppedAnimation<Color>(p.primary),
                        ),
                      ),
                      if (pc.missingFields.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Missing: ${pc.missingFields.join(', ')}',
                          style: TextStyle(fontSize: 12, color: p.onSurfaceSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
                if (me.workExperience.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'WORK EXPERIENCE & PAST PROJECTS',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: p.onSurfaceSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(me.workExperience, style: const TextStyle(fontSize: 13.5)),
                ],
                if (me.bio.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    'ABOUT ME / BIO',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: p.onSurfaceSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(me.bio, style: const TextStyle(fontSize: 13.5)),
                ],
                const SizedBox(height: 16),
                Text(
                  'MY SKILLS',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: p.onSurfaceSecondary),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: me.skills
                      .map((s) => Chip(label: Text(s), visualDensity: VisualDensity.compact))
                      .toList(),
                ),
                const SizedBox(height: 14),
                Text(
                  'INTERESTS & DOMAINS',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: p.onSurfaceSecondary),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: me.interests
                      .map((s) => Chip(label: Text(s), visualDensity: VisualDensity.compact))
                      .toList(),
                ),
                const SizedBox(height: 14),
                Text(
                  'WEEKLY AVAILABILITY',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: p.onSurfaceSecondary),
                ),
                const SizedBox(height: 6),
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
          content: Text('Profile saved! Add your projects anytime from the "+ Project" button or side drawer.'),
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
        title: Text(widget.isInitialSetup ? 'Set Up Your Student Profile' : 'Edit My Profile'),
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
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.pagePad),
          children: [
            if (widget.isInitialSetup)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: p.primaryTint,
                  borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                ),
                child: Text(
                  'Enter your personal academic details, skills & work experience below. '
                  'Once your profile is created, you can add Semester Projects or FYPs from the top bar or side menu!',
                  style: TextStyle(fontSize: 12.5, color: p.onPrimaryTint, height: 1.35),
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
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _uni,
                            isExpanded: true,
                            decoration: const InputDecoration(labelText: 'University *'),
                            items: kUniversities
                                .map((u) => DropdownMenuItem(value: u, child: Text(u, overflow: TextOverflow.ellipsis)))
                                .toList(),
                            onChanged: (v) => setState(() => _uni = v ?? _uni),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: _sem,
                            decoration: const InputDecoration(labelText: 'Semester *'),
                            items: kSemesters
                                .map((s) => DropdownMenuItem(value: s, child: Text('Semester $s')))
                                .toList(),
                            onChanged: (v) => setState(() => _sem = v ?? _sem),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _dept,
                      decoration: const InputDecoration(labelText: 'Department *'),
                      items: kDepartments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                      onChanged: (v) => setState(() => _dept = v ?? _dept),
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
                            : (widget.isInitialSetup ? 'Save Profile & Continue' : 'Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
// DIALOGS: Create New Project, Apply to Open Team, Send Request, Confirmations
// ============================================================================
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
      title: Text('Send Request to ${target.name}'),
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
