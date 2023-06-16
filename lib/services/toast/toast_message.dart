enum ToastType { info, error }

class ToastMessage {
  final ToastType type;
  final String text;
  final Duration duration;

  ToastMessage({
    required this.type,
    required this.text,
    this.duration = const Duration(seconds: 2),
  });
}
