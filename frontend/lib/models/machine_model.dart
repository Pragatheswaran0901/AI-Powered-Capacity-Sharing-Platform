class MachineCapabilityModel {
  final String id;
  final String process;
  final String material;
  final double? minToleranceMm;
  final double? maxDimX;
  final double? maxDimY;
  final double? maxDimZ;

  MachineCapabilityModel({
    required this.id,
    required this.process,
    required this.material,
    this.minToleranceMm,
    this.maxDimX,
    this.maxDimY,
    this.maxDimZ,
  });

  factory MachineCapabilityModel.fromJson(Map<String, dynamic> json) {
    return MachineCapabilityModel(
      id: json['id'] ?? '',
      process: json['process'] ?? '',
      material: json['material'] ?? '',
      minToleranceMm: (json['min_tolerance_mm'] as num?)?.toDouble(),
      maxDimX: (json['max_dimension_x'] as num?)?.toDouble(),
      maxDimY: (json['max_dimension_y'] as num?)?.toDouble(),
      maxDimZ: (json['max_dimension_z'] as num?)?.toDouble(),
    );
  }
}

class MachineAvailabilityModel {
  final String id;
  final String date;
  final String startTime;
  final String endTime;
  final bool isAvailable;
  final String? reason;

  MachineAvailabilityModel({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    this.reason,
  });

  factory MachineAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return MachineAvailabilityModel(
      id: json['id'] ?? '',
      date: json['date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      isAvailable: json['is_available'] ?? true,
      reason: json['reason'],
    );
  }
}

class MachineModel {
  final String id;
  final String businessId;
  final String? businessName;
  final String name;
  final String category;
  final String? manufacturer;
  final String? model;
  final int? year;
  final String? description;
  final String? dimensionsCapacity;
  final String? precisionTolerance;
  final double hourlyPrice;
  final double minJobValue;
  final bool operatorAvailable;
  final String locationAddress;
  final double latitude;
  final double longitude;
  final List<String> photos;
  final String status;
  final String verificationStatus;
  final List<MachineCapabilityModel> capabilities;
  final List<MachineAvailabilityModel> availabilities;
  final double averageRating;
  final int completedJobs;

  MachineModel({
    required this.id,
    required this.businessId,
    this.businessName,
    required this.name,
    required this.category,
    this.manufacturer,
    this.model,
    this.year,
    this.description,
    this.dimensionsCapacity,
    this.precisionTolerance,
    required this.hourlyPrice,
    this.minJobValue = 0.0,
    this.operatorAvailable = true,
    required this.locationAddress,
    required this.latitude,
    required this.longitude,
    this.photos = const [],
    this.status = 'ACTIVE',
    this.verificationStatus = 'PENDING',
    this.capabilities = const [],
    this.availabilities = const [],
    this.averageRating = 4.5,
    this.completedJobs = 0,
  });

  factory MachineModel.fromJson(Map<String, dynamic> json) {
    final capsList =
        (json['capabilities'] as List?)
            ?.map((e) => MachineCapabilityModel.fromJson(e))
            .toList() ??
        [];

    final availList =
        (json['availabilities'] as List?)
            ?.map((e) => MachineAvailabilityModel.fromJson(e))
            .toList() ??
        [];

    final photosList =
        (json['photos'] as List?)?.map((e) => e.toString()).toList() ?? [];

    return MachineModel(
      id: json['id'] ?? '',
      businessId: json['business_id'] ?? '',
      businessName: json['business_name'],
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      manufacturer: json['manufacturer'],
      model: json['model'],
      year: json['year'],
      description: json['description'],
      dimensionsCapacity: json['dimensions_capacity'],
      precisionTolerance: json['precision_tolerance'],
      hourlyPrice: (json['hourly_price'] as num?)?.toDouble() ?? 0.0,
      minJobValue: (json['min_job_value'] as num?)?.toDouble() ?? 0.0,
      operatorAvailable: json['operator_available'] ?? true,
      locationAddress: json['location_address'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 11.0168,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 76.9558,
      photos: photosList,
      status: json['status'] ?? 'ACTIVE',
      verificationStatus: json['verification_status'] ?? 'PENDING',
      capabilities: capsList,
      availabilities: availList,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 4.5,
      completedJobs: json['completed_jobs'] ?? 0,
    );
  }

  bool get isVerified => verificationStatus.toUpperCase() == 'VERIFIED';

  String get normalizedStatus {
    final upper = status.toUpperCase();
    if (upper == 'ACTIVE' || upper == 'AVAILABLE') return 'AVAILABLE';
    if (upper == 'INACTIVE' || upper == 'OFFLINE') return 'OFFLINE';
    if (upper == 'BUSY') return 'BUSY';
    if (upper == 'MAINTENANCE') return 'MAINTENANCE';
    return upper;
  }

  int? get utilizationPercentage {
    if (availabilities.isEmpty) return null;
    double totalLoad = 0.0;
    for (final slot in availabilities) {
      if (!slot.isAvailable) {
        totalLoad += 1.0;
      } else {
        final hours = _parseShiftHours(slot.startTime, slot.endTime);
        totalLoad += (hours / 18.0).clamp(0.2, 0.95);
      }
    }
    final pct = ((totalLoad / availabilities.length) * 100).round();
    return pct.clamp(0, 100);
  }

  static double _parseShiftHours(String start, String end) {
    try {
      final sParts = start.split(':');
      final eParts = end.split(':');
      if (sParts.length >= 2 && eParts.length >= 2) {
        final sHours = int.parse(sParts[0]) + (int.parse(sParts[1]) / 60.0);
        final eHours = int.parse(eParts[0]) + (int.parse(eParts[1]) / 60.0);
        if (eHours > sHours) {
          return eHours - sHours;
        }
      }
    } catch (_) {}
    return 9.0;
  }
}
