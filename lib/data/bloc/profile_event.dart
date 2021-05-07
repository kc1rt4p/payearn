part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class LoadProfile extends ProfileEvent {
  final String subscriberId;

  LoadProfile(this.subscriberId);

  @override
  List<Object> get props => [subscriberId];
}

class SaveProfile extends ProfileEvent {
  final String subscriberId;
  final Map<String, dynamic> subscriberData;
  final File profilePhoto;
  final File idPhoto;

  SaveProfile(
      this.subscriberData, this.subscriberId, this.profilePhoto, this.idPhoto);

  @override
  List<Object> get props =>
      [subscriberData, subscriberId, profilePhoto, idPhoto];
}
