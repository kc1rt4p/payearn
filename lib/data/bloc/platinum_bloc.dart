import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../models/platinum.dart';
import '../repositories/platinum_repository.dart';

part 'platinum_event.dart';
part 'platinum_state.dart';

class PlatinumBloc extends Bloc<PlatinumEvent, PlatinumState> {
  final PlatinumRepository platinumRepository;

  PlatinumBloc(this.platinumRepository) : super(PlatinumInitial());

  StreamSubscription platinum;

  @override
  Stream<PlatinumState> mapEventToState(
    PlatinumEvent event,
  ) async* {
    yield PlatinumLoading();

    if (event is LoadPlatinum) {
      yield PlatinumLoading();

      platinum?.cancel();

      platinum =
          platinumRepository.streamPlatinum(event.subscriberId).listen((plat) {
        add(PlatinumReady(plat));
      });
    }

    if (event is PlatinumReady) {
      if (event.platinum != null)
        yield PlatinumLoaded(platinum: event.platinum);
      else
        yield PlatinumNotFound();
    }
  }
}
