import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  ApiException({
    required this.message,
    this.statusCode,
    this.details,
  });

  factory ApiException.fromDioError(DioException error) {
    String message = 'An unexpected network error occurred.';
    int? statusCode = error.response?.statusCode;
    dynamic details;

    if (error.response?.data != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('detail')) {
          final detail = data['detail'];
          if (detail is String) {
            message = detail;
          } else if (detail is List && detail.isNotEmpty) {
            final first = detail[0];
            message = first['msg'] ?? message;
          }
        } else if (data.containsKey('message')) {
          message = data['message'];
        }
      }
      details = data;
    } else {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message = 'Network connection timed out. Please check your internet connection.';
          break;
        case DioExceptionType.connectionError:
          message = 'Unable to connect to Mach-Hunt servers. Ensure backend is running.';
          break;
        case DioExceptionType.badCertificate:
          message = 'Security certificate validation failed.';
          break;
        case DioExceptionType.cancel:
          message = 'Request was cancelled.';
          break;
        default:
          message = 'Failed to communicate with Mach-Hunt API.';
      }
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      details: details,
    );
  }

  @override
  String toString() => message;
}
