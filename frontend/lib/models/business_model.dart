class BusinessModel {
  final String id;
  final String userId;
  final String name;
  final String ownerName;
  final String phone;
  final String email;
  final String? gstin;
  final String? registrationNumber;
  final String industry;
  final String address;
  final String district;
  final String state;
  final String pincode;
  final double latitude;
  final double longitude;
  final String? description;
  final String verificationStatus; // PENDING, VERIFIED, REJECTED

  BusinessModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.ownerName,
    required this.phone,
    required this.email,
    this.gstin,
    this.registrationNumber,
    required this.industry,
    required this.address,
    required this.district,
    this.state = 'Tamil Nadu',
    required this.pincode,
    required this.latitude,
    required this.longitude,
    this.description,
    this.verificationStatus = 'PENDING',
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      ownerName: json['owner_name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      gstin: json['gstin'],
      registrationNumber: json['registration_number'],
      industry: json['industry'] ?? '',
      address: json['address'] ?? '',
      district: json['district'] ?? '',
      state: json['state'] ?? 'Tamil Nadu',
      pincode: json['pincode'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 11.0168,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 76.9558,
      description: json['description'],
      verificationStatus: json['verification_status'] ?? 'PENDING',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'owner_name': ownerName,
      'phone': phone,
      'email': email,
      'gstin': gstin,
      'registration_number': registrationNumber,
      'industry': industry,
      'address': address,
      'district': district,
      'state': state,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'verification_status': verificationStatus,
    };
  }

  bool get isVerified => verificationStatus == 'VERIFIED';
}
