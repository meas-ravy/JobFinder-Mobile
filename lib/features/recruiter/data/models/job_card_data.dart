import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/features/recruiter/data/models/company_model.dart';

class JobCardData {
  final String id;
  final String title;
  final String company;
  final String logo;
  final String location;
  final int? salaryMin;
  final int? salaryMax;
  final String? salaryCurrency;
  final String? salaryPeriod;
  final String? employmentType;
  final String? workArrangement;
  final String? experienceLevel;
  final int? positionsAvailable;
  final String status;
  final String description;
  final String? rejectionReason;

  JobCardData({
    required this.id,
    required this.title,
    required this.company,
    required this.logo,
    required this.location,
    required this.status,
    required this.description,
    this.salaryMin,
    this.salaryMax,
    this.salaryCurrency,
    this.salaryPeriod,
    this.employmentType,
    this.workArrangement,
    this.experienceLevel,
    this.positionsAvailable,
    this.rejectionReason,
  });

  factory JobCardData.fromJson(
    DataMap json, {
    CompanyModel? fallbackCompany,
  }) {
    // Determine company name and logo
    String companyName = '';
    String companyLogo = '';

    // Check if job json has company object
    if (json['company'] != null && json['company'] is Map<String, dynamic>) {
      final compJson = json['company'] as Map<String, dynamic>;
      companyName = compJson['name']?.toString() ?? '';
      companyLogo = compJson['logoUrl']?.toString() ?? '';
    } else if (fallbackCompany != null) {
      companyName = fallbackCompany.name;
      companyLogo = fallbackCompany.logoUrl;
    } else {
      // Last resort fallbacks
      companyName = json['companyName']?.toString() ?? 'Unknown Company';
      companyLogo = json['companyLogo']?.toString() ?? '';
    }

    return JobCardData(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      company: companyName,
      logo: companyLogo,
      location: (json['location'] ?? fallbackCompany?.location ?? '')
          .toString(),
      status: (json['status'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      salaryMin: json['salaryMin'] != null
          ? int.tryParse(json['salaryMin'].toString())
          : null,
      salaryMax: json['salaryMax'] != null
          ? int.tryParse(json['salaryMax'].toString())
          : null,
      salaryCurrency: json['salaryCurrency']?.toString(),
      salaryPeriod: json['salaryPeriod']?.toString(),
      employmentType: json['employmentType']?.toString(),
      workArrangement: json['workArrangement']?.toString(),
      experienceLevel: json['experienceLevel']?.toString(),
      positionsAvailable: json['positionsAvailable'] != null
          ? int.tryParse(json['positionsAvailable'].toString())
          : null,
      rejectionReason: json['rejectionReason']?.toString(),
    );
  }
}
