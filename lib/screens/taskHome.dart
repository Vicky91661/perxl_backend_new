import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pexllite/constants.dart';
import 'package:pexllite/helpers/helper_functions.dart';
import 'package:pexllite/screens/addtask.dart';
import 'package:pexllite/screens/welcome.dart';

class TaskHomeScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const TaskHomeScreen({
    Key? key,
    required this.groupId,
    required this.groupName,
  }) : super(key: key);

  @override
  _TaskHomeScreenState createState() => _TaskHomeScreenState();
}

class _TaskHomeScreenState extends State<TaskHomeScreen> {
  String _token = '';
  bool isLoading = false;
  List<dynamic> tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchToken();
  }

  Future<void> _fetchToken() async {
    try {
      String? token = await HelperFunctions.getUserTokenSharedPreference();
      if (token != null && mounted) {
        setState(() {
          _token = token;
        });
        _fetchTasks();
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Invalid User");
      await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _fetchTasks() async {
    try {
      setState(() => isLoading = true);
      final response = await http.get(
        Uri.parse('$baseurl/task/fetchalltasks?groupId=${widget.groupId}'),
        headers: {
          'authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        }
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() => tasks = responseData);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching tasks: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  String formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add_outlined),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddTaskScreen(groupId:widget.groupId)),
        ),
      ),
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(widget.groupName),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
              ? const Center(child: Text("No tasks available"))
              : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text(
                          task['taskName'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row([])
                            Text("Priority: ${task['priority']}"),
                            Text("Status: ${task['status']}"),
                            Text("Start Date: ${formatDate(task['startDate'])}"),
                            Text("Due Date: ${formatDate(task['dueDate'])}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

//   Future<bool> onBackPressed() {
//     SystemNavigator.pop();
//     return Future.value(true);
//   }

//   Widget _buildTask(Map<String, dynamic> taskData) {
//     int taskStatus = taskData['status'] ?? 0;

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 25.0),
//       child: Column(
//         children: <Widget>[
//           if (taskStatus == 0)
//             ListTile(
//               title: Text(
//                 taskData['title'] ?? 'No Title',
//                 style: TextStyle(
//                   fontSize: 18.0,
//                   decoration: taskStatus == 0
//                       ? TextDecoration.none
//                       : TextDecoration.lineThrough,
//                 ),
//               ),
//               subtitle: Text(
//                 '${_dateFormatter.format(DateTime.parse(taskData['date']))} • ${taskData['priority'] ?? 'No Priority'}',
//                 style: TextStyle(
//                   fontSize: 15.0,
//                   decoration: taskStatus == 0
//                       ? TextDecoration.none
//                       : TextDecoration.lineThrough,
//                 ),
//               ),
//               trailing: Checkbox(
//                 onChanged: (value) {
//                   int newStatus = (value ?? false) ? 1 : 0;
//                   DatabaseHelper.instance
//                       .updateTaskStatus(taskData['id'], newStatus);
//                   Fluttertoast.showToast(
//                     msg:
//                         (value ?? false) ? "Task Completed" : "Task Reassigned",
//                     toastLength: Toast.LENGTH_SHORT,
//                     gravity: ToastGravity.BOTTOM,
//                     backgroundColor: Colors.black,
//                     textColor: Colors.white,
//                   );
//                 },
//                 activeColor: Colors.redAccent,
//                 value: taskStatus == 1,
//               ),
//               onTap: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => AddTaskScreen(
//                     taskId: taskData['id'],
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: onBackPressed,
//       child: Scaffold(
//         floatingActionButton: FloatingActionButton(
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.black,
//           child: const Icon(Icons.add_outlined),
//           onPressed: () => Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => AddTaskScreen(),
//             ),
//           ),
//         ),
//         appBar: AppBar(
//           backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
//           title: Row(
//             children: const [
//               Text(
//                 "Task",
//                 style: TextStyle(
//                   color: Colors.redAccent,
//                   fontSize: 23.0,
//                   fontWeight: FontWeight.normal,
//                   letterSpacing: -1.2,
//                 ),
//               ),
//               Text(
//                 " Manager",
//                 style: TextStyle(
//                   color: Colors.redAccent,
//                   fontSize: 23.0,
//                   fontWeight: FontWeight.normal,
//                   letterSpacing: 0,
//                 ),
//               )
//             ],
//           ),
//           centerTitle: false,
//           elevation: 0,
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.history_outlined),
//               iconSize: 25.0,
//               color: Colors.black,
//               onPressed: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => HistoryScreen()),
//               ),
//             ),
//             IconButton(
//               icon: const Icon(Icons.settings_outlined),
//               iconSize: 25.0,
//               color: Colors.black,
//               onPressed: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => Settings()),
//               ),
//             ),
//           ],
//         ),
//         body: FutureBuilder<List<Map<String, dynamic>>>(
//           future: DatabaseHelper.instance.getTaskList(),
//           builder: (context, snapshot) {
//             if (!snapshot.hasData) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             final int completedTaskCount = snapshot.data!
//                 .where((taskData) => taskData['status'] == 0)
//                 .toList()
//                 .length;

//             return ListView.builder(
//               padding: const EdgeInsets.symmetric(vertical: 0.0),
//               itemCount: 1 + snapshot.data!.length,
//               itemBuilder: (BuildContext context, int index) {
//                 if (index == 0) {
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 0.0, vertical: 0.0),
//                     child: Container(
//                       margin: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
//                       padding: const EdgeInsets.all(10.0),
//                       decoration: BoxDecoration(
//                         shape: BoxShape.rectangle,
//                         color: const Color.fromRGBO(240, 240, 240, 1.0),
//                         borderRadius: BorderRadius.circular(10.0),
//                       ),
//                       child: Center(
//                         child: Text(
//                           'You have $completedTaskCount pending tasks out of ${snapshot.data!.length}',
//                           style: const TextStyle(
//                             color: Colors.blueGrey,
//                             fontSize: 15.0,
//                             fontWeight: FontWeight.normal,
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 }
//                 return _buildTask(snapshot.data![index - 1]);
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
