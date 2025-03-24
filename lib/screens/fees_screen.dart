import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/fees/fees_bloc.dart';
import '../models/fees.dart';

class AdminFeesScreen extends StatefulWidget {
  @override
  _AdminFeesScreenState createState() => _AdminFeesScreenState();
}

class _AdminFeesScreenState extends State<AdminFeesScreen> {
  String selectedYear = "2025"; // Default academic year

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    context.read<FeesBloc>().add(LoadFees());

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: Text("Manage Fees Structure")),
      body: Column(
        children: [
          // Dropdown for Academic Year Selection
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

                  return ListView(
                    children: classFees.entries.map((entry) {
                      return Card(
                        margin: EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 4,
                        child: ExpansionTile(
                          title: Text("${entry.key} (₹${entry.value.totalFees})"),
                          children: [
                            ...entry.value.breakdown.map((fee) {
                              return ListTile(
                                title: Text(fee.feeType),
                                trailing: Text("₹${fee.amount}"),
                              );
                            }),
                            ButtonBar(
                              children: [
                                TextButton(
                                  onPressed: () => _editClassFees(context, selectedYear, entry.key, entry.value),
                                  child: Text("Edit"),
                                ),
                                TextButton(
                                  onPressed: () => context.read<FeesBloc>().add(DeleteClassFees(selectedYear, entry.key)),
                                  child: Text("Delete"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }
                return Container();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _addClassFees(context, selectedYear),
      ),
    );
  }

  void _addClassFees(BuildContext context, String academicYear) {
    TextEditingController classController = TextEditingController();
    List<FeeBreakdown> breakdownList = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Add Fees for New Class"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: classController, decoration: InputDecoration(labelText: "Class Name")),
                  Divider(),
                  ...breakdownList.map((fee) {
                    return Row(
                      children: [
                        Expanded(child: Text(fee.feeType)),
                        SizedBox(width: 10),
                        Expanded(child: Text("₹${fee.amount}")),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              breakdownList.remove(fee);
                            });
                          },
                        ),
                      ],
                    );
                  }),
                  Divider(),
                  ElevatedButton(
                    onPressed: () {
                      if (classController.text.isNotEmpty) {
                        ClassFees newFees = ClassFees(
                          totalFees: breakdownList.fold(0, (sum, fee) => sum + fee.amount),
                          breakdown: breakdownList,
                        );
                        context.read<FeesBloc>().add(AddClassFees(academicYear, classController.text, newFees));
                        Navigator.pop(context);
                      }
                    },
                    child: Text("Save"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _editClassFees(BuildContext context, String academicYear, String className, ClassFees classFees) {
    List<FeeBreakdown> breakdownList = List.from(classFees.breakdown); // Create a new list
    TextEditingController newFeeTypeController = TextEditingController();
    TextEditingController newFeeAmountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Edit Fees for $className"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Existing breakdown list
                  ...breakdownList.asMap().entries.map((entry) {
                    int index = entry.key;
                    FeeBreakdown fee = entry.value;
                    TextEditingController amountController = TextEditingController(text: fee.amount.toString());

                    return Row(
                      children: [
                        Expanded(child: Text(fee.feeType)),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: "Amount"),
                            onChanged: (value) {
                              setState(() {
                                double? newAmount = double.tryParse(value);
                                if (newAmount != null) {
                                  breakdownList[index] = fee.copyWith(amount: newAmount);
                                }
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              breakdownList.removeAt(index);
                            });
                          },
                        ),
                      ],
                    );
                  }).toList(),

                  Divider(),

                  // New breakdown entry fields
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: newFeeTypeController,
                          decoration: InputDecoration(labelText: "Fee Type"),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: newFeeAmountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: "Amount"),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: Colors.green),
                        onPressed: () {
                          if (newFeeTypeController.text.isNotEmpty &&
                              newFeeAmountController.text.isNotEmpty) {
                            setState(() {
                              breakdownList.add(FeeBreakdown(
                                feeType: newFeeTypeController.text,
                                amount: double.tryParse(newFeeAmountController.text) ?? 0
                              ));
                              newFeeTypeController.clear();
                              newFeeAmountController.clear();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    double updatedTotal = breakdownList.fold(0, (sum, fee) => sum + fee.amount);
                    ClassFees updatedFees = ClassFees(totalFees: updatedTotal, breakdown: List.from(breakdownList));

                    context.read<FeesBloc>().add(UpdateClassFees(academicYear, className, updatedFees));
                    Navigator.pop(context);
                  },
                  child: Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
