import 'package:equatable/equatable.dart';

import '../../models/book.dart';
import '../../models/issued_book.dart';

abstract class LibraryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Fetch all books
class FetchBooks extends LibraryEvent {}

// Add a new book
class AddBook extends LibraryEvent {
  final Book book;
  AddBook(this.book);

  @override
  List<Object?> get props => [book];
}

// Issue a book
class IssueBook extends LibraryEvent {
  final IssuedBook issuedBook;
  IssueBook(this.issuedBook);

  @override
  List<Object?> get props => [issuedBook];
}

// Return a book
class ReturnBook extends LibraryEvent {
  final String issuedBookId;
  ReturnBook(this.issuedBookId);

  @override
  List<Object?> get props => [issuedBookId];
}

// Fetch issued books
class FetchIssuedBooks extends LibraryEvent {}
