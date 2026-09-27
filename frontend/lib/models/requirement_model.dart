class RequirementModel {
  final String id;
  final String seekerId;
  final String? seekerName;
  final String title;
  final String description;
  final String process;
  final String material;
  final int quantity;
  final String? dimensions;
  final double? toleranceMm;
  final String requiredDate;
  final String deliveryDeadline;
  final String preferredLocation;
  final double? latitude;
  final double? longitude;
  final double maxDistanceKm;
  final double budget;
  final String? qualityRequirements;
  final bool operatorRequired;
  final String status;
  final int matchedCount;

  RequirementModel({
    required this.id,
    required this.seekerId,
    this.seekerName,
    required this.title,
    required this.description,
    required this.process,
    required this.material,
    required this.quantity,
    this.dimensions,
    this.toleranceMm,
    required this.requiredDate,
    required this.deliveryDeadline,
    required this.preferredLocation,
    this.latitude,
    this.longitude,
    this.maxDistanceKm = 100.0,
    required this.budget,
    this.qualityRequirements,
    this.operatorRequired = true,
    this.status = 'OPEN',
    this.matchedCount = 0,
  });

  factory RequirementModel.fromJson(Map<String, dynamic> json) {
    return RequirementModel(
      id: json['id'] ?? '',
      seekerId: json['seeker_id'] ?? '',
      seekerName: json['seeker_name'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      process: json['process'] ?? '',
      material: json['material'] ?? '',
      quantity: json['quantity'] ?? 1,
      dimensions: json['dimensions'],
      toleranceMm: (json['tolerance_mm'] as num?)?.toDouble(),
      requiredDate: json['required_date'] ?? '',
      deliveryDeadline: json['delivery_deadline'] ?? '',
      preferredLocation: json['preferred_location'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      maxDistanceKm: (json['max_distance_km'] as num?)?.toDouble() ?? 100.0,
      budget: (json['budget'] as num?)?.toDouble() ?? 0.0,
      qualityRequirements: json['quality_requirements'],
      operatorRequired: json['operator_required'] ?? true,
      status: json['status'] ?? 'OPEN',
      matchedCount: json['matched_count'] ?? 0,
    );
  }
}

class InterpretedRequirementModel {
  final String title;
  final String process;
  final String material;
  final int quantity;
  final String? dimensions;
  final double? toleranceMm;
  final int deadlineDays;
  final String preferredLocation;
  final double estimatedBudget;
  final double confidenceScore;

  InterpretedRequirementModel({
    required this.title,
    required this.process,
    required this.material,
    required this.quantity,
    this.dimensions,
    this.toleranceMm,
    required this.deadlineDays,
    required this.preferredLocation,
    required this.estimatedBudget,
    this.confidenceScore = 0.94,
  });

  factory InterpretedRequirementModel.fromJson(Map<String, dynamic> json) {
    return InterpretedRequirementModel(
      title: json['title'] ?? '',
      process: json['process'] ?? '',
      material: json['material'] ?? '',
      quantity: json['quantity'] ?? 100,
      dimensions: json['dimensions'],
      toleranceMm: (json['tolerance_mm'] as num?)?.toDouble(),
      deadlineDays: json['deadline_days'] ?? 5,
      preferredLocation: json['preferred_location'] ?? 'Coimbatore',
      estimatedBudget: (json['estimated_budget'] as num?)?.toDouble() ?? 25000.0,
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.94,
    );
  }
}
