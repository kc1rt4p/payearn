import 'dart:async';
import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:appodeal_flutter/appodeal_flutter.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/bloc/daily_quotes_bloc.dart';
import '../data/models/quote.dart';
import '../services/authentication.dart';
import '../widgets/heartbeat_loading.dart';
import '../widgets/styled_button.dart';
import '../widgets/styled_text_field.dart';

int count = 0;
final _formKey = GlobalKey<FormState>();

class DailyQuotesPage extends StatefulWidget {
  @override
  _DailyQuotesPageState createState() => _DailyQuotesPageState();
}

class _DailyQuotesPageState extends State<DailyQuotesPage> {
  Timer timer;
  ConfettiController _controllerBottomCenter;
  GlobalKey _key = GlobalKey();

  bool _showCongrats = false;
  bool _dialogShown = false;
  bool _loadingAds = false;
  bool _showAddButton = true;

  @override
  void initState() {
    final authService = RepositoryProvider.of<AuthenticationService>(context);
    _controllerBottomCenter =
        ConfettiController(duration: const Duration(seconds: 2));

    Appodeal.setRewardCallback((event) {
      if (event == 'onRewardedVideoLoaded') {
        setState(() {
          _loadingAds = false;
        });
      }

      if (event == 'onRewardedVideoFinished') {
        BlocProvider.of<DailyQuotesBloc>(_key.currentContext)
            .add(DailyQuotesGiveReward(authService.currentUserId));
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _controllerBottomCenter.dispose();
    Appodeal.setRewardCallback(null);
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = RepositoryProvider.of<AuthenticationService>(context);
    return Container(
      color: Colors.blue[100],
      height: MediaQuery.of(context).size.height - kToolbarHeight - 25,
      child: Column(
        children: [
          Center(
            child: AppodealBanner(
              placementName: 'DailyQuote',
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                BlocProvider<DailyQuotesBloc>(
                  create: (context) => DailyQuotesBloc()
                    ..add(DailyQuotesInitialize(authService.currentUserId)),
                  child: BlocListener<DailyQuotesBloc, DailyQuotesState>(
                    listener: (context, state) {
                      if (state is DailyQuotesLoaded) {
                        if (!_dialogShown && !_loadingAds) {
                          setState(() {
                            _dialogShown = true;
                          });
                          Random random = new Random();
                          int randomSec = 5 + random.nextInt(20 - 5);

                          timer = Timer(Duration(seconds: randomSec), () {
                            showAdDialog(context);
                          });
                        }
                      }

                      if (state is DailyQuotesWillAdd) {
                        setState(() {
                          _showAddButton = false;
                        });
                      }

                      if (state is DailyQuotesAdded) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('A new quote has been added'),
                            backgroundColor: Colors.green[600],
                          ),
                        );
                      }

                      if (state is DailyQuotesDeleted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('A quote has been deleted'),
                            backgroundColor: Colors.red[600],
                          ),
                        );
                      }

                      if (state is DailyQuotesRewarded) {
                        _controllerBottomCenter.play();

                        setState(() {
                          _showCongrats = true;
                        });

                        Future.delayed(Duration(seconds: 3), () {
                          setState(() {
                            _showCongrats = false;
                          });
                        });
                      }

                      if (state is DailyQuotesDone) {
                        BlocProvider.of<DailyQuotesBloc>(_key.currentContext)
                            .add(DailyQuotesInitialize(
                                authService.currentUserId));

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('You can still view quotes for free'),
                            backgroundColor: Colors.green[600],
                          ),
                        );
                      }
                    },
                    child: BlocBuilder<DailyQuotesBloc, DailyQuotesState>(
                      key: _key,
                      builder: (context, state) {
                        if (state is DailyQuotesInitial) {
                          return buildInitial(context);
                        }

                        if (state is DailyQuotesLoaded) {
                          return buildLoaded(
                              context, state.quote, state.rewardCount);
                        }

                        if (state is DailyQuotesLoading) {
                          return buildLoading(context);
                        }

                        // if (state is DailyQuotesMaxed) {
                        //   return buildMaxed(context, state.lastRewardDate);
                        // }

                        if (state is DailyQuotesWillAdd) {
                          return buildWillAdd(context, state.quotes);
                        }

                        return buildLoading(context);
                      },
                    ),
                  ),
                ),
                Visibility(
                  visible: _showCongrats,
                  child: Align(
                    alignment: Alignment.center,
                    child: BounceInUp(
                      child: Container(
                        height: 200.0,
                        width: double.infinity,
                        padding: EdgeInsets.all(5.0),
                        color: Colors.blue[100],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'CONGRATULATIONS!',
                              style: TextStyle(
                                fontSize: 35.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                                'You received 1 loyalty point for helping out'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ConfettiWidget(
                    confettiController: _controllerBottomCenter,
                    blastDirection: -pi / 2,
                    emissionFrequency: 0.01,
                    numberOfParticles: 20,
                    maxBlastForce: 100,
                    minBlastForce: 80,
                    gravity: 0.3,
                  ),
                ),
                Visibility(
                  visible:
                      authService.currentUserType == 'super' && _showAddButton,
                  child: Positioned(
                    bottom: 10,
                    right: 10,
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        BlocProvider.of<DailyQuotesBloc>(_key.currentContext)
                            .add(DailyQuotesShowAdd());
                      },
                      label: Text(
                        'Add New Quote',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.0,
                        ),
                      ),
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 14.0,
                      ),
                      backgroundColor: Colors.blue[900],
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

  handleContinue(BuildContext context) {
    final authService = RepositoryProvider.of<AuthenticationService>(context);
    BlocProvider.of<DailyQuotesBloc>(context)
        .add(DailyQuotesLoad(authService.currentUserId));
  }

  showAdDialog(BuildContext context) async {
    Widget no1 = TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.white),
      ),
      child: Text(
        'No, I\'m not intersted',
        style: TextStyle(
          color: Colors.blue[900],
        ),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        BlocProvider.of<DailyQuotesBloc>(context).add(DailyQuotesFinish());
      },
    );

    Widget no2 = TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.white),
      ),
      child: Text(
        'No thanks',
        style: TextStyle(
          color: Colors.blue[900],
        ),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    Widget okButton = TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.white),
      ),
      child: Text(
        'Yes, I would love to watch it',
        style: TextStyle(
          color: Colors.blue[900],
        ),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        showInterstitialAd(context);
      },
    );

    SimpleDialog alert = SimpleDialog(
      contentPadding: EdgeInsets.all(10.0),
      backgroundColor: Colors.blue[900],
      children: [
        Container(
          height: 200.0,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                count > 0
                    ? 'Refill you financial wisdom\nThis ad will help us give financial advice for free'
                    : 'Watching an ad will help to give financial education to someone for free',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.blue[100],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 20.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              okButton,
              no1,
              no2,
            ],
          ),
        ),
      ],
    );

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });

    setState(() {
      _dialogShown = false;
      count += 1;
    });
  }

  showInterstitialAd(BuildContext context) {
    setState(() {
      _loadingAds = true;
    });
    Appodeal.show(AdType.REWARD, placementName: "DailyQuote");
  }

  buildWillAdd(BuildContext context, List<Quote> quotes) {
    TextEditingController quoteCtrl = new TextEditingController();
    TextEditingController authorCtrl = new TextEditingController();
    final authService = RepositoryProvider.of<AuthenticationService>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 25.0,
        vertical: 10.0,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'QUOTE LIST',
              style: TextStyle(
                color: Colors.blue[900],
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            Expanded(
              child: Center(
                child: ListView(
                  shrinkWrap: true,
                  children: quotes.map((quote) {
                    return Card(
                      child: ListTile(
                        title: Text(quote.quote),
                        subtitle: Text(quote.author),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red[900]),
                          onPressed: () => handleQuoteDelete(context, quote.id),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Expanded(
              child: Center(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Center(
                      child: Text(
                        'NEW QUOTE',
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    StyledTextField(
                      controller: quoteCtrl,
                      maxLines: null,
                      textInputType: TextInputType.multiline,
                      label: 'Quote',
                      validator: (String val) {
                        if (val.isEmpty) {
                          return 'Please enter a quote';
                        }
                        return null;
                      },
                    ),
                    StyledTextField(
                      controller: authorCtrl,
                      label: 'Author',
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: StyledButton(
                            labelText: 'CANCEL',
                            onPressed: () {
                              BlocProvider.of<DailyQuotesBloc>(context).add(
                                  DailyQuotesInitialize(
                                      authService.currentUserId));
                              setState(() {
                                _showAddButton = true;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: StyledButton(
                            labelText: 'SUBMIT',
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                final newQuote = {
                                  'quote': quoteCtrl.text.trim(),
                                  'author': authorCtrl.text.trim(),
                                };

                                BlocProvider.of<DailyQuotesBloc>(context)
                                    .add(DailyQuotesAdd(newQuote));

                                quoteCtrl.clear();
                                authorCtrl.clear();
                              }
                            },
                          ),
                        ),
                      ],
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

  handleQuoteDelete(BuildContext context, String id) async {
    Widget cancelButton = TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.white),
      ),
      child: Text(
        'No',
        style: TextStyle(
          color: Colors.blue[900],
        ),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    Widget okButton = TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.white),
      ),
      child: Text(
        'Yes',
        style: TextStyle(
          color: Colors.blue[900],
        ),
      ),
      onPressed: () {
        BlocProvider.of<DailyQuotesBloc>(context).add(DailyQuotesDelete(id));
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(
        'Confirm Quote Delete',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      content: Text(
        'You are about to delete a quote, do you want to continue?',
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

  buildLoading(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildHeartbeatLoading(),
      ],
    );
  }

  // buildMaxed(BuildContext context, DateTime lastRewardDate) {
  //   final nextRewardDate = lastRewardDate.add(Duration(days: 1));
  //   final DateFormat formatter = DateFormat(
  //     'MMM. dd, y @ hh:mma',
  //   );
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       Text(
  //         'Thank you!\n You can read again tomorrow',
  //         textAlign: TextAlign.center,
  //         style: TextStyle(
  //           color: Colors.blue[900],
  //           fontSize: 32.0,
  //           fontFamily: 'Manrope',
  //         ),
  //       ),
  //       SizedBox(height: 15.0),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Text(formatter.format(nextRewardDate)),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Column buildLoaded(BuildContext context, Quote quote, num rewardCount) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    '\"${quote.quote}\"',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: 20.0,
                      fontFamily: 'Manrope',
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Text(
                        '- ${quote.author}',
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontSize: 16.0,
                          fontFamily: 'Manrope',
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 120.0,
                      vertical: 8.0,
                    ),
                    child: StyledButton(
                      labelText: 'NEXT',
                      onPressed:
                          _loadingAds ? null : () => handleContinue(context),
                    ),
                  ),
                  // Center(
                  //     child: Text(
                  //   'Available Reward: $rewardCount',
                  //   style: TextStyle(fontSize: 12.0),
                  // )),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Column buildInitial(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Welcome to\n Financial Literacy',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.blue[900],
            fontSize: 32.0,
            fontFamily: 'Manrope',
          ),
        ),
        SizedBox(height: 35.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 120.0),
          child: StyledButton(
            labelText: 'CONTINUE',
            onPressed: () => handleContinue(context),
          ),
        ),
      ],
    );
  }
}

// giveLoyaltyBonus(String id) async {
//   final RewardService rewardService = RewardService(id);
//   await rewardService.giveReward();
// }
