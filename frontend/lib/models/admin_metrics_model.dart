class AdminMetricsModel {
  final int totalMsmes;
  final int totalProviders;
  final int totalSeekers;
  final int activeMachines;
  final int activeRequirements;
  final int totalBookings;
  final int completedJobs;
  final double totalGmvInr;
  final double platformRevenueInr;
  final double matchSuccessRatePercent;

  AdminMetricsModel({
    required this.totalMsmes,
    required this.totalProviders,
    required this.totalSeekers,
    required this.activeMachines,
    required this.activeRequirements,
    required this.totalBookings,
    required this.completedJobs,
    required this.totalGmvInr,
    required this.platformRevenueInr,
    required this.matchSuccessRatePercent,
  });

  factory AdminMetricsModel.fromJson(Map<String, dynamic> json) {
    return AdminMetricsModel(
      totalMsmes: json['total_msmes'] ?? 0,
      totalProviders: json['total_providers'] ?? 0,
      totalSeekers: json['total_seekers'] ?? 0,
      activeMachines: json['active_machines'] ?? 0,
      activeRequirements: json['active_requirements'] ?? 0,
      totalBookings: json['total_bookings'] ?? 0,
      completedJobs: json['completed_jobs'] ?? 0,
      totalGmvInr: (json['total_gmv_inr'] as num?)?.toDouble() ?? 0.0,
      platformRevenueInr: (json['platform_revenue_inr'] as num?)?.toDouble() ?? 0.0,
      matchSuccessRatePercent: (json['match_success_rate_percent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class VerificationQueueItemModel {
  final String id;
  final String entityType;
  final String entityName;
  final String ownerName;
  final String phone;
  final String? gstinOrCategory;
  final String verificationStatus;
  final String submittedAt;

  VerificationQueueItemModel({
    required this.id,
    required this.entityType,
    required this.entityName,
    required this.ownerName,
    required this.phone,
    this.gstinOrCategory,
    required this.verificationStatus,
    required this.submittedAt,
  });

  factory VerificationQueueItemModel.fromJson(Map<String, dynamic> json) {
    return VerificationQueueItemModel(
      id: json['id'] ?? '',
      entityType: json['entity_type'] ?? '',
      entityName: json['entity_name'] ?? '',
      ownerName: json['owner_name'] ?? '',
      phone: json['phone'] ?? '',
      gstinOrCategory: json['gstin_or_category'],
      verificationStatus: json['verification_status'] ?? 'PENDING',
      submittedAt: json['submitted_at'] ?? '',
    );
  }
}
