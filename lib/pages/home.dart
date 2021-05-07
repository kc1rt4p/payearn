import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:payearn_app/widgets/payearn_logo.dart';
import 'daily_quotes.dart';

import '../data/bloc/authentication_bloc.dart';
import '../data/models/account.dart';
import '../data/models/subscriber.dart';
import '../services/authentication.dart';
import '../widgets/styled_text_field.dart';
import 'chat.dart';
import 'dashboard.dart';
import 'profile.dart';
import 'subscribers.dart';
import 'transaction_history.dart';
// import 'settings.dart';

final walletsRef = FirebaseFirestore.instance.collection('wallets');
final subscribersRef = FirebaseFirestore.instance.collection('subscribers');
final cashOutsRef = FirebaseFirestore.instance.collection('cashOuts');

class HomePage extends StatefulWidget {
  final Account account;
  final Subscriber subscriber;

  HomePage(this.account, this.subscriber);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final globalKey = GlobalKey<ScaffoldState>();
  PageController pageController = PageController();
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = RepositoryProvider.of<AuthenticationService>(context);
    List<Widget> pageViewItems = [
      DashboardPage(),
      SubscribersPage(),
      ProfilePage(subscriberId: widget.subscriber.id),
      ChatPage(subscriberId: widget.subscriber.id),
      TransactionHistoryPage(),
      DailyQuotesPage(),
      // SettingsPage(),
    ];

    return Scaffold(
      key: globalKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 150.0,
              child: DrawerHeader(
                child: PayEarnLogo(size: 50.0),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Align(
                alignment: Alignment.centerLeft,
                child: Text('Dashboard'),
              ),
              selected: pageIndex == 0,
              onTap: () {
                Navigator.of(context).pop();
                pageController.animateToPage(
                  0,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
            Visibility(
              visible: authService.currentUserType != 'subscriber',
              child: ListTile(
                leading: Icon(Icons.people),
                title: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Subscribers'),
                ),
                selected: pageIndex == 1,
                onTap: () {
                  Navigator.of(context).pop();
                  pageController.animateToPage(
                    1,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Align(
                alignment: Alignment.centerLeft,
                child: Text('Profile'),
              ),
              selected: pageIndex == 2,
              onTap: () {
                Navigator.of(context).pop();
                pageController.animateToPage(
                  2,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('Chat'),
              selected: pageIndex == 3,
              onTap: () {
                Navigator.of(context).pop();
                pageController.animateToPage(
                  3,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
            ListTile(
              leading: FaIcon(
                  authService.currentUserType != 'subscriber'
                      ? FontAwesomeIcons.moneyBill
                      : FontAwesomeIcons.history,
                  size: 20.0),
              title: authService.currentUserType == 'subscriber'
                  ? Text('Transaction History')
                  : Text('Redeem Requests'),
              selected: pageIndex == 4,
              onTap: () {
                Navigator.of(context).pop();
                pageController.animateToPage(
                  4,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.format_quote),
              title: Text('Daily Quotes'),
              selected: pageIndex == 5,
              onTap: () {
                Navigator.of(context).pop();
                pageController.animateToPage(
                  5,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
            // Visibility(
            //   visible: authService.currentUserType == 'super',
            //   child: ListTile(
            //     leading: Icon(Icons.settings),
            //     title: Text('Settings'),
            //     selected: pageIndex == 6,
            //     onTap: () {
            //       Navigator.of(context).pop();
            //       pageController.animateToPage(
            //         6,
            //         duration: Duration(milliseconds: 300),
            //         curve: Curves.easeInOut,
            //       );
            //     },
            //   ),
            // ),
            // ListTile(
            //   leading: FaIcon(FontAwesomeIcons.key),
            //   title: Text('WALLET TO ZERO'),
            //   onTap: () => walletToZero(),
            // ),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.key),
              title: Text('Change Password'),
              onTap: () {
                Navigator.of(context).pop();
                handleChangePassword(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.of(context).pop();
                handleLogout(context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'PayEarn',
          style: TextStyle(
            fontFamily: 'Signatra',
            fontSize: 45.0,
            letterSpacing: 2.0,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              children: pageViewItems,
              controller: pageController,
              onPageChanged: onPageChanged,
              physics: NeverScrollableScrollPhysics(),
            ),
          ),
        ],
      ),
    );
  }
}

changePassword(String password) {}

handleChangePassword(BuildContext context) async {
  final authService = RepositoryProvider.of<AuthenticationService>(context);
  TextEditingController currentPasswordCtrl = TextEditingController();
  TextEditingController newPasswordCtrl = TextEditingController();
  TextEditingController confirmPasswordCtrl = TextEditingController();
  final passwordKey = GlobalKey<FormState>();

  Widget cancelButton = ElevatedButton(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(Colors.red[900]),
    ),
    child: Text(
      'Cancel',
      style: TextStyle(
        color: Colors.white,
      ),
    ),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  Widget okButton = ElevatedButton(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(Colors.blue[900]),
    ),
    child: Text(
      'Submit',
      style: TextStyle(
        color: Colors.white,
      ),
    ),
    onPressed: () async {
      if (!passwordKey.currentState.validate()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please check errors to proceed'),
            backgroundColor: Colors.red[600],
          ),
        );

        return;
      }

      final changed = await authService.changePassword(
          authService.currentUserId, newPasswordCtrl.text.trim());

      if (changed) {
        Navigator.of(context).pop();
        BlocProvider.of<AuthenticationBloc>(context).add(UserLoggedOut());
      }
    },
  );

  SimpleDialog alert = SimpleDialog(
    contentPadding: EdgeInsets.all(20.0),
    title: Text(
      'Change Password',
      style: TextStyle(
        color: Colors.blue[900],
      ),
    ),
    children: [
      Form(
        key: passwordKey,
        child: Column(
          children: [
            Text('You will be logged out after your password changes.'),
            SizedBox(height: 20.0),
            StyledTextField(
              controller: currentPasswordCtrl,
              label: 'Current Password',
              isPassword: true,
              validator: (String value) {
                if (value != authService.currentAccount.password) {
                  return 'Invalid Password';
                } else {
                  return null;
                }
              },
            ),
            SizedBox(height: 10.0),
            StyledTextField(
              controller: newPasswordCtrl,
              label: 'New Password',
              isPassword: true,
              validator: (String value) {
                if (value.length < 6 || value.length > 20) {
                  return 'Should be atleast 6 to 20 characters';
                } else {
                  return null;
                }
              },
            ),
            SizedBox(height: 10.0),
            StyledTextField(
              controller: confirmPasswordCtrl,
              label: 'Confirm Password',
              isPassword: true,
              validator: (value) {
                if (value != newPasswordCtrl.text.trim()) {
                  return 'Does not match new password';
                } else {
                  return null;
                }
              },
            ),
            SizedBox(height: 20.0),
            Row(
              children: [
                Expanded(
                  child: cancelButton,
                ),
                SizedBox(width: 5.0),
                Expanded(
                  child: okButton,
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

// walletToZero() async {
//   /** TURN ALL WALLETS TO ZERO */
//   final subscriberListSnapshot = await subscribersRef.get();
//   final subscriberList =
//       subscriberListSnapshot.docs.map((doc) => Subscriber.fromDocument(doc));
//   final verifiedSubscribers =
//       subscriberList.where((subscriber) => subscriber.isVerified);

//   print('Number of verified subscribers: ${verifiedSubscribers.length}');

//   num affectedSubscribers = 0;

//   for (var subscriber in verifiedSubscribers) {
//     final id = subscriber.id;
//     final walletDoc = await walletsRef.doc(id).get();
//     final wallet = Wallet.fromDocument(walletDoc);

//     bool affected = false;

//     if (wallet.electronic.amount >= 1) {
//       affected = true;
//       final cashOutDoc = await cashOutsRef.doc(id).get();

//       if (!cashOutDoc.exists) {
//         final subscriberDoc = await subscribersRef.doc(id).get();
//         final subscriber = Subscriber.fromDocument(subscriberDoc);

//         await cashOutsRef.doc(id).set({
//           'requestor': '${subscriber.firstName} ${subscriber.lastName}',
//           'lastRequestDate': FieldValue.serverTimestamp(),
//         });
//       }

//       await cashOutsRef.doc(id).update({
//         'lastRequestDate': FieldValue.serverTimestamp(),
//       });

//       await cashOutsRef.doc(id).collection('requests').add({
//         'amount': wallet.electronic.amount,
//         'wallet': 'electronic',
//         'type': 'withdraw',
//         'paymentMethod': 'TO BE ADDED',
//         'paymentOption': 'TO BE ADDED',
//         'accountName': '${subscriber.firstName} ${subscriber.lastName}',
//         'accountNumber': subscriber.mobile,
//         'dateRequested': FieldValue.serverTimestamp(),
//         'subscriberId': subscriber.id,
//         'status': 'pending',
//         'dateApproved': null,
//         'dateClaimed': null,
//         'dateRejected': null,
//         'depositPhotoUrl': null,
//       });

//       await walletsRef.doc(id).update({
//         'electronic.amount': FieldValue.increment(-wallet.electronic.amount),
//         'electronic.lastUpdate': FieldValue.serverTimestamp(),
//         'electronic.lastRedeem': FieldValue.serverTimestamp(),
//       });
//     }

//     if (wallet.loyalty.amount >= 1) {
//       affected = true;
//       final cashOutDoc = await cashOutsRef.doc(id).get();

//       if (!cashOutDoc.exists) {
//         final subscriberDoc = await subscribersRef.doc(id).get();
//         final subscriber = Subscriber.fromDocument(subscriberDoc);

//         await cashOutsRef.doc(id).set({
//           'requestor': '${subscriber.firstName} ${subscriber.lastName}',
//           'lastRequestDate': FieldValue.serverTimestamp(),
//         });
//       }

//       await cashOutsRef.doc(id).update({
//         'lastRequestDate': FieldValue.serverTimestamp(),
//       });

//       await cashOutsRef.doc(id).collection('requests').add({
//         'amount': wallet.loyalty.amount,
//         'wallet': 'loyalty',
//         'type': 'withdraw',
//         'paymentMethod': 'TO BE ADDED',
//         'paymentOption': 'TO BE ADDED',
//         'accountName': '${subscriber.firstName} ${subscriber.lastName}',
//         'accountNumber': subscriber.mobile,
//         'dateRequested': FieldValue.serverTimestamp(),
//         'subscriberId': subscriber.id,
//         'status': 'pending',
//         'dateApproved': null,
//         'dateClaimed': null,
//         'dateRejected': null,
//         'depositPhotoUrl': null,
//       });

//       await walletsRef.doc(id).update({
//         'loyalty.amount': FieldValue.increment(-wallet.electronic.amount),
//         'loyalty.lastUpdate': FieldValue.serverTimestamp(),
//         'loyalty.lastRedeem': FieldValue.serverTimestamp(),
//       });
//     }

//     if (wallet.referral.amount >= 1) {
//       affected = true;
//       final cashOutDoc = await cashOutsRef.doc(id).get();

//       if (!cashOutDoc.exists) {
//         final subscriberDoc = await subscribersRef.doc(id).get();
//         final subscriber = Subscriber.fromDocument(subscriberDoc);

//         await cashOutsRef.doc(id).set({
//           'requestor': '${subscriber.firstName} ${subscriber.lastName}',
//           'lastRequestDate': FieldValue.serverTimestamp(),
//         });
//       }

//       await cashOutsRef.doc(id).update({
//         'lastRequestDate': FieldValue.serverTimestamp(),
//       });

//       await cashOutsRef.doc(id).collection('requests').add({
//         'amount': wallet.referral.amount,
//         'wallet': 'referral',
//         'type': 'withdraw',
//         'paymentMethod': 'TO BE ADDED',
//         'paymentOption': 'TO BE ADDED',
//         'accountName': '${subscriber.firstName} ${subscriber.lastName}',
//         'accountNumber': subscriber.mobile,
//         'dateRequested': FieldValue.serverTimestamp(),
//         'subscriberId': subscriber.id,
//         'status': 'pending',
//         'dateApproved': null,
//         'dateClaimed': null,
//         'dateRejected': null,
//         'depositPhotoUrl': null,
//       });

//       await walletsRef.doc(id).update({
//         'referral.amount': FieldValue.increment(-wallet.electronic.amount),
//         'referral.lastUpdate': FieldValue.serverTimestamp(),
//         'referral.lastRedeem': FieldValue.serverTimestamp(),
//       });
//     }
//     if (affected) affectedSubscribers += 1;
//   }
//   print('Affected Subscribers: $affectedSubscribers');
// }

handleLogout(context) async {
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
      BlocProvider.of<AuthenticationBloc>(context).add(UserLoggedOut());
      Navigator.of(context).pop();
    },
  );

  AlertDialog alert = AlertDialog(
    title: Text(
      'Confirm Logout',
      style: TextStyle(
        color: Colors.white,
      ),
    ),
    content: Text(
      'Are you sure you want to logout?',
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
