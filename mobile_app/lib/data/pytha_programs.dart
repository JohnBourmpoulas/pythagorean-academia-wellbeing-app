class PythaProgram {
  final String title;
  final String shortTitle;
  final String description;
  final String duration;
  final List<String> benefits;
  final List<String> activities;

  const PythaProgram({
    required this.title,
    required this.shortTitle,
    required this.description,
    required this.duration,
    required this.benefits,
    required this.activities,
  });
}

const List<PythaProgram> pythaPrograms = [
  PythaProgram(
    title:
    'Pythagorean Academia Retreat for Stress Management, Biological Age Reversion, Memory Improvement & Well-being',
    shortTitle: 'Stress Management Retreat',
    description:
    'Comprehensive 8-week program for stress management, biological age reversion, memory improvement and overall wellbeing.',
    duration: '8 weeks',
    benefits: [
      'Reduce stress levels',
      'Improve memory',
      'Enhance wellbeing',
    ],
    activities: [
      'Daily Meditation',
      'Breathing Exercises',
      'Progress Tracking',
      'Wellness Library',
    ],
  ),
  PythaProgram(
    title: 'Biological Age Measurement and Reversion',
    shortTitle: 'Biological Age Measurement',
    description:
    'A specialized program focused on measuring and supporting the reversion of biological age through lifestyle, wellbeing and biometric monitoring.',
    duration: '6 weeks',
    benefits: [
      'Measure biological age',
      'Track health indicators',
      'Improve lifestyle habits',
    ],
    activities: [
      'Biometric Tracking',
      'Lifestyle Monitoring',
      'Progress Dashboard',
      'Educational Content',
    ],
  ),
  PythaProgram(
    title: 'Training and Certification for Physicians and Healthcare Professionals',
    shortTitle: 'Physician Certification Program',
    description:
    'Training and certification in the Pythagorean Self-Awareness technique for physicians and healthcare professionals.',
    duration: '12 weeks',
    benefits: [
      'Professional certification',
      'Learn Pythagorean Self-Awareness',
      'Apply techniques in healthcare practice',
    ],
    activities: [
      'Seminars',
      'Training Modules',
      'Case Studies',
      'Certification Assessment',
    ],
  ),
];