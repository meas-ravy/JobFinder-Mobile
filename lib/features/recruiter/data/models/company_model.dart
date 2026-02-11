class CompanyModel {
  final String? id;
  final String name;
  final String contactEmail;
  final String contactPhone;
  final String location;
  final String description;
  final String logoUrl;
  final bool isVerified;
  final int followerCount;
  final double hireRating;

  CompanyModel({
    this.id,
    required this.name,
    required this.contactEmail,
    required this.contactPhone,
    required this.location,
    required this.description,
    required this.logoUrl,
    this.isVerified = false,
    this.followerCount = 0,
    this.hireRating = 0.0,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? '',
      contactEmail: json['contactEmail']?.toString() ?? '',
      contactPhone: json['contactPhone']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      logoUrl: json['logoUrl']?.toString() ?? '',
      isVerified: json['isVerified'] == true,
      followerCount: (json['followerCount'] as num?)?.toInt() ?? 0,
      hireRating: (json['hireRating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'location': location,
      'description': description,
      'logoUrl': logoUrl,
    };
  }
}
