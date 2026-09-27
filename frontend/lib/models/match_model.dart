class MatchScoreBreakdownModel {
  final double capabilityScore;
  final double availabilityScore;
  final double distanceScore;
  final double costScore;
  final double reliabilityScore;
  final double distanceKm;
  final double estimatedCost;

  MatchScoreBreakdownModel({
    required this.capabilityScore,
    required this.availabilityScore,
    required this.distanceScore,
    required this.costScore,
    required this.reliabilityScore,
    required this.distanceKm,
    required this.estimatedCost,
  });

  factory MatchScoreBreakdownModel.fromJson(Map<String, dynamic> json) {
    return MatchScoreBreakdownModel(
      capabilityScore: (json['capability_score'] as num?)?.toDouble() ?? 0.0,
      availabilityScore: (json['availability_score'] as num?)?.toDouble() ?? 0.0,
      distanceScore: (json['distance_score'] as num?)?.toDouble() ?? 0.0,
      costScore: (json['cost_score'] as num?)?.toDouble() ?? 0.0,
      reliabilityScore: (json['reliability_score'] as num?)?.toDouble() ?? 0.0,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      estimatedCost: (json['estimated_cost'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class MatchResultModel {
  final String? matchId;
  final String machineId;
  final String businessId;
  final String businessName;
  final String machineName;
  final String machineCategory;
  final String locationAddress;
  final double hourlyPrice;
  final double overallScore;
  final int matchPercentage;
  final MatchScoreBreakdownModel scoreBreakdown;
  final List<String> matchReasons;
  final List<String> photos;
  final double averageRating;
  final int completedJobs;
  final String verificationStatus;

  MatchResultModel({
    this.matchId,
    required this.machineId,
    required this.businessId,
    required this.businessName,
    required this.machineName,
    required this.machineCategory,
    required this.locationAddress,
    required this.hourlyPrice,
    required this.overallScore,
    required this.matchPercentage,
    required this.scoreBreakdown,
    required this.matchReasons,
    this.photos = const [],
    this.averageRating = 4.5,
    this.completedJobs = 0,
    this.verificationStatus = 'VERIFIED',
  });

  factory MatchResultModel.fromJson(Map<String, dynamic> json) {
    final reasonsList = (json['match_reasons'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final photosList = (json['photos'] as List?)?.map((e) => e.toString()).toList() ?? [];

    return MatchResultModel(
      matchId: json['match_id'],
      machineId: json['machine_id'] ?? '',
      businessId: json['business_id'] ?? '',
      businessName: json['business_name'] ?? 'MSME Partner',
      machineName: json['machine_name'] ?? '',
      machineCategory: json['machine_category'] ?? '',
      locationAddress: json['location_address'] ?? '',
      hourlyPrice: (json['hourly_price'] as num?)?.toDouble() ?? 0.0,
      overallScore: (json['overall_score'] as num?)?.toDouble() ?? 0.0,
      matchPercentage: json['match_percentage'] ?? 80,
      scoreBreakdown: MatchScoreBreakdownModel.fromJson(json['score_breakdown'] ?? {}),
      matchReasons: reasonsList,
      photos: photosList,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 4.5,
      completedJobs: json['completed_jobs'] ?? 0,
      verificationStatus: json['verification_status'] ?? 'VERIFIED',
    );
  }
}

class ComparisonItemModel {
  final String machineId;
  final String machineName;
  final String businessName;
  final String category;
  final double hourlyPrice;
  final int matchPercentage;
  final double distanceKm;
  final double estimatedCost;
  final String tolerance;
  final String dimensions;
  final double rating;
  final String verificationStatus;
  final List<String> keyReasons;

  ComparisonItemModel({
    required this.machineId,
    required this.machineName,
    required this.businessName,
    required this.category,
    required this.hourlyPrice,
    required this.matchPercentage,
    required this.distanceKm,
    required this.estimatedCost,
    required this.tolerance,
    required this.dimensions,
    required this.rating,
    required this.verificationStatus,
    this.keyReasons = const [],
  });

  factory ComparisonItemModel.fromJson(Map<String, dynamic> json) {
    final reasons = (json['key_reasons'] as List?)?.map((e) => e.toString()).toList() ?? [];
    return ComparisonItemModel(
      machineId: json['machine_id'] ?? '',
      machineName: json['machine_name'] ?? '',
      businessName: json['business_name'] ?? '',
      category: json['category'] ?? '',
      hourlyPrice: (json['hourly_price'] as num?)?.toDouble() ?? 0.0,
      matchPercentage: json['match_percentage'] ?? 0,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      estimatedCost: (json['estimated_cost'] as num?)?.toDouble() ?? 0.0,
      tolerance: json['tolerance'] ?? '',
      dimensions: json['dimensions'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      verificationStatus: json['verification_status'] ?? 'VERIFIED',
      keyReasons: reasons,
    );
  }
}

class ComparisonMatrixModel {
  final String requirementId;
  final String requirementTitle;
  final List<ComparisonItemModel> items;

  ComparisonMatrixModel({
    required this.requirementId,
    required this.requirementTitle,
    required this.items,
  });

  factory ComparisonMatrixModel.fromJson(Map<String, dynamic> json) {
    final list = (json['items'] as List?)?.map((e) => ComparisonItemModel.fromJson(e)).toList() ?? [];
    return ComparisonMatrixModel(
      requirementId: json['requirement_id'] ?? '',
      requirementTitle: json['requirement_title'] ?? '',
      items: list,
    );
  }
}
