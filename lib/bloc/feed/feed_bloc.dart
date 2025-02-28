import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/post.dart';
import '../../repositories/feed_repository.dart';

part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final FeedRepository feedRepository;

  FeedBloc({required this.feedRepository}) : super(FeedLoading()) {
    print("feed bloc : Initialised");
    on<LoadFeed>(_onLoadFeed);
    add(LoadFeed());
  }

  Future<void> _onLoadFeed(LoadFeed event, Emitter<FeedState> emit) async {
    print("feed bloc : onLoadFeed called");
    try {
      emit(FeedLoading());
      final posts = await feedRepository.fetchFeedPosts();
      emit(FeedLoaded(posts));
    } catch (e) {
      emit(FeedFailure('Failed to load feed: ${e.toString()}'));
    }
  }
}