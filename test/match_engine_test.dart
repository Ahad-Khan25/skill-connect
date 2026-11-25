import 'package:flutter_test/flutter_test.dart';
import 'package:teamup/data/match_engine.dart';
import 'package:teamup/data/sample_data.dart';
import 'package:teamup/models/models.dart';

Profile _me({
  List<String> skills = const ['Flutter', 'Dart'],
  List<String> needed = const ['Figma', 'UI/UX Design'],
  List<String> interests = const ['AI', 'Mobile Apps'],
  String type = 'FYP',
  List<String> avail = const ['Weekends'],
  int sem = 7,
}) =>
    Profile(
      id: 'me',
      name: 'Me',
      department: 'Computer Science',
      semester: sem,
      projectType: type,
      skills: List.of(skills),
      skillsNeeded: List.of(needed),
      interests: List.of(interests),
      availability: List.of(avail),
      isMe: true,
    );

Profile _c(String id, {
  List<String> skills = const [],
  List<String> interests = const [],
  String type = 'Semester Project',
  List<String> avail = const ['Weekdays'],
  int sem = 4,
}) =>
    Profile(
      id: id,
      name: 'Cand $id',
      department: 'Software Engineering',
      semester: sem,
      projectType: type,
      skills: List.of(skills),
      interests: List.of(interests),
      availability: List.of(avail),
    );

void main() {
  group('MatchEngine.score', () {
    test('perfect candidate scores 100 with all reasons', () {
      final r = MatchEngine.score(
        _me(),
        _c('x',
            skills: ['Figma', 'UI/UX Design'],
            interests: ['AI', 'Mobile Apps'],
            type: 'FYP',
            avail: ['Weekends'],
            sem: 7),
      );
      expect(r.score, 100);
      expect(r.matchedSkills, ['Figma', 'UI/UX Design']);
      expect(r.reasons.length, 5);
      expect(r.reasons.first, 'Has 2 skills you need: Figma, UI/UX Design');
      expect(r.reasons, contains('Both doing an FYP'));
      expect(r.reasons, contains('Both free on Weekends'));
      expect(r.reasons, contains('Same semester (7)'));
    });

    test('no overlap gives only the minimum semester points', () {
      final r = MatchEngine.score(_me(), _c('x', skills: ['Java'], interests: ['Gaming']));
      expect(r.score, 2);
      expect(r.reasons, isEmpty);
    });

    test('partial: 1 of 2 skills, 1 of 3 interests, sem +-1', () {
      final r = MatchEngine.score(
        _me(),
        _c('x', skills: ['Figma'], interests: ['AI', 'Gaming'], sem: 6),
      );
      // 40*1/2=20, 25*1/3=8.33, 0, 0, 6 => 34.33 -> 34
      expect(r.score, 34);
      expect(r.reasons, contains('One semester apart'));
      expect(r.reasons, contains('1 shared interest: AI'));
    });

    test('Flexible availability overlaps everything', () {
      final r = MatchEngine.score(_me(avail: ['Weekdays']), _c('x', avail: ['Flexible']));
      expect(r.reasons, contains('Flexible schedule fits yours'));
    });

    test('no needed skills -> complementary bonus up to 20', () {
      final r = MatchEngine.score(
        _me(needed: []),
        _c('x', skills: ['Figma', 'Python', 'SQL', 'React', 'Java']),
      );
      expect(r.score, 22); // 20 bonus + 2 semester
      expect(r.reasons.first, startsWith('Brings 5 skills'));
    });

    test('score always within 0..100 for all samples', () {
      for (final p in kSampleProfiles) {
        final s = MatchEngine.score(_me(), p).score;
        expect(s, inInclusiveRange(0, 100));
      }
    });
  });

  group('MatchEngine.rank / needs / gap', () {
    final team = Team(
      id: 't',
      title: 'T',
      projectType: 'FYP',
      openRoles: ['Tester'],
      iAmOwner: true,
      members: [
        TeamMember(profile: _me(), role: 'Owner', isOwner: true),
        TeamMember(profile: _c('mate', skills: ['Figma']), role: 'Designer'),
      ],
    );

    test('needed skills include open-role skills', () {
      final n = MatchEngine.neededSkills(_me(), team);
      expect(n, containsAll(['Figma', 'UI/UX Design', 'Manual Testing', 'Automation Testing']));
    });

    test('rank excludes me and team members, sorted desc', () {
      final all = [
        _me(),
        _c('mate', skills: ['Figma']),
        ...kSampleProfiles,
      ];
      final ranked = MatchEngine.rank(_me(), all, team);
      expect(ranked.any((m) => m.profile.id == 'me' || m.profile.id == 'mate'), isFalse);
      expect(ranked.length, kSampleProfiles.length);
      for (var i = 1; i < ranked.length; i++) {
        expect(ranked[i - 1].score >= ranked[i].score, isTrue);
      }
    });

    test('skill gap = needed skills nobody on the team has', () {
      final gap = MatchEngine.skillGap(_me(), team);
      expect(gap, isNot(contains('Figma'))); // teammate has it
      expect(gap, containsAll(['UI/UX Design', 'Manual Testing', 'Automation Testing']));
    });

    test('scores are spread across sample profiles', () {
      final ranked = MatchEngine.rank(_me(), kSampleProfiles, null);
      final distinct = ranked.map((m) => m.score).toSet();
      expect(distinct.length, greaterThanOrEqualTo(3));
    });
  });
}
