import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../services/reward.dart';
import '../models/quote.dart';
import '../repositories/quote_repository.dart';

part 'daily_quotes_event.dart';
part 'daily_quotes_state.dart';

class DailyQuotesBloc extends Bloc<DailyQuotesEvent, DailyQuotesState> {
  QuoteRepository quoteRepository = new QuoteRepository();

  DailyQuotesBloc() : super(DailyQuotesInitial());

  @override
  Stream<DailyQuotesState> mapEventToState(
    DailyQuotesEvent event,
  ) async* {
    if (event is DailyQuotesInitialize) {
      yield DailyQuotesLoading();
      yield DailyQuotesInitial();
    }

    if (event is DailyQuotesFinish) {
      yield DailyQuotesDone();
    }

    if (event is DailyQuotesDelete) {
      yield DailyQuotesLoading();

      final result = await quoteRepository.delete(event.id);

      if (result) {
        yield DailyQuotesDeleted();
      }

      final quotes = await quoteRepository.getAll();

      yield DailyQuotesWillAdd(quotes);
    }

    if (event is DailyQuotesShowAdd) {
      final quotes = await quoteRepository.getAll();

      yield DailyQuotesWillAdd(quotes);
    }

    if (event is DailyQuotesAdd) {
      yield DailyQuotesLoading();
      final result = await quoteRepository.add(event.quote);
      if (result != null) {
        yield DailyQuotesAdded();
      }

      final quotes = await quoteRepository.getAll();
      yield DailyQuotesWillAdd(quotes);
    }

    if (event is DailyQuotesGiveReward) {
      yield DailyQuotesLoading();
      RewardService rewardService = new RewardService(event.id);
      await rewardService.giveReward();
      yield DailyQuotesRewarded();
      add(DailyQuotesLoad(event.id));
    }

    if (event is DailyQuotesLoad) {
      yield DailyQuotesLoading();
      RewardService rewardService = new RewardService(event.id);

      final quotes = await quoteRepository.getAll();

      final rewardCount = await rewardService.checkRewardCount();

      Random random = new Random();
      int randomIndex = random.nextInt(quotes.length);

      yield DailyQuotesLoaded(quotes[randomIndex], rewardCount);
    }
  }
}
