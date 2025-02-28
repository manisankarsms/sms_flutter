part of 'feed_bloc.dart';

abstract class FeedState extends Equatable {
  const FeedState();

  @override
  List<Object?> get props => [];
}

class FeedLoading extends FeedState {}

class FeedLoaded extends FeedState {
  final List<Post> posts;
  const FeedLoaded(this.posts);

  @override
  List<Object?> get props => [posts];
}

class FeedFailure extends FeedState {
  final String error;
  const FeedFailure(this.error);

  @override
  List<Object?> get props => [error];
}