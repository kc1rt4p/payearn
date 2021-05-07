import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import '../data/models/subscriber.dart';
import '../data/repositories/subscriber_repository.dart';

SubscriberRepository subscriberRepository = SubscriberRepository();

buildSubscriberField({Function(Subscriber) onChanged}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: DropdownSearch<Subscriber>(
      label: 'Subscriber',
      showSearchBox: true,
      onFind: (String filter) => subscriberRepository.searchSubscribers(filter),
      hint: 'Search for a subscriber',
      itemAsString: (subscriber) =>
          '${subscriber.firstName} ${subscriber.lastName}',
      onChanged: onChanged,
    ),
  );
}
