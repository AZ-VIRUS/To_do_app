import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo_model.dart';

/// Handles all Cloud Firestore reads/writes for To-Do items.
/// Keeping this isolated from the UI/provider layer makes it easy to
/// swap out the backend or unit test the data layer independently.
class FirestoreService {
  final CollectionReference<Map<String, dynamic>> _todosRef =
      FirebaseFirestore.instance.collection('todos');

  /// READ: real-time stream of the signed-in user's todos, newest first.
  Stream<List<Todo>> streamTodos(String uid) {
    return _todosRef
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Todo.fromDocument(doc)).toList());
  }

  /// CREATE
  Future<void> addTodo(Todo todo) async {
    await _todosRef.add(todo.toJson());
  }

  /// UPDATE
  Future<void> updateTodo(Todo todo) async {
    await _todosRef.doc(todo.id).update(todo.toJson());
  }

  /// UPDATE (quick toggle of completion status)
  Future<void> toggleCompleted(String id, bool isCompleted) async {
    await _todosRef.doc(id).update({'isCompleted': isCompleted});
  }

  /// DELETE
  Future<void> deleteTodo(String id) async {
    await _todosRef.doc(id).delete();
  }
}
