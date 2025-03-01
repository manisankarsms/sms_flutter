import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:sms/screens/print_preview_screen.dart';
import '../bloc/students/students_bloc.dart';
import '../bloc/students/students_event.dart';
import '../bloc/students/students_state.dart';
import '../models/student.dart';
import '../utils/ExportUtil.dart';

class StudentsScreen extends StatelessWidget {
  final String standard;
  final String classId;

  const StudentsScreen(
      {Key? key, required this.standard, required this.classId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$standard Students'),
        actions: [
          IconButton(
              icon: const Icon(Icons.print),
              onPressed: () => _printStudentList(context)),
          IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => _showExportOptions(context)),
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<StudentsBloc>().add(RefreshStudents(classId));
              }),
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddStudentDialog(context)),
        ],
      ),
      body: BlocBuilder<StudentsBloc, StudentsState>(
        builder: (context, state) {
          if (state is StudentsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StudentsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}',
                      style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<StudentsBloc>().add(LoadStudents(classId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is StudentsLoaded && state.students.isEmpty) {
            return const Center(
                child: Text('No students found',
                    style: TextStyle(fontSize: 18, color: Colors.grey)));
          }

          if (state is StudentsLoaded) {
            return PlutoGrid(
              columns: _buildGridColumns(),
              rows: _buildGridRows(state.students),
              configuration: const PlutoGridConfiguration(
                style: PlutoGridStyleConfig(
                  rowHeight: 60,
                  oddRowColor: Colors.white, // Light grey for odd rows
                  evenRowColor: Colors.white, // White for even rows
                ),
                columnSize: PlutoGridColumnSizeConfig(
                    autoSizeMode: PlutoAutoSizeMode.scale),
              ),
              onLoaded: (event) {
                event.stateManager.setShowColumnFilter(true);
                event.stateManager.setPageSize(10);
              },
              mode: PlutoGridMode.select,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  List<PlutoColumn> _buildGridColumns() {
    return [
      PlutoColumn(
          title: 'Name',
          field: 'name',
          type: PlutoColumnType.text(),
          enableFilterMenuItem: true,
          enableSorting: true),
      PlutoColumn(
          title: 'Email',
          field: 'email',
          type: PlutoColumnType.text(),
          enableFilterMenuItem: true),
      PlutoColumn(
          title: 'DOB',
          field: 'dob',
          type: PlutoColumnType.text(),
          enableSorting: true),
      PlutoColumn(
          title: 'Gender',
          field: 'gender',
          type: PlutoColumnType.text(),
          enableSorting: true),
      PlutoColumn(
          title: 'Contact', field: 'contact', type: PlutoColumnType.text()),
      PlutoColumn(
          title: 'Address',
          field: 'address',
          type: PlutoColumnType.text(),
          width: 200,
          enableColumnDrag: false),
    ];
  }

  List<PlutoRow> _buildGridRows(List<Student> students) {
    return students
        .map((student) => PlutoRow(cells: {
              'name':
                  PlutoCell(value: '${student.firstName} ${student.lastName}'),
              'email': PlutoCell(value: student.email),
              'dob': PlutoCell(value: student.dateOfBirth),
              'gender': PlutoCell(value: student.gender),
              'contact': PlutoCell(value: student.contactNumber),
              'address': PlutoCell(value: student.address),
            }))
        .toList();
  }

  void _showAddStudentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Student'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              TextField(decoration: InputDecoration(labelText: 'Name')),
              TextField(decoration: InputDecoration(labelText: 'Email')),
              TextField(decoration: InputDecoration(labelText: 'DOB')),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(onPressed: () {}, child: const Text('Add')),
          ],
        );
      },
    );
  }

  void _printStudentList(BuildContext context) {
    final bloc = context.read<StudentsBloc>();
    if (bloc.state is StudentsLoaded) {
      final students = (bloc.state as StudentsLoaded).students;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PrintPreviewScreen(
            title: "Student List",
            headers: const [
              'Name',
              'Email',
              'DOB',
              'Gender',
              'Contact',
              'Address'
            ],
            data: students
                .map((s) => [
                      s.firstName + ' ' + s.lastName,
                      s.email,
                      s.dateOfBirth,
                      s.gender,
                      s.contactNumber,
                      s.address
                    ])
                .toList(),
          ),
        ),
      );
    }
  }

  void _showExportOptions(BuildContext context) {
    final bloc = context.read<StudentsBloc>();
    if (bloc.state is StudentsLoaded) {
      final students = (bloc.state as StudentsLoaded).students;
      final headers = ['Name', 'Email', 'DOB', 'Gender', 'Contact', 'Address'];
      final data = students
          .map((s) => [
                s.firstName + ' ' + s.lastName,
                s.email,
                s.dateOfBirth,
                s.gender,
                s.contactNumber,
                s.address
              ])
          .toList();

      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.file_download),
                title: const Text("Export as CSV"),
                onTap: () {
                  ExportUtil.exportToCSV(
                      fileName: 'students', headers: headers, data: data);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("CSV exported successfully!")));
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text("Export as Excel"),
                onTap: () {
                  ExportUtil.exportToExcel(
                      fileName: 'students', headers: headers, data: data);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Excel exported successfully!")));
                },
              ),
            ],
          );
        },
      );
    }
  }
}
