import 'package:flutter/material.dart';
import 'package:lista_tarefas/app/app.dart';
import 'package:lista_tarefas/features/tasks/presentation/providers/task_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: const ListaTarefasApp(),
    ),
  );
}
