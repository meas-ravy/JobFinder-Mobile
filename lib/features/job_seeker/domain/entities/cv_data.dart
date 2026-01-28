class CvData {
  final PersonalDetails personalDetails;
  final String summary;
  final List<Experience> experiences;
  final List<Education> educations;
  final List<String> skills;

  CvData({
    required this.personalDetails,
    required this.summary,
    required this.experiences,
    required this.educations,
    required this.skills,
  });
}

class PersonalDetails {
  final String name;
  final String email;
  final String phoneNumber;
  final String address;

  PersonalDetails({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
  });
}

class Experience {
  final String jobTitle;
  final String companyName;
  final String startDate;
  final String endDate;
  final String description;

  Experience({
    required this.jobTitle,
    required this.companyName,
    required this.startDate,
    required this.endDate,
    required this.description,
  });
}

class Education {
  final String degree;
  final String institution;
  final String startDate;
  final String endDate;

  Education({
    required this.degree,
    required this.institution,
    required this.startDate,
    required this.endDate,
  });
}
