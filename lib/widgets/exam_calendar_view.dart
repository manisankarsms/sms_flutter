// lib/widgets/exam_calendar_view.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/exams.dart';

class ExamCalendarView extends StatefulWidget {
  final List<Exam> exams;
  final Function(Exam) onExamTap;
  final Function(DateTime) onDateTap;
  final Function(Exam) onExamEdit;
  final Function(Exam) onExamDelete;

  const ExamCalendarView({
    Key? key,
    required this.exams,
    required this.onExamTap,
    required this.onDateTap,
    required this.onExamEdit,
    required this.onExamDelete,
  }) : super(key: key);

  @override
  _ExamCalendarViewState createState() => _ExamCalendarViewState();
}

class _ExamCalendarViewState extends State<ExamCalendarView> with TickerProviderStateMixin {
  DateTime _currentDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // View modes
  CalendarView _currentView = CalendarView.month;

  // Filter states
  String? _filterSubject;
  String? _filterClass;
  List<String> _selectedExamTypes = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCalendarHeader(),
        _buildViewToggle(),
        _buildFilters(),
        Expanded(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildCalendarContent(),
          ),
        ),
        _buildSelectedDateDetails(),
      ],
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _previousPeriod,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous ${_currentView.name}',
          ),
          Expanded(
            child: GestureDetector(
              onTap: _showDatePicker,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getHeaderTitle(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _nextPeriod,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next ${_currentView.name}',
          ),
          IconButton(
            onPressed: _goToToday,
            icon: const Icon(Icons.today),
            tooltip: 'Go to Today',
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<CalendarView>(
              segments: const [
                ButtonSegment(
                  value: CalendarView.month,
                  label: Text('Month'),
                  icon: Icon(Icons.calendar_view_month, size: 16),
                ),
                ButtonSegment(
                  value: CalendarView.week,
                  label: Text('Week'),
                  icon: Icon(Icons.calendar_view_week, size: 16),
                ),
                ButtonSegment(
                  value: CalendarView.day,
                  label: Text('Day'),
                  icon: Icon(Icons.calendar_view_day, size: 16),
                ),
              ],
              selected: {_currentView},
              onSelectionChanged: (Set<CalendarView> selection) {
                setState(() {
                  _currentView = selection.first;
                });
                _animationController.reset();
                _animationController.forward();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              label: 'Subject',
              value: _filterSubject,
              onSelected: _showSubjectFilter,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Class',
              value: _filterClass,
              onSelected: _showClassFilter,
            ),
            const SizedBox(width: 8),
            if (_selectedExamTypes.isNotEmpty)
              _buildFilterChip(
                label: 'Types (${_selectedExamTypes.length})',
                value: _selectedExamTypes.join(', '),
                onSelected: _showExamTypeFilter,
              ),
            if (_selectedExamTypes.isEmpty)
              _buildFilterChip(
                label: 'Exam Types',
                value: null,
                onSelected: _showExamTypeFilter,
              ),
            const SizedBox(width: 8),
            if (_hasActiveFilters())
              TextButton.icon(
                onPressed: _clearAllFilters,
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('Clear All'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    String? value,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      label: Text(value ?? label),
      selected: value != null,
      onSelected: (_) => onSelected(),
      avatar: value != null
          ? GestureDetector(
        onTap: () => _clearFilter(label),
        child: const Icon(Icons.close, size: 16),
      )
          : null,
    );
  }

  Widget _buildCalendarContent() {
    switch (_currentView) {
      case CalendarView.month:
        return _buildMonthView();
      case CalendarView.week:
        return _buildWeekView();
      case CalendarView.day:
        return _buildDayView();
    }
  }

  Widget _buildMonthView() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentDate = DateTime(_currentDate.year, _currentDate.month + (index - 500), 1);
        });
      },
      itemBuilder: (context, index) {
        final date = DateTime(_currentDate.year, _currentDate.month + (index - 500), 1);
        return _buildMonthGrid(date);
      },
    );
  }

  Widget _buildMonthGrid(DateTime monthDate) {
    final firstDayOfMonth = DateTime(monthDate.year, monthDate.month, 1);
    final lastDayOfMonth = DateTime(monthDate.year, monthDate.month + 1, 0);
    final firstDayOfWeek = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday - 1));
    final lastDayOfWeek = lastDayOfMonth.add(Duration(days: 7 - lastDayOfMonth.weekday));

    final days = <DateTime>[];
    for (DateTime date = firstDayOfWeek; date.isBefore(lastDayOfWeek.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
      days.add(date);
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildWeekdayHeader(),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.0,
              ),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final date = days[index];
                final isCurrentMonth = date.month == monthDate.month;
                final isToday = _isSameDay(date, DateTime.now());
                final isSelected = _isSameDay(date, _selectedDate);
                final dayExams = _getExamsForDate(date);

                return _buildDayCell(
                  date: date,
                  isCurrentMonth: isCurrentMonth,
                  isToday: isToday,
                  isSelected: isSelected,
                  exams: dayExams,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekView() {
    final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    final weekDays = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildWeekdayHeader(),
          Expanded(
            child: Row(
              children: weekDays.map((date) {
                final isToday = _isSameDay(date, DateTime.now());
                final isSelected = _isSameDay(date, _selectedDate);
                final dayExams = _getExamsForDate(date);

                return Expanded(
                  child: _buildWeekDayColumn(
                    date: date,
                    isToday: isToday,
                    isSelected: isSelected,
                    exams: dayExams,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayView() {
    final dayExams = _getExamsForDate(_selectedDate);

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE').format(_selectedDate),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      DateFormat('MMMM dd, yyyy').format(_selectedDate),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${dayExams.length} ${dayExams.length == 1 ? 'Exam' : 'Exams'}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: dayExams.isEmpty
                ? _buildNoExamsState()
                : _buildDayExamsList(dayExams),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Container(
      height: 40,
      child: Row(
        children: weekdays.map((day) => Expanded(
          child: Center(
            child: Text(
              day,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildDayCell({
    required DateTime date,
    required bool isCurrentMonth,
    required bool isToday,
    required bool isSelected,
    required List<Exam> exams,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
        widget.onDateTap(date);
      },
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : isToday
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
          borderRadius: BorderRadius.circular(8),
          border: isToday && !isSelected
              ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
              : null,
        ),
        child: Column(
          children: [
            Container(
              height: 32,
              child: Center(
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: !isCurrentMonth
                        ? Theme.of(context).colorScheme.outline
                        : isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : isToday
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                child: Column(
                  children: [
                    ...exams.take(2).map((exam) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: _getExamColor(exam).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        exam.name.length > 8 ? '${exam.name.substring(0, 8)}...' : exam.name,
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )),
                    if (exams.length > 2)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          '+${exams.length - 2} more',
                          style: TextStyle(
                            fontSize: 8,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekDayColumn({
    required DateTime date,
    required bool isToday,
    required bool isSelected,
    required List<Exam> exams,
  }) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
        borderRadius: BorderRadius.circular(8),
        border: isToday
            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
            : null,
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
              widget.onDateTap(date);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Text(
                    DateFormat('E').format(date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${date.day}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isToday
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: exams.map((exam) => _buildWeekExamCard(exam)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekExamCard(Exam exam) {
    return GestureDetector(
      onTap: () => widget.onExamTap(exam),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getExamColor(exam),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exam.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            if (exam.subjectName != null)
              Text(
                exam.subjectName!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayExamsList(List<Exam> exams) {
    // Sort exams by time
    final sortedExams = List<Exam>.from(exams)
      ..sort((a, b) => a.date.compareTo(b.date));

    return ListView.builder(
      itemCount: sortedExams.length,
      itemBuilder: (context, index) {
        final exam = sortedExams[index];
        return _buildDetailedExamCard(exam);
      },
    );
  }

  Widget _buildDetailedExamCard(Exam exam) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => widget.onExamTap(exam),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(
                color: _getExamColor(exam),
                width: 4,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getExamColor(exam).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.assignment,
                      color: _getExamColor(exam),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exam.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (exam.subjectName != null)
                          Text(
                            exam.subjectName!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleExamAction(value, exam),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Edit'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Delete', style: TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.schedule,
                    label: DateFormat('HH:mm').format(exam.date),
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    icon: Icons.score,
                    label: '${exam.maxMarks} marks',
                  ),
                  const SizedBox(width: 8),
                  if (exam.className != null && exam.sectionName != null)
                    _buildInfoChip(
                      icon: Icons.class_,
                      label: '${exam.className}-${exam.sectionName}',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoExamsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No Exams Scheduled',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No exams are scheduled for ${DateFormat('MMMM dd, yyyy').format(_selectedDate)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDateDetails() {
    final selectedDateExams = _getExamsForDate(_selectedDate);

    if (selectedDateExams.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Exams on ${DateFormat('MMM dd').format(_selectedDate)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${selectedDateExams.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: selectedDateExams.map((exam) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => widget.onExamTap(exam),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _getExamColor(exam),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            exam.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          if (exam.subjectName != null) ...[
                            const SizedBox(width: 4),
                            Text(
                              '• ${exam.subjectName}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  List<Exam> _getExamsForDate(DateTime date) {
    return widget.exams.where((exam) {
      if (!_isSameDay(exam.date, date)) return false;

      // Apply filters
      if (_filterSubject != null && exam.subjectName != _filterSubject) return false;
      if (_filterClass != null && '${exam.className}-${exam.sectionName}' != _filterClass) return false;
      if (_selectedExamTypes.isNotEmpty && !_selectedExamTypes.contains(exam.name)) return false;

      return true;
    }).toList();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Color _getExamColor(Exam exam) {
    // Generate color based on subject or exam type
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];

    final index = (exam.subjectName?.hashCode ?? exam.name.hashCode) % colors.length;
    return colors[index.abs()];
  }

  String _getHeaderTitle() {
    switch (_currentView) {
      case CalendarView.month:
        return DateFormat('MMMM yyyy').format(_currentDate);
      case CalendarView.week:
        final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        if (startOfWeek.month == endOfWeek.month) {
          return '${DateFormat('MMM dd').format(startOfWeek)} - ${DateFormat('dd, yyyy').format(endOfWeek)}';
        } else {
          return '${DateFormat('MMM dd').format(startOfWeek)} - ${DateFormat('MMM dd, yyyy').format(endOfWeek)}';
        }
      case CalendarView.day:
        return DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate);
    }
  }

  void _previousPeriod() {
    setState(() {
      switch (_currentView) {
        case CalendarView.month:
          _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
          break;
        case CalendarView.week:
          _selectedDate = _selectedDate.subtract(const Duration(days: 7));
          break;
        case CalendarView.day:
          _selectedDate = _selectedDate.subtract(const Duration(days: 1));
          break;
      }
    });
    _animationController.reset();
    _animationController.forward();
  }

  void _nextPeriod() {
    setState(() {
      switch (_currentView) {
        case CalendarView.month:
          _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
          break;
        case CalendarView.week:
          _selectedDate = _selectedDate.add(const Duration(days: 7));
          break;
        case CalendarView.day:
          _selectedDate = _selectedDate.add(const Duration(days: 1));
          break;
      }
    });
    _animationController.reset();
    _animationController.forward();
  }

  void _goToToday() {
    setState(() {
      _currentDate = DateTime.now();
      _selectedDate = DateTime.now();
    });
    _animationController.reset();
    _animationController.forward();
  }

  void _showDatePicker() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        _currentDate = selectedDate;
        _selectedDate = selectedDate;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _showSubjectFilter() {
    final subjects = widget.exams
        .map((e) => e.subjectName)
        .where((s) => s != null)
        .cast<String>()
        .toSet()
        .toList()
      ..sort();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Subject'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: const Text('All Subjects'),
                leading: Radio<String?>(
                  value: null,
                  groupValue: _filterSubject,
                  onChanged: (value) {
                    setState(() => _filterSubject = value);
                    Navigator.pop(context);
                  },
                ),
              ),
              ...subjects.map((subject) => ListTile(
                title: Text(subject),
                leading: Radio<String?>(
                  value: subject,
                  groupValue: _filterSubject,
                  onChanged: (value) {
                    setState(() => _filterSubject = value);
                    Navigator.pop(context);
                  },
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _showClassFilter() {
    final classes = widget.exams
        .where((e) => e.className != null && e.sectionName != null)
        .map((e) => '${e.className}-${e.sectionName}')
        .toSet()
        .toList()
      ..sort();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Class'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: const Text('All Classes'),
                leading: Radio<String?>(
                  value: null,
                  groupValue: _filterClass,
                  onChanged: (value) {
                    setState(() => _filterClass = value);
                    Navigator.pop(context);
                  },
                ),
              ),
              ...classes.map((className) => ListTile(
                title: Text(className),
                leading: Radio<String?>(
                  value: className,
                  groupValue: _filterClass,
                  onChanged: (value) {
                    setState(() => _filterClass = value);
                    Navigator.pop(context);
                  },
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _showExamTypeFilter() {
    final examTypes = widget.exams
        .map((e) => e.name)
        .toSet()
        .toList()
      ..sort();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Exam Type'),
        content: SizedBox(
          width: double.maxFinite,
          child: StatefulBuilder(
            builder: (context, setStateDialog) => ListView(
              shrinkWrap: true,
              children: examTypes.map((examType) => CheckboxListTile(
                title: Text(examType),
                value: _selectedExamTypes.contains(examType),
                onChanged: (selected) {
                  setStateDialog(() {
                    if (selected == true) {
                      _selectedExamTypes.add(examType);
                    } else {
                      _selectedExamTypes.remove(examType);
                    }
                  });
                },
              )).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _selectedExamTypes.clear());
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {}); // Trigger rebuild with new filters
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _clearFilter(String filterType) {
    setState(() {
      switch (filterType) {
        case 'Subject':
          _filterSubject = null;
          break;
        case 'Class':
          _filterClass = null;
          break;
        case 'Types':
        case 'Exam Types':
          _selectedExamTypes.clear();
          break;
      }
    });
  }

  void _clearAllFilters() {
    setState(() {
      _filterSubject = null;
      _filterClass = null;
      _selectedExamTypes.clear();
    });
  }

  bool _hasActiveFilters() {
    return _filterSubject != null ||
        _filterClass != null ||
        _selectedExamTypes.isNotEmpty;
  }

  void _handleExamAction(String action, Exam exam) {
    switch (action) {
      case 'edit':
        widget.onExamEdit(exam);
        break;
      case 'delete':
        widget.onExamDelete(exam);
        break;
    }
  }
}

// Enum for calendar view types
enum CalendarView { month, week, day }