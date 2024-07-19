import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:freshice/backend/api.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> notifications = [
    {"description": "Sale added successfully", "date": "10 / 06 / 2024"},
    {
      "description": "Production order added successfully",
      "date": "06/ 06 / 2024"
    }
  ];

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: FaIcon(
                FontAwesomeIcons.arrowLeft,
                color: API.buttoncolor,
                size: 20,
              )),
          centerTitle: true,
          title: Text(
            "Notifications",
            style: TextStyle(
                color: API.buttoncolor,
                fontSize: 16,
                fontWeight: FontWeight.w300),
          ),
        ),
        body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(
                      Icons.circle,
                      size: 15,
                      color: API.appcolor,
                    ),
                    title: Text(
                      notifications[index]["description"].toString(),
                      style: TextStyle(
                          color: API.textcolor,
                          fontSize: 13,
                          fontWeight: FontWeight.w400),
                    ),
                    subtitle: Text(
                      notifications[index]["date"].toString(),
                      style: TextStyle(
                          color: API.textcolor.withOpacity(0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.w300),
                    ),
                  );
                })));
  }
}
