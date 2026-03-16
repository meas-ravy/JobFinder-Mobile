import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/features/recruiter/domain/entity/job_entity.dart';

class JobModel extends JobEntity {
  const JobModel({
    super.id,
    required super.title,
    required super.category,
    required super.location,
    required super.employmentType,
    required super.workArrangement,
    required super.experienceLevel,
    required super.positionsAvailable,
    required super.description,
    required super.responsibilities,
    required super.requirements,
    required super.skills,
    required super.salaryType,
    super.salaryMin,
    super.salaryMax,
    super.salaryFixed,
    required super.salaryCurrency,
    required super.salaryPeriod,
    required super.benefits,
    required super.applicationDeadline,
    super.companyId,
    super.status,
    super.createdAt,
    super.updatedAt,
  });

  factory JobModel.fromMap(DataMap map) {
    final salaryMin = _parseInt(map['salaryMin']);
    final salaryType = (map['salaryType'] as String?) ?? 'Negotiable';

    return JobModel(
      id: map['_id']?.toString() ?? map['id']?.toString(),
      title: (map['title'] as String?) ?? '',
      category: (map['category'] as String?) ?? '',
      location: (map['location'] as String?) ?? '',
      employmentType: (map['employmentType'] as String?) ?? '',
      workArrangement: (map['workArrangement'] as String?) ?? '',
      experienceLevel: (map['experienceLevel'] as String?) ?? '',
      positionsAvailable: _parseInt(map['positionsAvailable']),
      description: (map['description'] as String?) ?? '',
      responsibilities: _parseList(map['responsibilities']),
      requirements: _parseList(map['requirements']),
      skills: (map['skills'] as String?) ?? '',
      salaryType: salaryType,
      salaryMin: salaryMin,
      salaryMax: _parseInt(map['salaryMax']),
      salaryFixed: salaryType == 'Fixed'
          ? salaryMin
          : _parseInt(map['salaryFixed']),
      salaryCurrency: (map['salaryCurrency'] as String?) ?? 'USD',
      salaryPeriod: (map['salaryPeriod'] as String?) ?? 'Month',
      benefits: _parseList(map['benefits']),
      applicationDeadline: _parseDate(map['applicationDeadline']),
      companyId: map['companyId']?.toString(),
      status: map['status']?.toString(),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString())
          : null,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static List<String> _parseList(dynamic value) {
    if (value == null) return [];
    if (value is List) return List<String>.from(value);
    if (value is String) {
      // Handle the bulleted string format from FormListInput
      return value
          .split('\n')
          .where((e) => e.trim().startsWith('• '))
          .map((e) => e.replaceFirst('• ', '').trim())
          .toList();
    }
    return [];
  }

  DataMap toJson() {
    return {
      'title': title,
      'category': category,
      'location': location,
      'employmentType': employmentType,
      'workArrangement': workArrangement,
      'experienceLevel': experienceLevel,
      'positionsAvailable': positionsAvailable,
      'description': description,
      'responsibilities': responsibilities.map((e) => '• $e').join('\n'),
      'requirements': requirements.map((e) => '• $e').join('\n'),
      'skills': skills,
      'salaryType': salaryType,
      'salaryMin': salaryMin,
      'salaryMax': salaryMax,
      if (salaryFixed != null) 'salaryFixed': salaryFixed,
      'salaryCurrency': salaryCurrency,
      'salaryPeriod': salaryPeriod,
      'benefits': benefits.map((e) => '• $e').join('\n'),
      'applicationDeadline': applicationDeadline.toIso8601String(),
    };
  }

  JobModel copyWith({
    String? title,
    String? category,
    String? location,
    String? employmentType,
    String? workArrangement,
    String? experienceLevel,
    int? positionsAvailable,
    String? description,
    List<String>? responsibilities,
    List<String>? requirements,
    String? skills,
    String? salaryType,
    int? salaryMin,
    int? salaryMax,
    int? salaryFixed,
    String? salaryCurrency,
    String? salaryPeriod,
    List<String>? benefits,
    DateTime? applicationDeadline,
  }) {
    return JobModel(
      title: title ?? this.title,
      category: category ?? this.category,
      location: location ?? this.location,
      employmentType: employmentType ?? this.employmentType,
      workArrangement: workArrangement ?? this.workArrangement,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      positionsAvailable: positionsAvailable ?? this.positionsAvailable,
      description: description ?? this.description,
      responsibilities: responsibilities ?? this.responsibilities,
      requirements: requirements ?? this.requirements,
      skills: skills ?? this.skills,
      salaryType: salaryType ?? this.salaryType,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      salaryFixed: salaryFixed ?? this.salaryFixed,
      salaryCurrency: salaryCurrency ?? this.salaryCurrency,
      salaryPeriod: salaryPeriod ?? this.salaryPeriod,
      benefits: benefits ?? this.benefits,
      applicationDeadline: applicationDeadline ?? this.applicationDeadline,
    );
  }
}

DataMap normalizeData(DataMap? data) {
  if (data == null) return {};
  final normalized = DataMap.from(data);

  // Normalize applicationDeadline
  if (normalized['applicationDeadline'] is String) {
    normalized['applicationDeadline'] = DateTime.tryParse(
      normalized['applicationDeadline'],
    );
  }

  // Normalize salary fields to String for FormBuilder compatibility
  if (normalized['salaryMin'] != null) {
    normalized['salaryMin'] = normalized['salaryMin'].toString();
  }
  if (normalized['salaryMax'] != null) {
    normalized['salaryMax'] = normalized['salaryMax'].toString();
  }

  // Normalize positionsAvailable to String
  if (normalized['positionsAvailable'] != null) {
    normalized['positionsAvailable'] = normalized['positionsAvailable']
        .toString();
  }

  return normalized;
}
