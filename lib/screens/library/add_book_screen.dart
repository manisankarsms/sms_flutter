import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/library/library_bloc.dart';
import '../../bloc/library/library_event.dart';
import '../../models/book.dart';

class AddBookScreen extends StatefulWidget {
  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _isbnController = TextEditingController();
  final _categoryController = TextEditingController();
  final _copiesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Book")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "Title"),
                validator: (value) => value!.isEmpty ? "Enter book title" : null,
              ),
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(labelText: "Author"),
                validator: (value) => value!.isEmpty ? "Enter author name" : null,
              ),
              TextFormField(
                controller: _isbnController,
                decoration: InputDecoration(labelText: "ISBN"),
              ),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: "Category"),
              ),
              TextFormField(
                controller: _copiesController,
                decoration: InputDecoration(labelText: "Total Copies"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Enter copies count" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final book = Book(
                      id: DateTime.now().toString(),
                      title: _titleController.text,
                      author: _authorController.text,
                      isbn: _isbnController.text,
                      category: _categoryController.text,
                      totalCopies: int.parse(_copiesController.text),
                      availableCopies: int.parse(_copiesController.text),
                    );
                    context.read<LibraryBloc>().add(AddBook(book));
                    Navigator.pop(context);
                  }
                },
                child: Text("Add Book"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
