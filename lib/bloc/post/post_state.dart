// post_state.dart
import 'package:equatable/equatable.dart';
import '../../models/post.dart';

abstract class PostState extends Equatable {
  const PostState();
  @override
  List<Object?> get props => [];
}

class PostLoading extends PostState {}

class PostsLoaded extends PostState {
  final List<Post> posts;
  const PostsLoaded(this.posts);
  @override
  List<Object?> get props => [posts];
}

class PostOperationInProgress extends PostState {
  final List<Post> currentPosts;
  final String operation;
  const PostOperationInProgress(this.currentPosts, this.operation);
  @override
  List<Object?> get props => [currentPosts, operation];
}

class PostOperationSuccess extends PostState {
  final List<Post> posts;
  final String message;
  const PostOperationSuccess(this.posts, this.message);
  @override
  List<Object?> get props => [posts, message];
}

class PostOperationFailure extends PostState {
  final String error;
  final List<Post> currentPosts;
  const PostOperationFailure(this.error, this.currentPosts);
  @override
  List<Object?> get props => [error, currentPosts];
}