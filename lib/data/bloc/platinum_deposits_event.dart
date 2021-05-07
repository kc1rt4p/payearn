part of 'platinum_deposits_bloc.dart';

abstract class PlatinumDepositsEvent extends Equatable {
  const PlatinumDepositsEvent();

  @override
  List<Object> get props => [];
}

class PlatinumDepositsLoad extends PlatinumDepositsEvent {
  final String subscriberId;

  const PlatinumDepositsLoad(this.subscriberId);

  @override
  List<Object> get props => [subscriberId];
}

class PlatinumDepositsReady extends PlatinumDepositsEvent {
  final List<PlatinumDeposit> platinumDepositList;

  const PlatinumDepositsReady(this.platinumDepositList);

  @override
  List<Object> get props => [platinumDepositList];
}

class PlatinumDepositDelete extends PlatinumDepositsEvent {
  final String subscriberId;
  final PlatinumDeposit platinumDeposit;

  const PlatinumDepositDelete(this.platinumDeposit, this.subscriberId);

  @override
  List<Object> get props => [subscriberId, platinumDeposit];
}

class PlatinumDepositVerify extends PlatinumDepositsEvent {
  final String subscriberId;
  final PlatinumDeposit platinumDeposit;

  const PlatinumDepositVerify(this.subscriberId, this.platinumDeposit);

  @override
  List<Object> get props => [subscriberId, platinumDeposit];
}
