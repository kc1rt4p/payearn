import 'dart:io';

import 'package:appodeal_flutter/appodeal_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../data/bloc/profile_bloc.dart';
import '../data/models/subscriber.dart';
import '../data/repositories/subscriber_repository.dart';
import '../widgets/date_picker.dart';
import '../widgets/heartbeat_loading.dart';
import '../widgets/image_selector.dart';
import '../widgets/profile_text_field.dart';
import '../widgets/progress.dart';
import '../widgets/styled_button.dart';

TextEditingController _firstNameController = TextEditingController();
TextEditingController _lastNameController = TextEditingController();
TextEditingController _emailController = TextEditingController();
TextEditingController _birthdateController = TextEditingController();
TextEditingController _mobileController = TextEditingController();
TextEditingController _addressController = TextEditingController();
TextEditingController _workController = TextEditingController();
TextEditingController _workAddressController = TextEditingController();

File _profilePhoto;
File _idPhoto;

DateTime _birthDate;

class ProfilePage extends StatefulWidget {
  final String subscriberId;

  const ProfilePage({this.subscriberId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  buildProfile(BuildContext context, Subscriber subscriber) {
    _firstNameController.text = subscriber.firstName;
    _lastNameController.text = subscriber.lastName;
    _birthdateController.text =
        DateFormat('MMM. dd, yyyy').format(subscriber.birthDate.toDate());
    _birthDate = subscriber.birthDate.toDate();
    _emailController.text = subscriber.email;
    _mobileController.text = subscriber.mobile;
    _addressController.text = subscriber.address;
    _workController.text = subscriber.work;
    _workAddressController.text = subscriber.workAddress;

    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              Card(
                color: Colors.blue[100],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              CircleAvatar(
                                maxRadius: 80.0,
                                backgroundColor: Colors.grey,
                                backgroundImage: _profilePhoto == null
                                    ? subscriber.photoUrl != null
                                        ? CachedNetworkImageProvider(
                                            subscriber.photoUrl,
                                          )
                                        : AssetImage(
                                            'assets/images/default_profile.png')
                                    : FileImage(_profilePhoto),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: RawMaterialButton(
                                  fillColor: Colors.white,
                                  onPressed: () =>
                                      handleSelectPhoto(context, 'profile'),
                                  shape: CircleBorder(),
                                  child: Icon(Icons.camera_alt),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 15.0),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                ProfileTextField(
                                  controller: _firstNameController,
                                  keyboardType: TextInputType.name,
                                  labelText: 'First Name',
                                ),
                                ProfileTextField(
                                  controller: _lastNameController,
                                  keyboardType: TextInputType.name,
                                  labelText: 'Last Name',
                                ),
                                ProfileTextField(
                                  controller: _birthdateController,
                                  keyboardType: TextInputType.datetime,
                                  labelText: 'Birthdate',
                                  readOnly: true,
                                  onTap: () => pickBirthdate(context),
                                ),
                                ProfileTextField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  labelText: 'Email Address',
                                ),
                                ProfileTextField(
                                  controller: _mobileController,
                                  keyboardType: TextInputType.phone,
                                  labelText: 'Mobile Number',
                                ),
                                ProfileTextField(
                                  controller: _workController,
                                  keyboardType: TextInputType.text,
                                  labelText: 'Work',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      ProfileTextField(
                        controller: _addressController,
                        keyboardType: TextInputType.multiline,
                        labelText: 'Home Address',
                      ),
                      ProfileTextField(
                        controller: _workAddressController,
                        keyboardType: TextInputType.multiline,
                        labelText: 'Work Address',
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(8.0),
                color: Colors.blue[200],
                child: Column(
                  children: [
                    Text(
                      'Photo ID',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Container(
                      constraints: BoxConstraints(
                        minHeight: 100.0,
                      ),
                      width: double.infinity,
                      child: Stack(
                        children: [
                          _idPhoto == null
                              ? subscriber.idUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: subscriber.idUrl,
                                      placeholder: (context, url) =>
                                          circularProgress(),
                                    )
                                  : Image.asset(
                                      'assets/images/default_image.jpg')
                              : Image.file(_idPhoto),
                          Positioned(
                            right: -15,
                            top: 0,
                            child: RawMaterialButton(
                              fillColor: Colors.white,
                              onPressed: () => handleSelectPhoto(context, 'id'),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: StyledButton(
            labelText: 'SAVE CHANGES',
            onPressed: () => handleSaveChanges(context),
            color: Colors.blue[100],
          ),
        ),
      ],
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
          _idPhoto = picked;
        }
      });
    }
  }

  handleSaveChanges(BuildContext context) {
    final subscriberData = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'birthDate': _birthDate,
      'email': _emailController.text.trim(),
      'mobile': _mobileController.text.trim(),
      'address': _addressController.text.trim(),
      'work': _workController.text.trim(),
      'workAddress': _workAddressController.text.trim(),
    };

    BlocProvider.of<ProfileBloc>(context).add(SaveProfile(
        subscriberData, widget.subscriberId, _profilePhoto, _idPhoto));
  }

  @override
  Widget build(BuildContext context) {
    final subscriberRepo = SubscriberRepository();
    return Column(
      children: [
        Center(
          child: AppodealBanner(
            placementName: 'ProfilePage',
          ),
        ),
        Expanded(
          child: BlocProvider<ProfileBloc>(
            create: (context) => ProfileBloc(subscriberRepo)
              ..add(
                LoadProfile(widget.subscriberId),
              ),
            child: BlocListener<ProfileBloc, ProfileState>(
              listener: (context, state) {
                if (state is ProfileSaved) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Profile successfully updated'),
                      backgroundColor: Colors.green[600],
                    ),
                  );

                  BlocProvider.of<ProfileBloc>(context)
                      .add(LoadProfile(widget.subscriberId));
                }

                if (state is ProfileError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error),
                      backgroundColor: Colors.red[600],
                    ),
                  );
                }
              },
              child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  if (state is ProfileLoaded) {
                    return buildProfile(context, state.subscriber);
                  }

                  return buildHeartbeatLoading();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

pickBirthdate(BuildContext context) async {
  final selectedDate = await pickDate(context);
  if (selectedDate == null) return;
  _birthDate = selectedDate;
  _birthdateController.text = DateFormat('MMM. dd, yyyy').format(_birthDate);
}
