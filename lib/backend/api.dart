// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freshice/frontend/loginscreen.dart';
import 'package:freshice/model/customermodel.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class API {
  static Color backgroundsubcolor = Colors.white;
  static Color backgroundmaincolor = const Color(0xFFd8dadd);
  static Color buttoncolor = Colors.black;
  static Color appcolor = const Color(0xFF2596be);
  static Color textcolor = Colors.black;
  static Color maintextcolor = Colors.black;
  static Color bordercolor = Colors.black;
  static double appfontsize = 13;

  static String baseurl = "https://blueskyerp.com/freshice/index.php?r=";

  static String devicetype = "android";
  static String buildversion = "1.0.0";

  static Future<Map<String, dynamic>> postLoginAPI(
      String username,
      String password,
      String deviceid,
      String devicetype,
      String appversion,
      String devicedescription,
      BuildContext context) async {
    print(json.encode({
      "username": username,
      "password": password,
      "device_id": deviceid,
      "device_type": devicetype,
      "app_version": appversion,
      "device_description": devicedescription
    }));
    final response = await post(
        Uri.parse(
          '${baseurl}Apilogin/login',
        ),
        body: json.encode({
          "username": username,
          "password": password,
          "device_id": deviceid,
          "device_type": devicetype,
          "app_version": appversion,
          "device_description": devicedescription
        }));
    print(response.statusCode);
    if (response.statusCode == 200) {
      dynamic requestresponse = jsonDecode(response.body);
      print("========================================");
      print("========================================");
      print(requestresponse);
      print("========================================");
      print("========================================");
      return requestresponse;
    } else if (response.statusCode == 401) {
      API.showSnackBar('failed', "User unauthorized", context);
      pushWidgetWhileRemove(newPage: const LoginScreen(), context: context);
      return {'status': 'failed', 'message': response.reasonPhrase.toString()};
    } else {
      return {'status': 'failed', 'message': response.reasonPhrase.toString()};
    }
  }

  static Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'systemFeatures': build.systemFeatures
    };
  }

  static Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  static Future<Map<String, dynamic>> getDeviceInfo() async {
    Map<String, dynamic> result = <String, dynamic>{};
    Map<String, dynamic> deviceData = <String, dynamic>{};
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        String? deviceId = await PlatformDeviceId.getDeviceId;
        var androidInfo = await deviceInfoPlugin.androidInfo;
        deviceData = _readAndroidBuildData(androidInfo);
        result = {
          "status": "success",
          "deviceinfo": deviceData,
          "device_id": deviceId
        };
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        var iosInfo = await deviceInfoPlugin.iosInfo;
        deviceData = _readIosDeviceInfo(iosInfo);
        result = {"status": "success", "deviceinfo": deviceData};
      } else {
        result = {"status": "error", "message": "Platform not supported"};
      }
    } on PlatformException {
      result = {
        "status": "error",
        "message": "Failed to get platform version."
      };
    }
    return result;
  }

  static Future<Map<String, dynamic>> postAutoLoginAPI(
      String userid,
      String token,
      String deviceid,
      String devicetype,
      String appversion,
      String devicedescription,
      BuildContext context) async {
    print(json.encode({
      "user_id": userid,
      "device_id": deviceid,
      "device_type": devicetype,
      "app_version": appversion,
      "device_description": devicedescription
    }));
    final response = await post(
        Uri.parse(
          '${baseurl}apilogin/LoginSuccess',
        ),
        headers: <String, String>{'token': token},
        body: json.encode({
          "user_id": userid,
          "device_id": deviceid,
          "device_type": devicetype,
          "app_version": appversion,
          "device_description": devicedescription
        }));
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      dynamic requestresponse = jsonDecode(response.body);
      print("========================================");
      print("========================================");
      print(requestresponse);
      print("========================================");
      print("========================================");
      return requestresponse;
    } else if (response.statusCode == 401) {
      API.showSnackBar('failed', "User unauthorized", context);
      pushWidgetWhileRemove(newPage: const LoginScreen(), context: context);
      return {'status': 'failed', 'message': response.reasonPhrase.toString()};
    } else {
      return {'status': 'failed', 'message': response.reasonPhrase.toString()};
    }
  }

  static Future<Map<String, dynamic>> getProductsListAPI(String token,
      String term, String categoryid, BuildContext context) async {
    final response = await get(
      Uri.parse(
        '${baseurl}apistore/SearchProductList&term=$term&category_id=$categoryid',
      ),
      headers: <String, String>{'token': token},
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      dynamic requestresponse = jsonDecode(response.body);
      print("========================================");
      print("========================================");
      print(requestresponse);
      print("========================================");
      print("========================================");
      return requestresponse;
    } else if (response.statusCode == 401) {
      API.showSnackBar('failed', "User unauthorized", context);
      pushWidgetWhileRemove(newPage: const LoginScreen(), context: context);
      return {'status': 'failed', 'message': response.reasonPhrase.toString()};
    } else {
      return {'status': 'failed', 'message': response.reasonPhrase.toString()};
    }
  }

  static Future<Map<String, dynamic>> postSyncInvoicesAPI(
      String invoiceid,
      String customerid,
      String paymenttypeid,
      String roundoffamount,
      String grandtotal,
      String invoicedate,
      List<dynamic> materials,
      String token,
      BuildContext context) async {
    print(json.encode({
      "invoice_id": invoiceid,
      "customer_id": customerid,
      "payment_type_id": paymenttypeid,
      "round_off_amount": roundoffamount,
      "grand_total": grandtotal,
      'invoice_date': invoicedate,
      "inv_items": materials
    }));
    final response = await post(
      Uri.parse(
        '${baseurl}apisync/SyncInvoice',
      ),
      body: json.encode({
        "invoice_id": invoiceid,
        "customer_id": customerid,
        "payment_type_id": paymenttypeid,
        "round_off_amount": roundoffamount,
        "grand_total": grandtotal,
        'invoice_date': invoicedate,
        "inv_items": materials
      }),
      headers: <String, String>{'token': token},
    );
    print("mainly");
    print(response.body);
    if (response.statusCode == 200) {
      dynamic requestresponse = jsonDecode(response.body);
      print("========================================");
      print("========================================");
      print(requestresponse);
      print("========================================");
      print("========================================");
      return requestresponse;
    } else if (response.statusCode == 401) {
      API.showSnackBar('failed', "User unauthorized", context);
      pushWidgetWhileRemove(newPage: const LoginScreen(), context: context);
      return {'status': 'failed', 'message': response.reasonPhrase.toString()};
    } else {
      return {'status': 'failed', 'message': response.reasonPhrase.toString()};
    }
  }

  static Future<Map<String, dynamic>> postSyncBalanceInventoryAPI(
      List<dynamic> items, String token, BuildContext context) async {
    print("This is the balance");
    print(json.encode({"balance_items": items}));
    final response = await post(
      Uri.parse(
        '${baseurl}Apisync/SyncBalanceItems',
      ),
      body: json.encode({"balance_items": items}),
      headers: <String, String>{'token': token},
    );
    if (response.statusCode == 200) {
      dynamic requestresponse = jsonDecode(response.body);
      print("========================================");
      print("========================================");
      print(requestresponse);
      print("========================================");
      print("========================================");
      return requestresponse;
    } else if (response.statusCode == 401) {
      API.showSnackBar('failed', "User unauthorized", context);
      pushWidgetWhileRemove(newPage: const LoginScreen(), context: context);
      return {'status': 'failed', 'message': response.reasonPhrase.toString()};
    } else {
      return {'status': 'failed', 'message': response.reasonPhrase.toString()};
    }
  }

  static Future<Map<String, dynamic>> getSyncTablesAPI(
      String token, BuildContext context) async {
    print("This is the token for");
    print(token);
    final response = await get(
      Uri.parse(
        '${baseurl}apisync/Synctables',
      ),
      headers: <String, String>{'token': token},
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      dynamic requestresponse = jsonDecode(response.body);
      print("========================================");
      print("========================================");
      print(requestresponse);
      print("========================================");
      print("========================================");
      return requestresponse;
    } else if (response.statusCode == 401) {
      API.showSnackBar('failed', "User unauthorized", context);
      pushWidgetWhileRemove(newPage: const LoginScreen(), context: context);
      return {'status': 'failed', 'message': response.reasonPhrase.toString()};
    } else {
      return {'status': 'failed', 'message': response.reasonPhrase.toString()};
    }
  }

  static Future<Map<String, dynamic>> getBOMListAPI(
      String token, BuildContext context) async {
    final response = await get(
      Uri.parse(
        '${baseurl}apiassembly/bomlist',
      ),
      headers: <String, String>{'token': token},
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      dynamic requestresponse = jsonDecode(response.body);
      print("========================================");
      print("========================================");
      print(requestresponse);
      print("========================================");
      print("========================================");
      return requestresponse;
    } else if (response.statusCode == 401) {
      API.showSnackBar('failed', "User unauthorized", context);
      pushWidgetWhileRemove(newPage: const LoginScreen(), context: context);
      return {'status': 'failed', 'message': response.reasonPhrase.toString()};
    } else {
      return {'status': 'failed', 'message': response.reasonPhrase.toString()};
    }
  }

  static Future<Map<String, dynamic>> getDeviceListAPI(
      String token, BuildContext context) async {
    final response = await get(
      Uri.parse(
        '${baseurl}Apilogin/getuserdevicelist',
      ),
      headers: <String, String>{'token': token},
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      dynamic requestresponse = jsonDecode(response.body);
      print("========================================");
      print("========================================");
      print(requestresponse);
      print("========================================");
      print("========================================");
      return requestresponse;
    } else if (response.statusCode == 401) {
      API.showSnackBar('failed', "User unauthorized", context);
      pushWidgetWhileRemove(newPage: const LoginScreen(), context: context);
      return {'status': 'failed', 'message': response.reasonPhrase.toString()};
    } else {
      return {'status': 'failed', 'message': response.reasonPhrase.toString()};
    }
  }

  static Future<Map<String, dynamic>> postClearDeviceIDAPI(
      String userid, String token, BuildContext context) async {
    final response = await post(
        Uri.parse(
          '${baseurl}Apilogin/clearuserdevice',
        ),
        headers: <String, String>{'token': token},
        body: json.encode({"user_id": userid}));
    print(response.statusCode);
    if (response.statusCode == 200) {
      dynamic requestresponse = jsonDecode(response.body);
      print("========================================");
      print("========================================");
      print(requestresponse);
      print("========================================");
      print("========================================");
      return requestresponse;
    } else if (response.statusCode == 401) {
      API.showSnackBar('failed', "User unauthorized", context);
      pushWidgetWhileRemove(newPage: const LoginScreen(), context: context);
      return {'status': 'failed', 'message': response.reasonPhrase.toString()};
    } else {
      return {'status': 'failed', 'message': response.reasonPhrase.toString()};
    }
  }

  static Future<Map<String, dynamic>> postBOMMaterialDetailsAPI(
      String bomid, String token, BuildContext context) async {
    final response = await post(
        Uri.parse(
          '${baseurl}apiassembly/GetAutoProductionDetails',
        ),
        headers: <String, String>{'token': token},
        body: json.encode({"bom_id": bomid}));
    print(response.statusCode);
    if (response.statusCode == 200) {
      dynamic requestresponse = jsonDecode(response.body);
      print("========================================");
      print("========================================");
      print(requestresponse);
      print("========================================");
      print("========================================");
      return requestresponse;
    } else if (response.statusCode == 401) {
      API.showSnackBar('failed', "User unauthorized", context);
      pushWidgetWhileRemove(newPage: const LoginScreen(), context: context);
      return {'status': 'failed', 'message': response.reasonPhrase.toString()};
    } else {
      return {'status': 'failed', 'message': response.reasonPhrase.toString()};
    }
  }

  static Future<Map<String, dynamic>> postIntermediateSyncAPI(
      String token, BuildContext context) async {
    final response = await post(
      Uri.parse(
        '${baseurl}ApiTransfer/IntermediateSync',
      ),
      headers: <String, String>{'token': token},
    );
    if (response.statusCode == 200) {
      dynamic requestresponse = jsonDecode(response.body);
      print("========================================");
      print("========================================");
      print(requestresponse);
      print("========================================");
      print("========================================");
      return requestresponse;
    } else if (response.statusCode == 401) {
      API.showSnackBar('failed', "User unauthorized", context);
      pushWidgetWhileRemove(newPage: const LoginScreen(), context: context);
      return {'status': 'failed', 'message': response.reasonPhrase.toString()};
    } else {
      return {'status': 'failed', 'message': response.reasonPhrase.toString()};
    }
  }

  static Future<Map<String, dynamic>> postSyncTransferAPI(
      List<dynamic> transferids, String token, BuildContext context) async {
    final response = await post(
        Uri.parse(
          '${baseurl}ApiTransfer/SyncTransfer',
        ),
        headers: <String, String>{'token': token},
        body: json.encode({"transfer_ids": transferids}));
    print(response.statusCode);
    print("This is the response body");
    print(response.body);
    if (response.statusCode == 200) {
      dynamic requestresponse = jsonDecode(response.body);
      print("========================================");
      print("========================================");
      print(requestresponse);
      print("========================================");
      print("========================================");
      return requestresponse;
    } else if (response.statusCode == 401) {
      API.showSnackBar('failed', "User unauthorized", context);
      pushWidgetWhileRemove(newPage: const LoginScreen(), context: context);
      return {'status': 'failed', 'message': response.reasonPhrase.toString()};
    } else {
      return {'status': 'failed', 'message': response.reasonPhrase.toString()};
    }
  }

  static Future<Map<String, dynamic>> postSaveAutoProductionAPI(
      String bomid, String quantity, String token, BuildContext context) async {
    final response = await post(
        Uri.parse(
          '${baseurl}apiassembly/SaveAutoProduction',
        ),
        headers: <String, String>{'token': token},
        body: json.encode({"bom_id": bomid, "quantity": quantity}));
    print(response.statusCode);
    if (response.statusCode == 200) {
      dynamic requestresponse = jsonDecode(response.body);
      print("========================================");
      print("========================================");
      print(requestresponse);
      print("========================================");
      print("========================================");
      return requestresponse;
    } else if (response.statusCode == 401) {
      API.showSnackBar('failed', "User unauthorized", context);
      pushWidgetWhileRemove(newPage: const LoginScreen(), context: context);
      return {'status': 'failed', 'message': response.reasonPhrase.toString()};
    } else {
      return {'status': 'failed', 'message': response.reasonPhrase.toString()};
    }
  }

  static Widget alertboxScreen(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
              width: 200, child: Image.asset('assets/images/no-internet.png')),
          const SizedBox(height: 32),
          const Text(
            "Whoops!",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            "No internet connection found.",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            "Check your connection and try again.",
            style: TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              height: 40,
              width: MediaQuery.of(context).size.width / 2.35,
              decoration: BoxDecoration(
                color: API.appcolor,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Text(
                    "Try Again",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  static Widget loadingScreen(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: CircularProgressIndicator(
          color: API.appcolor,
          strokeWidth: 0.5,
        ),
      ),
    );
  }

  static Future<Map<String, dynamic>> addUserDetails(
      String userid,
      String username,
      String name,
      String token,
      String customerid,
      String customername,
      String companyname,
      String companyaddress,
      String companyphone,
      String companytrn,
      String appdirectsale,
      String appsales,
      String appproduction,
      String appcustomers,
      String appinventory,
      String appcloudsync,
      String appdevicesettings) async {
    SharedPreferences poscache = await SharedPreferences.getInstance();
    poscache.setString('userid', userid);
    poscache.setString('username', username);
    poscache.setString('name', name);
    poscache.setString('token', token);
    poscache.setString('customer_id', customerid);
    poscache.setString('customer_name', customername);
    poscache.setString('company_name', companyname);
    poscache.setString('company_address', companyaddress);
    poscache.setString('company_phone', companyphone);
    poscache.setString('company_trn', companytrn);
    poscache.setString('app_direct_sale', appdirectsale);
    poscache.setString('app_sales', appsales);
    poscache.setString('app_production', appproduction);
    poscache.setString('app_customers', appcustomers);
    poscache.setString('app_inventory', appinventory);
    poscache.setString('app_cloud_sync', appcloudsync);
    poscache.setString('app_device_settings', appdevicesettings);
    return {"status": "success"};
  }

  static Future<Map<String, dynamic>> getUserDetails() async {
    SharedPreferences poscache = await SharedPreferences.getInstance();
    if (poscache.containsKey('userid')) {
      String? userid = poscache.getString('userid');
      String? username = poscache.getString('username');
      String? name = poscache.getString('name');
      String? token = poscache.getString('token');
      String? customerid = poscache.getString('customer_id');
      String? customername = poscache.getString('customer_name');
      String? companyname = poscache.getString('company_name');
      String? companyaddress = poscache.getString('company_address');
      String? companyphone = poscache.getString('company_phone');
      String? companytrn = poscache.getString('company_trn');
      String? appdirectsale = poscache.getString('app_direct_sale');
      String? appsales = poscache.getString('app_sales');
      String? appproduction = poscache.getString('app_production');
      String? appcustomers = poscache.getString('app_customers');
      String? appinventory = poscache.getString('app_inventory');
      String? appcloudsync = poscache.getString('app_cloud_sync');
      String? appdevicesettings = poscache.getString('app_device_settings');

      return {
        'status': 'success',
        'userid': userid,
        'username': username,
        'name': name,
        'token': token,
        'customerid': customerid,
        'customername': customername,
        'companyname': companyname,
        'companyaddress': companyaddress,
        'companyphone': companyphone,
        'companytrn': companytrn,
        'app_direct_sale': appdirectsale,
        'app_sales': appsales,
        'app_production': appproduction,
        'app_customers': appcustomers,
        'app_inventory': appinventory,
        'app_cloud_sync': appcloudsync,
        'app_device_settings': appdevicesettings
      };
    } else {
      return {'status': 'failed', 'message': 'User not available'};
    }
  }

  static void showSnackBar(
      String status, String message, BuildContext context) {
    if (status == "success") {
      Get.snackbar("Success", message,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          maxWidth: MediaQuery.of(context).size.width);
    } else {
      Get.snackbar("Failed", message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          maxWidth: MediaQuery.of(context).size.width);
    }
  }

  static Future<void> getlaunchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  static Widget emptyWidget(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            width: MediaQuery.of(context).size.width / 2.5,
            child: Center(child: Image.asset("assets/images/empty-box.png"))),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            "There is no data available",
            style: TextStyle(
                color: API.textcolor,
                fontSize: 13,
                fontWeight: FontWeight.w300),
          ),
        )
      ],
    );
  }
}
