class TimerRecord {
  final String name;
  int seconds;
  int startTime;
  int endTime;

  TimerRecord({
    required this.name,
    required this.seconds,
    required this.startTime,
    required this.endTime,
  });

  factory TimerRecord.empty() {
    return TimerRecord(name: '', seconds: 0, startTime: 0, endTime: 0);
  }

    @override
  String toString() {
    return 'TimerRecord(name: $name, seconds: $seconds, startTime: $startTime, endTime: $endTime)';
  }

  factory TimerRecord.fromJson(Map<String, dynamic> json) {
    return TimerRecord(
      name: json['name'] as String,
      seconds: json['seconds'] as int,
      startTime: json['startTime'] as int,
      endTime: json['endTime'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'seconds': seconds,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}
