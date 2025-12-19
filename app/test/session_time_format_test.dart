import 'package:flutter_test/flutter_test.dart';
import 'package:speed_of_play/ui/session/time_format.dart';

void main() {
  test('formatSessionSeconds returns mm:ss for edge cases', () {
    expect(formatSessionSeconds(0), '00:00');
    expect(formatSessionSeconds(5), '00:05');
    expect(formatSessionSeconds(65), '01:05');
    expect(formatSessionSeconds(600), '10:00');
  });
}
