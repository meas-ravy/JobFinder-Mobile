import 'package:job_finder/features/job_seeker/domain/entities/job_entity.dart';

class JobModel extends JobEntity {
  JobModel({
    required super.id,
    super.recruiterId,
    super.companyProfileId,
    required super.title,
    super.description,
    super.location,
    super.jobImageUrl,
    super.category,
    super.employmentType,
    super.experienceLevel,
    super.workArrangement,
    super.salaryType,
    super.salaryMin,
    super.salaryMax,
    super.salaryFixed,
    super.salaryCurrency,
    super.salaryPeriod,
    super.requirements,
    super.responsibilities,
    super.benefits,
    super.skills,
    super.applicationDeadline,
    super.positionsAvailable,
    super.status,
    super.rejectionReason,
    super.submittedAt,
    super.reviewedAt,
    super.reviewedBy,
    super.isRecommended,
    super.viewCount,
    super.applicationCount,
    super.createdAt,
    super.updatedAt,
    super.shareUrl,
    super.isSaved,
    super.companyProfile,
    super.recruiter,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] ?? json['_id'] ?? '',
      recruiterId: json['recruiterId'],
      companyProfileId: json['companyProfileId'],
      title: json['title'] ?? '',
      description: json['description'],
      location: json['location'],
      jobImageUrl: json['jobImageUrl'],
      category: json['category'],
      employmentType: json['employmentType'],
      experienceLevel: json['experienceLevel'],
      workArrangement: json['workArrangement'],
      salaryType: json['salaryType'],
      salaryMin: json['salaryMin'] != null
          ? (json['salaryMin'] as num).toDouble()
          : null,
      salaryMax: json['salaryMax'] != null
          ? (json['salaryMax'] as num).toDouble()
          : null,
      salaryFixed: json['salaryFixed'] != null
          ? (json['salaryFixed'] as num).toDouble()
          : null,
      salaryCurrency: json['salaryCurrency'],
      salaryPeriod: json['salaryPeriod'],
      requirements: json['requirements'],
      responsibilities: json['responsibilities'],
      benefits: json['benefits'],
      skills: json['skills'],
      applicationDeadline: json['applicationDeadline'],
      positionsAvailable: json['positionsAvailable'],
      status: json['status'],
      rejectionReason: json['rejectionReason'],
      submittedAt: json['submittedAt'],
      reviewedAt: json['reviewedAt'],
      reviewedBy: json['reviewedBy'],
      isRecommended: json['isRecommended'],
      viewCount: json['viewCount'],
      applicationCount: json['applicationCount'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      shareUrl: json['shareUrl'],
      isSaved: json['isSaved'] ?? json['is_saved'] ?? false,
      companyProfile: json['companyProfile'] != null
          ? CompanyProfileModel.fromJson(json['companyProfile'])
          : null,
      recruiter: json['recruiter'] != null
          ? RecruiterModel.fromJson(json['recruiter'])
          : null,
    );
  }
}

class CompanyProfileModel extends CompanyProfileEntity {
  CompanyProfileModel({
    required super.id,
    required super.name,
    super.logoUrl,
    super.location,
    super.followerCount,
    super.contactEmail,
    super.contactPhone,
    super.description,
  });

  factory CompanyProfileModel.fromJson(Map<String, dynamic> json) {
    return CompanyProfileModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      logoUrl: json['logoUrl'],
      location: json['location'],
      followerCount: json['followerCount'],
      contactEmail: json['contactEmail'],
      contactPhone: json['contactPhone'],
      description: json['description'],
    );
  }
}

class RecruiterModel extends RecruiterEntity {
  RecruiterModel({required super.id, super.phone});

  factory RecruiterModel.fromJson(Map<String, dynamic> json) {
    return RecruiterModel(
      id: json['id'] ?? json['_id'] ?? '',
      phone: json['phone'],
    );
  }
}
