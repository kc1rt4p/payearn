part of 'platinum_bloc.dart';

abstract class PlatinumEvent extends Equatable {
  const PlatinumEvent();

  @override
  List<Object> get props => [];
}

class LoadPlatinum extends PlatinumEvent {
  final String subscriberId;

  const LoadPlatinum({@required this.subscriberId});

  @override
  List<Object> get props => [subscriberId];
}

class PlatinumReady extends PlatinumEvent {
  final Platinum platinum;

  const PlatinumReady(this.platinum);

  @override
  List<Object> get props => [platinum];
}
