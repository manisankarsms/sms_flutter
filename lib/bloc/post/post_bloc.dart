import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:sms/bloc/post/post_event.dart';
import 'package:sms/bloc/post/post_state.dart';
import '../../models/post.dart';
import '../../repositories/post_repository.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository postRepository;
  List<Post> _posts = [];

  PostBloc({required this.postRepository}) : super(PostLoading()) {
    if (kDebugMode) {
      print("[PostBloc] Initialized.");
    }
    on<LoadPosts>(_onLoadPosts);
    on<AddPost>(_onAddPost);
    on<UpdatePost>(_onUpdatePost);
    on<DeletePost>(_onDeletePost);
    add(LoadPosts());
  }

  Future<void> _onLoadPosts(LoadPosts event, Emitter<PostState> emit) async {
    try {
      if (kDebugMode) {
        print("[PostBloc] Processing LoadPosts event");
      }
      emit(PostLoading());
      _posts = await postRepository.fetchPosts();
      if (kDebugMode) {
        print("[PostBloc] Emitting PostsLoaded with ${_posts.length} posts");
      }
      emit(PostsLoaded(List.from(_posts)));
    } catch (e, stacktrace) {
      if (kDebugMode) {
        print("[PostBloc] Error loading posts: $e");
        print("[PostBloc] Stacktrace: $stacktrace");
      }
      emit(PostOperationFailure('Failed to load posts: ${e.toString()}', _posts));
    }
  }

  Future<void> _onAddPost(AddPost event, Emitter<PostState> emit) async {
    try {
      emit(PostOperationInProgress(List.from(_posts), "Adding post..."));

      // Simulate adding the post
      final createdPost = await postRepository.addPost(event.post);
      _posts.insert(0, createdPost);  // Update local cache

      // Emit success
      emit(PostOperationSuccess(List.from(_posts), "Post added successfully!"));

      // Emit PostsLoaded to reload the list and update UI
      emit(PostsLoaded(List.from(_posts)));
    } catch (e) {
      // Emit failure if any error occurs
      emit(PostOperationFailure('Failed to add post: ${e.toString()}', List.from(_posts)));
    }
  }

  Future<void> _onUpdatePost(UpdatePost event, Emitter<PostState> emit) async {
    try {
      emit(PostOperationInProgress(List.from(_posts), "Updating post..."));

      // Simulate updating the post
      await postRepository.updatePost(event.post);
      final index = _posts.indexWhere((p) => p.id == event.post.id);
      if (index != -1) {
        _posts[index] = event.post;  // Update local cache
      }

      // Emit success
      emit(PostOperationSuccess(List.from(_posts), "Post updated successfully!"));

      // Emit PostsLoaded to reload the list and update UI
      emit(PostsLoaded(List.from(_posts)));
    } catch (e) {
      // Emit failure if any error occurs
      emit(PostOperationFailure('Failed to update post: ${e.toString()}', List.from(_posts)));
    }
  }

  Future<void> _onDeletePost(DeletePost event, Emitter<PostState> emit) async {
    try {
      emit(PostOperationInProgress(List.from(_posts), "Deleting post..."));

      // Simulate deleting the post
      await postRepository.deletePost(event.postId);
      _posts.removeWhere((p) => p.id == event.postId);  // Update local cache

      // Emit success
      emit(PostOperationSuccess(List.from(_posts), "Post deleted successfully!"));

      // Emit PostsLoaded to reload the list and update UI
      emit(PostsLoaded(List.from(_posts)));
    } catch (e) {
      // Emit failure if any error occurs
      emit(PostOperationFailure('Failed to delete post: ${e.toString()}', List.from(_posts)));
    }
  }

}