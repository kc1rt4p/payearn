import 'package:equatable/equatable.dart';

class AuthenticationException extends Equatable {
  final String message;

  AuthenticationException(this.message);

  @override
  List<Object> get props => [message];
}
