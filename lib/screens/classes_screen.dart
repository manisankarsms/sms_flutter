import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms/screens/students_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../bloc/class_details/class_details_bloc.dart';
import '../bloc/classes/classes_bloc.dart';
import '../bloc/classes/classes_event.dart';
import '../bloc/classes/classes_state.dart';
import '../bloc/students/students_bloc.dart';
import '../models/class.dart';
import '../models/user.dart';
import '../repositories/students_repository.dart';
import 'class_details_screen.dart';

class ClassesScreen extends StatefulWidget {
  final User user;
  const ClassesScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(l10n?.classes ?? 'Classes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ClassesBloc>().add(LoadClasses()),
          ),
        ],
      ),
      body: BlocConsumer<ClassesBloc, ClassesState>(
        listener: (context, state) {
          if (state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: state.status == ClassesStatus.success ? Colors.green : Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == ClassesStatus.loading && state.filteredClasses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ClassesStatus.failure && state.filteredClasses.isEmpty) {
            return _buildErrorState(state.error ?? 'Unknown error');
          }

          if (state.filteredClasses.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ClassesBloc>().add(LoadClasses());
              await Future.delayed(const Duration(milliseconds: 300));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.filteredClasses.length,
              itemBuilder: (context, index) => ClassCard(
                classData: state.filteredClasses[index],
                user: widget.user,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddClassDialog,
        child: const Icon(Icons.add),
        tooltip: l10n?.add_class ?? 'Add Class',
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context);
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ClassesBloc>().add(LoadClasses());
        await Future.delayed(const Duration(milliseconds: 300));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 24),
              Text(
                l10n?.no_classes_found ?? 'No Classes Yet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Create your first class to get started!',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _showAddClassDialog,
                icon: const Icon(Icons.add),
                label: Text(l10n?.add_class ?? 'Add Class'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 24),
            Text(
              'Error Loading Classes',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.red[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.read<ClassesBloc>().add(LoadClasses()),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    final l10n = AppLocalizations.of(context);
    // Store reference to the bloc before showing dialog
    final classesBloc = context.read<ClassesBloc>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.search_classes ?? 'Search Classes'),
        content: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n?.search_by_name_or_instructor ?? 'Search by name or instructor',
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) => classesBloc.add(SearchClasses(value)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              classesBloc.add(const SearchClasses(''));
              Navigator.pop(context);
            },
            child: Text(l10n?.clear ?? 'Clear'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n?.done ?? 'Done'),
          ),
        ],
      ),
    );
  }

  void _showAddClassDialog() {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController();
    final sectionController = TextEditingController();
    // Store reference to the bloc before showing dialog
    final classesBloc = context.read<ClassesBloc>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.add_new_class ?? 'Add New Class'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n?.class_name ?? 'Class Name',
                hintText: l10n?.enter_class_name ?? 'Enter class name',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: sectionController,
              decoration: const InputDecoration(
                labelText: 'Section Name',
                hintText: 'Enter Section Name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                // Use the stored bloc reference instead of context.read
                classesBloc.add(
                  AddClass(Class(
                    className: nameController.text.trim(),
                    sectionName: sectionController.text.trim(),
                    id: '',
                    academicYearId: '',
                    academicYearName: '',
                  )),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n?.please_fill_in_required_fields ?? 'Please fill in required fields'),
                  ),
                );
              }
            },
            child: Text(l10n?.add ?? 'Add'),
          ),
        ],
      ),
    );
  }
}

class ClassCard extends StatelessWidget {
  final Class classData;
  final User user;

  const ClassCard({super.key, required this.classData, required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classData.className,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (classData.sectionName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Section: ${classData.sectionName}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ),
              ],
            ),
          ),
          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _navigateToClassDetails(context),
                icon: const Icon(Icons.info_outline, size: 20),
                tooltip: l10n?.details ?? 'Details',
              ),
              IconButton(
                onPressed: () => _navigateToStudents(context),
                icon: const Icon(Icons.people, size: 20),
                tooltip: l10n?.view_students ?? 'Students',
              ),
              IconButton(
                onPressed: () => _showDeleteDialog(context),
                icon: const Icon(Icons.delete_outline, size: 20),
                color: Colors.red[600],
                tooltip: l10n?.delete ?? 'Delete',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final classesBloc = context.read<ClassesBloc>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class'),
        content: Text('Are you sure you want to delete "${classData.className}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              classesBloc.add(DeleteClass(classData.id));
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n?.delete ?? 'Delete'),
          ),
        ],
      ),
    );
  }

  void _navigateToStudents(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => StudentsBloc(
            repository: context.read<StudentsRepository>(),
          ),
          child: StudentsScreen(
            standard: classData.className,
            classId: classData.id,
            userRole: user.role,
          ),
        ),
      ),
    );
  }

  void _navigateToClassDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<ClassDetailsBloc>(),
          child: ClassDetailsScreen(
            classData: classData,
            user: user,
          ),
        ),
      ),
    );
  }
}