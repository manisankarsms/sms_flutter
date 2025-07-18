import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/post/post_bloc.dart';
import '../../bloc/post/post_event.dart';
import '../../bloc/post/post_state.dart';
import '../../models/post.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  void _showPostDialog({Post? existingPost}) {
    final isEdit = existingPost != null;
    if (isEdit) {
      _titleController.text = existingPost.title;
      _contentController.text = existingPost.content;
    } else {
      _titleController.clear();
      _contentController.clear();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? "Edit Post" : "New Post"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: "Content",
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton.icon(
            icon: Icon(isEdit ? Icons.save : Icons.add),
            label: Text(isEdit ? "Update" : "Add"),
            onPressed: () {
              // Validate input
              if (_titleController.text.trim().isEmpty ||
                  _contentController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please fill in both title and content"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final post = Post(
                id: isEdit ? existingPost.id : 0,
                title: _titleController.text.trim(),
                content: _contentController.text.trim(),
                author: "Admin",
                createdAt: DateTime.now().toString(),
              );

              if (isEdit) {
                context.read<PostBloc>().add(UpdatePost(post));
              } else {
                context.read<PostBloc>().add(AddPost(post));
              }

              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(int postId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Post"),
        content: const Text("Are you sure you want to delete this post?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              context.read<PostBloc>().add(DeletePost(postId));
              Navigator.of(context).pop();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.post_add,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              "No Posts Yet",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Create your first post to get started!",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showPostDialog(),
              icon: const Icon(Icons.add),
              label: const Text("Create Post"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Posts"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<PostBloc>().add(LoadPosts()),
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          // Only show FAB when posts are loaded (even if empty)
          if (state is PostsLoaded) {
            return FloatingActionButton(
              onPressed: () => _showPostDialog(),
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      body: BlocConsumer<PostBloc, PostState>(
        listener: (context, state) {
          if (state is PostOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is PostOperationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PostLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PostsLoaded) {
            // Handle empty posts case
            if (state.posts.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              itemCount: state.posts.length,
              itemBuilder: (context, index) {
                final post = state.posts[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.blue,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        post.author,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatDate(post.createdAt),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    post.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    post.content,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                              onPressed: () => _showPostDialog(existingPost: post),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                              onPressed: () => _showDeleteConfirmation(post.id!),
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is PostOperationFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Error Loading Posts",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.error,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.read<PostBloc>().add(LoadPosts()),
                    icon: const Icon(Icons.refresh),
                    label: const Text("Retry"),
                  ),
                ],
              ),
            );
          } else if (state is PostOperationInProgress) {
            // Show current posts with loading overlay
            return Stack(
              children: [
                if (state.currentPosts.isNotEmpty)
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    itemCount: state.currentPosts.length,
                    itemBuilder: (context, index) {
                      final post = state.currentPosts[index];
                      return Opacity(
                        opacity: 0.6,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(post.title),
                          ),
                        ),
                      );
                    },
                  )
                else
                  _buildEmptyState(),
                // Loading overlay
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 12),
                            Text(state.operation),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy HH:mm').format(date);
    } catch (e) {
      return dateString; // Return original string if parsing fails
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}