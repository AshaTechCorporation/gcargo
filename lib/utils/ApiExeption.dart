class ApiException implements Exception {
  const ApiException([this.message]);

  final String? message;

  @override
  String toString() {
    Object? message = this.message;
    if (message == null) return "ApiException";
    return "$message";
  }
}
