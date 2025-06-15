import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:intl/intl.dart';
import '../../models/user.dart';
import '../../models/class.dart';
import '../bloc/student_admin/student_bloc.dart';
import '../bloc/student_admin/student_event.dart';
import '../bloc/student_admin/student_state.dart';

class UserAdminScreen extends StatefulWidget {
  const UserAdminScreen({super.key});

  @override
  State<UserAdminScreen> createState() => _UserAdminScreenState();
}

class _UserAdminScreenState extends State<UserAdminScreen> {
  late PlutoGridStateManager _stateManager;
  Key _gridKey = UniqueKey(); // Add this line
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  String _selectedRole = 'User';
  String? _selectedClassId;
  final List<String> _selectedPermissions = [];
  final List<String> _availablePermissions = [
    'read', 'write', 'delete', 'admin', 'manage_users', 'view_reports'
  ];

  // Multi-select functionality
  final Set<String> _selectedUserIds = <String>{};
  bool _isMultiSelectMode = false;

  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(LoadUsers());
    context.read<UserBloc>().add(LoadClasses());
  }

  void _toggleMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedUserIds.clear();
      }
      // Force grid rebuild when toggling mode
      _gridKey = UniqueKey();
    });
  }

  // Updated _selectAllUsers method
  void _selectAllUsers(List<User> users) {
    setState(() {
      if (_selectedUserIds.length == users.length) {
        _selectedUserIds.clear();
      } else {
        _selectedUserIds.clear();
        _selectedUserIds.addAll(users.map((user) => user.id));
      }
      // Force grid rebuild
      _gridKey = UniqueKey();
    });
  }

  void _toggleUserSelection(String userId) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else {
        _selectedUserIds.add(userId);
      }
    });

    // Force the grid to refresh to show updated checkbox states
    if (_stateManager != null) {
      _stateManager.notifyListeners();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: _isMultiSelectMode
            ? Text('${_selectedUserIds.length} Selected')
            : const Text('User Administration'),
        backgroundColor: _isMultiSelectMode ? Colors.orange : Colors.blue,
        foregroundColor: Colors.white,
        leading: _isMultiSelectMode
            ? IconButton(
          icon: const Icon(Icons.close),
          onPressed: _toggleMultiSelectMode,
        )
            : null,
        actions: _isMultiSelectMode ? _buildMultiSelectActions() : _buildNormalActions(),
      ),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Clear selections after successful operation
            setState(() {
              _selectedUserIds.clear();
            });
          } else if (state is UserOperationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UserOperationFailure) {
            return _buildErrorState(state.error);
          }

          // Handle the new state with both users and classes
          if (state is UsersAndClassesLoaded) {
            if (state.users.isEmpty) {
              return _buildEmptyState();
            }

            return _buildDataGrid(state.users);
          }

          // Handle other state types that might have users
          if (state is UserOperationSuccess || state is UserOperationInProgress) {
            List<User> users = [];
            if (state is UserOperationSuccess) {
              users = state.users;
            } else if (state is UserOperationInProgress) {
              users = state.users;
            }

            if (users.isEmpty) {
              return _buildEmptyState();
            }

            return _buildDataGrid(users);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: _isMultiSelectMode ? null : FloatingActionButton(
        onPressed: () => _showUserDialog(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  List<Widget> _buildNormalActions() {
    return [
      IconButton(
        icon: const Icon(Icons.checklist),
        onPressed: _toggleMultiSelectMode,
        tooltip: 'Multi-Select Mode',
      ),
      IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: () {
          context.read<UserBloc>().add(LoadUsers());
          context.read<UserBloc>().add(LoadClasses());
        },
        tooltip: 'Refresh',
      ),
      IconButton(
        icon: const Icon(Icons.add),
        onPressed: () => _showUserDialog(),
        tooltip: 'Add User',
      ),
    ];
  }

  List<Widget> _buildMultiSelectActions() {
    return [
      if (_selectedUserIds.isNotEmpty) ...[
        IconButton(
          icon: const Icon(Icons.school),
          onPressed: () => _showBulkAssignClassDialog(),
          tooltip: 'Bulk Assign to Class',
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _showBulkDeleteConfirmation(),
          tooltip: 'Delete Selected',
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: _handleBulkAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'change_role',
              child: Row(
                children: [
                  Icon(Icons.admin_panel_settings, size: 16),
                  SizedBox(width: 8),
                  Text('Change Role'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'add_permissions',
              child: Row(
                children: [
                  Icon(Icons.security, size: 16),
                  SizedBox(width: 8),
                  Text('Add Permissions'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'remove_permissions',
              child: Row(
                children: [
                  Icon(Icons.remove_circle, size: 16),
                  SizedBox(width: 8),
                  Text('Remove Permissions'),
                ],
              ),
            ),
          ],
        ),
      ],
    ];
  }

  Widget _buildDataGrid(List<User> users) {
    return Column(
      children: [
        if (_isMultiSelectMode) _buildMultiSelectHeader(users),
        Expanded(
          child: PlutoGrid(
            key: _gridKey,
            columns: _buildGridColumns(),
            rows: _buildGridRows(users),
            configuration: PlutoGridConfiguration(
              style: const PlutoGridStyleConfig(
                gridBorderColor: Colors.grey,
                gridBackgroundColor: Colors.white,
                rowColor: Colors.white,
                gridBorderRadius: BorderRadius.all(Radius.circular(8.0)),
                checkedColor: Colors.blue,
                activatedColor: Colors.blue,
                activatedBorderColor: Colors.blueAccent,
              ),
              columnSize: const PlutoGridColumnSizeConfig(
                autoSizeMode: PlutoAutoSizeMode.scale,
                resizeMode: PlutoResizeMode.pushAndPull,
              ),
              scrollbar: const PlutoGridScrollbarConfig(
                isAlwaysShown: true,
              ),
              enterKeyAction: PlutoGridEnterKeyAction.editingAndMoveDown,
            ),
            onLoaded: (PlutoGridOnLoadedEvent event) {
              _stateManager = event.stateManager;
              event.stateManager.setShowColumnFilter(true);
              event.stateManager.setPageSize(15);
              // Disable PlutoGrid's built-in selection in multi-select mode
              if (_isMultiSelectMode) {
                event.stateManager.setSelectingMode(PlutoGridSelectingMode.none);
              } else {
                event.stateManager.setSelectingMode(PlutoGridSelectingMode.row);
              }
            },
            onRowDoubleTap: (PlutoGridOnRowDoubleTapEvent event) {
              if (_isMultiSelectMode) {
                // In multi-select mode, double-tap should toggle selection
                final userId = event.row.cells['id']?.value?.toString() ?? '';
                _toggleUserSelection(userId);
              } else {
                _handleRowAction(event.row);
              }
            },
            onRowSecondaryTap: (PlutoGridOnRowSecondaryTapEvent event) {
              if (!_isMultiSelectMode) {
                _handleRowAction(event.row);
              }
            },
            createFooter: (stateManager) => PlutoPagination(stateManager),
            mode: _isMultiSelectMode ? PlutoGridMode.normal : PlutoGridMode.selectWithOneTap,
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelectHeader(List<User> users) {
    final selectedCount = _selectedUserIds.length;
    final totalCount = users.length;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.orange.shade50,
      child: Row(
        children: [
          Checkbox(
            value: selectedCount == totalCount && totalCount > 0,
            tristate: true,
            onChanged: (value) => _selectAllUsers(users),
          ),
          const SizedBox(width: 8),
          Text(
            selectedCount == totalCount
                ? 'All $totalCount users selected'
                : '$selectedCount of $totalCount users selected',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          if (selectedCount > 0) ...[
            TextButton(
              onPressed: () => setState(() => _selectedUserIds.clear()),
              child: const Text('Clear Selection'),
            ),
          ],
        ],
      ),
    );
  }

  List<PlutoColumn> _buildGridColumns() {
    List<PlutoColumn> columns = [];

    // Add checkbox column in multi-select mode
    if (_isMultiSelectMode) {
      columns.add(
        PlutoColumn(
          title: '☑',
          field: 'checkbox',
          type: PlutoColumnType.text(),
          width: 60,
          enableSorting: false,
          enableColumnDrag: false,
          enableContextMenu: false,
          enableFilterMenuItem: false,
          frozen: PlutoColumnFrozen.start,
          renderer: (rendererContext) {
            final userId = rendererContext.row.cells['id']?.value?.toString() ?? '';
            return Container(
              alignment: Alignment.center,
              child: Checkbox(
                value: _selectedUserIds.contains(userId),
                onChanged: (value) {
                  _toggleUserSelection(userId);
                  // Force PlutoGrid to rebuild this specific cell
                  _stateManager.notifyListeners();
                },
                visualDensity: VisualDensity.compact,
              ),
            );
          },
        ),
      );
    }

    columns.addAll([
      PlutoColumn(
        title: '#',
        field: 'index',
        type: PlutoColumnType.number(),
        width: 60,
        enableSorting: false,
        enableColumnDrag: false,
        enableContextMenu: false,
        enableFilterMenuItem: false,
        renderer: (rendererContext) {
          return Container(
            alignment: Alignment.center,
            child: Text(
              rendererContext.cell.value.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'ID',
        field: 'id',
        type: PlutoColumnType.text(),
        width: 100,
        hide: true,
      ),
      PlutoColumn(
        title: 'Full Name',
        field: 'name',
        type: PlutoColumnType.text(),
        width: 200,
      ),
      PlutoColumn(
        title: 'Email',
        field: 'email',
        type: PlutoColumnType.text(),
        width: 250,
      ),
      PlutoColumn(
        title: 'Mobile',
        field: 'mobile',
        type: PlutoColumnType.text(),
        width: 150,
      ),
      // Role column removed as requested
    ]);

    // Add actions column only in normal mode
    if (!_isMultiSelectMode) {
      columns.add(
        PlutoColumn(
          title: 'Actions',
          field: 'actions',
          type: PlutoColumnType.text(),
          width: 120,
          enableSorting: false,
          enableColumnDrag: false,
          enableContextMenu: false,
          enableFilterMenuItem: false,
          renderer: (rendererContext) {
            return Container(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () => _editUser(rendererContext.row),
                    tooltip: 'Edit',
                    color: Colors.blue,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18),
                    onPressed: () => _deleteUser(rendererContext.row),
                    tooltip: 'Delete',
                    color: Colors.red,
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18),
                    onSelected: (value) => _handleMenuAction(value, rendererContext.row),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'assign_class',
                        child: Row(
                          children: [
                            Icon(Icons.school, size: 16),
                            SizedBox(width: 8),
                            Text('Assign Class'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'view_details',
                        child: Row(
                          children: [
                            Icon(Icons.info, size: 16),
                            SizedBox(width: 8),
                            Text('View Details'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    return columns;
  }

  List<PlutoRow> _buildGridRows(List<User> users) {
    return users.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final user = entry.value;

      Map<String, PlutoCell> cells = {
        'index': PlutoCell(value: index),
        'id': PlutoCell(value: user.id),
        'name': PlutoCell(value: '${user.firstName} ${user.lastName}'),
        'email': PlutoCell(value: user.email),
        'mobile': PlutoCell(value: user.mobileNumber ?? 'N/A'),
        // Role cell removed as requested
      };

      if (_isMultiSelectMode) {
        cells['checkbox'] = PlutoCell(value: '');
      } else {
        cells['actions'] = PlutoCell(value: '');
      }

      return PlutoRow(cells: cells);
    }).toList();
  }

  // Bulk action handlers
  void _handleBulkAction(String action) {
    switch (action) {
      case 'change_role':
        _showBulkRoleChangeDialog();
        break;
      case 'add_permissions':
        _showBulkPermissionsDialog(true);
        break;
      case 'remove_permissions':
        _showBulkPermissionsDialog(false);
        break;
    }
  }

  void _showBulkAssignClassDialog() {
    final bloc = context.read<UserBloc>();
    List<Class> availableClasses = [];

    final currentState = bloc.state;
    if (currentState is UsersAndClassesLoaded) {
      availableClasses = currentState.classes;
    } else if (currentState is UserOperationSuccess) {
      availableClasses = currentState.classes;
    } else if (currentState is UserOperationInProgress) {
      availableClasses = currentState.classes;
    }

    if (availableClasses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No classes available. Please ensure classes are loaded.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String? selectedClassId = availableClasses.first.id;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Assign ${_selectedUserIds.length} Users to Class'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select a class to assign ${_selectedUserIds.length} selected users:'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedClassId,
                decoration: const InputDecoration(
                  labelText: 'Class',
                  border: OutlineInputBorder(),
                ),
                items: availableClasses.map((classItem) {
                  return DropdownMenuItem(
                    value: classItem.id,
                    child: Text('${classItem.className} - ${classItem.sectionName ?? ''}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    selectedClassId = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedClassId != null ? () {
                Navigator.pop(context);
                _performBulkAssignToClass(selectedClassId!);
              } : null,
              child: const Text('Assign All'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBulkRoleChangeDialog() {
    String selectedRole = 'User';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Change Role for ${_selectedUserIds.length} Users'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select new role for ${_selectedUserIds.length} selected users:'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'User', child: Text('User')),
                  DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'Teacher', child: Text('Teacher')),
                  DropdownMenuItem(value: 'Student', child: Text('Student')),
                ],
                onChanged: (value) {
                  setDialogState(() {
                    selectedRole = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _performBulkRoleChange(selectedRole);
              },
              child: const Text('Change Role'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBulkPermissionsDialog(bool isAdd) {
    final List<String> selectedPermissions = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('${isAdd ? 'Add' : 'Remove'} Permissions for ${_selectedUserIds.length} Users'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select permissions to ${isAdd ? 'add to' : 'remove from'} ${_selectedUserIds.length} selected users:'),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Permissions',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _availablePermissions.map((permission) {
                        return FilterChip(
                          label: Text(permission),
                          selected: selectedPermissions.contains(permission),
                          onSelected: (selected) {
                            setDialogState(() {
                              if (selected) {
                                selectedPermissions.add(permission);
                              } else {
                                selectedPermissions.remove(permission);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedPermissions.isNotEmpty ? () {
                Navigator.pop(context);
                _performBulkPermissionsChange(selectedPermissions, isAdd);
              } : null,
              child: Text(isAdd ? 'Add Permissions' : 'Remove Permissions'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBulkDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Users'),
        content: Text('Are you sure you want to delete ${_selectedUserIds.length} selected users?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _performBulkDelete();
            },
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  // Bulk operation implementations
  void _performBulkAssignToClass(String classId) {
    for (String userId in _selectedUserIds) {
      context.read<UserBloc>().add(AssignUserToClass(userId, classId));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_selectedUserIds.length} users assigned to class'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _performBulkRoleChange(String newRole) {
    // You'll need to implement BulkUpdateUserRole event in your bloc
    context.read<UserBloc>().add(BulkUpdateUserRole(_selectedUserIds.toList(), newRole));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Role changed for ${_selectedUserIds.length} users'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _performBulkPermissionsChange(List<String> permissions, bool isAdd) {
    // You'll need to implement BulkUpdateUserPermissions event in your bloc
    context.read<UserBloc>().add(BulkUpdateUserPermissions(_selectedUserIds.toList(), permissions, isAdd));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Permissions ${isAdd ? 'added to' : 'removed from'} ${_selectedUserIds.length} users'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _performBulkDelete() {
    for (String userId in _selectedUserIds) {
      context.read<UserBloc>().add(DeleteUser(userId));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_selectedUserIds.length} users deleted'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Existing methods remain the same...
  void _handleRowAction(PlutoRow row) {
    final userId = _getUserIdFromRow(row);
    final userName = row.cells['name']?.value ?? 'Unknown';

    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to identify user. Please refresh and try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Actions for $userName',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit User'),
                onTap: () {
                  Navigator.pop(context);
                  _editUser(row);
                },
              ),
              ListTile(
                leading: const Icon(Icons.school, color: Colors.green),
                title: const Text('Assign to Class'),
                onTap: () {
                  Navigator.pop(context);
                  _showAssignClassDialog(userId, userName);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info, color: Colors.orange),
                title: const Text('View Details'),
                onTap: () {
                  Navigator.pop(context);
                  _viewUserDetails(row);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete User'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteUser(row);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _handleMenuAction(String action, PlutoRow row) {
    final userId = _getUserIdFromRow(row);
    final userName = row.cells['name']?.value ?? 'Unknown';

    switch (action) {
      case 'assign_class':
        _showAssignClassDialog(userId, userName);
        break;
      case 'view_details':
        _viewUserDetails(row);
        break;
    }
  }

  void _editUser(PlutoRow row) {
    final user = _getUserFromRow(row);
    if (user != null) {
      _showUserDialog(existingUser: user);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not found. Please refresh and try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteUser(PlutoRow row) {
    final userId = _getUserIdFromRow(row);
    final userName = row.cells['name']?.value ?? 'Unknown';
    _showDeleteConfirmation(userId, userName);
  }

  void _viewUserDetails(PlutoRow row) {
    final user = _getUserFromRow(row);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not found. Please refresh and try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user.firstName} ${user.lastName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Email', user.email),
            _buildDetailRow('Mobile', user.mobileNumber ?? 'Not provided'),
            _buildDetailRow('Role', user.role),
            _buildDetailRow('Permissions', user.permissions.join(', ')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value.isEmpty ? 'None' : value),
          ),
        ],
      ),
    );
  }

  void _showAssignClassDialog(String userId, String userName) {
    final bloc = context.read<UserBloc>();
    List<Class> availableClasses = [];

    // Get current classes from the bloc state
    final currentState = bloc.state;
    if (currentState is UsersAndClassesLoaded) {
      availableClasses = currentState.classes;
    } else if (currentState is UserOperationSuccess) {
      availableClasses = currentState.classes;
    } else if (currentState is UserOperationInProgress) {
      availableClasses = currentState.classes;
    }

    if (availableClasses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No classes available. Please ensure classes are loaded.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Set default selection to first class if none selected
    if (_selectedClassId == null && availableClasses.isNotEmpty) {
      _selectedClassId = availableClasses.first.id;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Assign $userName to Class'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select a class to assign this user:'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedClassId,
                decoration: const InputDecoration(
                  labelText: 'Class',
                  border: OutlineInputBorder(),
                ),
                items: availableClasses.map((classItem) {
                  return DropdownMenuItem(
                    value: classItem.id,
                    child: Text('${classItem.className} - ${classItem.sectionName ?? ''}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    _selectedClassId = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _selectedClassId != null ? () {
                Navigator.pop(context);
                _assignUserToClass(userId, userName, _selectedClassId!);
              } : null,
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }

  void _assignUserToClass(String userId, String userName, String classId) {
    final bloc = context.read<UserBloc>();

    // Get class name for display
    String className = classId;
    final currentState = bloc.state;
    if (currentState is UsersAndClassesLoaded) {
      final classItem = currentState.classes.firstWhere(
              (c) => c.id == classId,
          orElse: () => Class(id: classId, className: '', sectionName: '', academicYearId: '', academicYearName: '')
      );
      className = '${classItem.className} - ${classItem.sectionName ?? ''}';
    }

    // Add the assignment event to bloc
    context.read<UserBloc>().add(AssignUserToClass(userId, classId));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$userName assigned to $className'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _getUserIdFromRow(PlutoRow row) {
    return row.cells['id']?.value?.toString() ?? '';
  }

  User? _getUserFromRow(PlutoRow row) {
    try {
      final state = context.read<UserBloc>().state;
      List<User> users = [];

      if (state is UsersAndClassesLoaded) {
        users = state.users;
      } else if (state is UserOperationSuccess) {
        users = state.users;
      } else if (state is UserOperationInProgress) {
        users = state.users;
      }

      final userId = row.cells['id']?.value?.toString();
      if (userId == null || userId.isEmpty) {
        return null;
      }

      return users.firstWhere(
            (user) => user.id == userId,
        orElse: () => throw StateError('User not found'),
      );
    } catch (e) {
      print('Error finding user: $e');
    }
    return null;
  }

  void _showUserDialog({User? existingUser}) {
    final isEdit = existingUser != null;
    if (isEdit) {
      _firstNameController.text = existingUser.firstName;
      _lastNameController.text = existingUser.lastName;
      _emailController.text = existingUser.email;
      _mobileController.text = existingUser.mobileNumber ?? '';
      _selectedRole = existingUser.role;
      _selectedPermissions.clear();
      _selectedPermissions.addAll(existingUser.permissions);
    } else {
      _firstNameController.clear();
      _lastNameController.clear();
      _emailController.clear();
      _mobileController.clear();
      _selectedRole = 'User';
      _selectedPermissions.clear();
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit User' : 'Add New User'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'First Name *',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Last Name *',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _mobileController,
                    decoration: const InputDecoration(
                      labelText: 'Mobile Number (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'User', child: Text('User')),
                      DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                      DropdownMenuItem(value: 'Teacher', child: Text('Teacher')),
                      DropdownMenuItem(value: 'Student', child: Text('Student')),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        _selectedRole = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Permissions',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _availablePermissions.map((permission) {
                            return FilterChip(
                              label: Text(permission),
                              selected: _selectedPermissions.contains(permission),
                              onSelected: (selected) {
                                setDialogState(() {
                                  if (selected) {
                                    _selectedPermissions.add(permission);
                                  } else {
                                    _selectedPermissions.remove(permission);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              icon: Icon(isEdit ? Icons.save : Icons.add),
              label: Text(isEdit ? 'Update' : 'Add'),
              onPressed: () {
                if (_firstNameController.text.trim().isEmpty ||
                    _lastNameController.text.trim().isEmpty ||
                    _emailController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all required fields (marked with *)'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final user = User(
                  id: isEdit ? existingUser.id : DateTime.now().millisecondsSinceEpoch.toString(),
                  firstName: _firstNameController.text.trim(),
                  lastName: _lastNameController.text.trim(),
                  email: _emailController.text.trim(),
                  mobileNumber: _mobileController.text.trim().isEmpty ? null : _mobileController.text.trim(),
                  role: _selectedRole,
                  permissions: List.from(_selectedPermissions),
                  createdAt: isEdit ? existingUser.createdAt : DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                if (isEdit) {
                  context.read<UserBloc>().add(UpdateUser(user));
                } else {
                  context.read<UserBloc>().add(AddUser(user));
                }

                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(String userId, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete $userName?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              context.read<UserBloc>().add(DeleteUser(userId));
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Users Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first user to get started!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showUserDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add User'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Users',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<UserBloc>().add(LoadUsers());
              context.read<UserBloc>().add(LoadClasses());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }
}
