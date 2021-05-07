part of 'platinum_bloc.dart';

abstract class PlatinumState extends Equatable {
  const PlatinumState();

  @override
  List<Object> get props => [];
}

class PlatinumInitial extends PlatinumState {}

class PlatinumLoading extends PlatinumState {}

class PlatinumLoaded extends PlatinumState {
  final Platinum platinum;

  const PlatinumLoaded({@required this.platinum});

  @override
  List<Object> get props => [platinum];
}

class PlatinumNotFound extends PlatinumState {}

class PlatinumError extends PlatinumState {
  final String error;

  const PlatinumError({@required this.error});
}
