import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo_model.dart';

class TodoTile extends StatelessWidget {
  final Todo todo;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TodoTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  Future<bool> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete to-do?'),
        content: Text('This will permanently delete "${todo.title}".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _handleDeleteButton(BuildContext context) async {
    final confirmed = await _confirmDelete(context);
    if (confirmed) onDelete();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(Icons.delete_outline,
            color: Theme.of(context).colorScheme.onErrorContainer),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          onTap: onTap,
          leading: Checkbox(
            value: todo.isCompleted,
            onChanged: onToggle,
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              decoration:
                  todo.isCompleted ? TextDecoration.lineThrough : null,
              color: todo.isCompleted
                  ? Theme.of(context).disabledColor
                  : null,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (todo.description.isNotEmpty)
                Text(
                  todo.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    decoration:
                        todo.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMM d, yyyy • h:mm a').format(todo.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          isThreeLine: todo.description.isNotEmpty,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete',
                onPressed: () => _handleDeleteButton(context),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}