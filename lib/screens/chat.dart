import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io'; // Import to display image from file
import 'package:pexllite/constants.dart';
import 'package:pexllite/api_services/message_api_service.dart';
import 'package:pexllite/screens/FilePreviewScreen.dart';
import 'package:pexllite/screens/FullScreenImageViewer.dart';
import 'package:pexllite/screens/MyPdfViewer.dart';
import 'package:pexllite/screens/audioPlayer.dart';
import 'package:pexllite/utils/CompressImage.dart';
import 'package:video_player/video_player.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_sound/flutter_sound.dart'; // Audio recording package
import 'package:permission_handler/permission_handler.dart'; // For permissions
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

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
  late IO.Socket _socket;
  final _apiService = MessageApiService();
  final TextEditingController _messageController = TextEditingController();
  String? selectedFilePath; // Variable to store selected file path
  List<Map<String, dynamic>> messages = [];
  bool isTyping = false;
  bool _isDisposed = false; // To track if the widget is disposed
  bool _isUploading = false; // State variable to track uploading status

  // Variables for audio recording
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  String? _audioFilePath;
  bool showIcons = true; // State variable to control the visibility of icons
  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _initializeSocket();
    _initializeRecorder();
    // Add listener to detect changes in the text field
    _messageController.addListener(() {
      setState(() {
        showIcons = _messageController.text.isEmpty;
      });
    });
  }

  Future<void> _initializeRecorder() async {
    _recorder = FlutterSoundRecorder();
    await _recorder!.openRecorder();
    if (await Permission.microphone.request().isGranted) {
      print("Microphone permission granted");
    } else {
      print("Microphone permission denied");
    }
  }

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
    });
    _audioFilePath = '${Directory.systemTemp.path}/audio_message.aac';
    await _recorder!.startRecorder(toFile: _audioFilePath);
  }

  Future<void> _stopRecording() async {
    await _recorder!.stopRecorder();
    setState(() {
      _isRecording = false;
    });

    if (_audioFilePath != null) {
      _sendAudioMessage(_audioFilePath!);
    }
  }

  Future<void> _sendAudioMessage(String filePath) async {
    try {
      setState(() {
        _isUploading = true;
      });
      var messageData = {
        'taskId': widget.taskId,
        'filePath': filePath,
        'isAudio': true,
      };
      var sentMessage = await _apiService.sendFileMessage(messageData);
      print("Audio message sent: $sentMessage");
      if (!_isDisposed) {
        setState(() {
          _isUploading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      if (!_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending audio: $e')),
        );
      }
    }
  }

  void _initializeSocket() {
    _socket = IO.io(serverurl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket.onConnect((_) {
      print('Connected to server');
      _socket.emit('joinRoom', widget.taskId);
    });

    _socket.on('newMessage', (data) {
      print("The message received is $data");
      if (mounted) {
        setState(() {
          messages.insert(0, data);
        });
      }
    });

    _socket.onDisconnect((_) {
      print('Disconnected from server');
    });
  }

  bool _isFilePickerActive = false;
  Future<void> _pickFile() async {
    if (_isFilePickerActive) {
      // Prevent multiple simultaneous calls
      return;
    }
    _isFilePickerActive = true;
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'], // 'mp4'
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
          if (fileSent == true && mounted) {
            _fetchMessages(); // Refresh messages to display the sent file
          }
        });
      }
    } finally {
      _isFilePickerActive = false;
    }
  }

  bool isImageFile(String filePath) {
    final imageExtensions = [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'bmp',
      'webp',
      'tiff'
    ];
    final extension = filePath.split('.').last.toLowerCase();
    return imageExtensions.contains(extension);
  }

  Future<void> _sendFile(String filePath) async {
    try {
      var messageData;
      // Compress the image file
      File originalFile = File(filePath);
      if (isImageFile(filePath)) {
        // Compress the image file
        XFile? compressedImage = await compressImage(originalFile);
        if (compressedImage == null) {
          throw Exception("Failed to compress image.");
        }
        messageData = {
          'taskId': widget.taskId,
          'filePath': compressedImage.path, // Include file path if any
        };
      } else {
        messageData = {
          'taskId': widget.taskId,
          'filePath': filePath, // Include file path if any
        };
      }
      setState(() {
        _isUploading = true; // Show loader during file upload
      });

      var sentMessage = await _apiService.sendFileMessage(messageData);

      print(
          "Inside the chating Screen, The response from sendFileMessage is $sentMessage");

      if (!_isDisposed && mounted) {
        setState(() {
          _isUploading = false; // Hide loader after upload completes
        });
      }
    } catch (e) {
      setState(() {
        _isUploading = false; // Ensure loader is hidden if an error occurs
      });

      if (!_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading File: $e')),
        );
      }
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
        'isMessage': true,
      };
      // Send message with file if applicable
      var sentMessage = await _apiService.sendMessage(messageData);
      setState(() {
        // if (sentMessage != null) {
        //   messages.insert(0, sentMessage); // Add to message list
        // }
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

  Future<void> _openCameraAndCapturePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      String filePath = photo.path;
      // Navigate to preview or directly send the photo
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FilePreviewScreen(
            filePath: filePath,
            onSend: () => _sendFile(filePath),
          ),
        ),
      ).then((fileSent) {
        if (fileSent == true && mounted) {
          _fetchMessages(); // Refresh messages after sending
        }
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true; // Mark as disposed
    _recorder?.closeRecorder();
    _messageController.dispose();
    _socket.dispose();
    super.dispose();
  }

  Widget _buildMessage(Map<String, dynamic> messageData) {
    final bool isCurrentUser =
        messageData['sender']['_id'] == widget.currentUserId;
    final sender = messageData['sender'];
    // Parse the timestamp from the message data
    final DateTime messageTime = DateTime.parse(messageData['createdAt']).toLocal();
    String formattedTime = DateFormat('hh:mm a').format(messageTime);
    // print("The Time is $formattedTime");

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
                padding:const EdgeInsets.all(8),
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7),
                decoration: BoxDecoration(
                  color: isCurrentUser ? const Color.fromARGB(202, 124, 77, 255) : Colors.grey[300],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Add timestamp here
                    Text(
                      formattedTime,
                      style: TextStyle(
                        fontSize: 12,
                        color: isCurrentUser ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(
                        height:
                            4), // Add some space between timestamp and message
                    if (messageData['isMessage'])
                      Text(
                        messageData['message'],
                        style: TextStyle(
                          color: isCurrentUser ? Colors.white : Colors.black,
                        )
                        ,
                      
                      ),
                    if (!messageData['isMessage']) ...[
                      const SizedBox(height: 8), // Padding before file widget
                      _buildFileWidget(messageData['message']),
                    ],
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

  Widget _buildFileWidget(
      String fileUrl) {
    if (fileUrl.endsWith('.jpg') ||
        fileUrl.endsWith('.jpeg') ||
        fileUrl.endsWith('.png')) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullScreenImageViewer(imageUrl: fileUrl),
            ),
          );
        },
        child: Image.network(
          fileUrl,
          height: 320, // Adjust as needed for preview
          fit: BoxFit.cover,
        ),
      );
    } else if (fileUrl.endsWith('.mp4')) {
      return _buildVideoPlayer(fileUrl);
    } else if (fileUrl.endsWith('.aac') ||
        fileUrl.endsWith('.aiff') ||
        fileUrl.endsWith('.amr') ||
        fileUrl.endsWith('.flac') | fileUrl.endsWith('.m4a') ||
        fileUrl.endsWith('.mp3') ||
        fileUrl.endsWith('.ogg') ||
        fileUrl.endsWith('.opus') ||
        fileUrl.endsWith('.wav')) {
      return AudioPlayerWidget(audioUrl: fileUrl);
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
        child: Container(
          width: 145, // Set width for PDF preview
          height: 50, // Set height for PDF preview
          decoration: BoxDecoration(
            color: Colors.grey[200], // Light gray background
            borderRadius: BorderRadius.circular(10), // Rounded corners
            border: Border.all(color: Colors.grey, width: 1), // Border styling
          ),
          alignment: Alignment.center, // Center content inside the container
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center, // Center the content horizontally
            children: [
              Icon(
                Icons.picture_as_pdf,
                size: 30,
                color: Colors.red, // PDF icon color
              ),
              const SizedBox(width: 8), // Add space between the icon and text
              Text(
                'PDF File',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ],
          ),
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
        title: Text(
          widget.taskName,
          style: TextStyle(color: Colors.white),
        ),
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
          if (_isUploading) // Show loader when a file is being uploaded
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  CircularProgressIndicator(
                    color: kPrimaryColor,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Uploading...",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
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
                if (showIcons)
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: kPrimaryColor),
                    onPressed: _openCameraAndCapturePhoto,
                  ),
                if (showIcons)
                  IconButton(
                    icon: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: _isRecording ? Colors.red : kPrimaryColor,
                    ),
                    onPressed: _isRecording ? _stopRecording : _startRecording,
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
