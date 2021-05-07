import 'package:appodeal_flutter/appodeal_flutter.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:progress_indicators/progress_indicators.dart';

import 'data/bloc/authentication_bloc.dart';
import 'data/repositories/account_repository.dart';
import 'data/repositories/subscriber_repository.dart';
import 'pages/home.dart';
import 'pages/login.dart';
import 'services/authentication.dart';

const PLAY_STORE_URL =
    'https://play.google.com/store/apps/details?id=com.payearn.payearn_app';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var connectivityResult = await (Connectivity().checkConnectivity());

  if (connectivityResult == ConnectivityResult.none) {}

  // checkVersion();

  await Firebase.initializeApp();
  try {
    Appodeal.setAppKeys(
      androidAppKey: '1956e7f9d564302c5ec8cc5c03252d08f5ce0f06d76fbb06',
    );

    await Appodeal.initialize(
      hasConsent: false,
      adTypes: [
        AdType.BANNER,
        AdType.INTERSTITIAL,
        AdType.REWARD,
      ],
      testMode: false,
    );
  } catch (e) {
    print('appodeal error: ${e.toString()}');
  }

  runApp(
    RepositoryProvider<AuthenticationService>(
      create: (context) {
        return AuthenticationService(
            AccountRepository(), SubscriberRepository());
      },
      child: BlocProvider<AuthenticationBloc>(
        create: (context) {
          final authService =
              RepositoryProvider.of<AuthenticationService>(context);
          return AuthenticationBloc(authService)..add(AppLoaded());
        },
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'PayEarn',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Roboto',
          primarySwatch: Colors.blue,
          accentColor: Colors.white,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            if (state is AuthenticationInitial) {
              try {
                checkVersion();
              } catch (e) {
                print(e);
              }
              return buildSplashScreen();
            }
            if (state is AuthenticationNotAuthenticated) {
              return LoginPage();
            }

            if (state is AuthenticationAuthenticated) {
              return HomePage(state.account, state.subscriber);
            }

            if (state is AuthenticationLoading) {
              return buildSplashScreen();
            }

            return buildSplashScreen();
          },
        ));
  }
}

checkVersion() async {
  InAppUpdate.checkForUpdate().then((AppUpdateInfo info) {
    if (info.updateAvailability == UpdateAvailability.updateAvailable) {
      InAppUpdate.performImmediateUpdate();
    }
  }).catchError((error) => print('error updating: ${error.toString()}'));
}

buildSplashScreen() {
  return Scaffold(
    backgroundColor: Colors.blue[100],
    body: Center(
      child: HeartbeatProgressIndicator(
        child: SizedBox(
          height: 100.0,
          child: Image.asset(
            'assets/images/payearn_logo.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    ),
  );
}

// versionCheck(context) async {
//   //Get Current installed version of app
//   final PackageInfo info = await PackageInfo.fromPlatform();
//   double currentVersion = double.parse(info.version.trim().replaceAll(".", ""));

//   //Get Latest version info from firebase config
//   final RemoteConfig remoteConfig = await RemoteConfig.instance;

//   try {
//     // Using default duration to force fetching from remote server.
//     await remoteConfig.fetch(expiration: const Duration(seconds: 0));
//     await remoteConfig.activateFetched();
//     remoteConfig.getString('force_update_current_version');
//     double newVersion = double.parse(remoteConfig
//         .getString('force_update_current_version')
//         .trim()
//         .replaceAll(".", ""));
//     if (newVersion > currentVersion) {
//       _showVersionDialog(context);
//     }
//   } on FetchThrottledException catch (exception) {
//     // Fetch throttled.
//     print(exception);
//   } catch (exception) {
//     print('Unable to fetch remote config. Cached or default values will be '
//         'used');
//   }
// }

// _showVersionDialog(context) async {
//   await showDialog<String>(
//     context: context,
//     barrierDismissible: false,
//     builder: (BuildContext context) {
//       String title = "New Update Available";
//       String message =
//           "There is a newer version of app available please update it now.";
//       String btnLabel = "Update Now";
//       String btnLabelCancel = "Later";
//       return new AlertDialog(
//         title: Text(title),
//         content: Text(message),
//         actions: <Widget>[
//           FlatButton(
//             child: Text(btnLabel),
//             onPressed: () => _launchURL(PLAY_STORE_URL),
//           ),
//           FlatButton(
//             child: Text(btnLabelCancel),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ],
//       );
//     },
//   );
// }

// _launchURL(String url) async {
//   if (await canLaunch(url)) {
//     await launch(url);
//   } else {
//     throw 'Could not launch $url';
//   }
// }
