// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:intl/intl.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:pexllite/constants.dart';
// import 'package:pexllite/helpers/helper_functions.dart';
// import 'package:pexllite/screens/aboutTask.dart';
// import 'package:pexllite/screens/addtask.dart';
// import 'package:pexllite/screens/chat.dart';
// import 'package:pexllite/screens/welcome.dart';

// class TaskHomeScreen extends StatefulWidget {
//   final String groupId;
//   final String groupName;

//   const TaskHomeScreen({
//     Key? key,
//     required this.groupId,
//     required this.groupName,
//   }) : super(key: key);

//   @override
//   _TaskHomeScreenState createState() => _TaskHomeScreenState();
// }

// class _TaskHomeScreenState extends State<TaskHomeScreen> {
//   String _token = '';
//   bool isLoading = false;
//   List<dynamic> tasks = [];
//   String _currentUserId = '';

//   @override
//   void initState() {
//     super.initState();
//     _fetchTokenandUserId();
//   }

//   Future<void> _fetchTokenandUserId() async {
//     try {
//       String? token = await HelperFunctions.getUserTokenSharedPreference();
//       String? currentUserid = await HelperFunctions.getUserIdSharedPreference();
//       if (token != null && currentUserid != null && mounted) {
//         setState(() {
//           _token = token;
//           _currentUserId = currentUserid;
//         });
//         _fetchTasks();
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Invalid User");
//       await Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (context) => WelcomeScreen()),
//         (route) => false,
//       );
//     }
//   }

//   Future<void> _fetchTasks() async {
//     try {
//       setState(() => isLoading = true);
//       final response = await http.get(
//         Uri.parse('$baseurl/task/fetchalltasks?groupId=${widget.groupId}'),
//         headers: {
//           'authorization': 'Bearer $_token',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         setState(() => tasks = responseData);
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Error fetching tasks: $e");
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> _deleteTask(String taskId) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('$baseurl/task/deletetask'),
//         headers: {
//           'authorization': 'Bearer $_token',
//           'Content-Type': 'application/json',
//         },
//         body: json.encode({"taskId": taskId}),
//       );

//       final responseData = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         setState(() {
//           tasks.removeWhere((task) => task['_id'] == taskId);
//         });
//         Fluttertoast.showToast(msg: responseData['message']);
//       } else {
//         Fluttertoast.showToast(
//           msg: "Failed to delete task: ${responseData['message']}",
//         );
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Error deleting task: $e");
//     }
//   }

//   String formatDate(int timestamp) {
//     final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
//     return DateFormat('MMM dd, yyyy').format(date);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         child: const Icon(Icons.add_outlined),
//         onPressed: () async {
//           final result = await Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (_) => AddTaskScreen(groupId: widget.groupId)),
//           );

//           // Refresh task list if result is true
//           if (result == true) {
//             _fetchTasks();
//           }
//         },
//       ),
//       appBar: AppBar(
//         backgroundColor: kPrimaryColor,
//         title: Text(widget.groupName),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : tasks.isEmpty
//               ? const Center(child: Text("No tasks available"))
//               : ListView.builder(
//                   itemCount: tasks.length,
//                   itemBuilder: (context, index) {
//                     final task = tasks[index];
//                     return Card(
//                       margin: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 8,
//                       ),
//                       child: ListTile(
//                          onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => ChatScreen(
//                                 taskId: task['_id'],
//                                 taskName: task['taskName'],
//                                 currentUserId: _currentUserId,
//                               ),
//                             ),
//                           );
//                         },
//                         title: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               task['taskName'].toUpperCase(),
//                               style: const TextStyle(
//                                   fontWeight: FontWeight.bold, fontSize: 16),
//                             ),
//                             Row(
//                               children: [
//                                 IconButton(
//                                   icon: const Icon(Icons.edit,
//                                       color: Colors.blue),
//                                   onPressed: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (_) => AboutTaskScreen(
//                                               taskId: task['_id'])),
//                                     );
//                                   },
//                                 ),
//                                 IconButton(
//                                   icon: const Icon(Icons.delete,
//                                       color: Colors.red),
//                                   onPressed: () => _deleteTask(task['_id']),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Row(children: [
//                                   const Text("Priority: ",
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.bold)),
//                                   Text(
//                                     '${task['priority']}',
//                                     style: const TextStyle(
//                                         fontWeight: FontWeight.w400),
//                                   ),
//                                 ]),
//                                 Row(children: [
//                                   const Text("Start Date: ",
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.bold)),
//                                   Text(
//                                     formatDate(task['startDate']),
//                                     style: const TextStyle(
//                                         fontWeight: FontWeight.w400),
//                                   ),
//                                 ]),
//                               ],
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Row(children: [
//                                   const Text("Status: ",
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.bold)),
//                                   Text(
//                                     '${task['status']}',
//                                     style: const TextStyle(
//                                         fontWeight: FontWeight.w400),
//                                   ),
//                                 ]),
//                                 Row(children: [
//                                   const Text("Due Date: ",
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.bold)),
//                                   Text(
//                                     formatDate(task['dueDate']),
//                                     style: const TextStyle(
//                                         fontWeight: FontWeight.w400),
//                                   ),
//                                 ]),
//                               ],
//                             ),
//                             Row(
//                               children: [
//                                 CircleAvatar(
//                                   backgroundImage: NetworkImage(
//                                     task['createrId']['profilePic'] ??
//                                         'https://via.placeholder.com/150',
//                                   ),
//                                   radius: 16,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   "Created by: ${task['createrId']['firstName']} ${task['createrId']['lastName']}",
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pexllite/constants.dart';
import 'package:pexllite/helpers/helper_functions.dart';
import 'package:pexllite/screens/aboutTask.dart';
import 'package:pexllite/screens/addtask.dart';
import 'package:pexllite/screens/chat.dart';
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
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _fetchTokenandUserId();
  }

  Future<void> _fetchTokenandUserId() async {
    try {
      String? token = await HelperFunctions.getUserTokenSharedPreference();
      String? currentUserid = await HelperFunctions.getUserIdSharedPreference();
      print("THe toekn and the cureent user id is $token and $currentUserid");
      if (token != null && currentUserid != null && mounted) {
        setState(() {
          _token = token;
          _currentUserId = currentUserid;
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
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() => tasks = responseData);
      } else {
        Fluttertoast.showToast(msg: "Failed to fetch tasks");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching tasks: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseurl/task/deletetask'),
        headers: {
          'authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: json.encode({"taskId": taskId}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          tasks.removeWhere((task) => task['_id'] == taskId);
        });
        Fluttertoast.showToast(msg: responseData['message']);
      } else {
        Fluttertoast.showToast(
          msg: "Failed to delete task: ${responseData['message']}",
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error deleting task: $e");
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
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AddTaskScreen(groupId: widget.groupId)),
          );

          // Refresh task list if result is true
          if (result == true) {
            _fetchTasks();
          }
        },
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
                    final userProfilePic = task['createrId']['profilePic'] ??
                        'https://via.placeholder.com/150';
                    final userFirstName = task['createrId']['firstName'];
                    final userLastName = task['createrId']['lastName'];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                taskId: task['_id'],
                                taskName: task['taskName'],
                                currentUserId: _currentUserId,
                              ),
                            ),
                          );
                        },
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                           Expanded(
                              child: Text(
                                task['taskName'].toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                overflow: TextOverflow.ellipsis, // Adds "..." at the end if too long
                                maxLines: 1, // Limits to one line
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => AboutTaskScreen(
                                              taskId: task['_id'])),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _deleteTask(task['_id']),
                                ),
                              ],
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  const Text("Priority: ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                    '${task['priority']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w400),
                                  ),
                                ]),
                                Row(children: [
                                  const Text("Start Date: ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                    formatDate(task['startDate']),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w400),
                                  ),
                                ]),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  const Text("Status: ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                    '${task['status']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w400),
                                  ),
                                ]),
                                Row(children: [
                                  const Text("Due Date: ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                    formatDate(task['dueDate']),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w400),
                                  ),
                                ]),
                              ],
                            ),
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(userProfilePic),
                                  radius: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Created by: $userFirstName $userLastName",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
