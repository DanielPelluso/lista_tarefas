import '../domain/entities/day_group.dart';
import '../domain/entities/task.dart';
import 'task_database.dart';

class TaskRepository {
  Future<List<Task>> getAll() async {
    final db = await TaskDatabase.instance.database;
    final rows = await db.query('tasks', orderBy: 'created_at ASC');
    return rows.map(_toTask).toList();
  }

  Future<List<Task>> getByDay(DateTime day) async {
    final db = await TaskDatabase.instance.database;
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    final rows = await db.query(
      'tasks',
      where: 'created_at >= ? AND created_at < ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      orderBy: 'created_at ASC',
    );

    return rows.map(_toTask).toList();
  }

  Future<List<DayGroup>> getDayGroups() async {
    final db = await TaskDatabase.instance.database;
    final rows = await db.query(
      'tasks',
      columns: ['created_at', 'done'],
      orderBy: 'created_at DESC',
    );

    final groups = <DateTime, DayGroup>{};

    for (final row in rows) {
      final date = DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int);
      final day = DateTime(date.year, date.month, date.day);
      final isDone = (row['done'] as int) == 1;

      final existing = groups[day];
      groups[day] = DayGroup(
        day: day,
        total: (existing?.total ?? 0) + 1,
        pending: (existing?.pending ?? 0) + (isDone ? 0 : 1),
      );
    }

    final list = groups.values.toList();
    list.sort((a, b) => b.day.compareTo(a.day));
    return list;
  }

  Future<Task> insert(Task task) async {
    final db = await TaskDatabase.instance.database;
    final id = await db.insert('tasks', _toRow(task));
    return task.copyWith(id: id);
  }

  Future<void> update(Task task) async {
    final db = await TaskDatabase.instance.database;
    await db.update(
      'tasks',
      _toRow(task),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await TaskDatabase.instance.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteByDay(DateTime day) async {
    final db = await TaskDatabase.instance.database;
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    await db.delete(
      'tasks',
      where: 'created_at >= ? AND created_at < ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
    );
  }

  Task _toTask(Map<String, Object?> row) {
    return Task(
      id: row['id'] as int,
      title: row['title'] as String,
      isDone: (row['done'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
    );
  }

  Map<String, Object?> _toRow(Task task) {
    return {
      'title': task.title,
      'done': task.isDone ? 1 : 0,
      'created_at': task.createdAt.millisecondsSinceEpoch,
    };
  }
}
