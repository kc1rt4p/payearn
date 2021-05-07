import 'package:appodeal_flutter/appodeal_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../data/bloc/cash_out_bloc.dart';
import '../data/models/payment_method.dart';
import '../data/models/reward.dart';
import '../data/models/wallet.dart';
import '../services/authentication.dart';
import '../widgets/heartbeat_loading.dart';
import '../widgets/profile_text_field.dart';
import '../widgets/styled_button.dart';

final oCcy = new NumberFormat("#,##0.00", "en_US");

TextEditingController amountCtrl = TextEditingController();
TextEditingController accountNameCtrl = TextEditingController();
TextEditingController accountNumberCtrl = TextEditingController();
final _cashOutFormKey = GlobalKey<FormState>();

class CashOutPage extends StatefulWidget {
  final Wallet wallet;
  final String walletName;

  const CashOutPage(this.wallet, this.walletName) : super();

  @override
  _CashOutPageState createState() => _CashOutPageState();
}

class _CashOutPageState extends State<CashOutPage>
    with SingleTickerProviderStateMixin {
  TabController tabController;
  String _selectedReward;
  String _selectedNetwork;
  String _selectedRewardType;
  num _selectedLoadAmount;
  List<PaymentMethod> paymentMethods;
  PaymentMethod _selectedPaymentMethod;
  String _selectedPaymentOption;

  List<Reward> rewards = [
    Reward(
      'mbload',
      'Mobile Load',
      10,
    ),
    Reward(
      'mbphone',
      'Mobile Phone',
      13000,
    ),
    Reward(
      'lptp',
      'Laptop',
      30000,
    ),
    Reward(
      'mtrcycl',
      'Honda Beat (Motorcycle)',
      50000,
    ),
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    _selectedReward = rewards[0].id;
    _selectedNetwork = 'globe';
    _selectedLoadAmount = 10;
    _selectedRewardType = 'withdraw';
    tabController.addListener(() {
      if (tabController.index == 0) {
        _selectedRewardType = 'withdraw';
      } else {
        _selectedRewardType = 'convert';
      }
    });
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  handlePaymentMethodOnChanged(PaymentMethod method) {
    setState(() {
      _selectedPaymentMethod = method;
      _selectedPaymentOption = method.options[0];
    });
  }

  buildDropdownPaymentMethods(BuildContext context) {
    return DropdownButton(
      value: _selectedPaymentMethod,
      isExpanded: true,
      items: paymentMethods.map<DropdownMenuItem>((method) {
        return DropdownMenuItem(
          value: method,
          child: Text(
            method.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
      onChanged: (method) {
        setState(() {
          setState(() {
            _selectedPaymentMethod = method;
            _selectedPaymentOption = method.options[0];
          });
        });
      },
      underline: Container(
        height: 2.0,
        color: Colors.black,
      ),
    );
  }

  buildDropdownPaymentOptions() {
    return DropdownButton(
      value: _selectedPaymentOption,
      isExpanded: true,
      items: _selectedPaymentMethod.options.map<DropdownMenuItem>((option) {
        return DropdownMenuItem(
          value: option,
          child: Text(
            option,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
      onChanged: (option) {
        setState(() {
          _selectedPaymentOption = option;
        });
      },
      underline: Container(
        height: 2.0,
        color: Colors.black,
      ),
    );
  }

  buildCashOutInitial(BuildContext context, Wallet wallet, String walletName) {
    num walletBalance;

    switch (walletName) {
      case 'referral':
        walletBalance = wallet.referral.amount;
        break;
      case 'loyalty':
        walletBalance = wallet.loyalty.amount;
        break;
      case 'electronic':
        walletBalance = wallet.electronic.amount;
        break;
    }

    return Container(
      child: Column(
        children: <Widget>[
          TabBar(
            controller: tabController,
            labelColor: Colors.blue[900],
            unselectedLabelColor: Colors.grey[700],
            indicatorColor: Colors.blue[900],
            labelStyle: TextStyle(
              fontSize: 12.0,
            ),
            tabs: [
              Tab(
                text: 'WITHDRAW',
              ),
              Tab(
                text: 'CONVERT',
              ),
            ],
            onTap: (index) {
              if (widget.walletName != 'loyalty') {
                tabController.index = tabController.previousIndex;
              }
            },
          ),
          SizedBox(height: 10.0),
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Column(
              children: [
                Center(
                  child: Text(
                    walletName.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                      oCcy.format(walletBalance.round()),
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: tabController,
              children: [
                buildWithdrawForm(walletName, walletBalance, context),
                buildRewardShop(context, walletBalance),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: StyledButton(
              labelText: 'SUBMIT REQUEST',
              color: Colors.white,
              onPressed: () => handleSubmitRequest(context),
            ),
          ),
        ],
      ),
    );
  }

  buildNetworkDropdown(BuildContext context) {
    List<String> networks = ['globe', 'smart', 'tnt'];
    return DropdownButton(
      isExpanded: true,
      value: _selectedNetwork,
      items: networks.map((network) {
        return DropdownMenuItem(
          value: network,
          child: Center(
            child: Text(
              network.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
      onChanged: (network) {
        setState(() {
          _selectedNetwork = network;
        });
      },
    );
  }

  buildLoadAmountDropdown(BuildContext context, num walletBalance) {
    List<num> loads = [10, 20, 30, 50, 100, 200];
    return DropdownButton(
      isExpanded: true,
      value: _selectedLoadAmount,
      items: loads.map((amount) {
        return DropdownMenuItem(
          value: amount,
          child: Center(
            child: Text(
              amount.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
      onChanged: (amount) {
        if (walletBalance < amount) {
          return null;
        }
        setState(() {
          _selectedLoadAmount = amount;
        });
      },
    );
  }

  buildRewardShop(BuildContext context, num walletBalance) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: ListView(
              shrinkWrap: true,
              children: rewards.map((reward) {
                return ListTile(
                  title: Text(reward.name),
                  subtitle: reward.price > 10
                      ? Text('${oCcy.format(reward.price)} points')
                      : null,
                  leading: Radio(
                    activeColor: Colors.blue[900],
                    groupValue: _selectedReward,
                    value: reward.id,
                    onChanged: reward.price <= walletBalance
                        ? (String value) {
                            setState(() {
                              _selectedReward = value;
                            });
                          }
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Visibility(
          visible: _selectedReward == 'mbload',
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: buildNetworkDropdown(context),
                      ),
                      SizedBox(width: 5.0),
                      Expanded(
                        child: buildLoadAmountDropdown(context, walletBalance),
                      ),
                    ],
                  ),
                  ProfileTextField(
                    controller: accountNumberCtrl,
                    labelText: 'Mobile Number',
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.center,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Enter your mobile number';
                      }

                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Form buildWithdrawForm(
      String walletName, num walletBalance, BuildContext context) {
    return Form(
      key: _cashOutFormKey,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 45.0),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              Stack(
                children: [
                  TextFormField(
                    maxLines: null,
                    controller: amountCtrl,
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                    ),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          width: 2.0,
                        ),
                      ),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      double amount = double.tryParse(value);
                      double balance = walletBalance.roundToDouble();
                      if (amount != null) {
                        if (amount > balance) {
                          return 'Insufficient balance';
                        }
                      } else {
                        return 'Please enter an amount';
                      }

                      if (walletName == 'electronic') {
                        if (amount != balance.round()) {
                          return 'Should be equal to your total e-wallet coins';
                        }
                      }

                      if (walletName == 'loyalty') {
                        if (amount < 2000) {
                          return 'Minimum redeem from loyalty wallet is 2,000 points';
                        }
                      }

                      if (walletName == 'referral') {
                        if (amount < 200) {
                          return 'Minimum redeem from referral wallet is 200 coins';
                        }
                      }

                      return null;
                    },
                  ),
                  Positioned(
                    top: 20,
                    child: FaIcon(
                      FontAwesomeIcons.coins,
                      size: 18.0,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 25.0),
              Row(
                children: [
                  Text(
                    'Redeem Method:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: buildDropdownPaymentMethods(context),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Row(
                children: [
                  Text(
                    'Redeem Option:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: buildDropdownPaymentOptions(),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: accountNameCtrl,
                decoration: InputDecoration(
                  hintText: 'Account Name',
                  labelStyle: TextStyle(
                    color: Colors.black,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 2.0,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Enter your account name';
                  }

                  return null;
                },
              ),
              SizedBox(height: 10.0),
              TextFormField(
                controller: accountNumberCtrl,
                decoration: InputDecoration(
                  hintText: 'Account Number',
                  labelStyle: TextStyle(
                    color: Colors.black,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 2.0,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Enter your account number';
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildCashOutAdded() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.paperPlane,
            size: 150.0,
            color: Colors.blue,
          ),
          SizedBox(
            height: 20.0,
          ),
          Text(
            'REQUEST SUBMITTED',
            style: TextStyle(
              color: Colors.blue[900],
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Your redeem request has been submitted.\nAn admin will review your request.\nA message will be sent after.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(
            height: 50.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 60.0,
            ),
            child: Material(
              elevation: 5.0,
              borderRadius: BorderRadius.circular(32.0),
              color: Colors.indigoAccent,
              child: MaterialButton(
                minWidth: MediaQuery.of(context).size.width,
                padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  handleSubmitRequest(context) {
    final authService = RepositoryProvider.of<AuthenticationService>(context);

    Map<String, dynamic> cashOutData;

    if (_selectedRewardType == 'withdraw') {
      if (!_cashOutFormKey.currentState.validate()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter required data'),
            backgroundColor: Colors.red[600],
          ),
        );
        return;
      }

      cashOutData = {
        'amount': double.tryParse(amountCtrl.text.trim()),
        'wallet': widget.walletName,
        'type': 'withdraw',
        'paymentMethod': _selectedPaymentMethod.name,
        'paymentOption': _selectedPaymentOption,
        'accountName': accountNameCtrl.text.trim(),
        'accountNumber': accountNumberCtrl.text.trim(),
        'dateRequested': FieldValue.serverTimestamp(),
        'subscriberId': authService.currentUserId,
        'status': 'pending',
        'dateApproved': null,
        'dateClaimed': null,
        'dateRejected': null,
        'depositPhotoUrl': null,
      };
    } else {
      if (widget.wallet.loyalty.amount < 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Insufficient points to convert'),
            backgroundColor: Colors.red[600],
          ),
        );
        return;
      }
      final reward =
          rewards.singleWhere((reward) => reward.id == _selectedReward);
      final amount =
          _selectedReward == 'mbload' ? _selectedLoadAmount : reward.price;

      cashOutData = {
        'amount': amount,
        'wallet': widget.walletName,
        'type': 'convert',
        'paymentMethod': 'Redeem',
        'paymentOption': reward.name,
        'accountName': _selectedReward == 'mbload'
            ? _selectedNetwork.toUpperCase()
            : '${authService.currentSubscriber.firstName} ${authService.currentSubscriber.lastName}',
        'accountNumber': accountNumberCtrl.text.isNotEmpty
            ? accountNumberCtrl.text.trim()
            : authService.currentSubscriber.mobile,
        'dateRequested': FieldValue.serverTimestamp(),
        'subscriberId': authService.currentUserId,
        'status': 'pending',
        'dateApproved': null,
        'dateClaimed': null,
        'dateRejected': null,
        'depositPhotoUrl': null,
      };
    }

    BlocProvider.of<CashOutBloc>(context)
        .add(CashOutAdd(authService.currentUserId, cashOutData));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        title: Text('REDEEM POINTS REQUEST'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: AppodealBanner(
              placementName: 'TopUpPage',
            ),
          ),
          Expanded(
            child: BlocProvider<CashOutBloc>(
              create: (context) => CashOutBloc()..add(CashOutInitialize()),
              child: BlocListener<CashOutBloc, CashOutState>(
                listener: (context, state) {
                  if (state is CashOutInitialized) {
                    paymentMethods = state.paymentMethods;
                    _selectedPaymentMethod = paymentMethods[0];
                    _selectedPaymentOption = _selectedPaymentMethod.options[0];
                  }

                  if (state is CashOutAdded) {
                    accountNameCtrl.clear();
                    accountNumberCtrl.clear();
                    amountCtrl.clear();

                    Appodeal.show(AdType.INTERSTITIAL);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Your request has been submitted'),
                        backgroundColor: Colors.green[600],
                      ),
                    );
                  }
                },
                child: BlocBuilder<CashOutBloc, CashOutState>(
                  builder: (context, state) {
                    if (state is CashOutInitialized) {
                      return buildCashOutInitial(
                          context, widget.wallet, widget.walletName);
                    }

                    if (state is CashOutAdded) {
                      return buildCashOutAdded();
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
