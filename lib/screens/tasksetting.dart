import 'package:flutter/material.dart';
import 'package:pexllite/helpers/database_helper.dart';
import 'taskHome.dart';
import 'taskstackedicon.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  _SettingsState createState() => _SettingsState();
}

showAlertDialog(BuildContext context) async {
  // Set up the buttons
  Widget cancelButton = TextButton(
    child: Text("Cancel"),
    onPressed: () {
      Navigator.pop(context);
    },
  );

  Widget continueButton = TextButton(
    child: Text("OK"),
    onPressed: () {
      DatabaseHelper.instance.deleteAllTask();
      Fluttertoast.showToast(
        msg: "All data cleared",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TaskHomeScreen()),
      );
    },
  );

  // Set up the AlertDialog
  AlertDialog alert = AlertDialog(
    content: Text("Would you like to clear all data? It cannot be undone."),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // Show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(250, 250, 250, 1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: const TextStyle(
            color: Colors.redAccent,
            fontSize: 20.0,
            fontWeight: FontWeight.normal,
          ),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(25.0, 60.0, 25.0, 25.0),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              StakedIcons(),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Task Manager",
                  style: TextStyle(fontSize: 20.0, color: Colors.grey),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 5.0, left: 25.0, right: 20.0, bottom: 60.0),
                child: Text(
                  "Version: 3.0.0",
                  style: TextStyle(fontSize: 12.0, color: Colors.grey),
                ),
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: GestureDetector(
                        onTap: () {
                          showAlertDialog(context);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 40.0,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(9.0),
                          ),
                          child: Text(
                            "CLEAR ALL DATA",
                            style: TextStyle(
                                fontSize: 15.0, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: InkWell(
                  child: Text(
                    "Terms and Condition",
                    style: TextStyle(
                        fontSize: 17.0, color: Colors.brown),
                  ),
                  onTap: () async {
                    final Uri url = Uri.parse('https://bornomala-tech.web.app/policies');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: InkWell(
                  child: Text(
                    "Privacy Policy",
                    style: TextStyle(
                        fontSize: 17.0, color: Colors.brown),
                  ),
                  onTap: () async {
                    final Uri url = Uri.parse('https://bornomala-tech.web.app/policies');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  "PerXL  ",
                  style: TextStyle(fontSize: 15.0, color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
