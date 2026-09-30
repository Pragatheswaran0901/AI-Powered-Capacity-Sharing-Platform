class ApiEndpoints {
  // Configurable via --dart-define=API_BASE_URL=...
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );

  // Auth Mode: 'demo' (Password Authentication) or 'otp' (Email OTP)
  static const String authMode = String.fromEnvironment(
    'AUTH_MODE',
    defaultValue: 'demo',
  );

  static bool get isDemoMode => authMode == 'demo';
  static bool get isOtpMode => authMode == 'otp';

  // Auth & Passwordless Email OTP
  static const String requestOtp = '/auth/request-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String onboarding = '/auth/onboarding';
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';

  // Users
  static const String profile = '/users/profile';

  // Businesses
  static const String businesses = '/businesses';
  static const String myBusiness = '/businesses/me';

  // Companies & Industries (49 Master Industrial Locations)
  static const String companies = '/companies';
  static String companyDetail(String id) => '/companies/$id';
  static const String industries = '/industries';

  // Machines
  static const String machines = '/machines';
  static const String myMachines = '/machines/my';
  static String machineDetail(String id) => '/machines/$id';
  static String machineAvailability(String id) => '/machines/$id/availability';

  // Requirements & AI
  static const String requirements = '/requirements';
  static const String myRequirements = '/requirements/my';
  static const String parseNl = '/requirements/parse-nl';
  static String requirementDetail(String id) => '/requirements/$id';

  // Matching & Comparison
  static String requirementMatches(String id) => '/matches/requirement/$id';
  static const String compareMachines = '/matches/compare';

  // Bookings
  static const String bookings = '/bookings';
  static const String myBookings = '/bookings/my';
  static String bookingDetail(String id) => '/bookings/$id';
  static String acceptBooking(String id) => '/bookings/$id/accept';
  static String rejectBooking(String id) => '/bookings/$id/reject';
  static String confirmBooking(String id) => '/bookings/$id/confirm';
  static String startProduction(String id) => '/bookings/$id/start';
  static String completeJob(String id) => '/bookings/$id/complete';
  static String cancelBooking(String id) => '/bookings/$id/cancel';

  // Payments & Reviews
  static String bookingPayment(String id) => '/payments/booking/$id';
  static const String reviews = '/reviews';
  static String businessReviews(String id) => '/reviews/business/$id';

  // Notifications
  static const String notifications = '/notifications';
  static String markNotificationRead(String id) => '/notifications/$id/read';
  static const String readAllNotifications = '/notifications/read-all';

  // Admin
  static const String adminMetrics = '/admin/metrics';
  static const String adminVerifications = '/admin/verifications';
  static String verifyBusiness(String id) => '/admin/businesses/$id/verify';
  static String verifyMachine(String id) => '/admin/machines/$id/verify';
  static const String auditLogs = '/admin/audit-logs';
}
