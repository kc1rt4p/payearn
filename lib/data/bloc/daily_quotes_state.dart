part of 'daily_quotes_bloc.dart';

abstract class DailyQuotesState extends Equatable {
  const DailyQuotesState();

  @override
  List<Object> get props => [];
}

class DailyQuotesInitial extends DailyQuotesState {}

class DailyQuotesLoaded extends DailyQuotesState {
  final Quote quote;
  final num rewardCount;

  DailyQuotesLoaded(this.quote, this.rewardCount);

  @override
  List<Object> get props => [quote, rewardCount];
}

class DailyQuotesWillAdd extends DailyQuotesState {
  final List<Quote> quotes;

  DailyQuotesWillAdd(this.quotes);

  @override
  List<Object> get props => [quotes];
}

class DailyQuotesAdded extends DailyQuotesState {}

class DailyQuotesDeleted extends DailyQuotesState {}

class DailyQuotesLoading extends DailyQuotesState {}

class DailyQuotesDone extends DailyQuotesState {}

class DailyQuotesRewarded extends DailyQuotesState {}

class DailyQuotesMaxed extends DailyQuotesState {
  final DateTime lastRewardDate;

  DailyQuotesMaxed(this.lastRewardDate);

  @override
  List<Object> get props => [lastRewardDate];
}
