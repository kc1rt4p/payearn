part of 'cash_out_bloc.dart';

abstract class CashOutState extends Equatable {
  const CashOutState();

  @override
  List<Object> get props => [];
}

class CashOutInitial extends CashOutState {}

class CashOutAdded extends CashOutState {}

class CashOutAdding extends CashOutState {}

class CashOutInitialized extends CashOutState {
  final List<PaymentMethod> paymentMethods;

  const CashOutInitialized(this.paymentMethods);

  @override
  List<Object> get props => [paymentMethods];
}

class CashOutError extends CashOutState {
  final String error;

  const CashOutError(this.error);

  @override
  List<Object> get props => [error];
}

class CashOutPaymentMethodSelected extends CashOutState {
  final PaymentMethod paymentMethod;

  const CashOutPaymentMethodSelected(this.paymentMethod);

  @override
  List<Object> get props => [paymentMethod];
}
