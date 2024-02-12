
import 'package:flutter/material.dart';
import 'package:sms/screens/attendance_screen.dart';

import 'calendar_screen.dart';
import 'messages_screen.dart';

class HomeScreenStudent extends StatelessWidget {
  // Sample list of items
  final List<Item> items = [
    Item(name: 'Calendar', imagePath: 'assets/images/calendar.png'),
    Item(name: 'Messages', imagePath: 'assets/images/messages.png'),
    Item(name: 'Attendance', imagePath: 'assets/images/attendance.png'),
    Item(name: 'Item 4', imagePath: 'assets/images/students3.png'),
    Item(name: 'Item 5', imagePath: 'assets/images/students3.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Home'),
      ),
      body: GridView.count(
        crossAxisCount: 3, // Number of columns
        children: items.map((item) {
          return GridItem(item: item);
        }).toList(),
      ),
    );
  }
}

class GridItem extends StatelessWidget {
  final Item item;

  const GridItem({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: InkWell(
          onTap: () {
            // Handle tap on grid item
            // Navigate to different screens based on the item
            if (item.name == 'Calendar') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CalendarScreen(),
                ),
              );
            } else if (item.name == 'Messages') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessagesScreen(),
                ),
              );
            } else if (item.name == 'Attendance') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AttendanceScreen(),
                ),
              );
            }
            else {
              // Handle navigation for other items
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Development In Progress...'),
                ),
              );
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                item.imagePath,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 8), // Adjust spacing between image and text
              Text(
                item.name,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Item {
  final String name;
  final String imagePath;

  Item({required this.name, required this.imagePath});
}