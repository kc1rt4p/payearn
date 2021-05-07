import 'package:appodeal_flutter/appodeal_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../data/bloc/platinum_bloc.dart';
import '../data/bloc/subscriber_details_bloc.dart';
import '../data/bloc/wallet_bloc.dart';
import '../data/models/platinum.dart';
import '../data/models/subscriber.dart';
import '../data/models/wallet.dart';
import '../data/repositories/platinum_repository.dart';
import '../data/repositories/wallet_repository.dart';
import '../services/authentication.dart';
import '../widgets/styled_button.dart';
import 'cash_out.dart';
import 'platinum_deposit.dart';
import 'platinum_deposit_list.dart';

final oCcy = new NumberFormat("#,##0.00", "en_US");

class DashboardPage extends StatefulWidget {
  DashboardPage();

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool showBanner = true;
  @override
  void initState() {
    super.initState();
  }

  toggleBanner() {
    setState(() {
      showBanner = !showBanner;
    });
  }

  @override
  Widget build(BuildContext context) {
    final walletRepo = WalletRepository();
    final platinumRepo = PlatinumRepository();
    final authService = RepositoryProvider.of<AuthenticationService>(context);

    FocusScope.of(context).unfocus();

    final size = MediaQuery.of(context).size;

    return Container(
      height:
          MediaQuery.of(context).size.height - AppBar().preferredSize.height,
      child: Column(
        children: [
          Visibility(
            visible: showBanner,
            child: Center(
              child: AppodealBanner(
                placementName: 'Dashboard',
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                Card(
                  color: Colors.blue[100],
                  child: Container(
                    height:
                        (size.height - AppBar().preferredSize.height) * 0.25,
                    width: size.width,
                    child: BlocProvider<SubscriberDetailsBloc>(
                      create: (context) => SubscriberDetailsBloc()
                        ..add(
                          LoadSubscriberDetails(
                            subscriberId: authService.currentUserId,
                          ),
                        ),
                      child: BlocListener<SubscriberDetailsBloc,
                          SubscriberDetailsState>(
                        listener: (context, state) {},
                        child: BlocBuilder<SubscriberDetailsBloc,
                            SubscriberDetailsState>(
                          builder: (context, state) {
                            if (state is SubscriberDetailsLoaded) {
                              return buildSubscriberDetailsLoaded(
                                  context,
                                  state.subscriber,
                                  authService.currentAccount.referralCode);
                            }

                            return buildLoading();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Card(
                  color: Colors.blue[100],
                  child: BlocProvider<WalletBloc>(
                    create: (context) => WalletBloc(walletRepo)
                      ..add(
                        CheckDailyEarnings(authService.currentUserId),
                      ),
                    child: Container(
                      height:
                          (size.height - AppBar().preferredSize.height) * 0.33,
                      width: size.width,
                      child: BlocListener<WalletBloc, WalletState>(
                        listener: (context, state) {},
                        child: BlocBuilder<WalletBloc, WalletState>(
                          builder: (context, state) {
                            if (state is WalletLoaded) {
                              return buildWalletLoaded(
                                  context,
                                  state.wallet,
                                  state.platinum,
                                  toggleBanner,
                                  state.currentDate);
                            }

                            if (state is WalletNotFound) {
                              return buildWalletNotFound();
                            }

                            if (state is WalletError) {
                              print(state.error);
                            }

                            return buildLoading();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Card(
                  color: Colors.blue[100],
                  child: Container(
                    height:
                        (size.height - AppBar().preferredSize.height) * 0.33,
                    width: size.width,
                    child: BlocProvider<PlatinumBloc>(
                      create: (context) => PlatinumBloc(platinumRepo)
                        ..add(
                          LoadPlatinum(subscriberId: authService.currentUserId),
                        ),
                      child: BlocListener<PlatinumBloc, PlatinumState>(
                        listener: (context, state) {},
                        child: BlocBuilder<PlatinumBloc, PlatinumState>(
                          builder: (context, state) {
                            if (state is PlatinumLoaded) {
                              return buildPlatinumLoaded(
                                  context, state.platinum, toggleBanner);
                            }

                            if (state is PlatinumNotFound) {
                              return buildPlatinumNotFound(
                                  context,
                                  authService.currentSubscriber.isVerified,
                                  toggleBanner);
                            }

                            if (state is PlatinumError) {
                              print(state.error);
                            }

                            return buildLoading();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

buildSubscriberDetailsLoaded(
    BuildContext context, Subscriber subscriber, String referralCode) {
  return Row(
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              maxRadius: MediaQuery.of(context).size.height * .08,
              backgroundColor: Colors.grey,
              backgroundImage: subscriber.photoUrl != null
                  ? CachedNetworkImageProvider(subscriber.photoUrl)
                  : AssetImage('assets/images/default_profile.png'),
            ),
            SizedBox(height: 5.0),
            GestureDetector(
              child: Text(
                referralCode != null ? referralCode : 'NOT VERIFIED',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              onTap: () {
                Clipboard.setData(new ClipboardData(text: referralCode));
              },
            ),
          ],
        ),
      ),
      Expanded(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
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
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
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
                      SizedBox(height: 8.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

buildLoading() {
  return Center(
    child: JumpingDotsProgressIndicator(
      fontSize: 50.0,
    ),
  );
}

buildPlatinumLoaded(
    BuildContext context, Platinum subscriberPlatinum, Function toggleBanner) {
  if (subscriberPlatinum.status == 'pending') {
    return buildPendingPlatinum(context, toggleBanner);
  }

  final endDate =
      subscriberPlatinum.startDate.toDate().add(Duration(days: 1095));
  num monthlyInterest = subscriberPlatinum.capital * .12;

  return Column(
    children: [
      Material(
        elevation: 10.0,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5.0),
          color: Colors.blue[900],
          child: Center(
            child: Text(
              'PLATINUM',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontSize: 16.0,
              ),
            ),
          ),
        ),
      ),
      Expanded(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: FaIcon(
                                    FontAwesomeIcons.piggyBank,
                                    size: 14.0,
                                    color: Colors.blue[900],
                                  ),
                                ),
                                SizedBox(width: 4.0),
                                Text(
                                  oCcy.format(subscriberPlatinum.capital),
                                  style: TextStyle(
                                    color: Colors.blue[900],
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text('Piggy Bank'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              DateFormat('MMM. dd, yyyy').format(
                                subscriberPlatinum.startDate.toDate(),
                              ),
                              style: TextStyle(
                                color: Colors.blue[900],
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            Text('Date Started'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: FaIcon(
                                    FontAwesomeIcons.coins,
                                    size: 14.0,
                                    color: Colors.blue[900],
                                  ),
                                ),
                                SizedBox(width: 4.0),
                                Text(
                                  oCcy.format(monthlyInterest),
                                  style: TextStyle(
                                    color: Colors.blue[900],
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text('Monthly Coins'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              DateFormat('MMM. dd, yyyy').format(endDate),
                              style: TextStyle(
                                color: Colors.blue[900],
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            Text('End Date'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: StyledButton(
                          labelText: 'TOP UP COINS',
                          onPressed: () =>
                              handleSubscribe(context, toggleBanner),
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Expanded(
                        child: StyledButton(
                          labelText: 'TOP UP HISTORY',
                          onPressed: () =>
                              handleViewPlatinumDeposits(context, toggleBanner),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

buildPendingPlatinum(BuildContext context, Function toggleBanner) {
  return Column(
    children: [
      Material(
        elevation: 10.0,
        child: Container(
          color: Colors.blue[900],
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              'PLATINUM',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontSize: 18.0,
              ),
            ),
          ),
        ),
      ),
      Expanded(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'PENDING',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 25.0,
                  ),
                  child: Text(
                    'Deposit(s) under verification process by admins and will reflect on your dashboard once verified.',
                    style: TextStyle(
                      fontSize: 13.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 5.0),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 55.0),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        handleViewPlatinumDeposits(context, toggleBanner),
                    child: Text(
                      'TOP UP HISTORY',
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
          ),
        ),
      ),
    ],
  );
}

handleViewPlatinumDeposits(context, Function toggleBanner) async {
  final authService = RepositoryProvider.of<AuthenticationService>(context);
  toggleBanner();
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PlatinumDepositListPage(authService.currentUserId),
    ),
  );
  toggleBanner();
}

handleSubscribe(BuildContext context, Function toggleBanner) async {
  toggleBanner();
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PlatinumDepositPage(),
    ),
  );
  toggleBanner();
}

buildPlatinumNotFound(
    BuildContext context, bool isVerified, Function toggleBanner) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.wallet_membership,
          size: 70.0,
          color: Colors.blue[900],
        ),
        SizedBox(height: 10.0),
        Text(
          'NO PLATINUM SAVINGS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.blue[900],
            fontSize: 18.0,
          ),
        ),
        Padding(
            padding: EdgeInsets.only(
              left: 35.0,
              right: 35.0,
              bottom: isVerified ? 10.0 : 0,
            ),
            child: Text(
              isVerified
                  ? 'Deposit a capital amount to subscribe and earn monthly interest for 3 years'
                  : 'You can subscriber after your account is verified',
              textAlign: TextAlign.center,
            )),
        Visibility(
          visible: isVerified,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 55.0),
            child: StyledButton(
              labelText: 'SUBSCRIBE',
              onPressed: () => handleSubscribe(context, toggleBanner),
            ),
          ),
        ),
      ],
    ),
  );
}

buildWalletLoaded(BuildContext context, Wallet subscriberWallet,
    Platinum platinum, Function toggleBanner, DateTime currentDate) {
  return DefaultTabController(
    length: 3,
    child: Column(
      children: <Widget>[
        TabBar(
          labelColor: Colors.blue[900],
          unselectedLabelColor: Colors.grey[700],
          indicatorColor: Colors.blue[900],
          labelStyle: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
          ),
          tabs: [
            Tab(
              text: 'Electronic'.toUpperCase(),
            ),
            Tab(
              text: 'Referral'.toUpperCase(),
            ),
            Tab(
              text: 'Loyalty'.toUpperCase(),
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            children: [
              buildElectronicWallet(
                electronic: subscriberWallet.electronic,
                platinum: platinum,
                onPressed: () => showCashOutPage(
                    context, subscriberWallet, 'electronic', toggleBanner),
                currentDate: currentDate,
              ),
              buildWalletItem(
                amount: subscriberWallet.referral.amount,
                wallet: 'referral',
                lastUpdate: subscriberWallet.referral.lastUpdate?.toDate() ??
                    currentDate,
                onPressed: () => showCashOutPage(
                    context, subscriberWallet, 'referral', toggleBanner),
                currentDate: currentDate,
              ),
              buildWalletItem(
                amount: subscriberWallet.loyalty.amount,
                wallet: 'loyalty',
                lastUpdate: subscriberWallet.loyalty.lastUpdate?.toDate() ??
                    currentDate,
                onPressed: () => showCashOutPage(
                    context, subscriberWallet, 'loyalty', toggleBanner),
                currentDate: currentDate,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Text(
              'Total Accumulated: ${oCcy.format(subscriberWallet.electronic.amount + subscriberWallet.loyalty.amount + subscriberWallet.referral.amount)}'),
        )
      ],
    ),
  );
}

showCashOutPage(BuildContext context, Wallet subscriberWallet, String wallet,
    Function toggleBanner) async {
  toggleBanner();
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CashOutPage(subscriberWallet, wallet),
    ),
  );
  toggleBanner();
}

buildElectronicWallet(
    {Electronic electronic,
    Platinum platinum,
    Function onPressed,
    DateTime currentDate}) {
  bool isWithdrawable = false;

  if (platinum != null && platinum.status == 'active' && currentDate != null) {
    final monthDifference =
        currentDate.difference(platinum.startDate.toDate()).inDays / 30;

    final currentHour = currentDate.hour;

    if (currentDate.weekday == DateTime.monday) {
      isWithdrawable = (currentHour >= 9 && currentHour < 17);

      if (electronic.lastRedeem != null) {
        final daysSinceLastRedeem =
            currentDate.difference(electronic.lastRedeem.toDate()).inDays;

        isWithdrawable = daysSinceLastRedeem > 30;
      } else {
        isWithdrawable = monthDifference >= 1;
      }
    }
  }

  return Center(
    child: ListView(
      shrinkWrap: true,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: FaIcon(
                FontAwesomeIcons.coins,
                size: 14.0,
                color: Colors.blue[900],
              ),
            ),
            SizedBox(width: 4.0),
            Text(
              oCcy.format(electronic.amount.round()),
              style: TextStyle(
                color: Colors.blue[900],
                fontSize: 34.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          'Last updated ${timeago.format(electronic.lastUpdate == null ? currentDate : electronic.lastUpdate.toDate())}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.0,
          ),
        ),
        SizedBox(height: 10.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 65.0),
          child: StyledButton(
            labelText: 'REDEEM',
            onPressed:
                electronic.amount > 0 && isWithdrawable ? onPressed : null,
            // onPressed: onPressed,
          ),
        ),
      ],
    ),
  );
}

Widget buildWalletItem(
    {num amount,
    String wallet,
    DateTime lastUpdate,
    Function onPressed,
    DateTime currentDate}) {
  final currentDay = currentDate.weekday;
  final currentHour = currentDate.hour;

  var canRedeem = false;
  if (currentDay == DateTime.monday) {
    if (currentHour >= 9 && currentHour < 17) {
      canRedeem = true;
    }
  }

  return Center(
    child: ListView(
      shrinkWrap: true,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              oCcy.format(amount),
              style: TextStyle(
                color: Colors.blue[900],
                fontSize: 34.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 4.0),
            Align(
              alignment: Alignment.center,
              child: Text(
                'points',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.blue[900],
                ),
              ),
            ),
          ],
        ),
        Text(
          'Last updated ${timeago.format(lastUpdate)}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.0,
          ),
        ),
        SizedBox(height: 10.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 65.0),
          child: StyledButton(
            labelText: 'REDEEM',
            onPressed: amount > 0 && canRedeem ? onPressed : null,
            // onPressed: onPressed,
          ),
        ),
      ],
    ),
  );
}

buildWalletNotFound() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_sharp,
          size: 70.0,
          color: Colors.blue[900],
        ),
        SizedBox(height: 10.0),
        Text(
          'WALLET NOT FOUND',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.blue[900],
            fontSize: 18.0,
          ),
        ),
        Text('Your account is not yet verified'),
      ],
    ),
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
