import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewStudentScreen extends StatefulWidget {
  const NewStudentScreen({super.key});

  @override
  State<NewStudentScreen> createState() => _NewStudentScreenState();
}

class _NewStudentScreenState extends State<NewStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Student Details Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _motherTongueController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _previousSchoolController = TextEditingController();
  final _bloodGroupController = TextEditingController();

  // Family Details Controllers
  final _fatherNameController = TextEditingController();
  final _fatherEducationController = TextEditingController();
  final _fatherOccupationController = TextEditingController();
  final _fatherAadhaarController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _motherEducationController = TextEditingController();
  final _motherOccupationController = TextEditingController();
  final _motherAadhaarController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _guardianRelationController = TextEditingController();

  // Contact Details Controllers
  final _primaryMobileController = TextEditingController();
  final _alternateMobileController = TextEditingController();
  final _primaryEmailController = TextEditingController();
  final _alternateEmailController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();

  // Dropdown values
  String? _selectedGender;
  String? _selectedClass;
  String? _selectedReligion;
  String? _selectedCommunity;
  String? _selectedBloodGroup;
  String? _selectedIncome;

  // File upload status
  bool _birthCertificateUploaded = false;
  bool _photographUploaded = false;
  bool _fatherEducationProofUploaded = false;
  bool _motherEducationProofUploaded = false;

  @override
  void dispose() {
    // Dispose all controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    // ... dispose all other controllers
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 4)),
      // Default to 4 years ago
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      // 20 years ago
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Divider(thickness: 2),
        ],
      ),
    );
  }

 /* Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = true,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: '$label${isRequired ? '*' : ''}',
          border: const OutlineInputBorder(),
          suffix: suffix,
          filled: true,
        ),
        keyboardType: keyboardType,
        validator: validator ??
            (value) {
              if (isRequired && (value == null || value.isEmpty)) {
                return 'This field is required';
              }
              return null;
            },
        readOnly: readOnly,
        onTap: onTap,
      ),
    );
  }*/

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required String? value,
    required Function(String?) onChanged,
    bool isRequired = true,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: '$label${isRequired ? '*' : ''}',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: isRequired
          ? (value) => value == null || value == '-Select-'
          ? 'Please select $label'
          : null
          : null,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = true,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: '$label${isRequired ? '*' : ''}',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        suffix: suffix,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      keyboardType: keyboardType,
      validator: validator ?? (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        return null;
      },
      readOnly: readOnly,
      onTap: onTap,
    );
  }

  Widget _buildFileUpload({
    required String label,
    required bool isUploaded,
    required Function(bool) onUploadComplete,
    bool isRequired = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text('$label${isRequired ? '*' : ''}'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              // Implement file picker logic here
              // For now, just toggle the status
              onUploadComplete(!isUploaded);
            },
            icon: Icon(isUploaded ? Icons.check : Icons.upload),
            label: Text(isUploaded ? 'Uploaded' : 'Upload'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isUploaded ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveRow(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            // Desktop/Tablet layout
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children.map((child) => Expanded(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: child,
              ))).toList(),
            );
          } else {
            // Mobile layout
            return Column(
              children: children.map((child) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: child,
              )).toList(),
            );
          }
        },
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Student Registration'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Student Basic Details Card
                _buildCard(
                  'Student Basic Details',
                  [
                    _buildResponsiveRow([
                      _buildTextField(
                        controller: _firstNameController,
                        label: 'First Name',
                      ),
                      _buildTextField(
                        controller: _lastNameController,
                        label: 'Last Name',
                      ),
                    ]),
                    _buildResponsiveRow([
                      _buildTextField(
                        controller: _dobController,
                        label: 'Date of Birth',
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        suffix: const Icon(Icons.calendar_today, size: 20),
                      ),
                      _buildDropdown(
                        label: 'Gender',
                        items: const ['-Select-', 'Male', 'Female', 'Other'],
                        value: _selectedGender,
                        onChanged: (value) => setState(() => _selectedGender = value),
                      ),
                      _buildDropdown(
                        label: 'Blood Group',
                        items: const ['-Select-', 'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'],
                        value: _selectedBloodGroup,
                        onChanged: (value) => setState(() => _selectedBloodGroup = value),
                      ),
                    ]),
                  ],
                ),

                // Academic Details Card
                _buildCard(
                  'Academic Details',
                  [
                    _buildResponsiveRow([
                      _buildDropdown(
                        label: 'Class applying for',
                        items: const ['-Select-', 'LKG', 'UKG', 'I', 'II', 'III', 'IV', 'V'],
                        value: _selectedClass,
                        onChanged: (value) => setState(() => _selectedClass = value),
                      ),
                      _buildTextField(
                        controller: _previousSchoolController,
                        label: 'Previous School',
                        isRequired: false,
                      ),
                    ]),
                    _buildResponsiveRow([
                      _buildDropdown(
                        label: 'Religion',
                        items: const ['-Select-', 'Hindu', 'Muslim', 'Christian', 'Others'],
                        value: _selectedReligion,
                        onChanged: (value) => setState(() => _selectedReligion = value),
                      ),
                      _buildDropdown(
                        label: 'Community',
                        items: const ['-Select-', 'General', 'OBC', 'SC', 'ST', 'Others'],
                        value: _selectedCommunity,
                        onChanged: (value) => setState(() => _selectedCommunity = value),
                      ),
                    ]),
                  ],
                ),

                // Personal Details Card
                _buildCard(
                  'Personal Details',
                  [
                    _buildResponsiveRow([
                      _buildTextField(
                        controller: _motherTongueController,
                        label: 'Mother Tongue',
                      ),
                      _buildTextField(
                        controller: _nationalityController,
                        label: 'Nationality',
                      ),
                    ]),
                    _buildResponsiveRow([
                      _buildTextField(
                        controller: _aadhaarController,
                        label: 'Aadhaar Number',
                        keyboardType: TextInputType.number,
                      ),
                    ]),
                    // Document Upload Section with modern design
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Required Documents',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          _buildResponsiveRow([
                            _buildUploadCard(
                              'Birth Certificate',
                              _birthCertificateUploaded,
                                  (value) => setState(() => _birthCertificateUploaded = value),
                            ),
                            _buildUploadCard(
                              'Photograph',
                              _photographUploaded,
                                  (value) => setState(() => _photographUploaded = value),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),

                // Family Details Card
                _buildCard(
                  'Family Details',
                  [
                    // Father's Details
                    Text(
                      'Father\'s Details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildResponsiveRow([
                      _buildTextField(
                        controller: _fatherNameController,
                        label: 'Name',
                      ),
                      _buildTextField(
                        controller: _fatherEducationController,
                        label: 'Education',
                      ),
                    ]),
                    _buildResponsiveRow([
                      _buildTextField(
                        controller: _fatherOccupationController,
                        label: 'Occupation',
                      ),
                      _buildTextField(
                        controller: _fatherAadhaarController,
                        label: 'Aadhaar Number',
                        keyboardType: TextInputType.number,
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // Mother's Details
                    Text(
                      'Mother\'s Details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildResponsiveRow([
                      _buildTextField(
                        controller: _motherNameController,
                        label: 'Name',
                      ),
                      _buildTextField(
                        controller: _motherEducationController,
                        label: 'Education',
                      ),
                    ]),
                    _buildResponsiveRow([
                      _buildTextField(
                        controller: _motherOccupationController,
                        label: 'Occupation',
                      ),
                      _buildTextField(
                        controller: _motherAadhaarController,
                        label: 'Aadhaar Number',
                        keyboardType: TextInputType.number,
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // Guardian's Details
                    Text(
                      'Guardian\'s Details (Optional)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildResponsiveRow([
                      _buildTextField(
                        controller: _guardianNameController,
                        label: 'Name',
                        isRequired: false,
                      ),
                      _buildTextField(
                        controller: _guardianRelationController,
                        label: 'Relation',
                        isRequired: false,
                      ),
                    ]),
                  ],
                ),

                // Contact Details Card
                _buildCard(
                  'Contact Details',
                  [
                    _buildResponsiveRow([
                      _buildTextField(
                        controller: _primaryMobileController,
                        label: 'Primary Mobile',
                        keyboardType: TextInputType.phone,
                      ),
                      _buildTextField(
                        controller: _alternateMobileController,
                        label: 'Alternate Mobile',
                        keyboardType: TextInputType.phone,
                        isRequired: false,
                      ),
                    ]),
                    _buildResponsiveRow([
                      _buildTextField(
                        controller: _primaryEmailController,
                        label: 'Primary Email',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _buildTextField(
                        controller: _alternateEmailController,
                        label: 'Alternate Email',
                        keyboardType: TextInputType.emailAddress,
                        isRequired: false,
                      ),
                    ]),
                    _buildResponsiveRow([
                      _buildTextField(
                        controller: _addressLine1Controller,
                        label: 'Address Line 1',
                      ),
                      _buildTextField(
                        controller: _addressLine2Controller,
                        label: 'Address Line 2',
                        isRequired: false,
                      ),
                    ]),
                    _buildResponsiveRow([
                      _buildTextField(
                        controller: _cityController,
                        label: 'City',
                      ),
                      _buildTextField(
                        controller: _stateController,
                        label: 'State',
                      ),
                      _buildTextField(
                        controller: _pincodeController,
                        label: 'Pincode',
                        keyboardType: TextInputType.number,
                      ),
                    ]),
                  ],
                ),

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Submit Application',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadCard(String title, bool isUploaded, Function(bool) onUploadComplete) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  isUploaded ? Icons.check_circle : Icons.upload_file,
                  color: isUploaded ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  isUploaded ? 'Uploaded' : 'Upload File',
                  style: TextStyle(
                    color: isUploaded ? Colors.green : Colors.grey,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => onUploadComplete(!isUploaded),
                  child: Text(isUploaded ? 'Change' : 'Upload'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // Create a map of all the form data
      final formData = {
        'studentDetails': {
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'gender': _selectedGender,
          'dateOfBirth': _dobController.text,
          'bloodGroup': _selectedBloodGroup,
          'nationality': _nationalityController.text,
          'previousSchool': _previousSchoolController.text,
          'class': _selectedClass,
          'religion': _selectedReligion,
          'community': _selectedCommunity,
          'motherTongue': _motherTongueController.text,
          'aadhaar': _aadhaarController.text,
          'documentsUploaded': {
            'birthCertificate': _birthCertificateUploaded,
            'photograph': _photographUploaded,
          }
        },
        'familyDetails': {
          'father': {
            'name': _fatherNameController.text,
            'education': _fatherEducationController.text,
            'occupation': _fatherOccupationController.text,
            'aadhaar': _fatherAadhaarController.text,
            'educationProofUploaded': _fatherEducationProofUploaded,
          },
          'mother': {
            'name': _motherNameController.text,
            'education': _motherEducationController.text,
            'occupation': _motherOccupationController.text,
            'aadhaar': _motherAadhaarController.text,
            'educationProofUploaded': _motherEducationProofUploaded,
          },
          'guardian': {
            'name': _guardianNameController.text,
            'relation': _guardianRelationController.text,
          },
          'annualIncome': _selectedIncome,
        },
        'contactDetails': {
          'mobile': {
            'primary': _primaryMobileController.text,
            'alternate': _alternateMobileController.text,
          },
          'email': {
            'primary': _primaryEmailController.text,
            'alternate': _alternateEmailController.text,
          },
          'address': {
            'line1': _addressLine1Controller.text,
            'line2': _addressLine2Controller.text,
            'city': _cityController.text,
            'state': _stateController.text,
            'pincode': _pincodeController.text,
          },
        },
      };

      // Show loading indicator
      _showLoadingDialog();

      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        // Hide loading indicator
        Navigator.pop(context);

        // Show success dialog
        _showSuccessDialog();
      });
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content:
              const Text('Student registration form submitted successfully!'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                // Optionally navigate back or to another screen
                // Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Initialize controllers with default values if needed
    _nationalityController.text = 'Indian'; // Default nationality
  }
}
