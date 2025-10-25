import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/models/task.dart';
import 'package:flutter_application_2/providers/task_provider.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes da Tarefa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: null),
            onPressed: () {
              context.read<TaskProvider>().removeTask(task);

              Navigator.pop(context);
            },
            tooltip: 'Remover Tarefa',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TAREFA:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                task.text,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 24),
              Text(
                'ESTADO:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                task.isDone ? 'Concluída' : 'Pendente',
                style: TextStyle(
                  fontSize: 24,
                  color: task.isDone
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
