import 'package:flutter/material.dart';
import 'package:sms/models/attendance.dart';
import 'package:sms/repositories/mock_repository.dart';
import 'package:table_calendar/table_calendar.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final kToday = DateTime.now();
  late DateTime kFirstDay;
  late DateTime kLastDay;

  Map<DateTime, List> _events = {};

    @override
  void initState(){
    // TODO: implement initState
    // Simulated database data
    // _events = {
    //   DateTime.utc(2024, 2, 10): ['Event 1'], // Example: Date with an event
    //   DateTime.utc(2024, 2, 15): ['Event 2'], // Example: Date with another event
    // };
    _fetchEvents();
    kFirstDay = DateTime(kToday.year, kToday.month - 1, kToday.day);
    kLastDay = DateTime(kToday.year, kToday.month + 1, kToday.day);
    super.initState();
  }

  Future<void> _fetchEvents() async {
    try {
      final List<Attendance> events = await MockAuthRepository().fetchAttendance();
      setState(() {
        _events = _mapEvents(events);
      });
    } catch (e) {
      // Handle error
      print('Error fetching events: $e');
    }
  }
  Map<DateTime, List> _mapEvents(List<Attendance> events) {
    return Map.fromIterable(
      events,
      key: (event) => event.date,
      value: (event) => [event.eventName],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
      ),
      body: TableCalendar(
        firstDay: kFirstDay,
        lastDay: kLastDay,
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        availableCalendarFormats: const {CalendarFormat.month : 'Month'},
        selectedDayPredicate: (day) {
          // Use `selectedDayPredicate` to determine which day is currently selected.
          // If this returns true, then `day` will be marked as selected.

          // Using `isSameDay` is recommended to disregard
          // the time-part of compared DateTime objects.
          return isSameDay(_selectedDay, day);
        },
        eventLoader: (day) {
          return _events[day] ?? [];
        },
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            final hasEvents = events.isNotEmpty;
            return Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                color: hasEvents ? Colors.green : null,
              ),
              width: 10,
              height: 10,
            );
          },
        ),
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            // Call `setState()` when updating the selected day
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          }
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            // Call `setState()` when updating calendar format
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        onPageChanged: (focusedDay) {
          // No need to call `setState()` here
          _focusedDay = focusedDay;
        },
      ),
    );
  }
}