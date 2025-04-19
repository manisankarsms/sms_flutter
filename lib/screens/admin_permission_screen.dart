import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/permissions.dart';
import '../bloc/permissions/permissions_bloc.dart';
import '../bloc/permissions/permissions_event.dart';
import '../bloc/permissions/permissions_state.dart';

class AdminPermissionScreen extends StatefulWidget {
  const AdminPermissionScreen({Key? key}) : super(key: key);

  @override
  State<AdminPermissionScreen> createState() => _AdminPermissionScreenState();
}

class _AdminPermissionScreenState extends State<AdminPermissionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Staff? _selectedStaff;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    context.read<PermissionBloc>().add(LoadPermissions());

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showPermissionsUI(Staff staff, List<PermissionDefinition> definitions) {
    setState(() {
      _selectedStaff = staff;
    });

    // Check if device is mobile based on size
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    if (isMobile) {
      // Show bottom sheet for mobile
      _showPermissionsBottomSheet(staff, definitions);
    } else {
      // Show drawer for tablet/desktop (50% or less of screen width)
      _scaffoldKey.currentState?.openEndDrawer();
    }
  }

  void _showPermissionsBottomSheet(Staff staff, List<PermissionDefinition> definitions) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return BlocBuilder<PermissionBloc, PermissionState>(
          builder: (context, state) {
            if (state is PermissionLoaded) {
              return _buildPermissionsContent(context, state, isBottomSheet: true);
            }
            return const Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }

  Widget _buildPermissionsContent(BuildContext context, PermissionLoaded state, {bool isBottomSheet = false}) {
    final theme = Theme.of(context);
    // Group permissions by category
    final Map<String, List<PermissionDefinition>> categorizedPermissions = {};

    for (final def in state.definitions) {
      final category = def.key.split('.').first;
      categorizedPermissions.putIfAbsent(category, () => []);
      categorizedPermissions[category]!.add(def);
    }

    return Container(
      // For bottom sheet, use DraggableScrollableSheet height constraints
      height: isBottomSheet ? MediaQuery.of(context).size.height * 0.85 : null,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.primaryColor.withOpacity(0.1),
            child: Column(
              children: [
                if (isBottomSheet)
                  Center(
                    child: Container(
                      height: 4,
                      width: 40,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: theme.primaryColor.withOpacity(0.2),
                      child: Text(
                        _selectedStaff!.name.characters.first.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedStaff!.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Staff ID: ${_selectedStaff!.id}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  'Permissions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_selectedStaff!.permissions.length}/${state.definitions.length}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: categorizedPermissions.entries.map((entry) {
                final category = entry.key;
                final perms = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        category.toUpperCase(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    ...perms.map((def) {
                      final enabled = _selectedStaff!.permissions.contains(def.key);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 0,
                        color: enabled
                            ? theme.primaryColor.withOpacity(0.08)
                            : Colors.grey.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: enabled
                                ? theme.primaryColor.withOpacity(0.3)
                                : Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: SwitchListTile(
                          title: Text(
                            def.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: enabled
                                  ? theme.textTheme.bodyLarge?.color
                                  : Colors.grey.shade700,
                            ),
                          ),
                          subtitle: Text(
                            def.key,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade500,
                            ),
                          ),
                          value: enabled,
                          activeColor: theme.primaryColor,
                          onChanged: (_) {
                            context.read<PermissionBloc>().add(
                              TogglePermission(
                                staffId: _selectedStaff!.id,
                                permissionKey: def.key,
                              ),
                            );
                            // Update local state to show changes immediately
                            setState(() {
                              final staff = state.staffList.firstWhere(
                                      (s) => s.id == _selectedStaff!.id);
                              _selectedStaff = staff;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ],
                );
              }).toList(),
            ),
          ),
          SafeArea(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  context.read<PermissionBloc>().add(SavePermissions());
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Permissions saved successfully'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('SAVE CHANGES',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Staff Permissions'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          BlocBuilder<PermissionBloc, PermissionState>(
            builder: (context, state) {
              if (state is PermissionLoaded) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: IconButton(
                    tooltip: 'Save all changes',
                    icon: const Icon(Icons.save_outlined),
                    onPressed: () {
                      context.read<PermissionBloc>().add(SavePermissions());
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Saving permissions...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<PermissionBloc, PermissionState>(
        listener: (context, state) {
          if (state is PermissionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                margin: const EdgeInsets.all(8),
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'RETRY',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<PermissionBloc>().add(LoadPermissions());
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PermissionLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: theme.primaryColor),
                  const SizedBox(height: 16),
                  const Text('Loading staff permissions...'),
                ],
              ),
            );
          } else if (state is PermissionLoaded) {
            final filteredStaff = _searchQuery.isEmpty
                ? state.staffList
                : state.staffList.where((staff) =>
                staff.name.toLowerCase().contains(_searchQuery)).toList();

            return Column(
              children: [
                Container(
                  color: theme.primaryColor.withOpacity(0.05),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Staff Access Control',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select a staff member to manage their permissions',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SearchBar(
                        controller: _searchController,
                        hintText: 'Search staff members...',
                        leading: const Icon(Icons.search),
                        trailing: [
                          if (_searchQuery.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _searchController.clear(),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredStaff.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No staff members found',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredStaff.length,
                    itemBuilder: (context, index) {
                      final staff = filteredStaff[index];
                      final totalPerms = staff.permissions.length;
                      final maxPerms = state.definitions.length;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => _showPermissionsUI(staff, state.definitions),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                                  child: Text(
                                    staff.name.characters.first.toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        staff.name,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Container(
                                              height: 6,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(3),
                                                color: Colors.grey.shade200,
                                              ),
                                              child: Row(
                                                children: [
                                                  Flexible(
                                                    flex: totalPerms,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(3),
                                                        color: totalPerms > 0
                                                            ? theme.primaryColor
                                                            : Colors.transparent,
                                                      ),
                                                    ),
                                                  ),
                                                  Flexible(
                                                    flex: maxPerms - totalPerms,
                                                    child: Container(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            '$totalPerms/$maxPerms',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is PermissionError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 64, color: Colors.red.shade300),
                    const SizedBox(height: 24),
                    Text(
                      'Unable to load permissions',
                      style: theme.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<PermissionBloc>().add(LoadPermissions());
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      endDrawer: isTablet && _selectedStaff != null ?
      Drawer(
        width: MediaQuery.of(context).size.width * 0.5, // 50% of screen width for tablet/desktop
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
        ),
        child: BlocBuilder<PermissionBloc, PermissionState>(
          builder: (context, state) {
            if (state is PermissionLoaded) {
              return _buildPermissionsContent(context, state);
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ) : null,
    );
  }
}