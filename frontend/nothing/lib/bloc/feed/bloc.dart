import 'dart:async';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:nothing/bloc/feed/event.dart';
import 'package:nothing/bloc/feed/state.dart';
import 'package:nothing/bloc/questions/bloc.dart';

export 'event.dart';
export 'state.dart';

class FeedBloc extends Bloc<FeedEvent, Feed> {
  final int threshold;
  final QuestionsBloc questionsBloc;
  StreamSubscription _sub;

  FeedBloc({
    @required this.questionsBloc,
    this.threshold = 6,
  }) {
    _sub = questionsBloc.listen((state) {
      if (state is LoadedQuestions) {
        add(NewArrived(state.questions));
      }
    });
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }

  @override
  Feed get initialState => EmptyFeed();

  @override
  Stream<Feed> mapEventToState(FeedEvent event) async* {
    if (event is NewArrived) {
      yield* _mapNewArrived(event);
    } else if (event is MoveNext) {
      yield* _mapMoveNext();
    }
  }

  Stream<Feed> _mapNewArrived(NewArrived event) async* {
    yield Feed(
      state.batch.toList()..addAll(event.batch),
      state.batch.toList(),
    );
  }

  Stream<Feed> _mapMoveNext() async* {
    print('l1: ${state.batch.length}');
    yield Feed(
      state.batch.toList()..removeAt(0),
      state.batch.toList(),
    );
    print('l2: ${state.batch.length}');
    if (state.batch.length == threshold) {
      questionsBloc.add(FetchQuestions());
    }
  }
}