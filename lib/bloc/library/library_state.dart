import 'package:equatable/equatable.dart';

import '../../models/book.dart';
import '../../models/issued_book.dart';

abstract class LibraryState extends Equatable {
  @override
  List<Object?> get props => [];
}

// Initial state
class LibraryInitial extends LibraryState {}

// Loading state
class LibraryLoading extends LibraryState {}

// Books fetched successfully
class BooksLoaded extends LibraryState {
  final List<Book> books;
  BooksLoaded(this.books);

  @override
  List<Object?> get props => [books];
}

// Book added successfully
class BookAdded extends LibraryState {}

// Book issued successfully
class BookIssued extends LibraryState {}

// Book returned successfully
class BookReturned extends LibraryState {}

// Issued books fetched successfully
class IssuedBooksLoaded extends LibraryState {
  final List<IssuedBook> issuedBooks;
  IssuedBooksLoaded(this.issuedBooks);

  @override
  List<Object?> get props => [issuedBooks];
}

// Error state
class LibraryError extends LibraryState {
  final String message;
  LibraryError(this.message);

  @override
  List<Object?> get props => [message];
}
