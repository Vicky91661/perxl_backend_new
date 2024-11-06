// import 'package:flutter/material.dart';
import 'package:pexllite/constants.dart';
// // import 'package:flutter_emoji_picker/flutter_emoji_picker.dart';

import 'package:pexllite/api_services/socket_service.dart';
import 'package:pexllite/api_services/message_api_service.dart';

// class ChatScreen extends StatefulWidget {
//   final String groupId;
//   final String groupName;

//   const ChatScreen({super.key, required this.groupId,required this.groupName});

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final _socketService = SocketService();
//   final _apiService = MessageApiService();
//   final TextEditingController _messageController = TextEditingController();
//   bool isTyping = false;
//   bool showPicker = false;
//   List<String> messages = []; // Placeholder for messages

//   @override
//   void initState() {
//     super.initState();
//     // _socketService.connect('USER_ID');
//     // _socketService.joinRoom(widget.groupId);

//     // _socketService.onTyping((_) {
//     //   setState(() {
//     //     isTyping = true;
//     //   });
//     // });

//     // _socketService.onStopTyping((_) {
//     //   setState(() {
//     //     isTyping = false;
//     //   });
//     // });

//     _fetchMessages();
//   }

//   void _fetchMessages() async {
//      messages = await _apiService.fetchMessages(widget.groupId);
//     // Update your UI state with the fetched messages.
//   }

//   void _sendMessage() async {
//     String messageText = _messageController.text;
//     if (messageText.isEmpty) return;

//     var messageData = {
//       'groupId': widget.groupId,
//       'message': messageText,
//     };
//     var sentMessage = await _apiService.sendMessage(messageData);

//     // _socketService.sendMessage(sentMessage);
//     // _messageController.clear();
//   }

//   void _handleTyping() {
//     // _socketService.sendTyping(widget.groupId);
//     // Future.delayed(Duration(seconds: 3), () {
//     //   _socketService.stopTyping(widget.groupId);
//     // });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: kPrimaryColor,
//         title: Text(widget.groupName),
//       ),
//       body: Column(
//         children: [
//           // Chat history
//           Expanded(
//             child: ListView.builder(
//               reverse: true, // Displays the latest message at the bottom
//               itemCount: messages.length,
//               itemBuilder: (context, index) {
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//                   child: Align(
//                     alignment: index % 2 == 0
//                         ? Alignment.centerLeft
//                         : Alignment.centerRight, // Alternate sender and receiver
//                     child: Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: index % 2 == 0 ? Colors.grey[300] : kPrimaryColor,
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       child: Text(
//                         messages[index],
//                         style: TextStyle(
//                           color: index % 2 == 0 ? Colors.black : Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),

//           // Typing indicator
//           if (isTyping)
//             Padding(
//               padding: const EdgeInsets.only(left: 15.0),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text("User is typing...", style: TextStyle(color: Colors.grey)),
//               ),
//             ),

//           // Text input area with emoji picker
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
//             color: Colors.grey[200],
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     onChanged: (value) {
//                       setState(() {
//                         isTyping = value.isNotEmpty;
//                       });
//                     },
//                     decoration: InputDecoration(
//                       hintText: "Type a message",
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(20),
//                         borderSide: BorderSide.none,
//                       ),
//                       filled: true,
//                       fillColor: Colors.white,
//                       suffixIcon: IconButton(
//                         icon: Icon(showPicker ? Icons.emoji_emotions : Icons.emoji_emotions_outlined),
//                         onPressed: () {
//                           setState(() {
//                             showPicker = !showPicker;
//                           });
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   icon: const Icon(Icons.send, color: kPrimaryColor),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:pexllite/constants.dart';

class ChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String currentUserId;

  const ChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.currentUserId,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _socketService = SocketService();
  final _apiService = MessageApiService();
  bool isTyping = false;
  bool showPicker = false;
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> messages =
      []; // To store the message objects from API

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  void _sendMessage() async {
    String messageText = _messageController.text;
    if (messageText.isEmpty) return;

    var messageData = {
      'groupId': widget.groupId,
      'message': messageText,
    };
    var sentMessage = await _apiService.sendMessage(messageData);

    // _socketService.sendMessage(sentMessage);
    // _messageController.clear();
  }

  void _handleTyping() {
    // _socketService.sendTyping(widget.groupId);
    // Future.delayed(Duration(seconds: 3), () {
    //   _socketService.stopTyping(widget.groupId);
    // });
  }

  void _fetchMessages() async {
    // Fetch messages from the API
    print("the group id of the group is ${widget.groupId}");
    List<Map<String, dynamic>>? fetchedMessages =
        await _apiService.fetchMessages(widget.groupId);
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
                child: Text(
                  messageData['message'],
                  style: TextStyle(
                    color: isCurrentUser ? Colors.white : Colors.black,
                  ),
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
        title: Text(widget.groupName),
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
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message",
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
