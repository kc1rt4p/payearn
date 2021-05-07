import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../models/subscriber.dart';
import '../repositories/subscriber_repository.dart';

part 'subscribers_event.dart';
part 'subscribers_state.dart';

class SubscribersBloc extends Bloc<SubscribersEvent, SubscribersState> {
  SubscriberRepository subscriberRepository = SubscriberRepository();

  SubscribersBloc() : super(SubscribersInitial());

  StreamSubscription subscriberList;

  @override
  Stream<SubscribersState> mapEventToState(
    SubscribersEvent event,
  ) async* {
    if (event is SubscriberDelete) {
      yield SubscribersLoading();
      try {
        await subscriberRepository.delete(event.id);
        yield SubscriberDeleted();
      } catch (e) {
        yield SubscribersError('Unable to delete subscriber');
      }
    }

    if (event is SubscriberGetAll) {
      yield GettingSubscribers();

      subscriberList?.cancel();

      subscriberList = subscriberRepository.getSubscribers().listen((list) {
        List<Subscriber> newList = [];
        for (Subscriber subscriber in list) {
          final String fullname =
              '${subscriber.firstName} ${subscriber.lastName}';

          // check query
          if (event.query.length > 0) {
            if (!fullname.toLowerCase().contains(event.query.toLowerCase())) {
              continue;
            }
          }

          newList.add(subscriber);
        }

        add(SubscribersLoad(newList));
      });
    }

    if (event is SubscribersLoad) {
      yield SubscribersLoaded(event.subscriberList);
    }
  }
}
