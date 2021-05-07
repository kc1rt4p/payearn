import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../services/image_upload.dart';
import '../models/subscriber.dart';
import '../repositories/subscriber_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final SubscriberRepository subscriberRepository;
  ProfileBloc(this.subscriberRepository) : super(ProfileInitial());

  @override
  Stream<ProfileState> mapEventToState(
    ProfileEvent event,
  ) async* {
    yield ProfileLoading();

    if (event is LoadProfile) {
      try {
        final subscriber = await subscriberRepository.get(event.subscriberId);

        if (subscriber != null) {
          yield ProfileLoaded(subscriber);
        } else {
          yield ProfileNotFound();
        }
      } catch (e) {
        yield ProfileError('Server error');
      }
    }

    if (event is SaveProfile) {
      try {
        var subscriberData = event.subscriberData;
        if (event.profilePhoto != null) {
          final String newProfilePhotoUrl = await uploadImage(
              event.profilePhoto, 'profile', event.subscriberId);
          subscriberData['photoUrl'] = newProfilePhotoUrl;
        }

        if (event.idPhoto != null) {
          final String newIdPhotoUrl =
              await uploadImage(event.idPhoto, 'id', event.subscriberId);
          subscriberData['idUrl'] = newIdPhotoUrl;
        }

        final updated = await subscriberRepository.update(
            event.subscriberId, subscriberData);

        if (updated) {
          yield ProfileSaved();
        } else {
          yield ProfileError('Unable to update subscriber profile');
        }
      } catch (e) {
        print(e.toString());
        yield ProfileError('Problem occurred while updating profile');
      }
    }
  }
}
