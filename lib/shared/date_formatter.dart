String formatDay(DateTime day) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  if (day == today) return 'Hoje';
  return '${_two(day.day)}/${_two(day.month)}/${_two(day.year % 100)}';
}

String formatTime(DateTime date) {
  return '${_two(date.hour)}:${_two(date.minute)}';
}

String _two(int n) => n.toString().padLeft(2, '0');
