import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../services/authentication.dart';
import '../models/account.dart';
import '../models/subscriber.dart';
import 'authentication_bloc.dart';

part 'register_event.dart';
part 'register_state.dart';

final accountsRef = FirebaseFirestore.instance.collection('accounts');

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthenticationBloc authenticationBloc;
  final AuthenticationService authenticationService;

  RegisterBloc(this.authenticationBloc, this.authenticationService)
      : super(RegisterInitial());

  @override
  Stream<RegisterState> mapEventToState(
    RegisterEvent event,
  ) async* {
    yield RegisterLoading();

    if (event is RegisterReset) {
      yield GettingAccountInfo();
    }

    if (event is VerifyReferralCode) {
      // verify referral
      yield VerifyingCode();
      yield RegisterLoading();
      final referrerId =
          await authenticationService.verifyReferralCode(event.code);

      if (referrerId == null) {
        yield VerifyingCodeError('Invalid referral code');
      } else {
        yield VerifiedCode(referrerId);
        yield GettingPersonalInfo();
      }
    }

    if (event is RegisterChangeAccountType) {
      yield RegisterAccountTypeChanged(event.type);
    }

    if (event is GetAccountInformation) {
      yield GettingAccountInfo();
    }

    if (event is GetPersonalInformation) {
      yield GettingPersonalInfo();
    }

    if (event is GetRequiredPhotos) {
      yield GettingRequiredPhotos();
    }

    if (event is RegisterUser) {
      try {
        yield CreatingAccount();
        yield RegisterLoading();

        final existingDoc =
            await accountsRef.doc(event.account['username']).get();
        if (existingDoc.exists) {
          yield RegisterError('Username is not available');
        } else {
          final newUser = await authenticationService.registerUser(
              event.referralCode,
              event.account,
              event.subscriber,
              event.workPhoto,
              event.profilePhoto);
          if (newUser == null) {
            yield RegisterError('Error creating subscriber');
          } else {
            yield RegisterSuccess(newUser);
          }
        }
      } catch (e) {
        print('error creating subscriber: ${e.toString()}');
        yield RegisterError('Error creating subscriber');
      }
    }
  }
}
