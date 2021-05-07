import 'dart:io';

import 'package:appodeal_flutter/appodeal_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../data/bloc/platinum_deposit_bloc.dart';
import '../data/models/payment_method.dart';
import '../services/authentication.dart';
import '../widgets/heartbeat_loading.dart';
import '../widgets/image_selector.dart';
import '../widgets/styled_button.dart';

File _depositPhoto;
TextEditingController amountCtrl = TextEditingController();
final _depositFormKey = GlobalKey<FormState>();

class PlatinumDepositPage extends StatefulWidget {
  @override
  _PlatinumDepositPageState createState() => _PlatinumDepositPageState();
}

class _PlatinumDepositPageState extends State<PlatinumDepositPage> {
  List<PaymentMethod> paymentMethods;
  PaymentMethod _selectedPaymentMethod;
  String _selectedPaymentOption;

  @override
  void dispose() {
    super.dispose();
    _depositPhoto = null;
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

  selectPhoto(BuildContext context) async {
    File picked = await ImageSelect(titleText: 'Select Deposit Photo')
        .selectImage(context);

    if (picked != null) {
      setState(() {
        _depositPhoto = picked;
      });
    }
  }

  handleSubmit(BuildContext context) {
    final authService = RepositoryProvider.of<AuthenticationService>(context);

    if (!_depositFormKey.currentState.validate()) {
      return;
    }

    if (_depositPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select your deposit photo'),
          backgroundColor: Colors.red[600],
        ),
      );
      return;
    }

    final platinumDepositData = {
      'amount': double.tryParse(amountCtrl.text.trim()),
      'paymentMethod': _selectedPaymentMethod.name,
      'paymentOption': _selectedPaymentOption,
      'isVerified': false,
    };

    BlocProvider.of<PlatinumDepositBloc>(context).add(PlatinumDepositAdd(
        authService.currentUserId, platinumDepositData, _depositPhoto));
  }

  buildPlatinumDepositInitialized(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Form(
                key: _depositFormKey,
                child: Column(
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
                            if (amount != null) {
                              if (amount < 500) {
                                return 'Should be at least 500';
                              } else if (amount > 100000) {
                                return 'Should not be larger than 100,000';
                              }
                            } else {
                              return 'Please enter an amount';
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
                          'Top Up Method:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 10.0),
                        Expanded(
                          child: buildDropdownPaymentMethods(context),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Top Up Option:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 10.0),
                        Expanded(
                          child: buildDropdownPaymentOptions(),
                        ),
                      ],
                    ),
                    SizedBox(height: 25.0),
                    Container(
                      color: Colors.blue[200],
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Text(
                            'Deposit Photo',
                          ),
                          SizedBox(height: 10.0),
                          SizedBox(
                            child: Stack(
                              children: [
                                _depositPhoto != null
                                    ? Image.file(_depositPhoto)
                                    : Image(
                                        image: AssetImage(
                                          'assets/images/default_image.jpg',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                Positioned(
                                  right: -15,
                                  bottom: 10,
                                  child: RawMaterialButton(
                                    fillColor: Colors.grey[100],
                                    onPressed: () => selectPhoto(context),
                                    shape: CircleBorder(),
                                    child: Icon(Icons.camera_alt),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 25.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 45.0),
              child: StyledButton(
                labelText: 'SUBMIT',
                onPressed: () => handleSubmit(context),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        title: Text('Top Up Coins'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Center(
            child: AppodealBanner(
              placementName: 'TopUpPage',
            ),
          ),
          Expanded(
            child: BlocProvider<PlatinumDepositBloc>(
              create: (context) =>
                  PlatinumDepositBloc()..add(PlatinumDepositInitialize()),
              child: BlocListener<PlatinumDepositBloc, PlatinumDepositState>(
                listener: (context, state) {
                  if (state is PlatinumDepositInitialized) {
                    paymentMethods = state.paymentMethods;
                    _selectedPaymentMethod = paymentMethods[0];
                    _selectedPaymentOption = _selectedPaymentMethod.options[0];
                  }

                  if (state is PlatinumDepositAdded) {
                    amountCtrl.clear();
                    _depositPhoto = null;

                    Appodeal.show(AdType.INTERSTITIAL);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Your top up has been submitted'),
                        backgroundColor: Colors.green[600],
                      ),
                    );
                  }
                },
                child: BlocBuilder<PlatinumDepositBloc, PlatinumDepositState>(
                  builder: (context, state) {
                    if (state is PlatinumDepositInitialized) {
                      return buildPlatinumDepositInitialized(context);
                    }

                    if (state is PlatinumDepositAdded) {
                      return buildPlatinumDepositAdded(context);
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

buildPlatinumDepositAdded(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FaIcon(
          FontAwesomeIcons.checkCircle,
          size: 150.0,
          color: Colors.blue,
        ),
        SizedBox(
          height: 20.0,
        ),
        Text(
          'DEPOSIT SUBMITTED',
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
              'Your deposit will be reviewed, the amount will reflect on your dashboard once an admin verify it',
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
