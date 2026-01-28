import 'package:objectbox/objectbox.dart';

@Entity()
class CvEntity {
  @Id()
  int id = 0; // ObjectBox requires an integer ID. 0 means it's a new object.

  /// To identify this CV in a list (e.g., "Software Engineer CV", "Manager Resume")
  String title;
  String imgurl;

  // --- Personal Details ---
  String fullName;
  String email;
  String phone;
  String address;
  String? linkedinUrl;
  String? github;
  String? website;

  // --- Professional Summary ---
  String? summary;

  // --- Skills ---
  // ObjectBox supports List<String> natively.
  List<String> skills;
  List<String> language;

  // --- Relationships ---
  // We use ToMany for lists of complex objects.
  final exp = ToMany<ExpEntity>();
  final edu = ToMany<EduEntity>();
  final project = ToMany<Project>();
  final ref = ToMany<Reference>();

  // --- Metadata ---
  @Property(type: PropertyType.date)
  DateTime updatedAt;

  CvEntity({
    this.id = 0,
    required this.imgurl,
    required this.title,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    this.linkedinUrl,
    this.github,
    this.website,
    required this.summary,
    this.skills = const [],
    this.language = const [],
    required this.updatedAt,
  });
}

@Entity()
class Project {
  @Id()
  int id = 0;

  String projectName;
  String projectdec;
  String projectUrl;
  String techStack;

  @Property(type: PropertyType.date)
  DateTime? startDate;
  @Property(type: PropertyType.date)
  DateTime? endDate;

  Project({
    this.id = 0,
    required this.projectName,
    required this.projectdec,
    required this.projectUrl,
    required this.techStack,
  });
}

@Entity()
class Reference {
  @Id()
  int id = 0;

  String name;
  String position;
  String? company;
  String phone;
  String email;

  Reference({
    this.id = 0,
    required this.name,
    required this.position,
    required this.company,
    required this.phone,
    required this.email,
  });
}

@Entity()
class EduEntity {
  EduEntity({
    this.id = 0,
    required this.institution,
    required this.degree,
    required this.startDate,
    required this.endDate,
  });

  @Id()
  int id = 0;
  String institution;
  String degree;

  @Property(type: PropertyType.date)
  DateTime startDate;

  @Property(type: PropertyType.date)
  DateTime endDate;
}

@Entity()
class ExpEntity {
  ExpEntity({
    this.id = 0,
    required this.jobTitle,
    required this.companyName,
    required this.description,
    required this.startDate,
    required this.endDate,
  });

  @Id()
  int id = 0;

  String jobTitle;
  String companyName;
  String description;
  @Property(type: PropertyType.date)
  DateTime startDate;
  @Property(type: PropertyType.date)
  DateTime endDate;
}
