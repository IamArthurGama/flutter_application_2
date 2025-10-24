import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findRootAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: Colors.lightBlue,
      brightness: Brightness.light,
    );

    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: Colors.lightBlue,
      brightness: Brightness.dark,
    );
  
    return MaterialApp(
      
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: lightColorScheme,
        appBarTheme: AppBarTheme(
          backgroundColor: lightColorScheme.primary,
          foregroundColor: lightColorScheme.onPrimary,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: darkColorScheme,
        appBarTheme: AppBarTheme(
          backgroundColor: darkColorScheme.primaryContainer,
          foregroundColor: darkColorScheme.onPrimaryContainer,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,

      home: const TodoListScreen(),

      debugShowCheckedModeBanner: false,
    );
  }
}

class Task {
  String text;
  bool isDone;

  Task({required this.text, this.isDone = false});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(text: json['text'], isDone: json['isDone']);
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'isDone': isDone};
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<Task> _tasks = [];

  final TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? tasksJson = prefs.getStringList('tasks');
    if (tasksJson != null) {
      setState(() {
        _tasks.addAll(tasksJson.map((json) => Task.fromJson(jsonDecode(json))));
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> tasksJson = _tasks
        .map((task) => jsonEncode(task.toJson()))
        .toList();
    await prefs.setStringList('tasks', tasksJson);
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
                  if (newText.isNotEmpty) {
                    if (isEditing) {
                      task.text = newText;
                    } else {
                      _tasks.add(Task(text: newText));
                    }
                    _saveTasks();
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Lista de Tarefas'),
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
      body: _tasks.isEmpty
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
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: ListTile(
                      onTap: () {
                        setState(() {
                          task.isDone = !task.isDone;
                          _saveTasks();
                        });
                      },
                      leading: Checkbox(
                        value: task.isDone,
                        onChanged: (value) {
                          setState(() {
                            task.isDone = value!;
                            _saveTasks();
                          });
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
                              setState(() {
                                _tasks.removeAt(index);
                                _saveTasks();
                              });
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
