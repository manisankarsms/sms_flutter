import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/library_repository.dart';
import 'library_event.dart';
import 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final LibraryRepository libraryRepository;

  LibraryBloc({required this.libraryRepository}) : super(LibraryInitial()) {
    on<FetchBooks>(_onFetchBooks);
    on<AddBook>(_onAddBook);
    on<IssueBook>(_onIssueBook);
    on<ReturnBook>(_onReturnBook);
    on<FetchIssuedBooks>(_onFetchIssuedBooks);
    add(FetchBooks()); // Automatically load staff when the bloc is created
  }

  // Fetch Books
  Future<void> _onFetchBooks(FetchBooks event, Emitter<LibraryState> emit) async {
    emit(LibraryLoading());
    try {
      final books = await libraryRepository.fetchBooks();
      emit(BooksLoaded(books));
    } catch (e) {
      emit(LibraryError(e.toString()));
    }
  }

  // Add a Book
  Future<void> _onAddBook(AddBook event, Emitter<LibraryState> emit) async {
    emit(LibraryLoading());
    try {
      await libraryRepository.addBook(event.book);
      emit(BookAdded());
      add(FetchBooks()); // Refresh books list
    } catch (e) {
      emit(LibraryError(e.toString()));
    }
  }

  // Issue a Book
  Future<void> _onIssueBook(IssueBook event, Emitter<LibraryState> emit) async {
    emit(LibraryLoading());
    try {
      await libraryRepository.issueBook(event.issuedBook);
      emit(BookIssued());
      add(FetchBooks()); // Refresh books list
      add(FetchIssuedBooks()); // Refresh issued books
    } catch (e) {
      emit(LibraryError(e.toString()));
    }
  }

  // Return a Book
  Future<void> _onReturnBook(ReturnBook event, Emitter<LibraryState> emit) async {
    emit(LibraryLoading());
    try {
      await libraryRepository.returnBook(event.issuedBookId);
      emit(BookReturned());
      add(FetchBooks()); // Refresh books list
      add(FetchIssuedBooks()); // Refresh issued books
    } catch (e) {
      emit(LibraryError(e.toString()));
    }
  }

  // Fetch Issued Books
  Future<void> _onFetchIssuedBooks(FetchIssuedBooks event, Emitter<LibraryState> emit) async {
    emit(LibraryLoading());
    try {
      final issuedBooks = await libraryRepository.fetchIssuedBooks();
      emit(IssuedBooksLoaded(issuedBooks));
    } catch (e) {
      emit(LibraryError(e.toString()));
    }
  }
}
