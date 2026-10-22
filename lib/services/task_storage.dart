import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskStorage {
  static const String _storageKey = 'task';

  Future<List <Task>> loadTask() async{
    final prefs = await SharedPreferences.getInstance();
    final JsonString = prefs.getString(_storageKey);

    if (JsonString == null){
      return[];
    }

    final List<dynamic> decodedList = jsonDecode(JsonString);

    return decodedList
      .map((item ) => Task.fromJson(item as Map<String, dynamic>))
      .toList();
  }

  Future<void> saveTask(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();

    final JsonString = jsonEncode(
      tasks.map((task) => task.toJson()).toList(),
    );

    await prefs.setString(_storageKey, JsonString);
  }
}
