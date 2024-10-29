import 'package:flutter/material.dart';
import 'package:pexllite/constants.dart';
// import 'package:flutter_emoji_picker/flutter_emoji_picker.dart';

import 'package:pexllite/api_services/socket_service.dart';
import 'package:pexllite/api_services/message_api_service.dart';

class ChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const ChatScreen({Key? key, required this.groupId,required this.groupName}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _socketService = SocketService();
  final _apiService = MessageApiService();
  final TextEditingController _messageController = TextEditingController();
  bool isTyping = false;
  bool showPicker = false;
  List<String> messages = []; // Placeholder for messages

  @override
  void initState() {
    super.initState();
    _socketService.connect('USER_ID');
    // _socketService.joinRoom(widget.groupId);

    // _socketService.onTyping((_) {
    //   setState(() {
    //     isTyping = true;
    //   });
    // });

    // _socketService.onStopTyping((_) {
    //   setState(() {
    //     isTyping = false;
    //   });
    // });

    _fetchMessages();
  }

  void _fetchMessages() async {
     messages = await _apiService.fetchMessages(widget.groupId);
    // Update your UI state with the fetched messages.
  }

  void _sendMessage() async {
    String messageText = _messageController.text;
    if (messageText.isEmpty) return;

    var messageData = {
      'chatId': widget.groupId,
      'message': messageText,
    };
    var sentMessage = await _apiService.sendMessage(messageData);

    _socketService.sendMessage(sentMessage);
    _messageController.clear();
  }

  void _handleTyping() {
    // _socketService.sendTyping(widget.groupId);
    // Future.delayed(Duration(seconds: 3), () {
    //   _socketService.stopTyping(widget.groupId);
    // });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(widget.groupName),
      ),
      body: Column(
        children: [
          // Chat history
          Expanded(
            child: ListView.builder(
              reverse: true, // Displays the latest message at the bottom
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Align(
                    alignment: index % 2 == 0
                        ? Alignment.centerLeft
                        : Alignment.centerRight, // Alternate sender and receiver
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: index % 2 == 0 ? Colors.grey[300] : kPrimaryColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        messages[index],
                        style: TextStyle(
                          color: index % 2 == 0 ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Typing indicator
          if (isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("User is typing...", style: TextStyle(color: Colors.grey)),
              ),
            ),

          // Text input area with emoji picker
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onChanged: (value) {
                      setState(() {
                        isTyping = value.isNotEmpty;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                        icon: Icon(showPicker ? Icons.emoji_emotions : Icons.emoji_emotions_outlined),
                        onPressed: () {
                          setState(() {
                            showPicker = !showPicker;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: kPrimaryColor),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
          
          // Emoji picker
          // if (showPicker)
          //   EmojiPicker(
          //     onEmojiSelected: (emoji, category) {
          //       setState(() {
          //         _messageController.text += emoji.emoji;
          //       });
          //     },
          //   ),
        ],
      ),
    );
  }
}
