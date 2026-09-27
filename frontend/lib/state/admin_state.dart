import 'package:flutter/material.dart';
import 'package:machhunt/core/constants/api_endpoints.dart';
import 'package:machhunt/core/network/api_client.dart';
import 'package:machhunt/models/admin_metrics_model.dart';

class AdminState extends ChangeNotifier {
  AdminMetricsModel? _metrics;
  List<VerificationQueueItemModel> _queue = [];
  bool _isLoading = false;
  String? _errorMessage;

  AdminMetricsModel? get metrics => _metrics;
  List<VerificationQueueItemModel> get queue => _queue;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMetrics() async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await apiClient.get(ApiEndpoints.adminMetrics);
      _metrics = AdminMetricsModel.fromJson(res);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchQueue() async {
    try {
      final res = await apiClient.get(ApiEndpoints.adminVerifications);
      if (res is List) {
        _queue = res.map((e) => VerificationQueueItemModel.fromJson(e)).toList();
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> verifyBusiness(String id, String status, {String? remarks}) async {
    try {
      await apiClient.post(
        ApiEndpoints.verifyBusiness(id),
        data: {'status': status, 'remarks': remarks},
      );
      await fetchQueue();
      await fetchMetrics();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyMachine(String id, String status, {String? remarks}) async {
    try {
      await apiClient.post(
        ApiEndpoints.verifyMachine(id),
        data: {'status': status, 'remarks': remarks},
      );
      await fetchQueue();
      await fetchMetrics();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}

final adminState = AdminState();
