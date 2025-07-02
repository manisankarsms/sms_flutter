import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sms/widgets/section_header.dart';

import '../bloc/profile/profile_bloc.dart';
import '../bloc/profile/profile_event.dart';
import '../bloc/profile/profile_state.dart';
import '../models/profile.dart';
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({Key? key, required this.user}) : super(key: key);


  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _roleController = TextEditingController();

  File? _pickedAvatarFile;
  XFile? _pickedAvatarXFile; // For web support
  String? _existingAvatarUrl;
  String? _uploadedAvatarUrl; // New avatar URL from upload
  String? _createdAt;
  String? _updatedAt;
  bool _isLoading = false;
  bool _isAvatarUploading = false;

  // You'll need to get this from your authentication system

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfile(widget.user.id));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileNumberController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
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
            _pickedAvatarXFile = pickedFile;
            _pickedAvatarFile = null;
          } else {
            _pickedAvatarFile = File(pickedFile.path);
            _pickedAvatarXFile = null;
          }
        });

        // Automatically upload the avatar after selection
        await _uploadAvatar();
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

  Future<void> _uploadAvatar() async {
    if (_pickedAvatarFile == null && _pickedAvatarXFile == null) return;

    context.read<ProfileBloc>().add(
      UploadAvatar(
        userId: widget.user.id,
        avatarFile: _pickedAvatarFile,
        avatarXFile: _pickedAvatarXFile,
      ),
    );
  }

  void _onSavePressed() {
    if (_formKey.currentState!.validate()) {
      final updated = Profile(
        email: _emailController.text.trim(),
        mobileNumber: _mobileNumberController.text.trim(),
        role: _roleController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        avatarUrl: _uploadedAvatarUrl ?? _existingAvatarUrl, // Use uploaded URL if available
        createdAt: _createdAt ?? DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      // Always use UpdateProfile since avatar is already uploaded and saved
      context.read<ProfileBloc>().add(UpdateProfile(updated, widget.user.id));
    }
  }

  Widget _buildAvatarPreview() {
    if (_isLoading || _isAvatarUploading) {
      return Container(
        width: 120,
        height: 120,
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

    // Show uploaded avatar first (highest priority)
    if (_uploadedAvatarUrl != null && _uploadedAvatarUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: _uploadedAvatarUrl!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
            ),
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
          errorWidget: (context, url, error) => const CircleAvatar(
            radius: 60,
            child: Icon(Icons.person, size: 60),
          ),
        ),
      );
    }

    // Show selected file (before upload) - Web
    if (kIsWeb && _pickedAvatarXFile != null) {
      return FutureBuilder<Uint8List>(
        future: _pickedAvatarXFile!.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ClipOval(
              child: Image.memory(
                snapshot.data!,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            );
          }
          return Container(
            width: 120,
            height: 120,
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
    if (!kIsWeb && _pickedAvatarFile != null) {
      return ClipOval(
        child: Image.file(
          _pickedAvatarFile!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
      );
    }

    // Show existing avatar from server
    if (_existingAvatarUrl != null && _existingAvatarUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: _existingAvatarUrl!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
            ),
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
          errorWidget: (context, url, error) => const CircleAvatar(
            radius: 60,
            child: Icon(Icons.person, size: 60),
          ),
        ),
      );
    }

    // Default placeholder with user initials or icon
    String initials = '';
    if (_firstNameController.text.isNotEmpty || _lastNameController.text.isNotEmpty) {
      initials = '${_firstNameController.text.isNotEmpty ? _firstNameController.text[0] : ''}${_lastNameController.text.isNotEmpty ? _lastNameController.text[0] : ''}'.toUpperCase();
    }

    return CircleAvatar(
      radius: 60,
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: initials.isNotEmpty
          ? Text(
        initials,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      )
          : const Icon(Icons.person, size: 60, color: Colors.white),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Not available';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
                duration: const Duration(seconds: 4),
              ),
            );
            // Reset loading states on error
            setState(() {
              _isAvatarUploading = false;
            });
          } else if (state is ProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Profile updated successfully"),
                backgroundColor: Colors.green.shade700,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is ProfileAvatarUploading) {
            setState(() => _isAvatarUploading = true);
          } else if (state is ProfileAvatarUploaded) {
            setState(() {
              _uploadedAvatarUrl = state.avatarUrl;
              _isAvatarUploading = false;
              // Clear the picked files since they're now uploaded
              _pickedAvatarFile = null;
              _pickedAvatarXFile = null;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Avatar uploaded and saved successfully"),
                backgroundColor: Colors.green.shade700,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is ProfileLoaded) {
            // Update the UI when profile is reloaded after avatar upload
            final profile = state.profile;
            setState(() {
              _existingAvatarUrl = profile.avatarUrl;
              // If we have a newly uploaded avatar, it should be reflected in the loaded profile
              if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
                _uploadedAvatarUrl = profile.avatarUrl;
              }
            });
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading profile...'),
                ],
              ),
            );
          }

          if (state is ProfileLoaded) {
            final profile = state.profile;

            // Only set these values once when loaded
            if (_createdAt == null) {
              _firstNameController.text = profile.firstName;
              _lastNameController.text = profile.lastName;
              _emailController.text = profile.email;
              _mobileNumberController.text = profile.mobileNumber;
              _roleController.text = profile.role;
              _existingAvatarUrl = profile.avatarUrl;
              _createdAt = profile.createdAt;
              _updatedAt = profile.updatedAt;
            }

            return _buildForm();
          }

          if (state is ProfileEmpty || state is ProfileInitial) {
            return _buildForm(); // empty form for first-time setup
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Unable to load profile.'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.read<ProfileBloc>().add(LoadProfile(widget.user.id)),
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
            // Avatar Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        _buildAvatarPreview(),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Material(
                            color: Theme.of(context).colorScheme.primary,
                            elevation: 4,
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: (_isAvatarUploading || _isLoading) ? null : _pickAvatar,
                              customBorder: const CircleBorder(),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Icon(
                                  _isAvatarUploading ? Icons.hourglass_empty : Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Profile Picture',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isAvatarUploading
                          ? 'Uploading avatar...'
                          : 'Upload your profile picture. This will be displayed across the application.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _isAvatarUploading ? Colors.orange : Colors.grey.shade700,
                      ),
                    ),
                    if (_uploadedAvatarUrl != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Avatar uploaded successfully',
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
            ),
            const SizedBox(height: 24),

            // Personal Information Section
            const SectionHeader(title: "Personal Information"),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name *',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty ? 'First name is required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name *',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Last name is required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _roleController,
              decoration: InputDecoration(
                labelText: 'Role *',
                prefixIcon: const Icon(Icons.work_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              validator: (value) => value == null || value.trim().isEmpty ? 'Role is required' : null,
            ),
            const SizedBox(height: 24),

            // Contact Information Section
            const SectionHeader(title: "Contact Information"),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email Address *',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email is required';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _mobileNumberController,
              decoration: InputDecoration(
                labelText: 'Mobile Number *',
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) => value == null || value.trim().isEmpty ? 'Mobile number is required' : null,
            ),
            const SizedBox(height: 24),

            // Account Information Section
            if (_createdAt != null || _updatedAt != null) ...[
              const SectionHeader(title: "Account Information"),
              const SizedBox(height: 16),
              Card(
                elevation: 1,
                color: Colors.grey.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_createdAt != null) ...[
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 8),
                            Text(
                              'Created: ${_formatDate(_createdAt)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (_updatedAt != null) ...[
                        Row(
                          children: [
                            Icon(Icons.update, size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 8),
                            Text(
                              'Last Updated: ${_formatDate(_updatedAt)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Save Button
            ElevatedButton(
              onPressed: (_isAvatarUploading || _isLoading) ? null : _onSavePressed,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                disabledBackgroundColor: Colors.grey.shade400,
              ),
              child: Text(
                _isAvatarUploading ? 'Uploading Avatar...' : 'Update Profile',
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