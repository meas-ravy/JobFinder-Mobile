class JobEntity {
  final String id;
  final String? recruiterId;
  final String? companyProfileId;
  final String title;
  final String? description;
  final String? location;
  final String? jobImageUrl;
  final String? category;
  final String? employmentType;
  final String? experienceLevel;
  final String? workArrangement;
  final String? salaryType;
  final double? salaryMin;
  final double? salaryMax;
  final double? salaryFixed;
  final String? salaryCurrency;
  final String? salaryPeriod;
  final String? requirements;
  final String? responsibilities;
  final String? benefits;
  final String? skills;
  final String? applicationDeadline;
  final int? positionsAvailable;
  final String? status;
  final String? rejectionReason;
  final String? submittedAt;
  final String? reviewedAt;
  final String? reviewedBy;
  final bool? isRecommended;
  final int? viewCount;
  final int? applicationCount;
  final String? createdAt;
  final String? updatedAt;
  final String? shareUrl;
  final bool? isSaved;
  final CompanyProfileEntity? companyProfile;
  final RecruiterEntity? recruiter;

  JobEntity({
    required this.id,
    this.recruiterId,
    this.companyProfileId,
    required this.title,
    this.description,
    this.location,
    this.jobImageUrl,
    this.category,
    this.employmentType,
    this.experienceLevel,
    this.workArrangement,
    this.salaryType,
    this.salaryMin,
    this.salaryMax,
    this.salaryFixed,
    this.salaryCurrency,
    this.salaryPeriod,
    this.requirements,
    this.responsibilities,
    this.benefits,
    this.skills,
    this.applicationDeadline,
    this.positionsAvailable,
    this.status,
    this.rejectionReason,
    this.submittedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.isRecommended,
    this.viewCount,
    this.applicationCount,
    this.createdAt,
    this.updatedAt,
    this.shareUrl,
    this.isSaved,
    this.companyProfile,
    this.recruiter,
  });

  JobEntity copyWith({
    String? id,
    String? title,
    bool? isSaved,
    CompanyProfileEntity? companyProfile,
    // Add other fields as needed, but at least these for now
  }) {
    return JobEntity(
      id: id ?? this.id,
      recruiterId: recruiterId,
      companyProfileId: companyProfileId,
      title: title ?? this.title,
      description: description,
      location: location,
      jobImageUrl: jobImageUrl,
      category: category,
      employmentType: employmentType,
      experienceLevel: experienceLevel,
      workArrangement: workArrangement,
      salaryType: salaryType,
      salaryMin: salaryMin,
      salaryMax: salaryMax,
      salaryFixed: salaryFixed,
      salaryCurrency: salaryCurrency,
      salaryPeriod: salaryPeriod,
      requirements: requirements,
      responsibilities: responsibilities,
      benefits: benefits,
      skills: skills,
      applicationDeadline: applicationDeadline,
      positionsAvailable: positionsAvailable,
      status: status,
      rejectionReason: rejectionReason,
      submittedAt: submittedAt,
      reviewedAt: reviewedAt,
      reviewedBy: reviewedBy,
      isRecommended: isRecommended,
      viewCount: viewCount,
      applicationCount: applicationCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      shareUrl: shareUrl,
      isSaved: isSaved ?? this.isSaved,
      companyProfile: companyProfile ?? this.companyProfile,
      recruiter: recruiter,
    );
  }
}

class CompanyProfileEntity {
  final String id;
  final String name;
  final String? logoUrl;
  final String? location;
  final int? followerCount;
  final String? contactEmail;
  final String? contactPhone;
  final String? description;

  CompanyProfileEntity({
    required this.id,
    required this.name,
    this.logoUrl,
    this.location,
    this.followerCount,
    this.contactEmail,
    this.contactPhone,
    this.description,
  });
}

class RecruiterEntity {
  final String id;
  final String? phone;

  RecruiterEntity({required this.id, this.phone});
}
