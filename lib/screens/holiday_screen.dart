import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/holiday/holiday_bloc.dart';
import '../bloc/holiday/holiday_event.dart';
import '../bloc/holiday/holiday_state.dart';
import '../models/holiday.dart';
import '../models/user.dart';

class HolidayScreen extends StatelessWidget {
  final User user;

  HolidayScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Holidays'),
        elevation: 0,
        actions: [
          if (user.role.toLowerCase() == 'admin')
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showHolidayDialog(context),
              tooltip: 'Add Holiday',
            ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: BlocListener<HolidayBloc, HolidayState>(
              listener: (context, state) {
                // Handle error messages
                if (state.errorMessage != null) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage!),
                      backgroundColor: Colors.red,
                      action: state.status == HolidayStatus.failure
                          ? SnackBarAction(
                        label: 'RETRY',
                        textColor: Colors.white,
                        onPressed: () {
                          context.read<HolidayBloc>().add(LoadHolidays());
                        },
                      )
                          : null,
                    ),
                  );
                }
                // Handle success messages for add, update, and delete
                if (!state.isOperating &&
                    state.status == HolidayStatus.success) {
                  String message = '';
                  if (state.holidays.length > _previousHolidayCount) {
                    message = 'Holiday added successfully';
                  } else if (state.holidays.length < _previousHolidayCount) {
                    message = 'Holiday deleted successfully';
                  } else if (_previousHolidayCount == state.holidays.length) {
                    message = 'Holiday updated successfully';
                  }
                  if (message.isNotEmpty) {
                    print('Showing SnackBar: $message'); // Debug log
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                    _previousHolidayCount = state.holidays.length;
                  }
                }
              },
              listenWhen: (previous, current) =>
              previous.errorMessage != current.errorMessage ||
                  (previous.isOperating != current.isOperating &&
                      current.status == HolidayStatus.success),
              child: BlocBuilder<HolidayBloc, HolidayState>(
                builder: (context, state) {
                  try {
                    print('Rendering HolidayScreen: status=${state
                        .status}, holidays=${state.holidays
                        .length}'); // Debug log
                    return _buildContent(context, state);
                  } catch (e) {
                    debugPrint('Error rendering holiday screen: $e');
                    return _buildErrorFallback(context, e.toString());
                  }
                },
              ),
            ),
          ),
          BlocBuilder<HolidayBloc, HolidayState>(
            builder: (context, state) {
              if (state.isOperating) {
                return Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Processing...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      floatingActionButton: user.role.toLowerCase() == 'admin'
          ? BlocBuilder<HolidayBloc, HolidayState>(
        builder: (context, state) {
          return FloatingActionButton(
            onPressed: state.isOperating
                ? null
                : () => _showHolidayDialog(context),
            child: const Icon(Icons.add),
            tooltip: 'Add Holiday',
          );
        },
      )
          : null,
    );
  }

  // Track previous holiday count to detect add/delete/update
  int _previousHolidayCount = 0;

  Widget _buildContent(BuildContext context, HolidayState state) {
    if (state.status == HolidayStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == HolidayStatus.failure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.errorMessage ?? 'Failed to load holidays'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<HolidayBloc>().add(LoadHolidays()),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Handle unexpected status (e.g., initial)
    if (state.status != HolidayStatus.success) {
      print('Unexpected state in _buildContent: ${state.status}'); // Debug log
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Waiting for holiday data...'),
          ],
        ),
      );
    }

    // Handle empty holidays list
    if (state.holidays.isEmpty) {
      print('Rendering empty holidays list'); // Debug log
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No holidays available'),
            if (user.role.toLowerCase() == 'admin') ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showHolidayDialog(context),
                child: const Text('Add Holiday'),
              ),
            ],
          ],
        ),
      );
    }

    // Non-empty holidays list
    return _buildHolidaysList(context, state);
  }

  Widget _buildHolidaysList(BuildContext context, HolidayState state) {
    try {
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month);
      final nextMonth = DateTime(now.year, now.month + 1);

      final Map<String, List<Holiday>> timelineHolidays = {
        'This Month': <Holiday>[],
        'Upcoming': <Holiday>[],
        'Past': <Holiday>[],
      };

      for (final holiday in state.holidays) {
        try {
          final holidayDate = _parseDate(holiday.date);
          if (holidayDate.isBefore(currentMonth)) {
            timelineHolidays['Past']!.add(holiday);
          } else if (holidayDate.isBefore(nextMonth)) {
            timelineHolidays['This Month']!.add(holiday);
          } else {
            timelineHolidays['Upcoming']!.add(holiday);
          }
        } catch (e) {
          debugPrint('Error parsing holiday date: ${holiday.date}, $e');
          timelineHolidays['Upcoming']!.add(holiday);
        }
      }

      final sections = <Widget>[];
      if (timelineHolidays['This Month']!.isNotEmpty) {
        sections.add(_buildTimelineHeader('This Month'));
        sections.addAll(
            _buildMonthWiseSections(context, timelineHolidays['This Month']!));
      }
      if (timelineHolidays['Upcoming']!.isNotEmpty) {
        sections.add(_buildTimelineHeader('Upcoming'));
        sections.addAll(
            _buildMonthWiseSections(context, timelineHolidays['Upcoming']!));
      }
      if (timelineHolidays['Past']!.isNotEmpty) {
        sections.add(_buildTimelineHeader('Past'));
        sections.addAll(
            _buildMonthWiseSections(context, timelineHolidays['Past']!));
      }

      // Fallback for no valid sections
      if (sections.isEmpty) {
        print('No valid timeline sections'); // Debug log
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No holidays to display in this period'),
          ),
        );
      }

      print('Rendering ${sections.length} sections'); // Debug log
      return CustomScrollView(
        slivers: [
          ...sections,
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      );
    } catch (e) {
      debugPrint('Error building holidays list: $e');
      return _buildErrorFallback(context, 'Error displaying holidays: $e');
    }
  }

  Widget _buildErrorFallback(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Something went wrong'),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<HolidayBloc>().add(LoadHolidays()),
            child: const Text('Reload'),
          ),
        ],
      ),
    );
  }

  static DateTime _parseDate(String dateStr) {
    try {
      if (dateStr.isEmpty) {
        return DateTime.now();
      }
      return DateFormat('yyyy-MM-dd').parse(dateStr);
    } catch (e) {
      debugPrint('Error parsing date: $dateStr, $e');
      try {
        return DateTime.parse(dateStr);
      } catch (e2) {
        debugPrint('Alternative date parsing failed: $e2');
        return DateTime.now();
      }
    }
  }

  List<Widget> _buildMonthWiseSections(BuildContext context,
      List<Holiday> holidays) {
    try {
      print('Building month-wise sections with ${holidays
          .length} holidays'); // Debug log
      if (holidays.isEmpty) {
        return [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No holidays in this period'),
            ),
          ),
        ];
      }

      final Map<String, List<Holiday>> monthlyHolidays = {};
      for (final holiday in holidays) {
        try {
          final holidayDate = _parseDate(holiday.date);
          final monthKey = DateFormat('MMMM yyyy').format(holidayDate);
          monthlyHolidays.putIfAbsent(monthKey, () => <Holiday>[]);
          monthlyHolidays[monthKey]!.add(holiday);
        } catch (e) {
          debugPrint(
              'Error processing holiday for grouping: ${holiday.name}, $e');
        }
      }

      if (monthlyHolidays.isEmpty) {
        return [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No valid holidays found'),
            ),
          ),
        ];
      }

      final sortedMonthKeys = monthlyHolidays.keys.toList();
      try {
        sortedMonthKeys.sort((a, b) {
          try {
            final dateA = DateFormat('MMMM yyyy').parse(a);
            final dateB = DateFormat('MMMM yyyy').parse(b);
            return dateA.compareTo(dateB);
          } catch (e) {
            debugPrint('Error sorting months: $e');
            return a.compareTo(b);
          }
        });
      } catch (e) {
        debugPrint('Error in month sorting: $e');
      }

      final List<Widget> monthSections = [];
      for (final monthKey in sortedMonthKeys) {
        final monthHolidays = monthlyHolidays[monthKey] ?? [];
        if (monthHolidays.isNotEmpty) {
          monthSections.add(_buildMonthHeader(monthKey));
          monthSections.add(_buildHolidayList(context, monthHolidays));
        }
      }

      return monthSections.isNotEmpty
          ? monthSections
          : [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No holidays to display'),
          ),
        ),
      ];
    } catch (e) {
      debugPrint('Error in _buildMonthWiseSections: $e');
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error displaying holidays: $e'),
          ),
        ),
      ];
    }
  }

  SliverList _buildHolidayList(BuildContext context, List<Holiday> holidays) {
    print(
        'Building holiday list with ${holidays.length} holidays'); // Debug log
    if (holidays.isEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate([
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No holidays in this period'),
          ),
        ]),
      );
    }

    try {
      holidays.sort((a, b) {
        try {
          final dateA = _parseDate(a.date);
          final dateB = _parseDate(b.date);
          return dateA.compareTo(dateB);
        } catch (e) {
          debugPrint('Error sorting holidays: $e');
          return (a.name ?? '').compareTo(b.name ?? '');
        }
      });
    } catch (e) {
      debugPrint('Error in holiday sorting: $e');
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          if (index >= holidays.length) {
            return const SizedBox.shrink();
          }
          final holiday = holidays[index];
          try {
            return _buildHolidayCard(context, holiday);
          } catch (e) {
            debugPrint('Error building holiday card at index $index: $e');
            return const Card(
              child: ListTile(
                title: Text('Error loading holiday'),
                leading: Icon(Icons.error, color: Colors.red),
              ),
            );
          }
        },
        childCount: holidays.length,
      ),
    );
  }

  Widget _buildHolidayCard(BuildContext context, Holiday holiday) {
    try {
      final holidayDate = _parseDate(holiday.date);

      return BlocBuilder<HolidayBloc, HolidayState>(
        builder: (context, state) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            elevation: 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Dismissible(
              key: Key(
                  'holiday_${holiday.id}_${holiday.name ?? "unnamed"}_${DateTime
                      .now()
                      .millisecondsSinceEpoch}'),
              direction: (user.role.toLowerCase() == 'admin' && !state.isOperating)
                  ? DismissDirection.endToStart
                  : DismissDirection.none,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20.0),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                if (user.role.toLowerCase() != 'admin' || state.isOperating) return false;
                return await _showDeleteConfirmation(context, holiday);
              },
              onDismissed: (direction) async {
                final deletedHoliday = holiday;
                context.read<HolidayBloc>().add(DeleteHoliday(holiday.id));
                await Future.delayed(const Duration(milliseconds: 200));
              },
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 8, horizontal: 16),
                leading: CircleAvatar(
                  backgroundColor: holiday.isPublicHoliday
                      ? Colors.orange.withOpacity(0.2)
                      : Colors.blue.withOpacity(0.2),
                  child: Icon(
                    holiday.isPublicHoliday ? Icons.star : Icons.event,
                    color: holiday.isPublicHoliday ? Colors.orange : Colors
                        .blue,
                  ),
                ),
                title: Text(
                  holiday.name ?? 'Unnamed Holiday',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: _buildHolidaySubtitle(holiday, holidayDate),
                trailing: user.role.toLowerCase() == 'admin' ? _buildAdminActions(
                    context, state, holiday) : null,
                onTap: (user.role.toLowerCase() == 'admin' && !state.isOperating)
                    ? () => _showHolidayDialog(context, holiday: holiday)
                    : null,
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('Error building holiday card: $e');
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: ListTile(
          title: Text(holiday.name ?? 'Holiday'),
          subtitle: const Text('Error displaying details'),
          leading: const Icon(Icons.error, color: Colors.red),
        ),
      );
    }
  }

  Widget _buildHolidaySubtitle(Holiday holiday, DateTime holidayDate) {
    try {
      return Column(
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
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
          if (holiday.description?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                holiday.description!,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ),
        ],
      );
    } catch (e) {
      debugPrint('Error building holiday subtitle: $e');
      return Text(
        'Error displaying date',
        style: TextStyle(color: Colors.grey[600]),
      );
    }
  }

  Widget _buildAdminActions(BuildContext context, HolidayState state,
      Holiday holiday) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.edit,
            color: state.isOperating ? Colors.grey : Colors.blue,
          ),
          onPressed: state.isOperating
              ? null
              : () => _showHolidayDialog(context, holiday: holiday),
        ),
        IconButton(
          icon: Icon(
            Icons.delete,
            color: state.isOperating ? Colors.grey : Colors.red,
          ),
          onPressed: state.isOperating
              ? null
              : () => _confirmDelete(context, holiday),
        ),
      ],
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context,
      Holiday holiday) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: Text("Are you sure you want to delete ${holiday.name ??
              'Unnamed Holiday'}?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("CANCEL"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("DELETE", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    ) ?? false;
  }

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

  bool _isUpcomingSoon(DateTime holidayDate) {
    try {
      final now = DateTime.now();
      final difference = holidayDate
          .difference(now)
          .inDays;
      return difference >= 0 && difference <= 14;
    } catch (e) {
      debugPrint('Error checking upcoming date: $e');
      return false;
    }
  }

  void _showHolidayDialog(BuildContext context, {Holiday? holiday}) {
    final bool isEditing = holiday != null;
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(
        text: isEditing ? holiday!.name : '');
    final _descriptionController = TextEditingController(
        text: isEditing && holiday!.description != null
            ? holiday.description!
            : '');
    DateTime? _selectedDate;
    final _dateController = TextEditingController();

    if (isEditing) {
      _selectedDate = _parseDate(holiday!.date);
      _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
    }

    bool _isPublicHoliday = isEditing ? holiday!.isPublicHoliday : false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: context.read<HolidayBloc>(),
          child: StatefulBuilder(
            builder: (context, setState) {
              Future<void> _selectDate() async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime(DateTime
                      .now()
                      .year - 1),
                  lastDate: DateTime(DateTime
                      .now()
                      .year + 2),
                );
                if (picked != null && picked != _selectedDate) {
                  setState(() {
                    _selectedDate = picked;
                    _dateController.text =
                        DateFormat('yyyy-MM-dd').format(picked);
                  });
                }
              }

              return BlocListener<HolidayBloc, HolidayState>(
                listener: (context, state) {
                  if (!state.isOperating &&
                      state.status == HolidayStatus.success) {
                    Navigator.of(dialogContext).pop();
                  }
                  if (!state.isOperating &&
                      state.status == HolidayStatus.failure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage ??
                            'Operation failed. Please try again.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: BlocBuilder<HolidayBloc, HolidayState>(
                  builder: (context, state) {
                    return AlertDialog(
                      title: Text(isEditing ? 'Edit Holiday' : 'Add Holiday'),
                      content: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _nameController,
                                enabled: !state.isOperating,
                                decoration: const InputDecoration(
                                  labelText: 'Holiday Name',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a holiday name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: state.isOperating ? null : _selectDate,
                                child: AbsorbPointer(
                                  child: TextFormField(
                                    controller: _dateController,
                                    enabled: !state.isOperating,
                                    decoration: const InputDecoration(
                                      labelText: 'Date',
                                      border: OutlineInputBorder(),
                                      suffixIcon: Icon(Icons.calendar_today),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select a date';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _descriptionController,
                                enabled: !state.isOperating,
                                decoration: const InputDecoration(
                                  labelText: 'Description (Optional)',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                              ),
                              const SizedBox(height: 16),
                              CheckboxListTile(
                                title: const Text('Public Holiday'),
                                value: _isPublicHoliday,
                                onChanged: state.isOperating
                                    ? null
                                    : (bool? value) {
                                  if (value != null) {
                                    setState(() {
                                      _isPublicHoliday = value;
                                    });
                                  }
                                },
                                contentPadding: EdgeInsets.zero,
                                controlAffinity: ListTileControlAffinity
                                    .leading,
                              ),
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: state.isOperating ? null : () =>
                              Navigator.of(dialogContext).pop(),
                          child: const Text('CANCEL'),
                        ),
                        if (isEditing)
                          TextButton(
                            onPressed: state.isOperating
                                ? null
                                : () => _confirmDelete(dialogContext, holiday!),
                            child: const Text(
                                'DELETE', style: TextStyle(color: Colors.red)),
                          ),
                        TextButton(
                          onPressed: state.isOperating
                              ? null
                              : () {
                            if (_formKey.currentState!.validate() &&
                                _selectedDate != null) {
                              final updatedHoliday = Holiday(
                                id: isEditing ? holiday!.id : 0,
                                name: _nameController.text,
                                date: DateFormat('yyyy-MM-dd').format(
                                    _selectedDate!),
                                description: _descriptionController.text
                                    .isNotEmpty
                                    ? _descriptionController.text
                                    : null,
                                isPublicHoliday: _isPublicHoliday,
                              );
                              if (isEditing) {
                                context.read<HolidayBloc>().add(
                                    UpdateHoliday(updatedHoliday));
                              } else {
                                context.read<HolidayBloc>().add(
                                    AddHoliday(updatedHoliday));
                              }
                            }
                          },
                          child: state.isOperating
                              ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : Text(isEditing ? 'UPDATE' : 'ADD'),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext dialogContext, Holiday holiday) {
    showDialog(
      context: dialogContext,
      builder: (BuildContext context) {
        return BlocProvider.value(
          value: dialogContext.read<HolidayBloc>(),
          child: BlocListener<HolidayBloc, HolidayState>(
            listener: (context, state) {
              if (!state.isOperating && state.status == HolidayStatus.success) {
                Navigator.of(context).pop();
              }
            },
            child: BlocBuilder<HolidayBloc, HolidayState>(
              builder: (context, state) {
                return AlertDialog(
                    title: const Text("Confirm Delete"),
                    content: Text(
                        "Are you sure you want to delete ${holiday.name ??
                            'Unnamed Holiday'}?"),
                    actions: <Widget>[
                TextButton(
                onPressed: state.isOperating ? null : ()
                =>
                    Navigator.of(context).pop()
                ,
                child: const Text("CANCEL"),
                ),
                TextButton(
                onPressed: state.isOperating
                ? null
                    : () => context.read<HolidayBloc>().add(DeleteHoliday(holiday.id)),
                child: state.isOperating
                ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text("DELETE", style: TextStyle(color: Colors.red)),
                )
                ,
                ]
                ,
                );
              },
            ),
          ),
        );
      },
    );
  }
}