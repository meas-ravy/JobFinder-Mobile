class TemplatesModel {
  const TemplatesModel({
    required this.id,
    required this.fullName,
    required this.jobTitle,
    required this.email,
    required this.phone,
    required this.profile,
    required this.skills,
    required this.links,
    required this.languages,
    required this.education,
    required this.experience,
  });

  final String id;
  final String fullName;
  final String jobTitle;
  final String email;
  final String phone;
  final String profile;
  final List<String> education;
  final List<String> experience;
  final List<String> skills;
  final List<String> links;
  final List<String> languages;
}