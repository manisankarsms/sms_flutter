import 'package:equatable/equatable.dart';
import '../../models/profile.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  final String mobile;
  final String userId;

  LoadProfile(this.mobile, this.userId);

  @override
  List<Object?> get props => [mobile, userId];
}

class SaveProfile extends ProfileEvent {
  final Profile profile;
  final String mobile;
  final String userId;

  SaveProfile(this.profile, this.mobile, this.userId);

  @override
  List<Object?> get props => [profile, mobile, userId];
}
