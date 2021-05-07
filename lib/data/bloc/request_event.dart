part of 'request_bloc.dart';

abstract class RequestEvent extends Equatable {
  const RequestEvent();

  @override
  List<Object> get props => [];
}

class LoadCashOuts extends RequestEvent {}

class LoadRequests extends RequestEvent {
  final String subscriberId;

  const LoadRequests(this.subscriberId);

  @override
  List<Object> get props => [subscriberId];
}

class CashOutsReceived extends RequestEvent {
  final List<CashOut> cashOutList;

  const CashOutsReceived(this.cashOutList);

  @override
  List<Object> get props => [cashOutList];
}

class RequestsReceived extends RequestEvent {
  final List<Request> requestList;

  const RequestsReceived(this.requestList);

  @override
  List<Object> get props => [requestList];
}

class DeleteRequest extends RequestEvent {
  final String requestId;
  final String subscriberId;

  const DeleteRequest(this.subscriberId, this.requestId);

  @override
  List<Object> get props => [subscriberId, requestId];
}

class LoadRequestById extends RequestEvent {
  final String cashOutId;
  final String requestId;

  const LoadRequestById(this.cashOutId, this.requestId);

  @override
  List<Object> get props => [cashOutId, requestId];
}

class UpdateRequestStatus extends RequestEvent {
  final String cashOutId;
  final Request request;
  final String status;

  const UpdateRequestStatus(this.cashOutId, this.request, this.status);

  @override
  List<Object> get props => [cashOutId, request, status];
}

class UploadRequestDepositPhoto extends RequestEvent {
  final Request request;
  final File imageFile;

  const UploadRequestDepositPhoto(this.request, this.imageFile);

  @override
  List<Object> get props => [request, imageFile];
}
