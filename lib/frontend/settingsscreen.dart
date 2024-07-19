// ignore_for_file: use_build_context_synchronously

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:freshice/backend/api.dart';

class SettingsScreen extends StatefulWidget {
  final String token;
  const SettingsScreen({super.key, required this.token});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<dynamic> devicelist = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await loadData();
    });
  }

  Future<void> loadData() async {
    setState(() {
      loading = true;
    });
    final dynamic response = await API.getDeviceListAPI(widget.token, context);
    setState(() {
      devicelist = response["status"] == "success" ? response["data"] : [];
      loading = false;
    });
  }

  static dynamic onAlertPopUp(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                "Are you sure ?",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                  color: API.textcolor,
                ),
              ),
              content: SizedBox(
                height: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(
                      thickness: 1,
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        "Please note that before clearing the device ID, ensure that local data on the user's device is synced to the cloud. Can we proceed with syncing your data? This action is irreversible.",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: API.textcolor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Container(
                      height: 30,
                      width: 50,
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(15)),
                      child: const Center(
                        child: Text(
                          "NO",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )),
                TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Container(
                        height: 30,
                        width: 50,
                        decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(15)),
                        child: const Center(
                            child: Text("YES",
                                style: TextStyle(color: Colors.white)))))
              ],
            ));
  }

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
            "User Devices",
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
          child: loading
              ? API.loadingScreen(context)
              : devicelist.isEmpty
                  ? API.emptyWidget(context)
                  : ListView.builder(
                      itemCount: devicelist.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () async {
                            final connectivityResult =
                                await Connectivity().checkConnectivity();
                            if (connectivityResult == ConnectivityResult.none) {
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (_) => API.alertboxScreen(context),
                              );
                            } else {
                              final shouldPop = await onAlertPopUp(context);
                              if (shouldPop == true) {
                                setState(() {
                                  loading = true;
                                });
                                final dynamic clearresponse =
                                    await API.postClearDeviceIDAPI(
                                        devicelist[index]["id"].toString(),
                                        widget.token,
                                        context);
                                if (clearresponse["status"] == "success") {
                                  setState(() {
                                    loading = false;
                                  });
                                  await loadData();
                                  setState(() {
                                    devicelist = [];
                                  });
                                } else {
                                  setState(() {
                                    loading = false;
                                  });
                                  API.showSnackBar(
                                      "failed",
                                      clearresponse["message"].toString(),
                                      context);
                                }
                              }
                            }
                          },
                          child: Card(
                            elevation: 5,
                            child: ListTile(
                              leading: Container(
                                  height: 30,
                                  child: Image.asset(
                                      "assets/images/mobile-app.png")),
                              title: Text(
                                devicelist[index]["username"].toString(),
                                style: TextStyle(
                                    color: API.textcolor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5),
                                              child: Text(
                                                "Device Id",
                                                style: TextStyle(
                                                    color: API.textcolor,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.w300),
                                              ),
                                            ),
                                            Text(
                                              devicelist[index]["device_id"]
                                                  .toString(),
                                              style: TextStyle(
                                                  color: API.textcolor,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3.5,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5),
                                              child: Text(
                                                "Device Type",
                                                style: TextStyle(
                                                    color: API.textcolor,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.w300),
                                              ),
                                            ),
                                            Text(
                                              devicelist[index]["device_type"]
                                                  .toString(),
                                              style: TextStyle(
                                                  color: API.textcolor,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(),
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: Text(
                                      "Device Info",
                                      style: TextStyle(
                                          color: API.textcolor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                  Text(
                                    devicelist[index]["device_info"].toString(),
                                    style: TextStyle(
                                        color: API.textcolor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  )
                                ],
                              ),
                              trailing: const Icon(
                                Icons.remove_circle_rounded,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        );
                      }),
        ));
  }
}
