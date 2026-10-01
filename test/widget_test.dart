import 'package:flutter_test/flutter_test.dart';
import 'package:lista_tarefas/features/tasks/data/task_database.dart';
import 'package:lista_tarefas/features/tasks/data/task_repository.dart';
import 'package:lista_tarefas/features/tasks/domain/entities/task.dart';
import 'package:lista_tarefas/features/tasks/presentation/providers/task_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await TaskDatabase.instance.close();
    final dbPath = await getDatabasesPath();
    await deleteDatabase('$dbPath/tasks.db');
  });

  group('Task', () {
    test('copyWith preserva campos não alterados', () {
      final task = Task(title: 'Estudar', createdAt: DateTime(2024, 1, 1));
      final updated = task.copyWith(isDone: true);

      expect(updated.isDone, true);
      expect(updated.title, 'Estudar');
      expect(updated.createdAt, DateTime(2024, 1, 1));
    });
  });

  group('TaskRepository', () {
    test('getByDay retorna tarefas do dia em ordem crescente de hora', () async {
      final repo = TaskRepository();
      final day = DateTime(2024, 1, 1);

      await repo.insert(Task(title: 'Tarefa 8h', createdAt: DateTime(2024, 1, 1, 8, 0)));
      await repo.insert(Task(title: 'Tarefa 7h', createdAt: DateTime(2024, 1, 1, 7, 0)));
      await repo.insert(Task(title: 'Tarefa 9h', createdAt: DateTime(2024, 1, 1, 9, 30)));

      final tasks = await repo.getByDay(day);

      expect(tasks.length, 3);
      expect(tasks[0].title, 'Tarefa 7h');
      expect(tasks[1].title, 'Tarefa 8h');
      expect(tasks[2].title, 'Tarefa 9h');
    });

    test('getByDay não retorna tarefas de outros dias', () async {
      final repo = TaskRepository();

      await repo.insert(Task(title: 'Dia 1', createdAt: DateTime(2024, 1, 1, 10)));
      await repo.insert(Task(title: 'Dia 2', createdAt: DateTime(2024, 1, 2, 10)));

      final tasks = await repo.getByDay(DateTime(2024, 1, 1));

      expect(tasks.length, 1);
      expect(tasks.first.title, 'Dia 1');
    });

    test('getDayGroups agrupa por dia com total e pendentes', () async {
      final repo = TaskRepository();

      await repo.insert(Task(title: 'A', createdAt: DateTime(2024, 1, 2, 10)));
      await repo.insert(Task(title: 'B', createdAt: DateTime(2024, 1, 2, 11)));
      await repo.insert(Task(title: 'C', createdAt: DateTime(2024, 1, 1, 9)));

      final groups = await repo.getDayGroups();

      expect(groups.length, 2);
      expect(groups.first.day, DateTime(2024, 1, 2));
      expect(groups.first.total, 2);
      expect(groups.first.pending, 2);
      expect(groups.last.day, DateTime(2024, 1, 1));
    });

    test('deleteByDay remove todas as tarefas do dia', () async {
      final repo = TaskRepository();

      await repo.insert(Task(title: 'A', createdAt: DateTime(2024, 1, 1, 8)));
      await repo.insert(Task(title: 'B', createdAt: DateTime(2024, 1, 1, 18)));
      await repo.insert(Task(title: 'C', createdAt: DateTime(2024, 1, 2, 10)));

      await repo.deleteByDay(DateTime(2024, 1, 1));

      expect(await repo.getByDay(DateTime(2024, 1, 1)), isEmpty);
      expect((await repo.getByDay(DateTime(2024, 1, 2))).length, 1);
    });
  });

  group('TaskProvider', () {
    late TaskProvider provider;

    setUp(() async {
      provider = TaskProvider();
      await provider.loadDays();
    });

    test('inicia vazio e sem loading', () {
      expect(provider.tasks, isEmpty);
      expect(provider.loading, false);
      expect(provider.pendingCount, 0);
    });

    test('adiciona tarefa e conta pendentes', () async {
      await provider.addTask('Comprar pão');

      expect(provider.tasks.length, 1);
      expect(provider.tasks.first.title, 'Comprar pão');
      expect(provider.pendingCount, 1);
    });

    test('ignora tarefa com título vazio', () async {
      await provider.addTask('   ');

      expect(provider.tasks, isEmpty);
    });

    test('marca tarefa como concluída', () async {
      await provider.addTask('Estudar Flutter');
      final task = provider.tasks.first;

      await provider.toggleTask(task);

      expect(provider.tasks.first.isDone, true);
      expect(provider.pendingCount, 0);
    });

    test('exclui tarefa', () async {
      await provider.addTask('Tarefa temporária');
      final task = provider.tasks.first;

      await provider.deleteTask(task.id!);

      expect(provider.tasks, isEmpty);
    });

    test('adiciona tarefa com data futura e navega para o dia', () async {
      final future = DateTime(2030, 12, 25, 7, 0);

      await provider.addTask('Tarefa futura', date: future);

      expect(provider.selectedDay, DateTime(2030, 12, 25));
      expect(provider.tasks.length, 1);
      expect(provider.tasks.first.createdAt, future);
      expect(provider.dayGroups.any((g) => g.day == DateTime(2030, 12, 25)), true);
    });
  });
}
