import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/todo_model.dart';
import '../services/firestore_service.dart';

/// Owns the real-time list of the signed-in user's todos and exposes
/// Create/Update/Delete/Toggle operations to the UI. No widget talks to
/// Firestore directly - everything goes through this notifier.
class TodoProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  TodoProvider(this._firestoreService);

  StreamSubscription<List<Todo>>? _subscription;

  List<Todo> _todos = [];
  List<Todo> get todos => _todos;

  bool isLoading = true;
  String? errorMessage;

  /// Call this once the user's uid is known (e.g. from the auth stream)
  /// to start listening to their todos in real time.
  void listenToTodos(String uid) {
    isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _firestoreService.streamTodos(uid).listen(
      (items) {
        _todos = items;
        isLoading = false;
        errorMessage = null;
        notifyListeners();
      },
      onError: (e) {
    print('TodoProvider stream error: $e');
    errorMessage = 'Could not load your todos. Please try again.';
    isLoading = false;
    notifyListeners();
  },
    );
  }

  /// Call when the user signs out, so state is cleared for the next user.
  void clear() {
    _subscription?.cancel();
    _subscription = null;
    _todos = [];
    isLoading = true;
    notifyListeners();
  }

  Future<void> addTodo({
    required String uid,
    required String title,
    required String description,
  }) async {
    final todo = Todo(
      id: '',
      title: title,
      description: description,
      isCompleted: false,
      userId: uid,
      createdAt: DateTime.now(),
    );
    await _firestoreService.addTodo(todo);
  }

  Future<void> updateTodo(Todo todo) async {
    await _firestoreService.updateTodo(todo);
  }

  Future<void> toggleCompleted(Todo todo) async {
    await _firestoreService.toggleCompleted(todo.id, !todo.isCompleted);
  }

  Future<void> deleteTodo(String id) async {
    await _firestoreService.deleteTodo(id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
