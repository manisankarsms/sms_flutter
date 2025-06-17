import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms/screens/students_marks_screen.dart';
import 'package:sms/screens/students_screen.dart';
import '../bloc/class_details/class_details_bloc.dart';
import '../bloc/classes_staff/staff_classes_bloc.dart';
import '../bloc/classes_staff/staff_classes_event.dart';
import '../bloc/classes_staff/staff_classes_state.dart';
import '../bloc/students/students_bloc.dart';
import '../models/class.dart';
import '../models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../repositories/students_repository.dart';
import '../widgets/section_header.dart';
import 'class_details_screen.dart';

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
    context.read<StaffClassesBloc>().add(LoadStaffClasses(staffId: widget.user.id));
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (context) => _buildMainScreen(context),
      ),
    );
  }

  Widget _buildMainScreen(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(l10n?.classes ?? 'Classes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<StaffClassesBloc>().add(LoadStaffClasses(staffId: widget.user.id)),
          ),
        ],
      ),
      body: BlocConsumer<StaffClassesBloc, StaffClassesState>(
        listener: (context, state) {
          if (state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: state.status == StaffClassesStatus.success ? Colors.green : Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == StaffClassesStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == StaffClassesStatus.failure) {
            return _buildErrorState(state.error ?? 'Unknown error');
          }

          if (state.myClasses.isEmpty && state.teachingClasses.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<StaffClassesBloc>().add(LoadStaffClasses(staffId: widget.user.id));
              await Future.delayed(const Duration(milliseconds: 300));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (state.myClasses.isNotEmpty) ...[
                  const SectionHeader(title: "My Class"),
                  const SizedBox(height: 8),
                  ...state.myClasses.map((classData) => StaffClassCard(
                    classData: classData,
                    user: widget.user,
                    classType: "My Class",
                  )).toList(),
                  const SizedBox(height: 16),
                ],
                if (state.teachingClasses.isNotEmpty) ...[
                  const SectionHeader(title: "Teaching Classes"),
                  const SizedBox(height: 8),
                  ...state.teachingClasses.map((classData) => StaffClassCard(
                    classData: classData,
                    user: widget.user,
                    classType: "Teaching",
                  )).toList(),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context);
    return RefreshIndicator(
      onRefresh: () async {
        context.read<StaffClassesBloc>().add(LoadStaffClasses(staffId: widget.user.id));
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
                l10n?.no_classes_found ?? 'No Classes Found',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'No classes assigned to you yet.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
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
              onPressed: () => context.read<StaffClassesBloc>().add(LoadStaffClasses(staffId: widget.user.id)),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class StaffClassCard extends StatelessWidget {
  final Class classData;
  final User user;
  final String classType;

  const StaffClassCard({
    super.key,
    required this.classData,
    required this.user,
    required this.classType,
  });

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
                if (classType == "Teaching")
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Teaching Class',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue[600],
                        fontWeight: FontWeight.w500,
                      ),
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
              if (classType == "Teaching")
                IconButton(
                  onPressed: () => _navigateToMarks(context),
                  icon: const Icon(Icons.edit_note, size: 20),
                  tooltip: 'Update Marks',
                )
              else
                IconButton(
                  onPressed: () => _navigateToAttendance(context),
                  icon: const Icon(Icons.check_circle_outline, size: 20),
                  tooltip: 'Mark Attendance',
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToMarks(BuildContext context) {
    Navigator.of(context, rootNavigator: false).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => StudentsBloc(
            repository: context.read<StudentsRepository>(),
          ),
          child: StudentsMarksScreen(
            standard: classData.className,
            classId: classData.id,
            subjectId: classData.subjectId!,
            subjectName: classData.subjectName!,
          ),
        ),
      ),
    );
  }

  void _navigateToAttendance(BuildContext context) {
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