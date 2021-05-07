import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../exceptions/exceptions.dart';
import '../../services/authentication.dart';
import 'authentication_bloc.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthenticationBloc _authenticationBloc;
  final AuthenticationService _authenticationService;

  LoginBloc(AuthenticationBloc authenticationBloc,
      AuthenticationService authenticationService)
      : assert(authenticationBloc != null),
        assert(authenticationService != null),
        _authenticationBloc = authenticationBloc,
        _authenticationService = authenticationService,
        super(LoginInitial());

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginUser) {
      yield* _mapLoginWithUsernameToState(event);
    }
  }

  Stream<LoginState> _mapLoginWithUsernameToState(LoginUser event) async* {
    yield LoginLoading();
    try {
      final user = await _authenticationService.signInWithUsernameAndPassword(
          event.username, event.password);
      if (user != null) {
        _authenticationBloc.add(UserLoggedIn(
            account: user['account'], subscriber: user['subscriber']));
        yield LoginSuccess();
        yield LoginInitial();
      } else {
        yield LoginFailure(error: 'Invalid credentials');
      }
    } on AuthenticationException catch (e) {
      yield LoginFailure(error: e.message);
    } catch (err) {
      yield LoginFailure(error: err.message ?? 'An unknown error occured');
    }
  }
}
