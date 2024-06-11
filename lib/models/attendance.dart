class Attendance {
  final DateTime date;
  final String eventName;

  Attendance({required this.date, required this.eventName});

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      date: DateTime.parse(json['date']),
      eventName: json['eventName'],
    );
  }
}