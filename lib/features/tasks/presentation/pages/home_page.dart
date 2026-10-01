import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/date_formatter.dart';
import '../providers/task_provider.dart';
import '../widgets/task_input.dart';
import '../widgets/task_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<TaskProvider>().loadDays();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<TaskProvider>(
          builder: (context, provider, _) {
            final count = provider.pendingCount;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(formatDay(provider.selectedDay)),
                Text(
                  '$count pendente${count == 1 ? '' : 's'}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            );
          },
        ),
      ),
      drawer: const _DaysDrawer(),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: TaskInput(),
          ),
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, provider, _) {
                if (provider.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.tasks.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma tarefa neste dia.'),
                  );
                }

                return ListView.builder(
                  itemCount: provider.tasks.length,
                  itemBuilder: (context, index) {
                    return TaskTile(task: provider.tasks[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DaysDrawer extends StatelessWidget {
  const _DaysDrawer();

  Future<void> _confirmDeleteDay(BuildContext context, DateTime day) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar dia'),
        content: Text('Apagar todas as tarefas de ${formatDay(day)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<TaskProvider>().deleteDay(day);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.teal),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Data',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
              ),
              if (provider.dayGroups.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Nenhum dia com tarefas.'),
                ),
              ...provider.dayGroups.map((group) {
                final isSelected = group.day == provider.selectedDay;

                return ListTile(
                  selected: isSelected,
                  title: Text(formatDay(group.day)),
                  subtitle: Text(
                    '${group.pending} pendente${group.pending == 1 ? '' : 's'}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDeleteDay(context, group.day),
                  ),
                  onTap: () {
                    context.read<TaskProvider>().selectDay(group.day);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
