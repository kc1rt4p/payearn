import 'dart:io';

import 'package:appodeal_flutter/appodeal_flutter.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../data/bloc/authentication_bloc.dart';
import '../data/bloc/register_bloc.dart';
import '../services/authentication.dart';
import '../widgets/date_picker.dart';
import '../widgets/image_selector.dart';
import '../widgets/progress.dart';
import '../widgets/round_button.dart';
import '../widgets/styled_text_field.dart';

final _accountFormKey = GlobalKey<FormState>();
final _subscriberFormKey = GlobalKey<FormState>();
String _loadingMessage = '';

TextEditingController _usernameController = TextEditingController();
TextEditingController _passwordController = TextEditingController();
TextEditingController _referralCodeController = TextEditingController();
TextEditingController _password2Controller = TextEditingController();

TextEditingController _firstNameController = TextEditingController();
TextEditingController _lastNameController = TextEditingController();
TextEditingController _birthDateController = TextEditingController();
TextEditingController _emailController = TextEditingController();
TextEditingController _mobileController = TextEditingController();
TextEditingController _addressController = TextEditingController();
TextEditingController _workController = TextEditingController();
TextEditingController _workAddressController = TextEditingController();

DateTime _birthDate;
var _newAccount = new Map<String, dynamic>();
var _newSubscriber = new Map<String, dynamic>();
String _accountType = 'subscriber';

File _workPhoto;
File _profilePhoto;

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  void dispose() {
    super.dispose();

    // clear account form
    _accountFormKey.currentState?.reset();
    _usernameController.clear();
    _passwordController.clear();
    _referralCodeController.clear();
    _password2Controller.clear();

    // clear subscriber form
    _subscriberFormKey.currentState?.reset();
    _firstNameController.clear();
    _lastNameController.clear();
    _birthDateController.clear();
    _emailController.clear();
    _mobileController.clear();
    _addressController.clear();
    _workController.clear();
    _workAddressController.clear();

    // clear photos selected
    _workPhoto = null;
    _profilePhoto = null;
  }

  buildPhotosForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Card(
              child: Column(
                children: [
                  Expanded(
                    child: SizedBox(
                      child: _profilePhoto != null
                          ? Image.file(_profilePhoto)
                          : Image(
                              image: AssetImage(
                                'assets/images/default_image.jpg',
                              ),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => handleSelectPhoto(context, 'profile'),
                    child: Text(
                      _profilePhoto != null
                          ? 'REPLACE PROFILE PHOTO'
                          : 'SELECT PROFILE PHOTO',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Card(
              child: Column(
                children: [
                  Expanded(
                    child: SizedBox(
                      child: _workPhoto != null
                          ? Image.file(_workPhoto)
                          : Image(
                              image: AssetImage(
                                'assets/images/default_image.jpg',
                              ),
                              fit: BoxFit.fill,
                            ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => handleSelectPhoto(context, 'id'),
                    child: Text(
                      _workPhoto != null
                          ? 'REPLACE WORK ID PHOTO'
                          : 'SELECT WORK ID PHOTO',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: RoundButton(
                    color: Colors.indigo,
                    onPressed: () {
                      BlocProvider.of<RegisterBloc>(context)
                          .add(GetPersonalInformation());
                    },
                    labelText: 'BACK',
                    labelColor: Colors.white,
                  ),
                ),
                SizedBox(width: 5.0),
                Expanded(
                  child: RoundButton(
                    color: Colors.blue[900],
                    onPressed: () => handleSubmit(context),
                    labelText: 'SUBMIT',
                    labelColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  handleSelectPhoto(BuildContext context, String photoType) async {
    File picked = await ImageSelect(titleText: 'Select Profile Photo')
        .selectImage(context);

    if (picked != null) {
      setState(() {
        if (photoType == 'profile') {
          _profilePhoto = picked;
        } else {
          _workPhoto = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = RepositoryProvider.of<AuthenticationService>(context);
    final authBloc = BlocProvider.of<AuthenticationBloc>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('NEW SUBSCRIBER'),
      ),
      body: Column(
        children: [
          Center(
            child: AppodealBanner(
              placementName: 'RegisterPage',
            ),
          ),
          Expanded(
            child: BlocProvider<RegisterBloc>(
              create: (context) => RegisterBloc(authBloc, authService),
              child: BlocListener<RegisterBloc, RegisterState>(
                listener: (context, state) {
                  if (state is VerifyingCodeError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.error),
                        backgroundColor: Colors.red[600],
                      ),
                    );
                  }

                  if (state is VerifyingCode) {
                    setState(() {
                      _loadingMessage = 'Verifying referral code';
                    });
                  }

                  if (state is CreatingAccount) {
                    setState(() {
                      _loadingMessage = 'Creating account';
                    });
                  }

                  if (state is RegisterAccountTypeChanged) {
                    _accountType = state.type;
                  }

                  if (state is VerifiedCode) {
                    final String referrerId = state.referrerId;
                    _newAccount.addAll({
                      'username': _usernameController.text.trim(),
                      'password': _password2Controller.text.trim(),
                      'type': _accountType,
                      'referrerId': referrerId,
                    });
                  }
                },
                child: BlocBuilder<RegisterBloc, RegisterState>(
                  builder: (context, state) {
                    if (state is GettingAccountInfo) {
                      return buildAccountForm(context);
                    } else if (state is RegisterLoading) {
                      return buildLoading(context);
                    } else if (state is GettingPersonalInfo) {
                      return buildSubscriberForm(context);
                    } else if (state is GettingRequiredPhotos) {
                      return buildPhotosForm(context);
                    } else if (state is RegisterLoading) {
                      return buildLoading(context);
                    } else if (state is RegisterSuccess) {
                      authBloc.add(UserLoggedIn(
                          account: state.newUser['account'],
                          subscriber: state.newUser['subscriber']));
                      return buildRegisterSuccess(context);
                    }

                    return buildAccountForm(context);
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

buildRegisterSuccess(BuildContext context) {
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
          'REGISTRATION COMPLETE',
          style: TextStyle(
            color: Colors.blue[900],
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        Text('Please wait for an admin to verify your account'),
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
              onPressed: () {
                Navigator.pop(context);
              },
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

buildLoading(BuildContext context) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      circularProgress(),
      SizedBox(height: 25.0),
      Text(_loadingMessage),
    ],
  );
}

void handleNextOnAccount(BuildContext context) {
  if (!_accountFormKey.currentState.validate()) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please check errors to proceed'),
        backgroundColor: Colors.red[600],
      ),
    );

    return;
  }

  BlocProvider.of<RegisterBloc>(context)
      .add(VerifyReferralCode(_referralCodeController.text.trim()));
}

void handleNextOnSubscriber(BuildContext context) {
  if (!_subscriberFormKey.currentState.validate()) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please check errors to proceed'),
        backgroundColor: Colors.red[600],
      ),
    );

    return;
  }

  _newSubscriber.addAll({
    'firstName': _firstNameController.text.trim(),
    'lastName': _lastNameController.text.trim(),
    'birthDate': _birthDate,
    'email': _emailController.text.trim(),
    'mobile': _mobileController.text.trim(),
    'address': _addressController.text.trim(),
    'work': _workController.text.trim(),
    'workAddress': _workAddressController.text.trim(),
  });

  BlocProvider.of<RegisterBloc>(context).add(GetRequiredPhotos());
}

handleSubmit(BuildContext context) {
  if (_workPhoto == null || _profilePhoto == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please select required photos to finish'),
        backgroundColor: Colors.red[600],
      ),
    );
    return;
  }
  BlocProvider.of<RegisterBloc>(context).add(RegisterUser(
      _referralCodeController.text.trim(),
      _newAccount,
      _newSubscriber,
      _workPhoto,
      _profilePhoto));
}

pickBirthdate(BuildContext context) async {
  final selectedDate = await pickDate(context);
  if (selectedDate == null) return;
  _birthDate = selectedDate;
  _birthDateController.text = DateFormat('MMM. dd, yyyy').format(_birthDate);
}

buildAccountTypeDropdown(BuildContext context) {
  return Row(
    children: [
      Text('Account Type:'),
      SizedBox(width: 15.0),
      Expanded(
        child: DropdownButton(
          value: _accountType,
          isExpanded: true,
          items: [
            DropdownMenuItem(
              value: 'subscriber',
              child: Text('Subscriber'),
            ),
            DropdownMenuItem(
              value: 'admin',
              child: Text('Admin'),
            ),
          ],
          onChanged: (value) {
            BlocProvider.of<RegisterBloc>(context)
                .add(RegisterChangeAccountType(value));
          },
        ),
      )
    ],
  );
}

buildAccountForm(BuildContext context) {
  final authService = RepositoryProvider.of<AuthenticationService>(context);
  final node = FocusScope.of(context);
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 25.0),
    child: Column(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Center(
            child: Text(
              'ACCOUNT DETAILS',
              style: TextStyle(
                color: Colors.blue[900],
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _accountFormKey,
                child: Column(
                  children: <Widget>[
                    Visibility(
                      visible: authService.currentUserType != null &&
                          authService.currentUserType != 'subscriber',
                      child: buildAccountTypeDropdown(context),
                    ),
                    StyledTextField(
                      controller: _usernameController,
                      label: 'Username',
                      hint: '4 to 16 characters',
                      validator: (String value) {
                        if (value.length < 4 || value.length > 16) {
                          return 'Should be atleast 4 to 16 characters';
                        }

                        if (value.contains(' ')) {
                          return 'Username should not have a space';
                        }

                        return null;
                      },
                      onEditingComplete: () => node.nextFocus(),
                    ),
                    StyledTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Password',
                      isPassword: true,
                      validator: (String value) {
                        if (value.length < 6 || value.length > 20) {
                          return 'Should be atleast 6 to 20 characters';
                        } else {
                          return null;
                        }
                      },
                      onEditingComplete: () => node.nextFocus(),
                    ),
                    StyledTextField(
                      controller: _password2Controller,
                      label: 'Confirm Password',
                      hint: 'Confirm Password',
                      isPassword: true,
                      validator: (value) {
                        if (value != _passwordController.text.trim()) {
                          return 'Does not match password';
                        } else {
                          return null;
                        }
                      },
                      onEditingComplete: () => node.nextFocus(),
                    ),
                    StyledTextField(
                      controller: _referralCodeController,
                      label: 'Referral Code',
                      hint: 'Enter code given by inviter',
                      validator: (String value) {
                        if (value.length < 1) {
                          return 'Please enter a referral code';
                        } else {
                          return null;
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: RoundButton(
              color: Colors.blue[900],
              onPressed: () => handleNextOnAccount(context),
              labelText: 'NEXT',
              labelColor: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );
}

buildSubscriberForm(BuildContext context) {
  final node = FocusScope.of(context);
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 25.0),
    child: Column(
      children: [
        Expanded(
          flex: 1,
          child: Center(
            child: Text(
              'PERSONAL INFORMATION',
              style: TextStyle(
                color: Colors.blue[900],
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 7,
          child: SingleChildScrollView(
            child: Form(
              key: _subscriberFormKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  children: <Widget>[
                    StyledTextField(
                      controller: _firstNameController,
                      label: 'First Name',
                      hint: 'Enter your first name',
                      validator: (String value) {
                        if (value.length < 1) {
                          return 'First name is required';
                        }
                      },
                      onEditingComplete: () => node.nextFocus(),
                    ),
                    StyledTextField(
                      controller: _lastNameController,
                      label: 'Last Name',
                      hint: 'Enter your last name',
                      validator: (String value) {
                        if (value.length < 1) {
                          return 'Last name is required';
                        }
                      },
                      onEditingComplete: () => node.nextFocus(),
                    ),
                    StyledTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'Enter your email address',
                      textInputType: TextInputType.emailAddress,
                      validator: (value) =>
                          EmailValidator.validate(value) == true
                              ? null
                              : "Please enter a valid email",
                      onEditingComplete: () => node.nextFocus(),
                    ),
                    StyledTextField(
                      controller: _mobileController,
                      label: 'Mobile Number',
                      hint: 'Enter your mobile number',
                      textInputType: TextInputType.phone,
                      validator: (String value) {
                        if (value.length < 1) {
                          return 'Mobile number is required';
                        }
                      },
                      onEditingComplete: () => node.nextFocus(),
                    ),
                    StyledTextField(
                      controller: _addressController,
                      label: 'Address',
                      hint: 'Enter your home address',
                      maxLines: null,
                      textInputType: TextInputType.multiline,
                      validator: (String value) {
                        if (value.length < 1) {
                          return 'Address is required';
                        }
                      },
                      onEditingComplete: () => node.nextFocus(),
                    ),
                    StyledTextField(
                      controller: _birthDateController,
                      label: 'Birthdate',
                      hint: 'Click to select your birthdate',
                      textInputType: TextInputType.streetAddress,
                      isReadOnly: true,
                      onTap: () async {
                        await pickBirthdate(context);
                        node.nextFocus();
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select your birthdate';
                        } else {
                          return null;
                        }
                      },
                    ),
                    StyledTextField(
                      controller: _workController,
                      label: 'Work',
                      hint: 'Enter your current work',
                      validator: (String value) {
                        if (value.length < 1) {
                          return 'Current work is required';
                        }
                      },
                      onEditingComplete: () => node.nextFocus(),
                    ),
                    StyledTextField(
                      controller: _workAddressController,
                      label: 'Work Address',
                      hint: 'Enter your current work address',
                      maxLines: null,
                      textInputType: TextInputType.multiline,
                      validator: (String value) {
                        if (value.length < 1) {
                          return 'Your work address is required';
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            children: <Widget>[
              Expanded(
                child: RoundButton(
                  color: Colors.indigo,
                  onPressed: () {
                    BlocProvider.of<RegisterBloc>(context).add(RegisterReset());
                  },
                  labelText: 'BACK',
                  labelColor: Colors.white,
                ),
              ),
              SizedBox(width: 5.0),
              Expanded(
                child: RoundButton(
                  color: Colors.blue[900],
                  onPressed: () => handleNextOnSubscriber(context),
                  labelText: 'NEXT',
                  labelColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
