import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:machhunt/core/constants/api_endpoints.dart';
import 'package:machhunt/core/network/api_client.dart';
import 'package:machhunt/models/requirement_model.dart';
import 'package:machhunt/models/match_model.dart';
import 'package:machhunt/models/booking_model.dart';
import 'package:machhunt/models/machine_model.dart';

class SeekerState extends ChangeNotifier {
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

  List<RequirementModel> _myRequirements = [];
  RequirementModel? _activeRequirement;
  List<MatchResultModel> _currentMatches = [];
  List<MachineModel> _availableMachines = [];
  ComparisonMatrixModel? _comparisonMatrix;
  List<BookingModel> _myBookings = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedLocation = 'Coimbatore';
  List<String> _industries = [];
  String? _selectedIndustry;

  List<RequirementModel> get myRequirements => _myRequirements;
  RequirementModel? get activeRequirement => _activeRequirement;
  List<MatchResultModel> get currentMatches => _currentMatches;
  List<MachineModel> get availableMachines => _availableMachines;
  ComparisonMatrixModel? get comparisonMatrix => _comparisonMatrix;
  List<BookingModel> get myBookings => _myBookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedLocation => _selectedLocation;
  List<String> get industries => _industries;
  String? get selectedIndustry => _selectedIndustry;

  void clear() {
    _myRequirements = [];
    _activeRequirement = null;
    _currentMatches = [];
    _availableMachines = [];
    _comparisonMatrix = null;
    _myBookings = [];
    _isLoading = false;
    _errorMessage = null;
    _selectedIndustry = null;
    notifyListeners();
  }

  void setSelectedLocation(String location) {
    if (_selectedLocation != location) {
      _selectedLocation = location;
      notifyListeners();
    }
  }

  void setSelectedIndustry(String? industry) {
    if (_selectedIndustry != industry) {
      _selectedIndustry = industry;
      notifyListeners();
    }
  }

  void setActiveRequirement(RequirementModel? req) {
    _activeRequirement = req;
    notifyListeners();
  }

  Future<RequirementModel?> fetchRequirementDetail(String requirementId) async {
    try {
      final res = await apiClient.get(
        ApiEndpoints.requirementDetail(requirementId),
      );
      if (res is Map<String, dynamic>) {
        final req = RequirementModel.fromJson(res);
        // Only set as active requirement if it is owned by the current user
        if (_myRequirements.any((r) => r.id == req.id)) {
          _activeRequirement = req;
          notifyListeners();
        }
        return req;
      }
    } catch (_) {
      // Check in cached myRequirements
      for (final r in _myRequirements) {
        if (r.id == requirementId) {
          _activeRequirement = r;
          notifyListeners();
          return r;
        }
      }
    }
    return null;
  }

  Future<void> fetchMyRequirements() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.get(ApiEndpoints.myRequirements);
      if (res is List) {
        _myRequirements = res.map((e) => RequirementModel.fromJson(e)).toList();
        // Crucial: ensure _activeRequirement belongs to THIS authenticated user
        if (_activeRequirement == null ||
            !_myRequirements.any((r) => r.id == _activeRequirement!.id)) {
          _activeRequirement =
              _myRequirements.isNotEmpty ? _myRequirements.first : null;
        }
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchMyBookings() async {
    try {
      final res = await apiClient.get(ApiEndpoints.myBookings);
      if (res is List) {
        _myBookings = res.map((e) => BookingModel.fromJson(e)).toList();
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<InterpretedRequirementModel?> parsePrompt(String prompt) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await apiClient.post(
        ApiEndpoints.parseNl,
        data: {'prompt': prompt},
      );
      _isLoading = false;
      notifyListeners();
      return InterpretedRequirementModel.fromJson(res);
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<RequirementModel?> createRequirement(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.post(ApiEndpoints.requirements, data: data);
      final newReq = RequirementModel.fromJson(res);
      _activeRequirement = newReq;
      await fetchMyRequirements();
      _isLoading = false;
      notifyListeners();
      return newReq;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> fetchIndustries() async {
    try {
      final res = await apiClient.get(ApiEndpoints.industries);
      if (res is List) {
        _industries = res.map((e) => e.toString()).toList();
        notifyListeners();
      }
    } catch (_) {
      // Graceful fallback
    }
  }

  Future<void> fetchMatches(
    String requirementId, {
    String? location,
    String? industry,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final loc = location ?? _selectedLocation;
      final ind = industry ?? _selectedIndustry;
      final queryParams = <String>[];
      if (loc.isNotEmpty) {
        queryParams.add('location=${Uri.encodeComponent(loc)}');
      }
      if (ind != null && ind.isNotEmpty) {
        queryParams.add('industry=${Uri.encodeComponent(ind)}');
      }
      final queryString =
          queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final res = await apiClient.get(
        '${ApiEndpoints.requirementMatches(requirementId)}$queryString',
      );
      if (res is List) {
        _currentMatches = res.map((e) => MatchResultModel.fromJson(e)).toList();
      } else {
        _currentMatches = [];
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchAvailableMachines({
    String? location,
    String? industry,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final loc = location ?? _selectedLocation;
      final ind = industry ?? _selectedIndustry;
      final queryParams = <String>[];
      if (loc.isNotEmpty) {
        queryParams.add('location=${Uri.encodeComponent(loc)}');
      }
      if (ind != null && ind.isNotEmpty) {
        queryParams.add('industry=${Uri.encodeComponent(ind)}');
      }
      final queryString =
          queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final res = await apiClient.get('${ApiEndpoints.machines}$queryString');
      if (res is List) {
        _availableMachines = res.map((e) => MachineModel.fromJson(e)).toList();
      } else {
        _availableMachines = [];
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> compareMachines(
    String requirementId,
    List<String> machineIds,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await apiClient.post(
        ApiEndpoints.compareMachines,
        data: {'requirement_id': requirementId, 'machine_ids': machineIds},
      );
      _comparisonMatrix = ComparisonMatrixModel.fromJson(res);
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

  Future<bool> requestBooking({
    required String requirementId,
    required String machineId,
    required String startDate,
    required String endDate,
    required double totalHours,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await apiClient.post(
        ApiEndpoints.bookings,
        data: {
          'requirement_id': requirementId,
          'machine_id': machineId,
          'start_date': startDate,
          'end_date': endDate,
          'total_hours': totalHours,
          'notes': notes,
        },
      );
      await fetchMyBookings();
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

  Future<bool> confirmEscrow(String bookingId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await apiClient.post(ApiEndpoints.confirmBooking(bookingId));
      await fetchMyBookings();
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

  Future<bool> markCompleted(String bookingId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await apiClient.post(ApiEndpoints.completeJob(bookingId));
      await fetchMyBookings();
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

  Future<bool> submitReview({
    required String bookingId,
    required int rating,
    String? reviewText,
  }) async {
    try {
      await apiClient.post(
        ApiEndpoints.reviews,
        data: {
          'booking_id': bookingId,
          'rating': rating,
          'review_text': reviewText,
        },
      );
      await fetchMyBookings();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}

final seekerState = SeekerState();
