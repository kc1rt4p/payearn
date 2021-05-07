import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../models/subscriber.dart';
import '../repositories/account_repository.dart';
import '../repositories/platinum_repository.dart';
import '../repositories/referral_repository.dart';
import '../repositories/subscriber_repository.dart';
import '../repositories/wallet_repository.dart';

part 'subscriber_details_event.dart';
part 'subscriber_details_state.dart';

class SubscriberDetailsBloc
    extends Bloc<SubscriberDetailsEvent, SubscriberDetailsState> {
  SubscriberRepository subscriberRepository = SubscriberRepository();
  AccountRepository accountRepository = AccountRepository();
  PlatinumRepository platinumRepository = PlatinumRepository();
  ReferralRepository referralRepository = ReferralRepository();
  WalletRepository walletRepository = WalletRepository();

  SubscriberDetailsBloc() : super(SubscriberDetailsInitial());

  @override
  Stream<SubscriberDetailsState> mapEventToState(
    SubscriberDetailsEvent event,
  ) async* {
    yield SubscriberDetailsLoading();

    if (event is LoadSubscriberDetails) {
      try {
        final subscriber = await subscriberRepository.get(event.subscriberId);

        if (subscriber != null) {
          yield SubscriberDetailsLoaded(subscriber);
        } else {
          yield SubscriberDetailsError('Error getting subscriber details');
        }
      } catch (e) {
        yield SubscriberDetailsError('Something went wrong on the server');
      }
    }

    if (event is LoadSubscriberInfo) {
      try {
        yield SubscriberDetailsLoading();

        final subscriber = await subscriberRepository.get(event.subscriberId);
        final account = await accountRepository.get(event.subscriberId);
        final referrer = await subscriberRepository.get(account.referrerId);
        final platinum = await platinumRepository.get(event.subscriberId);
        final referrals = await referralRepository.getAll(event.subscriberId);
        final referral = await referralRepository.get(
            account.referrerId, event.subscriberId);
        final wallet = await walletRepository.get(event.subscriberId);

        final result = {
          'subscriber': subscriber,
          'account': account,
          'referrer': referrer,
          'platinum': platinum,
          'referrals': referrals,
          'referral': referral,
          'wallet': wallet,
        };

        yield SubscriberInfoLoaded(result);
      } catch (e) {
        print('error loading subscriber info: ${e.toString()}');
        yield SubscriberDetailsError('Something went wrong on the server');
      }
    }

    if (event is VerifySubscriber) {
      yield SubscriberVerifying();

      try {
        await subscriberRepository.verifySubscriber(event.subscriberId);
        yield SubscriberVerified();
        add(LoadSubscriberInfo(event.subscriberId));
      } catch (e) {
        yield SubscriberDetailsError('Something went wrong on the server');
      }
    }

    if (event is UpdateSubscriberWallet) {
      yield SubscriberDetailsLoading();
      try {
        final updated =
            await walletRepository.update(event.subscriberId, event.walletData);
        if (updated) {
          yield SubscriberWalletUpdated();
          add(LoadSubscriberInfo(event.subscriberId));
        }
      } catch (e) {
        yield SubscriberDetailsError('Something went wrong on the server');
      }
    }
  }
}
