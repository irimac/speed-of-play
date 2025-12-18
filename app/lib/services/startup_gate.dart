/// Waits for both initialization to complete and a minimum duration to elapse.
/// Intentionally not user-configurable; keeps the launch screen visible long
/// enough on fast devices while still waiting for real initialization work.
Future<T> startupGate<T>(Future<T> initFuture, Duration minDuration) async {
  final results = await Future.wait<dynamic>([
    initFuture,
    Future.delayed(minDuration),
  ]);
  return results.first as T;
}
