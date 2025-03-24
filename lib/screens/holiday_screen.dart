import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/holiday/holiday_bloc.dart';
import '../bloc/holiday/holiday_state.dart';
import '../models/holiday.dart'; // Assuming this exists

class HolidayScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Holidays'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: BlocBuilder<HolidayBloc, HolidayState>(
          builder: (context, state) {
            if (state.status == HolidayStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.status == HolidayStatus.failure) {
              return const Center(child: Text('Failed to load holidays'));
            } else if (state.holidays.isEmpty) {
              return const Center(child: Text('No holidays available'));
            }

            // Partition holidays into timeline sections
            final now = DateTime.now();
            final currentMonth = DateTime(now.year, now.month);
            final nextMonth = DateTime(now.year, now.month + 1);

            final Map<String, List<dynamic>> timelineHolidays = {
              'This Month': [],
              'Upcoming': [],
              'Past': [],
            };

            for (final holiday in state.holidays) {
              final holidayDate = _parseDate(holiday.date);

              if (holidayDate.isBefore(currentMonth)) {
                timelineHolidays['Past']!.add(holiday);
              } else if (holidayDate.isBefore(nextMonth)) {
                timelineHolidays['This Month']!.add(holiday);
              } else {
                timelineHolidays['Upcoming']!.add(holiday);
              }
            }

            return CustomScrollView(
              slivers: [
                // This Month section
                if (timelineHolidays['This Month']!.isNotEmpty) ...[
                  _buildTimelineHeader('This Month'),
                  ..._buildMonthWiseSections(timelineHolidays['This Month']!),
                ],

                // Upcoming section
                if (timelineHolidays['Upcoming']!.isNotEmpty) ...[
                  _buildTimelineHeader('Upcoming'),
                  ..._buildMonthWiseSections(timelineHolidays['Upcoming']!),
                ],

                // Past section
                if (timelineHolidays['Past']!.isNotEmpty) ...[
                  _buildTimelineHeader('Past'),
                  ..._buildMonthWiseSections(timelineHolidays['Past']!),
                ],

                // Add padding at the bottom for better UX
                SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Timeline section header
  SliverToBoxAdapter _buildTimelineHeader(String title) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.only(top: 24, bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.indigo.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.indigo.shade100),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.indigo.shade800,
          ),
        ),
      ),
    );
  }

  // Month-wise subsection header
  SliverToBoxAdapter _buildMonthHeader(String monthYear) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.only(top: 16, bottom: 8, left: 8),
        child: Text(
          monthYear,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.blueGrey.shade700,
          ),
        ),
      ),
    );
  }

  // Group holidays by month and build sections
  List<Widget> _buildMonthWiseSections(List<dynamic> holidays) {
    // Group holidays by month
    final Map<String, List<dynamic>> monthlyHolidays = {};

    for (final holiday in holidays) {
      final holidayDate = _parseDate(holiday.date);
      final monthKey = DateFormat('MMMM yyyy').format(holidayDate);

      if (!monthlyHolidays.containsKey(monthKey)) {
        monthlyHolidays[monthKey] = [];
      }

      monthlyHolidays[monthKey]!.add(holiday);
    }

    // Sort month keys
    final sortedMonthKeys = monthlyHolidays.keys.toList()
      ..sort((a, b) {
        final dateA = DateFormat('MMMM yyyy').parse(a);
        final dateB = DateFormat('MMMM yyyy').parse(b);
        return dateA.compareTo(dateB);
      });

    // Build sliver widgets for each month
    final List<Widget> monthSections = [];

    for (final monthKey in sortedMonthKeys) {
      // Add month header
      monthSections.add(_buildMonthHeader(monthKey));

      // Add holidays for this month
      monthSections.add(_buildHolidayList(monthlyHolidays[monthKey]!));
    }

    return monthSections;
  }

  // Holiday list for a month
  SliverList _buildHolidayList(List<dynamic> holidays) {
    // Sort holidays by date within the month
    holidays.sort((a, b) {
      final dateA = _parseDate(a.date);
      final dateB = _parseDate(b.date);
      return dateA.compareTo(dateB);
    });

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final holiday = holidays[index];
          final holidayDate = _parseDate(holiday.date);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            elevation: 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              leading: CircleAvatar(
                backgroundColor: holiday.isPublicHoliday
                    ? Colors.orange.withOpacity(0.2)
                    : Colors.blue.withOpacity(0.2),
                child: Icon(
                  holiday.isPublicHoliday ? Icons.star : Icons.event,
                  color: holiday.isPublicHoliday ? Colors.orange : Colors.blue,
                ),
              ),
              title: Text(
                holiday.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          DateFormat('EEE, MMM d').format(holidayDate),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (_isUpcomingSoon(holidayDate))
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Soon',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (holiday.description != null && holiday.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        holiday.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
        childCount: holidays.length,
      ),
    );
  }

  // Check if a holiday is coming up in the next 14 days
  bool _isUpcomingSoon(DateTime holidayDate) {
    final now = DateTime.now();
    final difference = holidayDate.difference(now).inDays;
    return difference >= 0 && difference <= 14;
  }

  // Helper method to parse dates
  static DateTime _parseDate(String dateStr) {
    // Modify this based on your date format
    try {
      return DateFormat('yyyy-MM-dd').parse(dateStr);
    } catch (e) {
      // Fallback to current date if parsing fails
      return DateTime.now();
    }
  }
}