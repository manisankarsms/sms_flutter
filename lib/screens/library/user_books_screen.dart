import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/library/library_bloc.dart';
import '../../bloc/library/library_state.dart';
import '../../models/book.dart';

class UserBooksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Library Books")),
      body: BlocBuilder<LibraryBloc, LibraryState>(
        builder: (context, state) {
          if (state is LibraryLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is BooksLoaded) {
            return _buildBookList(state.books);
          } else if (state is LibraryError) {
            return Center(child: Text(state.message));
          } else {
            return Center(child: Text("No books available"));
          }
        },
      ),
    );
  }

  Widget _buildBookList(List<Book> books) {
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return ListTile(
          title: Text(book.title),
          subtitle: Text("${book.author} - ${book.category}"),
          trailing: book.availableCopies > 0
              ? Text("Available: ${book.availableCopies}")
              : Text("Not Available", style: TextStyle(color: Colors.red)),
        );
      },
    );
  }
}
