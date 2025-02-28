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
  final Post? currentPost;
  const PostsLoaded(this.posts, [this.currentPost]);

  @override
  List<Object?> get props => [posts, currentPost];
}
class PostOperationFailure extends PostState {
  final String error;
  const PostOperationFailure(this.error);
  @override
  List<Object?> get props => [error];
}