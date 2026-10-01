import 'package:flutter/material.dart';

import '../features/tasks/presentation/pages/home_page.dart';
import 'theme/app_theme.dart';

class ListaTarefasApp extends StatelessWidget {
  const ListaTarefasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tarefas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomePage(),
    );
  }
}
