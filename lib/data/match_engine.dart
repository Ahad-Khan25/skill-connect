import '../core/constants.dart';
import '../models/models.dart';

/// # TeamUp Smart Match
///
/// Pure, deterministic scoring of how good a teammate a candidate is for me.
/// No I/O, no randomness -> easy to unit test and explain.
///
/// **Needed skills** = my "skills I'm looking for" ∪ skills implied by my
/// team's open roles (see [kRoleSkills]).
///
/// | Factor            | Weight | How it is computed                                          |
/// |-------------------|-------:|-------------------------------------------------------------|
/// | Skill fit         |   40   | 40 × (needed skills the candidate has ÷ all needed skills)  |
/// |                   |        | (no needed skills → up to 20 pts for skills I don't have,   |
/// |                   |        |  5 pts each, max 4)                                         |
/// | Shared interests  |   25   | 25 × Jaccard(my interests, their interests) = ∩ ÷ ∪         |
/// | Project type      |   15   | 15 if same (FYP / Semester Project), else 0                 |
/// | Availability      |   10   | 10 if any slot overlaps ("Flexible" overlaps everything)    |
/// | Semester          |   10   | same 10, ±1 → 6, otherwise 2                                |
///
/// Final score = sum, rounded, clamped to 0..100. Every factor that adds
/// points also adds a human-readable reason shown on the match card.
class MatchEngine {
  static const int wSkill = 40;
  static const int wComplementary = 20;
  static const int wInterests = 25;
  static const int wProjectType = 15;
  static const int wAvailability = 10;
  static const int wSemester = 10;

  /// Skills I need: my skillsNeeded + active project's requiredSkills + skills of open roles.
  static Set<String> neededSkills(Profile me, Team? team) {
    final needed = <String>{...me.skillsNeeded, ...?team?.requiredSkills};
    for (final role in team?.openRoles ?? const <String>[]) {
      needed.addAll(kRoleSkills[role] ?? const []);
    }
    return needed;
  }

  /// Target interests/domains: active project's domainTags (if set) union my personal interests.
  static Set<String> targetInterests(Profile me, Team? team) {
    if (team != null && team.domainTags.isNotEmpty) {
      return <String>{...team.domainTags, ...me.interests};
    }
    return me.interests.toSet();
  }

  /// Score a single candidate against me (and my active project/team if provided).
  static MatchResult score(Profile me, Profile candidate, {Set<String>? needed, Team? activeTeam}) {
    needed ??= neededSkills(me, activeTeam);
    final reasons = <String>[];
    double total = 0;

    // 1) Skill fit (40)
    List<String> matched = [];
    if (needed.isNotEmpty) {
      matched = candidate.skills.where(needed.contains).toList();
      total += wSkill * matched.length / needed.length;
      if (matched.isNotEmpty) {
        final targetLabel = activeTeam != null ? 'for "${activeTeam.title}"' : 'you need';
        reasons.add('Has ${_plural(matched.length, 'skill')} $targetLabel: ${_list(matched)}');
      }
    } else {
      final mine = me.skills.toSet();
      final complementary = candidate.skills.where((s) => !mine.contains(s)).toList();
      final counted = complementary.length > 4 ? 4 : complementary.length;
      total += wComplementary * counted / 4;
      matched = complementary;
      if (complementary.isNotEmpty) {
        reasons.add('Brings ${_plural(complementary.length, 'skill')} you don\'t have: ${_list(complementary)}');
      }
    }

    // 2) Shared interests / project domains (25) – Jaccard similarity
    final a = targetInterests(me, activeTeam), b = candidate.interests.toSet();
    final inter = a.intersection(b);
    final union = a.union(b);
    if (union.isNotEmpty) total += wInterests * inter.length / union.length;
    if (inter.isNotEmpty) {
      final list = candidate.interests.where(inter.contains).toList();
      reasons.add('${_plural(inter.length, 'shared interest')}: ${_list(list)}');
    }

    // 3) Project type (15) – uses active project's type if selected, else my profile's projectType
    final targetType = (activeTeam != null && activeTeam.projectType.isNotEmpty)
        ? activeTeam.projectType
        : me.projectType;
    if (targetType.isNotEmpty && targetType == candidate.projectType) {
      total += wProjectType;
      reasons.add(targetType == 'FYP' ? 'Both doing an FYP' : 'Both doing a $targetType');
    }

    // 4) Availability (10)
    final av = availabilityOverlap(me.availability, candidate.availability);
    if (av != null) {
      total += wAvailability;
      reasons.add(av);
    }

    // 5) Semester closeness (10)
    final diff = (me.semester - candidate.semester).abs();
    if (diff == 0) {
      total += wSemester;
      reasons.add('Same semester (${candidate.semester})');
    } else if (diff == 1) {
      total += 6;
      reasons.add('One semester apart');
    } else {
      total += 2;
    }

    final s = total.round().clamp(0, 100);
    return MatchResult(profile: candidate, score: s, reasons: reasons, matchedSkills: matched);
  }

  /// Returns a reason string if availabilities overlap, else null.
  static String? availabilityOverlap(List<String> mine, List<String> theirs) {
    if (mine.isEmpty || theirs.isEmpty) return null;
    final common = mine.where(theirs.contains).where((e) => e != 'Flexible').toList();
    if (common.isNotEmpty) return 'Both free on ${_list(common)}';
    if (mine.contains('Flexible') && theirs.contains('Flexible')) return 'Both have flexible schedules';
    if (theirs.contains('Flexible')) return 'Flexible schedule fits yours';
    if (mine.contains('Flexible')) return 'Free on ${_list(theirs)} (you\'re flexible)';
    return null;
  }

  /// Rank everyone except me and my team members, highest score first
  /// (ties broken by name for a stable order).
  static List<MatchResult> rank(Profile me, List<Profile> all, Team? team) {
    final excluded = <String>{me.id, ...?team?.members.map((m) => m.profile.id)};
    final needed = neededSkills(me, team);
    final results = all
        .where((p) => !excluded.contains(p.id) && !p.isMe)
        .map((p) => score(me, p, needed: needed, activeTeam: team))
        .toList();
    results.sort((x, y) {
      final c = y.score.compareTo(x.score);
      return c != 0 ? c : x.profile.name.compareTo(y.profile.name);
    });
    return results;
  }

  /// Score how well an open project/team fits MY skills & interests (for the
  /// "Browse & Join Teams" board).
  static int scoreTeamForMe(Profile me, Team team) {
    final needed = <String>{
      ...team.requiredSkills,
      for (final r in team.openRoles) ...(kRoleSkills[r] ?? const []),
    };
    double total = 0;
    if (needed.isNotEmpty) {
      final matched = me.skills.where(needed.contains).length;
      total += 55 * (matched / needed.length);
    } else {
      total += 25;
    }
    final myInt = me.interests.toSet();
    final teamDom = <String>{
      ...team.domainTags,
      for (final m in team.members) ...m.profile.interests,
    };
    final union = myInt.union(teamDom);
    if (union.isNotEmpty) {
      total += 25 * (myInt.intersection(teamDom).length / union.length);
    }
    if (me.projectType == team.projectType) total += 20;
    return total.round().clamp(0, 100);
  }

  /// Needed skills that nobody on my team (including me) already has.
  static List<String> skillGap(Profile me, Team? team) {
    final covered = <String>{...me.skills};
    for (final m in team?.members ?? const <TeamMember>[]) {
      covered.addAll(m.profile.skills);
    }
    final gap = neededSkills(me, team).where((s) => !covered.contains(s)).toList();
    gap.sort((a, b) => kSkills.indexOf(a).compareTo(kSkills.indexOf(b)));
    return gap;
  }

  static String _plural(int n, String word) => '$n ${n == 1 ? word : '${word}s'}';

  static String _list(List<String> items) {
    if (items.length <= 3) return items.join(', ');
    return '${items.take(3).join(', ')} +${items.length - 3}';
  }
}
