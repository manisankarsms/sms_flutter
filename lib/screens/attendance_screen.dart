import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms/models/attendance.dart';
import 'package:sms/repositories/mock_repository.dart';
import 'package:table_calendar/table_calendar.dart';

import '../bloc/attendance/attendance_bloc.dart';
import '../bloc/attendance/attendance_event.dart';
import '../bloc/attendance/attendance_state.dart';

class AttendanceScreen extends StatelessWidget {
  final MockAuthRepository authRepository = MockAuthRepository(); // Create an instance of AuthRepository
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AttendanceBloc(repository: authRepository)..add(FetchAttendance()),
      child: AttendanceView(),
    );
  }
}

class AttendanceView extends StatefulWidget {
  @override
  _AttendanceViewState createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final DateTime kToday = DateTime.now();
  late DateTime kFirstDay;
  late DateTime kLastDay;

  Map<DateTime, List<Attendance>> _events = {};

  @override
  void initState() {
    super.initState();
    kFirstDay = DateTime(kToday.year, kToday.month - 1, kToday.day);
    kLastDay = DateTime(kToday.year, kToday.month + 1, kToday.day);
  }

  Map<DateTime, List<Attendance>> _mapEvents(List<Attendance> events) {
    Map<DateTime, List<Attendance>> mappedEvents = {};
    for (var event in events) {
      DateTime eventDate = DateTime(event.date.year, event.date.month, event.date.day);
      if (mappedEvents[eventDate] == null) {
        mappedEvents[eventDate] = [event];
      } else {
        mappedEvents[eventDate]!.add(event);
      }
    }
    return mappedEvents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
      ),
      body: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AttendanceLoaded) {
            _events = _mapEvents(state.attendance);
            return TableCalendar(
              firstDay: kFirstDay,
              lastDay: kLastDay,
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              availableCalendarFormats: const {CalendarFormat.month: 'Month'},
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              eventLoader: (day) {
                final events = _events[DateTime(day.year, day.month, day.day)] ?? [];
                return events;
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: events.map((event) {
                        final attendanceEvent = event as Attendance;
                        Color markerColor;
                        switch (attendanceEvent.eventName) {
                          case 'Present':
                            markerColor = Colors.green;
                            break;
                          case 'Absent':
                            markerColor = Colors.red;
                            break;
                          case 'Leave':
                            markerColor = Colors.orange;
                            break;
                          default:
                            markerColor = Colors.grey;
                        }
                        return Container(
                          width: 20,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: markerColor,
                          ),
                        );
                      }).toList(),
                    );
                  }
                  return null;
                },
              ),
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            );
          } else if (state is AttendanceError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
