import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/rules/rules_bloc.dart';
import '../bloc/rules/rules_event.dart';
import '../bloc/rules/rules_state.dart';
import '../models/user.dart';

class RulesScreen extends StatelessWidget {
  final User user;

  RulesScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('School Rules & Regulations'),
        elevation: 0,
        actions: [
          if (user.role.toLowerCase() == 'admin')
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showRuleDialog(context),
              tooltip: 'Add Rule',
            ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: BlocListener<RulesBloc, RulesState>(
              listener: (context, state) {
                // Handle error messages
                if (state.errorMessage != null) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage!),
                      backgroundColor: Colors.red,
                      action: state.status == RulesStatus.failure
                          ? SnackBarAction(
                        label: 'RETRY',
                        textColor: Colors.white,
                        onPressed: () {
                          context.read<RulesBloc>().add(LoadRulesEvent());
                        },
                      )
                          : null,
                    ),
                  );
                }
                // Handle success messages for add, update, and delete
                if (!state.isOperating &&
                    state.status == RulesStatus.success) {
                  String message = '';
                  if (state.rules.length > _previousRuleCount) {
                    message = 'Rule added successfully';
                  } else if (state.rules.length < _previousRuleCount) {
                    message = 'Rule deleted successfully';
                  } else if (_previousRuleCount == state.rules.length) {
                    message = 'Rule updated successfully';
                  }
                  if (message.isNotEmpty) {
                    print('Showing SnackBar: $message'); // Debug log
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                    _previousRuleCount = state.rules.length;
                  }
                }
              },
              listenWhen: (previous, current) =>
              previous.errorMessage != current.errorMessage ||
                  (previous.isOperating != current.isOperating &&
                      current.status == RulesStatus.success),
              child: BlocBuilder<RulesBloc, RulesState>(
                builder: (context, state) {
                  try {
                    print('Rendering RulesScreen: status=${state.status}, rules=${state.rules.length}'); // Debug log
                    return _buildContent(context, state);
                  } catch (e) {
                    debugPrint('Error rendering rules screen: $e');
                    return _buildErrorFallback(context, e.toString());
                  }
                },
              ),
            ),
          ),
          BlocBuilder<RulesBloc, RulesState>(
            builder: (context, state) {
              if (state.isOperating) {
                return Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Processing...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      floatingActionButton: user.role.toLowerCase() == 'admin'
          ? BlocBuilder<RulesBloc, RulesState>(
        builder: (context, state) {
          return FloatingActionButton(
            onPressed: state.isOperating
                ? null
                : () => _showRuleDialog(context),
            child: const Icon(Icons.add),
            tooltip: 'Add Rule',
          );
        },
      )
          : null,
    );
  }

  // Track previous rule count to detect add/delete/update
  int _previousRuleCount = 0;

  Widget _buildContent(BuildContext context, RulesState state) {
    if (state.status == RulesStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == RulesStatus.failure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.errorMessage ?? 'Failed to load rules'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<RulesBloc>().add(LoadRulesEvent()),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Handle unexpected status (e.g., initial)
    if (state.status != RulesStatus.success) {
      print('Unexpected state in _buildContent: ${state.status}'); // Debug log
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Waiting for rules data...'),
          ],
        ),
      );
    }

    // Handle empty rules list
    if (state.rules.isEmpty) {
      print('Rendering empty rules list'); // Debug log
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.rule, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No rules available'),
            if (user.role.toLowerCase() == 'admin') ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showRuleDialog(context),
                child: const Text('Add Rule'),
              ),
            ],
          ],
        ),
      );
    }

    // Non-empty rules list
    return _buildRulesList(context, state);
  }

  Widget _buildRulesList(BuildContext context, RulesState state) {
    try {
      print('Building rules list with ${state.rules.length} rules'); // Debug log

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 16),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.indigo.shade100),
            ),
            child: Text(
              'School Rules & Regulations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade800,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: state.rules.length,
              itemBuilder: (context, index) {
                if (index >= state.rules.length) {
                  return const SizedBox.shrink();
                }
                final rule = state.rules[index];
                try {
                  return _buildRuleCard(context, rule, index + 1);
                } catch (e) {
                  debugPrint('Error building rule card at index $index: $e');
                  return const Card(
                    child: ListTile(
                      title: Text('Error loading rule'),
                      leading: Icon(Icons.error, color: Colors.red),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 20), // Bottom padding for FAB
        ],
      );
    } catch (e) {
      debugPrint('Error building rules list: $e');
      return _buildErrorFallback(context, 'Error displaying rules: $e');
    }
  }

  Widget _buildRuleCard(BuildContext context, String rule, int ruleNumber) {
    try {
      return BlocBuilder<RulesBloc, RulesState>(
        builder: (context, state) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            elevation: 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Dismissible(
              key: Key('rule_${ruleNumber}_${rule.hashCode}_${DateTime.now().millisecondsSinceEpoch}'),
              direction: (user.role.toLowerCase() == 'admin' && !state.isOperating)
                  ? DismissDirection.endToStart
                  : DismissDirection.none,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20.0),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                if (user.role.toLowerCase() != 'admin' || state.isOperating) return false;
                return await _showDeleteConfirmation(context, rule, ruleNumber);
              },
              onDismissed: (direction) async {
                context.read<RulesBloc>().add(DeleteRuleEvent(ruleNumber - 1));
                await Future.delayed(const Duration(milliseconds: 200));
              },
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  child: Text(
                    '$ruleNumber',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                title: Text(
                  rule,
                  style: const TextStyle(fontSize: 16, height: 1.4),
                ),
                trailing: user.role.toLowerCase() == 'admin'
                    ? _buildAdminActions(context, state, rule, ruleNumber - 1)
                    : null,
                onTap: (user.role.toLowerCase() == 'admin' && !state.isOperating)
                    ? () => _showRuleDialog(context, rule: rule, index: ruleNumber - 1)
                    : null,
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('Error building rule card: $e');
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: ListTile(
          title: const Text('Error displaying rule'),
          leading: const Icon(Icons.error, color: Colors.red),
        ),
      );
    }
  }

  Widget _buildAdminActions(BuildContext context, RulesState state, String rule, int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.edit,
            color: state.isOperating ? Colors.grey : Colors.blue,
          ),
          onPressed: state.isOperating
              ? null
              : () => _showRuleDialog(context, rule: rule, index: index),
        ),
        IconButton(
          icon: Icon(
            Icons.delete,
            color: state.isOperating ? Colors.grey : Colors.red,
          ),
          onPressed: state.isOperating
              ? null
              : () => _confirmDelete(context, rule, index + 1),
        ),
      ],
    );
  }

  Widget _buildErrorFallback(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Something went wrong'),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<RulesBloc>().add(LoadRulesEvent()),
            child: const Text('Reload'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, String rule, int ruleNumber) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: Text("Are you sure you want to delete Rule #$ruleNumber?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("CANCEL"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("DELETE", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    ) ?? false;
  }

  void _showRuleDialog(BuildContext context, {String? rule, int? index}) {
    final bool isEditing = rule != null && index != null;
    final _formKey = GlobalKey<FormState>();
    final _ruleController = TextEditingController(text: isEditing ? rule : '');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: context.read<RulesBloc>(),
          child: BlocListener<RulesBloc, RulesState>(
            listener: (context, state) {
              if (!state.isOperating && state.status == RulesStatus.success) {
                Navigator.of(dialogContext).pop();
              }
              if (!state.isOperating && state.status == RulesStatus.failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage ?? 'Operation failed. Please try again.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: BlocBuilder<RulesBloc, RulesState>(
              builder: (context, state) {
                return AlertDialog(
                  title: Text(isEditing ? 'Edit Rule' : 'Add Rule'),
                  content: Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _ruleController,
                      enabled: !state.isOperating,
                      decoration: const InputDecoration(
                        labelText: 'Rule Description',
                        border: OutlineInputBorder(),
                        hintText: 'Enter the school rule...',
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a rule description';
                        }
                        return null;
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: state.isOperating ? null : () => Navigator.of(dialogContext).pop(),
                      child: const Text('CANCEL'),
                    ),
                    if (isEditing)
                      TextButton(
                        onPressed: state.isOperating
                            ? null
                            : () => _confirmDelete(dialogContext, rule!, index! + 1),
                        child: const Text('DELETE', style: TextStyle(color: Colors.red)),
                      ),
                    TextButton(
                      onPressed: state.isOperating
                          ? null
                          : () {
                        if (_formKey.currentState!.validate()) {
                          final ruleText = _ruleController.text.trim();
                          if (isEditing) {
                            context.read<RulesBloc>().add(UpdateRuleEvent(index!, ruleText));
                          } else {
                            context.read<RulesBloc>().add(AddRuleEvent(ruleText));
                          }
                        }
                      },
                      child: state.isOperating
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : Text(isEditing ? 'UPDATE' : 'ADD'),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext dialogContext, String rule, int ruleNumber) {
    showDialog(
      context: dialogContext,
      builder: (BuildContext context) {
        return BlocProvider.value(
          value: dialogContext.read<RulesBloc>(),
          child: BlocListener<RulesBloc, RulesState>(
            listener: (context, state) {
              if (!state.isOperating && state.status == RulesStatus.success) {
                Navigator.of(context).pop();
              }
            },
            child: BlocBuilder<RulesBloc, RulesState>(
              builder: (context, state) {
                return AlertDialog(
                  title: const Text("Confirm Delete"),
                  content: Text("Are you sure you want to delete Rule #$ruleNumber?"),
                  actions: <Widget>[
                    TextButton(
                      onPressed: state.isOperating ? null : () => Navigator.of(context).pop(),
                      child: const Text("CANCEL"),
                    ),
                    TextButton(
                      onPressed: state.isOperating
                          ? null
                          : () => context.read<RulesBloc>().add(DeleteRuleEvent(ruleNumber - 1)),
                      child: state.isOperating
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text("DELETE", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}