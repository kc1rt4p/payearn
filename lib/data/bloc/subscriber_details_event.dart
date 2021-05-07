part of 'subscriber_details_bloc.dart';

abstract class SubscriberDetailsEvent extends Equatable {
  const SubscriberDetailsEvent();

  @override
  List<Object> get props => [];
}

class LoadSubscriberDetails extends SubscriberDetailsEvent {
  final String subscriberId;

  const LoadSubscriberDetails({
    @required this.subscriberId,
  });

  @override
  List<Object> get props => [subscriberId];
}

class LoadSubscriberInfo extends SubscriberDetailsEvent {
  final String subscriberId;

  const LoadSubscriberInfo(this.subscriberId);

  @override
  List<Object> get props => [subscriberId];
}

class VerifySubscriber extends SubscriberDetailsEvent {
  final String subscriberId;

  const VerifySubscriber(this.subscriberId);

  @override
  List<Object> get props => [subscriberId];
}

class UpdateSubscriberWallet extends SubscriberDetailsEvent {
  final String subscriberId;
  final Map<String, dynamic> walletData;

  const UpdateSubscriberWallet(this.subscriberId, this.walletData);

  @override
  List<Object> get props => [walletData];
}
