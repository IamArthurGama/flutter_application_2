import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_2/models/task.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? tasksJson = prefs.getStringList('tasks');

    if (tasksJson != null) {
      _tasks = tasksJson.map((json) => Task.fromJson(jsonDecode(json))).toList();

      notifyListeners();
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> tasksJson = _tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList('tasks', tasksJson);
  }

  void addTask(String text) {
    _tasks.add(Task(text: text)); 
    _saveTasks();
    notifyListeners();
  }

  void editTask(Task task, String newText) {
    task.text = newText;
    _saveTasks();
    notifyListeners();
  }

  void removeTask(Task task) {
    _tasks.remove(task);
    _saveTasks();
    notifyListeners();
  }

  void toggleTaskStatus(Task task) {
    task.isDone = !task.isDone;
    _saveTasks();
    notifyListeners();
  }
}