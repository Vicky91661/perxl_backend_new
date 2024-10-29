class Task {
  int? id;
  String title;
  DateTime date;
  String priority;
  int status; // 0 - Incomplete, 1 - Complete

  // Constructor without ID
  Task({
    required this.title,
    required this.date,
    required this.priority,
    this.status = 0, // default to Incomplete
  });

  // Constructor with ID
  Task.withId({
    this.id,  // Nullable id
    required this.title,
    required this.date,
    required this.priority,
    this.status = 0,
  });

  // Convert Task object to a map for saving to a database
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (id != null) {
      map['id'] = id;
    }
    map['title'] = title;
    map['date'] = date.toIso8601String();
    map['priority'] = priority;
    map['status'] = status;
    return map;
  }

  // Create a Task object from a map (e.g., from a database)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task.withId(
      id: map['id'],  // This may be null
      title: map['title'],
      date: DateTime.parse(map['date']),
      priority: map['priority'],
      status: map['status'],
    );
  }
}
