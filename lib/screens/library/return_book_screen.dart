import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/library/library_bloc.dart';
import '../../bloc/library/library_event.dart';
import '../../bloc/library/library_state.dart';
import '../../models/issued_book.dart';

class ReturnBookScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Return Books")),
      body: BlocBuilder<LibraryBloc, LibraryState>(
        builder: (context, state) {
          if (state is LibraryLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is IssuedBooksLoaded) {
            return _buildIssuedBooksList(context, state.issuedBooks);
          } else if (state is LibraryError) {
            return Center(child: Text(state.message));
          } else {
            return Center(child: Text("No issued books found"));
          }
        },
      ),
    );
  }

  Widget _buildIssuedBooksList(BuildContext context, List<IssuedBook> issuedBooks) {
    return ListView.builder(
      itemCount: issuedBooks.length,
      itemBuilder: (context, index) {
        final issuedBook = issuedBooks[index];

        return ListTile(
          title: Text("Book ID: ${issuedBook.bookId}"),
          subtitle: Text("Issued to User: ${issuedBook.userId}"),
          trailing: ElevatedButton(
            onPressed: () {
              context.read<LibraryBloc>().add(ReturnBook(issuedBook.id));
            },
            child: Text("Return"),
          ),
        );
      },
    );
  }
}
