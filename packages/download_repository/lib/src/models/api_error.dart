class ApiError implements Exception {
  ApiError({required this.message});

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['message'] as String,
    );
  }

  final String message;
}
