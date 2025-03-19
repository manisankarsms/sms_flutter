import 'dart:convert';

import '../models/book.dart';
import '../models/issued_book.dart';
import '../services/web_service.dart';
import '../utils/constants.dart';

class LibraryRepository {
  final WebService webService;

  LibraryRepository({required this.webService});

  // Fetch all books
  Future<List<Book>> fetchBooks() async {
    try {
      final response = await webService.fetchData(ApiEndpoints.books);
      final List<dynamic> booksJson = jsonDecode(response);
      return booksJson.map((json) => Book.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to fetch books: ${error.toString()}');
    }
  }

  // Add a new book
  Future<void> addBook(Book book) async {
    try {
      final requestBody = jsonEncode(book.toJson());
      await webService.postData(ApiEndpoints.addBook, requestBody);
    } catch (error) {
      throw Exception('Failed to add book: ${error.toString()}');
    }
  }

  // Issue a book to a user
  Future<void> issueBook(IssuedBook issuedBook) async {
    try {
      final requestBody = jsonEncode(issuedBook.toJson());
      await webService.postData(ApiEndpoints.issueBook, requestBody);
    } catch (error) {
      throw Exception('Failed to issue book: ${error.toString()}');
    }
  }

  // Return a book
  Future<void> returnBook(String issuedBookId) async {
    try {
      final requestBody = jsonEncode({'id': issuedBookId});
      await webService.postData(ApiEndpoints.returnBook, requestBody);
    } catch (error) {
      throw Exception('Failed to return book: ${error.toString()}');
    }
  }

  // Fetch all issued books
  Future<List<IssuedBook>> fetchIssuedBooks() async {
    try {
      final response = await webService.fetchData(ApiEndpoints.issuedBooks);
      final List<dynamic> issuedBooksJson = jsonDecode(response);
      return issuedBooksJson.map((json) => IssuedBook.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to fetch issued books: ${error.toString()}');
    }
  }
}
