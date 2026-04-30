import 'dart:convert';
import 'package:test/test.dart';
import 'lib/constants/colors.dart';
import 'lib/models/event_log.dart';

void main() {
  test('enum and DateTime map keys serialize to strings', () {
    final log = EventLog.build(
      colorMap: {Color.Red: 'alert'},
      dateMap: {DateTime.utc(2024, 1, 2, 3, 4, 5): 7},
      timeMap: {'start': DateTime.utc(2024, 1, 2, 3, 4, 5)},
      timestamps: [DateTime.utc(2024, 1, 2, 3, 4, 5)],
      createdAt: DateTime.utc(2024, 1, 2, 3, 4, 5),
    );

    final decoded = jsonDecode(log.toJson()) as Map<String, dynamic>;
    final colorMap = decoded['color_map'] as Map<String, dynamic>;
    final dateMap = decoded['date_map'] as Map<String, dynamic>;
    final timeMap = decoded['time_map'] as Map<String, dynamic>;

    expect(colorMap.keys.first, 'red');
    expect(colorMap['red'], 'alert');
    expect(dateMap.keys.first, '2024-01-02T03:04:05.000Z');
    expect(dateMap['2024-01-02T03:04:05.000Z'], 7);
    expect(timeMap['start'], '2024-01-02T03:04:05.000Z');
    expect(decoded['created_at'], '2024-01-02T03:04:05.000Z');
  });

  test('enum and DateTime map keys roundtrip from json', () {
    final json = jsonEncode({
      'color_map': {'green': 'ok'},
      'date_map': {'2024-01-02T03:04:05.000Z': 9},
      'time_map': {'end': '2024-01-02T03:04:05.000Z'},
      'timestamps': ['2024-01-02T03:04:05.000Z'],
      'created_at': '2024-01-02T03:04:05.000Z',
    });

    final log = EventLog.fromJson(json)!;

    expect(log.colorMap.keys.first, Color.Green);
    expect(log.colorMap[Color.Green], 'ok');
    expect(log.dateMap.keys.first, DateTime.utc(2024, 1, 2, 3, 4, 5));
    expect(log.dateMap[DateTime.utc(2024, 1, 2, 3, 4, 5)], 9);
    expect(log.timeMap['end'], DateTime.utc(2024, 1, 2, 3, 4, 5));
    expect(log.timestamps.first, DateTime.utc(2024, 1, 2, 3, 4, 5));
    expect(log.createdAt, DateTime.utc(2024, 1, 2, 3, 4, 5));
  });

  test('serialize uses enum values and DateTime strings', () {
    final log = EventLog.build(
      colorMap: {Color.Green: 'go'},
      dateMap: {DateTime.utc(2024, 1, 2, 3, 4, 5): 1},
      timeMap: {'go': DateTime.utc(2024, 1, 2, 3, 4, 5)},
      timestamps: [DateTime.utc(2024, 1, 2, 3, 4, 5)],
      createdAt: DateTime.utc(2024, 1, 2, 3, 4, 5),
    );

    final serialized = log.serialize();
    final colorMap = serialized['colorMap'] as Map<String, dynamic>;
    final dateMap = serialized['dateMap'] as Map<String, dynamic>;
    final timeMap = serialized['timeMap'] as Map<String, dynamic>;

    expect(colorMap.keys.first, 'green');
    expect(dateMap.keys.first, '2024-01-02T03:04:05.000Z');
    expect(timeMap['go'], '2024-01-02T03:04:05.000Z');
    expect(serialized['createdAt'], '2024-01-02T03:04:05.000Z');
  });
}
