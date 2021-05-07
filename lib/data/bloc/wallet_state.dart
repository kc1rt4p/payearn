part of 'wallet_bloc.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final Wallet wallet;
  final Platinum platinum;
  final DateTime currentDate;

  const WalletLoaded(this.wallet, this.platinum, this.currentDate);

  @override
  List<Object> get props => [wallet, platinum, currentDate];
}

class WalletNotFound extends WalletState {}

class WalletError extends WalletState {
  final String error;

  const WalletError(this.error);

  @override
  List<Object> get props => [error];
}
