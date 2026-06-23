

// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freshice/frontend/common/loginscreen.dart';
import 'package:freshice/model/customermodel.dart';
import 'package:freshice/model/inventorymodel.dart';
import 'package:freshice/model/paymenttermmodel.dart';
import 'package:freshice/model/warehousemodel.dart';
import 'package:freshice/model/warehouseproductmodel.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
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

  // static String baseurl = "https://bluesky-erp.com/freshice/index.php?r=";
  // static String fileurl = "https://bluesky-erp.com/freshice/";

  static String baseurl = "https://blueskycosmos.com/freshice/index.php?r=";
  static String fileurl = "https://blueskycosmos.com/freshice/";

  static String devicetype = "android";
  static String buildversion = "1.0.1";
  static String updateddate = "23 / 06 / 2026";

  static String printertype = "2";

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

  static Future<Map<String, dynamic>> getInventoryListAPI(
      String term,
      String warehouseid,
      String token,
      BuildContext context) async {
    final response = await post(
        Uri.parse(
          '${baseurl}apistore/GetInventoryList',
        ),
        headers: <String, String>{'token': token},
        body: json.encode({
          "term": term,
          "warehouse_id": warehouseid
        })
      );
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

  static Future<Map<String, dynamic>> getCustomersListAPI(
      String term,
      String token,
      BuildContext context) async {
    final response = await get(
        Uri.parse(
          '${baseurl}apicustomer/GetCustomerList&term=$term',
        ),
        headers: <String, String>{'token': token},
      );
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

   static Future<Map<String, dynamic>> getDashboardDetailsAPI(
      String token,
      BuildContext context) async {
        print("This is token");
        print(token);
    final response = await post(
        Uri.parse(
          '${baseurl}Apidashboard/GetDashboardDetails',
        ),
        headers: <String, String>{'token': token},
      );
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

  

   static Future<List<CustomerModel>> getCustomerQueryList(
      String term, String token) async {
    final response = await get(
        headers: <String, String>{'token': token},
        Uri.parse(
          '${baseurl}apicustomer/GetCustomerList&term=$term',
        ),
     );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responselistjson = json.decode(response.body);
      List<dynamic> outputlist = responselistjson["status"] == "success"
          ? responselistjson["data"]
          : [];
      return outputlist.map((json) => CustomerModel.fromJson(json)).toList();
    } else {
      throw Exception();
    }
  }

  static Future<List<InventoryModel>> getInventoryQueryList(
      String term,
      String warehouseid,
      String token) async {
    final response = await post(
        headers: <String, String>{'token': token},
        Uri.parse(
          '${baseurl}apistore/GetInventoryList'
        ),
           body: json.encode({
          "term": term,
          "warehouse_id": warehouseid
        })
     );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responselistjson = json.decode(response.body);
      List<dynamic> outputlist = responselistjson["status"] == "success"
          ? responselistjson["data"]
          : [];
      print("This is the inventory");
      print(json.encode(outputlist));
      print(outputlist);
      return outputlist.map((json) => InventoryModel.fromJson(json)).toList();
    } else {
      throw Exception();
    }
  }

  static Future<List<PaymentTermModel>> getPaymentTermQueryList(
      String term,
      String token) async {
    final response = await post(
        headers: <String, String>{'token': token},
        Uri.parse(
          '${baseurl}Apimaster/GetPaymentTermList'
        ),
           body: json.encode({
          "term": term
        })
     );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responselistjson = json.decode(response.body);
      List<dynamic> outputlist = responselistjson["status"] == "success"
          ? responselistjson["data"]
          : [];
      print("This is the inventory");
      print(json.encode(outputlist));
      print(outputlist);
      return outputlist.map((json) => PaymentTermModel.fromJson(json)).toList();
    } else {
      throw Exception();
    }
  }


   static Future<Map<String, dynamic>> getInvoicesListAPI(
      String startdate,
      String enddate,
      String term,
      String token,
      BuildContext context) async {
    final response = await post(
        Uri.parse(
          '${baseurl}Apidirectinvoice/GetInvoiceList',
        ),
        headers: <String, String>{'token': token},
        body: json.encode(
          {
          "start_date":startdate,
	        "end_date":enddate,
	        "term":term
          }
        )
      );
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

   static Future<Map<String, dynamic>> getInvoicesDetailsByIDAPI(
      String invoiceid,
      String token,
      BuildContext context) async {
    final response = await post(
        Uri.parse(
          '${baseurl}Apidirectinvoice/GetInvoiceDetailsFromId',
        ),
        headers: <String, String>{'token': token},
        body: json.encode(
          {
          "invoice_id":invoiceid
          }
        )
      );
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

  static Future<Map<String, dynamic>> postSalesSaveAPI(
      String customerid,
      String paymenttermsid,
      String invoicedate,
      List<dynamic> items,
      String token,
      BuildContext context) async {
        print(json.encode(
         {
            "customer_id":customerid,
            "payment_terms_id": paymenttermsid,
            "invoice_date": invoicedate,
            "items": items
          }
        ));
    final response = await post(
        Uri.parse(
          '${baseurl}Apidirectinvoice/SaveDirectInvoice',
        ),
        headers: <String, String>{'token': token},
        body: json.encode(
         {
            "customer_id":customerid,
            "payment_terms_id": paymenttermsid,
            "invoice_date": invoicedate,
            "items": items
          }
        )
      );
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


  static Future<List<WarehouseModel>> postWarehouseListAPI(String token,
      String warehouseid, String type, BuildContext context) async {
    final response = await post(
        Uri.parse(
          '${baseurl}Apiiwarehouse/GetTransferWarehouses',
        ),
        headers: <String, String>{'token': token},
        body: json.encode({"from_warehouse_id": warehouseid, "type": type}));
    print(response.body);
    dynamic requestresponse = jsonDecode(response.body);
    if (requestresponse["status"] == "success") {
      final List responselist = requestresponse["data"];
      return responselist.map((json) => WarehouseModel.fromJson(json)).toList();
    } else {
      throw Exception();
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

  static Future<Map<String, dynamic>> getAvailableQuantityAPI(
      String unitid,
      String fromwarehouseid,
      String productid,
      String token,
      BuildContext context) async {
    final response = await post(
        Uri.parse(
          '${baseurl}Apiiwarehouse/GetAvailableQty',
        ),
        headers: <String, String>{'token': token},
        body: json.encode({
          "unit_id": unitid,
          "from_warehouse_id": fromwarehouseid,
          "product_id": productid
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

  static Future<Map<String, dynamic>> postTransferAPI(
      String id,
      String fromwarehouseid,
      String towarehouseid,
      String reference,
      String transferdate,
      String description,
      List<dynamic> items,
      String token,
      BuildContext context) async {
    final response = await post(
        Uri.parse(
          '${baseurl}Apiiwarehouse/SaveTransfer',
        ),
        headers: <String, String>{'token': token},
        body: json.encode({
          "id": id,
          "from_warehouse_id": fromwarehouseid,
          "to_warehouse_id": towarehouseid,
          "reference": reference,
          "transfer_date": transferdate,
          "direct_transfer_description": description,
          "transfer_items": items
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

  static Future<Map<String, dynamic>> getTransferListAPI(
      String term, String token, BuildContext context) async {
    final response = await post(
        Uri.parse(
          '${baseurl}Apiiwarehouse/GetTransferList',
        ),
        headers: <String, String>{'token': token},
        body: json.encode({
          "term": term,
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

  static Future<Map<String, dynamic>> getTransferPDF(String transferid) async {
    String requesturl = '${baseurl}Apiiwarehouse/PrintDirectTransferPDF';
    try {
      final response = await post(Uri.parse(requesturl),
          headers: {"Accept": "application/json"},
          body: json.encode({"id": transferid}));
      if (response.statusCode == 200) {
        final jsondata = json.decode(response.body);
        return jsondata;
      } else {
        return {
          "status": "failed",
          "message": response.reasonPhrase.toString()
        };
      }
    } catch (e) {
      return {"status": "failed", "message": e.toString()};
    }
  }

   static Future<Map<String, dynamic>> getDailyReportPDF(String filterdate, String token) async {
    String requesturl = '${baseurl}Apidirectinvoice/DaysaleSummaryReport';
    try {
      final response = await post(Uri.parse(requesturl),
          headers: <String, String>{'token': token},
          body: json.encode({"from_date": filterdate}));
      if (response.statusCode == 200) {
        final jsondata = json.decode(response.body);
        return jsondata;
      } else {
        return {
          "status": "failed",
          "message": response.reasonPhrase.toString()
        };
      }
    } catch (e) {
      return {"status": "failed", "message": e.toString()};
    }
  }

   static Future<Map<String, dynamic>> getFOCReportPDF(String fromdate, String todate, String productid, String token) async {
    String requesturl = '${baseurl}ApiReport/GetItemWiseSalesFOCReport';
    try {
      final response = await post(Uri.parse(requesturl),
          headers: <String, String>{'token': token},
          body: json.encode({
            "from_date": fromdate,
	"to_date": todate,
	"product_id": productid
          }));
      if (response.statusCode == 200) {
        final jsondata = json.decode(response.body);
        return jsondata;
      } else {
        return {
          "status": "failed",
          "message": response.reasonPhrase.toString()
        };
      }
    } catch (e) {
      return {"status": "failed", "message": e.toString()};
    }
  }
  
  static Future<Map<String, dynamic>> getPrintItemWiseGoodReceiptReportPDF(
      String startdate, String enddate, String type, String token) async {
    String requesturl = '${baseurl}ApiReport/PrintItemWiseGoodReceiptReportPDF';
    try {
      final response = await post(Uri.parse(requesturl),
          headers: <String, String>{'token': token},
          body: json.encode({
            "receipt_from_date": startdate,
            "receipt_to_date": enddate,
            "receipt_type": type
          }));
      if (response.statusCode == 200) {
        final jsondata = json.decode(response.body);
        return jsondata;
      } else {
        return {
          "status": "failed",
          "message": response.reasonPhrase.toString()
        };
      }
    } catch (e) {
      return {"status": "failed", "message": e.toString()};
    }
  }

  static Future<List<WarehouseProductModel>> getProductsListByWarehouseAPI(
      String term,
      String warehouseid,
      String token,
      BuildContext context) async {
    final response = await post(
        Uri.parse(
          '${baseurl}Apiiwarehouse/GetAllProducts',
        ),
        headers: <String, String>{'token': token},
        body: json.encode({"term": term, "from_warehouse_id": warehouseid}));
    print(response.body);
    dynamic requestresponse = jsonDecode(response.body);
    if (requestresponse["status"] == "success") {
      final List responselist = requestresponse["data"];
      return responselist
          .map((json) => WarehouseProductModel.fromJson(json))
          .toList();
    } else {
      throw Exception();
    }
  }

  static Future<Map<String, dynamic>> getCurrentStockListAPI(String warehouseid,
      String term, String token, BuildContext context) async {
    print({"warehouse_id": warehouseid, "term": term});
    final response = await post(
        Uri.parse(
          '${baseurl}Apistore/CurrentStock',
        ),
        headers: <String, String>{'token': token},
        body: json.encode({"warehouse_id": warehouseid, "term": term}));
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

  static Future<Map<String, dynamic>> getWarehouseListAPI(
      String token, BuildContext context) async {
    final response = await get(
      Uri.parse(
        '${baseurl}Apistore/WarehouseList',
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

  static String formatDateTime(DateTime dateTime) {
    DateFormat formatter = DateFormat('dd / MM / yyyy h:mm a');
    return formatter.format(dateTime);
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
      String appdevicesettings,
      String appstore,
      String defaultwarehouseid,
      String defaultwarehousename,
      String defaultprintcheck,
      String apptransfer,
      String warehouseid
      ) async {
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
    poscache.setString('app_store', appstore);
    poscache.setString('default_warehouse_id', defaultwarehouseid);
    poscache.setString('default_warehouse_name', defaultwarehousename);
    poscache.setString('default_print_check', defaultprintcheck);
    poscache.setString('app_transfer', apptransfer);
    poscache.setString('warehouse_id', warehouseid);
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
      String? appstore = poscache.getString('app_store');
      String? defaultwarehouseid = poscache.getString('default_warehouse_id');
      String? defaultwarehousename =
          poscache.getString('default_warehouse_name');
      String? defaultprintcheck = poscache.getString('default_print_check');
      String? apptransfer = poscache.getString('app_transfer');
      String? warehouseid = poscache.getString('warehouse_id');

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
        'app_device_settings': appdevicesettings,
        'app_store': appstore,
        'default_warehouse_id': defaultwarehouseid,
        'default_warehouse_name': defaultwarehousename,
        'default_print_check': defaultprintcheck,
        'app_transfer': apptransfer,
        'warehouse_id':warehouseid
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

  static Future<Map<String, dynamic>> addPrinterDetails(
    String btname,
    String btaddress,
  ) async {
    SharedPreferences blueskyesellcache = await SharedPreferences.getInstance();
    blueskyesellcache.setString('btname', btname);
    blueskyesellcache.setString('btaddress', btaddress);
    return {
      'status': 'success',
    };
  }

  static Future<Map<String, dynamic>> getPrinterDetails() async {
    SharedPreferences blueskyesellcache = await SharedPreferences.getInstance();
    if (blueskyesellcache.containsKey('btname')) {
      String? btname = blueskyesellcache.getString('btname');
      String? btaddress = blueskyesellcache.getString('btaddress');
      return {
        'status': 'success',
        'btname': btname,
        'btaddress': btaddress,
      };
    } else {
      return {'status': 'failed', 'msg': 'Printer not available'};
    }
  }

  static Future<List<int>> printWithDevice(
    PaperSize paper,
    CapabilityProfile profile,
    Map<String, dynamic> details,
  ) async {
    final Generator ticket = Generator(paper, profile);

    List<int> bytes = [];

    bytes += ticket.text(details["company_name"].toString(),
        styles: const PosStyles(
            fontType: PosFontType.fontA,
            align: PosAlign.center,
            bold: true,
            height: PosTextSize.size3));

    bytes += ticket.hr(ch: '=');
    bytes += ticket.text(details["company_address"].toString(),
        styles: const PosStyles(
            fontType: PosFontType.fontA, align: PosAlign.center, bold: true));
    bytes += ticket.text(details["company_phone"].toString(),
        styles: const PosStyles(
            fontType: PosFontType.fontA, align: PosAlign.center, bold: true));
    bytes += ticket.text("TRN : ${details["company_trn"]}",
        styles: const PosStyles(
            fontType: PosFontType.fontA, align: PosAlign.center, bold: true));
    bytes += ticket.text("");
    bytes += ticket.text("TAX INVOICE",
        styles: const PosStyles(
            fontType: PosFontType.fontA,
            align: PosAlign.center,
            bold: true,
            height: PosTextSize.size2));
    bytes += ticket.text("");

    // Characters available in the width-7 value column for this paper size.
    // esc_pos uses a 12-column grid (~48 chars on 80mm, ~32 on 58mm) and does
    // NOT auto-wrap column text, so we wrap it ourselves.
    final int maxChars = paper == PaperSize.mm58 ? 32 : 48;
    final int valueChars = maxChars * 7 ~/ 12;

    // Split [text] into chunks no longer than [width], breaking on word
    // boundaries where possible and hard-splitting words longer than [width].
    List<String> wrapText(String text, int width) {
      final words = text.trim().split(RegExp(r'\s+'));
      final lines = <String>[];
      var current = '';
      for (final word in words) {
        if (word.isEmpty) continue;
        var w = word;
        while (w.length > width) {
          if (current.isNotEmpty) {
            lines.add(current);
            current = '';
          }
          lines.add(w.substring(0, width));
          w = w.substring(width);
        }
        if (current.isEmpty) {
          current = w;
        } else if (current.length + 1 + w.length <= width) {
          current = '$current $w';
        } else {
          lines.add(current);
          current = w;
        }
      }
      if (current.isNotEmpty) lines.add(current);
      if (lines.isEmpty) lines.add('');
      return lines;
    }

    // Prints a label/value info row, wrapping the value onto extra rows when it
    // is longer than the value column. Label and ":" only show on the first row.
    List<int> infoRow(String label, String value) {
      final lines = wrapText(value, valueChars);
      final List<int> out = [];
      for (var i = 0; i < lines.length; i++) {
        out.addAll(ticket.row([
          PosColumn(
              width: 4,
              text: i == 0 ? label : '',
              styles: const PosStyles(
                  fontType: PosFontType.fontA, align: PosAlign.left)),
          PosColumn(
              width: 1,
              text: i == 0 ? ':' : '',
              styles: const PosStyles(
                  fontType: PosFontType.fontA, align: PosAlign.center)),
          PosColumn(
              text: lines[i],
              width: 7,
              styles: const PosStyles(
                  fontType: PosFontType.fontA,
                  align: PosAlign.left,
                  bold: true)),
        ]));
      }
      return out;
    }

    bytes += infoRow("INVOICE NO", details["invoice_no"].toString());
    bytes += infoRow("INVOICE DATE", details["invoice_date"].toString());
    bytes += infoRow("CUSTOMER NAME", details["customer_name"].toString());
    bytes += infoRow("CUSTOMER TRN NO", details["customer_trn_no"].toString());
    bytes += infoRow("SALESMAN", details["salesman"].toString());
    bytes += infoRow("PAYMENT TYPE", details["payment_type"].toString());


    bytes += ticket.hr(
      ch: '=',
    );
    bytes += ticket.row([
      PosColumn(
          text: 'Item',
          width: 4,
          styles: const PosStyles(fontType: PosFontType.fontA, bold: true)),
      PosColumn(
          text: 'Qty',
          width: 2,
          styles: const PosStyles(fontType: PosFontType.fontA, bold: true,    align: PosAlign.right,)),
      PosColumn(
          text: 'Unit',
          width: 2,
          styles: const PosStyles(fontType: PosFontType.fontA, bold: true,    align: PosAlign.right,)),
      PosColumn(
          text: 'Rate',
          width: 2,
          styles: const PosStyles(
              align: PosAlign.right, fontType: PosFontType.fontA, bold: true)),
      PosColumn(
          text: 'Total',
          width: 2,
          styles: const PosStyles(
              align: PosAlign.right, fontType: PosFontType.fontA, bold: true)),
    ]);
    bytes += ticket.hr(ch: '-');

    for (var item in details["invoice_item_list"]) {
      bytes += ticket.row([
        PosColumn(
            text: item["description"].toString(),
            width: 4,
            styles: const PosStyles(fontType: PosFontType.fontA, bold: true)),
        PosColumn(
            text: item["quantity"].toString(),
            width: 2,
            styles: const PosStyles(fontType: PosFontType.fontA, bold: true,    align: PosAlign.right,)),
        PosColumn(
            text: item["unit_name"].toString(),
            width: 2,
            styles: const PosStyles(fontType: PosFontType.fontA, bold: true,    align: PosAlign.right,)),
        PosColumn(
            text: item["rate"].toString(),
            width: 2,
            styles: const PosStyles(
                align: PosAlign.right,
                fontType: PosFontType.fontA,
                bold: true)),
        PosColumn(
            text: item["total_amount"].toString(),
            width: 2,
            styles: const PosStyles(
                align: PosAlign.right,
                fontType: PosFontType.fontA,
                bold: true)),
      ]);
    }
    bytes += ticket.hr(
      ch: '-',
    );

    bytes += ticket.row([
      PosColumn(
          text: 'Sub Total',
          width: 6,
          styles: const PosStyles(
              align: PosAlign.left, fontType: PosFontType.fontA, bold: true)),
      PosColumn(
          text: details["total_amount"],
          width: 6,
          styles: const PosStyles(
              align: PosAlign.right, fontType: PosFontType.fontA, bold: true)),
    ]);
    bytes += ticket.hr(
      ch: '-',
    );
    bytes += ticket.row([
      PosColumn(
          text: 'VAT amount',
          width: 6,
          styles: const PosStyles(
              align: PosAlign.left, fontType: PosFontType.fontA, bold: true)),
      PosColumn(
          text: details["tax_total"],
          width: 6,
          styles: const PosStyles(
              align: PosAlign.right, fontType: PosFontType.fontA, bold: true)),
    ]);
    bytes += ticket.hr(
      ch: '=',
    );
    bytes += ticket.row([
      PosColumn(
          text: 'Grand Total',
          width: 6,
          styles: const PosStyles(
              align: PosAlign.left, fontType: PosFontType.fontA, bold: true)),
      PosColumn(
          text: details["grand_total"],
          width: 6,
          styles: const PosStyles(
              align: PosAlign.right, fontType: PosFontType.fontA, bold: true)),
    ]);

    bytes += ticket.hr(ch: '-');
    bytes += ticket.text("Thank you for shopping with us",
        styles: const PosStyles(align: PosAlign.center));
    bytes += ticket.hr(ch: '-');
    bytes += ticket.text("Signature/Date",
        styles: const PosStyles(align: PosAlign.center, bold: true));

    bytes += ticket.feed(2);
    bytes += ticket.cut(mode: PosCutMode.full);

    return bytes;
  }
}
