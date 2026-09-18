import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single To-Do item stored in Cloud Firestore.
class Todo {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final String userId;
  final DateTime createdAt;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.userId,
    required this.createdAt,
  });

  /// Builds a [Todo] from a Firestore document snapshot.
  factory Todo.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Todo(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts this [Todo] into a map suitable for writing to Firestore.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Todo copyWith({
    String? title,
    String? description,
    bool? isCompleted,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      userId: userId,
      createdAt: createdAt,
    );
  }
}
