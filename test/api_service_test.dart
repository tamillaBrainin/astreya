import 'package:astrobot/services/api_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TransitResponse strips fallback Claude note from interpretation', () {
    final response = TransitResponse.fromJson({
      'transits': [
        {
          'transitPlanet': 'Moon',
          'transitSign': 'Aries',
          'transitHouse': 8,
          'natalPlanet': 'Mercury',
          'aspect': 'Trine',
          'orb': 0.8,
        },
      ],
      'interpretation': '''
Structured transit summary.

*Note: This interpretation was generated using structural templates. For deeper insights, please ensure your Claude API key is properly configured.
''',
    });

    expect(response.interpretation, contains('Structured transit summary.'));
    expect(response.interpretation, isNot(contains('Claude API key')));
    expect(response.interpretation, isNot(contains('structural templates')));
  });
}