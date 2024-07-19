import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:freshice/backend/api.dart';
import 'package:freshice/frontend/homescreen.dart';
import 'package:freshice/frontend/sidebarscreen.dart';

class CustomDrawerScreen extends StatefulWidget {
  const CustomDrawerScreen({super.key});

  @override
  State<CustomDrawerScreen> createState() => _CustomDrawerScreenState();
}

class _CustomDrawerScreenState extends State<CustomDrawerScreen> {
  final drawerController = ZoomDrawerController();

  Map<String, dynamic> userdetails = {};
  bool loading = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 0), () async {
      setState(() {
        loading = true;
      });
      final dynamic userdetailsresponse = await API.getUserDetails();
      print("User details");
      print("====================");
      print(userdetailsresponse);
      print("====================");
      if (userdetailsresponse["status"] == "success") {
        setState(() {
          userdetails = userdetailsresponse;
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ZoomDrawer(
        controller: drawerController,
        menuScreen: SideBarScreen(
          userdetails: userdetails,
        ),
        mainScreen: HomeScreen(
          zoomdrawerdontroller: drawerController,
          userdetails: userdetails,
        ),
        borderRadius: 24,
        style: DrawerStyle.Style1,
        openCurve: Curves.fastOutSlowIn,
        disableGesture: false,
        mainScreenTapClose: true,
        slideWidth: MediaQuery.of(context).size.width * 0.65,
        duration: const Duration(milliseconds: 500),
        backgroundColor: API.backgroundmaincolor,
        showShadow: true,
        angle: 0.0,
        clipMainScreen: true,
      ),
    );
  }
}
