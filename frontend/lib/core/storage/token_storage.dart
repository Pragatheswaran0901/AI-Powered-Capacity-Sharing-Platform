import 'package:flutter/foundation.dart';
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

    if (!kIsWeb) {
      try {
        await _secureStorage.write(key: _keyAccessToken, value: accessToken);
        await _secureStorage.write(key: _keyRefreshToken, value: refreshToken);
        await _secureStorage.write(key: _keyUserId, value: userId);
        await _secureStorage.write(key: _keyUserRole, value: role);
        await _secureStorage.write(key: _keyFullName, value: fullName);
        await _secureStorage.write(
          key: _keyIsOnboarded,
          value: isOnboarded.toString(),
        );
        if (businessId != null) {
          await _secureStorage.write(key: _keyBusinessId, value: businessId);
        } else {
          await _secureStorage.delete(key: _keyBusinessId);
        }
      } catch (_) {}
    }
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final prefToken = prefs.getString(_keyAccessToken);
    if (prefToken != null && prefToken.isNotEmpty) return prefToken;

    if (!kIsWeb) {
      try {
        final token = await _secureStorage.read(key: _keyAccessToken);
        if (token != null) return token;
      } catch (_) {}
    }
    return null;
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final prefToken = prefs.getString(_keyRefreshToken);
    if (prefToken != null && prefToken.isNotEmpty) return prefToken;
    if (!kIsWeb) {
      try {
        final token = await _secureStorage.read(key: _keyRefreshToken);
        if (token != null) return token;
      } catch (_) {}
    }
    return null;
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final prefId = prefs.getString(_keyUserId);
    if (prefId != null && prefId.isNotEmpty) return prefId;
    if (!kIsWeb) {
      try {
        final id = await _secureStorage.read(key: _keyUserId);
        if (id != null) return id;
      } catch (_) {}
    }
    return null;
  }

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final prefRole = prefs.getString(_keyUserRole);
    if (prefRole != null && prefRole.isNotEmpty) return prefRole;
    if (!kIsWeb) {
      try {
        final role = await _secureStorage.read(key: _keyUserRole);
        if (role != null) return role;
      } catch (_) {}
    }
    return null;
  }

  Future<void> setUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserRole, role);
    if (!kIsWeb) {
      try {
        await _secureStorage.write(key: _keyUserRole, value: role);
      } catch (_) {}
    }
  }

  Future<String?> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    final prefName = prefs.getString(_keyFullName);
    if (prefName != null && prefName.isNotEmpty) return prefName;
    if (!kIsWeb) {
      try {
        final name = await _secureStorage.read(key: _keyFullName);
        if (name != null) return name;
      } catch (_) {}
    }
    return null;
  }

  Future<bool> getIsOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    final prefVal = prefs.getBool(_keyIsOnboarded);
    if (prefVal != null) return prefVal;
    if (!kIsWeb) {
      try {
        final val = await _secureStorage.read(key: _keyIsOnboarded);
        if (val != null) return val == 'true';
      } catch (_) {}
    }
    return true;
  }

  Future<void> setIsOnboarded(bool isOnboarded) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsOnboarded, isOnboarded);
    if (!kIsWeb) {
      try {
        await _secureStorage.write(
          key: _keyIsOnboarded,
          value: isOnboarded.toString(),
        );
      } catch (_) {}
    }
  }

  Future<String?> getBusinessId() async {
    final prefs = await SharedPreferences.getInstance();
    final prefBid = prefs.getString(_keyBusinessId);
    if (prefBid != null && prefBid.isNotEmpty) return prefBid;
    if (!kIsWeb) {
      try {
        final bid = await _secureStorage.read(key: _keyBusinessId);
        if (bid != null) return bid;
      } catch (_) {}
    }
    return null;
  }

  Future<void> setBusinessId(String businessId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBusinessId, businessId);
    if (!kIsWeb) {
      try {
        await _secureStorage.write(key: _keyBusinessId, value: businessId);
      } catch (_) {}
    }
  }

  Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserRole);
    await prefs.remove(_keyFullName);
    await prefs.remove(_keyBusinessId);
    await prefs.remove(_keyIsOnboarded);
    if (!kIsWeb) {
      try {
        await _secureStorage.deleteAll();
      } catch (_) {}
    }
  }
}

final tokenStorage = TokenStorage();
