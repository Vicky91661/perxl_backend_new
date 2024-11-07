import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pexllite/constants.dart';
import 'package:pexllite/helpers/helper_functions.dart';

class AddTaskScreen extends StatefulWidget {
  final String groupId;

  const AddTaskScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  String _priority = '';
  String _token = '';
  final List<String> _priorities = [
    "Low",
    "Normal",
    "Medium",
    "High",
    "Critical"
  ];
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    super.initState();
    _fetchToken();
  }

  Future<void> _fetchToken() async {
    try {
      final token = await HelperFunctions.getUserTokenSharedPreference();
      if (token != null && mounted) {
        setState(() {
          _token = token;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Invalid User");
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  Future<void> _handleStartDatePicker() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      _startDateController.text = _dateFormatter.format(date);
    }
  }

  Future<void> _handleDueDatePicker() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      _dueDateController.text = _dateFormatter.format(date);
    }
  }

  Future<void> _submitTask() async {
    if (_formKey.currentState!.validate()) {
      try {
        final startDate = _dateFormatter.parse(_startDateController.text);
        final dueDate = _dateFormatter.parse(_dueDateController.text);

        final response = await http.post(
          Uri.parse('$baseurl/task/createtask'),
          headers: {
            'authorization': 'Bearer $_token',
            'Content-Type': 'application/json'
          },
          body: json.encode({
            "taskName": _titleController.text,
            "priority": _priority,
            "startDate": startDate.toIso8601String(),
            "dueDate": dueDate.toIso8601String(),
            "groupId": widget.groupId
          }),
        );

        if (response.statusCode == 200) {
          Fluttertoast.showToast(msg: "Task added successfully!");
           Navigator.pop(context, true);  // Return true after successful task addition
        } else {
          Fluttertoast.showToast(
              msg: "Failed to add task. Status: ${response.statusCode}");
        }
      } catch (e) {
        Fluttertoast.showToast(msg: "Error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Task"),
        backgroundColor: kPrimaryColor,
      ),
      body: Padding(
  
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Task Name'),
                validator: (value) => value!.isEmpty ? "Enter task name" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                readOnly: true,
                controller: _startDateController,
                decoration: const InputDecoration(labelText: 'Start Date'),
                onTap: () => _handleStartDatePicker(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                readOnly: true,
                controller: _dueDateController,
                decoration: const InputDecoration(labelText: 'Due Date'),
                onTap: () => _handleDueDatePicker(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                items: _priorities.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority),
                  );
                }).toList(),
                onChanged: (value) => setState(() {
                  _priority = value!;
                }),
                decoration: const InputDecoration(labelText: 'Priority'),
                validator: (value) => value == null ? "Select priority" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                // style: Color(Color.fromARGB(0, 0, 255,0)),
                onPressed: _submitTask,
                child: const Text("Submit Task"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
