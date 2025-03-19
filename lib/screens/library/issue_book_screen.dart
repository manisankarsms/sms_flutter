import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/library/library_bloc.dart';
import '../../bloc/library/library_event.dart';
import '../../models/book.dart';
import '../../models/issued_book.dart';

class IssueBookScreen extends StatefulWidget {
  final Book? book; // Make book optional

  IssueBookScreen({this.book}); // Allow null values

  @override
  _IssueBookScreenState createState() => _IssueBookScreenState();
}

class _IssueBookScreenState extends State<IssueBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Issue Book")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text("Book: ${widget.book?.title}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _userIdController,
                decoration: InputDecoration(labelText: "User ID"),
                validator: (value) => value!.isEmpty ? "Enter User ID" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final issuedBook = IssuedBook(
                      id: DateTime.now().toString(),
                      bookId: widget.book!.id,
                      userId: _userIdController.text,
                      issuedDate: DateTime.now().toIso8601String(),
                      dueDate: DateTime.now().add(Duration(days: 14)).toIso8601String(),
                      isReturned: false,
                    );
                    context.read<LibraryBloc>().add(IssueBook(issuedBook));
                    Navigator.pop(context);
                  }
                },
                child: Text("Issue Book"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
