import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../repositories/profile_repository.dart';
import '../../models/profile.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;
  Profile? _currentProfile;

  ProfileBloc(this.repository) : super(ProfileInitial()) {
    // Load Profile
    on<LoadProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        final profile = await repository.fetchProfile(event.userId);
        _currentProfile = profile;
        if (profile == null) {
          emit(ProfileEmpty());
        } else {
          emit(ProfileLoaded(profile));
        }
      } catch (e) {
        emit(ProfileError('Failed to load profile: $e'));
      }
    });

    // Update Profile (no avatar)
    on<UpdateProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        final success = await repository.updateProfile(event.updatedProfile, event.userId);
        if (success) {
          _currentProfile = event.updatedProfile;
          emit(ProfileUpdated());
          emit(ProfileLoaded(event.updatedProfile));
        } else {
          emit(ProfileError('Profile update failed'));
        }
      } catch (e) {
        emit(ProfileError('Failed to update profile: $e'));
      }
    });

    // Upload only avatar
    on<UploadAvatar>((event, emit) async {
      emit(ProfileAvatarUploading());
      try {
        final avatar = event.avatarFile ?? File(event.avatarXFile!.path);
        final avatarUrl = await repository.uploadAvatar(event.userId, avatar);
        if (avatarUrl != null) {
          emit(ProfileAvatarUploaded(avatarUrl));
        } else {
          emit(ProfileError('Avatar upload failed'));
        }
      } catch (e) {
        emit(ProfileError('Failed to upload avatar: $e'));
      }
    });

    // Update profile and upload avatar together
    on<UpdateProfileWithAvatar>((event, emit) async {
      emit(ProfileLoading());
      try {
        String? avatarUrl;
        if (event.avatarFile != null || event.avatarXFile != null) {
          final avatar = event.avatarFile ?? File(event.avatarXFile!.path);
          avatarUrl = await repository.uploadAvatar(event.userId, avatar);
        }

        final updatedProfile = event.profile.copyWith(
          // Only overwrite avatar if upload succeeded
          avatarUrl: avatarUrl ?? event.profile.avatarUrl,
        );

        final success = await repository.updateProfile(updatedProfile, event.userId);
        if (success) {
          _currentProfile = updatedProfile;
          emit(ProfileUpdated());
          emit(ProfileLoaded(updatedProfile));
        } else {
          emit(ProfileError('Failed to update profile with avatar'));
        }
      } catch (e) {
        emit(ProfileError('Error during update with avatar: $e'));
      }
    });
  }
}
