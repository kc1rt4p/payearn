part of 'cash_out_bloc.dart';

abstract class CashOutEvent extends Equatable {
  const CashOutEvent();

  @override
  List<Object> get props => [];
}

class CashOutInitialize extends CashOutEvent {}

class CashOutAdd extends CashOutEvent {
  final String subscriberId;
  final Map cashOutData;

  const CashOutAdd(this.subscriberId, this.cashOutData);

  @override
  List<Object> get props => [subscriberId, cashOutData];
}

class CashOutPaymentMethodSelect extends CashOutEvent {
  final PaymentMethod paymentMethod;

  const CashOutPaymentMethodSelect(this.paymentMethod);

  @override
  List<Object> get props => [paymentMethod];
}
