import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'debug_logger.dart';

class DebugConsoleOverlay extends StatefulWidget {
  final Function? onClose;

  const DebugConsoleOverlay({Key? key, this.onClose}) : super(key: key);

  @override
  State createState() => _DebugConsoleOverlayState();
}

class _DebugConsoleOverlayState extends State {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.1,
      maxChildSize: 0.8, // Increased to 80% of screen height
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              // Drag handle indicator
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Debug Console',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: () {
                          DebugLogger.clear();
                          setState(() {});
                        },
                        tooltip: 'Clear logs',
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ],
              ),
              // Search field
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search logs...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    suffixIcon: _searchTerm.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                  ),
                ),
              ),
              const Divider(color: Colors.white),
              Expanded(
                child: ValueListenableBuilder<List<String>>(
                  valueListenable: DebugLogger.logsNotifier,
                  builder: (context, logs, _) {
                    final filteredLogs = _searchTerm.isEmpty
                        ? logs
                        : logs
                        .where((log) =>
                        log.toLowerCase().contains(_searchTerm))
                        .toList();

                    if (filteredLogs.isEmpty) {
                      return Center(
                        child: Text(
                          logs.isEmpty
                              ? 'No logs available'
                              : 'No logs matching "${_searchController.text}"',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      itemCount: filteredLogs.length,
                      itemBuilder: (context, index) {
                        final log = filteredLogs[index];

                        if (_searchTerm.isEmpty) {
                          return LogEntry(log: log);
                        }

                        // Highlight matching text
                        return LogEntryWithHighlight(
                            log: log,
                            searchTerm: _searchTerm
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class LogEntry extends StatelessWidget {
  final String log;

  const LogEntry({Key? key, required this.log}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        log,
        style: const TextStyle(
          color: Colors.greenAccent,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

class LogEntryWithHighlight extends StatelessWidget {
  final String log;
  final String searchTerm;

  const LogEntryWithHighlight({
    Key? key,
    required this.log,
    required this.searchTerm
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String logLower = log.toLowerCase();
    final List<TextSpan> spans = [];
    int start = 0;

    while (true) {
      final int index = logLower.indexOf(searchTerm, start);
      if (index == -1) {
        // Add remaining text
        if (start < log.length) {
          spans.add(TextSpan(
            text: log.substring(start),
            style: const TextStyle(
              color: Colors.greenAccent,
            ),
          ));
        }
        break;
      }

      // Add text before match
      if (index > start) {
        spans.add(TextSpan(
          text: log.substring(start, index),
          style: const TextStyle(
            color: Colors.greenAccent,
          ),
        ));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: log.substring(index, index + searchTerm.length),
        style: const TextStyle(
          color: Colors.black,
          backgroundColor: Colors.yellowAccent,
          fontWeight: FontWeight.bold,
        ),
      ));

      start = index + searchTerm.length;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontFamily: 'monospace',
          ),
          children: spans,
        ),
      ),
    );
  }
}