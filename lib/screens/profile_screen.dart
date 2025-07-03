import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  final _controllers = <String, TextEditingController>{
    'firstName': TextEditingController(),
    'lastName': TextEditingController(),
    'email': TextEditingController(),
    'mobile': TextEditingController(),
    'role': TextEditingController(),
  };

  File? _avatarFile;
  XFile? _avatarXFile;
  String? _existingAvatarUrl;
  String? _uploadedAvatarUrl;
  String? _createdAt;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfile(widget.user.id));
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
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
            _avatarXFile = pickedFile;
            _avatarFile = null;
          } else {
            _avatarFile = File(pickedFile.path);
            _avatarXFile = null;
          }
        });

        context.read<ProfileBloc>().add(UploadAvatar(
          userId: widget.user.id,
          avatarFile: _avatarFile,
          avatarXFile: _avatarXFile,
        ));
      }
    } catch (e) {
      _showSnackBar("Error picking image: $e", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final profile = Profile(
        email: _controllers['email']!.text.trim(),
        mobileNumber: _controllers['mobile']!.text.trim(),
        role: _controllers['role']!.text.trim(),
        firstName: _controllers['firstName']!.text.trim(),
        lastName: _controllers['lastName']!.text.trim(),
        avatarUrl: _uploadedAvatarUrl ?? _existingAvatarUrl,
        createdAt: _createdAt ?? DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      context.read<ProfileBloc>().add(UpdateProfile(profile, widget.user.id));
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        ),
      );
    }
  }

  Widget _buildAvatarSection() {
    final name = '${_controllers['firstName']!.text} ${_controllers['lastName']!.text}';
    final initials = name.trim().split(' ').take(2).map((n) => n.isNotEmpty ? n[0] : '').join().toUpperCase();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    _buildAvatar(initials),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: _isLoading ? null : _pickAndUploadAvatar,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isLoading ? Icons.hourglass_empty : Icons.camera_alt,
                            color: const Color(0xFF667EEA),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  name.trim().isEmpty ? 'Your Name' : name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _controllers['role']!.text.isEmpty ? 'Your Role' : _controllers['role']!.text,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String initials) {
    if (_uploadedAvatarUrl != null) {
      return _buildNetworkAvatar(_uploadedAvatarUrl!);
    }

    if (kIsWeb && _avatarXFile != null) {
      return FutureBuilder<Uint8List>(
        future: _avatarXFile!.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ClipOval(
              child: Image.memory(snapshot.data!, width: 100, height: 100, fit: BoxFit.cover),
            );
          }
          return _buildLoadingAvatar();
        },
      );
    }

    if (!kIsWeb && _avatarFile != null) {
      return ClipOval(
        child: Image.file(_avatarFile!, width: 100, height: 100, fit: BoxFit.cover),
      );
    }

    if (_existingAvatarUrl != null) {
      return _buildNetworkAvatar(_existingAvatarUrl!);
    }

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          initials.isEmpty ? 'UN' : initials,
          style: const TextStyle(
            fontSize: 36,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkAvatar(String url) {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildLoadingAvatar(),
        errorWidget: (context, url, error) => Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, size: 50, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLoadingAvatar() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      ),
    );
  }

  Widget _buildFormField(String key, String label, IconData icon, {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _controllers[key],
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF667EEA)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1F2937),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1F2937),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            _showSnackBar(state.message, isError: true);
          } else if (state is ProfileUpdated) {
            _showSnackBar("Profile updated successfully");
          } else if (state is ProfileAvatarUploaded) {
            setState(() {
              _uploadedAvatarUrl = state.avatarUrl;
              _avatarFile = null;
              _avatarXFile = null;
            });
            _showSnackBar("Avatar uploaded successfully");
          } else if (state is ProfileLoaded) {
            final profile = state.profile;
            _controllers['firstName']!.text = profile.firstName;
            _controllers['lastName']!.text = profile.lastName;
            _controllers['email']!.text = profile.email;
            _controllers['mobile']!.text = profile.mobileNumber;
            _controllers['role']!.text = profile.role;
            _existingAvatarUrl = profile.avatarUrl;
            _createdAt = profile.createdAt;
            setState(() {});
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF667EEA)),
                  SizedBox(height: 16),
                  Text('Loading profile...', style: TextStyle(color: Color(0xFF6B7280))),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatarSection(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Personal Information'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormField(
                          'firstName',
                          'First Name *',
                          Icons.person_outline,
                          validator: (value) => value?.trim().isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFormField(
                          'lastName',
                          'Last Name *',
                          Icons.person,
                          validator: (value) => value?.trim().isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  _buildFormField(
                    'role',
                    'Role *',
                    Icons.work_outline,
                    validator: (value) => value?.trim().isEmpty ?? true ? 'Required' : null,
                  ),
                  _buildSectionTitle('Contact Information'),
                  _buildFormField(
                    'email',
                    'Email Address *',
                    Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value?.trim().isEmpty ?? true) return 'Required';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) return 'Invalid email';
                      return null;
                    },
                  ),
                  _buildFormField(
                    'mobile',
                    'Mobile Number *',
                    Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) => value?.trim().isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667EEA),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        _isLoading ? 'Updating...' : 'Update Profile',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}