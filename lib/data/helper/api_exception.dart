// ============================================================
// api_exception.dart
// Custom exception untuk semua error dari API call.
// Dipisah dari api_helper.dart agar bisa diimport sendiri
// tanpa circular dependency.
// ============================================================

class ApiException implements Exception {
  final String message;
  final int statusCode;

  const ApiException({required this.message, required this.statusCode});

  @override
  String toString() => 'ApiException ($statusCode): $message';
}