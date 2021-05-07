import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:ntp/ntp.dart';

import '../models/platinum.dart';
import '../models/wallet.dart';
import '../repositories/platinum_repository.dart';
import '../repositories/wallet_repository.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository walletRepository;
  PlatinumRepository platinumRepository = PlatinumRepository();
  WalletBloc(this.walletRepository) : super(WalletInitial());

  StreamSubscription wallet;

  @override
  Stream<WalletState> mapEventToState(WalletEvent event) async* {
    yield WalletLoading();

    if (event is CheckDailyEarnings) {
      try {
        await walletRepository.checkDailyEarnings(event.subscriberId);
      } catch (e) {}

      add(LoadWallet(subscriberId: event.subscriberId));
    }

    if (event is LoadWallet) {
      yield WalletLoading();

      wallet?.cancel();

      final platinum = await platinumRepository.get(event.subscriberId);

      wallet = walletRepository
          .streamWallet(event.subscriberId)
          .listen((walletdata) {
        add(WalletReady(walletdata, platinum));
      });
    }

    if (event is WalletReady) {
      if (event.wallet != null) {
        final currentDate = await NTP.now();
        yield WalletLoaded(event.wallet, event.platinum, currentDate);
      } else
        yield WalletNotFound();
    }
  }
}
