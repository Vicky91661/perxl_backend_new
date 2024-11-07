import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pexllite/constants.dart';
import 'package:pexllite/api_services/socket_service.dart';
import 'package:pexllite/api_services/message_api_service.dart';

class ChatScreen extends StatefulWidget {
  final String taskId;
  final String taskName;
  final String currentUserId;

  const ChatScreen({
    super.key,
    required this.taskId,
    required this.taskName,
    required this.currentUserId,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _socketService = SocketService();
  final _apiService = MessageApiService();
  final TextEditingController _messageController = TextEditingController();
  String? selectedFilePath; // Variable to store selected file path
  List<Map<String, dynamic>> messages = [];
  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'mp4'],
    );

    if (result != null) {
      setState(() {
        selectedFilePath = result.files.single.path; // Store selected file path
      });
    }
  }

  void _sendMessage() async {
    String messageText = _messageController.text;
    _messageController.clear();

    // If there's a message or file selected, proceed
    if(messageText.isNotEmpty){
      
    }
    if (messageText.isNotEmpty || selectedFilePath != null) {
      var messageData = {
        'taskId': widget.taskId,
        'message': messageText,
        'filePath': selectedFilePath, // Include file path if any
      };

      // Send message with file if applicable
      var sentMessage = await (selectedFilePath == null
          ? _apiService.sendMessage(messageData)
          : _apiService.sendFileMessage(messageData));

      setState(() {
        if (sentMessage != null) {
          messages.insert(0, sentMessage); // Add to message list
        }
        selectedFilePath = null; // Clear selected file after sending
      });
    }
  }

  void _fetchMessages() async {
    List<Map<String, dynamic>>? fetchedMessages =
        await _apiService.fetchMessages(widget.taskId);
    setState(() {
      messages = fetchedMessages ?? [];
    });
  }

  Widget _buildMessage(Map<String, dynamic> messageData) {
    final bool isCurrentUser =
        messageData['sender']['_id'] == widget.currentUserId;
    final sender = messageData['sender'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              backgroundImage: NetworkImage(sender['profilePic']),
              radius: 20,
            ),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: isCurrentUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (!isCurrentUser)
                Text(
                  "${sender['firstName']} ${sender['lastName']}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(12),
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7),
                decoration: BoxDecoration(
                  color: isCurrentUser ? kPrimaryColor : Colors.grey[300],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (messageData['message'] != null)
                      Text(
                        messageData['message'],
                        style: TextStyle(
                          color: isCurrentUser ? Colors.white : Colors.black,
                        ),
                      ),
                    if (messageData['fileUrl'] != null) // Display file link
                      GestureDetector(
                        onTap: () {
                          // Open the file link
                        },
                        child: Text(
                          '📎 File attachment',
                          style: TextStyle(
                              color: isCurrentUser ? Colors.white : Colors.blue),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (isCurrentUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(widget.taskName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(messages[index]);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            color: Colors.grey[200],
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: kPrimaryColor),
                  onPressed: _pickFile,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: selectedFilePath == null
                          ? "Type a message"
                          : "File selected. Tap send.",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: kPrimaryColor),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
