import 'dart:convert';
import '../constants/colors.dart';

@pragma('model')
class EventLog {
  @pragma('json:color_map')
  Map<Color, String> colorMap = {};

  @pragma('json:date_map')
  Map<DateTime, int> dateMap = {};

  @pragma('json:time_map')
  Map<String, DateTime> timeMap = {};

  @pragma('json:timestamps')
  List<DateTime> timestamps = [];

  @pragma('json:created_at')
  DateTime? createdAt;

  EventLog();

  EventLog.build({
    required this.colorMap,
    required this.dateMap,
    required this.timeMap,
    required this.timestamps,
    this.createdAt,
  });

  void patch(Map? _data) {
    if (_data == null) return;

    DateTime? toDateTime(val) =>
        val == null ? null : DateTime.parse(val.toString());

    colorMap = (_data['color_map'] as Map?)?.map<Color, String>(
            (k, v) => MapEntry(Color.parse(k)!, v as String)) ??
        {};
    dateMap = (_data['date_map'] as Map?)?.map<DateTime, int>(
            (k, v) => MapEntry(DateTime.parse(k), v ~/ 1)) ??
        {};
    timeMap = (_data['time_map'] as Map?)?.map<String, DateTime>(
            (k, v) => MapEntry(k as String, toDateTime(v)!)) ??
        {};
    timestamps = _data['timestamps']
            ?.map((i) => toDateTime(i)!)
            .toList()
            .cast<DateTime>() ??
        [];
    createdAt = toDateTime(_data['created_at']) ?? createdAt;
  }

  static EventLog? fromMap(Map? data) {
    if (data == null) return null;
    return EventLog()..patch(data);
  }

  Map<String, dynamic> toMap() => {
        'color_map':
            colorMap.map<String, dynamic>((k, v) => MapEntry(k.value, v)),
        'date_map': dateMap
            .map<String, dynamic>((k, v) => MapEntry(k.toIso8601String(), v)),
        'time_map': timeMap
            .map<String, dynamic>((k, v) => MapEntry(k, v.toIso8601String())),
        'timestamps': timestamps.map((i) => i.toIso8601String()).toList(),
        'created_at': createdAt?.toIso8601String(),
      };
  String toJson() => json.encode(toMap());
  static EventLog? fromJson(String data) => EventLog.fromMap(json.decode(data));
  Map<String, dynamic> serialize() => {
        'colorMap':
            colorMap.map<String, dynamic>((k, v) => MapEntry(k.value, v)),
        'dateMap': dateMap
            .map<String, dynamic>((k, v) => MapEntry(k.toIso8601String(), v)),
        'timeMap': timeMap
            .map<String, dynamic>((k, v) => MapEntry(k, v.toIso8601String())),
        'timestamps': timestamps.map((i) => i.toIso8601String()).toList(),
        'createdAt': createdAt?.toIso8601String(),
      };
}
