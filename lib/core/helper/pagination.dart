class PaginationInfo {
  final int page;
  final int limit;
  final int totalCount;
  final int totalPages;

  const PaginationInfo({
    required this.page,
    required this.limit,
    required this.totalCount,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'],
      limit: json['limit'],
      totalCount: json['totalCount'],
      totalPages: json['totalPages'],
    );
  }

  bool get hasMore => page < totalPages;

  PaginationInfo copyWith({
    int? page,
    int? limit,
    int? totalCount,
    int? totalPages,
  }) {
    return PaginationInfo(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      totalCount: totalCount ?? this.totalCount,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}
