import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../models/platinum_deposit.dart';
import '../repositories/platinum_deposit_repository.dart';

part 'platinum_deposits_event.dart';
part 'platinum_deposits_state.dart';

class PlatinumDepositsBloc
    extends Bloc<PlatinumDepositsEvent, PlatinumDepositsState> {
  PlatinumDepositRepository platinumDepositRepository =
      PlatinumDepositRepository();

  PlatinumDepositsBloc() : super(PlatinumDepositsInitial());

  StreamSubscription platinumDepositList;

  @override
  Stream<PlatinumDepositsState> mapEventToState(
    PlatinumDepositsEvent event,
  ) async* {
    if (event is PlatinumDepositsLoad) {
      yield PlatinumDepositsLoading();

      platinumDepositList?.cancel();

      platinumDepositList = platinumDepositRepository
          .getSubscriberPlatinumDeposits(event.subscriberId)
          .listen((list) {
        add(PlatinumDepositsReady(list));
      });
    }

    if (event is PlatinumDepositsReady) {
      yield PlatinumDepositsLoaded(event.platinumDepositList);
    }

    if (event is PlatinumDepositVerify) {
      yield PlatinumDepositVerifying();
      try {
        await platinumDepositRepository.verify(
            event.subscriberId, event.platinumDeposit);
        yield PlatinumDepositVerified();
      } catch (e) {
        yield PlatinumDepositsError('Unable to verify deposit, try again.');
      }
    }

    if (event is PlatinumDepositDelete) {
      yield PlatinumDepositDeleting();
      try {
        final deleted = await platinumDepositRepository.delete(
            event.subscriberId, event.platinumDeposit);
        if (deleted) {
          yield PlatinumDepositDeleted();
        } else {
          yield PlatinumDepositsError(
              'Deposit is already verified, unable to delete.');
        }
      } catch (e) {
        yield PlatinumDepositsError('Error deleting deposit');
      }
    }
  }
}
