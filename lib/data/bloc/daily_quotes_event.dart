part of 'daily_quotes_bloc.dart';

abstract class DailyQuotesEvent extends Equatable {
  const DailyQuotesEvent();

  @override
  List<Object> get props => [];
}

class DailyQuotesInitialize extends DailyQuotesEvent {
  final String id;

  DailyQuotesInitialize(this.id);

  @override
  List<Object> get props => [id];
}

class DailyQuotesAdd extends DailyQuotesEvent {
  final Map quote;

  DailyQuotesAdd(this.quote);

  @override
  List<Object> get props => [quote];
}

class DailyQuotesLoad extends DailyQuotesEvent {
  final String id;

  DailyQuotesLoad(this.id);

  @override
  List<Object> get props => [id];
}

class DailyQuotesDelete extends DailyQuotesEvent {
  final String id;

  DailyQuotesDelete(this.id);

  @override
  List<Object> get props => [id];
}

class DailyQuotesShowAdd extends DailyQuotesEvent {}

class DailyQuotesGiveReward extends DailyQuotesEvent {
  final String id;

  DailyQuotesGiveReward(this.id);

  @override
  List<Object> get props => [id];
}

class DailyQuotesFinish extends DailyQuotesEvent {}
