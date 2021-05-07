part of 'platinum_deposits_bloc.dart';

abstract class PlatinumDepositsState extends Equatable {
  const PlatinumDepositsState();

  @override
  List<Object> get props => [];
}

class PlatinumDepositsInitial extends PlatinumDepositsState {}

class PlatinumDepositsLoading extends PlatinumDepositsState {}

class PlatinumDepositDeleted extends PlatinumDepositsState {}

class PlatinumDepositDeleting extends PlatinumDepositsState {}

class PlatinumDepositVerifying extends PlatinumDepositsState {}

class PlatinumDepositVerified extends PlatinumDepositsState {}

class PlatinumDepositsLoaded extends PlatinumDepositsState {
  final List<PlatinumDeposit> platinumDeposits;

  const PlatinumDepositsLoaded(this.platinumDeposits);

  @override
  List<Object> get props => [platinumDeposits];
}

class PlatinumDepositsError extends PlatinumDepositsState {
  final String error;

  const PlatinumDepositsError(this.error);

  @override
  List<Object> get props => [error];
}
