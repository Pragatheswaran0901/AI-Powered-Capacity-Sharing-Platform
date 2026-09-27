import 'package:flutter/foundation.dart';
import 'package:machhunt/core/constants/api_endpoints.dart';
import 'package:machhunt/core/network/api_client.dart';
import 'package:machhunt/core/network/api_exception.dart';
import 'package:machhunt/core/storage/token_storage.dart';
import 'package:machhunt/models/user_model.dart';
import 'package:machhunt/models/business_model.dart';

class AuthState extends ChangeNotifier {
  UserModel? _currentUser;
  BusinessModel? _currentBusiness;
  bool _isLoading = false;
  String? _errorMessage;
  String? _pendingEmail;
  int _otpExpiresIn = 300;

  UserModel? get currentUser => _currentUser;
  BusinessModel? get currentBusiness => _currentBusiness;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get pendingEmail => _pendingEmail;
  int get otpExpiresIn => _otpExpiresIn;
  bool get isAuthenticated => _currentUser != null;

  bool get isProvider => _currentUser?.isProvider ?? false;
  bool get isSeeker => _currentUser?.isSeeker ?? false;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isOnboarded => _currentUser?.isOnboarded ?? true;

  void setPendingEmail(String email) {
    _pendingEmail = email.trim().toLowerCase();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> switchRole(String newRole) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(role: newRole);
      await tokenStorage.setUserRole(newRole);
      notifyListeners();
    }
  }

  Future<bool> checkAuthSession() async {
    final hasToken = await tokenStorage.hasValidToken();
    if (!hasToken) {
      _currentUser = null;
      _currentBusiness = null;
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final res = await apiClient.get(ApiEndpoints.me);
      _currentUser = UserModel.fromJson(res);

      await fetchMyBusiness();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _currentUser = null;
      _currentBusiness = null;
      await tokenStorage.clear();
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchMyBusiness() async {
    try {
      final res = await apiClient.get(ApiEndpoints.myBusiness);
      if (res != null) {
        _currentBusiness = BusinessModel.fromJson(res);
        if (_currentBusiness != null) {
          await tokenStorage.setBusinessId(_currentBusiness!.id);
        }
      }
    } catch (_) {
      _currentBusiness = null;
    }
  }

  /// Request 6-digit passwordless OTP for email
  Future<bool> requestOtp(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final normEmail = email.trim().toLowerCase();

    try {
      final res = await apiClient.post(
        ApiEndpoints.requestOtp,
        data: {'email': normEmail},
      );

      _pendingEmail = normEmail;
      _otpExpiresIn = res['expires_in'] ?? 300;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _parseErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// Resend 6-digit verification code
  Future<bool> resendOtp(String email) async {
    return requestOtp(email);
  }

  /// Verify 6-digit OTP and store JWT session
  Future<bool> verifyOtp(String email, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final normEmail = email.trim().toLowerCase();
    final cleanOtp = otp.trim();

    try {
      final res = await apiClient.post(
        ApiEndpoints.verifyOtp,
        data: {'email': normEmail, 'otp': cleanOtp},
      );

      final userJson = res['user'];
      final userModel = UserModel.fromJson(userJson);

      await tokenStorage.saveTokens(
        accessToken: res['access_token'],
        refreshToken: res['refresh_token'],
        userId: userModel.id,
        role: userModel.role,
        fullName: userModel.fullName,
        businessId: userModel.businessId,
        isOnboarded: userModel.isOnboarded,
      );

      _currentUser = userModel;
      await fetchMyBusiness();

      _isLoading = false;
      _pendingEmail = null;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _parseErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// Progressive Onboarding for newly registered MSMEs
  Future<bool> completeOnboarding({
    required String role,
    required String fullName,
    required String phone,
    required String businessName,
    required String industry,
    required String district,
    String state = "Tamil Nadu",
    required String pincode,
    required String address,
    String? description,
    String? gstin,
    List<String>? machineCategories,
    List<String>? primaryProcesses,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.post(
        ApiEndpoints.onboarding,
        data: {
          'role': role,
          'full_name': fullName,
          'phone': phone,
          'business_name': businessName,
          'industry': industry,
          'district': district,
          'state': state,
          'pincode': pincode,
          'address': address,
          'description': description,
          'gstin': gstin,
          'machine_categories': machineCategories,
          'primary_processes': primaryProcesses,
        },
      );

      final userJson = res['user'];
      final userModel = UserModel.fromJson(userJson);

      await tokenStorage.saveTokens(
        accessToken: res['access_token'],
        refreshToken: res['refresh_token'],
        userId: userModel.id,
        role: userModel.role,
        fullName: userModel.fullName,
        businessId: userModel.businessId,
        isOnboarded: true,
      );

      _currentUser = userModel;
      await fetchMyBusiness();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _parseErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// Legacy Password Authentication (for Seeded Demo Accounts)
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.post(
        ApiEndpoints.login,
        data: {'email': email.trim().toLowerCase(), 'password': password},
      );

      await tokenStorage.saveTokens(
        accessToken: res['access_token'],
        refreshToken: res['refresh_token'],
        userId: res['user_id'],
        role: res['role'],
        fullName: res['full_name'],
        businessId: res['business_id'],
        isOnboarded: res['is_onboarded'] ?? true,
      );

      try {
        final meRes = await apiClient.get(ApiEndpoints.me);
        _currentUser = UserModel.fromJson(meRes);
        await fetchMyBusiness();
      } catch (_) {
        _currentUser = UserModel(
          id: res['user_id'] ?? '',
          email: email.trim().toLowerCase(),
          fullName: res['full_name'] ?? '',
          phone: '',
          role: res['role'] ?? 'PROVIDER',
          isOnboarded: res['is_onboarded'] ?? true,
          businessId: res['business_id'],
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _parseErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// Direct Registration
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.post(
        ApiEndpoints.register,
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
          'full_name': fullName,
          'phone': phone,
          'role': role,
        },
      );

      await tokenStorage.saveTokens(
        accessToken: res['access_token'],
        refreshToken: res['refresh_token'],
        userId: res['user_id'],
        role: res['role'],
        fullName: res['full_name'],
        isOnboarded: true,
      );

      final meRes = await apiClient.get(ApiEndpoints.me);
      _currentUser = UserModel.fromJson(meRes);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _parseErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await apiClient.post(ApiEndpoints.logout);
    } catch (_) {}
    await tokenStorage.clear();
    _currentUser = null;
    _currentBusiness = null;
    _pendingEmail = null;
    notifyListeners();
  }

  String _parseErrorMessage(dynamic error) {
    if (error == null) return "An unexpected error occurred. Please try again.";

    debugPrint('[AUTH ERROR] Type: ${error.runtimeType}, Details: $error');

    if (error is ApiException) {
      final msg = error.message;
      final status = error.statusCode;

      // 401 Unauthorized: Invalid credentials
      if (status == 401 || msg.toLowerCase().contains("invalid email or password")) {
        return "Invalid email or password.";
      }

      // 422 Unprocessable Entity / Malformed email
      if (status == 422 || msg.toLowerCase().contains("valid email")) {
        return "Please enter a valid email address.";
      }

      // Connection / Network failure
      if (status == null ||
          msg.toLowerCase().contains("unable to connect") ||
          msg.toLowerCase().contains("failed to communicate") ||
          msg.toLowerCase().contains("network error") ||
          msg.toLowerCase().contains("connection refused")) {
        return "Unable to connect to Mach-Hunt. Please check that the backend is running.";
      }

      return msg;
    }

    final str = error.toString();
    if (str.toLowerCase().contains("connection refused") ||
        str.toLowerCase().contains("network error") ||
        str.toLowerCase().contains("socketexception")) {
      return "Unable to connect to Mach-Hunt. Please check that the backend is running.";
    }

    if (str.toLowerCase().contains("invalid email or password")) {
      return "Invalid email or password.";
    }

    if (str.contains("value is not a valid email address")) {
      return "Please enter a valid email address.";
    }

    return "An unexpected error occurred. Please try again.";
  }
}

final authState = AuthState();
