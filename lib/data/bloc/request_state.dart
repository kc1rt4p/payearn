part of 'request_bloc.dart';

abstract class RequestState extends Equatable {
  const RequestState();

  @override
  List<Object> get props => [];
}

class RequestInitial extends RequestState {}

class RequestLoading extends RequestState {}

class CashOutsLoaded extends RequestState {
  final List<CashOut> cashOutList;

  const CashOutsLoaded(this.cashOutList);

  @override
  List<Object> get props => [cashOutList];
}

class RequestsLoaded extends RequestState {
  final List<Request> requestList;

  const RequestsLoaded(this.requestList);

  @override
  List<Object> get props => [requestList];
}

class RequestDeleted extends RequestState {}

class RequestDepositPhotoUploaded extends RequestState {}

class RequestByIdLoaded extends RequestState {
  final Request request;

  const RequestByIdLoaded(this.request);

  @override
  List<Object> get props => [request];
}

class RequestError extends RequestState {
  final String error;

  const RequestError(this.error);

  @override
  List<Object> get props => [error];
}

class RequestStatusUpdated extends RequestState {
  final String status;

  const RequestStatusUpdated(this.status);

  @override
  List<Object> get props => [status];
}
