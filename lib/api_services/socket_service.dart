// import 'package:socket_io_client/socket_io_client.dart' as IO;

// class SocketService {
//   late IO.Socket socket;
//   final String baseUrl = 'http://localhost:3500';

//   void connect(String userId) {
//     socket = IO.io(
//       baseUrl,
//       IO.OptionBuilder()
//           .setTransports(['websocket']).setQuery({'userId': userId}).build(),
//     );

//     socket.onConnect((_) {
//       print("Connected to socket");
//       socket.emit('setup', {'id': userId});
//     });

//     socket.onDisconnect((_) => print("Disconnected from socket"));
//   }

//   void makingGroups(String groupId) {
//     socket.emit('Group Created', groupId);
//   }

//   void sendTyping(String groupId) {
//     socket.emit('typing', groupId);
//   }

//   void sendMessage(Map<String, dynamic> message) {
//     socket.emit('new message', message);
//   }

//   // void onMessageReceived(Function callback) {
//   //   socket.on('message received', callback);
//   // }

//   // void onTyping(Function callback) {
//   //   socket.on('typing', callback);
//   // }

//   // void onStopTyping(Function callback) {
//   //   socket.on('stop typing', callback);
//   // }
// }





// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:pexllite/constants.dart';
// late IO.Socket _socket;
//  void _initializeSocket() {
//     _socket = IO.io(serverurl, <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': true,
//     });

//     _socket.onConnect((_) {
//       print('Connected to server');
//       _socket.emit('joinRoom', widget.taskId);
//     });

//     _socket.on('newMessage', (data) {
//       print("The message received is $data");
//       if (mounted) {
//         setState(() {
//           messages.insert(0, data);
//         });
//       }
//     });

//     _socket.onDisconnect((_) {
//       print('Disconnected from server');
//     });
//   }