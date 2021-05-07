import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../models/payment_method.dart';
import '../repositories/payment_method_repository.dart';
import '../repositories/platinum_deposit_repository.dart';

part 'platinum_deposit_event.dart';
part 'platinum_deposit_state.dart';

class PlatinumDepositBloc
    extends Bloc<PlatinumDepositEvent, PlatinumDepositState> {
  PlatinumDepositRepository platinumDepositRepository =
      PlatinumDepositRepository();
  PaymentMethodRepository paymentMethodRepository = PaymentMethodRepository();

  PlatinumDepositBloc() : super(PlatinumDepositInitial());

  @override
  Stream<PlatinumDepositState> mapEventToState(
    PlatinumDepositEvent event,
  ) async* {
    if (event is PlatinumDepositInitialize) {
      try {
        final paymentMethods = await paymentMethodRepository.getAll();
        yield PlatinumDepositInitialized(paymentMethods);
      } catch (e) {
        print('error getting paymentMethods');
        yield PlatinumDepositError('Unable to retrieve payment methods.');
      }
    }

    if (event is PlatinumDepositAdd) {
      try {
        yield PlatinumDepositAdding();
        await platinumDepositRepository.create(
            event.subscriberId, event.platinumDepositData, event.depositPhoto);
        yield PlatinumDepositAdded();
      } catch (e) {
        print('error adding deposit: ${e.toString()}');
        yield PlatinumDepositError(
            'Error ocurred while adding platinum deposit.');
      }
    }
  }
}
