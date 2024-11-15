import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io'; // Import to display image from file
import 'package:pexllite/constants.dart';
import 'package:pexllite/api_services/socket_service.dart';
import 'package:pexllite/api_services/message_api_service.dart';
import 'package:pexllite/screens/FilePreviewScreen.dart';
import 'package:http/http.dart' as http;
import 'package:pexllite/screens/MyPdfViewer.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:pdf_render/pdf_render_widgets.dart';

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
      String filePath = result.files.single.path!;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FilePreviewScreen(
            filePath: filePath,
            onSend: () => _sendFile(filePath),
          ),
        ),
      ).then((fileSent) {
        if (fileSent == true) {
          _fetchMessages(); // Refresh messages to display the sent file
        }
      });
    }
  }

  Future<void> _sendFile(String filePath) async {
    try {
      var messageData = {
        'taskId': widget.taskId,
        'filePath': filePath, // Include file path if any
      };
      var sentMessage = await _apiService.sendFileMessage(messageData);
      print(
          "Inside the chating Screen, The response from sendFileMessage is $sentMessage");
      setState(() {
        if (sentMessage != null) {
          messages.insert(0, sentMessage); // Add to message list
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading File: $e')),
      );
    }
  }

  void _sendMessage() async {
    String messageText = _messageController.text;
    _messageController.clear();

    // If there's a message or file selected, proceed
    if (messageText.isNotEmpty) {
      var messageData = {
        'taskId': widget.taskId,
        'message': messageText,
        'isMessage':true,
      };
      // Send message with file if applicable
      var sentMessage = await _apiService.sendMessage(messageData);
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
    final bool isCurrentUser = messageData['sender']['_id'] == widget.currentUserId;
    final sender = messageData['sender'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              backgroundImage: NetworkImage(sender['profilePic']),
              radius: 20,
            ),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
                padding:messageData['isMessage']? const EdgeInsets.all(12):const EdgeInsets.all(0),
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                decoration: BoxDecoration(
                  color: isCurrentUser ? kPrimaryColor : Colors.grey[300],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (messageData['isMessage'])
                      Text(
                        messageData['message'],
                        style: TextStyle(
                          color: isCurrentUser ? Colors.white : Colors.black,
                        ),
                      ),
                    if (!messageData['isMessage'])
                      _buildFileWidget(messageData['message']),
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
  Widget _buildFileWidget(String fileUrl) {
    if (fileUrl.endsWith('.jpg') || fileUrl.endsWith('.jpeg') || fileUrl.endsWith('.png')) {
      return Image.network(
        fileUrl,
        height: 320, // Adjust as needed
        fit: BoxFit.cover,
      );
    } else if (fileUrl.endsWith('.mp4')) {
      return _buildVideoPlayer(fileUrl);
    } else if (fileUrl.endsWith('.pdf')) {
      return GestureDetector(
        onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyPdfViewer(pdfUrl: fileUrl),
          ),
        );
      },
        child: Text(
          '📎 PDF Attachment',
          style: TextStyle(color: Colors.blue),
        ),
      );
    } else {
      return Text('Unsupported file type');
    }
  }

  Widget _buildVideoPlayer(String videoUrl) {
    VideoPlayerController _controller = VideoPlayerController.network(videoUrl);
    return FutureBuilder(
      future: _controller.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
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
          if (selectedFilePath != null) // Show preview if an image is selected
            Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  if (selectedFilePath!.endsWith('.jpg') ||
                      selectedFilePath!.endsWith('.jpeg') ||
                      selectedFilePath!.endsWith('.png'))
                    Image.file(
                      File(selectedFilePath!),
                      height: 500,
                      fit: BoxFit.cover,
                    ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "File selected. Tap send to proceed.",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            selectedFilePath = null;
                          });
                        },
                      ),
                    ],
                  ),
                ],
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
