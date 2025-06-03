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

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.grey.shade100,
          body: BlocBuilder<ClassesBloc, ClassesState>(
            builder: (context, state) {
              if (state.status == ClassesStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.filteredClasses.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)?.no_classes_found ?? 'No classes found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => _showAddClassDialog(context),
                        icon: const Icon(Icons.add),
                        label: Text(AppLocalizations.of(context)?.add_class ?? 'Add Class'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: state.filteredClasses.length,
                itemBuilder: (context, index) {
                  final cls = state.filteredClasses[index];
                  return ClassCard(classData: cls, user: widget.user);
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddClassDialog(context),
            child: const Icon(Icons.add),
            tooltip: AppLocalizations.of(context)?.add_class ?? 'Add Class',
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
              border: OutlineInputBorder(),
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

    showDialog(
      context: parentContext,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)?.add_new_class ?? 'Add New Class'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, AppLocalizations.of(context)?.class_name ?? 'Class Name', AppLocalizations.of(context)?.enter_class_name ?? 'Enter class name'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final newClass = Class(
                    name: nameController.text, id: '',
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
        border: OutlineInputBorder(),
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
                classData.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: classData.staff != null
                  ? Text(
                "${AppLocalizations.of(context)?.instructor ?? 'Instructor'}: ${classData.staff!}",
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
                  onPressed: () => context.read<ClassesBloc>().add(DeleteClass(classData.id)),
                ),
              ],
            ),
          ],
        ),
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
            standard: classData.name,
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