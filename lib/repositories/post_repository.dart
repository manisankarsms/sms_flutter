// repository/post_repository.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/post.dart';
import '../services/web_service.dart';

class PostRepository {
  final WebService webService;

  PostRepository({required this.webService});

  Future<List<Post>> fetchPosts() async {
    try {
      final String responseString = await webService.fetchData('admin/posts');
      if (kDebugMode) {
        print("API Response: $responseString");
      } // Debugging

      final Map<String, dynamic> response = jsonDecode(responseString);
      final List<dynamic> postsJson = response['posts'];
      return postsJson.map((json) => Post.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching posts: $e");
      } // Debugging
      throw Exception('Failed to fetch posts: $e');
    }
  }

  Future<void> addPost(Post newPost) async {
    try {
      // Convert to JSON string since webService.postData expects a String
      final String postJson = jsonEncode(newPost.toJson());
      await webService.postData('admin/posts', postJson);
    } catch (e) {
      throw Exception('Failed to add post: $e');
    }
  }

  Future<void> updatePost(Post post) async {
    try {
      final String postJson = jsonEncode(post.toJson());
      await webService.putData('admin/posts/${post.id}', postJson);
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await webService.deleteData('admin/posts/$postId');
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  // Mock implementation methods remain the same
  Future<List<Post>> fetchPostsMock() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Post(
        id: "1",
        title: "Important Announcement",
        author: "Admin",
        content: "School will be closed on Monday due to weather conditions.",
        createdAt: DateTime.now().subtract(Duration(days: 1)),
      ),
      Post(
        id: "2",
        title: "Upcoming Events",
        author: "Admin",
        content: "Check out the upcoming science fair next week.",
        createdAt: DateTime.now().subtract(Duration(days: 3)),
      ),
      Post(
        id: "3",
        title: "New Curriculum",
        author: "Principal",
        content: "We're introducing a new mathematics curriculum next semester.",
        createdAt: DateTime.now().subtract(Duration(days: 5)),
      ),
    ];
  }

  Future<void> addPostMock(Post newPost) async {
    await Future.delayed(Duration(seconds: 1));
  }

  Future<void> updatePostMock(Post post) async {
    await Future.delayed(Duration(seconds: 1));
  }

  Future<void> deletePostMock(String postId) async {
    await Future.delayed(Duration(seconds: 1));
  }
}