class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final String role; // PROVIDER, SEEKER, ADMIN
  final bool isActive;
  final bool isVerified;
  final bool emailVerified;
  final bool isOnboarded;
  final String authenticationProvider;
  final String? businessId;
  final String? businessName;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.role,
    this.isActive = true,
    this.isVerified = false,
    this.emailVerified = false,
    this.isOnboarded = true,
    this.authenticationProvider = 'email_otp',
    this.businessId,
    this.businessName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? json['name'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'SEEKER',
      isActive: json['is_active'] ?? true,
      isVerified: json['is_verified'] ?? false,
      emailVerified: json['email_verified'] ?? false,
      isOnboarded:
          json['is_onboarded'] ??
          (json['role'] == 'ADMIN' || json['business_id'] != null),
      authenticationProvider: json['authentication_provider'] ?? 'email_otp',
      businessId: json['business_id'],
      businessName: json['business_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'role': role,
      'is_active': isActive,
      'is_verified': isVerified,
      'email_verified': emailVerified,
      'is_onboarded': isOnboarded,
      'authentication_provider': authenticationProvider,
      'business_id': businessId,
      'business_name': businessName,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? role,
    bool? isActive,
    bool? isVerified,
    bool? emailVerified,
    bool? isOnboarded,
    String? authenticationProvider,
    String? businessId,
    String? businessName,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      emailVerified: emailVerified ?? this.emailVerified,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      authenticationProvider:
          authenticationProvider ?? this.authenticationProvider,
      businessId: businessId ?? this.businessId,
      businessName: businessName ?? this.businessName,
    );
  }

  bool get isProvider => role == 'PROVIDER';
  bool get isSeeker => role == 'SEEKER';
  bool get isAdmin => role == 'ADMIN';
}
