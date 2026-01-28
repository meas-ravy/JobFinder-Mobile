class CvModel {
  String fullName;
  String email;
  String phone;
  String summary;
  List<String> skills;
  List<Experience> experience;

  CvModel({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.summary = '',
    this.skills = const [],
    this.experience = const [],
  });
}

class Experience {
  String jobTitle;
  String company;
  String dateRange;
  Experience({
    required this.jobTitle,
    required this.company,
    required this.dateRange,
  });
}
