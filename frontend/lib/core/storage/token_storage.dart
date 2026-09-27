import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _keyAccessToken = 'machhunt_access_token';
  static const String _keyRefreshToken = 'machhunt_refresh_token';
  static const String _keyUserId = 'machhunt_user_id';
  static const String _keyUserRole = 'machhunt_user_role';
  static const String _keyFullName = 'machhunt_full_name';
  static const String _keyBusinessId = 'machhunt_business_id';
  static const String _keyIsOnboarded = 'machhunt_is_onboarded';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String role,
    required String fullName,
    String? businessId,
    bool isOnboarded = true,
  }) async {
    try {
      await _secureStorage.write(key: _keyAccessToken, value: accessToken);
      await _secureStorage.write(key: _keyRefreshToken, value: refreshToken);
      await _secureStorage.write(key: _keyUserId, value: userId);
      await _secureStorage.write(key: _keyUserRole, value: role);
      await _secureStorage.write(key: _keyFullName, value: fullName);
      await _secureStorage.write(key: _keyIsOnboarded, value: isOnboarded.toString());
      if (businessId != null) {
        await _secureStorage.write(key: _keyBusinessId, value: businessId);
      } else {
        await _secureStorage.delete(key: _keyBusinessId);
      }
    } catch (_) {
      // Safe fallback for environments where secure storage is restricted
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAccessToken, accessToken);
      await prefs.setString(_keyRefreshToken, refreshToken);
      await prefs.setString(_keyUserId, userId);
      await prefs.setString(_keyUserRole, role);
      await prefs.setString(_keyFullName, fullName);
      await prefs.setBool(_keyIsOnboarded, isOnboarded);
      if (businessId != null) {
        await prefs.setString(_keyBusinessId, businessId);
      } else {
        await prefs.remove(_keyBusinessId);
      }
    }
  }

  Future<String?> getAccessToken() async {
    try {
      final token = await _secureStorage.read(key: _keyAccessToken);
      if (token != null) return token;
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    try {
      final token = await _secureStorage.read(key: _keyRefreshToken);
      if (token != null) return token;
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  Future<String?> getUserId() async {
    try {
      final id = await _secureStorage.read(key: _keyUserId);
      if (id != null) return id;
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  Future<String?> getUserRole() async {
    try {
      final role = await _secureStorage.read(key: _keyUserRole);
      if (role != null) return role;
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserRole);
  }

  Future<void> setUserRole(String role) async {
    try {
      await _secureStorage.write(key: _keyUserRole, value: role);
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserRole, role);
  }

  Future<String?> getFullName() async {
    try {
      final name = await _secureStorage.read(key: _keyFullName);
      if (name != null) return name;
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFullName);
  }

  Future<bool> getIsOnboarded() async {
    try {
      final val = await _secureStorage.read(key: _keyIsOnboarded);
      if (val != null) return val == 'true';
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsOnboarded) ?? true;
  }

  Future<void> setIsOnboarded(bool isOnboarded) async {
    try {
      await _secureStorage.write(key: _keyIsOnboarded, value: isOnboarded.toString());
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsOnboarded, isOnboarded);
  }

  Future<String?> getBusinessId() async {
    try {
      final bid = await _secureStorage.read(key: _keyBusinessId);
      if (bid != null) return bid;
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBusinessId);
  }

  Future<void> setBusinessId(String businessId) async {
    try {
      await _secureStorage.write(key: _keyBusinessId, value: businessId);
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBusinessId, businessId);
  }

  Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clear() async {
    try {
      await _secureStorage.deleteAll();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserRole);
    await prefs.remove(_keyFullName);
    await prefs.remove(_keyBusinessId);
    await prefs.remove(_keyIsOnboarded);
  }
}

final tokenStorage = TokenStorage();
