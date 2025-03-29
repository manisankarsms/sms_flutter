import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/new_staff/new_staff_bloc.dart';
import '../bloc/new_staff/new_staff_event.dart';
import '../bloc/new_staff/new_staff_state.dart';
class StaffRegistrationScreen extends StatefulWidget {
  const StaffRegistrationScreen({super.key});

  @override
  State<StaffRegistrationScreen> createState() => _StaffRegistrationScreenState();
}

class _StaffRegistrationScreenState extends State<StaffRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Personal Details Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _nationalityController = TextEditingController();

  // Professional Details Controllers
  final _qualificationController = TextEditingController();
  final _designationController = TextEditingController();
  final _departmentController = TextEditingController();
  final _experienceController = TextEditingController();

  // Contact Details Controllers
  final _primaryMobileController = TextEditingController();
  final _primaryEmailController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();

  // Dropdown values
  String? _selectedGender;
  String? _selectedBloodGroup;
  String? _selectedEmploymentType;
  String? _selectedStaffCategory;

  @override
  void initState() {
    super.initState();
    _nationalityController.text = 'Indian'; // Default nationality
  }

  @override
  void dispose() {
    // Dispose all controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _aadhaarController.dispose();
    _nationalityController.dispose();
    _qualificationController.dispose();
    _designationController.dispose();
    _departmentController.dispose();
    _experienceController.dispose();
    _primaryMobileController.dispose();
    _primaryEmailController.dispose();
    _addressLine1Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 22)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 60)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final staffRegistrationData = {
        'personalDetails': {
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'dateOfBirth': _dobController.text,
          'gender': _selectedGender,
          'bloodGroup': _selectedBloodGroup,
          'aadhaarNumber': _aadhaarController.text,
          'nationality': _nationalityController.text,
        },
        'professionalDetails': {
          'qualification': _qualificationController.text,
          'designation': _designationController.text,
          'department': _departmentController.text,
          'employmentType': _selectedEmploymentType,
          'staffCategory': _selectedStaffCategory,
          'totalExperience': _experienceController.text,
        },
        'contactDetails': {
          'primaryMobile': _primaryMobileController.text,
          'primaryEmail': _primaryEmailController.text,
          'address': {
            'line1': _addressLine1Controller.text,
            'city': _cityController.text,
            'state': _stateController.text,
            'pincode': _pincodeController.text,
          },
        },
      };

      // Dispatch event to the bloc
      context.read<StaffRegistrationBloc>().add(
        SubmitStaffRegistrationEvent(staffRegistrationData),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: BlocListener<StaffRegistrationBloc, StaffRegistrationState>(
        listener: (context, state) {
          if (state is StaffRegistrationSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Staff Registration Successful')),
            );
            // Optionally navigate to another screen
          } else if (state is StaffRegistrationErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Personal Details Card
                _buildPersonalDetailsCard(),

                // Professional Details Card
                _buildProfessionalDetailsCard(),

                // Contact Details Card
                _buildContactDetailsCard(),

                const SizedBox(height: 20),

                // Submit Button
                ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty
                        ? 'Please enter first name'
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty
                        ? 'Please enter last name'
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dobController,
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                    readOnly: true,
                    validator: (value) =>
                    value == null || value.isEmpty
                        ? 'Please select date of birth'
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedGender,
                    items: ['Male', 'Female', 'Other']
                        .map((gender) => DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedGender = value),
                    validator: (value) =>
                    value == null
                        ? 'Please select gender'
                        : null,
                  ),
                ),
              ],
            ),
            // Add more personal details fields as needed
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Professional Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _qualificationController,
                    decoration: const InputDecoration(
                      labelText: 'Highest Qualification',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty
                        ? 'Please enter qualification'
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _designationController,
                    decoration: const InputDecoration(
                      labelText: 'Designation',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty
                        ? 'Please enter designation'
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Employment Type',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedEmploymentType,
                    items: ['Full-Time', 'Part-Time', 'Contract']
                        .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedEmploymentType = value),
                    validator: (value) =>
                    value == null
                        ? 'Please select employment type'
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Staff Category',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedStaffCategory,
                    items: ['Teaching', 'Non-Teaching', 'Administrative']
                        .map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedStaffCategory = value),
                    validator: (value) =>
                    value == null
                        ? 'Please select staff category'
                        : null,
                  ),
                ),
              ],
            ),
            // Add more professional details fields as needed
          ],
        ),
      ),
    );
  }

  Widget _buildContactDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _primaryMobileController,
                    decoration: const InputDecoration(
                      labelText: 'Primary Mobile',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                    value == null || value.isEmpty
                        ? 'Please enter mobile number'
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _primaryEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Primary Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                    value == null || value.isEmpty
                        ? 'Please enter email'
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _addressLine1Controller,
              decoration: const InputDecoration(
                labelText: 'Address Line 1',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
              value == null || value.isEmpty
                  ? 'Please enter address'
                  : null,
            ),
            // Add more contact details fields as needed
          ],
        ),
      ),
    );
  }
}