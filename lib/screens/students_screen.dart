import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:sms/screens/print_preview_screen.dart';
import 'package:sms/utils/constants.dart';
import '../bloc/students/students_bloc.dart';
import '../bloc/students/students_event.dart';
import '../bloc/students/students_state.dart';
import '../models/student.dart';
import 'package:intl/intl.dart';
import '../utils/ExportUtil.dart';

class StudentsScreen extends StatefulWidget {
  final String standard;
  final String classId;
  final String userRole; // "admin" or "staff"

  const StudentsScreen({
    Key? key,
    required this.standard,
    required this.classId,
    required this.userRole,
  }) : super(key: key);

  @override
  _StudentsScreenState createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  DateTime selectedDate = DateTime.now();
  late PlutoGridStateManager _stateManager;
  Map<String, String> attendanceMap = {};
  List<Student> currentStudents = []; // Track current students

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  void _loadStudents() {
    context.read<StudentsBloc>().add(LoadStudents(
        widget.classId,
        widget.userRole,
        DateFormat('yyyy-MM-dd').format(selectedDate)
    ));
  }

  // Initialize attendance map when students are loaded
  void _initializeAttendanceMap(List<Student> students) {
    attendanceMap.clear();
    for (var student in students) {
      // Use the actual attendance status from API, default to 'Absent' if empty
      String? status = student.attendanceStatus;

    // Normalize null and unexpected values first
      if (status == null || status.isEmpty ||
          !['PRESENT', 'ABSENT', 'HALFDAY', 'HALF_DAY'].contains(status.toUpperCase())) {
        status = 'ABSENT';
      }

    // Convert API status format to display format
      switch (status.toUpperCase()) {
        case 'PRESENT':
          status = 'Present';
          break;
        case 'ABSENT':
          status = 'Absent';
          break;
        case 'HALFDAY':
        case 'HALF_DAY':
          status = 'Half-Day';
          break;
        default:
          status = 'Absent';
      }

      attendanceMap[student.studentId] = status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Column(
          children: [
            Text('${widget.standard} Students'),
            Text(
              '${DateFormat('yyyy-MM-dd').format(selectedDate)}',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          if (widget.userRole.toLowerCase() == Constants.admin) ...[
            IconButton(
                icon: const Icon(Icons.print),
                onPressed: () => _printStudentList(context)),
            IconButton(
                icon: const Icon(Icons.download),
                onPressed: () => _showExportOptions(context)),
          ],
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _loadStudents()),
          if (widget.userRole.toLowerCase() == Constants.admin)
            IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddStudentDialog(context)),
          if (widget.userRole.toLowerCase() == Constants.staff) ...[
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () => _pickDate(),
              tooltip: "Select Date",
            ),
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              onPressed: () => _submitAttendance(),
              tooltip: "Submit Attendance",
            ),
            IconButton(
              icon: const Icon(Icons.done_all, color: Colors.blue),
              onPressed: () => _markAllAttendance("Present"),
              tooltip: "Mark All Present",
            ),
            IconButton(
              icon: const Icon(Icons.timelapse, color: Colors.orange),
              onPressed: () => _markAllAttendance("Half-Day"),
              tooltip: "Mark All Half-Day",
            ),
          ],
        ],
      ),
      body: BlocListener<StudentsBloc, StudentsState>(
        listener: (context, state) {
          if (state is AttendanceSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Optionally reload students after successful submission
            _loadStudents();
          } else if (state is AttendanceSubmissionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<StudentsBloc, StudentsState>(
          builder: (context, state) {
            if (state is StudentsLoading || state is AttendanceSubmitting) {
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
                      onPressed: () => _loadStudents(),
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
              // Update current students and initialize attendance map
              currentStudents = state.students;
              _initializeAttendanceMap(state.students);

              return Column(
                children: [
                  if (widget.userRole.toLowerCase() == Constants.staff)
                    _buildAttendanceSummary(),
                  Expanded(
                    child: PlutoGrid(
                      columns: widget.userRole.toLowerCase() == Constants.admin
                          ? _buildAdminGridColumns()
                          : _buildStaffGridColumns(),
                      rows: widget.userRole.toLowerCase() == Constants.admin
                          ? _buildAdminGridRows(state.students)
                          : _buildStaffGridRows(state.students),
                      configuration: const PlutoGridConfiguration(
                        style: PlutoGridStyleConfig(
                          gridBorderColor: Colors.grey,
                          gridBackgroundColor: Colors.white,
                          rowColor: Colors.white,
                          gridBorderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        columnSize: PlutoGridColumnSizeConfig(
                          autoSizeMode: PlutoAutoSizeMode.scale,
                          resizeMode: PlutoResizeMode.pushAndPull,
                        ),
                        scrollbar: PlutoGridScrollbarConfig(
                          isAlwaysShown: true,
                        ),
                      ),
                      onLoaded: (PlutoGridOnLoadedEvent event) {
                        _stateManager = event.stateManager;
                        event.stateManager.setShowColumnFilter(true);
                        event.stateManager.setPageSize(10);
                      },
                      onChanged: (PlutoGridOnChangedEvent event) {
                        if (event.column.field == 'attendance') {
                          final studentId = event.row.cells['id']?.value;
                          final newStatus = event.value;
                          if (studentId != null) {
                            setState(() {
                              attendanceMap[studentId] = newStatus;
                            });
                          }
                        }
                      },
                      createFooter: (stateManager) => PlutoPagination(stateManager),
                      mode: PlutoGridMode.normal,
                    ),
                  )
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // Admin Grid
  List<PlutoColumn> _buildAdminGridColumns() {
    return [
      PlutoColumn(title: 'Name', field: 'name', type: PlutoColumnType.text()),
      PlutoColumn(title: 'Email', field: 'email', type: PlutoColumnType.text()),
      PlutoColumn(title: 'DOB', field: 'dob', type: PlutoColumnType.text()),
      PlutoColumn(title: 'Gender', field: 'gender', type: PlutoColumnType.text()),
      PlutoColumn(title: 'Contact', field: 'contact', type: PlutoColumnType.text()),
      PlutoColumn(
          title: 'Address',
          field: 'address',
          type: PlutoColumnType.text(),
          width: 200),
    ];
  }

  List<PlutoRow> _buildAdminGridRows(List<Student> students) {
    return students
        .map((student) => PlutoRow(cells: {
      'name': PlutoCell(value: '${student.firstName} ${student.lastName}'),
      'email': PlutoCell(value: student.email),
      'dob': PlutoCell(value: student.dateOfBirth),
      'gender': PlutoCell(value: student.gender),
      'contact': PlutoCell(value: student.mobileNumber),
      'address': PlutoCell(value: student.address),
    }))
        .toList();
  }

  // Staff Grid (For Attendance) - FIXED
  List<PlutoColumn> _buildStaffGridColumns() {
    return [
      PlutoColumn(title: 'Student ID', field: 'id', type: PlutoColumnType.text()),
      PlutoColumn(title: 'Name', field: 'name', type: PlutoColumnType.text()),
      PlutoColumn(
        title: 'Attendance',
        field: 'attendance',
        type: PlutoColumnType.select(['Present', 'Half-Day', 'Absent']),
      ),
    ];
  }

  // FIXED: Corrected attendance mapping
  List<PlutoRow> _buildStaffGridRows(List<Student> students) {
    return students
        .map((student) => PlutoRow(cells: {
      'id': PlutoCell(value: student.studentId),
      'name': PlutoCell(value: '${student.firstName} ${student.lastName}'),
      // FIXED: Use attendanceMap[student.studentId] instead of attendanceMap[student.attendanceStatus]
      'attendance': PlutoCell(value: attendanceMap[student.studentId] ?? 'Absent'),
    }))
        .toList();
  }

  // Submit Attendance Data
  void _submitAttendance() {
    if (attendanceMap.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("No attendance data to submit!"),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Submission'),
        content: Text('Submit attendance for ${DateFormat('yyyy-MM-dd').format(selectedDate)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Trigger the attendance submission
              try {
                context.read<StudentsBloc>().add(SubmitAttendance(
                  widget.classId,
                  DateFormat('yyyy-MM-dd').format(selectedDate),
                  attendanceMap,
                ));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error submitting attendance: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Student'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              '${s.firstName} ${s.lastName}',
              s.email,
              s.dateOfBirth,
              s.gender,
              s.mobileNumber,
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
        '${s.firstName} ${s.lastName}',
        s.email,
        s.dateOfBirth,
        s.gender,
        s.mobileNumber,
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

  Widget _buildAttendanceSummary() {
    int presentCount = attendanceMap.values.where((status) => status == "Present").length;
    int halfDayCount = attendanceMap.values.where((status) => status == "Half-Day").length;
    int absentCount = attendanceMap.values.where((status) => status == "Absent").length;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statusChip("Present", presentCount, Colors.green),
          _statusChip("Half-Day", halfDayCount, Colors.orange),
          _statusChip("Absent", absentCount, Colors.red),
        ],
      ),
    );
  }

  Widget _statusChip(String label, int count, Color color) {
    return Chip(
      label: Text("$label: $count"),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }

  void _markAllAttendance(String status) {
    setState(() {
      for (var student in currentStudents) {
        attendanceMap[student.studentId] = status;
      }
    });

    // Update PlutoGrid rows manually
    if (_stateManager != null) {
      for (var row in _stateManager.rows) {
        row.cells['attendance']!.value = status;
      }
      _stateManager.notifyListeners();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("All students marked as $status")),
    );
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        attendanceMap.clear(); // Clear existing attendance data
      });

      _loadStudents(); // Fetch students for the selected date
    }
  }
}