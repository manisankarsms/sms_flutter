import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/staffs/staff_bloc.dart';
import '../bloc/staffs/staff_event.dart';
import '../bloc/staffs/staff_state.dart';
import '../models/staff.dart';
import '../models/user.dart';

class StaffsScreen extends StatefulWidget {
  @override
  _StaffsScreenState createState() => _StaffsScreenState();
}

class _StaffsScreenState extends State<StaffsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Staffs',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: false, // Ensures the title is left-aligned
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () => _showAddStaffDialog(context),
            tooltip: 'Add New Staff',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search staffs...',
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (query) {
                context.read<StaffsBloc>().add(SearchStaffs(query));
              },
            ),
          ),
        ),
      ),
      body: BlocBuilder<StaffsBloc, StaffsState>(
        builder: (context, state) {
          if (state.status == StaffsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.staff.isEmpty) {
            return const Center(
              child: Text(
                'No staff found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: state.staff.length,
            itemBuilder: (context, index) {
              final staff = state.staff[index];
              return StaffCard(staffData: staff);
            },
          );
        },
      ),
    );
  }

  void _showAddStaffDialog(BuildContext context) {
    final nameController = TextEditingController();
    final roleController = TextEditingController();
    final departmentController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Staff'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, 'Name', 'Enter staff name'),
              _buildTextField(roleController, 'Role', 'Enter role'),
              _buildTextField(departmentController, 'Department', 'Enter department'),
              _buildTextField(phoneController, 'Phone Number', 'Enter phone number'),
              _buildTextField(emailController, 'Email', 'Enter email'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && roleController.text.isNotEmpty) {
                  final newStaff = Staff(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    role: roleController.text,
                    department: departmentController.text,
                    phoneNumber: phoneController.text,
                    email: emailController.text,
                    active: true,
                  );

                  context.read<StaffsBloc>().add(AddStaff(newStaff));
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in required fields')),
                  );
                }
              },
              child: const Text('Add'),
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

class StaffCard extends StatelessWidget {
  final User staffData;

  const StaffCard({super.key, required this.staffData});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        title: Text(
          staffData.firstName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Role: ${staffData.role}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            context.read<StaffsBloc>().add(DeleteStaff(staffData.id));
          },
        ),
      ),
    );
  }
}
