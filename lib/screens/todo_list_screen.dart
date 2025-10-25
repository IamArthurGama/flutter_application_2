import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_2/main.dart';
import 'package:flutter_application_2/models/task.dart';
import 'package:flutter_application_2/screens/task_detail_screen.dart';
import 'package:flutter_application_2/providers/task_provider.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() => context.read<TaskProvider>().loadTasks());
  }

  Future<void> _displayDialog({Task? task}) async {
    _textFieldController.text = task?.text ?? '';

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final isEditing = task != null;

        return AlertDialog(
          title: Text(isEditing ? 'Editar tarefa' : 'Adicionar nova tarefa'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: 'Digite a sua tarefa'),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                _textFieldController.clear();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(isEditing ? 'Salvar' : 'Adicionar'),
              onPressed: () {
                setState(() {
                  final newText = _textFieldController.text;

                  if ( newText.isNotEmpty ) {
                    final provider = context.read<TaskProvider>();

                    if ( isEditing ) {
                      provider.editTask(task!, newText);
                    } else {
                      provider.addTask(newText);
                    }
                  }
                });
                _textFieldController.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final tasks = provider.tasks;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista Boladona'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              MyApp.of(context).toggleTheme();
            },
            tooltip: 'Alterar Tema',
          ),
        ],
      ),
      body: tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    // color: Colors.grey[350],
                    color: Theme.of(context).disabledColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma tarefa encontrada.',
                    style: TextStyle(fontSize: 18, color: Theme.of(context).disabledColor),
                  ),
                  Text(
                    'Adicione uma nova tarefa no botão "+"',
                    style: TextStyle(fontSize: 14, color:Theme.of(context).disabledColor),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: ListTile(
                      onTap: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskDetailScreen(task: task)
                        ),
                       );
                      },
                      leading: Checkbox(
                        value: task.isDone,
                        onChanged: (value) {
                          context.read<TaskProvider>().toggleTaskStatus(task);
                        },
                      ),
                      title: Text(
                        task.text,
                        style: TextStyle(
                          decoration: task.isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: task.isDone ? Theme.of(context).disabledColor : null,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: null),
                            onPressed: () {
                              _displayDialog(task: task);
                            },
                            tooltip: 'Editar Tarefa',
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: null),
                            onPressed: () {
                              context.read<TaskProvider>().removeTask(task);
                            },
                            tooltip: 'Remover Tarefa',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _displayDialog,
        tooltip: 'Adicionar Tarefa',
        child: const Icon(Icons.add),
      ),
    );
  }
}
