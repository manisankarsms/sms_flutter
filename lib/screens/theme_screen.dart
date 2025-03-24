import '../bloc/theme/theme_bloc.dart';
import '../utils/theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentTheme = context.watch<ThemeBloc>().state.themeData;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Select Theme", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 2,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2; // Adjust grid size for web
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: AppThemes.themes.length,
              itemBuilder: (context, index) {
                final themeData = AppThemes.themes[index];
                final isSelected = themeData['theme'] == currentTheme;
                return GestureDetector(
                  onTap: () {
                    context.read<ThemeBloc>().add(ChangeThemeEvent(themeData['theme']));
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: themeData['theme'].primaryColor,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: themeData['theme'].primaryColorLight,
                          radius: 24,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          themeData['name'],
                          style: TextStyle(
                            color: themeData['theme'].textTheme.bodyLarge?.color ?? Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}