import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/library/library_bloc.dart';
import '../../bloc/library/library_state.dart';
import '../../models/issued_book.dart';

class MyIssuedBooksScreen extends StatelessWidget {
  final String userId; // User ID of logged-in student/staff

  MyIssuedBooksScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Issued Books")),
      body: BlocBuilder<LibraryBloc, LibraryState>(
        builder: (context, state) {
          if (state is LibraryLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is IssuedBooksLoaded) {
            return _buildIssuedBooksList(state.issuedBooks);
          } else if (state is LibraryError) {
            return Center(child: Text(state.message));
          } else {
            return Center(child: Text("No issued books found"));
          }
        },
      ),
    );
  }

  Widget _buildIssuedBooksList(List<IssuedBook> issuedBooks) {
    final myBooks = issuedBooks.where((book) => book.userId == userId).toList();

    if (myBooks.isEmpty) {
      return Center(child: Text("You have not borrowed any books."));
    }

    return ListView.builder(
      itemCount: myBooks.length,
      itemBuilder: (context, index) {
        final book = myBooks[index];
        return ListTile(
          title: Text("Book ID: ${book.bookId}"),
          subtitle: Text("Due Date: ${book.dueDate}"),
          trailing: book.isReturned
              ? Icon(Icons.check_circle, color: Colors.green)
              : Icon(Icons.warning, color: Colors.red),
        );
      },
    );
  }
}
