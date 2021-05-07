part of 'platinum_deposit_bloc.dart';

abstract class PlatinumDepositState extends Equatable {
  const PlatinumDepositState();

  @override
  List<Object> get props => [];
}

class PlatinumDepositInitial extends PlatinumDepositState {}

class PlatinumDepositAdded extends PlatinumDepositState {}

class PlatinumDepositInitialized extends PlatinumDepositState {
  final List<PaymentMethod> paymentMethods;

  const PlatinumDepositInitialized(this.paymentMethods);

  @override
  List<Object> get props => [paymentMethods];
}

class PlatinumDepositAdding extends PlatinumDepositState {}

class PlatinumDepositError extends PlatinumDepositState {
  final String error;

  const PlatinumDepositError(this.error);

  @override
  List<Object> get props => [error];
}

class PlatinumDepositPaymentMethodSelected extends PlatinumDepositState {
  final PaymentMethod paymentMethod;

  const PlatinumDepositPaymentMethodSelected(this.paymentMethod);

  @override
  List<Object> get props => [paymentMethod];
}
