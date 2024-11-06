import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pexllite/constants.dart';
import 'package:pexllite/helpers/helper_functions.dart';
import 'package:pexllite/screens/chat.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pexllite/screens/makeGroup.dart';
import 'package:pexllite/screens/taskHome.dart';
import 'package:pexllite/screens/welcome.dart';
import 'profile.dart';
import 'package:provider/provider.dart';
import 'package:pexllite/state_management/group_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _token = '';
  int _selectedIndex = 0;
  bool isLoading = false;
  List<dynamic> searchResults = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchToken();
  }

  Future<void> _fetchToken() async {
    try {
      print("inside the _getUserLoggedInStatus function");
      String? token = await HelperFunctions.getUserTokenSharedPreference();
      print("THE VALUE OF TOKEN IS $token");
      if (token != null && mounted) {
        setState(() {
          _token = token;
        });
        _fetchGroups();
      }
    } catch (e) {
      setState(() {
        _token = '';
      });
      Fluttertoast.showToast(msg: "Invalid User");
      await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> _fetchGroups() async {
    try {
      setState(() => isLoading = true);
      final response =
          await http.get(Uri.parse('$baseurl/group/fetchgroups'), headers: {
        'authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final groups = responseData['groups'];
        Provider.of<GroupProvider>(context, listen: false).setGroups(groups);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching Groups: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _onItemTapped(int index) async {
    if (index == 1) {
      // Navigate to ProfileScreen and await the returned index
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(token: _token),
        ),
      );

      // Set selected index based on the result or default to Home
      setState(() => _selectedIndex = result ?? 0);
    } else if (index == 2) {
      // Navigate to MakeGroupScreen
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MakeGroupScreen(token: _token),
        ),
      );
    } else {
      // Default behavior for Home
      setState(() => _selectedIndex = index);
    }
  }

  Future<void> _handleSearch(String query) async {
    setState(() => searchQuery = query);
    try {
      final response = await http.get(Uri.parse('$baseurl/'), headers: {
        'Authorization': 'Bearer $_token',
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
    print("the group provider data has => ${groupProvider.groups}");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Row(
          children: const [
            Image(
              image: AssetImage("assets/images/perxl_logo.png"),
              height: 30,
            ),
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
                      backgroundImage: NetworkImage("${group['photo']}")),
                  title: Text(group['GroupName']),
                  // subtitle: Text(group['latestMessage'] ?? 'No message'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TaskHomeScreen(
                            groupId: group['_id'],
                            groupName: group['GroupName'],
                            )),
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
