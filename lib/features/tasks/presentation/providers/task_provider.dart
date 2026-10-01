import 'package:flutter/material.dart';

import '../../data/task_repository.dart';
import '../../domain/entities/day_group.dart';
import '../../domain/entities/task.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository _repository = TaskRepository();

  List<DayGroup> _dayGroups = [];
  DateTime _selectedDay = _today();
  List<Task> _tasks = [];
  bool _loading = true;

  List<DayGroup> get dayGroups => _dayGroups;
  DateTime get selectedDay => _selectedDay;
  List<Task> get tasks => _tasks;
  bool get loading => _loading;

  int get pendingCount => _tasks.where((task) => !task.isDone).length;

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> loadDays() async {
    _loading = true;
    notifyListeners();

    _dayGroups = await _repository.getDayGroups();

    final today = _today();
    if (_dayGroups.any((group) => group.day == today)) {
      _selectedDay = today;
    } else if (_dayGroups.isNotEmpty) {
      _selectedDay = _dayGroups.first.day;
    } else {
      _selectedDay = today;
    }

    _tasks = await _repository.getByDay(_selectedDay);

    _loading = false;
    notifyListeners();
  }

  Future<void> selectDay(DateTime day) async {
    _selectedDay = day;
    _loading = true;
    notifyListeners();

    _tasks = await _repository.getByDay(day);

    _loading = false;
    notifyListeners();
  }

  Future<void> addTask(String title, {DateTime? date}) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;

    final createdAt = date ?? DateTime.now();
    final task = Task(title: trimmed, createdAt: createdAt);
    await _repository.insert(task);

    final day = DateTime(createdAt.year, createdAt.month, createdAt.day);
    _dayGroups = await _repository.getDayGroups();
    _selectedDay = day;
    _tasks = await _repository.getByDay(day);
    notifyListeners();
  }

  Future<void> toggleTask(Task task) async {
    final updated = task.copyWith(isDone: !task.isDone);
    await _repository.update(updated);

    _tasks = await _repository.getByDay(_selectedDay);
    _dayGroups = await _repository.getDayGroups();
    notifyListeners();
  }

  Future<void> deleteTask(int id) async {
    await _repository.delete(id);

    _tasks = await _repository.getByDay(_selectedDay);
    _dayGroups = await _repository.getDayGroups();

    if (_tasks.isEmpty && _dayGroups.isNotEmpty) {
      _selectedDay = _dayGroups.first.day;
      _tasks = await _repository.getByDay(_selectedDay);
    }

    notifyListeners();
  }

  Future<void> deleteDay(DateTime day) async {
    await _repository.deleteByDay(day);

    _dayGroups = await _repository.getDayGroups();

    if (_dayGroups.isEmpty) {
      _selectedDay = _today();
      _tasks = [];
    } else if (_selectedDay == day) {
      _selectedDay = _dayGroups.first.day;
      _tasks = await _repository.getByDay(_selectedDay);
    }

    notifyListeners();
  }
}
