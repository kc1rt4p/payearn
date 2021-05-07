part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Subscriber subscriber;

  const ProfileLoaded(this.subscriber);

  @override
  List<Object> get props => [subscriber];
}

class ProfileNotFound extends ProfileState {}

class ProfileError extends ProfileState {
  final String error;

  const ProfileError(this.error);

  @override
  List<Object> get props => [error];
}

class ProfileSaved extends ProfileState {}
