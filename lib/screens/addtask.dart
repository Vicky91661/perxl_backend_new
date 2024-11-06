// import 'package:flutter/material.dart';
// import 'package:pexllite/constants.dart';
// import 'package:pexllite/helpers/database_helper.dart';
// import 'package:pexllite/model/task_model.dart';
// import 'package:intl/intl.dart';
// import 'package:fluttertoast/fluttertoast.dart';

// class AddTaskScreen extends StatefulWidget {
//   const AddTaskScreen({super.key});

//   @override
//   _AddTaskScreenState createState() => _AddTaskScreenState();
// }

// class _AddTaskScreenState extends State<AddTaskScreen> {
//   final _formKey = GlobalKey<FormState>();
//   String _title = '';
//   String? _priority;
//   DateTime _date = DateTime.now();
//   final TextEditingController _dateController = TextEditingController();
//   final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');

//   final List<String> _priorities = ["Low","Normal","Medium","High","Critical"];

//   @override
//   void initState() {
//     super.initState();

//     if (widget.task != null) {
//       _title = widget.task!.title;
//       _date = widget.task!.date;
//       _priority = widget.task!.priority;
//     }

//     _dateController.text = _dateFormatter.format(_date);
//   }

//   @override
//   void dispose() {
//     _dateController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleDatePicker() async {
//     final DateTime? date = await showDatePicker(
//       context: context,
//       initialDate: _date,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );
//     if (date != null && date != _date) {
//       setState(() {
//         _date = date;
//       });
//       _dateController.text = _dateFormatter.format(date);
//     }
//   }

//   Future<void> _delete() async {
//     if (widget.task != null) {
//       await DatabaseHelper.instance.deleteTask(widget.task!.id!); // Null safety
//       Navigator.pop(context);
//       widget.updateTaskList();
//       Fluttertoast.showToast(
//         msg: "Task Deleted",
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         backgroundColor: Colors.black,
//         textColor: Colors.white,
//       );
//     }
//   }

//   Future<void> _submit() async {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();

//       // Convert DateTime to Unix timestamp (milliseconds since epoch)
//       int startDateTimestamp = _date.millisecondsSinceEpoch;

//       // Assuming the due date is the same as `_date` for simplicity
//       int dueDateTimestamp = _date.millisecondsSinceEpoch;

//       // Construct task object with timestamps
//       Task task = Task(
//         title: _title,
//         date: DateTime.fromMillisecondsSinceEpoch(startDateTimestamp),
//         priority: _priority!,
//       );

//       // Use DatabaseHelper or API call to send `startDateTimestamp` and `dueDateTimestamp` to the backend
//       if (widget.task == null) {
//         task.status = 0;
//         await DatabaseHelper.instance.insertTask(task);  // Save new task
//       } else {
//         task.id = widget.task?.id;
//         task.status = widget.task?.status ?? 0;  // Update existing task
//         await DatabaseHelper.instance.updateTask(task);
//       }

//       Navigator.pop(context);
//       widget.updateTaskList();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: kPrimaryColor,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios, color: const Color.fromARGB(255, 254, 254, 254)),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           widget.task == null ? 'Add Task' : 'Update Task',
//           style: const TextStyle(
//             color: Color.fromARGB(255, 251, 250, 250),
//             fontSize: 20.0,
//             fontWeight: FontWeight.normal,
//           ),
//         ),
//         centerTitle: false,
//         elevation: 0,
//       ),
//       body: GestureDetector(
//         onTap: () => FocusScope.of(context).unfocus(),
//         child: SingleChildScrollView(
//           child: Container(
//             padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 40.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Padding(
//                     padding: EdgeInsets.symmetric(vertical: 20.0),
//                     child: TextFormField(
//                       style: TextStyle(fontSize: 18.0),
//                       decoration: InputDecoration(
//                         labelText: 'Title',
//                         labelStyle: TextStyle(fontSize: 18.0),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                       ),
//                       validator: (input) => (input?.trim().isEmpty ?? true) ? 'Please enter a task title' : null,
//                       onSaved: (input) => _title = input!,
//                       initialValue: _title,
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.symmetric(vertical: 20.0),
//                     child: TextFormField(
//                       readOnly: true,
//                       controller: _dateController,
//                       style: TextStyle(fontSize: 18.0),
//                       onTap: _handleDatePicker,
//                       decoration: InputDecoration(
//                         labelText: 'Date',
//                         labelStyle: TextStyle(fontSize: 18.0),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.symmetric(vertical: 20.0),
//                     child: DropdownButtonFormField<String>(
//                       isDense: true,
//                       icon: Icon(Icons.arrow_drop_down_circle),
//                       iconSize: 22.0,
//                       iconEnabledColor: Theme.of(context).primaryColor,
//                       items: _priorities.map((String priority) {
//                         return DropdownMenuItem(
//                           value: priority,
//                           child: Text(
//                             priority,
//                             style: TextStyle(color: Colors.black, fontSize: 18.0),
//                           ),
//                         );
//                       }).toList(),
//                       style: TextStyle(fontSize: 18.0),
//                       decoration: InputDecoration(
//                         labelText: 'Priority',
//                         labelStyle: TextStyle(fontSize: 18.0),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                       ),
//                       validator: (input) => _priority == null ? 'Please select a priority level' : null,
//                       onChanged: (value) {
//                         setState(() {
//                           _priority = value;
//                         });
//                       },
//                       value: _priority,
//                     ),
//                   ),
//                   Container(
//                     margin: EdgeInsets.symmetric(vertical: 20.0),
//                     height: 60.0,
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).primaryColor,
//                       borderRadius: BorderRadius.circular(30.0),
//                     ),
//                     child: TextButton(
//                       onPressed: _submit,
//                       child: Text(
//                         widget.task == null ? 'Add' : 'Update',
//                         style: TextStyle(color: Colors.white, fontSize: 20.0),
//                       ),
//                     ),
//                   ),
//                   if (widget.task != null)
//                     Container(
//                       margin: EdgeInsets.symmetric(vertical: 0.0),
//                       height: 60.0,
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: Theme.of(context).primaryColor,
//                         borderRadius: BorderRadius.circular(30.0),
//                       ),
//                       child: TextButton(
//                         onPressed: _delete,
//                         child: Text(
//                           'Delete',
//                           style: TextStyle(color: Colors.white, fontSize: 20.0),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
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
  final TextEditingController _dateController = TextEditingController();
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
      // Assume `HelperFunctions.getUserTokenSharedPreference` fetches the token correctly
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

  Future<void> _handleDatePicker(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      _dateController.text = _dateFormatter.format(date);
    }
  }

  Future<void> _submitTask() async {
    if (_formKey.currentState!.validate()) {
      // Parse date
      DateTime startDate;
      try {
        startDate = DateFormat('MMM dd, yyyy').parse(_dateController.text);
      } catch (e) {
        Fluttertoast.showToast(msg: "Invalid date format");
        return;
      }
      final dueDate = startDate.add(Duration(days: 7));

      // Prepare API call
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
          "groupId": widget.groupId // Replace with actual group ID
        }),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Task added successfully!");
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(
            msg: "Failed to add task. Status: ${response.statusCode}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Task"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Task Name'),
                validator: (value) => value!.isEmpty ? "Enter task name" : null,
              ),
              TextFormField(
                readOnly: true,
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Start Date'),
                onTap: () => _handleDatePicker(context),
              ),
              DropdownButtonFormField<String>(
                items: _priorities.map((priority) {
                  return DropdownMenuItem(
                      value: priority, child: Text(priority));
                }).toList(),
                onChanged: (value) => setState(() {
                  _priority = value!;
                }),
                decoration: const InputDecoration(labelText: 'Priority'),
                validator: (value) => value == null ? "Select priority" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
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
