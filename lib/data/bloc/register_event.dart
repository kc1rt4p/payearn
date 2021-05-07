part of 'register_bloc.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();
}

class RegisterReset extends RegisterEvent {
  const RegisterReset();

  @override
  List<Object> get props => [];
}

class VerifyReferralCode extends RegisterEvent {
  final String code;

  const VerifyReferralCode(this.code);

  @override
  List<Object> get props => [code];
}

class RegisterChangeAccountType extends RegisterEvent {
  final String type;

  const RegisterChangeAccountType(this.type);

  @override
  List<Object> get props => [type];
}

class GetPersonalInformation extends RegisterEvent {
  const GetPersonalInformation();

  @override
  List<Object> get props => [];
}

class GetAccountInformation extends RegisterEvent {
  const GetAccountInformation();

  @override
  List<Object> get props => [];
}

class GetRequiredPhotos extends RegisterEvent {
  const GetRequiredPhotos();

  @override
  List<Object> get props => [];
}

class RegisterUser extends RegisterEvent {
  final String referralCode;
  final Map account;
  final Map subscriber;
  final File workPhoto;
  final File profilePhoto;

  const RegisterUser(this.referralCode, this.account, this.subscriber,
      this.workPhoto, this.profilePhoto);

  @override
  List<Object> get props => [
        referralCode,
        account,
        subscriber,
        workPhoto,
        profilePhoto,
      ];
}
