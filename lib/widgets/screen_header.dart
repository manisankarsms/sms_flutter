import 'package:flutter/material.dart';

class ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showLeadingSpace;

  const ScreenHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.showLeadingSpace = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
