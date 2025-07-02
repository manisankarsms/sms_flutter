import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/profile.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  final String userId;
  const LoadProfile(this.userId);
}

class UpdateProfile extends ProfileEvent {
  final String userId;
  final Profile updatedProfile;

  const UpdateProfile(this.updatedProfile, this.userId);

  @override
  List<Object?> get props => [updatedProfile];
}

class UpdateProfileWithAvatar extends ProfileEvent {
  final Profile profile;
  final String userId;
  final File? avatarFile;
  final XFile? avatarXFile;

  const UpdateProfileWithAvatar({
    required this.profile,
    required this.userId,
    this.avatarFile,
    this.avatarXFile,
  });

  @override
  List<Object?> get props => [profile, userId, avatarFile, avatarXFile];
}

class UploadAvatar extends ProfileEvent {
  final String userId;
  final File? avatarFile;
  final XFile? avatarXFile;

  const UploadAvatar({
    required this.userId,
    this.avatarFile,
    this.avatarXFile,
  });

  @override
  List<Object?> get props => [userId, avatarFile, avatarXFile];
}