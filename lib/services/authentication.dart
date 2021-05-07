import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/account.dart';
import '../data/models/subscriber.dart';
import '../data/repositories/account_repository.dart';
import '../data/repositories/subscriber_repository.dart';

class AuthenticationService {
  final IAccountRepository accountRepository;
  final ISubscriberRepository subscriberRepository;

  String _currentUserId;
  String _currentUserType;
  Account _currentAccount;
  Subscriber _currentSubscriber;

  AuthenticationService(this.accountRepository, this.subscriberRepository);

  String get currentUserId {
    return _currentUserId;
  }

  String get currentUserType {
    return _currentUserType;
  }

  Account get currentAccount {
    return _currentAccount;
  }

  Subscriber get currentSubscriber {
    return _currentSubscriber;
  }

  Future<Map<String, dynamic>> checkIfLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String username = prefs.get('payearn_username');
    final String password = prefs.get('payearn_password');
    if (username == null || password == null) return null;
    return await signInWithUsernameAndPassword(username, password);
  }

  changePassword(String id, String newPassword) async {
    try {
      await accountRepository.changePassword(id, newPassword);
      return true;
    } catch (e) {
      return false;
    }
  }

  signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('payearn_username');
    prefs.remove('payearn_password');
    _currentUserId = null;
    _currentUserType = null;
    _currentAccount = null;
    _currentSubscriber = null;
  }

  Future<String> verifyReferralCode(String code) async {
    return await accountRepository.verifyReferralCode(code);
  }

  Future<Map<String, dynamic>> signInWithUsernameAndPassword(
      String username, String password) async {
    final isValid = await accountRepository.login(username, password);
    if (!isValid) return null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('payearn_username', username);
    prefs.setString('payearn_password', password);
    final account = await accountRepository.get(username);
    final subscriber = await subscriberRepository.get(username);
    _currentUserId = account.username;
    _currentUserType = account.type;
    _currentAccount = account;
    _currentSubscriber = subscriber;
    return {
      'account': account,
      'subscriber': subscriber,
    };
  }

  Future<Map<String, dynamic>> registerUser(String referralCode, Map account,
      Map subscriber, File idPhoto, File profilePhoto) async {
    final newAccount = await accountRepository.create(account, referralCode);

    final newSubscriber = await subscriberRepository.create(
        account['username'], subscriber, idPhoto, profilePhoto);

    if (newAccount == null || newSubscriber == null) return null;

    _currentAccount = newAccount;
    _currentSubscriber = newSubscriber;

    return {
      'account': newAccount,
      'subscriber': newSubscriber,
    };
  }
}
