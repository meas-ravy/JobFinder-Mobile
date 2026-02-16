import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/features/recruiter/data/models/company_model.dart';

class JobCardData {
  const JobCardData({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.time,
    required this.logo,
    required this.description,
    required this.status,
    this.employmentType,
    this.workArrangement,
    this.experienceLevel,
    this.salaryMin,
    this.salaryMax,
    this.salaryCurrency,
    this.salaryPeriod,
    this.positionsAvailable,
  });

  final String id;
  final String title;
  final String company;
  final String location;
  final String time;
  final String logo;
  final String description;
  final String status;

  // New fields
  final String? employmentType;
  final String? workArrangement;
  final String? experienceLevel;
  final int? salaryMin;
  final int? salaryMax;
  final String? salaryCurrency;
  final String? salaryPeriod;
  final int? positionsAvailable;

  factory JobCardData.fromJson(DataMap json, {CompanyModel? fallbackCompany}) {
    final companyRaw = json['company'];
    DataMap? companyData;

    if (companyRaw is Map<String, dynamic>) {
      companyData = companyRaw;
    }

    final companyName =
        companyData?['name'] ?? fallbackCompany?.name ?? 'Company';
    final logo =
        companyData?['logoUrl'] ??
        companyData?['logo'] ??
        fallbackCompany?.logoUrl ??
        'https://cdn-icons-png.flaticon.com/512/3800/3800024.png';

    return JobCardData(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      company: companyName,
      location: json['location'] ?? '',
      time: 'Posted just now',
      logo: logo,
      description: json['description'] ?? '',
      status: json['status'] ?? 'Active',
      employmentType: json['employmentType'],
      workArrangement: json['workArrangement'],
      experienceLevel: json['experienceLevel'],
      salaryMin: json['salaryMin'] != null
          ? (json['salaryMin'] as num).toInt()
          : null,
      salaryMax: json['salaryMax'] != null
          ? (json['salaryMax'] as num).toInt()
          : null,
      salaryCurrency: json['salaryCurrency'],
      salaryPeriod: json['salaryPeriod'],
      positionsAvailable: json['positionsAvailable'] != null
          ? (json['positionsAvailable'] as num).toInt()
          : null,
    );
  }
}
