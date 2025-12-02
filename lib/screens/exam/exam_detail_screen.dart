// lib/screens/exams/exam_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/exam/exam_bloc.dart';
import '../../bloc/exam/exam_event.dart';
import '../../bloc/exam/exam_state.dart';
import '../../models/exams.dart';
import '../../widgets/exam_calendar_view.dart';
import 'exam_form_screen.dart';

class ExamDetailScreen extends StatefulWidget {
  final String examId;

  const ExamDetailScreen({Key? key, required this.examId}) : super(key: key);

  @override
  _ExamDetailScreenState createState() => _ExamDetailScreenState();
}

class _ExamDetailScreenState extends State<ExamDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context.read<ExamBloc>().add(LoadExam(widget.examId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ExamBloc, ExamState>(
        listener: (context, state) {
          if (state is ExamError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is ExamOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            if (state.message.contains('deleted')) {
              Navigator.pop(context);
            }
          }
        },
        builder: (context, state) {
          if (state is ExamLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ExamLoaded) {
            return _buildExamDetails(state.exam);
          } else if (state is ExamError) {
            return _buildErrorState(state.message);
          }
          return const Center(child: Text('No exam details available'));
        },
      ),
    );
  }

  Widget _buildExamDetails(Exam exam) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          _buildSliverAppBar(exam),
          SliverPersistentHeader(
            delegate: _SliverTabBarDelegate(_buildTabBar()),
            pinned: true,
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(exam),
          _buildStudentsTab(exam),
          _buildResultsTab(exam),
          _buildAnalyticsTab(exam),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(Exam exam) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          exam.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(height: 80), // Space for app bar
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.assignment,
                        size: 32,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exam.subjectName ?? 'Subject',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${exam.className ?? 'Class'} - ${exam.sectionName ?? 'Section'}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, exam),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit Exam'),
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
              value: 'publish',
              child: ListTile(
                leading: Icon(Icons.publish),
                title: Text('Publish'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: ListTile(
                leading: Icon(Icons.download),
                title: Text('Export Results'),
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
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: Theme.of(context).colorScheme.primary,
      unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
      indicatorColor: Theme.of(context).colorScheme.primary,
      tabs: const [
        Tab(text: 'Overview', icon: Icon(Icons.info)),
        Tab(text: 'Students', icon: Icon(Icons.people)),
        Tab(text: 'Results', icon: Icon(Icons.grade)),
        Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
      ],
    );
  }

  Widget _buildOverviewTab(Exam exam) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickStatsRow(exam),
          const SizedBox(height: 24),
          _buildExamInfoCard(exam),
          const SizedBox(height: 16),
          _buildScheduleCard(exam),
          const SizedBox(height: 16),
          _buildClassificationCard(exam),
          const SizedBox(height: 16),
          _buildActionsCard(exam),
        ],
      ),
    );
  }

  Widget _buildQuickStatsRow(Exam exam) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Max Marks',
            value: exam.maxMarks.toString(),
            icon: Icons.score,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Students',
            value: '45', // This would come from API
            icon: Icons.people,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Duration',
            value: '2h', // This would come from API
            icon: Icons.timer,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Status',
            value: 'Draft', // This would come from API
            icon: Icons.flag,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamInfoCard(Exam exam) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Exam Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow('Exam Name', exam.name),
            _buildInfoRow('Subject', exam.subjectName ?? 'Not specified'),
            _buildInfoRow('Subject Code', exam.subjectCode ?? 'Not specified'),
            _buildInfoRow('Maximum Marks', '${exam.maxMarks} marks'),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(Exam exam) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Schedule',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow('Exam Date', DateFormat('EEEE, dd MMMM yyyy').format(exam.date)),
            _buildInfoRow('Start Time', DateFormat('hh:mm a').format(exam.date)),
            _buildInfoRow('Duration', '2 hours'), // This would come from API
            _buildInfoRow('End Time', DateFormat('hh:mm a').format(exam.date.add(const Duration(hours: 2)))),
          ],
        ),
      ),
    );
  }

  Widget _buildClassificationCard(Exam exam) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.category,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Classification',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow('Class', exam.className ?? 'Not specified'),
            _buildInfoRow('Section', exam.sectionName ?? 'Not specified'),
            _buildInfoRow('Academic Year', exam.academicYearName ?? 'Not specified'),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard(Exam exam) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildActionChip(
                  label: 'Edit Exam',
                  icon: Icons.edit,
                  onPressed: () => _editExam(exam),
                ),
                _buildActionChip(
                  label: 'Add Questions',
                  icon: Icons.quiz,
                  onPressed: () => _addQuestions(exam),
                ),
                _buildActionChip(
                  label: 'View Results',
                  icon: Icons.grade,
                  onPressed: () => _viewResults(exam),
                ),
                _buildActionChip(
                  label: 'Export Data',
                  icon: Icons.download,
                  onPressed: () => _exportData(exam),
                ),
                _buildActionChip(
                  label: 'Publish',
                  icon: Icons.publish,
                  onPressed: () => _publishExam(exam),
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return ActionChip(
      label: Text(label),
      avatar: Icon(icon, size: 16),
      onPressed: onPressed,
      backgroundColor: color?.withOpacity(0.1),
      labelStyle: TextStyle(color: color),
      side: BorderSide(color: color ?? Theme.of(context).colorScheme.outline),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(':'),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsTab(Exam exam) {
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
                    Icons.people,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Student Management',
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
                    'This section will show enrolled students, their attendance, and performance tracking.',
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

  Widget _buildResultsTab(Exam exam) {
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
                    Icons.grade,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Results & Grading',
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
                    'View exam results, grade distribution, and performance analytics.',
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

  Widget _buildAnalyticsTab(Exam exam) {
    // Get related exams for calendar view (same class/subject)
    final relatedExams = _getRelatedExams(exam);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics Cards
          Row(
            children: [
              Expanded(child: _buildAnalyticsCard('Total Students', '45', Icons.people)),
              const SizedBox(width: 12),
              Expanded(child: _buildAnalyticsCard('Average Score', '78%', Icons.trending_up)),
              const SizedBox(width: 12),
              Expanded(child: _buildAnalyticsCard('Pass Rate', '92%', Icons.check_circle)),
            ],
          ),
          const SizedBox(height: 24),

          // Calendar Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Exam Schedule',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 400, // Fixed height for calendar
                    child: ExamCalendarView(
                      exams: relatedExams,
                      onExamTap: (selectedExam) {
                        // Navigate to exam detail or show quick view
                        _showExamQuickView(selectedExam);
                      },
                      onDateTap: (date) {
                        // Handle date selection
                        _onCalendarDateSelected(date);
                      },
                      onExamEdit: (examToEdit) {
                        // Handle exam editing
                        _editExam(examToEdit);
                      },
                      onExamDelete: (examToDelete) {
                        // Handle exam deletion
                        _confirmDelete(examToDelete);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Performance Chart Placeholder
          const SizedBox(height: 16),
          Card(
            child: Container(
              padding: const EdgeInsets.all(24),
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Performance Analytics',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Detailed performance charts will be available here',
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

  List<Exam> _getRelatedExams(Exam exam) {
    // This would typically come from your repository/BLoC
    // For now, return sample data including the current exam
    final now = DateTime.now();
    return [
      exam, // Include current exam
      // Add related exams (same subject/class)
      Exam(
        id: 'related_1',
        name: 'Unit Test 1',
        date: now.subtract(const Duration(days: 30)),
        subjectId: exam.subjectId,
        subjectName: exam.subjectName,
        classId: exam.classId,
        className: exam.className,
        sectionName: exam.sectionName,
        maxMarks: 50,
      ),
      Exam(
        id: 'related_2',
        name: 'Final Exam',
        date: now.add(const Duration(days: 15)),
        subjectId: exam.subjectId,
        subjectName: exam.subjectName,
        classId: exam.classId,
        className: exam.className,
        sectionName: exam.sectionName,
        maxMarks: 100,
      ),
    ];
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showExamQuickView(Exam selectedExam) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(selectedExam.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subject: ${selectedExam.subjectName ?? "N/A"}'),
            Text('Class: ${selectedExam.className}-${selectedExam.sectionName}'),
            Text('Date: ${DateFormat('MMM dd, yyyy HH:mm').format(selectedExam.date)}'),
            Text('Max Marks: ${selectedExam.maxMarks}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to full exam details
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExamDetailScreen(examId: selectedExam.id!),
                ),
              );
            },
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }

  void _onCalendarDateSelected(DateTime date) {
    // Handle date selection - could show create exam dialog for that date
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: ${DateFormat('MMM dd, yyyy').format(date)}'),
        action: SnackBarAction(
          label: 'CREATE EXAM',
          onPressed: () {
            // Navigate to create exam with pre-selected date
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExamFormScreen(), // Could pre-populate with date
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.read<ExamBloc>().add(LoadExam(widget.examId)),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, Exam exam) {
    switch (action) {
      case 'edit':
        _editExam(exam);
        break;
      case 'duplicate':
        _duplicateExam(exam);
        break;
      case 'publish':
        _publishExam(exam);
        break;
      case 'export':
        _exportData(exam);
        break;
      case 'delete':
        _confirmDelete(exam);
        break;
    }
  }

  void _editExam(Exam exam) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExamFormScreen(exam: exam),
      ),
    );
  }

  void _duplicateExam(Exam exam) {
    final duplicatedExam = Exam(
      name: '${exam.name} (Copy)',
      date: exam.date.add(const Duration(days: 7)),
      subjectId: exam.subjectId,
      classId: exam.classId,
      maxMarks: exam.maxMarks,
      subjectName: exam.subjectName,
      className: exam.className,
      sectionName: exam.sectionName,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExamFormScreen(exam: duplicatedExam),
      ),
    );
  }

  void _publishExam(Exam exam) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Publish Exam'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to publish "${exam.name}"?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Publishing will:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('• Make the exam visible to students'),
                  const Text('• Lock major exam settings'),
                  const Text('• Enable result recording'),
                  const Text('• Send notifications to enrolled students'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Once published, only minor edits will be allowed.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ExamBloc>().add(PublishExam(exam.id!));
            },
            child: const Text('Publish'),
          ),
        ],
      ),
    );
  }

  void _addQuestions(Exam exam) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Question management coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _viewResults(Exam exam) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Results view coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _exportData(Exam exam) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Export as Excel'),
              subtitle: const Text('Download exam data as spreadsheet'),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Excel export coming soon!');
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export as PDF'),
              subtitle: const Text('Generate PDF report'),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('PDF export coming soon!');
              },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Export as CSV'),
              subtitle: const Text('Raw data in CSV format'),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('CSV export coming soon!');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Exam exam) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                  Text('Date: ${DateFormat('dd MMM yyyy').format(exam.date)}'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This action cannot be undone. All related data including questions, results, and analytics will be permanently deleted.',
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ExamBloc>().add(DeleteExam(exam.id!));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

// Custom SliverTabBarDelegate for the tab bar
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => 48.0;

  @override
  double get maxExtent => 48.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}