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

/// Default role responsibilities shown when a student views a project they joined.
const Map<String, List<String>> kRoleResponsibilities = {
  'Owner': [
    'Coordinate project roadmap, milestones & weekly supervisor reviews',
    'Review & integrate deliverables across development, design & testing',
    'Manage team roles, project documentation & final presentation pitch',
  ],
  'Developer': [
    'Architect and implement core mobile/web application features & UI flows',
    'Integrate backend APIs, authentication, database queries & state management',
    'Maintain clean Git branches, code reviews & release builds',
  ],
  'Designer': [
    'Design high-fidelity wireframes, user flows & Figma prototypes',
    'Maintain consistent design tokens (colors, typography, icons & spacing)',
    'Conduct usability checks & ensure responsive layouts on mobile screens',
  ],
  'Tester': [
    'Create test plans, edge-case scenarios & automated/manual QA checklists',
    'Verify bug fixes, form validations, offline caching & device compatibility',
    'Sign off on release APK stability before demonstrations',
  ],
  'Report Writer': [
    'Draft SRS, system architecture diagrams (UML/ERD) & proposal documents',
    'Maintain weekly progress logs, user manuals & final FYP/semester report',
    'Prepare presentation slides & 2-minute demo script for evaluation',
  ],
  'Data/ML Engineer': [
    'Collect, clean & preprocess datasets and build analytical/ML pipelines',
    'Train, evaluate & optimize models and expose inference endpoints',
    'Document model accuracy metrics, feature importance & evaluation charts',
  ],
  'Member': [
    'Collaborate with the project lead on assigned module deliverables',
    'Participate in weekly standups, testing & documentation updates',
  ],
};

/// Validation limits.
const int kMaxBioLength = 300;
const int kMaxExperienceLength = 400;
const int kMaxProjectDescription = 500;
const int kMaxRequestMessage = 200;
const int kMaxTeamTitle = 60;

