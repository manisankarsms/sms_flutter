import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/post/post_bloc.dart';
import '../bloc/post/post_event.dart';
import '../bloc/post/post_state.dart';
import '../models/post.dart';

class PostsScreen extends StatelessWidget {
  const PostsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Manage Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showPostForm(context),
          ),
        ],
      ),
      body: BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          if (state is PostLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PostOperationFailure) {
            return Center(child: Text(state.error));
          } else if (state is PostsLoaded) {
            if (state.posts.isEmpty) {
              return const Center(child: Text('No posts available'));
            }
            return ListView.separated(
              itemCount: state.posts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final post = state.posts[index];
                return PostItem(
                  post: post,
                  onEdit: () => _showPostForm(context, post),
                  onDelete: () => _confirmDelete(context, post),
                );
              },
            );
          }
          return const Center(child: Text('Unexpected state'));
        },
      ),
    );
  }

  void _showPostForm(BuildContext context, [Post? post]) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    if (isMobile) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => PostForm(post: post),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          child: SizedBox(
            width: 600,
            child: PostForm(post: post),
          ),
        ),
      );
    }
  }

  void _confirmDelete(BuildContext context, Post post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<PostBloc>().add(DeletePost(post.id));
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class PostItem extends StatelessWidget {
  final Post post;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PostItem({
    required this.post,
    required this.onEdit,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(post.title),
        subtitle: Text(
          post.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}

class PostForm extends StatefulWidget {
  final Post? post;

  const PostForm({this.post, Key? key}) : super(key: key);

  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post?.title ?? '');
    _contentController = TextEditingController(text: widget.post?.content ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 5,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text(widget.post == null ? 'Create Post' : 'Update Post'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final post = Post(
        id: widget.post?.id ?? DateTime.now().toString(),
        title: _titleController.text,
        content: _contentController.text,
        author: widget.post?.author ?? 'Admin',
        createdAt: widget.post?.createdAt ?? DateTime.now(),
      );

      if (widget.post == null) {
        context.read<PostBloc>().add(AddPost(post));
      } else {
        context.read<PostBloc>().add(UpdatePost(post));
      }

      Navigator.pop(context);
    }
  }
}
