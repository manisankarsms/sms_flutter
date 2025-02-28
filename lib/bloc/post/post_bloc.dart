// bloc/post/post_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:sms/bloc/post/post_event.dart';
import 'package:sms/bloc/post/post_state.dart';
import '../../models/post.dart';
import '../../repositories/post_repository.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository postRepository;
  List<Post> _posts = [];
  Post? _currentPost;

  PostBloc({required this.postRepository}) : super(PostLoading()) {
    print("[PostBloc] Initialized.");
    on<LoadPosts>(_onLoadPosts);
    on<AddPost>(_onAddPost);
    on<UpdatePost>(_onUpdatePost);
    on<DeletePost>(_onDeletePost);
    on<SetCurrentPost>(_onSetCurrentPost);
    add(LoadPosts()); // Automatically load staff when the bloc is created
  }

  Future<void> _onLoadPosts(LoadPosts event, Emitter<PostState> emit) async {
    try {
      print("[PostBloc] Loading posts...");
      emit(PostLoading());

      // Fetch posts from repository
      _posts = await postRepository.fetchPosts();

      if (_posts.isNotEmpty) {
        print("[PostBloc] Posts loaded successfully. Count: ${_posts.length}");
        emit(PostsLoaded(List.from(_posts), _currentPost));
      } else {
        print("[PostBloc] No posts found.");
        emit(PostOperationFailure("No posts available."));
      }
    } catch (e, stacktrace) {
      print("[PostBloc] Error loading posts: $e");
      print("[PostBloc] Stacktrace: $stacktrace");
      emit(PostOperationFailure('Failed to load posts: ${e.toString()}'));
    }
  }


  Future<void> _onAddPost(AddPost event, Emitter<PostState> emit) async {
    try {
      emit(PostLoading());
      // Change this to postRepository.addPost() when API is ready
      await postRepository.addPostMock(event.post);
      _posts.insert(0, event.post);
      emit(PostsLoaded(List.from(_posts), _currentPost));
    } catch (e) {
      emit(PostOperationFailure('Failed to add post: ${e.toString()}'));
    }
  }

  Future<void> _onUpdatePost(UpdatePost event, Emitter<PostState> emit) async {
    try {
      emit(PostLoading());
      // Change this to postRepository.updatePost() when API is ready
      await postRepository.updatePostMock(event.post);
      final index = _posts.indexWhere((p) => p.id == event.post.id);
      if (index != -1) {
        _posts[index] = event.post;
      }
      emit(PostsLoaded(List.from(_posts), _currentPost));
    } catch (e) {
      emit(PostOperationFailure('Failed to update post: ${e.toString()}'));
    }
  }

  Future<void> _onDeletePost(DeletePost event, Emitter<PostState> emit) async {
    try {
      emit(PostLoading());
      // Change this to postRepository.deletePost() when API is ready
      await postRepository.deletePostMock(event.postId);
      _posts.removeWhere((p) => p.id == event.postId);
      emit(PostsLoaded(List.from(_posts), _currentPost));
    } catch (e) {
      emit(PostOperationFailure('Failed to delete post: ${e.toString()}'));
    }
  }

  void _onSetCurrentPost(SetCurrentPost event, Emitter<PostState> emit) {
    _currentPost = event.post;
    emit(PostsLoaded(List.from(_posts), _currentPost));
  }
}