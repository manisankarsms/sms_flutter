import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/student_fees/student_fees_bloc.dart';
import '../bloc/student_fees/student_fees_event.dart';
import '../models/fees_structures/StudentFeeDto.dart';

class PaymentDialog extends StatefulWidget {
  final StudentFeeDto studentFee;

  const PaymentDialog({Key? key, required this.studentFee}) : super(key: key);

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _receiptController = TextEditingController();
  final _remarksController = TextEditingController();

  String _selectedPaymentMode = 'CASH';
  late double _balanceAmount;

  @override
  void initState() {
    super.initState();
    _balanceAmount = double.parse(widget.studentFee.amount) -
        double.parse(widget.studentFee.paidAmount);
    _amountController.text = _balanceAmount.toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Record Payment - ${widget.studentFee.studentName}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Payment Details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Fee Structure:', widget.studentFee.feeStructureName ?? ''),
                    _buildInfoRow('Total Amount:', '₹${widget.studentFee.amount}'),
                    _buildInfoRow('Paid Amount:', '₹${widget.studentFee.paidAmount}'),
                    _buildInfoRow('Balance Amount:', '₹${_balanceAmount.toStringAsFixed(2)}'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Payment Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Payment Amount',
                  border: OutlineInputBorder(),
                  prefixText: '₹',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter payment amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter valid amount';
                  }
                  if (amount > _balanceAmount) {
                    return 'Amount cannot exceed balance';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Payment Mode
              DropdownButtonFormField<String>(
                value: _selectedPaymentMode,
                decoration: const InputDecoration(
                  labelText: 'Payment Mode',
                  border: OutlineInputBorder(),
                ),
                items: ['CASH', 'ONLINE', 'BANK_TRANSFER', 'UPI', 'CARD'].map((mode) {
                  return DropdownMenuItem(value: mode, child: Text(mode));
                }).toList(),
                onChanged: (value) => setState(() => _selectedPaymentMode = value!),
              ),

              const SizedBox(height: 16),

              // Receipt Number
              TextFormField(
                controller: _receiptController,
                decoration: const InputDecoration(
                  labelText: 'Receipt Number (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // Remarks
              TextFormField(
                controller: _remarksController,
                decoration: const InputDecoration(
                  labelText: 'Remarks (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _recordPayment,
          child: const Text('Record Payment'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _recordPayment() {
    if (_formKey.currentState!.validate()) {
      final paymentRequest = PayFeeRequest(
        amount: _amountController.text.trim(),
        paymentMode: _selectedPaymentMode,
        receiptNumber: _receiptController.text.trim().isEmpty ? null : _receiptController.text.trim(),
        remarks: _remarksController.text.trim().isEmpty ? null : _remarksController.text.trim(),
      );

      // Emit the record payment event
      context.read<StudentFeesBloc>().add(RecordPayment(
        widget.studentFee.id!,
        paymentRequest,
      ));

      Navigator.of(context).pop();
    }
  }
}