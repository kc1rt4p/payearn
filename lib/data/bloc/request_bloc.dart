import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../models/cash_out.dart';
import '../models/request.dart';
import '../repositories/request_repository.dart';

part 'request_event.dart';
part 'request_state.dart';

class RequestBloc extends Bloc<RequestEvent, RequestState> {
  final RequestRepository requestRepository;

  RequestBloc(this.requestRepository) : super(RequestInitial());

  StreamSubscription cashOutList;
  StreamSubscription requestList;

  @override
  Stream<RequestState> mapEventToState(
    RequestEvent event,
  ) async* {
    yield RequestLoading();

    if (event is LoadRequests) {
      requestList?.cancel();

      requestList =
          requestRepository.getRequests(event.subscriberId).listen((list) {
        add(RequestsReceived(list));
      });
    }

    if (event is LoadCashOuts) {
      cashOutList = requestRepository.getCashOuts().listen((list) {
        add(CashOutsReceived(list));
      });
    }

    if (event is UpdateRequestStatus) {
      try {
        await requestRepository.updateRequestStatus(
            event.cashOutId, event.request, event.status);
        yield RequestStatusUpdated(event.status);
      } catch (e) {
        print('update request error: ${e.toString()}');
        yield RequestError('Unable to update request');
      }
    }

    if (event is DeleteRequest) {
      try {
        await requestRepository.deleteRequest(
            event.subscriberId, event.requestId);
        yield RequestDeleted();
      } catch (e) {
        yield RequestError('Unable to delete request');
      }
    }

    if (event is UploadRequestDepositPhoto) {
      try {
        await requestRepository.addRequestDepositphoto(
            event.request, event.imageFile);

        yield RequestDepositPhotoUploaded();
      } catch (e) {
        print('error uplading deeposit photo: ${e.toString()}');
        yield RequestError('An error occurred while uploading deposit photo.');
      }
    }

    if (event is RequestsReceived) {
      yield RequestsLoaded(event.requestList);
    }

    if (event is CashOutsReceived) {
      yield CashOutsLoaded(event.cashOutList);
    }
  }

  @override
  Future<void> close() {
    requestList?.cancel();
    cashOutList?.cancel();
    return super.close();
  }
}
