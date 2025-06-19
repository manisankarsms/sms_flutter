import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms/models/class.dart';
import '../../bloc/exam/exam_bloc.dart';
import '../../bloc/exam/exam_event.dart';
import '../../bloc/exam/exam_state.dart';

class ExamsListScreen extends StatefulWidget {
  const ExamsListScreen({Key? key}) : super(key: key);

  @override
  _ExamsListScreenState createState() => _ExamsListScreenState();
}

class _ExamsListScreenState extends State<ExamsListScreen> {
  String? selectedExamName;
  List<Class> selectedExamClasses = [];
  List<String> examNames = []; // Store exam names locally

  @override
  void initState() {
    super.initState();
    context.read<ExamBloc>().add(LoadExams());
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
        listener: (context, state) {
          if (state is ExamError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ExamNamesLoaded) {
            setState(() {
              examNames = state.examNames;
            });
          } else if (state is ClassesLoaded) {
            setState(() {
              selectedExamName = state.examName;
              selectedExamClasses = state.classes;
            });
          } else if (state is ExamOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ExamLoading && examNames.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else if (examNames.isNotEmpty) {
            if (isWideScreen) {
              return _buildMasterDetailLayout(examNames);
            } else {
              return _buildMobileLayout(examNames);
            }
          } else if (state is ExamError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('No exams available'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateExamSheet,
        child: const Icon(Icons.add),
        tooltip: 'Create new exam',
      ),
    );
  }

  Widget _buildMasterDetailLayout(List<String> examNames) {
    return Row(
      children: [
        // Left Panel - Exams List
        Container(
          width: 350,
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Exams (${examNames.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(child: _buildExamsList(examNames)),
            ],
          ),
        ),
        // Right Panel - Classes List
        Expanded(
          child: _buildClassesPanel(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(List<String> examNames) {
    if (selectedExamName != null && selectedExamClasses.isNotEmpty) {
      return Column(
        children: [
          // Header with back button
          Container(
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
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      selectedExamName = null;
                      selectedExamClasses = [];
                    });
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Classes for "$selectedExamName"',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildClassesList()),
        ],
      );
    }
    return _buildExamsList(examNames);
  }

  Widget _buildExamsList(List<String> examNames) {
    if (examNames.isEmpty) {
      return const Center(child: Text('No exams found'));
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
            onTap: () {
              context.read<ExamBloc>().add(LoadClassesByExamName(examName));
            },
          ),
        );
      },
    );
  }

  Widget _buildClassesPanel() {
    if (selectedExamName == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Select an exam to view classes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
              Expanded(
                child: Text(
                  'Classes for "$selectedExamName"',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (selectedExamClasses.isNotEmpty)
                Chip(
                  label: Text('${selectedExamClasses.length} classes'),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  backgroundColor:
                  Theme.of(context).colorScheme.secondaryContainer,
                ),
            ],
          ),
        ),
        Expanded(child: _buildClassesList()),
      ],
    );
  }

  Widget _buildClassesList() {
    if (selectedExamClasses.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.class_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('No classes found for this exam'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: selectedExamClasses.length,
      itemBuilder: (context, index) {
        final classItem = selectedExamClasses[index];
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                classItem.className.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              '${classItem.className} - ${classItem.sectionName}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text('Section: ${classItem.sectionName}'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Handle class selection - navigate to class details
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Selected: ${classItem.className} - ${classItem.sectionName}',
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showCreateExamSheet() {
    if (kIsWeb && MediaQuery.of(context).size.width > 800) {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: "Right Drawer",
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          return Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.white,
              elevation: 16,
              child: SizedBox(
                width: 400,
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 56.0),
                      child: Placeholder(), // Replace with your ExamFormScreen
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
          final tween = Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          );
          return SlideTransition(
            position: tween.animate(animation),
            child: child,
          );
        },
      );
    } else {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        isScrollControlled: true,
        builder: (_) => const Placeholder(), // Replace with ExamFormScreen
      );
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
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
                  context.read<ExamBloc>().add(LoadExams());
                  setState(() {
                    selectedExamName = null;
                    selectedExamClasses = [];
                    examNames = []; // Clear local state to force reload
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showClassSelectionDialog() {
    final dummyClasses = [
      {'id': 'class1', 'name': 'Class 1'},
      {'id': 'class2', 'name': 'Class 2'},
      {'id': 'class3', 'name': 'Class 3'},
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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
        );
      },
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
      builder: (context) {
        return AlertDialog(
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
        );
      },
    );
  }
}