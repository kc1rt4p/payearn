part of 'subscribers_bloc.dart';

abstract class SubscribersState extends Equatable {
  const SubscribersState();

  @override
  List<Object> get props => [];
}

class SubscribersInitial extends SubscribersState {}

class SubscribersLoading extends SubscribersState {}

class GettingSubscribers extends SubscribersState {}

class SubscribersLoaded extends SubscribersState {
  final List<Subscriber> subscriberList;

  const SubscribersLoaded(this.subscriberList);

  @override
  List<Object> get props => [subscriberList];
}

class SubscriberDeleted extends SubscribersState {}

class SubscribersError extends SubscribersState {
  final String error;

  const SubscribersError(this.error);

  @override
  List<Object> get props => [error];
}
