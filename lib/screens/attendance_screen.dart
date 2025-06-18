import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms/models/attendance.dart';
import 'package:table_calendar/table_calendar.dart';

import '../bloc/attendance/attendance_bloc.dart';
import '../bloc/attendance/attendance_event.dart';
import '../bloc/attendance/attendance_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/user.dart';

class AttendanceScreen extends StatefulWidget {
  final User user;

  const AttendanceScreen({Key? key, required this.user});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
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

    // Trigger initial data fetch
    context.read<AttendanceBloc>().add(FetchAttendance(widget.user));
  }

  Map<DateTime, List<Attendance>> _mapEvents(List<Attendance> events) {
    Map<DateTime, List<Attendance>> mappedEvents = {};
    for (var event in events) {
      // Parse the date string from API response (format: "2025-06-17")
      DateTime eventDate = DateTime.parse(event.date);
      DateTime normalizedDate = DateTime(eventDate.year, eventDate.month, eventDate.day);

      if (mappedEvents[normalizedDate] == null) {
        mappedEvents[normalizedDate] = [event];
      } else {
        mappedEvents[normalizedDate]!.add(event);
      }
    }
    return mappedEvents;
  }

  // Calculate attendance statistics for the current month
  Map<String, dynamic> _calculateMonthlyStats(List<Attendance> allAttendance) {
    final currentMonth = _focusedDay.month;
    final currentYear = _focusedDay.year;

    final monthlyAttendance = allAttendance.where((attendance) {
      final attendanceDate = DateTime.parse(attendance.date);
      return attendanceDate.month == currentMonth && attendanceDate.year == currentYear;
    }).toList();

    int totalDays = monthlyAttendance.length;
    int presentDays = monthlyAttendance.where((a) => a.status.toUpperCase() == 'PRESENT').length;
    int absentDays = monthlyAttendance.where((a) => a.status.toUpperCase() == 'ABSENT').length;
    int lateDays = monthlyAttendance.where((a) => a.status.toUpperCase() == 'LATE').length;
    int leaveDays = monthlyAttendance.where((a) => a.status.toUpperCase() == 'LEAVE').length;
    int excusedDays = monthlyAttendance.where((a) => a.status.toUpperCase() == 'EXCUSED').length;

    double attendancePercentage = totalDays > 0 ? (presentDays / totalDays) * 100 : 0.0;

    return {
      'totalDays': totalDays,
      'presentDays': presentDays,
      'absentDays': absentDays,
      'lateDays': lateDays,
      'leaveDays': leaveDays,
      'excusedDays': excusedDays,
      'attendancePercentage': attendancePercentage,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.attendance ?? 'Attendance'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AttendanceLoaded) {
            _events = _mapEvents(state.attendance);
            final monthlyStats = _calculateMonthlyStats(state.attendance);
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildCalendar(),
                  _buildStatsCards(monthlyStats),
                ],
              ),
            );
          } else if (state is AttendanceError) {
            return _buildErrorState(context, state.message);
          } else {
            return _buildEmptyState(context);
          }
        },
      ),
    );
  }

  Widget _buildStatsCards(Map<String, dynamic> stats) {
    final monthName = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ][_focusedDay.month - 1];

    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$monthName ${_focusedDay.year} Overview',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // Compact attendance percentage card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Attendance Rate',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${stats['presentDays']} out of ${stats['totalDays']} days',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${stats['attendancePercentage'].toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Compact statistics row
          Row(
            children: [
              Expanded(
                child: _buildCompactStatCard(
                  'Present',
                  stats['presentDays'].toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCompactStatCard(
                  'Absent',
                  stats['absentDays'].toString(),
                  Icons.cancel,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCompactStatCard(
                  'Late',
                  stats['lateDays'].toString(),
                  Icons.access_time,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCompactStatCard(
                  'Leave',
                  stats['leaveDays'].toString(),
                  Icons.event_busy,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TableCalendar(
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

                    switch (attendanceEvent.status.toUpperCase()) {
                      case 'PRESENT':
                        markerColor = Colors.green;
                        break;
                      case 'ABSENT':
                        markerColor = Colors.red;
                        break;
                      case 'LEAVE':
                      case 'LATE':
                        markerColor = Colors.orange;
                        break;
                      case 'EXCUSED':
                        markerColor = Colors.blue;
                        break;
                      default:
                        markerColor = Colors.grey;
                    }

                    return Container(
                      width: 20,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
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
              _showDayDetails(selectedDay);
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
            setState(() {
              _focusedDay = focusedDay;
            });
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Something went wrong!',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Error: $message',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<AttendanceBloc>().add(FetchAttendance(widget.user));
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No attendance data available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your attendance records will appear here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<AttendanceBloc>().add(FetchAttendance(widget.user));
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDayDetails(DateTime selectedDay) {
    final dayEvents = _events[DateTime(selectedDay.year, selectedDay.month, selectedDay.day)];

    if (dayEvents != null && dayEvents.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Attendance for ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}',
            style: const TextStyle(fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: dayEvents.map((attendance) {
              Color statusColor;
              IconData statusIcon;

              switch (attendance.status.toUpperCase()) {
                case 'PRESENT':
                  statusColor = Colors.green;
                  statusIcon = Icons.check_circle;
                  break;
                case 'ABSENT':
                  statusColor = Colors.red;
                  statusIcon = Icons.cancel;
                  break;
                case 'LEAVE':
                case 'LATE':
                  statusColor = Colors.orange;
                  statusIcon = Icons.event_busy;
                  break;
                case 'EXCUSED':
                  statusColor = Colors.blue;
                  statusIcon = Icons.event_available;
                  break;
                default:
                  statusColor = Colors.grey;
                  statusIcon = Icons.help_outline;
              }

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          attendance.status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${attendance.className} - ${attendance.sectionName}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }
}