// PLACEHOLDER – owned by the UI teammate. Replace freely.
// Shows how to consume the controllers: auth gate -> profile gate -> home.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/state.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeamUp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const _Gate(),
    );
  }
}

class _Gate extends StatelessWidget {
  const _Gate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final profile = context.watch<ProfileController>();
    if (auth.status == AuthStatus.unknown) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (auth.status == AuthStatus.signedOut) return const _SignIn();
    return switch (profile.state) {
      LoadState.loading when profile.me == null =>
        const Scaffold(body: Center(child: CircularProgressIndicator())),
      LoadState.error when profile.me == null => Scaffold(
          body: Center(
            child: TextButton(onPressed: profile.refresh, child: Text('${profile.error}\nTap to retry')),
          ),
        ),
      _ when !profile.hasProfile => const _QuickSetup(),
      _ => const _Debug(),
    };
  }
}

class _SignIn extends StatefulWidget {
  const _SignIn();
  @override
  State<_SignIn> createState() => _SignInState();
}

class _SignInState extends State<_SignIn> {
  final _email = TextEditingController(text: 'demo@teamup.app');
  final _pass = TextEditingController(text: 'password');
  final _name = TextEditingController(text: 'Test Student');

  Future<void> _go(bool signUp) async {
    final auth = context.read<AuthController>();
    final err = signUp
        ? await auth.signUp(_name.text, _email.text, _pass.text)
        : await auth.signIn(_email.text, _pass.text);
    if (err != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<AuthController>().busy;
    return Scaffold(
      appBar: AppBar(title: const Text('TeamUp (placeholder UI)')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name (sign up)')),
        TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
        TextField(controller: _pass, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
        const SizedBox(height: 16),
        FilledButton(onPressed: busy ? null : () => _go(false), child: const Text('Sign in')),
        OutlinedButton(onPressed: busy ? null : () => _go(true), child: const Text('Sign up')),
      ]),
    );
  }
}

class _QuickSetup extends StatelessWidget {
  const _QuickSetup();
  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Profile setup (placeholder)')),
      body: Center(
        child: FilledButton(
          onPressed: () async {
            final err = await context.read<ProfileController>().save(Profile(
                  name: auth.signUpName ?? 'New Student',
                  department: kDepartments.first,
                  semester: 7,
                  projectType: 'FYP',
                  skills: ['Flutter', 'Dart'],
                  interests: ['Mobile Apps', 'AI'],
                  skillsNeeded: ['Figma', 'UI/UX Design'],
                  availability: ['Weekends'],
                ));
            if (err != null && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
            }
          },
          child: const Text('Save sample profile'),
        ),
      ),
    );
  }
}

class _Debug extends StatelessWidget {
  const _Debug();
  @override
  Widget build(BuildContext context) {
    final me = context.watch<ProfileController>().me!;
    final matches = context.watch<MatchController>();
    final req = context.watch<RequestsController>();
    final team = context.watch<TeamController>();
    final disc = context.watch<DiscoverController>();
    return Scaffold(
      appBar: AppBar(title: Text('Hi ${me.name}'), actions: [
        IconButton(onPressed: context.read<AuthController>().signOut, icon: const Icon(Icons.logout)),
      ]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text('Discover: ${disc.state.name}, ${disc.results.length} students${disc.offline ? ' (offline)' : ''}'),
        Text('Requests: ${req.state.name}, sent ${req.sent.length}, received ${req.received.length}, pending ${req.pendingReceivedCount}'),
        Text('Team: ${team.state.name} ${team.team?.title ?? ''} open ${team.team?.openRoles ?? []}'),
        Text('Skill gap: ${matches.skillGap}'),
        const Divider(),
        for (final m in matches.matches.take(8))
          ListTile(
            title: Text('${m.profile.name}  •  ${m.score}%'),
            subtitle: Text(m.reasons.join('\n')),
          ),
      ]),
    );
  }
}
