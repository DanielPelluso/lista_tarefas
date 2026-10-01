import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';
import '../../../../shared/date_formatter.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: task.isDone,
        onChanged: (_) => context.read<TaskProvider>().toggleTask(task),
      ),
      title: Text(
        task.title,
        style: TextStyle(
          decoration: task.isDone ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(formatTime(task.createdAt)),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () => context.read<TaskProvider>().deleteTask(task.id!),
      ),
    );
  }
}
