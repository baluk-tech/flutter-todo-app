import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: MainApp());
  }
}

class MainApp extends StatefulWidget {
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  List<String> taskList = [];
  List<bool> checkedList = [];
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData(); // 🔹 Load saved data when app starts
  }

  /// Save data to SharedPreferences
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("tasks", jsonEncode(taskList));
    prefs.setString("checked", jsonEncode(checkedList));
  }

  /// Load data from SharedPreferences
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    String? tasks = prefs.getString("tasks");
    String? checked = prefs.getString("checked");

    if (tasks != null && checked != null) {
      setState(() {
        taskList = List<String>.from(jsonDecode(tasks));
        checkedList = List<bool>.from(jsonDecode(checked));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo list app"),
        backgroundColor: Colors.blue,
        centerTitle: false,
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Enter a task"),
                    ),
                  ),
                ),
              ),
              MaterialButton(
                color: Colors.white,
                height: 50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onPressed: () {
                  if (textController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Type something to create list"),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    setState(() {
                      checkedList.add(false);
                      taskList.add(textController.text.trim());
                      textController.clear();
                      saveData(); // 🔹 Save after adding
                    });
                  }
                },
                child: Text("Add"),
              ),
            ],
          ),
          Flexible(
            child: taskList.isEmpty
                ? Center(
                    child: Text(
                      "No data found !",
                      style: TextStyle(fontSize: 30, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: taskList.length,
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          Checkbox(
                            value: checkedList[index],
                            onChanged: (newValue) {
                              setState(() {
                                checkedList[index] = newValue!;
                                saveData(); // 🔹 Save after checkbox update
                              });
                            },
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                taskList[index],
                                style: TextStyle(
                                  decoration: checkedList[index]
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                            ),
                          ),
                          MaterialButton(
                            child: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                taskList.removeAt(index);
                                checkedList.removeAt(index);
                                saveData(); // 🔹 Save after delete
                              });
                            },
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
