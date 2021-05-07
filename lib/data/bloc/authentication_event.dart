part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class AppLoaded extends AuthenticationEvent {}

class UserLoggedIn extends AuthenticationEvent {
  final Subscriber subscriber;
  final Account account;

  UserLoggedIn({@required this.account, @required this.subscriber});

  @override
  List<Object> get props => [account, subscriber];
}

class UserLoggedOut extends AuthenticationEvent {}
