import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/rules/rules_bloc.dart';
import '../bloc/rules/rules_event.dart';
import '../bloc/rules/rules_state.dart';
import '../repositories/rules_repository.dart';

class RulesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RulesBloc(RulesRepository())..add(LoadRulesEvent()),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Text("School Rules & Regulations", style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 2,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<RulesBloc, RulesState>(
            builder: (context, state) {
              if (state is RulesLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is RulesLoaded) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "School Rules & Regulations",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.rules.length,
                        itemBuilder: (context, index) {
                          return RuleItem(text: state.rules[index]);
                        },
                      ),
                    ),
                  ],
                );
              } else {
                return const Center(child: Text("Failed to load rules."));
              }
            },
          ),
        ),
      ),
    );
  }
}

class RuleItem extends StatelessWidget {
  final String text;
  const RuleItem({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}