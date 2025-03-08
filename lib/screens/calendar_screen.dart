import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CalendarScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.calendar ?? 'Calendar'),
      ),
      body: Center(
        child: Text('Calendar Screen'),
      ),
    );
  }
}