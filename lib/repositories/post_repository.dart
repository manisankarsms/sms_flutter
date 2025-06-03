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
      final Map<String, dynamic> response = jsonDecode(responseString);
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch posts');
      }
      final List<dynamic> postsJson = response['data'];
      return postsJson.map((json) => Post.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching posts: $e");
      }
      throw Exception('Failed to fetch posts: $e');
    }
  }

  Future<void> addPost(Post newPost) async {
    try {
      final String postJson = jsonEncode(newPost.toJson());
      final responseString = await webService.postData(ApiEndpoints.adminPosts, postJson);

      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? response['description'] ?? 'Failed to add post');
      }
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
      final responseString = await webService.putData('posts/${post.id}', postJson);
      if (kDebugMode) {
        print("Update Post API Response: $responseString");
      }
      final Map<String, dynamic> response = jsonDecode(responseString);
      if (response['success'] != true) {
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
      final responseString = await webService.deleteData('posts/$postId');
      if (kDebugMode) {
        print("Delete Post API Response: $responseString");
      }
      final Map<String, dynamic> response = jsonDecode(responseString);
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to delete post');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting post: $e");
      }
      throw Exception('Failed to delete post: $e');
    }
  }
}