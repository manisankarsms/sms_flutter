import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms/utils/theme.dart';
import '../bloc/feed/feed_bloc.dart';
import '../models/post.dart';

class StudentFeedScreen extends StatelessWidget {
  const StudentFeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface, // Change to your preferred color
      body: BlocBuilder<FeedBloc, FeedState>(
        builder: (context, state) {
          if (state is FeedLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FeedFailure) {
            return Center(child: Text(state.error));
          } else if (state is FeedLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<FeedBloc>().add(LoadFeed());
              },
              child: ListView.builder(
                itemCount: state.posts.length,
                itemBuilder: (context, index) {
                  return PostWidget(post: state.posts[index]);
                },
              ),
            );
          }
          return const Center(child: Text('Unexpected state'));
        },
      ),
    );
  }
}

class PostWidget extends StatelessWidget {
  final Post post;
  const PostWidget({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal,
              child: Text(
                post.author[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              post.author,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              post.title,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              post.content,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {},
                    ),
                  ],
                ),
                Text(
                  post.createdAt,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

