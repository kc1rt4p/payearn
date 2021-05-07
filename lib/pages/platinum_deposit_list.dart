import 'package:appodeal_flutter/appodeal_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../data/bloc/platinum_deposits_bloc.dart';
import '../data/models/platinum_deposit.dart';
import '../services/authentication.dart';
import '../services/photo_view.dart';
import '../widgets/heartbeat_loading.dart';

final oCcy = new NumberFormat("#,##0.00", "en_US");

class PlatinumDepositListPage extends StatelessWidget {
  final String subscriberId;

  const PlatinumDepositListPage(this.subscriberId) : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        centerTitle: true,
        title: Text('Top Up History'),
      ),
      body: Column(
        children: [
          Center(
            child: AppodealBanner(
              placementName: 'DepositListPage',
            ),
          ),
          Expanded(
            child: BlocProvider<PlatinumDepositsBloc>(
              create: (context) => PlatinumDepositsBloc()
                ..add(PlatinumDepositsLoad(subscriberId)),
              child: BlocListener<PlatinumDepositsBloc, PlatinumDepositsState>(
                listener: (context, state) {
                  if (state is PlatinumDepositDeleted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('A Top Up record has been deleted.'),
                        backgroundColor: Colors.red[600],
                      ),
                    );
                  }

                  if (state is PlatinumDepositVerified) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Top Up has been verified.'),
                        backgroundColor: Colors.green[600],
                      ),
                    );
                  }

                  if (state is PlatinumDepositsError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.error),
                        backgroundColor: Colors.red[600],
                      ),
                    );
                  }
                },
                child: BlocBuilder<PlatinumDepositsBloc, PlatinumDepositsState>(
                  builder: (context, state) {
                    if (state is PlatinumDepositsLoaded) {
                      return buildPlatinumDepositsLoaded(
                          context, subscriberId, state.platinumDeposits);
                    }

                    return buildHeartbeatLoading();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

buildPlatinumDepositsLoaded(BuildContext context, String subscriberId,
    List<PlatinumDeposit> platinumDeposits) {
  if (platinumDeposits.length < 1) return buildEmptyPlatinumDeposits(context);

  return Column(
    children: <Widget>[
      Expanded(
        child: ListView(
          children: platinumDeposits.map((deposit) {
            return Card(
              color: Colors.blue[200],
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: FaIcon(
                                        FontAwesomeIcons.coins,
                                        size: 14.0,
                                      ),
                                    ),
                                    SizedBox(width: 4.0),
                                    Text(
                                      oCcy.format(deposit.amount),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  DateFormat('MMM. dd, yyyy')
                                      .format(deposit.depositDate.toDate()),
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.0),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                    '${deposit.paymentMethod} - ${deposit.paymentOption}'),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: deposit.isVerified
                                      ? Colors.green[600]
                                      : Colors.red[600],
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 5.0),
                                child: Row(
                                  children: [
                                    deposit.isVerified
                                        ? Icon(Icons.check, color: Colors.white)
                                        : Icon(Icons.close,
                                            color: Colors.white),
                                    SizedBox(width: 5.0),
                                    Text(
                                      'VERIFIED',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.more_vert),
                      onPressed: () =>
                          viewDepositOptions(context, subscriberId, deposit),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ],
  );
}

viewDepositOptions(BuildContext blocContext, String subscriberId,
    PlatinumDeposit deposit) async {
  final authService = RepositoryProvider.of<AuthenticationService>(blocContext);

  await showModalBottomSheet(
    context: blocContext,
    builder: (context) {
      return Container(
        padding: EdgeInsets.all(8.0),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            TextButton(
              child: Text(
                'View Top Up Photo',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                viewPhoto(context, deposit.depositPhotoUrl);
              },
            ),
            Visibility(
              visible: (authService.currentUserType != 'subscriber' &&
                          !deposit.isVerified) &&
                      subscriberId != authService.currentUserId ||
                  authService.currentUserType == 'super' && !deposit.isVerified,
              child: TextButton(
                child: Text(
                  'Verify Top Up',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  verifyDeposit(blocContext, subscriberId, deposit);
                },
              ),
            ),
            Visibility(
              visible: authService.currentUserType != 'admin' &&
                      !deposit.isVerified ||
                  authService.currentUserId == subscriberId,
              child: TextButton(
                child: Text(
                  'Delete Top Up',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
                onPressed: !deposit.isVerified
                    ? () {
                        Navigator.pop(context);
                        deleteDeposit(blocContext, subscriberId, deposit);
                      }
                    : null,
              ),
            ),
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.red[600],
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  );
}

buildEmptyPlatinumDeposits(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FaIcon(
          FontAwesomeIcons.moneyBill,
          size: 60.0,
          color: Colors.blue,
        ),
        SizedBox(height: 10.0),
        Text('No Top Ups found'),
      ],
    ),
  );
}

deleteDeposit(
    BuildContext context, String subscriberId, PlatinumDeposit deposit) async {
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
      BlocProvider.of<PlatinumDepositsBloc>(context)
          .add(PlatinumDepositDelete(deposit, subscriberId));
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
      'You are about to delete a top up, do you want to continue?',
      style: TextStyle(
        color: Colors.white,
      ),
    ),
    backgroundColor: Colors.blue[900],
    actions: [okButton, cancelButton],
  );

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

verifyDeposit(
    BuildContext context, String subscriberId, PlatinumDeposit deposit) {
  BlocProvider.of<PlatinumDepositsBloc>(context)
      .add(PlatinumDepositVerify(subscriberId, deposit));
}
