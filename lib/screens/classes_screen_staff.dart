import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms/screens/students_marks_screen.dart';
import '../bloc/classes_staff/staff_classes_bloc.dart';
import '../bloc/classes_staff/staff_classes_event.dart';
import '../bloc/classes_staff/staff_classes_state.dart';
import '../bloc/students/students_bloc.dart';
import '../models/class.dart';
import '../models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../repositories/students_repository.dart';
import '../widgets/section_header.dart';

class ClassesScreenStaff extends StatefulWidget {
  final User user;

  const ClassesScreenStaff({Key? key, required this.user}) : super(key: key);

  @override
  State<ClassesScreenStaff> createState() => _ClassesScreenStaffState();
}

class _ClassesScreenStaffState extends State<ClassesScreenStaff> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    context
        .read<StaffClassesBloc>()
        .add(LoadStaffClasses(staffId: widget.user.id));
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
        key: _navigatorKey,
        onGenerateRoute: (settings) => MaterialPageRoute(
            builder: (context) => Scaffold(
                  backgroundColor: Colors.grey.shade100,
                  body: BlocBuilder<StaffClassesBloc, StaffClassesState>(
                    builder: (context, state) {
                      if (state.status == StaffClassesStatus.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state.myClasses.isEmpty &&
                          state.teachingClasses.isEmpty) {
                        return Center(
                          child: Text(
                              AppLocalizations.of(context)?.no_classes_found ??
                                  'No classes found'),
                        );
                      }

                      return ListView(
                        padding: const EdgeInsets.all(10),
                        children: [
                          if (state.myClasses.isNotEmpty) ...[
                            const SectionHeader(title: "MyClass"),
                            ContentBasedClassGrid(
                                classes: state.myClasses, user: widget.user),
                          ],
                          if (state.teachingClasses.isNotEmpty) ...[
                            const SectionHeader(title: "Teaching Classes"),
                            ContentBasedClassGrid(
                                classes: state.teachingClasses,
                                user: widget.user),
                          ],
                        ],
                      );
                    },
                  ),
                )
        )
    );
  }
}

class ContentBasedClassGrid extends StatelessWidget {
  final List<Class> classes;
  final User user;

  const ContentBasedClassGrid({
    super.key,
    required this.classes,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Dynamic crossAxisCount based on screen width
    int crossAxisCount;
    if (kIsWeb) {
      crossAxisCount = (screenWidth ~/ 400).clamp(1, 4); // Wider cards for web
    } else if (screenWidth > 600) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1; // Single column for small screens
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: classes.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: screenWidth > 600 ? 2.8 : 2.3, // Slightly wider cards
      ),
      itemBuilder: (context, index) {
        return ContentSizedClassCard(
          classData: classes[index],
          user: user,
        );
      },
    );
  }
}

class ContentSizedClassCard extends StatelessWidget {
  final Class classData;
  final User user;

  const ContentSizedClassCard({
    super.key,
    required this.classData,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Color accent on left side
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 8,
            child: Container(
              color: colorScheme.primary,
            ),
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Class header row with name and icon
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: colorScheme.primaryContainer,
                      radius: 18,
                      child: Icon(
                        Icons.school,
                        color: colorScheme.onPrimaryContainer,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            classData.name ?? 'Unnamed Class',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (classData.staff != null &&
                              classData.staff!.isNotEmpty)
                            Text(
                              classData.staff!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Additional class info (can add more details here)
                /*if (classData.description != null && classData.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      classData.description!,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),*/

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildActionButton(
                      context,
                      label: 'Details',
                      icon: Icons.info_outline,
                      onPressed: () {
                        // Navigate to details page
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      context,
                      label: 'Update Marks',
                      icon: Icons.edit_note,
                      primary: true,
                      onPressed: () {
                        // Navigate to marks update page
                        _navigateToStudents(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool primary = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 18,
      ),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: primary ? colorScheme.primary : Colors.transparent,
        foregroundColor: primary ? colorScheme.onPrimary : colorScheme.primary,
        elevation: primary ? 1 : 0,
        side: primary ? null : BorderSide(color: colorScheme.primary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
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
          child: StudentsMarksScreen(
            standard: classData.name,
            classId: classData.id,
            subjectId: classData.subjectId!,
            subjectName: classData.subjectName!,
          ),
        ),
      ),
    );
  }
}
