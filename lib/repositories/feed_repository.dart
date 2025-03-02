import 'dart:convert';

import 'package:sms/utils/constants.dart';

import '../models/post.dart';
import '../services/web_service.dart';

class FeedRepository {
  final WebService webService;

  FeedRepository({required this.webService});

  Future<List<Post>> fetchFeedPosts() async {
    try {
      final String responseString = await webService.fetchData(ApiEndpoints.studentFeed);
      final Map<String, dynamic> response = jsonDecode(responseString);
      final List<dynamic> postsJson = response['posts'];
      return postsJson.map((json) => Post.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch feed posts: $e');
    }
  }
}