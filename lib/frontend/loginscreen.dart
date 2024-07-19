// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freshice/backend/api.dart';
import 'package:freshice/frontend/customdrawerscreen.dart';
import 'package:freshice/frontend/homescreen.dart';
import 'package:route_transitions/route_transitions.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController usernamecontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      loading = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final dynamic response = await API.getUserDetails();
      if (response["status"] == "success") {
        dynamic deviceinformation = await API.getDeviceInfo();
        print("==============================");
        print("This is the device information");
        print("==============================");
        print(deviceinformation);
        if (deviceinformation["status"] == "success") {
          final dynamic autologinresponse = await API.postAutoLoginAPI(
              response["userid"].toString(),
              response["token"],
              defaultTargetPlatform == TargetPlatform.android
                  ? deviceinformation["device_id"].toString()
                  : deviceinformation["deviceinfo"]["identifierForVendor"]
                      .toString(),
              API.devicetype,
              API.buildversion,
              defaultTargetPlatform == TargetPlatform.android
                  ? ("Brand : ${deviceinformation["deviceinfo"]["brand"]} Device : ${deviceinformation["deviceinfo"]["device"]}")
                  : ("Name : ${deviceinformation["deviceinfo"]["name"]} systemName : ${deviceinformation["deviceinfo"]["systemName"]} systemVersion : ${deviceinformation["deviceinfo"]["systemVersion"]} model : ${deviceinformation["deviceinfo"]["model"]} localizedModel : ${deviceinformation["deviceinfo"]["localizedModel"]}"),
              context);
          print("This is the autologin details");
          print(autologinresponse);
          if (autologinresponse["status"] == "success") {
            await API
                .addUserDetails(
                    autologinresponse["id"].toString(),
                    autologinresponse["name"].toString(),
                    autologinresponse["name"].toString(),
                    autologinresponse["_token"].toString(),
                    autologinresponse["customer_id"].toString(),
                    autologinresponse["customer_name"].toString(),
                    autologinresponse["company_name"].toString(),
                    autologinresponse["billing_address"].toString(),
                    autologinresponse["genral_phno"].toString(),
                    autologinresponse["trn_no"].toString(),
                    autologinresponse["app_direct_sale"].toString(),
                    autologinresponse["app_sales"].toString(),
                    autologinresponse["app_production"].toString(),
                    autologinresponse["app_customers"].toString(),
                    autologinresponse["app_inventory"].toString(),
                    autologinresponse["app_cloud_sync"].toString(),
                    autologinresponse["app_device_settings"].toString())
                .then((value) {
              if (value["status"] == "success") {
                pushWidgetWhileRemove(
                    newPage: const CustomDrawerScreen(), context: context);
              } else {
                pushWidgetWhileRemove(
                    newPage: const LoginScreen(), context: context);
              }
            });
          } else {
            setState(() {
              loading = false;
            });
          }
        } else {
          setState(() {
            loading = false;
          });
        }
      } else {
        setState(() {
          loading = false;
        });
      }
    });
  }

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: loading
            ? API.loadingScreen(context)
            : Column(
                children: [
                  Expanded(
                      child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: API.appcolor,
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30, top: 80),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Login to\nYour account",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 20, right: 20),
                              child: Text(
                                "We are pleased to welcome you back to the Freshice Sales application. Here, you can create sales, manage your customer base, and access daily reports.",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )),
                  Container(
                    height: MediaQuery.of(context).size.height / 2,
                    width: MediaQuery.of(context).size.width / 1,
                    child: Card(
                      elevation: 0,
                      semanticContainer: true,
                      clipBehavior: Clip.antiAlias,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 50,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            child: TextFormField(
                              style: TextStyle(fontSize: API.appfontsize),
                              controller: usernamecontroller,
                              textAlign: TextAlign.left,
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 0.5)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: API.appcolor, width: 0.5)),
                                enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 0.5)),
                                contentPadding: const EdgeInsets.all(10),
                                hintText: "Username",
                                labelText: "Username",
                                isDense: true,
                                labelStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400),
                                hintStyle: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w300),
                                prefixIcon: Icon(
                                  Icons.person_2_outlined,
                                  color: API.appcolor,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            child: TextFormField(
                              style: TextStyle(fontSize: API.appfontsize),
                              controller: passwordcontroller,
                              textAlign: TextAlign.left,
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 0.5)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: API.appcolor, width: 0.5)),
                                enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 0.5)),
                                contentPadding: const EdgeInsets.all(10),
                                hintText: "Password",
                                labelText: "Password",
                                labelStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400),
                                hintStyle: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w300),
                                isDense: true,
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: API.appcolor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () async {
                              if (usernamecontroller.text.isEmpty &&
                                  passwordcontroller.text.isEmpty) {
                                API.showSnackBar(
                                    "failed",
                                    "Please enter username and password",
                                    context);
                              } else {
                                setState(() {
                                  loading = true;
                                });
                                dynamic deviceinformation =
                                    await API.getDeviceInfo();
                                print("==============================");
                                print("This is the device information");
                                print("==============================");
                                print(deviceinformation);
                                if (deviceinformation["status"] == "success") {
                                  final dynamic response = await API.postLoginAPI(
                                      usernamecontroller.text,
                                      passwordcontroller.text,
                                      defaultTargetPlatform ==
                                              TargetPlatform.android
                                          ? deviceinformation["device_id"]
                                              .toString()
                                          : deviceinformation["deviceinfo"]
                                                  ["identifierForVendor"]
                                              .toString(),
                                      API.devicetype,
                                      API.buildversion,
                                      defaultTargetPlatform ==
                                              TargetPlatform.android
                                          ? ("Brand : ${deviceinformation["deviceinfo"]["brand"]} Device : ${deviceinformation["deviceinfo"]["device"]}")
                                          : ("Name : ${deviceinformation["deviceinfo"]["name"]} systemName : ${deviceinformation["deviceinfo"]["systemName"]} systemVersion : ${deviceinformation["deviceinfo"]["systemVersion"]} model : ${deviceinformation["deviceinfo"]["model"]} localizedModel : ${deviceinformation["deviceinfo"]["localizedModel"]}"),
                                      context);
                                  print("This is the login details");
                                  print(response);
                                  if (response["status"] == "success") {
                                    await API
                                        .addUserDetails(
                                            response["user_data"]["user_id"]
                                                .toString(),
                                            response["user_data"]["username"]
                                                .toString(),
                                            response["user_data"]["name"]
                                                .toString(),
                                            response["user_data"]["token"]
                                                .toString(),
                                            response["user_data"]["customer_id"]
                                                .toString(),
                                            response["user_data"]
                                                    ["customer_name"]
                                                .toString(),
                                            response["user_data"]
                                                    ["company_name"]
                                                .toString(),
                                            response["user_data"]
                                                    ["billing_address"]
                                                .toString(),
                                            response["user_data"]
                                                    ["genral_phno"]
                                                .toString(),
                                            response["user_data"]["trn_no"]
                                                .toString(),
                                            response["user_data"]
                                                    ["app_direct_sale"]
                                                .toString(),
                                            response["user_data"]["app_sales"]
                                                .toString(),
                                            response["user_data"]
                                                    ["app_production"]
                                                .toString(),
                                            response["user_data"]
                                                    ["app_customers"]
                                                .toString(),
                                            response["user_data"]
                                                    ["app_inventory"]
                                                .toString(),
                                            response["user_data"]
                                                    ["app_cloud_sync"]
                                                .toString(),
                                            response["user_data"]
                                                    ["app_device_settings"]
                                                .toString())
                                        .then((value) {
                                      if (value["status"] == "success") {
                                        pushWidgetWhileRemove(
                                            newPage: const CustomDrawerScreen(),
                                            context: context);
                                      } else {
                                        pushWidgetWhileRemove(
                                            newPage: const LoginScreen(),
                                            context: context);
                                      }
                                    });
                                  } else {
                                    setState(() {
                                      loading = false;
                                    });
                                    API.showSnackBar(
                                        response["status"],
                                        response["message"].toString(),
                                        context);
                                  }
                                }
                              }
                            },
                            child: Container(
                              height: 40,
                              width: MediaQuery.of(context).size.width / 1.5,
                              decoration: BoxDecoration(
                                color: API.appcolor,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: const Center(
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
