String formatSessionSeconds(int seconds) {
  final clamped = seconds < 0 ? 0 : seconds;
  final minutes = clamped ~/ 60;
  final remaining = clamped % 60;
  return '${minutes.toString().padLeft(2, '0')}:'
      '${remaining.toString().padLeft(2, '0')}';
}
