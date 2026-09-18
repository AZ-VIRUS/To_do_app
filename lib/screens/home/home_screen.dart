import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/todo_provider.dart';
import '../../widgets/todo_tile.dart';
import '../settings/settings_screen.dart';
import 'add_edit_todo_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Start listening to this user's real-time todo stream.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoProvider>().listenToTodos(widget.user.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final todoProvider = context.watch<TodoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My To-Dos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: _buildBody(todoProvider),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddEditTodoScreen(uid: widget.user.uid),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(TodoProvider todoProvider) {
    if (todoProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (todoProvider.errorMessage != null) {
      return Center(child: Text(todoProvider.errorMessage!));
    }
    if (todoProvider.todos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.checklist_rtl,
                  size: 64, color: Theme.of(context).disabledColor),
              const SizedBox(height: 12),
              const Text(
                'No to-dos yet.\nTap + to add your first one!',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
      itemCount: todoProvider.todos.length,
      itemBuilder: (context, index) {
        final todo = todoProvider.todos[index];
        return TodoTile(
          todo: todo,
          onToggle: (_) => todoProvider.toggleCompleted(todo),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  AddEditTodoScreen(uid: widget.user.uid, todo: todo),
            ),
          ),
          onDelete: () => todoProvider.deleteTodo(todo.id),
        );
      },
    );
  }
}
