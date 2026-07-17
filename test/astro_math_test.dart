import 'package:flutter_test/flutter_test.dart';
import 'package:astrobot/services/astro_math.dart';

void main() {
  test('angularDistance uses the shortest wrap-around angle', () {
    expect(angularDistance(359, 1), closeTo(2, 1e-9));
    expect(angularDistance(1, 359), closeTo(2, 1e-9));
    expect(angularDistance(16.43, 243.81), closeTo(132.62, 1e-9));
  });
}
