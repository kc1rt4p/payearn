part of 'platinum_deposit_bloc.dart';

abstract class PlatinumDepositEvent extends Equatable {
  const PlatinumDepositEvent();

  @override
  List<Object> get props => [];
}

class PlatinumDepositInitialize extends PlatinumDepositEvent {}

class PlatinumDepositAdd extends PlatinumDepositEvent {
  final String subscriberId;
  final Map platinumDepositData;
  final File depositPhoto;

  const PlatinumDepositAdd(
      this.subscriberId, this.platinumDepositData, this.depositPhoto);

  @override
  List<Object> get props => [subscriberId, platinumDepositData];
}

class PlatinumDepositPaymentMethodSelect extends PlatinumDepositEvent {
  final PaymentMethod paymentMethod;

  const PlatinumDepositPaymentMethodSelect(this.paymentMethod);

  @override
  List<Object> get props => [paymentMethod];
}
