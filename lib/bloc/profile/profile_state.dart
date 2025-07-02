import 'package:equatable/equatable.dart';
import '../../models/profile.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Profile profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileEmpty extends ProfileState {}

class ProfileUpdated extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileAvatarUploading extends ProfileState {}

class ProfileAvatarUploaded extends ProfileState {
  final String avatarUrl;

  const ProfileAvatarUploaded(this.avatarUrl);

  @override
  List<Object?> get props => [avatarUrl];
}