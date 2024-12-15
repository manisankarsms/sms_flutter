import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;

  ProfileBloc(this.profileRepository) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<SaveProfile>(_onSaveProfile);
  }

  void _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final profileData = await profileRepository.fetchProfileData(event.mobile, event.userId);
      emit(ProfileLoaded(profileData!));
    } catch (e) {
      emit(ProfileError("Failed to load profile: $e"));
    }
  }

  void _onSaveProfile(SaveProfile event, Emitter<ProfileState> emit) async {
    try {
      await profileRepository.updateProfile(event.profile);
      emit(ProfileSaved());
      add(LoadProfile(event.mobile, event.userId)); // Reload profile data after saving
    } catch (e) {
      emit(ProfileError("Failed to save profile: $e"));
    }
  }
}
