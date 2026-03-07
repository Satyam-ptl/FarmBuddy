import 'package:flutter/material.dart';
import '../models/farmer_model.dart';
import '../models/task_model.dart';  // Import Task model
import '../services/api_service.dart';  // Import API service
import '../services/auth_service.dart';
import '../services/auth_ui_service.dart';
import '../services/localization_service.dart';
import 'package:intl/intl.dart';  // For date formatting

/// Tasks screen - shows list of all tasks
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<FarmerTask> tasks = [];  // List of tasks
  bool isLoading = true;
  String? errorMessage;
  String selectedStatus = 'All';  // Filter by status

  // Available statuses
  final List<String> statuses = [
    'All',
    'Pending',
    'In Progress',
    'Completed',
    'Overdue',
    'Cancelled'
  ];

  bool get _isAdmin => AuthService.session?.isAdmin ?? false;

  List<FarmerTask> get _scheduledTasks {
    final now = DateTime.now();
    return tasks
        .where((task) => !task.isCompleted && task.dueDate != null)
        .toList()
      ..sort((a, b) {
        final aDue = a.dueDate ?? now;
        final bDue = b.dueDate ?? now;
        return aDue.compareTo(bDue);
      });
  }

  int get _overdueCount => _scheduledTasks
      .where((task) => (task.isOverdue == true) || (task.daysRemaining ?? 999) < 0)
      .length;

  int get _todayCount => _scheduledTasks
      .where((task) => (task.daysRemaining ?? 999) == 0)
      .length;

  int get _nextThreeDaysCount => _scheduledTasks
      .where((task) {
        final days = task.daysRemaining;
        return days != null && days > 0 && days <= 3;
      })
      .length;

  @override
  void initState() {
    super.initState();
    loadTasks();  // Load tasks when screen opens
  }

  /// Load tasks from Django API
  Future<void> loadTasks() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.getTasks(
        status: selectedStatus == 'All' ? null : selectedStatus,
        pageSize: 100,
      );
      final List<dynamic> tasksJson = (response['results'] as List<dynamic>? ?? []);
      final List<FarmerTask> loadedTasks = tasksJson
          .map((json) => FarmerTask.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();

      setState(() {
        tasks = loadedTasks;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final handled = await AuthUiService.handleAuthError(
        context,
        e,
        message: 'Session expired. Please sign in again.',
      );
      if (handled) return;
      setState(() {
        errorMessage = 'Failed to load tasks: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService.tr('Tasks')),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => AuthUiService.confirmAndLogout(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadTasks,
            tooltip: LocalizationService.tr('Refresh'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateTaskDialog,
        icon: const Icon(Icons.add_task),
        label: const Text('Add Task'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _buildReminderSummary(),
          ),

          // Status filter chips
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: statuses.map((status) {
                final isSelected = status == selectedStatus;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => selectedStatus = status);
                      loadTasks();
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Tasks list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(errorMessage!,
                                style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: loadTasks,
                              child: Text(LocalizationService.tr('Retry')),
                            ),
                          ],
                        ),
                      )
                    : tasks.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.task_alt, size: 64, color: Colors.grey.shade300),
                                  const SizedBox(height: 16),
                                  Text(
                                    selectedStatus == 'All'
                                        ? 'No tasks yet'
                                        : 'No $selectedStatus tasks',
                                    style: TextStyle(fontSize: 16, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap + to create your first task',
                                    style: TextStyle(color: Colors.grey.shade400),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: loadTasks,
                            child: ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                if (_scheduledTasks.isNotEmpty) ...[
                                  _buildReminderSection(),
                                  const SizedBox(height: 8),
                                ],
                                ...tasks.map(_buildTaskCard),
                              ],
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  /// Build a card widget for a task
  Widget _buildTaskCard(FarmerTask task) {
    final DateFormat dateFormat = DateFormat('dd MMM yyyy');  // Date formatter

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          _showTaskDetails(task);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task name and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.taskName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Chip(
                    label: Text(task.status),
                    backgroundColor: _getStatusColor(task.status),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Farmer name (admin-focused)
              if (_isAdmin)
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text('Farmer: ${task.farmerName}'),
                  ],
                ),

              // Crop name if available
              if (task.cropName != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.grass, size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Text('Crop: ${task.cropName}'),
                  ],
                ),
              ],

              // Due date if available
              if (task.dueDate != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: task.isOverdue == true ? Colors.red : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${dateFormat.format(task.dueDate!)}',
                      style: TextStyle(
                        color: task.isOverdue == true ? Colors.red : Colors.black,
                        fontWeight: task.isOverdue == true
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    if (task.daysRemaining != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        _buildDueText(task.daysRemaining!),
                        style: TextStyle(
                          color: task.isOverdue == true ? Colors.red : Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ],

              // Priority and importance
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(
                    label: Text('Priority: ${task.priority}'),
                    backgroundColor: _getPriorityColor(task.priority),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(task.importance),
                    backgroundColor: _getImportanceColor(task.importance),
                  ),
                ],
              ),

              if (task.completedDate != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Text('Completed: ${DateFormat('dd MMM yyyy').format(task.completedDate!)}'),
                  ],
                ),
              ],

              // Description preview
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  task.description,
                  style: const TextStyle(color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderSummary() {
    return Row(
      children: [
        Expanded(
          child: _buildReminderSummaryCard(
            title: 'Overdue',
            value: _overdueCount,
            color: Colors.red,
            icon: Icons.warning_amber_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildReminderSummaryCard(
            title: 'Today',
            value: _todayCount,
            color: Colors.orange,
            icon: Icons.today,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildReminderSummaryCard(
            title: 'Next 3 days',
            value: _nextThreeDaysCount,
            color: Colors.blue,
            icon: Icons.schedule,
          ),
        ),
      ],
    );
  }

  Widget _buildReminderSummaryCard({
    required String title,
    required int value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReminderSection() {
    final reminderTasks = _scheduledTasks.take(4).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.notifications_active, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Time-based reminders',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...reminderTasks.map((task) {
              final days = task.daysRemaining;
              final bool overdue = (task.isOverdue == true) || (days != null && days < 0);
              final Color color = overdue
                  ? Colors.red
                  : (days == 0 ? Colors.orange : Colors.blue);

              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  overdue ? Icons.error_outline : Icons.alarm,
                  color: color,
                ),
                title: Text(task.taskName, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(task.cropName ?? task.farmerName),
                trailing: Text(
                  days == null ? 'Scheduled' : _buildDueText(days),
                  style: TextStyle(color: color, fontWeight: FontWeight.w600),
                ),
                onTap: () => _showTaskDetails(task),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _buildDueText(int daysRemaining) {
    if (daysRemaining < 0) {
      return '(${daysRemaining.abs()} day${daysRemaining.abs() == 1 ? '' : 's'} overdue)';
    }
    if (daysRemaining == 0) {
      return '(due today)';
    }
    return '(in $daysRemaining day${daysRemaining == 1 ? '' : 's'})';
  }

  /// Get color for status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange.shade100;
      case 'In Progress':
        return Colors.blue.shade100;
      case 'Completed':
        return Colors.green.shade100;
      case 'Overdue':
        return Colors.red.shade100;
      case 'Cancelled':
        return Colors.grey.shade300;
      default:
        return Colors.grey.shade100;
    }
  }

  /// Get color for priority
  Color _getPriorityColor(int priority) {
    if (priority >= 8) return Colors.red.shade100;
    if (priority >= 5) return Colors.orange.shade100;
    return Colors.blue.shade100;
  }

  /// Get color for importance
  Color _getImportanceColor(String importance) {
    switch (importance) {
      case 'Critical':
        return Colors.red.shade200;
      case 'High':
        return Colors.orange.shade200;
      case 'Medium':
        return Colors.yellow.shade200;
      case 'Low':
        return Colors.blue.shade200;
      default:
        return Colors.grey.shade200;
    }
  }

  /// Show task details dialog
  void _showTaskDetails(FarmerTask task) {
    final DateFormat dateFormat = DateFormat('dd MMM yyyy');
    final DateFormat dateTimeFormat = DateFormat('dd MMM yyyy HH:mm');
    final notesController = TextEditingController(text: task.farmerNotes ?? '');
    String selectedStatus = task.status;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(task.taskName),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isAdmin) _buildDetailRow('Farmer', task.farmerName),
                if (task.cropName != null) _buildDetailRow('Crop', task.cropName!),
                _buildDetailRow('Status', task.status),
                if (task.dueDate != null) _buildDetailRow('Due Date', dateFormat.format(task.dueDate!)),
                if (task.completedDate != null)
                  _buildDetailRow('Completed Date', dateFormat.format(task.completedDate!)),
                _buildDetailRow('Priority', task.priority.toString()),
                _buildDetailRow('Priority Mode', task.isPriorityManual ? 'Manual' : 'Auto'),
                _buildDetailRow('Importance', task.importance),
                _buildDetailRow('Completed', task.isCompleted ? 'Yes' : 'No'),
                _buildDetailRow('Photos', task.photoCount.toString()),
                if (task.reminderSentAt != null)
                  _buildDetailRow('Last Reminder', dateTimeFormat.format(task.reminderSentAt!)),
                _buildDetailRow('Created', dateTimeFormat.format(task.createdAt)),
                _buildDetailRow('Updated', dateTimeFormat.format(task.updatedAt)),
                const SizedBox(height: 8),
                const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(task.description),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Update status',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'In Progress', child: Text('In Progress')),
                    DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                    DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedStatus = value ?? task.status;
                    });
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Farmer notes',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                FutureBuilder<Map<String, List<dynamic>>>(
                  future: _loadTaskActivity(task.id),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox(
                        height: 60,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final reminders = snapshot.data!['reminders'] ?? [];
                    final logs = snapshot.data!['logs'] ?? [];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Reminders', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        if (reminders.isEmpty)
                          const Text('No reminders found', style: TextStyle(color: Colors.grey))
                        else
                          ...reminders.take(3).map((item) {
                            final reminder = item as TaskReminder;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '• ${reminder.reminderChannel} - ${dateFormat.format(reminder.reminderDate)} (${reminder.isSent ? 'Sent' : 'Pending'})',
                              ),
                            );
                          }),
                        const SizedBox(height: 10),
                        const Text('Activity Log', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        if (logs.isEmpty)
                          const Text('No activity yet', style: TextStyle(color: Colors.grey))
                        else
                          ...logs.take(4).map((item) {
                            final log = item as TaskLog;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '• ${log.action} - ${dateTimeFormat.format(log.timestamp)}',
                              ),
                            );
                          }),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final payload = <String, dynamic>{
                  'status': selectedStatus,
                  'farmer_notes': notesController.text.trim(),
                };

                if (selectedStatus == 'Completed') {
                  payload['is_completed'] = true;
                  payload['completed_date'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
                } else {
                  payload['is_completed'] = false;
                }

                await _updateTaskWithFeedback(
                  task.id,
                  payload,
                  successMessage: 'Task updated successfully',
                  onSuccessCloseContext: dialogContext,
                );
              },
              child: const Text('Save'),
            ),
            if (!task.isCompleted)
              TextButton(
                onPressed: () async {
                  await _updateTaskWithFeedback(
                    task.id,
                    {
                      'status': 'Completed',
                      'is_completed': true,
                      'completed_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                      'farmer_notes': notesController.text.trim(),
                    },
                    successMessage: 'Task marked as completed',
                    onSuccessCloseContext: dialogContext,
                  );
                },
                child: const Text('Mark Complete'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    ).then((_) => notesController.dispose());
  }

  Future<Map<String, List<dynamic>>> _loadTaskActivity(int taskId) async {
    try {
      final remindersResponse = await ApiService.getTaskReminders(taskId: taskId, pageSize: 20);
      final logsResponse = await ApiService.getTaskLogs(taskId: taskId, pageSize: 20);

      final reminders = (remindersResponse['results'] as List<dynamic>? ?? [])
          .map((item) => TaskReminder.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();

      final logs = (logsResponse['results'] as List<dynamic>? ?? [])
          .map((item) => TaskLog.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();

      return {
        'reminders': reminders,
        'logs': logs,
      };
    } catch (_) {
      return {
        'reminders': <TaskReminder>[],
        'logs': <TaskLog>[],
      };
    }
  }

  Future<void> _updateTaskWithFeedback(
    int taskId,
    Map<String, dynamic> payload, {
    required String successMessage,
    BuildContext? onSuccessCloseContext,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final closeNavigator =
        onSuccessCloseContext != null ? Navigator.of(onSuccessCloseContext) : null;
    try {
      await ApiService.updateTask(taskId, payload);
      if (!mounted) return;
      if (closeNavigator != null) {
        closeNavigator.pop();
      }
      await loadTasks();
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(successMessage)),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  /// Build detail row
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _showCreateTaskDialog() async {
    final taskNameController = TextEditingController();
    final descriptionController = TextEditingController();
    final dueDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 3))),
    );

    List<Farmer> farmers = [];
    List<FarmerCrop> farmerCrops = [];
    int? selectedFarmerId = AuthService.session?.farmerId;
    int? selectedFarmerCropId;
    bool isManualPriority = false;
    int selectedManualPriority = 5;

    try {
      if (_isAdmin) {
        final farmersResponse = await ApiService.getFarmers(pageSize: 200);
        final farmersJson = (farmersResponse['results'] as List<dynamic>? ?? []);
        farmers = farmersJson
            .map((item) => Farmer.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
        selectedFarmerId = farmers.isNotEmpty ? farmers.first.id : null;
      }

      final cropsResponse = await ApiService.getFarmerCrops(
        farmerId: _isAdmin ? null : AuthService.session?.farmerId,
        pageSize: 200,
      );
      final cropsJson = (cropsResponse['results'] as List<dynamic>? ?? []);
      farmerCrops = cropsJson
          .map((item) => FarmerCrop.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
      selectedFarmerCropId = farmerCrops.isNotEmpty ? farmerCrops.first.id : null;
    } catch (_) {}

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredCrops = _isAdmin && selectedFarmerId != null
                ? farmerCrops.where((item) => item.farmerId == selectedFarmerId).toList()
                : farmerCrops;

            if (filteredCrops.isNotEmpty &&
                !filteredCrops.any((item) => item.id == selectedFarmerCropId)) {
              selectedFarmerCropId = filteredCrops.first.id;
            }

            FarmerCrop? selectedCrop;
            if (selectedFarmerCropId != null) {
              for (final crop in filteredCrops) {
                if (crop.id == selectedFarmerCropId) {
                  selectedCrop = crop;
                  break;
                }
              }
            }

            return AlertDialog(
              title: const Text('Create Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isAdmin) ...[
                      DropdownButtonFormField<int>(
                        initialValue: selectedFarmerId,
                        decoration: const InputDecoration(labelText: 'Farmer'),
                        items: farmers
                            .map(
                              (farmer) => DropdownMenuItem(
                                value: farmer.id,
                                child: Text(farmer.fullName),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedFarmerId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                    DropdownButtonFormField<int>(
                      initialValue: selectedFarmerCropId,
                      decoration: const InputDecoration(labelText: 'Farmer Crop'),
                      items: filteredCrops
                          .map(
                            (crop) => DropdownMenuItem(
                              value: crop.id,
                              child: Text('${crop.cropName} • ${crop.status}'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedFarmerCropId = value;
                        });
                      },
                    ),
                    if (filteredCrops.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'No crops found for selected farmer. Go to Crops tab and add a crop first.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    if (selectedCrop != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Selected: ${selectedCrop.cropName} (${selectedCrop.status}) | Area: ${selectedCrop.areaAllocatedHectares.toStringAsFixed(2)} ha',
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: taskNameController,
                      decoration: const InputDecoration(labelText: 'Task Name'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'Task Description'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: dueDateController,
                      readOnly: true,
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 3)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 3650)),
                        );

                        if (pickedDate == null) return;
                        dueDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Due Date (YYYY-MM-DD)',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                    if (_isAdmin) ...[
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: isManualPriority ? 'Manual' : 'Auto',
                        decoration: const InputDecoration(labelText: 'Priority Mode'),
                        items: const [
                          DropdownMenuItem(value: 'Auto', child: Text('Auto (from due date)')),
                          DropdownMenuItem(value: 'Manual', child: Text('Manual')),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            isManualPriority = value == 'Manual';
                          });
                        },
                      ),
                      if (isManualPriority) ...[
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          initialValue: selectedManualPriority,
                          decoration: const InputDecoration(labelText: 'Manual Priority (1-10)'),
                          items: List.generate(
                            10,
                            (index) => DropdownMenuItem(
                              value: index + 1,
                              child: Text('${index + 1}'),
                            ),
                          ),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedManualPriority = value ?? 5;
                            });
                          },
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: filteredCrops.isEmpty
                      ? null
                      : () async {
                    final dialogNavigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    final taskName = taskNameController.text.trim();
                    final description = descriptionController.text.trim();
                    final dueDate = dueDateController.text.trim();

                    // Safety: if crops exist but selection wasn't set by UI, pick first.
                    selectedFarmerCropId ??= filteredCrops.isNotEmpty ? filteredCrops.first.id : null;

                    if (selectedFarmerCropId == null) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Please select a crop for this task.')),
                      );
                      return;
                    }

                    if (taskName.isEmpty) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Task name is required.')),
                      );
                      return;
                    }

                    if (description.length < 10) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Task description must be at least 10 characters.')),
                      );
                      return;
                    }

                    if (dueDate.isEmpty) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Due date is required.')),
                      );
                      return;
                    }

                    try {
                      final payload = <String, dynamic>{
                        'farmer_crop': selectedFarmerCropId,
                        'task_name': taskName,
                        'task_description': description,
                        'due_date': dueDate,
                      };

                      if (_isAdmin && selectedFarmerId != null) {
                        payload['farmer'] = selectedFarmerId;
                        payload['is_priority_manual'] = isManualPriority;
                        if (isManualPriority) {
                          payload['priority'] = selectedManualPriority;
                        }
                      }

                      await ApiService.createTask(payload);
                      if (!mounted) return;
                      dialogNavigator.pop();
                      await loadTasks();
                      if (!mounted) return;
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Task created successfully')),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      final handled = await AuthUiService.handleAuthError(
                        this.context,
                        e,
                        message: 'Session expired. Please sign in again.',
                      );
                      if (handled) return;
                      messenger.showSnackBar(
                        SnackBar(content: Text('Failed to create task: $e')),
                      );
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );

    taskNameController.dispose();
    descriptionController.dispose();
    dueDateController.dispose();
  }
}
