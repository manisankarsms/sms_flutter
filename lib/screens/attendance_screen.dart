import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms/models/attendance.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../bloc/attendance/attendance_bloc.dart';
import '../bloc/attendance/attendance_event.dart';
import '../bloc/attendance/attendance_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/user.dart';
import '../widgets/screen_header.dart';

class AttendanceScreen extends StatefulWidget {
  final User user;

  const AttendanceScreen({Key? key, required this.user}) : super(key: key);

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
      DateTime normalizedDate =
          DateTime(eventDate.year, eventDate.month, eventDate.day);

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
      return attendanceDate.month == currentMonth &&
          attendanceDate.year == currentYear;
    }).toList();

    int totalDays = monthlyAttendance.length;
    int presentDays = monthlyAttendance
        .where((a) => a.status.toUpperCase() == 'PRESENT')
        .length;
    int absentDays = monthlyAttendance
        .where((a) => a.status.toUpperCase() == 'ABSENT')
        .length;
    int lateDays =
        monthlyAttendance.where((a) => a.status.toUpperCase() == 'LATE').length;
    int leaveDays = monthlyAttendance
        .where((a) => a.status.toUpperCase() == 'LEAVE')
        .length;
    int excusedDays = monthlyAttendance
        .where((a) => a.status.toUpperCase() == 'EXCUSED')
        .length;

    double attendancePercentage =
        totalDays > 0 ? (presentDays / totalDays) * 100 : 0.0;

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
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: ScreenHeader(
                title: 'Attendance',
              ),
            ),
            Expanded(
              child: BlocBuilder<AttendanceBloc, AttendanceState>(
                builder: (context, state) => _buildContent(state),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildContent(AttendanceState state) {
    if (state is AttendanceLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is AttendanceError) {
      return _buildErrorView(state.message);
    }

    if (state is AttendanceLoaded) {
      _events = _mapEvents(state.attendance);
      final monthlyStats = _calculateMonthlyStats(state.attendance);

      if (state.attendance.isEmpty) {
        return _buildEmptyView();
      }

      return SingleChildScrollView(
        child: Column(
          children: [
            _buildCalendar(),
            _buildStatsSection(monthlyStats),
          ],
        ),
      );
    }

    return _buildEmptyView();
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.error_outline, size: 48, color: Colors.red),
          ),
          const SizedBox(height: 16),
          const Text(
            'Something went wrong!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<AttendanceBloc>().add(FetchAttendance(widget.user));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.calendar_today_outlined,
                size: 48, color: Color(0xFF6366F1)),
          ),
          const SizedBox(height: 16),
          const Text(
            'No attendance data available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your attendance records will appear here',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<AttendanceBloc>().add(FetchAttendance(widget.user));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
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
        calendarStyle: const CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle(color: Color(0xFF6B7280)),
          selectedDecoration: BoxDecoration(
            color: Color(0xFF6366F1),
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Color(0xFF10B981),
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF6B7280)),
          rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF6B7280)),
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
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
                      markerColor = const Color(0xFF10B981);
                      break;
                    case 'ABSENT':
                      markerColor = const Color(0xFFEF4444);
                      break;
                    case 'LATE':
                      markerColor = const Color(0xFFF59E0B);
                      break;
                    case 'LEAVE':
                      markerColor = const Color(0xFF8B5CF6);
                      break;
                    case 'EXCUSED':
                      markerColor = const Color(0xFF6366F1);
                      break;
                    default:
                      markerColor = const Color(0xFF6B7280);
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
    );
  }

  Widget _buildStatsSection(Map<String, dynamic> stats) {
    final monthName = DateFormat('MMMM yyyy').format(_focusedDay);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Overview Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$monthName Overview',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Attendance Rate Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Attendance Rate',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${stats['presentDays']} out of ${stats['totalDays']} days',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${stats['attendancePercentage'].toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Progress Bar
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B7280).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: stats['attendancePercentage'] / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Statistics Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildStatCard(
                'Present',
                stats['presentDays'].toString(),
                Icons.check_circle_rounded,
                const Color(0xFF10B981),
              ),
              _buildStatCard(
                'Absent',
                stats['absentDays'].toString(),
                Icons.cancel_rounded,
                const Color(0xFFEF4444),
              ),
              _buildStatCard(
                'Late',
                stats['lateDays'].toString(),
                Icons.access_time_rounded,
                const Color(0xFFF59E0B),
              ),
              _buildStatCard(
                'Leave',
                stats['leaveDays'].toString(),
                Icons.event_busy_rounded,
                const Color(0xFF8B5CF6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        context.read<AttendanceBloc>().add(FetchAttendance(widget.user));
      },
      backgroundColor: const Color(0xFF6366F1),
      elevation: 8,
      child: const Icon(Icons.refresh_rounded, color: Colors.white),
    );
  }

  void _showDayDetails(DateTime selectedDay) {
    final dayEvents =
        _events[DateTime(selectedDay.year, selectedDay.month, selectedDay.day)];

    if (dayEvents != null && dayEvents.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Attendance for ${DateFormat('MMM d, yyyy').format(selectedDay)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: dayEvents.map((attendance) {
                Color statusColor;
                IconData statusIcon;

                switch (attendance.status.toUpperCase()) {
                  case 'PRESENT':
                    statusColor = const Color(0xFF10B981);
                    statusIcon = Icons.check_circle_rounded;
                    break;
                  case 'ABSENT':
                    statusColor = const Color(0xFFEF4444);
                    statusIcon = Icons.cancel_rounded;
                    break;
                  case 'LATE':
                    statusColor = const Color(0xFFF59E0B);
                    statusIcon = Icons.access_time_rounded;
                    break;
                  case 'LEAVE':
                    statusColor = const Color(0xFF8B5CF6);
                    statusIcon = Icons.event_busy_rounded;
                    break;
                  case 'EXCUSED':
                    statusColor = const Color(0xFF6366F1);
                    statusIcon = Icons.event_available_rounded;
                    break;
                  default:
                    statusColor = const Color(0xFF6B7280);
                    statusIcon = Icons.help_outline_rounded;
                }

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.2)),
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
                      const SizedBox(height: 8),
                      Text(
                        '${attendance.className} - ${attendance.sectionName}',
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6366F1),
              ),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }
}
