import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:machhunt/core/constants/api_endpoints.dart';
import 'package:machhunt/core/network/api_client.dart';
import 'package:machhunt/models/machine_model.dart';
import 'package:machhunt/models/booking_model.dart';

class ProviderState extends ChangeNotifier {
  @override
  void notifyListeners() {
    if (WidgetsBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        super.notifyListeners();
      });
    } else {
      super.notifyListeners();
    }
  }

  List<MachineModel> _myMachines = [];
  List<BookingModel> _incomingRequests = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MachineModel> get myMachines => _myMachines;
  List<BookingModel> get incomingRequests => _incomingRequests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clear() {
    _myMachines = [];
    _incomingRequests = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  double get totalEarnings {
    double total = 0.0;
    for (var b in _incomingRequests) {
      if (b.status == 'COMPLETED' ||
          b.status == 'CONFIRMED' ||
          b.status == 'IN_PROGRESS') {
        total += b.providerPayout;
      }
    }
    return total;
  }

  int get activeJobCount {
    return _incomingRequests
        .where((b) => b.status == 'IN_PROGRESS' || b.status == 'CONFIRMED')
        .length;
  }

  Future<void> fetchMyMachines() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.get(ApiEndpoints.myMachines);
      if (res is List) {
        _myMachines = res.map((e) => MachineModel.fromJson(e)).toList();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchIncomingRequests() async {
    try {
      final res = await apiClient.get(ApiEndpoints.myBookings);
      if (res is List) {
        _incomingRequests = res.map((e) => BookingModel.fromJson(e)).toList();
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addMachine({
    required String name,
    required String category,
    String? manufacturer,
    String? model,
    int? year,
    String? description,
    String? dimensionsCapacity,
    String? precisionTolerance,
    required double hourlyPrice,
    double minJobValue = 0.0,
    bool operatorAvailable = true,
    required String locationAddress,
    required double latitude,
    required double longitude,
    List<String> photos = const [],
    List<Map<String, dynamic>> capabilities = const [],
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final payload = {
        'name': name,
        'category': category,
        'manufacturer': manufacturer,
        'model': model,
        'year': year,
        'description': description,
        'dimensions_capacity': dimensionsCapacity,
        'precision_tolerance': precisionTolerance,
        'hourly_price': hourlyPrice,
        'min_job_value': minJobValue,
        'operator_available': operatorAvailable,
        'location_address': locationAddress,
        'latitude': latitude,
        'longitude': longitude,
        'photos': photos,
        'capabilities': capabilities,
      };

      await apiClient.post(ApiEndpoints.machines, data: payload);
      await fetchMyMachines();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMachine(
    String machineId,
    Map<String, dynamic> updateData,
  ) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await apiClient.put(
        ApiEndpoints.machineDetail(machineId),
        data: updateData,
      );
      await fetchMyMachines();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> setAvailability(
    String machineId,
    List<Map<String, dynamic>> slots,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      await apiClient.post(
        ApiEndpoints.machineAvailability(machineId),
        data: {'slots': slots},
      );
      await fetchMyMachines();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> acceptRequest(String bookingId) async {
    try {
      await apiClient.post(ApiEndpoints.acceptBooking(bookingId));
      await fetchIncomingRequests();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectRequest(String bookingId, {String? reason}) async {
    try {
      await apiClient.post(
        ApiEndpoints.rejectBooking(bookingId),
        data: {'reason': reason},
      );
      await fetchIncomingRequests();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> startProduction(String bookingId) async {
    try {
      await apiClient.post(ApiEndpoints.startProduction(bookingId));
      await fetchIncomingRequests();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}

final providerState = ProviderState();
