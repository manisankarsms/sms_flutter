import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms/screens/students_screen.dart';

import '../bloc/classes/classes_bloc.dart';
import '../bloc/classes/classes_event.dart';
import '../bloc/classes/classes_state.dart';
import '../bloc/students/students_bloc.dart';
import '../bloc/students/students_event.dart';
import '../models/class.dart';
import '../models/user.dart';
import '../repositories/students_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'class_details_screen.dart';

class ClassesScreen extends StatefulWidget {
  final User user;
  const ClassesScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ClassesScreenState createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    print("ClassesBloc found: ${context.read<ClassesBloc>()}");
  }

  Future<void> _onRefresh() async {
    context.read<ClassesBloc>().add(LoadClasses());
    // Wait for the operation to complete
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.no_classes_found ?? 'No Classes Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first class to get started!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddClassDialog(context),
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context)?.add_class ?? 'Add Class'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
             "Error Loading Classes",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.read<ClassesBloc>().add(LoadClasses()),
            icon: const Icon(Icons.refresh),
            label: Text("Retry"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)?.classes ?? 'Classes'),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _showSearchDialog(context),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => context.read<ClassesBloc>().add(LoadClasses()),
              ),
            ],
          ),
          body: BlocConsumer<ClassesBloc, ClassesState>(
            listener: (context, state) {
              // Handle success and error messages
              if (state.status == ClassesStatus.success && state.message != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message!),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state.status == ClassesStatus.failure && state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error!),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              // Show loading indicator for initial load
              if (state.status == ClassesStatus.loading && state.filteredClasses.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              // Show error state if there's an error and no classes
              if (state.status == ClassesStatus.failure && state.filteredClasses.isEmpty) {
                return _buildErrorState(state.error ?? 'Unknown error occurred');
              }

              // Show empty state if no classes
              if (state.filteredClasses.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: _buildEmptyState(),
                    ),
                  ),
                );
              }

              // Show classes list with refresh capability
              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: Stack(
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.all(10),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: state.filteredClasses.length,
                      itemBuilder: (context, index) {
                        final cls = state.filteredClasses[index];
                        return Opacity(
                          opacity: state.status == ClassesStatus.loading ? 0.6 : 1.0,
                          child: ClassCard(classData: cls, user: widget.user),
                        );
                      },
                    ),
                    // Show loading overlay during operations
                    if (state.status == ClassesStatus.loading && state.filteredClasses.isNotEmpty)
                      Container(
                        color: Colors.black.withOpacity(0.1),
                        child: const Center(
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 12),
                                  Text('Loading...'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          floatingActionButton: BlocBuilder<ClassesBloc, ClassesState>(
            builder: (context, state) {
              // Only show FAB when not in initial loading state
              if (state.status != ClassesStatus.loading || state.filteredClasses.isNotEmpty) {
                return FloatingActionButton(
                  onPressed: () => _showAddClassDialog(context),
                  child: const Icon(Icons.add),
                  tooltip: AppLocalizations.of(context)?.add_class ?? 'Add Class',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)?.search_classes ?? 'Search Classes'),
          content: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)?.search_by_name_or_instructor ?? 'Search by name or instructor',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              context.read<ClassesBloc>().add(SearchClasses(value));
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                _searchController.clear();
                context.read<ClassesBloc>().add(const SearchClasses(''));
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)?.clear ?? 'Clear'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)?.done ?? 'Done'),
            ),
          ],
        );
      },
    );
  }

  void _showAddClassDialog(BuildContext parentContext) {
    final nameController = TextEditingController();
    final sectionController = TextEditingController();
    showDialog(
      context: parentContext,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)?.add_new_class ?? 'Add New Class'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, AppLocalizations.of(context)?.class_name ?? 'Class Name', AppLocalizations.of(context)?.enter_class_name ?? 'Enter class name'),
              const SizedBox(height: 16),
              _buildTextField(sectionController, 'Section Name', 'Enter Section Name'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  final newClass = Class(
                    className: nameController.text.trim(),
                    id: '',
                    sectionName: sectionController.text.trim(),
                    academicYearId: '',
                    academicYearName: '',
                  );

                  parentContext.read<ClassesBloc>().add(AddClass(newClass));
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)?.please_fill_in_required_fields ?? 'Please fill in required fields')),
                  );
                }
              },
              child: Text(AppLocalizations.of(context)?.add ?? 'Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
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
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                classData.className,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: classData.sectionName.isNotEmpty
                  ? Text(
                'Section: ${classData.sectionName}',
                style: TextStyle(color: Colors.grey[600]),
              )
                  : null,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildActionButton(
                  context,
                  icon: Icons.info,
                  label: AppLocalizations.of(context)?.details ?? 'Details',
                  color: Colors.green,
                  onPressed: () => _navigateToClassDetails(context),
                ),
                _buildActionButton(
                  context,
                  icon: Icons.people,
                  label: AppLocalizations.of(context)?.view_students ?? 'View Students',
                  color: Colors.blue,
                  onPressed: () => _navigateToStudents(context),
                ),
                _buildActionButton(
                  context,
                  icon: Icons.delete,
                  label: AppLocalizations.of(context)?.delete ?? 'Delete',
                  color: Colors.red,
                  onPressed: () => _showDeleteConfirmation(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    // Capture the BLoC reference BEFORE showing the dialog
    final classesBloc = context.read<ClassesBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Delete Class"),
        content: Text("Are you sure you want to delete this class?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppLocalizations.of(dialogContext)?.cancel ?? "Cancel"),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              // Use the captured BLoC reference, NOT context.read()
              classesBloc.add(DeleteClass(classData.id));
              Navigator.of(dialogContext).pop();
            },
            child: Text(AppLocalizations.of(dialogContext)?.delete ?? "Delete"),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onPressed,
      }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      label: Text(label, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withOpacity(0.6)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  void _navigateToStudents(BuildContext context) {
    Navigator.of(context, rootNavigator: false).push(
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
    Navigator.of(context, rootNavigator: false).push(
      MaterialPageRoute(
        builder: (context) => ClassDetailsScreen(classData: classData, user: user),
      ),
    );
  }
}