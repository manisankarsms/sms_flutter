import 'package:flutter/material.dart';
import 'package:sms/screens/attendance_screen.dart';
import 'package:sms/screens/profile_screen.dart';
import '../models/item.dart';
import 'calendar_screen.dart';
import 'messages_screen.dart';

class HomeScreenStudent extends StatelessWidget {
  // Sample list of items
  final List<Item> items = [
    Item(name: 'Calendar', imagePath: 'assets/images/calendar.png'),
    Item(name: 'Messages', imagePath: 'assets/images/messages.png'),
    Item(name: 'Attendance', imagePath: 'assets/images/attendance.png'),
    Item(name: 'Profile', imagePath: 'assets/images/students2.png'),
    Item(name: 'Item 5', imagePath: 'assets/images/students3.png'),
    Item(name: 'Item 6', imagePath: 'assets/images/students3.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Home'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount;
          if (constraints.maxWidth > 1200) {
            crossAxisCount = 5; // Large screens
          } else if (constraints.maxWidth > 800) {
            crossAxisCount = 3; // Medium screens
          } else {
            crossAxisCount = 2; // Small screens
          }
          return GridView.count(
            crossAxisCount: crossAxisCount,
            children: items.map((item) {
              return GridItem(item: item);
            }).toList(),
          );
        },
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
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 4.0,
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
            } else if (item.name == 'Profile') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(),
                ),
              );
            } else {
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
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 12),
              Text(
                item.name,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
