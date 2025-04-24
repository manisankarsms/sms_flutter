import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sms/utils/constants.dart';
import '../models/post.dart';
import '../services/web_service.dart';

class PostRepository {
  final WebService webService;

  PostRepository({required this.webService});

  Future<List<Post>> fetchPosts() async {
    try {
      final String responseString = await webService.fetchData(ApiEndpoints.adminPosts);
      if (kDebugMode) {
        print("Fetch Posts API Response: $responseString");
      }
      final Map<String, dynamic> response = jsonDecode(responseString);
      if (response['status'] != 1) {
        throw Exception(response['message'] ?? 'Failed to fetch posts');
      }
      final List<dynamic> postsJson = response['posts'];
      return postsJson.map((json) => Post.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching posts: $e");
      }
      throw Exception('Failed to fetch posts: $e');
    }
  }

  Future<Post> addPost(Post newPost) async {
    try {
      final String postJson = jsonEncode(newPost.toJson());
      final responseString = await webService.postData('admin/posts', postJson);

      if (kDebugMode) {
        print("Add Post API Response: $responseString");
      }

      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['status'] != 1) {
        throw Exception(response['message'] ?? response['description'] ?? 'Failed to add post');
      }

      // Create a Post object from the response data
      return Post(
        id: response['id'],
        title: response['title'],
        content: response['content'],
        author: response['author'],
        createdAt: DateTime.parse(response['created_at']),
        imageUrl: response['image_url'],
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error adding post: $e");
      }
      throw Exception('Failed to add post: $e');
    }
  }

  Future<void> updatePost(Post post) async {
    try {
      final String postJson = jsonEncode(post.toJson());
      final responseString = await webService.putData('admin/posts/${post.id}', postJson);
      if (kDebugMode) {
        print("Update Post API Response: $responseString");
      }
      final Map<String, dynamic> response = jsonDecode(responseString);
      if (response['status'] != 1) {
        throw Exception(response['message'] ?? 'Failed to update post');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating post: $e");
      }
      throw Exception('Failed to update post: $e');
    }
  }

  Future<void> deletePost(int? postId) async {
    try {
      if (postId == null) {
        throw Exception('Post ID is null');
      }
      final responseString = await webService.deleteData('admin/posts/$postId');
      if (kDebugMode) {
        print("Delete Post API Response: $responseString");
      }
      final Map<String, dynamic> response = jsonDecode(responseString);
      if (response['status'] != 1) {
        throw Exception(response['message'] ?? 'Failed to delete post');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting post: $e");
      }
      throw Exception('Failed to delete post: $e');
    }
  }

  // Mock implementation methods (unchanged)
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