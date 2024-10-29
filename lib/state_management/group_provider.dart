import 'package:flutter/material.dart';

class GroupProvider with ChangeNotifier {
  List<dynamic> groups = [];
  String lastestChat = '';
  List<dynamic> notifications = [];

  void setGroups(List<dynamic> groupList) {
    groups = groupList;
    notifyListeners();
  }

  void setLastestChat(String groupId) {
    lastestChat = groupId;
    notifyListeners();
  }

  void setNotifications(List<dynamic> newNotifications) {
    notifications = newNotifications;
    notifyListeners();
  }
}
