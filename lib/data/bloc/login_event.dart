part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
}

class LoginUser extends LoginEvent {
  final String username;
  final String password;

  const LoginUser(this.username, this.password);

  @override
  List<Object> get props => [
        username,
        password,
      ];
}
