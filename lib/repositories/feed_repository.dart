import 'dart:convert';

import 'package:sms/utils/constants.dart';

import '../models/post.dart';
import '../services/web_service.dart';

class FeedRepository {
  final WebService webService;

  FeedRepository({required this.webService});

  Future<List<Post>> fetchFeedPosts() async {
    try {
      final String responseString = await webService.fetchData(ApiEndpoints.adminPosts);
      final Map<String, dynamic> response = jsonDecode(responseString);
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch posts');
      }
      final List<dynamic> postsJson = response['data'];
      return postsJson.map((json) => Post.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }
}