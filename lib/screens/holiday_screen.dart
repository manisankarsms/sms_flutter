import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

import '../bloc/holiday/holiday_bloc.dart';
import '../bloc/holiday/holiday_event.dart';
import '../bloc/holiday/holiday_state.dart';
import '../models/holiday.dart';
import '../models/user.dart';
import '../widgets/screen_header.dart';

class HolidayScreen extends StatefulWidget {
  final User user;

  const HolidayScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<HolidayScreen> createState() => _HolidayScreenState();
}

class _HolidayScreenState extends State<HolidayScreen> {
  int _previousHolidayCount = 0;
  final Set<int> _dismissedHolidays = <int>{};

  @override
  void initState() {
    super.initState();
    // Load holidays when screen initializes
    context.read<HolidayBloc>().add(LoadHolidays());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: BlocListener<HolidayBloc, HolidayState>(
          listener: _handleStateChanges,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: ScreenHeader(
                  title: 'Holidays',
                ),
              ),
              Expanded(
                child: BlocBuilder<HolidayBloc, HolidayState>(
                  builder: (context, state) => _buildContent(state),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildContent(HolidayState state) {
    if (state.status == HolidayStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == HolidayStatus.failure) {
      return _buildErrorView(state.errorMessage);
    }

    if (state.holidays.isEmpty) {
      return _buildEmptyView();
    }

    return _buildHolidaysList(state.holidays);
  }

  Widget _buildErrorView(String? message) {
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
          Text(
            message ?? 'Failed to load holidays',
            style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<HolidayBloc>().add(LoadHolidays()),
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
            child: const Icon(Icons.event_available,
                size: 48, color: Color(0xFF6366F1)),
          ),
          const SizedBox(height: 16),
          const Text(
            'No holidays yet',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first holiday to get started',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          if (widget.user.role.toLowerCase() == 'admin') ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _showHolidayDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Add Holiday'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHolidaysList(List<Holiday> holidays) {
    // Filter out dismissed holidays
    final filteredHolidays = holidays.where((holiday) => !_dismissedHolidays.contains(holiday.id)).toList();
    final groupedHolidays = _groupHolidaysByMonth(filteredHolidays);

    return RefreshIndicator(
      onRefresh: () async {
        context.read<HolidayBloc>().add(LoadHolidays());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: groupedHolidays.length,
        itemBuilder: (context, index) {
          final monthData = groupedHolidays[index];
          return _buildMonthSection(monthData['month'], monthData['holidays']);
        },
      ),
    );
  }

  Widget _buildMonthSection(String month, List<Holiday> holidays) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              month,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...holidays.map((holiday) => _buildHolidayCard(holiday)),
        ],
      ),
    );
  }

  Widget _buildHolidayCard(Holiday holiday) {
    final holidayDate = _parseDate(holiday.date);
    final isUpcoming = _isUpcomingSoon(holidayDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Dismissible(
          key: Key('holiday_${holiday.id}'),
          direction: widget.user.role.toLowerCase() == 'admin'
              ? DismissDirection.endToStart
              : DismissDirection.none,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) => _showDeleteConfirmation(holiday),
          onDismissed: (direction) {
            // Immediately remove from dismissed set and delete
            setState(() {
              _dismissedHolidays.add(holiday.id);
            });
            _deleteHoliday(holiday.id);
          },
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: holiday.isPublicHoliday
                    ? const Color(0xFFF59E0B).withOpacity(0.1)
                    : const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                holiday.isPublicHoliday
                    ? Icons.star_rounded
                    : Icons.event_rounded,
                color: holiday.isPublicHoliday
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF10B981),
                size: 24,
              ),
            ),
            title: Text(
              holiday.name ?? 'Unnamed Holiday',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B7280).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        DateFormat('MMM d, yyyy').format(holidayDate),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isUpcoming) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Soon',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (holiday.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    holiday.description!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ],
            ),
            trailing: widget.user.role.toLowerCase() == 'admin'
                ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded,
                      color: Color(0xFF6B7280)),
                  onPressed: () =>
                      _showHolidayDialog(context, holiday: holiday),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_rounded,
                      color: Colors.red),
                  onPressed: () => _showDeleteConfirmation(holiday).then((confirmed) {
                    if (confirmed) {
                      setState(() {
                        _dismissedHolidays.add(holiday.id);
                      });
                      _deleteHoliday(holiday.id);
                    }
                  }),
                ),
              ],
            )
                : null,
            onTap: widget.user.role.toLowerCase() == 'admin'
                ? () => _showHolidayDialog(context, holiday: holiday)
                : null,
          ),
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (widget.user.role.toLowerCase() != 'admin') return null;

    return BlocBuilder<HolidayBloc, HolidayState>(
      builder: (context, state) {
        return FloatingActionButton(
          onPressed:
          state.isOperating ? null : () => _showHolidayDialog(context),
          backgroundColor: const Color(0xFF6366F1),
          elevation: 8,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        );
      },
    );
  }

  // Helper methods
  List<Map<String, dynamic>> _groupHolidaysByMonth(List<Holiday> holidays) {
    final Map<String, List<Holiday>> grouped = {};

    for (final holiday in holidays) {
      final date = _parseDate(holiday.date);
      final monthKey = DateFormat('MMMM yyyy').format(date);
      grouped.putIfAbsent(monthKey, () => []).add(holiday);
    }

    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => DateFormat('MMMM yyyy')
          .parse(a)
          .compareTo(DateFormat('MMMM yyyy').parse(b)));

    return sortedKeys
        .map((month) => {
      'month': month,
      'holidays': grouped[month]!
        ..sort(
                (a, b) => _parseDate(a.date).compareTo(_parseDate(b.date)))
    })
        .toList();
  }

  DateTime _parseDate(String dateStr) {
    try {
      return DateFormat('yyyy-MM-dd').parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  bool _isUpcomingSoon(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    return difference >= 0 && difference <= 14;
  }

  void _handleStateChanges(BuildContext context, HolidayState state) {
    if (state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage!),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    if (!state.isOperating && state.status == HolidayStatus.success) {
      String message = '';

      // Only compare if _previousHolidayCount has been initialized (>0)
      if (_previousHolidayCount > 0) {
        if (state.holidays.length > _previousHolidayCount) {
          message = 'Holiday added successfully';
          // Clear dismissed holidays on successful add
          _dismissedHolidays.clear();
        } else if (state.holidays.length < _previousHolidayCount) {
          message = 'Holiday deleted successfully';
        } else {
          message = 'Holiday updated successfully';
        }
      }

      _previousHolidayCount = state.holidays.length;

      if (message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<bool> _showDeleteConfirmation(Holiday holiday) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Holiday'),
        content: Text('Are you sure you want to delete "${holiday.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ??
        false;
  }

  void _deleteHoliday(int id) {
    context.read<HolidayBloc>().add(DeleteHoliday(id));
  }

  void _showHolidayDialog(BuildContext context, {Holiday? holiday}) {
    final isEditing = holiday != null;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: holiday?.name ?? '');
    final descriptionController = TextEditingController(text: holiday?.description ?? '');
    DateTime? selectedDate = holiday != null ? _parseDate(holiday.date) : null;
    bool isPublicHoliday = holiday?.isPublicHoliday ?? false;

    // Get the bloc reference before showing dialog
    final holidayBloc = context.read<HolidayBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isEditing ? 'Edit Holiday' : 'Add Holiday'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Holiday Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Please enter a name' : null,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 730)),
                      );
                      if (date != null) {
                        setState(() => selectedDate = date);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Color(0xFF6B7280)),
                          const SizedBox(width: 12),
                          Text(
                            selectedDate != null
                                ? DateFormat('MMM d, yyyy').format(selectedDate!)
                                : 'Select Date',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Public Holiday'),
                    value: isPublicHoliday,
                    onChanged: (value) => setState(() => isPublicHoliday = value ?? false),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate() && selectedDate != null) {
                  final updatedHoliday = Holiday(
                    id: holiday?.id ?? 0,
                    name: nameController.text,
                    date: DateFormat('yyyy-MM-dd').format(selectedDate!),
                    description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
                    isPublicHoliday: isPublicHoliday,
                  );

                  // Use the bloc reference from outside the dialog
                  if (isEditing) {
                    holidayBloc.add(UpdateHoliday(updatedHoliday));
                  } else {
                    holidayBloc.add(AddHoliday(updatedHoliday));
                  }
                  Navigator.of(dialogContext).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }
}