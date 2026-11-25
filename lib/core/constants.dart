/// Shared, fixed option lists used by profile setup, filters and the match
/// engine. Keep these in sync with `supabase/schema.sql` (role_skills()).
library;

const List<String> kUniversities = [
  'COMSATS Wah',
  'COMSATS Islamabad',
  'NUST',
  'FAST-NUCES',
  'UET Taxila',
  'AIR University',
  'GIKI',
];

const List<String> kDepartments = [
  'Computer Science',
  'Software Engineering',
  'Artificial Intelligence',
  'Data Science',
  'Cyber Security',
  'Electrical Engineering',
];

/// Short labels for small cards / chips (e.g. "CS").
const Map<String, String> kDepartmentShort = {
  'Computer Science': 'CS',
  'Software Engineering': 'SE',
  'Artificial Intelligence': 'AI',
  'Data Science': 'DS',
  'Cyber Security': 'CYS',
  'Electrical Engineering': 'EE',
};

const List<int> kSemesters = [4, 5, 6, 7, 8];

const List<String> kSkills = [
  'Flutter',
  'Dart',
  'React',
  'Node.js',
  'Firebase',
  'SQL',
  'Java',
  'Kotlin',
  'Python',
  'Machine Learning',
  'Deep Learning',
  'Data Analysis',
  'Computer Vision',
  'NLP',
  'UI/UX Design',
  'Figma',
  'Graphic Design',
  'Manual Testing',
  'Automation Testing',
  'Technical Writing',
  'Documentation',
  'Project Management',
  'Arduino',
  'IoT',
  'Embedded C',
  'Cloud',
  'Git',
];

const List<String> kInterests = [
  'AI',
  'Web Development',
  'Mobile Apps',
  'Health Tech',
  'FinTech',
  'EdTech',
  'Gaming',
  'IoT',
  'Cyber Security',
  'Blockchain',
  'E-commerce',
  'Social Impact',
  'Robotics',
  'Data Science',
  'AR/VR',
];

const List<String> kProjectTypes = ['Semester Project', 'FYP'];

const List<String> kAvailability = ['Weekdays', 'Weekends', 'Evenings', 'Flexible'];

const List<String> kRoles = [
  'Developer',
  'Designer',
  'Tester',
  'Report Writer',
  'Data/ML Engineer',
];

/// Which skills "cover" a role. Used to (a) turn a team's open roles into
/// needed skills for matching and (b) pick the best role for a new member.
const Map<String, List<String>> kRoleSkills = {
  'Developer': ['Flutter', 'React', 'Node.js', 'Firebase', 'SQL'],
  'Designer': ['UI/UX Design', 'Figma', 'Graphic Design'],
  'Tester': ['Manual Testing', 'Automation Testing'],
  'Report Writer': ['Technical Writing', 'Documentation', 'Project Management'],
  'Data/ML Engineer': ['Python', 'Machine Learning', 'Deep Learning', 'Data Analysis'],
};

/// Validation limits.
const int kMaxBioLength = 300;
const int kMaxExperienceLength = 400;
const int kMaxProjectDescription = 500;
const int kMaxRequestMessage = 200;
const int kMaxTeamTitle = 60;

