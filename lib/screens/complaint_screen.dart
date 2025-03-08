import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../bloc/complaint/complaint_bloc.dart';
import '../bloc/complaint/complaint_event.dart';
import '../models/complaint.dart';
import '../widgets/text_form_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ComplaintScreen extends StatefulWidget {
  @override
  _ComplaintScreenState createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  String _subject = '';
  String _description = '';
  String _selectedCategory = 'Staff';
  String _otherCategory = ''; // Stores the "Other" input
  bool _isAnonymous = false;

  final List<String> _categories = ['Staff', 'Transport', 'Management', 'Other'];

  void _submitComplaint() {
    if (_formKey.currentState!.validate()) {
      final category = _selectedCategory == 'Other' ? _otherCategory : _selectedCategory;

      final complaint = Complaint(
        id: Uuid().v4(),
        subject: _subject,
        description: _description,
        category: category,
        isAnonymous: _isAnonymous,
      );

      context.read<ComplaintBloc>().add(AddComplaint(complaint));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.complaint_submitted ?? "Complaint Submitted")),
      );
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)?.complaint_title ??"Register Complaint")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextFormField(
                  label: AppLocalizations.of(context)?.complaint_subject ??"Subject",
                  onChanged: (value) => _subject = value,
                  validator: (value) => value!.isEmpty ? AppLocalizations.of(context)?.complaint_subject_hint ?? "Please enter subject" : null,
                ),
                SizedBox(height: 10),
                CustomTextFormField(
                  label: AppLocalizations.of(context)?.complaint_description ??"Description",
                  onChanged: (value) => _description = value,
                  validator: (value) => value!.isEmpty ? AppLocalizations.of(context)?.complaint_description_hint ??"Please enter description" : null,
                  maxLines: 5,
                ),
                SizedBox(height: 10),
                Text(AppLocalizations.of(context)?.complaint_about ??"Complaint About", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8.0,
                  children: _categories.map((category) {
                    return ChoiceChip(
                      label: Text(category),
                      selected: _selectedCategory == category,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                          if (category != 'Other') _otherCategory = '';
                        });
                      },
                    );
                  }).toList(),
                ),
                if (_selectedCategory == 'Other') ...[
                  SizedBox(height: 10),
                  CustomTextFormField(
                    label: AppLocalizations.of(context)?.complaint_other_specify ??"Specify Other",
                    onChanged: (value) => _otherCategory = value,
                    validator: (value) => value!.isEmpty ? "Please specify the complaint" : null,
                  ),
                ],
                SizedBox(height: 10),
                CheckboxListTile(
                  title: Text(AppLocalizations.of(context)?.complaint_anonymous ??"Submit as Anonymous"),
                  value: _isAnonymous,
                  onChanged: (value) {
                    setState(() {
                      _isAnonymous = value!;
                    });
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _submitComplaint();
                      }
                    },
                    child: Text(AppLocalizations.of(context)?.submit ?? "Submit"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
