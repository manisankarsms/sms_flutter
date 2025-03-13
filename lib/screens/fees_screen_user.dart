import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/fees/fees_bloc.dart';

class UserFeesScreen extends StatefulWidget {
  final String studentClass; // The class of the logged-in student

  UserFeesScreen({required this.studentClass});

  @override
  _UserFeesScreenState createState() => _UserFeesScreenState();
}

class _UserFeesScreenState extends State<UserFeesScreen> {
  String selectedYear = "2025"; // Default academic year

  @override
  Widget build(BuildContext context) {
    context.read<FeesBloc>().add(LoadFees());

    return Scaffold(
      appBar: AppBar(title: Text("My Fees Structure")),
      body: Column(
        children: [
          // Dropdown for selecting academic year
          Padding(
            padding: EdgeInsets.all(10),
            child: DropdownButton<String>(
              value: selectedYear,
              items: ["2024", "2025", "2026"]
                  .map((year) => DropdownMenuItem(value: year, child: Text(year)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedYear = value;
                  });
                }
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<FeesBloc, FeesState>(
              builder: (context, state) {
                if (state is FeesLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is FeesLoaded) {
                  final classFees = state.academicYearFees[selectedYear]?.classFees ?? {};
                  final studentFees = classFees[widget.studentClass];

                  if (studentFees == null) {
                    return Center(child: Text("No fee details available for ${widget.studentClass}"));
                  }

                  return Card(
                    margin: EdgeInsets.all(15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${widget.studentClass} - ${selectedYear}",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Divider(),
                          Text("Total Fees: ₹${studentFees.totalFees}",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                          SizedBox(height: 10),
                          Column(
                            children: studentFees.breakdown.map((fee) {
                              return ListTile(
                                title: Text(fee.feeType),
                                trailing: Text("₹${fee.amount}"),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }
}
