import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sms/widgets/section_header.dart';

import '../bloc/configuration/configuration_bloc.dart';
import '../bloc/configuration/configuration_event.dart';
import '../bloc/configuration/configuration_state.dart';
import '../models/configuration.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({Key? key}) : super(key: key);

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _schoolNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumber1Controller = TextEditingController();
  final _phoneNumber2Controller = TextEditingController();
  final _phoneNumber3Controller = TextEditingController();
  final _phoneNumber4Controller = TextEditingController();
  final _phoneNumber5Controller = TextEditingController();
  final _websiteController = TextEditingController();

  File? _pickedLogoFile;
  XFile? _pickedLogoXFile; // For web support
  String? _existingLogoUrl;
  String? _uploadedLogoUrl; // New logo URL from upload
  int? _configId;
  bool _isLoading = false;
  bool _isLogoUploading = false;

  // You'll need to get this from your authentication system
  String get userId => "user123"; // Replace with actual user ID logic

  @override
  void initState() {
    super.initState();
    context.read<ConfigurationBloc>().add(LoadConfiguration());
  }

  @override
  void dispose() {
    _schoolNameController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneNumber1Controller.dispose();
    _phoneNumber2Controller.dispose();
    _phoneNumber3Controller.dispose();
    _phoneNumber4Controller.dispose();
    _phoneNumber5Controller.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    setState(() => _isLoading = true);

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        setState(() {
          if (kIsWeb) {
            _pickedLogoXFile = pickedFile;
            _pickedLogoFile = null;
          } else {
            _pickedLogoFile = File(pickedFile.path);
            _pickedLogoXFile = null;
          }
        });

        // Automatically upload the logo after selection
        await _uploadLogo();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error picking image: $e"),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _uploadLogo() async {
    if (_pickedLogoFile == null && _pickedLogoXFile == null) return;

    context.read<ConfigurationBloc>().add(
      UploadLogo(
        userId: userId,
        logoFile: _pickedLogoFile,
        logoXFile: _pickedLogoXFile,
      ),
    );
  }

  void _onSavePressed() {
    if (_formKey.currentState!.validate()) {
      final updated = Configuration(
        id: _configId ?? 1,
        schoolName: _schoolNameController.text.trim(),
        logoUrl: _uploadedLogoUrl ?? _existingLogoUrl, // Use uploaded URL if available
        address: _addressController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        phoneNumber1: _phoneNumber1Controller.text.trim().isEmpty ? null : _phoneNumber1Controller.text.trim(),
        phoneNumber2: _phoneNumber2Controller.text.trim().isEmpty ? null : _phoneNumber2Controller.text.trim(),
        phoneNumber3: _phoneNumber3Controller.text.trim().isEmpty ? null : _phoneNumber3Controller.text.trim(),
        phoneNumber4: _phoneNumber4Controller.text.trim().isEmpty ? null : _phoneNumber4Controller.text.trim(),
        phoneNumber5: _phoneNumber5Controller.text.trim().isEmpty ? null : _phoneNumber5Controller.text.trim(),
        website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
      );

      // Always use UpdateConfiguration since logo is already uploaded and saved
      context.read<ConfigurationBloc>().add(UpdateConfiguration(updated));
    }
  }

  Widget _buildLogoPreview() {
    if (_isLoading || _isLogoUploading) {
      return Container(
        width: 100,
        height: 100,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey,
        ),
        child: const CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 3,
        ),
      );
    }

    // Show uploaded logo first (highest priority)
    if (_uploadedLogoUrl != null && _uploadedLogoUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: _uploadedLogoUrl!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
            ),
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
          errorWidget: (context, url, error) => const CircleAvatar(
            radius: 50,
            child: Icon(Icons.school, size: 50),
          ),
        ),
      );
    }

    // Show selected file (before upload) - Web
    if (kIsWeb && _pickedLogoXFile != null) {
      return FutureBuilder<Uint8List>(
        future: _pickedLogoXFile!.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ClipOval(
              child: Image.memory(
                snapshot.data!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            );
          }
          return Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
            ),
            child: const CircularProgressIndicator(strokeWidth: 2),
          );
        },
      );
    }

    // Show selected file (before upload) - Mobile
    if (!kIsWeb && _pickedLogoFile != null) {
      return ClipOval(
        child: Image.file(
          _pickedLogoFile!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      );
    }

    // Show existing logo from server
    if (_existingLogoUrl != null && _existingLogoUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: _existingLogoUrl!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
            ),
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
          errorWidget: (context, url, error) => const CircleAvatar(
            radius: 50,
            child: Icon(Icons.school, size: 50),
          ),
        ),
      );
    }

    // Default placeholder
    return const CircleAvatar(
      radius: 50,
      backgroundColor: Colors.grey,
      child: Icon(Icons.school, size: 50, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ConfigurationBloc, ConfigurationState>(
        listener: (context, state) {
          if (state is ConfigurationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
                duration: const Duration(seconds: 4),
              ),
            );
            // Reset loading states on error
            setState(() {
              _isLogoUploading = false;
            });
          } else if (state is ConfigurationUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Configuration saved successfully"),
                backgroundColor: Colors.green.shade700,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is ConfigurationLogoUploading) {
            setState(() => _isLogoUploading = true);
          } else if (state is ConfigurationLogoUploaded) {
            setState(() {
              _uploadedLogoUrl = state.logoUrl;
              _isLogoUploading = false;
              // Clear the picked files since they're now uploaded
              _pickedLogoFile = null;
              _pickedLogoXFile = null;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Logo uploaded and saved successfully"),
                backgroundColor: Colors.green.shade700,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is ConfigurationLoaded) {
            // Update the UI when configuration is reloaded after logo upload
            final config = state.config;
            setState(() {
              _existingLogoUrl = config.logoUrl;
              // If we have a newly uploaded logo, it should be reflected in the loaded config
              if (config.logoUrl != null && config.logoUrl!.isNotEmpty) {
                _uploadedLogoUrl = config.logoUrl;
              }
            });
          }
        },
        builder: (context, state) {
          if (state is ConfigurationLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading configuration...'),
                ],
              ),
            );
          }

          if (state is ConfigurationLoaded) {
            final config = state.config;

            // Only set these values once when loaded
            if (_configId == null) {
              _configId = config.id;
              _schoolNameController.text = config.schoolName;
              _addressController.text = config.address;
              _emailController.text = config.email ?? '';
              _phoneNumber1Controller.text = config.phoneNumber1 ?? '';
              _phoneNumber2Controller.text = config.phoneNumber2 ?? '';
              _phoneNumber3Controller.text = config.phoneNumber3 ?? '';
              _phoneNumber4Controller.text = config.phoneNumber4 ?? '';
              _phoneNumber5Controller.text = config.phoneNumber5 ?? '';
              _websiteController.text = config.website ?? '';
              _existingLogoUrl = config.logoUrl;
            }

            return _buildForm();
          }

          if (state is ConfigurationEmpty || state is ConfigurationInitial) {
            return _buildForm(); // empty form for first-time config
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Unable to load configuration.'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.read<ConfigurationBloc>().add(LoadConfiguration()),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            // Logo Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        _buildLogoPreview(),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Material(
                            color: Theme.of(context).colorScheme.primary,
                            elevation: 4,
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: (_isLogoUploading || _isLoading) ? null : _pickLogo,
                              customBorder: const CircleBorder(),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  _isLogoUploading ? Icons.hourglass_empty : Icons.camera_alt,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'School Logo',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isLogoUploading
                                ? 'Uploading logo...'
                                : 'Upload your school logo. The image will be shown on reports, dashboards and other documents.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: _isLogoUploading ? Colors.orange : Colors.grey.shade700,
                            ),
                          ),
                          if (_uploadedLogoUrl != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Logo uploaded successfully',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // School Information Section
            const SectionHeader(title: "School Information"),
            const SizedBox(height: 16),
            TextFormField(
              controller: _schoolNameController,
              decoration: InputDecoration(
                labelText: 'School Name *',
                prefixIcon: const Icon(Icons.business),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              validator: (value) => value == null || value.trim().isEmpty ? 'School name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Address *',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              maxLines: 2,
              validator: (value) => value == null || value.trim().isEmpty ? 'Address is required' : null,
            ),
            const SizedBox(height: 24),

            // Contact Information Section
            const SectionHeader(title: "Contact Information"),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.trim().isNotEmpty && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _websiteController,
              decoration: InputDecoration(
                labelText: 'Website',
                prefixIcon: const Icon(Icons.web),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value != null && value.trim().isNotEmpty && !RegExp(r'^https?:\/\/[\w\-]+(\.[\w\-]+)+([\w\-\.,@?^=%&:/~\+#]*[\w\-\@?^=%&/~\+#])?$').hasMatch(value.trim())) {
                  return 'Enter a valid website URL (e.g., https://example.com)';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Phone Numbers Section
            const SectionHeader(title: "Phone Numbers"),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneNumber1Controller,
              decoration: InputDecoration(
                labelText: 'Primary Phone Number',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneNumber2Controller,
              decoration: InputDecoration(
                labelText: 'Phone Number 2 (Optional)',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneNumber3Controller,
              decoration: InputDecoration(
                labelText: 'Phone Number 3 (Optional)',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneNumber4Controller,
              decoration: InputDecoration(
                labelText: 'Phone Number 4 (Optional)',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneNumber5Controller,
              decoration: InputDecoration(
                labelText: 'Phone Number 5 (Optional)',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: (_isLogoUploading || _isLoading) ? null : _onSavePressed,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                disabledBackgroundColor: Colors.grey.shade400,
              ),
              child: Text(
                _isLogoUploading ? 'Uploading Logo...' : 'Save Configuration',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}