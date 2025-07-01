import 'dart:io';
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
  int? _configId;
  bool _isLoading = false;

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
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking image: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSavePressed() {
    if (_formKey.currentState!.validate()) {
      String logoPath = '';

      if (kIsWeb && _pickedLogoXFile != null) {
        logoPath = _pickedLogoXFile!.path;
      } else if (!kIsWeb && _pickedLogoFile != null) {
        logoPath = _pickedLogoFile!.path;
      } else {
        logoPath = _existingLogoUrl ?? '';
      }

      final updated = Configuration(
        id: _configId ?? 1,
        schoolName: _schoolNameController.text,
        logoUrl: logoPath.isEmpty ? null : logoPath,
        address: _addressController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        phoneNumber1: _phoneNumber1Controller.text.isEmpty ? null : _phoneNumber1Controller.text,
        phoneNumber2: _phoneNumber2Controller.text.isEmpty ? null : _phoneNumber2Controller.text,
        phoneNumber3: _phoneNumber3Controller.text.isEmpty ? null : _phoneNumber3Controller.text,
        phoneNumber4: _phoneNumber4Controller.text.isEmpty ? null : _phoneNumber4Controller.text,
        phoneNumber5: _phoneNumber5Controller.text.isEmpty ? null : _phoneNumber5Controller.text,
        website: _websiteController.text.isEmpty ? null : _websiteController.text,
      );

      context.read<ConfigurationBloc>().add(UpdateConfiguration(updated));
    }
  }

  Widget _buildLogoPreview() {
    if (_isLoading) {
      return const CircleAvatar(
        radius: 50,
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (kIsWeb && _pickedLogoXFile != null) {
      return ClipOval(
        child: Image.network(
          _pickedLogoXFile!.path,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      );
    } else if (!kIsWeb && _pickedLogoFile != null) {
      return ClipOval(
        child: Image.file(
          _pickedLogoFile!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      );
    } else if (_existingLogoUrl?.isNotEmpty == true) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: _existingLogoUrl!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.school, size: 50),
        ),
      );
    } else {
      return const CircleAvatar(
        radius: 50,
        child: Icon(Icons.school, size: 50),
      );
    }
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
              ),
            );
          } else if (state is ConfigurationUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Configuration saved successfully"),
                backgroundColor: Colors.green.shade700,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ConfigurationLoading) {
            return const Center(child: CircularProgressIndicator());
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
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Row(
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
                          onTap: _pickLogo,
                          customBorder: const CircleBorder(),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.camera_alt,
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
                        'Upload your school logo. The image will be shown on reports, dashboards and other documents.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const SectionHeader(title: "School Information"),
            const SizedBox(height: 16),
            TextFormField(
              controller: _schoolNameController,
              decoration: InputDecoration(
                labelText: 'School Name',
                prefixIcon: const Icon(Icons.business),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              validator: (value) => value == null || value.isEmpty ? 'School name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              maxLines: 2,
              validator: (value) => value == null || value.isEmpty ? 'Address is required' : null,
            ),
            const SizedBox(height: 24),
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
                if (value != null && value.isNotEmpty && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
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
                if (value != null && value.isNotEmpty && !RegExp(r'^https?:\/\/[\w\-]+(\.[\w\-]+)+([\w\-\.,@?^=%&:/~\+#]*[\w\-\@?^=%&/~\+#])?$').hasMatch(value)) {
                  return 'Enter a valid website URL (e.g., https://example.com)';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
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
            ElevatedButton(
              onPressed: _onSavePressed,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Save Configuration', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}