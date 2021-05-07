part of 'wallet_bloc.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object> get props => [];
}

class CheckDailyEarnings extends WalletEvent {
  final String subscriberId;

  const CheckDailyEarnings(this.subscriberId);

  @override
  List<Object> get props => [subscriberId];
}

class LoadWallet extends WalletEvent {
  final String subscriberId;

  const LoadWallet({@required this.subscriberId});

  @override
  List<Object> get props => [subscriberId];
}

class WalletReady extends WalletEvent {
  final Wallet wallet;
  final Platinum platinum;

  const WalletReady(this.wallet, this.platinum);

  @override
  List<Object> get props => [wallet, platinum];
}
