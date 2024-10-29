import 'package:flutter/material.dart';
import 'package:pexllite/constants.dart';
import 'package:pexllite/screens/chat.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pexllite/screens/makeGroup.dart';
import 'profile.dart';

import 'package:provider/provider.dart';
import 'package:pexllite/state_management/user_provider.dart';
import 'package:pexllite/state_management/group_provider.dart';

class HomeScreen extends StatefulWidget {
  final String token;

  const HomeScreen({super.key, required this.token});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool isLoading = false;
  List<dynamic> searchResults = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchGroups();
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await http.get(Uri.parse('YOUR_API_ENDPOINT'), headers: {
        'Authorization': 'Bearer ${widget.token}',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Provider.of<UserProvider>(context, listen: false).setUser(data['user']);
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> _fetchGroups() async {
    try {
      setState(() => isLoading = true);
      final response =
          await http.get(Uri.parse('/api/v1/group/fetchgroups'), headers: {
        'authorization': 'Bearer ${widget.token}',
      });

      if (response.statusCode == 200) {
        final groups = jsonDecode(response.body);
        Provider.of<GroupProvider>(context, listen: false).setGroups(groups);
      }
    } catch (e) {
      print("Error fetching Groups: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen(token: widget.token)));
        break;
      case 1:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProfileScreen(token: widget.token)));
        break;
      case 2:
        // Make Group
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MakeGroupScreen(token: widget.token)));
        break;
      default:
        break;
    }
  }

  Future<void> _handleSearch(String query) async {
    setState(() => searchQuery = query);
    try {
      final response =
          await http.get(Uri.parse('YOUR_SEARCH_ENDPOINT'), headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        setState(() => searchResults = jsonDecode(response.body));
      }
    } catch (e) {
      print("Error searching groups: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Row(
          children: const [
            // Image(
            //   image: AssetImage("assets/images/perxl_logo.png"),
            //   height: 30,
            // ),
            SizedBox(width: 10),
            Text("Messages"),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _handleSearch,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Search group...',
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchQuery.isNotEmpty
                  ? searchResults.length
                  : groupProvider.groups.length,
              itemBuilder: (context, index) {
                final group = searchQuery.isNotEmpty
                    ? searchResults[index]
                    : groupProvider.groups[index];
                return ListTile(
                  leading: CircleAvatar(
                      backgroundImage: AssetImage("assets/images/logo.png")),
                  title: Text(group['groupName']),
                  subtitle: Text(group['latestMessage'] ?? 'No message'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatScreen(
                            groupId: group['groupid'],
                            groupName: group['groupName'])),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
              icon: Icon(Icons.group_add), label: 'Make Group'),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}
