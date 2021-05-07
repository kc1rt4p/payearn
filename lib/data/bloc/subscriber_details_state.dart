part of 'subscriber_details_bloc.dart';

abstract class SubscriberDetailsState extends Equatable {
  const SubscriberDetailsState();

  @override
  List<Object> get props => [];
}

class SubscriberDetailsInitial extends SubscriberDetailsState {}

class SubscriberDetailsLoading extends SubscriberDetailsState {}

class SubscriberWalletUpdated extends SubscriberDetailsState {}

class SubscriberDetailsLoaded extends SubscriberDetailsState {
  final Subscriber subscriber;
  const SubscriberDetailsLoaded(this.subscriber);
  @override
  List<Object> get props => [subscriber];
}

class SubscriberInfoLoaded extends SubscriberDetailsState {
  final Map subscriberInfo;

  SubscriberInfoLoaded(this.subscriberInfo);

  @override
  List<Object> get props => [subscriberInfo];
}

class SubscriberDetailsError extends SubscriberDetailsState {
  final String error;
  const SubscriberDetailsError(this.error);
  @override
  List<Object> get props => [error];
}

class SubscriberVerified extends SubscriberDetailsState {}

class SubscriberVerifying extends SubscriberDetailsState {}
