import 'package:flutter/material.dart';
import 'package:machhunt/core/constants/api_endpoints.dart';
import 'package:machhunt/core/network/api_client.dart';
import 'package:machhunt/models/requirement_model.dart';
import 'package:machhunt/models/match_model.dart';
import 'package:machhunt/models/booking_model.dart';

class SeekerState extends ChangeNotifier {
  List<RequirementModel> _myRequirements = [];
  List<MatchResultModel> _currentMatches = [];
  ComparisonMatrixModel? _comparisonMatrix;
  List<BookingModel> _myBookings = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<RequirementModel> get myRequirements => _myRequirements;
  List<MatchResultModel> get currentMatches => _currentMatches;
  ComparisonMatrixModel? get comparisonMatrix => _comparisonMatrix;
  List<BookingModel> get myBookings => _myBookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMyRequirements() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.get(ApiEndpoints.myRequirements);
      if (res is List) {
        _myRequirements = res.map((e) => RequirementModel.fromJson(e)).toList();
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

  Future<void> fetchMatches(String requirementId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.get(ApiEndpoints.requirementMatches(requirementId));
      if (res is List) {
        _currentMatches = res.map((e) => MatchResultModel.fromJson(e)).toList();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> compareMachines(String requirementId, List<String> machineIds) async {
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
