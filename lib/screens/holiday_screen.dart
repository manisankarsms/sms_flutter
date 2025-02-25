import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/holiday/holiday_bloc.dart';
import '../bloc/holiday/holiday_state.dart';

class HolidayScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<HolidayBloc, HolidayState>(
          builder: (context, state) {
            if (state.status == HolidayStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.status == HolidayStatus.failure) {
              return const Center(child: Text('Failed to load holidays'));
            } else if (state.holidays.isEmpty) {
              return const Center(child: Text('No holidays available'));
            }
            return ListView.separated(
              itemCount: state.holidays.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final holiday = state.holidays[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Row(
                      children: [
                        Icon(
                          holiday.isPublicHoliday ? Icons.star : Icons.event,
                          color: holiday.isPublicHoliday ? Colors.orange : Colors.blue,
                          size: 30,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                holiday.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${holiday.date} • ${holiday.description}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
