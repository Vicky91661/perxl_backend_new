import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;
  final String baseUrl = const String.fromEnvironment('REACT_APP_SERVER_URL');

  void connect(String userId) {
    socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'userId': userId})
          .build(),
    );

    socket.onConnect((_) {
      print("Connected to socket");
      socket.emit('setup', {'id': userId});
    });

    socket.onDisconnect((_) => print("Disconnected from socket"));
  }

  void makingGroups(String groupId) {
    socket.emit('Group Created', groupId);
  }

  void sendTyping(String groupId) {
    socket.emit('typing', groupId);
  }

  void sendMessage(Map<String, dynamic> message) {
    socket.emit('new message', message);
  }

  // void onMessageReceived(Function callback) {
  //   socket.on('message received', callback);
  // }

  // void onTyping(Function callback) {
  //   socket.on('typing', callback);
  // }

  // void onStopTyping(Function callback) {
  //   socket.on('stop typing', callback);
  // }
}
