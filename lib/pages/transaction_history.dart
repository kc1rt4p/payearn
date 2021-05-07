import 'dart:io';

import 'package:appodeal_flutter/appodeal_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../data/bloc/request_bloc.dart';
import '../data/models/request.dart';
import '../data/repositories/request_repository.dart';
import '../services/authentication.dart';
import '../services/photo_view.dart';
import '../widgets/heartbeat_loading.dart';
import '../widgets/image_selector.dart';

final oCcy = new NumberFormat("#,##0.00", "en_US");
String selectedCashOutId;
File newDepositPhoto;

class TransactionHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final requestRepository = RequestRepository();
    final authService = RepositoryProvider.of<AuthenticationService>(context);

    selectedCashOutId = authService.currentUserId;

    return Column(
      children: [
        Expanded(
          child: BlocProvider<RequestBloc>(
            create: authService.currentUserType == 'subscriber'
                ? (context) => RequestBloc(requestRepository)
                  ..add(LoadRequests(authService.currentUserId))
                : (context) =>
                    RequestBloc(requestRepository)..add(LoadCashOuts()),
            child: BlocListener<RequestBloc, RequestState>(
              listener: (context, state) {
                if (state is RequestError) {}

                if (state is RequestStatusUpdated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Request has been ${state.status}!'),
                      backgroundColor: Colors.green[600],
                    ),
                  );
                }

                if (state is RequestDepositPhotoUploaded) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Request deposit photo added!'),
                      backgroundColor: Colors.green[600],
                    ),
                  );
                }
              },
              child: BlocBuilder<RequestBloc, RequestState>(
                builder: (context, state) {
                  if (state is RequestsLoaded) {
                    return buildRequestLoaded(context, state);
                  }

                  if (state is CashOutsLoaded) {
                    return buildCashOutsLoaded(context, state);
                  }

                  return buildHeartbeatLoading();
                },
              ),
            ),
          ),
        ),
        Center(
          child: AppodealBanner(
            placementName: 'TransactionsPage',
          ),
        ),
      ],
    );
  }
}

buildCashOutsLoaded(BuildContext context, CashOutsLoaded state) {
  if (state.cashOutList.isEmpty) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FaIcon(
          FontAwesomeIcons.history,
          size: 100.0,
          color: Colors.blue[900],
        ),
        SizedBox(height: 10.0),
        Text('No requests found'),
      ],
    );
  }
  final cashOuts = state.cashOutList;
  return Column(
    children: <Widget>[
      Material(
        elevation: 10.0,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              'REQUESTS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Colors.blue[900],
              ),
            ),
          ),
        ),
      ),
      Expanded(
        child: ListView(
          children: cashOuts.map((cashout) {
            return Card(
              color: Colors.blue[200],
              child: ListTile(
                title: Text(cashout.requestor),
                subtitle: Text(
                    'Last request was made ${timeago.format(cashout.lastRequestDate.toDate())}'),
                trailing: Icon(Icons.arrow_right, size: 40.0),
                onTap: () {
                  BlocProvider.of<RequestBloc>(context)
                      .add(LoadRequests(cashout.id));
                },
              ),
            );
          }).toList(),
        ),
      ),
    ],
  );
}

buildRequestLoaded(BuildContext context, RequestsLoaded state) {
  if (state.requestList.isEmpty) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FaIcon(
          FontAwesomeIcons.history,
          size: 100.0,
          color: Colors.blue[900],
        ),
        SizedBox(height: 10.0),
        Text('No transactions found'),
      ],
    );
  }
  final authService = RepositoryProvider.of<AuthenticationService>(context);
  final requests = state.requestList;
  return Column(
    children: <Widget>[
      Material(
        elevation: 10.0,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'TRANSACTIONS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                    color: Colors.blue[900],
                  ),
                ),
              ),
            ),
            Visibility(
              visible: authService.currentUserType != 'subscriber',
              child: Positioned(
                left: 0,
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    BlocProvider.of<RequestBloc>(context).add(LoadCashOuts());
                  },
                ),
              ),
            )
          ],
        ),
      ),
      Expanded(
        child: ListView(
          children: requests.map((request) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(request.wallet.toUpperCase()),
                        ),
                        Expanded(
                          child:
                              Center(child: Text(request.status.toUpperCase())),
                        ),
                        Expanded(
                          child: Text(
                            DateFormat('MMM. dd, yyyy')
                                .format(request.dateRequested.toDate()),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Card(
                    color: request.type == 'convert'
                        ? Colors.indigo[100]
                        : Colors.blue[200],
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(children: <Widget>[
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Align(
                                          alignment: Alignment.center,
                                          child: FaIcon(
                                            FontAwesomeIcons.coins,
                                            size: 10.0,
                                            color: Colors.blue[900],
                                          ),
                                        ),
                                        SizedBox(width: 4.0),
                                        Text(
                                          oCcy.format(request.amount),
                                          style: TextStyle(
                                            color: Colors.blue[900],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: request.type != null
                                        ? Text(request.type.toUpperCase())
                                        : Text('CASHOUT'),
                                  ),
                                ]),
                                Row(children: <Widget>[
                                  Expanded(
                                    child: Text(request.paymentMethod),
                                  ),
                                  Expanded(
                                    child: Text(request.paymentOption),
                                  ),
                                ]),
                                Row(children: <Widget>[
                                  Expanded(
                                    child: Text(request.accountName),
                                  ),
                                  Expanded(
                                    child: Text(request.accountNumber),
                                  ),
                                ]),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.more_vert),
                            onPressed: () =>
                                viewRequestOptions(context, request),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    ],
  );
}

viewRequestOptions(BuildContext blocContext, Request request) async {
  final authService = RepositoryProvider.of<AuthenticationService>(blocContext);
  if (authService.currentUserType != 'subscriber') {
    await showModalBottomSheet(
      context: blocContext,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(8.0),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              TextButton(
                child: Text(
                  'View Deposit Photo',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
                onPressed: request.depositPhotoUrl != null
                    ? () {
                        Navigator.pop(context);
                        viewPhoto(context, request.depositPhotoUrl);
                      }
                    : null,
              ),
              Visibility(
                visible: authService.currentUserId != request.subscriberId,
                child: TextButton(
                  child: Text(
                    request.depositPhotoUrl != null
                        ? 'Change Deposit Photo'
                        : 'Upload Deposit Photo',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    selectPhoto(blocContext, request);
                  },
                ),
              ),
              Visibility(
                visible: authService.currentUserId == request.subscriberId,
                child: TextButton(
                  child: Text(
                    'Claim Deposit',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                  onPressed: request.status == 'approved' &&
                          request.depositPhotoUrl != null
                      ? () {
                          Navigator.pop(context);
                          updateStatus(blocContext, request, 'claimed');
                        }
                      : null,
                ),
              ),
              Visibility(
                visible: authService.currentUserId != request.subscriberId ||
                    authService.currentUserType == 'super',
                child: TextButton(
                  child: Text(
                    'Approve Request',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                  onPressed: request.status == 'pending'
                      ? () {
                          Navigator.pop(context);
                          updateStatus(blocContext, request, 'approved');
                        }
                      : null,
                ),
              ),
              Visibility(
                visible: authService.currentUserId != request.subscriberId,
                child: TextButton(
                  child: Text(
                    'Reject Request',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                  onPressed: request.status == 'pending'
                      ? () {
                          Navigator.pop(context);
                          updateStatus(blocContext, request, 'rejected');
                        }
                      : null,
                ),
              ),
              Visibility(
                visible: authService.currentUserType == 'super' &&
                    request.status == 'pending',
                child: TextButton(
                  child: Text(
                    'Delete Request',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                  onPressed: request.status == 'pending'
                      ? () {
                          Navigator.pop(context);
                          deleteRequest(blocContext, request);
                        }
                      : null,
                ),
              ),
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.red,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  } else {
    await showModalBottomSheet(
      context: blocContext,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(8.0),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              TextButton(
                child: Text(
                  'View Deposit',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
                onPressed: request.depositPhotoUrl != null
                    ? () {
                        Navigator.pop(context);
                        viewPhoto(context, request.depositPhotoUrl);
                      }
                    : null,
              ),
              TextButton(
                child: Text(
                  'Claim Deposit',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
                onPressed: request.status == 'approved' &&
                        request.depositPhotoUrl != null
                    ? () {
                        Navigator.pop(context);
                        updateStatus(blocContext, request, 'claimed');
                      }
                    : null,
              ),
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.red,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}

updateStatus(BuildContext context, Request request, String status) {
  selectedCashOutId = request.subscriberId;
  BlocProvider.of<RequestBloc>(context)
      .add(UpdateRequestStatus(selectedCashOutId, request, status));
}

deleteRequest(BuildContext context, Request request) async {
  Widget cancelButton = TextButton(
    child: Text(
      'No',
      style: TextStyle(
        color: Colors.white,
      ),
    ),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  Widget okButton = TextButton(
    child: Text(
      'Yes',
      style: TextStyle(
        color: Colors.white,
      ),
    ),
    onPressed: () {
      BlocProvider.of<RequestBloc>(context)
          .add(DeleteRequest(request.subscriberId, request.id));
      Navigator.of(context).pop();
    },
  );

  AlertDialog alert = AlertDialog(
    title: Text(
      'Confirm Request Delete',
      style: TextStyle(
        color: Colors.white,
      ),
    ),
    content: Text(
      'You are about to delete a cash out request, do you want to continue?',
      style: TextStyle(
        color: Colors.white,
      ),
    ),
    backgroundColor: Colors.blue[900],
    actions: [cancelButton, okButton],
  );

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

selectPhoto(BuildContext context, Request request) async {
  File picked =
      await ImageSelect(titleText: 'Select Deposit Photo').selectImage(context);

  if (picked != null) {
    BlocProvider.of<RequestBloc>(context)
        .add(UploadRequestDepositPhoto(request, picked));
  }
}
