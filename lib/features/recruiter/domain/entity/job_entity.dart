import 'package:equatable/equatable.dart';

class JobEntity extends Equatable {
  const JobEntity({
    this.id,
    required this.title,
    required this.category,
    required this.location,
    required this.employmentType,
    required this.workArrangement,
    required this.experienceLevel,
    required this.positionsAvailable,
    required this.description,
    required this.responsibilities,
    required this.requirements,
    required this.skills,
    required this.salaryType,
    this.salaryMin,
    this.salaryMax,
    this.salaryFixed,
    required this.salaryCurrency,
    required this.salaryPeriod,
    required this.benefits,
    required this.applicationDeadline,
    this.companyId,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String title;
  final String category;
  final String location;
  final String employmentType;
  final String workArrangement;
  final String experienceLevel;
  final int positionsAvailable;
  final String description;
  final List<String> responsibilities;
  final List<String> requirements;
  final String skills;
  final String salaryType;
  final int? salaryMin;
  final int? salaryMax;
  final int? salaryFixed;
  final String salaryCurrency;
  final String salaryPeriod;
  final List<String> benefits;
  final DateTime applicationDeadline;
  final String? companyId;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
    id,
    title,
    category,
    location,
    employmentType,
    workArrangement,
    experienceLevel,
    positionsAvailable,
    description,
    responsibilities,
    requirements,
    skills,
    salaryType,
    salaryMin,
    salaryMax,
    salaryFixed,
    salaryCurrency,
    salaryPeriod,
    benefits,
    applicationDeadline,
    companyId,
    status,
    createdAt,
    updatedAt,
  ];
}
