import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/library/library_bloc.dart';
import '../../bloc/library/library_event.dart';
import 'library_screen.dart';
import 'add_book_screen.dart';
import 'return_book_screen.dart';

class LibraryHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Library Management")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCard(
                  context,
                  title: "View Books",
                  icon: Icons.book,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LibraryScreen()),
                  ),
                ),
                _buildCard(
                  context,
                  title: "Add Book",
                  icon: Icons.add,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddBookScreen()),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCard(
                  context,
                  title: "Return Book",
                  icon: Icons.assignment_return,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ReturnBookScreen()),
                  ),
                ),
                _buildCard(
                  context,
                  title: "Refresh Data",
                  icon: Icons.refresh,
                  onTap: () => context.read<LibraryBloc>().add(FetchBooks()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required String title, required IconData icon, required VoidCallback onTap}) {
    return Expanded( // Prevents overflow by adjusting width dynamically
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            height: 150,
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: Colors.blue),
                SizedBox(height: 10),
                Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
