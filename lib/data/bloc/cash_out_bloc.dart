import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../models/payment_method.dart';
import '../repositories/cash_out_repository.dart';
import '../repositories/payment_method_repository.dart';

part 'cash_out_event.dart';
part 'cash_out_state.dart';

class CashOutBloc extends Bloc<CashOutEvent, CashOutState> {
  PaymentMethodRepository paymentMethodRepository = PaymentMethodRepository();
  CashOutRepository cashOutRepository = CashOutRepository();

  CashOutBloc() : super(CashOutInitial());

  @override
  Stream<CashOutState> mapEventToState(
    CashOutEvent event,
  ) async* {
    if (event is CashOutInitialize) {
      yield* _mapCashOutInitializedState(event);
    }

    if (event is CashOutAdd) {
      yield* _mapCashOutAddedState(event);
    }

    // if (event is CashOutPaymentMethodSelect) {
    //   yield CashOutPaymentMethodSelected(event.paymentMethod);
    // }
  }

  Stream<CashOutState> _mapCashOutInitializedState(
      CashOutInitialize event) async* {
    try {
      final paymentMethods = await paymentMethodRepository.getAll();
      yield CashOutInitialized(paymentMethods);
    } catch (e) {
      yield CashOutError('${e.toString()}');
    }
  }

  Stream<CashOutState> _mapCashOutAddedState(CashOutAdd event) async* {
    try {
      yield CashOutAdding();
      await cashOutRepository.create(event.subscriberId, event.cashOutData);
      yield CashOutAdded();
    } catch (e) {
      yield CashOutError('${e.toString()}');
    }
  }
}
