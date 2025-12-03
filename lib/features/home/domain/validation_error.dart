class ValidationError {
  final String field;
  final String message;

  ValidationError({required this.field, required this.message});

  factory ValidationError.fromJson(Map<String, dynamic> json) {
    return ValidationError(
      field: json['field'] ?? '',
      message: json['message'] ?? '',
    );
  }
}
