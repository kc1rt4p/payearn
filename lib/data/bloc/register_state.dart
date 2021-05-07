part of 'register_bloc.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();
}

class RegisterInitial extends RegisterState {
  const RegisterInitial();

  @override
  List<Object> get props => [];
}

class RegisterLoading extends RegisterState {
  const RegisterLoading();

  @override
  List<Object> get props => [];
}

class RegisterSuccess extends RegisterState {
  final Map<String, dynamic> newUser;

  const RegisterSuccess(this.newUser);

  @override
  List<Object> get props => [newUser];
}

class AddingReferral extends RegisterState {
  const AddingReferral();

  @override
  List<Object> get props => [];
}

class CreatingAccount extends RegisterState {
  const CreatingAccount();

  @override
  List<Object> get props => [];
}

class AccountCreated extends RegisterState {
  final Account account;
  const AccountCreated(this.account);

  @override
  List<Object> get props => [account];
}

class CreatingSubscriber extends RegisterState {
  const CreatingSubscriber();

  @override
  List<Object> get props => [];
}

class SubscriberCreated extends RegisterState {
  final Subscriber subscriber;
  const SubscriberCreated(this.subscriber);

  @override
  List<Object> get props => [];
}

class VerifyingCode extends RegisterState {
  @override
  List<Object> get props => [];
}

class VerifyingCodeError extends RegisterState {
  final String error;
  const VerifyingCodeError(this.error);
  @override
  List<Object> get props => [error];
}

class VerifiedCode extends RegisterState {
  final String referrerId;

  const VerifiedCode(this.referrerId);

  @override
  List<Object> get props => [];
}

class GettingAccountInfo extends RegisterState {
  const GettingAccountInfo();

  @override
  List<Object> get props => [];
}

class GettingPersonalInfo extends RegisterState {
  const GettingPersonalInfo();

  @override
  List<Object> get props => [];
}

class GettingRequiredPhotos extends RegisterState {
  const GettingRequiredPhotos();

  @override
  List<Object> get props => [];
}

class RequiredPhotosObtained extends RegisterState {
  final File workPhoto;
  final File profilePhoto;
  const RequiredPhotosObtained(this.workPhoto, this.profilePhoto);

  @override
  List<Object> get props => [workPhoto, profilePhoto];
}

class RegisterError extends RegisterState {
  final String error;
  const RegisterError(this.error);

  @override
  List<Object> get props => [error];
}

class RegisterAccountTypeChanged extends RegisterState {
  final String type;

  const RegisterAccountTypeChanged(this.type);

  @override
  List<Object> get props => [type];
}
