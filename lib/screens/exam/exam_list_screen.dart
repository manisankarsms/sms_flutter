// lib/screens/exams/exam_list_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sms/models/class.dart';
import 'package:sms/screens/exam/exam_form_screen.dart';
import 'package:sms/widgets/exam_calendar_view.dart';
import 'exam_detail_screen.dart';
import '../../bloc/exam/exam_bloc.dart';
import '../../bloc/exam/exam_event.dart';
import '../../bloc/exam/exam_state.dart';
import '../../models/exams.dart';

class ExamsListScreen extends StatefulWidget {
  const ExamsListScreen({Key? key}) : super(key: key);

  @override
  _ExamsListScreenState createState() => _ExamsListScreenState();
}

class _ExamsListScreenState extends State<ExamsListScreen>
    with TickerProviderStateMixin {
  String? selectedExamName;
  List<Class> selectedExamClasses = [];
  List<String> examNames = [];
  String? selectedClassId;
  List<dynamic> selectedExamDetails = [];

  // Loading states
  bool isLoadingClasses = false;
  bool isLoadingExamDetails = false;

  // Search and filter states
  String _searchQuery = '';
  String? _filterByClass;
  String? _filterByStatus;

  // Controllers
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  // Tab indices
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
    context.read<ExamBloc>().add(LoadExams());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 800;

    return Scaffold(
      body: Column(
        children: [
          _buildAppBar(context),
          _buildTabBar(),
          Expanded(
            child: BlocConsumer<ExamBloc, ExamState>(
              listener: _handleBlocListener,
              builder: (context, state) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildExamNamesTab(state, isWideScreen),
                    _buildExamDetailsTab(state, isWideScreen),
                    _buildExamCalendarTab(state),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
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
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.assignment,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Exams Management',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Organize and manage exam schedules',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildQuickActions(),
                ],
              ),
              const SizedBox(height: 16),
              _buildSearchAndFilters(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => _refreshData(),
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'export',
              child: ListTile(
                leading: Icon(Icons.download),
                title: Text('Export Exams'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'import',
              child: ListTile(
                leading: Icon(Icons.upload),
                title: Text('Import Exams'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search exams...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                onPressed: _clearSearch,
                icon: const Icon(Icons.clear),
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        _buildFilterChip(
          label: 'Class',
          value: _filterByClass,
          onSelected: _showClassFilter,
        ),
        const SizedBox(width: 8),
        _buildFilterChip(
          label: 'Status',
          value: _filterByStatus,
          onSelected: _showStatusFilter,
        ),
      ],
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

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        indicatorColor: Theme.of(context).colorScheme.primary,
        tabs: const [
          Tab(
            icon: Icon(Icons.list),
            text: 'By Name',
          ),
          Tab(
            icon: Icon(Icons.details),
            text: 'Details',
          ),
          Tab(
            icon: Icon(Icons.calendar_month),
            text: 'Calendar',
          ),
        ],
      ),
    );
  }

  Widget _buildExamNamesTab(ExamState state, bool isWideScreen) {
    if (state is ExamLoading && examNames.isEmpty) {
      return _buildLoader(message: 'Loading exams...');
    }

    if (examNames.isEmpty) {
      return _buildEmptyState(
        icon: Icons.assignment_outlined,
        title: 'No exams available',
        subtitle: 'Create your first exam to get started.',
      );
    }

    return isWideScreen ? _buildMasterDetailLayout() : _buildMobileLayout();
  }

  Widget _buildExamDetailsTab(ExamState state, bool isWideScreen) {
    final filteredExams = _getFilteredExams();

    if (state is ExamLoading) {
      return _buildLoader(message: 'Loading exam details...');
    }

    if (filteredExams.isEmpty) {
      return _buildEmptyState(
        icon: Icons.assignment_outlined,
        title: 'No exam details found',
        subtitle: 'Try adjusting your search or filters.',
      );
    }

    return _buildExamDetailsList(filteredExams, isWideScreen);
  }

  Widget _buildExamCalendarTab(ExamState state) {
    return _buildCalendarView();
  }

  Widget _buildExamDetailsList(List<Exam> exams, bool isWideScreen) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Exam Details',
            count: exams.length,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isWideScreen ? _buildGridView(exams) : _buildListView(exams),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<Exam> exams) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: exams.length,
      itemBuilder: (context, index) => _buildExamCard(exams[index], isGrid: true),
    );
  }

  Widget _buildListView(List<Exam> exams) {
    return ListView.builder(
      itemCount: exams.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: _buildExamCard(exams[index]),
      ),
    );
  }

  Widget _buildCalendarView() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.calendar_month,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Calendar View',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Coming Soon',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Calendar view will show all exams in a monthly calendar format with filtering and scheduling capabilities.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamCard(Exam exam, {bool isGrid = false}) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _viewExamDetails(exam),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.assignment,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exam.name ?? 'Unknown Exam',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (exam.subjectName != null)
                          Text(
                            exam.subjectName!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleExamAction(value, exam),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: ListTile(
                          leading: Icon(Icons.visibility),
                          title: Text('View Details'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Edit'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: ListTile(
                          leading: Icon(Icons.copy),
                          title: Text('Duplicate'),
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

              const SizedBox(height: 16),

              // Details
              if (!isGrid) ...[
                _buildDetailRow('Max Marks', '${exam.maxMarks} marks'),
                _buildDetailRow('Date', _formatDate(exam.date.toString())),
                if (exam.className != null && exam.sectionName != null)
                  _buildDetailRow('Class', '${exam.className}-${exam.sectionName}'),
              ] else ...[
                // Grid view - condensed info
                Row(
                  children: [
                    Icon(Icons.score, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('${exam.maxMarks} marks'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _formatDate(exam.date.toString()),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _viewExamDetails(exam),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _editExam(exam),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced loader widget
  Widget _buildLoader({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Empty state widget
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateExamSheet,
            icon: const Icon(Icons.add),
            label: const Text('Create First Exam'),
          ),
        ],
      ),
    );
  }

  // Enhanced header widget
  Widget _buildSectionHeader({
    required String title,
    int? count,
    VoidCallback? onBack,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (onBack != null) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (count != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count ${count == 1 ? 'exam' : 'exams'}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMasterDetailLayout() {
    return Row(
      children: [
        // Left Panel - Exams List
        Container(
          width: 300,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                title: 'Exams',
                count: examNames.length,
              ),
              Expanded(child: _buildExamsList()),
            ],
          ),
        ),
        // Middle Panel - Classes List
        Container(
          width: 300,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: _buildClassesPanel(),
        ),
        // Right Panel - Exam Details
        Expanded(child: _buildExamDetailsPanel()),
      ],
    );
  }

  Widget _buildMobileLayout() {
    // Show exam details if selected
    if (selectedClassId != null && selectedExamDetails.isNotEmpty) {
      return Column(
        children: [
          _buildSectionHeader(
            title: 'Exam Details',
            onBack: () => setState(() {
              selectedClassId = null;
              selectedExamDetails = [];
            }),
          ),
          Expanded(child: _buildExamDetailsList(selectedExamDetails.cast<Exam>(), false)),
        ],
      );
    }

    // Show classes if exam is selected
    if (selectedExamName != null && selectedExamClasses.isNotEmpty) {
      return Column(
        children: [
          _buildSectionHeader(
            title: 'Classes for "$selectedExamName"',
            count: selectedExamClasses.length,
            onBack: _resetToExamsList,
          ),
          Expanded(child: _buildClassesList()),
        ],
      );
    }

    // Show exams list by default
    return _buildExamsList();
  }

  Widget _buildExamsList() {
    final filteredNames = examNames.where((name) {
      return _searchQuery.isEmpty ||
          name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    if (filteredNames.isEmpty) {
      return _buildEmptyState(
        icon: Icons.assignment_outlined,
        title: 'No exams found',
        subtitle: _searchQuery.isNotEmpty
            ? 'Try a different search term'
            : 'Create your first exam',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      itemCount: filteredNames.length,
      itemBuilder: (context, index) {
        final examName = filteredNames[index];
        final isSelected = selectedExamName == examName;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8.0),
            border: isSelected
                ? Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 1,
            )
                : null,
          ),
          child: ListTile(
            title: Text(
              examName,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : null,
              ),
            ),
            trailing: selectedExamClasses.isNotEmpty && selectedExamName == examName
                ? Badge(
              label: Text('${selectedExamClasses.length}'),
              child: const Icon(Icons.chevron_right),
            )
                : const Icon(Icons.chevron_right),
            onTap: () => _selectExam(examName),
          ),
        );
      },
    );
  }

  Widget _buildClassesPanel() {
    if (selectedExamName == null) {
      return _buildEmptyState(
        icon: Icons.school_outlined,
        title: 'Select an exam to view classes',
      );
    }

    if (isLoadingClasses) {
      return _buildLoader(message: 'Loading classes...');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Classes for "$selectedExamName"',
          count: selectedExamClasses.length,
        ),
        Expanded(child: _buildClassesList()),
      ],
    );
  }

  Widget _buildClassesList() {
    if (selectedExamClasses.isEmpty) {
      return _buildEmptyState(
        icon: Icons.class_outlined,
        title: 'No classes found',
        subtitle: 'There are no classes for this exam.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: selectedExamClasses.length,
      itemBuilder: (context, index) {
        final classItem = selectedExamClasses[index];
        final isSelected = selectedClassId == classItem.id;

        return Card(
          elevation: isSelected ? 3 : 1,
          margin: const EdgeInsets.only(bottom: 8.0),
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                classItem.className.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              '${classItem.className} - ${classItem.sectionName}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : null,
              ),
            ),
            subtitle: Text(
              'Section: ${classItem.sectionName}',
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : null,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _selectClass(classItem),
          ),
        );
      },
    );
  }

  Widget _buildExamDetailsPanel() {
    if (selectedClassId == null) {
      return _buildEmptyState(
        icon: Icons.assignment_outlined,
        title: 'Select a class to view exam details',
      );
    }

    if (isLoadingExamDetails) {
      return _buildLoader(message: 'Loading exam details...');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Exam Details',
          count: selectedExamDetails.length,
        ),
        Expanded(child: _buildExamDetailsList(selectedExamDetails.cast<Exam>(), false)),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _showCreateExamSheet,
      icon: const Icon(Icons.add),
      label: const Text('Create Exam'),
      tooltip: 'Create new exam',
    );
  }

  // Helper methods
  List<Exam> _getFilteredExams() {
    // This would filter selectedExamDetails based on search and filters
    var exams = selectedExamDetails.cast<Exam>();

    if (_searchQuery.isNotEmpty) {
      exams = exams.where((exam) =>
      exam.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (exam.subjectName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }

    return exams;
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _handleBlocListener(BuildContext context, ExamState state) {
    if (state is ExamError) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      _showSnackBar(state.message, isError: true);
    } else if (state is ExamNamesLoaded) {
      setState(() {
        examNames = state.examNames;
      });
    } else if (state is ClassesLoaded) {
      setState(() {
        selectedExamName = state.examName;
        selectedExamClasses = state.classes;
        selectedClassId = null;
        selectedExamDetails = [];
        isLoadingClasses = false;
      });
    } else if (state is ExamsByClassExamNameLoaded) {
      setState(() {
        selectedExamDetails = state.exams;
        isLoadingExamDetails = false;
      });
    } else if (state is ExamOperationSuccess) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      _showSnackBar(state.message);

      if (state.message.contains('deleted')) {
        _resetToExamsList();
        context.read<ExamBloc>().add(LoadExams());
      }
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _showSnackBar('Export functionality coming soon');
        break;
      case 'import':
        _showSnackBar('Import functionality coming soon');
        break;
      case 'settings':
        _showSnackBar('Settings coming soon');
        break;
    }
  }

  void _handleExamAction(String action, Exam exam) {
    switch (action) {
      case 'view':
        _viewExamDetails(exam);
        break;
      case 'edit':
        _editExam(exam);
        break;
      case 'duplicate':
        _duplicateExam(exam);
        break;
      case 'delete':
        _showDeleteConfirmation(exam);
        break;
    }
  }

  void _selectExam(String examName) {
    setState(() {
      selectedClassId = null;
      selectedExamDetails = [];
      isLoadingClasses = true;
    });
    context.read<ExamBloc>().add(LoadClassesByExamName(examName));
  }

  void _selectClass(Class classItem) {
    setState(() {
      selectedClassId = classItem.id;
      isLoadingExamDetails = true;
    });
    context.read<ExamBloc>().add(
      LoadExamsByClassesAndExamsName(selectedExamName!, classItem.id),
    );
  }

  void _resetToExamsList() {
    setState(() {
      selectedExamName = null;
      selectedExamClasses = [];
      selectedClassId = null;
      selectedExamDetails = [];
      isLoadingClasses = false;
      isLoadingExamDetails = false;
    });
  }

  void _refreshData() {
    context.read<ExamBloc>().add(LoadExams());
    _resetToExamsList();
    _showSnackBar('Refreshing data...');
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _clearFilter(String filterType) {
    setState(() {
      if (filterType == 'Class') {
        _filterByClass = null;
      } else if (filterType == 'Status') {
        _filterByStatus = null;
      }
    });
  }

  void _showClassFilter() {
    // Implement class filter dialog
    _showSnackBar('Class filter coming soon');
  }

  void _showStatusFilter() {
    // Implement status filter dialog
    _showSnackBar('Status filter coming soon');
  }

  void _viewExamDetails(Exam exam) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExamDetailScreen(examId: exam.id!),
      ),
    );
  }

  void _editExam(Exam exam) {
    if (kIsWeb && MediaQuery.of(context).size.width > 800) {
      _showEditExamWebDialog(exam);
    } else {
      _showEditExamMobileBottomSheet(exam);
    }
  }

  void _duplicateExam(Exam exam) {
    // Create a copy of the exam
    final duplicatedExam = Exam(
      name: '${exam.name} (Copy)',
      date: exam.date.add(const Duration(days: 7)), // Add a week
      subjectId: exam.subjectId,
      classId: exam.classId,
      maxMarks: exam.maxMarks,
      subjectName: exam.subjectName,
      className: exam.className,
      sectionName: exam.sectionName,
    );

    if (kIsWeb && MediaQuery.of(context).size.width > 800) {
      _showEditExamWebDialog(duplicatedExam);
    } else {
      _showEditExamMobileBottomSheet(duplicatedExam);
    }
  }

  void _showDeleteConfirmation(Exam exam) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Icon(
            Icons.warning_amber_rounded,
            color: Theme.of(context).colorScheme.error,
            size: 48,
          ),
          title: const Text('Delete Exam'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this exam?',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exam: ${exam.name}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (exam.subjectName != null)
                      Text('Subject: ${exam.subjectName}'),
                    if (exam.className != null && exam.sectionName != null)
                      Text('Class: ${exam.className}-${exam.sectionName}'),
                    Text('Date: ${_formatDate(exam.date.toString())}'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This action cannot be undone. All related data will be permanently deleted.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteExam(exam);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteExam(Exam exam) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Deleting exam: ${exam.name}...'),
            ],
          ),
        );
      },
    );

    context.read<ExamBloc>().add(DeleteExam(exam.id!));
  }

  void _showEditExamWebDialog(Exam exam) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Edit Exam",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: 16,
            child: SizedBox(
              width: 500,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 56.0),
                    child: ExamFormScreen(exam: exam),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  void _showEditExamMobileBottomSheet(Exam exam) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) => ExamFormScreen(exam: exam),
    );
  }

  void _showCreateExamSheet() async {
    bool? result;

    if (kIsWeb && MediaQuery.of(context).size.width > 800) {
      result = await _showWebDialog();
    } else {
      result = await _showMobileBottomSheet();
    }

    if (result == true) {
      context.read<ExamBloc>().add(LoadExams());
      _resetToExamsList();
    }
  }

  Future<bool?> _showWebDialog() {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Create Exam",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: 16,
            child: SizedBox(
              width: 500,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 56.0),
                    child: ExamFormScreen(),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(false),
                      tooltip: 'Close',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  Future<bool?> _showMobileBottomSheet() {
    return showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) => const ExamFormScreen(),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}