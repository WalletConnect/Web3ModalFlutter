class LaunchUrlException {
  final String message;

  LaunchUrlException(this.message);

  @override
  String toString() {
    return 'LaunchUrlException{message: $message}';
  }
}
