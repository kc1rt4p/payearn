part of 'subscribers_bloc.dart';

abstract class SubscribersEvent extends Equatable {
  const SubscribersEvent();

  @override
  List<Object> get props => [];
}

class SubscriberGetAll extends SubscribersEvent {
  final String query;

  const SubscriberGetAll(this.query);

  @override
  List<Object> get props => [query];
}

class SubscribersLoad extends SubscribersEvent {
  final List<Subscriber> subscriberList;

  const SubscribersLoad(this.subscriberList);

  @override
  List<Object> get props => [subscriberList];
}

class SubscriberDelete extends SubscribersEvent {
  final String id;

  const SubscriberDelete(this.id);

  @override
  List<Object> get props => [id];
}
