import 'package:appodeal_flutter/appodeal_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../data/bloc/subscriber_details_bloc.dart';
import '../data/models/platinum.dart';
import '../data/models/referral.dart';
import '../data/models/subscriber.dart';
import '../data/models/wallet.dart' as sWallet;
import '../services/authentication.dart';
import '../widgets/date_picker.dart';
import '../widgets/heartbeat_loading.dart';
import '../widgets/profile_text_field.dart';
import '../widgets/progress.dart';
import '../widgets/styled_button.dart';
import 'platinum_deposit_list.dart';

class SubscriberInfoPage extends StatelessWidget {
  final String subscriberId;

  const SubscriberInfoPage(this.subscriberId) : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscriber Information'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Center(
            child: AppodealBanner(
              placementName: 'InfoPage',
            ),
          ),
          Expanded(
            child: BlocProvider<SubscriberDetailsBloc>(
              create: (context) => SubscriberDetailsBloc()
                ..add(LoadSubscriberInfo(subscriberId)),
              child:
                  BlocListener<SubscriberDetailsBloc, SubscriberDetailsState>(
                listener: (context, state) {
                  if (state is SubscriberWalletUpdated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Subscriber wallet has been updated'),
                        backgroundColor: Colors.green[600],
                      ),
                    );
                  }
                },
                child:
                    BlocBuilder<SubscriberDetailsBloc, SubscriberDetailsState>(
                  builder: (context, state) {
                    if (state is SubscriberInfoLoaded) {
                      return buildSubscriberInfoLoaded(
                          context, state.subscriberInfo);
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

buildSubscriberInfoLoaded(BuildContext context, Map subscriberInfo) {
  return Column(
    children: <Widget>[
      Expanded(
        flex: 2,
        child: Card(
          color: Colors.blue[200],
          child: buildSubscriberDetails(context, subscriberInfo['subscriber'],
              subscriberInfo['account'].referralCode),
        ),
      ),
      Expanded(
        flex: 3,
        child: Card(
          color: Colors.blue[200],
          child: DefaultTabController(
            length: 4,
            child: Column(
              children: <Widget>[
                TabBar(
                  labelColor: Colors.blue[900],
                  unselectedLabelColor: Colors.grey[700],
                  indicatorColor: Colors.blue[900],
                  labelStyle: TextStyle(
                    fontSize: 12.0,
                  ),
                  tabs: [
                    Tab(
                      text: 'Referrer',
                    ),
                    Tab(
                      text: 'Platinum',
                    ),
                    Tab(
                      text: 'Referrals',
                    ),
                    Tab(
                      text: 'Wallet',
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      buildReferrerDetails(context, subscriberInfo['referral'],
                          subscriberInfo['referrer']),
                      buildPlatinumDetails(context, subscriberInfo['platinum'],
                          subscriberInfo['subscriber']),
                      buildReferrals(context, subscriberInfo['referrals']),
                      buildWalletDetails(context, subscriberInfo['wallet']),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

buildReferrals(BuildContext context, List<Map> referrals) {
  if (referrals.length < 1) {
    return Center(
      child: Text('NO REFERRALS'),
    );
  }

  return ListView(
    children: referrals
        .where((referral) => referral['referredSubscriber'] != null)
        .map((referral) {
      final subscriber = referral['referredSubscriber'];
      return Card(
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 30.0,
                backgroundColor: Colors.grey,
                backgroundImage: subscriber.photoUrl != null
                    ? CachedNetworkImageProvider(subscriber.photoUrl)
                    : AssetImage('assets/images/no_img.png'),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${subscriber.firstName} ${subscriber.lastName}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(subscriber.address),
                  Row(
                    children: <Widget>[
                      subscriber.hasPlatinum == true
                          ? Text(
                              '✓ PLATINUM',
                              style: TextStyle(color: Colors.green[900]),
                            )
                          : Text(
                              '✕ PLATINUM',
                              style: TextStyle(color: Colors.red[900]),
                            ),
                      SizedBox(width: 10.0),
                      subscriber.isVerified == true
                          ? Text(
                              '✓ VERIFIED',
                              style: TextStyle(color: Colors.green[900]),
                            )
                          : Text(
                              '✕ VERIFIED',
                              style: TextStyle(color: Colors.red[900]),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );
}

buildPlatinumDetails(
    BuildContext context, Platinum platinum, Subscriber subscriber) {
  if (platinum == null) {
    return Center(
      child: Text('NOT SUBSCRIBED TO PLATINUM'),
    );
  }

  final endDate = platinum.status == 'pending'
      ? 'PENDING'
      : platinum.startDate.toDate().add(Duration(days: 1095));
  Color statusColor;

  switch (platinum.status) {
    case 'pending':
      statusColor = Colors.grey[900];
      break;
    case 'active':
      statusColor = Colors.green[900];
      break;
    case 'completed':
      statusColor = Colors.blue[900];
      break;
    default:
  }

  return Center(
    child: ListView(
      shrinkWrap: true,
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  'STATUS',
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            SizedBox(width: 5.0),
            Expanded(
              child: Text(
                platinum.status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  'PIGGY BANK',
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            SizedBox(width: 5.0),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.coins,
                    size: 20.0,
                    color: Colors.blue[900],
                  ),
                  SizedBox(width: 4.0),
                  Text(
                    platinum.status == 'active'
                        ? '${oCcy.format(platinum.capital)}'
                        : '',
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Visibility(
          visible: platinum.status != 'pending',
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    'MONTHLY COINS',
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
              SizedBox(width: 5.0),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.coins,
                      size: 20.0,
                      color: Colors.blue[900],
                    ),
                    SizedBox(width: 4.0),
                    Text(
                      platinum.status == 'active'
                          ? '${oCcy.format(platinum.capital * .12)}'
                          : '',
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Visibility(
          visible: platinum.status != 'pending',
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    'DATE STARTED',
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
              SizedBox(width: 5.0),
              Expanded(
                child: Text(
                  platinum.status == 'active'
                      ? DateFormat('MMM. dd, yyyy')
                          .format(platinum.startDate.toDate())
                      : '',
                  style: TextStyle(
                    color: Colors.blue[900],
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Visibility(
          visible: platinum.status != 'pending',
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    'EXPIRY DATE',
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
              SizedBox(width: 5.0),
              Expanded(
                child: Text(
                  platinum.status == 'active'
                      ? DateFormat('MMM. dd, yyyy').format(endDate)
                      : '',
                  style: TextStyle(
                    color: Colors.blue[900],
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 55.0),
          width: double.infinity,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.white),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlatinumDepositListPage(subscriber.id),
                ),
              );
            },
            child: Text(
              'VIEW DEPOSITS',
              style: TextStyle(
                color: Colors.blue[900],
                fontWeight: FontWeight.bold,
                fontSize: 15.0,
                letterSpacing: 2.0,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

buildWalletDetails(BuildContext context, sWallet.Wallet wallet) {
  if (wallet == null) {
    return Center(
      child: Text('SUBSCRIBER NOT VERIFIED'),
    );
  }

  final totalAccumulated =
      wallet.electronic.amount + wallet.referral.amount + wallet.loyalty.amount;

  return Center(
    child: ListView(
      shrinkWrap: true,
      children: [
        SizedBox(height: 5.0),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  'ELECTRONIC',
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            SizedBox(width: 5.0),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.coins,
                    size: 20.0,
                    color: Colors.blue[900],
                  ),
                  SizedBox(width: 4.0),
                  Text(
                    '${oCcy.format(wallet.electronic.amount)}',
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Center(
          child: Text(
            'Last updated ${timeago.format(wallet.electronic.lastUpdate.toDate())}',
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.grey[700],
            ),
          ),
        ),
        SizedBox(height: 10.0),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  'REFERRAL',
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            SizedBox(width: 5.0),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.coins,
                    size: 20.0,
                    color: Colors.blue[900],
                  ),
                  SizedBox(width: 4.0),
                  Text(
                    '${oCcy.format(wallet.referral.amount)}',
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Center(
          child: Text(
            'Last updated ${timeago.format(wallet.referral.lastUpdate.toDate())}',
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.grey[700],
            ),
          ),
        ),
        SizedBox(height: 10.0),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  'LOYALTY',
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            SizedBox(width: 5.0),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.coins,
                    size: 20.0,
                    color: Colors.blue[900],
                  ),
                  SizedBox(width: 4.0),
                  Text(
                    '${oCcy.format(wallet.loyalty.amount)}',
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Center(
          child: Text(
            'Last updated ${timeago.format(wallet.loyalty.lastUpdate.toDate())}',
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.grey[700],
            ),
          ),
        ),
        SizedBox(height: 10.0),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  'TOTAL ACCUMULATED',
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            SizedBox(width: 5.0),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.coins,
                    size: 20.0,
                    color: Colors.blue[900],
                  ),
                  SizedBox(width: 4.0),
                  Text(
                    '${oCcy.format(totalAccumulated)}',
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 15.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35.0),
          child: StyledButton(
            labelText: 'EDIT WALLET',
            onPressed: () => showEditWalletDialog(context, wallet),
          ),
        ),
        SizedBox(height: 15.0),
      ],
    ),
  );
}

showEditWalletDialog(BuildContext context, sWallet.Wallet wallet) async {
  final oCcy2 = new NumberFormat("###0.00", "en_US");
  TextEditingController eAmountCtrl = TextEditingController();
  eAmountCtrl.text = oCcy2.format(wallet.electronic.amount);

  TextEditingController eLastRedeemCtrl = TextEditingController();
  var eLastRedeem = wallet.electronic.lastRedeem?.toDate();
  eLastRedeemCtrl.text = eLastRedeem != null
      ? DateFormat('MMM. dd, yyyy').format(eLastRedeem)
      : '';

  TextEditingController rAmountCtrl = TextEditingController();
  rAmountCtrl.text = oCcy2.format(wallet.referral.amount);

  TextEditingController rLastRedeemCtrl = TextEditingController();
  var rLastRedeem = wallet.referral.lastRedeem?.toDate();
  rLastRedeemCtrl.text = rLastRedeem != null
      ? DateFormat('MMM. dd, yyyy').format(wallet.referral.lastRedeem.toDate())
      : '';

  TextEditingController lAmountCtrl = TextEditingController();
  lAmountCtrl.text = oCcy2.format(wallet.loyalty.amount);

  TextEditingController lLastRedeemCtrl = TextEditingController();
  var lLastRedeem = wallet.loyalty.lastRedeem?.toDate();
  lLastRedeemCtrl.text = lLastRedeem != null
      ? DateFormat('MMM. dd, yyyy').format(wallet.loyalty.lastRedeem.toDate())
      : '';

  Widget cancelButton = StyledButton(
    labelText: 'CANCEL',
    color: Colors.red,
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  Widget okButton = StyledButton(
    labelText: 'UPDATE',
    onPressed: () {
      Navigator.of(context).pop();
      final walletData = {
        'electronic.amount':
            eAmountCtrl.text.isNotEmpty ? double.tryParse(eAmountCtrl.text) : 0,
        'electronic.lastRedeem': eLastRedeem ?? eLastRedeem,
        'referral.amount':
            rAmountCtrl.text.isNotEmpty ? double.tryParse(rAmountCtrl.text) : 0,
        'referral.lastRedeem': rLastRedeem ?? rLastRedeem,
        'loyalty.amount':
            lAmountCtrl.text.isNotEmpty ? double.tryParse(lAmountCtrl.text) : 0,
        'loyalty.lastRedeem': lLastRedeem ?? lLastRedeem,
      };

      BlocProvider.of<SubscriberDetailsBloc>(context)
          .add(UpdateSubscriberWallet(wallet.id, walletData));
    },
  );

  final editWalletDialog = SimpleDialog(
    contentPadding: EdgeInsets.all(10.0),
    titlePadding: EdgeInsets.all(8.0),
    title: Text('Edit Wallet'),
    children: [
      Text(
        'Electronic',
        textAlign: TextAlign.right,
      ),
      ProfileTextField(
        controller: eAmountCtrl,
        labelText: 'Amount',
      ),
      ProfileTextField(
        labelText: 'Last Redeem',
        controller: eLastRedeemCtrl,
        readOnly: true,
        onTap: () async {
          var date = await pickDate(context);
          if (date != null) {
            eLastRedeem = date;
            eLastRedeemCtrl.text =
                DateFormat('MMM. dd, yyyy').format(eLastRedeem);
          }
        },
      ),
      Divider(),
      Text(
        'Referral',
        textAlign: TextAlign.right,
      ),
      ProfileTextField(
        controller: rAmountCtrl,
        labelText: 'Amount',
      ),
      ProfileTextField(
        labelText: 'Last Redeem',
        controller: rLastRedeemCtrl,
        readOnly: true,
        onTap: () async {
          var date = await pickDate(context);
          if (date != null) {
            rLastRedeem = date;
            rLastRedeemCtrl.text =
                DateFormat('MMM. dd, yyyy').format(rLastRedeem);
          }
        },
      ),
      Divider(),
      Text(
        'Loyalty',
        textAlign: TextAlign.right,
      ),
      ProfileTextField(
        controller: lAmountCtrl,
        labelText: 'Amount',
      ),
      ProfileTextField(
        controller: lLastRedeemCtrl,
        labelText: 'Last Redeem',
        readOnly: true,
        onTap: () async {
          var date = await pickDate(context);
          if (date != null) {
            lLastRedeem = date;
            lLastRedeemCtrl.text =
                DateFormat('MMM. dd, yyyy').format(lLastRedeem);
          }
        },
      ),
      SizedBox(height: 10.0),
      Row(
        children: [
          Expanded(
            child: okButton,
          ),
          SizedBox(width: 5.0),
          Expanded(
            child: cancelButton,
          ),
        ],
      ),
    ],
  );

  await showDialog(
      context: context,
      builder: (BuildContext context) {
        return editWalletDialog;
      });
}

buildReferrerDetails(
    BuildContext context, Referral referral, Subscriber referrer) {
  if (referral == null) {
    return Center(
      child: Text('SUBSCRIBER WAS NOT REFERRED'),
    );
  }

  return Center(
    child: ListView(
      shrinkWrap: true,
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  'REFERRER',
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            SizedBox(width: 5.0),
            Expanded(
              child: Text(
                '${referrer.firstName} ${referrer.lastName}',
                style: TextStyle(
                  color: Colors.blue[900],
                  fontSize: 25.0,
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
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  'CODE USED',
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            SizedBox(width: 5.0),
            Expanded(
              child: Text(
                referral.referralCodeUsed,
                style: TextStyle(
                  color: Colors.blue[900],
                  fontSize: 25.0,
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
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  'DATE INVITED',
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            SizedBox(width: 5.0),
            Expanded(
              child: Text(
                DateFormat('MMM. dd yyyy')
                    .format(referral.dateReferred.toDate()),
                style: TextStyle(
                  color: Colors.blue[900],
                  fontSize: 25.0,
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
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  'BONUS RECEIVED',
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            SizedBox(width: 5.0),
            Expanded(
              child: Text(
                referral.bonusGiven ? 'YES' : 'NOT YET',
                style: TextStyle(
                  color: Colors.blue[900],
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

handleVerifySubscriber(BuildContext context, String subscriberId) async {
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
      BlocProvider.of<SubscriberDetailsBloc>(context)
          .add(VerifySubscriber(subscriberId));
      Navigator.of(context).pop();
    },
  );

  AlertDialog alert = AlertDialog(
    title: Text(
      'Confirm Verify Subscriber',
      style: TextStyle(
        color: Colors.white,
      ),
    ),
    content: Text(
      "The subscriber's account will be verified and a referral code will be generated. The referral bonus will also be given to the referrer. Do you want to continue?",
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

buildSubscriberDetails(
    BuildContext context, Subscriber subscriber, String referralCode) {
  final authService = RepositoryProvider.of<AuthenticationService>(context);
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Text(
          '${subscriber.firstName} ${subscriber.lastName}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
      ),
      Expanded(
        child: SingleChildScrollView(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      maxRadius: MediaQuery.of(context).size.height * .08,
                      backgroundColor: Colors.grey,
                      backgroundImage: subscriber.photoUrl != null
                          ? CachedNetworkImageProvider(subscriber.photoUrl)
                          : AssetImage('assets/images/default_profile.png'),
                    ),
                    SizedBox(height: 10.0),
                    Visibility(
                      visible: subscriber.isVerified,
                      child: Text(
                        referralCode != null ? referralCode : 'NOT VERIFIED',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: !subscriber.isVerified &&
                          subscriber.id != authService.currentUserId,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.white),
                        ),
                        child: Text(
                          'VERIFY',
                          style: TextStyle(
                            letterSpacing: 1.5,
                            color: Colors.blue[900],
                          ),
                        ),
                        onPressed: () =>
                            handleVerifySubscriber(context, subscriber.id),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      buildSubscriberInfoItem(
                        Icon(Icons.cake, size: 16.0),
                        DateFormat('MMM. dd, yyyy')
                            .format(subscriber.birthDate.toDate()),
                      ),
                      buildSubscriberInfoItem(
                        Icon(Icons.pin_drop, size: 16.0),
                        subscriber.address,
                      ),
                      buildSubscriberInfoItem(
                        Icon(Icons.phone, size: 16.0),
                        subscriber.mobile,
                      ),
                      buildSubscriberInfoItem(
                        Icon(Icons.email, size: 16.0),
                        subscriber.email,
                      ),
                      buildSubscriberInfoItem(
                        FaIcon(FontAwesomeIcons.briefcase, size: 14.0),
                        '${subscriber.work} at ${subscriber.workAddress}',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 55.0,
          vertical: 5.0,
        ),
        child: StyledButton(
          labelText: 'VIEW ID',
          onPressed: () => handleViewId(context, subscriber.idUrl),
          color: Colors.white,
        ),
      ),
    ],
  );
}

handleViewId(BuildContext context, String url) {
  showDialog(
    context: context,
    builder: (context) {
      return Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: <Widget>[
                  Container(
                    color: Colors.grey[600],
                    child: PhotoView(
                      imageProvider: NetworkImage(url),
                      loadingBuilder: (context, event) {
                        return circularProgress();
                      },
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: -20,
                    child: RawMaterialButton(
                      onPressed: () => Navigator.pop(context),
                      elevation: 2.0,
                      fillColor: Colors.white,
                      child: Icon(Icons.close),
                      shape: CircleBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

buildSubscriberInfoItem(Widget icon, String text) {
  return RichText(
    textAlign: TextAlign.center,
    text: TextSpan(
      style: TextStyle(
        fontSize: 14.0,
        color: Colors.black,
      ),
      children: [
        WidgetSpan(
          child: Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: icon,
          ),
        ),
        TextSpan(text: text),
      ],
    ),
  );
}
