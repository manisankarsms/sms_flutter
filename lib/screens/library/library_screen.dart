import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/library/library_bloc.dart';
import '../../bloc/library/library_event.dart';
import '../../bloc/library/library_state.dart';
import '../../models/book.dart';
import 'add_book_screen.dart';
import 'issue_book_screen.dart';

class LibraryScreen extends StatefulWidget {
  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Book> _filteredBooks = [];

  @override
  void initState() {
    super.initState();
    context.read<LibraryBloc>().add(FetchBooks());
  }

  void _filterBooks(List<Book> books, String query) {
    setState(() {
      _filteredBooks = books
          .where((book) =>
      book.title.toLowerCase().contains(query.toLowerCase()) ||
          book.author.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Library Management")),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: BlocBuilder<LibraryBloc, LibraryState>(
              builder: (context, state) {
                if (state is LibraryLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is BooksLoaded) {
                  _filteredBooks = _filteredBooks.isEmpty ? state.books : _filteredBooks;
                  return _filteredBooks.isNotEmpty
                      ? _buildBookList(context, _filteredBooks)
                      : Center(child: Text("No books found."));
                } else if (state is LibraryError) {
                  return Center(child: Text(state.message));
                } else {
                  return Center(child: Text("No books available"));
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddBookScreen()),
        ),
        child: Icon(Icons.add),
        tooltip: "Add Book",
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: TextField(
        controller: _searchController,
        onChanged: (query) => _filterBooks(context.read<LibraryBloc>().state is BooksLoaded
            ? (context.read<LibraryBloc>().state as BooksLoaded).books
            : [] , query),
        decoration: InputDecoration(
          hintText: "Search books...",
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBookList(BuildContext context, List<Book> books) {
    return ListView.builder(
      padding: EdgeInsets.all(10),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            contentPadding: EdgeInsets.all(10),
            title: Text(
              book.title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text("${book.author} - ${book.category}"),
            trailing: book.availableCopies > 0
                ? PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'Issue') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => IssueBookScreen(book: book)),
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'Issue', child: Text("Issue Book")),
              ],
            )
                : Text("Not Available", style: TextStyle(color: Colors.red)),
          ),
        );
      },
    );
  }
}
