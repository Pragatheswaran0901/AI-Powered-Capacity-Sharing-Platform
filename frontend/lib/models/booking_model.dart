class BookingModel {
  final String id;
  final String requirementId;
  final String? requirementTitle;
  final String machineId;
  final String? machineName;
  final String seekerId;
  final String? seekerName;
  final String providerId;
  final String? providerName;
  final String? businessName;
  final String status;
  final String startDate;
  final String endDate;
  final double totalHours;
  final double unitPrice;
  final double totalAmount;
  final double commissionAmount;
  final double providerPayout;
  final String? notes;
  final String createdAt;
  final String? escrowStatus;
  final bool hasReview;

  BookingModel({
    required this.id,
    required this.requirementId,
    this.requirementTitle,
    required this.machineId,
    this.machineName,
    required this.seekerId,
    this.seekerName,
    required this.providerId,
    this.providerName,
    this.businessName,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.totalHours,
    required this.unitPrice,
    required this.totalAmount,
    required this.commissionAmount,
    required this.providerPayout,
    this.notes,
    required this.createdAt,
    this.escrowStatus,
    this.hasReview = false,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      requirementId: json['requirement_id'] ?? '',
      requirementTitle: json['requirement_title'],
      machineId: json['machine_id'] ?? '',
      machineName: json['machine_name'],
      seekerId: json['seeker_id'] ?? '',
      seekerName: json['seeker_name'],
      providerId: json['provider_id'] ?? '',
      providerName: json['provider_name'],
      businessName: json['business_name'],
      status: json['status'] ?? 'PENDING',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      totalHours: (json['total_hours'] as num?)?.toDouble() ?? 0.0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      commissionAmount: (json['commission_amount'] as num?)?.toDouble() ?? 0.0,
      providerPayout: (json['provider_payout'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'],
      createdAt: json['created_at'] ?? '',
      escrowStatus: json['escrow_status'],
      hasReview: json['has_review'] ?? false,
    );
  }

  bool get isPending => status == 'PENDING';
  bool get isAccepted => status == 'ACCEPTED';
  bool get isConfirmed => status == 'CONFIRMED';
  bool get isInProgress => status == 'IN_PROGRESS';
  bool get isCompleted => status == 'COMPLETED';
}
