import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms/models/class.dart';
import 'package:sms/screens/exam/exam_form_screen.dart';
import '../../bloc/exam/exam_bloc.dart';
import '../../bloc/exam/exam_event.dart';
import '../../bloc/exam/exam_state.dart';
import '../../models/exams.dart';

class ExamsListScreen extends StatefulWidget {
  const ExamsListScreen({Key? key}) : super(key: key);

  @override
  _ExamsListScreenState createState() => _ExamsListScreenState();
}

class _ExamsListScreenState extends State<ExamsListScreen> {
  String? selectedExamName;
  List<Class> selectedExamClasses = [];
  List<String> examNames = [];
  String? selectedClassId;
  List<dynamic> selectedExamDetails = [];

  // Loading states
  bool isLoadingClasses = false;
  bool isLoadingExamDetails = false;

  @override
  void initState() {
    super.initState();
    context.read<ExamBloc>().add(LoadExams());
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
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
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
            Chip(
              label: Text('$count ${count == 1 ? 'item' : 'items'}'),
              labelStyle: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            ),
        ],
      ),
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
        Expanded(child: _buildExamDetailsList()),
      ],
    );
  }

  Widget _buildExamDetailsList() {
    if (selectedExamDetails.isEmpty) {
      return _buildEmptyState(
        icon: Icons.assignment_outlined,
        title: 'No exam details found',
        subtitle: 'There are no exams for the selected class.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: selectedExamDetails.length,
      itemBuilder: (context, index) {
        final exam = selectedExamDetails[index];
        return _buildExamCard(exam);
      },
    );
  }

  Widget _buildExamCard(Exam exam) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with exam name and subject
            Row(
              children: [
                Icon(
                  Icons.assignment,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
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
                // Max marks badge
                if (exam.maxMarks != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${exam.maxMarks} marks',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Exam details
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                if (exam.date != null)
                  _buildDetailChip(
                    icon: Icons.calendar_today,
                    label: _formatDate(exam.date.toString()),
                  ),
                if (exam.className != null && exam.sectionName != null)
                  _buildDetailChip(
                    icon: Icons.class_,
                    label: 'Class ${exam.className}-${exam.sectionName}',
                  ),
                if (exam.subjectCode != null)
                  _buildDetailChip(
                    icon: Icons.code,
                    label: exam.subjectCode!,
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showSnackBar('View exam details'),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View Details'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _editExam(exam),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showDeleteConfirmation(exam),
                  icon: const Icon(Icons.delete),
                  color: Theme.of(context).colorScheme.error,
                  tooltip: 'Delete Exam',
                ),
              ],
            ),
          ],
        ),
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
                      'Exam: ${exam.name ?? 'Unknown'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (exam.subjectName != null)
                      Text('Subject: ${exam.subjectName}'),
                    if (exam.className != null && exam.sectionName != null)
                      Text('Class: ${exam.className}-${exam.sectionName}'),
                    if (exam.date != null)
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
    // Show loading indicator
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

    // Trigger delete event
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
              width: 400,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 56.0),
                    child: ExamFormScreen(exam: exam), // Pass the exam for editing
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
      builder: (_) => ExamFormScreen(exam: exam), // Pass the exam for editing
    );
  }

  Widget _buildDetailChip({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
      ],
    );
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
      return dateString; // Return original string if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exams'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: BlocConsumer<ExamBloc, ExamState>(
        listener: _handleBlocListener,
        builder: (context, state) {
          if (state is ExamLoading && examNames.isEmpty) {
            return _buildLoader(message: 'Loading exams...');
          }

          if (examNames.isNotEmpty) {
            return isWideScreen
                ? _buildMasterDetailLayout()
                : _buildMobileLayout();
          }

          if (state is ExamError) {
            return _buildErrorState(state.message);
          }

          return _buildEmptyState(
            icon: Icons.assignment_outlined,
            title: 'No exams available',
            subtitle: 'Create your first exam to get started.',
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateExamSheet,
        tooltip: 'Create new exam',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _handleBlocListener(BuildContext context, ExamState state) {
    if (state is ExamError) {
      // Close any loading dialogs
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
      // Close any loading dialogs
      Navigator.of(context).popUntil((route) => route.isFirst);
      _showSnackBar(state.message);

      // Refresh the exam list after successful operations
      if (state.message.contains('deleted')) {
        // Reset the view and reload exams
        _resetToExamsList();
        context.read<ExamBloc>().add(LoadExams());
      }
    }
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
            onPressed: () => context.read<ExamBloc>().add(LoadExams()),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
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
          Expanded(child: _buildExamDetailsList()),
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
    if (examNames.isEmpty) {
      return _buildEmptyState(
        icon: Icons.assignment_outlined,
        title: 'No exams found',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      itemCount: examNames.length,
      itemBuilder: (context, index) {
        final examName = examNames[index];
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

  // Simplified action methods
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

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : null,
      ),
    );
  }

  void _showCreateExamSheet() async {
    bool? result;

    if (kIsWeb && MediaQuery.of(context).size.width > 800) {
      result = await _showWebDialog();
    } else {
      result = await _showMobileBottomSheet();
    }

    // Refresh the exam list if operation was successful
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
              width: 400,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 56.0),
                    child: ExamFormScreen(), // No exam parameter = create mode
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
      builder: (_) => const ExamFormScreen(), // No exam parameter = create mode
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildFilterOptions(),
    );
  }

  Widget _buildFilterOptions() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Filter Exams',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.class_),
            title: const Text('Filter by Class'),
            onTap: () {
              Navigator.pop(context);
              _showClassSelectionDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.subject),
            title: const Text('Filter by Subject'),
            onTap: () {
              Navigator.pop(context);
              _showSubjectSelectionDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.clear_all),
            title: const Text('Clear Filters'),
            onTap: () {
              Navigator.pop(context);
              _clearFilters();
            },
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    context.read<ExamBloc>().add(LoadExams());
    _resetToExamsList();
    setState(() {
      examNames = [];
    });
  }

  void _showClassSelectionDialog() {
    final dummyClasses = [
      {'id': 'class1', 'name': 'Class 1'},
      {'id': 'class2', 'name': 'Class 2'},
      {'id': 'class3', 'name': 'Class 3'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Class'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: dummyClasses.length,
            itemBuilder: (context, index) {
              final classItem = dummyClasses[index];
              return ListTile(
                title: Text(classItem['name']!),
                onTap: () {
                  Navigator.pop(context);
                  context.read<ExamBloc>().add(
                    LoadExamsByClass(classItem['id']!),
                  );
                },
              );
            },
          ),
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

  void _showSubjectSelectionDialog() {
    final dummySubjects = [
      {'id': 'subject1', 'name': 'Mathematics'},
      {'id': 'subject2', 'name': 'Science'},
      {'id': 'subject3', 'name': 'English'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Subject'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: dummySubjects.length,
            itemBuilder: (context, index) {
              final subject = dummySubjects[index];
              return ListTile(
                title: Text(subject['name']!),
                onTap: () {
                  Navigator.pop(context);
                  context.read<ExamBloc>().add(
                    LoadExamsBySubject(subject['id']!),
                  );
                },
              );
            },
          ),
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
}