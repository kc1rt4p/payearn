import 'package:appodeal_flutter/appodeal_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../data/bloc/subscribers_bloc.dart';
import '../services/authentication.dart';
import '../widgets/heartbeat_loading.dart';
import '../widgets/styled_button.dart';
import 'register.dart';
import 'subscriber_info.dart';

TextEditingController searchCtrl = TextEditingController();
bool hasPlatinum = false;
bool isVerified = false;
bool showBanner = true;

class SubscribersPage extends StatefulWidget {
  @override
  _SubscribersPageState createState() => _SubscribersPageState();
}

class _SubscribersPageState extends State<SubscribersPage> {
  toggleBanner() {
    setState(() {
      showBanner = !showBanner;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BlocProvider<SubscribersBloc>(
            create: (context) => SubscribersBloc()..add(SubscriberGetAll('')),
            child: BlocListener<SubscribersBloc, SubscribersState>(
              listener: (context, state) {
                if (state is SubscriberDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'A subscriber has been deleted including all data'),
                      backgroundColor: Colors.red[600],
                    ),
                  );
                }
              },
              child: BlocBuilder<SubscribersBloc, SubscribersState>(
                builder: (context, state) {
                  if (state is SubscribersLoaded) {
                    return buildSubscribersLoaded(context, state, toggleBanner);
                  }

                  if (state is GettingSubscribers) {
                    return buildHeartbeatLoading();
                  }

                  return buildHeartbeatLoading();
                },
              ),
            ),
          ),
        ),
        Visibility(
          visible: showBanner,
          child: Center(
            child: AppodealBanner(
              placementName: 'SubscriberListPage',
            ),
          ),
        ),
      ],
    );
  }
}

buildSubscribersLoaded(
    BuildContext context, SubscribersLoaded state, Function toggleBanner) {
  final authService = RepositoryProvider.of<AuthenticationService>(context);

  return Column(
    children: <Widget>[
      Material(
        elevation: 10.0,
        child: TextFormField(
          controller: searchCtrl,
          style: TextStyle(
            color: Colors.blue[900],
            fontSize: 15.0,
          ),
          decoration: InputDecoration(
            hintText: 'Search for a subscriber...',
            hintStyle: TextStyle(
              color: Colors.blue[600],
            ),
            filled: true,
            prefixIcon: Icon(
              Icons.search,
              size: 25.0,
              color: Colors.blue[900],
            ),
            suffix: IconButton(
              icon: Icon(Icons.clear, size: 20.0),
              onPressed: () => clearSearch(context),
            ),
            fillColor: Colors.transparent,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          onFieldSubmitted: (value) {
            BlocProvider.of<SubscribersBloc>(context)
                .add(SubscriberGetAll(searchCtrl.text.trim()));
          },
        ),
      ),
      SizedBox(height: 10.0),
      Align(
        alignment: Alignment.topCenter,
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: Text(
                    'Unverified: ${state.subscriberList.where((s) => !s.isVerified).length}'),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                    'Verified: ${state.subscriberList.where((s) => s.isVerified).length}'),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                    'Platinum: ${state.subscriberList.where((s) => s.hasPlatinum).length}'),
              ),
            ),
          ],
        ),
      ),
      Expanded(
        child: state.subscriberList
                    .where((subscriber) =>
                        subscriber.id != authService.currentUserId)
                    .isEmpty ==
                true
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(FontAwesomeIcons.usersSlash, size: 80.0),
                  SizedBox(height: 10.0),
                  Text('No subscribers found'),
                  SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 55.0),
                    child: StyledButton(
                      labelText: 'Add Subscriber',
                      onPressed: () => handleAdd(context, toggleBanner),
                    ),
                  ),
                ],
              )
            : Stack(
                children: [
                  ListView(
                    children: state.subscriberList
                        .where((subscriber) =>
                            subscriber.id != authService.currentUserId)
                        .map((subscriber) {
                      return GestureDetector(
                        child: Card(
                          color: Colors.blue[200],
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircleAvatar(
                                  radius: 30.0,
                                  backgroundColor: Colors.grey,
                                  backgroundImage: subscriber.photoUrl !=
                                              null &&
                                          subscriber.photoUrl.isNotEmpty
                                      ? CachedNetworkImageProvider(
                                          subscriber.photoUrl)
                                      : AssetImage('assets/images/no_img.png'),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      '${subscriber.firstName} ${subscriber.lastName}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(subscriber.address),
                                    Row(
                                      children: <Widget>[
                                        subscriber.hasPlatinum == true
                                            ? Text(
                                                '✓ PLATINUM',
                                                style: TextStyle(
                                                    color: Colors.green[900]),
                                              )
                                            : Text(
                                                '✕ PLATINUM',
                                                style: TextStyle(
                                                    color: Colors.red[900]),
                                              ),
                                        SizedBox(width: 10.0),
                                        subscriber.isVerified == true
                                            ? Text(
                                                '✓ VERIFIED',
                                                style: TextStyle(
                                                    color: Colors.green[900]),
                                              )
                                            : Text(
                                                '✕ VERIFIED',
                                                style: TextStyle(
                                                    color: Colors.red[900]),
                                              ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: authService.currentUserType == 'super',
                                child: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () =>
                                      handleDelete(context, subscriber.id),
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () async {
                          toggleBanner();
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SubscriberInfoPage(subscriber.id),
                            ),
                          );
                          toggleBanner();
                        },
                      );
                    }).toList(),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: FloatingActionButton(
                      onPressed: () => handleAdd(context, toggleBanner),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      backgroundColor: Colors.indigo,
                    ),
                  ),
                ],
              ),
      ),
    ],
  );
}

handleAdd(BuildContext context, Function toggleBanner) async {
  toggleBanner();
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => RegisterPage(),
    ),
  );
  toggleBanner();
}

handleDelete(BuildContext context, String id) async {
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
      BlocProvider.of<SubscribersBloc>(context).add(SubscriberDelete(id));
      Navigator.of(context).pop();
    },
  );

  AlertDialog alert = AlertDialog(
    title: Text(
      'Confirm Subscriber Delete',
      style: TextStyle(
        color: Colors.white,
      ),
    ),
    content: Text(
      'This will delete all data related to selected subscriber, do you want to continue?',
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

clearSearch(BuildContext context) {
  searchCtrl.clear();
  BlocProvider.of<SubscribersBloc>(context)
      .add(SubscriberGetAll(searchCtrl.text.trim()));
}
