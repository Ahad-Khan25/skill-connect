import '../models/models.dart';

/// Clean set of 5 dummy student profiles for testing & matching.
/// No pre-existing dummy projects/teams are created—users create their own projects fresh!
String sampleId(int n) => 'a0000000-0000-4000-8000-${n.toString().padLeft(12, '0')}';

String sampleTeamId(int n) => 'b0000000-0000-4000-8000-${n.toString().padLeft(12, '0')}';

final List<Profile> kSampleProfiles = [
  Profile(
    id: sampleId(1), name: 'Ayesha Siddiqui', university: 'COMSATS Wah', department: 'Computer Science', semester: 7,
    projectType: 'FYP',
    skills: ['Flutter', 'Dart', 'Firebase', 'Git'],
    interests: ['Mobile Apps', 'Health Tech', 'AI'],
    skillsNeeded: ['UI/UX Design', 'Manual Testing'],
    availability: ['Weekdays', 'Evenings'],
    workExperience: '3-month Flutter Intern at Systems Ltd; shipped 2 apps to Google Play.',
    bio: 'Flutter dev who has shipped two apps on Play Store. Looking to build a mobile app.',
  ),
  Profile(
    id: sampleId(2), name: 'Hamza Ali', university: 'COMSATS Islamabad', department: 'Software Engineering', semester: 6,
    projectType: 'Semester Project',
    skills: ['React', 'Node.js', 'SQL', 'Git'],
    interests: ['Web Development', 'E-commerce', 'FinTech'],
    skillsNeeded: ['Figma', 'Automation Testing'],
    availability: ['Weekends'],
    workExperience: 'Freelance MERN developer (12+ client web projects).',
    bio: 'Full-stack JS enthusiast. Love clean APIs and quick prototypes.',
  ),
  Profile(
    id: sampleId(3), name: 'Fatima Zahra', university: 'COMSATS Wah', department: 'Software Engineering', semester: 7,
    projectType: 'FYP',
    skills: ['UI/UX Design', 'Figma', 'Graphic Design'],
    interests: ['Mobile Apps', 'EdTech', 'Social Impact'],
    skillsNeeded: ['Flutter', 'Firebase'],
    availability: ['Flexible'],
    workExperience: 'UI/UX Design Lead at Google Developer Student Club (GDSC).',
    bio: 'Designer at heart. I turn messy ideas into clean, usable screens.',
  ),
  Profile(
    id: sampleId(4), name: 'Muhammad Usman', university: 'NUST', department: 'Artificial Intelligence', semester: 8,
    projectType: 'FYP',
    skills: ['Python', 'Machine Learning', 'Deep Learning', 'Computer Vision'],
    interests: ['AI', 'Health Tech', 'Robotics'],
    skillsNeeded: ['Flutter', 'Technical Writing'],
    availability: ['Evenings', 'Weekends'],
    workExperience: 'Undergraduate Research Assistant at Deep Learning Lab.',
    bio: 'Working on AI & computer vision models. Looking for an app dev and writer.',
  ),
  Profile(
    id: sampleId(5), name: 'Zainab Hussain', university: 'FAST-NUCES', department: 'Computer Science', semester: 5,
    projectType: 'Semester Project',
    skills: ['Manual Testing', 'Automation Testing', 'Technical Writing', 'Documentation'],
    interests: ['Web Development', 'Cyber Security', 'EdTech'],
    skillsNeeded: ['React', 'Node.js'],
    availability: ['Weekdays', 'Flexible'],
    workExperience: 'QA & Technical Documentation Lead; automated 50+ test suites.',
    bio: 'QA and technical report specialist. I test apps thoroughly and write clear SRS docs.',
  ),
];

/// No pre-existing dummy projects/teams—projects are created fresh by users!
List<Team> buildSampleOpenTeams() => [];

/// Messages used if a sample request is sent.
const List<String> kSampleRequestMessages = [
  'Hi! Your profile looks like a great fit for my project. Want to team up?',
  'Hey, I need someone with your skills for my FYP. Interested?',
  'Saw your skills on SkillConnect, would love to work together this semester!',
];
