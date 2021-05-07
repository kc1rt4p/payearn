import 'package:appodeal_flutter/appodeal_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payearn_app/widgets/heartbeat_loading.dart';
import 'package:payearn_app/widgets/payearn_logo.dart';

import '../data/bloc/authentication_bloc.dart';
import '../data/bloc/login_bloc.dart';
import '../services/authentication.dart';
import '../widgets/round_button.dart';
import '../widgets/round_text_input.dart';
import 'register.dart';

TextEditingController _usernameCtrl = TextEditingController();
TextEditingController _passwordCtrl = TextEditingController();
final _loginFormKey = GlobalKey<FormState>();
bool showBanner = true;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  toggleBanner() {
    setState(() {
      showBanner = !showBanner;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = RepositoryProvider.of<AuthenticationService>(context);
    final authBloc = BlocProvider.of<AuthenticationBloc>(context);

    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: SafeArea(
        child: Column(
          children: [
            Visibility(
              visible: showBanner,
              child: Center(
                child: AppodealBanner(
                  placementName: 'LoginPage',
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: BlocProvider<LoginBloc>(
                    create: (context) => LoginBloc(authBloc, authService),
                    child: BlocListener<LoginBloc, LoginState>(
                      listener: (context, state) {
                        if (state is LoginSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Login successful!'),
                              backgroundColor: Colors.green[600],
                            ),
                          );
                          _usernameCtrl.clear();
                          _passwordCtrl.clear();
                        }

                        if (state is LoginFailure) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Invalid credentials, please try again.'),
                              backgroundColor: Colors.red[600],
                            ),
                          );
                        }
                      },
                      child: BlocBuilder<LoginBloc, LoginState>(
                        builder: (context, state) {
                          if (state is LoginLoading) {
                            return buildHeartbeatLoading();
                          }

                          return buildLoginInitial(context, toggleBanner);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void loginUser(BuildContext context) {
  final String username = _usernameCtrl.text.trim();
  final String password = _passwordCtrl.text.trim();
  final loginBloc = BlocProvider.of<LoginBloc>(context);
  loginBloc.add(LoginUser(username, password));
}

void handleRegister(BuildContext context, Function toggleBanner) async {
  toggleBanner();
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => RegisterPage(),
    ),
  );
  toggleBanner();
}

Center buildLoginInitial(BuildContext context, Function toggleBanner) {
  return Center(
    child: SingleChildScrollView(
      child: Column(
        children: [
          PayEarnLogo(size: 90.0, withBackground: true),
          SizedBox(height: 50.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Form(
              key: _loginFormKey,
              child: Column(
                children: [
                  RoundTextField(
                    controller: _usernameCtrl,
                    hint: 'Username',
                    validator: (String value) {
                      if (value.isEmpty) return 'Please enter your username';

                      return null;
                    },
                  ),
                  RoundTextField(
                    controller: _passwordCtrl,
                    hint: 'Password',
                    isPassword: true,
                    validator: (String value) {
                      if (value.isEmpty) return 'Please enter your password';

                      return null;
                    },
                  ),
                  SizedBox(height: 20.0),
                  RoundButton(
                    color: Colors.purple[900],
                    labelText: 'LOGIN',
                    onPressed: () => loginUser(context),
                  ),
                  SizedBox(height: 8.0),
                  RoundButton(
                    color: Colors.indigo[900],
                    labelText: 'REGISTER',
                    onPressed: () => handleRegister(context, toggleBanner),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
