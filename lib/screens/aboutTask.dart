import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pexllite/constants.dart';
import 'package:pexllite/helpers/helper_functions.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pexllite/screens/welcome.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class AboutTaskScreen extends StatefulWidget {
  final String taskId;

  const AboutTaskScreen({Key? key, required this.taskId}) : super(key: key);

  @override
  _AboutTaskScreenState createState() => _AboutTaskScreenState();
}

class _AboutTaskScreenState extends State<AboutTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();

  String _priority = "Low";
  String _status = "Todo";
  DateTime? startDate;
  DateTime? dueDate;
  bool isLoading = false;
  String _token = '';
  final List<String> _priorityOptions = ["Low", "Normal", "Medium", "High", "Critical"];
  final List<String> _statusOptions = ["Todo", "Working", "Completed"];
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _wordsSpoken = "";

  @override
  void initState() {
    super.initState();
    _fetchTokenAndTaskDetails();
    initSpeech();
  }
  void initSpeech() async {
    bool speechEnabledResult = await _speechToText.initialize();
    setState(() {
      _speechEnabled = speechEnabledResult;
    });
  }


  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
  }


  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }


  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _wordsSpoken = result.recognizedWords;
      taskNameController.text = _wordsSpoken; // Add the recognized words to the TextField
    });
  }

  Future<void> _fetchTokenAndTaskDetails() async {
  
    try {
      final token = await HelperFunctions.getUserTokenSharedPreference();
      if (token != null && mounted) {
        setState(() => _token = token);
        await _fetchTaskDetails();
      } else {
        Fluttertoast.showToast(msg: "Authentication failed.");
        await Navigator.pushAndRemoveUntil(
          context,
         MaterialPageRoute(builder: (context) => WelcomeScreen()),
          (route) => false,
        );
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

  Future<void> _fetchTaskDetails() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('$baseurl/task/fetchtask?taskId=${widget.taskId}'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          taskNameController.text = data['taskName'];
          _priority = data['priority'];
          _status = data['status'];
          startDate = DateTime.fromMillisecondsSinceEpoch(data['startDate']);
          dueDate = DateTime.fromMillisecondsSinceEpoch(data['dueDate']);
          _startDateController.text = _dateFormatter.format(startDate!);
          _dueDateController.text = _dateFormatter.format(dueDate!);
        });
      } else {
        Fluttertoast.showToast(msg: "Failed to fetch task details.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching task details.");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _selectDate(TextEditingController controller, DateTime? initialDate) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        controller.text = _dateFormatter.format(date);
        if (controller == _startDateController) {
          startDate = date;
        } else {
          dueDate = date;
        }
      });
    }
  }

  Future<void> _updateTask() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        final response = await http.put(
          Uri.parse('$baseurl/task/update'),
          headers: {
            'Authorization': 'Bearer $_token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "taskId": widget.taskId,
            "taskName": taskNameController.text,
            "priority": _priority,
            "status": _status,
            "startDate": startDate?.millisecondsSinceEpoch,
            "dueDate": dueDate?.millisecondsSinceEpoch,
          }),
        );

        if (response.statusCode == 200) {
          Fluttertoast.showToast(msg: "Task updated successfully.");
          Navigator.pop(context, true); // Trigger refresh on task list
        } else {
          Fluttertoast.showToast(msg: "Failed to update task.");
        }
        
      } catch (e) {
        Fluttertoast.showToast(msg: "Error updating task.");
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Task',
           style: TextStyle(
              color: Colors.white,
            )
          ),
        backgroundColor: kPrimaryColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          TextFormField(
                            controller: taskNameController,
                            decoration: InputDecoration(
                              labelText: 'Task Name',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) => value!.isEmpty ? "Enter task name" : null,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_speechToText.isListening)
                                const Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    "listening...",
                                    style: TextStyle(color: Colors.red, fontSize: 12),
                                  ),
                                ),
                              IconButton(
                                icon: Icon(
                                  _speechToText.isListening ? Icons.mic : Icons.mic_none,
                                  color: _speechToText.isListening ? Colors.red : Colors.black,
                                ),
                                onPressed: _speechEnabled
                                    ? () {
                                        if (_speechToText.isListening) {
                                          _stopListening();
                                        } else {
                                          _startListening();
                                        }
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                      // TextFormField(
                      //   controller: taskNameController,
                      //   decoration: InputDecoration(
                      //       labelText: 'Task Name',
                      //       filled: true,
                      //       fillColor: Colors.white,
                      //       border: OutlineInputBorder(
                      //         borderRadius: BorderRadius.circular(12),
                      //       ),
                      //   ),
                      //   validator: (value) =>
                      //       value!.isEmpty ? "Task name cannot be empty" : null,
                      // ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: _priority,
                        items: _priorityOptions.map((priority) {
                          return DropdownMenuItem(
                            value: priority,
                            child: Text(priority),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() {
                          _priority = value!;
                        }),
                        decoration:  InputDecoration(
                          labelText: 'Priority',
                           filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: _status,
                        items: _statusOptions.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() {
                          _status = value!;
                        }),
                        decoration:  InputDecoration(
                          labelText: 'Status',
                           filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          
                          ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        readOnly: true,
                        controller: _startDateController,
                        decoration:  InputDecoration(
                          labelText: 'Start Date',
                           filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        onTap: () => _selectDate(_startDateController, startDate),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        readOnly: true,
                        controller: _dueDateController,
                        decoration: InputDecoration(
                          labelText: 'Due Date',
                           filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        onTap: () => _selectDate(_dueDateController, dueDate),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _updateTask,
                        child: const Text('Save Changes'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
