// ignore_for_file: use_build_context_synchronously

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:freshice/backend/api.dart';
import 'package:freshice/frontend/customdrawerscreen.dart';
import 'package:freshice/frontend/successpage.dart';
import 'package:freshice/maindatabase/database.dart';
import 'package:freshice/maindatabase/databasemodels/inventorydatabasemodel.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:route_transitions/route_transitions.dart';

class CloudSyncScreen extends StatefulWidget {
  final String token;

  const CloudSyncScreen({super.key, required this.token});

  @override
  State<CloudSyncScreen> createState() => _CloudSyncScreenState();
}

class _CloudSyncScreenState extends State<CloudSyncScreen> {
  List<dynamic> tables = [];
  List<dynamic> transferids = [];
  Map<String, dynamic> companydetails = {};

  bool loading = false;
  bool syncing = false;
  bool closinginventory = false;
  bool closinginvoice = false;

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
  //     setState(() {
  //       loading = true;
  //     });
  //     final dynamic response =
  //         await API.getSyncTablesAPI(widget.token, context);
  //     print("This is the response");
  //     print(response);
  //     setState(() {
  //       tables = response["status"] == "success" ? response["data"] : [];
  //       companydetails = response["status"] == "success"
  //           ? {
  //               "last_invoiced_no": response["last_invoiced_no"],
  //               "next_invoice_no": response["next_invoice_no"],
  //               "warehouse_id": response["warehouse_id"]
  //             }
  //           : {};
  //       transferids =
  //           response["status"] == "success" ? response["transfer_ids"] : [];
  //       loading = false;
  //     });
  //     print(" this is the transfer");
  //     print(transferids);
  //   });
  // }

  String transformString(String input) {
    if (input.startsWith('pos_')) {
      input = input.substring(4);
    }
    if (input.isNotEmpty) {
      input = input[0].toUpperCase() + input.substring(1);
    }
    return input;
  }

  String formatDateTime(String input) {
    DateTime dateTime = DateTime.parse(input);

    String formattedDate = DateFormat('dd / MM / yyyy').format(dateTime);
    String formattedTime = DateFormat('hh : mm a').format(dateTime);

    return '$formattedDate $formattedTime';
  }

  DateTime convertDateTime(String input) {
    DateTime dateTime = DateTime.parse(input);
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  Future<bool> onWillPop() async {
    final shouldPop = await onClosePopUp(context);
    if (shouldPop == true) {
      Navigator.pop(context);
    }
    return shouldPop ?? false;
  }

  static dynamic onClosePopUp(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                "Are you sure ?",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: API.textcolor,
                ),
              ),
              content: SizedBox(
                height: 52,
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
                        "Do you want to leave this screen?.Please note that leaving the screen while syncing the data may face data loss.",
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
                height: 52,
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
                        "Please note that leaving the screen while syncing the data may result data loss.Can we proceed to sync your data?",
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

  Future<List<dynamic>> convertInventory(List<dynamic> details) async {
    List<dynamic> result = [];
    for (int i = 0; i < details.length; i++) {
      result.add({
        "product_id": details[i]["id"].toString(),
        "quantity": details[i]["available_qty"].toString(),
        "unit_id": details[i]["default_unit_id"].toString()
      });
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: API.backgroundsubcolor,
          leading: IconButton(
              onPressed: onWillPop,
              icon: FaIcon(
                FontAwesomeIcons.arrowLeft,
                color: API.buttoncolor,
                size: 20,
              )),
          centerTitle: true,
          title: Text(
            "Cloud Sync",
            style: TextStyle(
                color: API.buttoncolor,
                fontSize: 16,
                fontWeight: FontWeight.w300),
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: API.backgroundsubcolor,
          child: loading
              ? API.loadingScreen(context)
              : syncing
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 3,
                          width: MediaQuery.of(context).size.width / 1.2,
                          child:
                              Lottie.asset("assets/images/cloudloading.json"),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 50),
                          child: Text(
                            "Syncing ...please wait...\nclosing the screen while syncing may result in data loss.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: API.textcolor,
                                fontSize: 14,
                                fontWeight: FontWeight.w400),
                          ),
                        )
                      ],
                    )
                  : Column(
                      children: [
                        FutureBuilder(
                            future: FreshIceDatabase.instance.getCompanyById(1),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                Map<String, dynamic>? companyresponse =
                                    snapshot.data;
                                return companyresponse!["status"] == 0
                                    ? const SizedBox()
                                    : Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                      border: Border.all(
                                                          color: API.appcolor)),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 3,
                                                            bottom: 3,
                                                            left: 8,
                                                            right: 8),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 4),
                                                          child: Text(
                                                            "Last Synced",
                                                            style: TextStyle(
                                                                color: API
                                                                    .textcolor,
                                                                fontSize: 9,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300),
                                                          ),
                                                        ),
                                                        Text(
                                                          formatDateTime(
                                                              companyresponse[
                                                                          "data"]
                                                                      [
                                                                      "last_local_synced"]
                                                                  .toString()),
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.teal,
                                                              overflow:
                                                                  TextOverflow
                                                                      .visible,
                                                              fontSize: 9,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Divider(
                                            height: 5,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height: 50,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2.1,
                                                // color: Colors.red,
                                                child: Card(
                                                  elevation: 10,
                                                  semanticContainer: true,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 4),
                                                        child: Text(
                                                          "Last Invoice No",
                                                          style: TextStyle(
                                                              color:
                                                                  API.textcolor,
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300),
                                                        ),
                                                      ),
                                                      Text(
                                                        companyresponse["data"][
                                                                "last_invoiced_no"]
                                                            .toString(),
                                                        style: TextStyle(
                                                            color:
                                                                API.textcolor,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 50,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2.1,
                                                // color: Colors.red,
                                                child: Card(
                                                  elevation: 10,
                                                  semanticContainer: true,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 4),
                                                        child: Text(
                                                          "Next Invoice No",
                                                          style: TextStyle(
                                                              color:
                                                                  API.textcolor,
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300),
                                                        ),
                                                      ),
                                                      Text(
                                                        companyresponse!["data"]
                                                                [
                                                                "next_invoice_no"]
                                                            .toString(),
                                                        style: TextStyle(
                                                            color:
                                                                API.textcolor,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                              } else {
                                return const SizedBox();
                              }
                            }),
                        // Wrap(
                        //   children: tables.map<Widget>((e) {
                        //     return GestureDetector(
                        //       onTap: () {},
                        //       child: Padding(
                        //         padding:
                        //             const EdgeInsets.symmetric(horizontal: 10),
                        //         child: Card(
                        //           elevation: 10,
                        //           semanticContainer: true,
                        //           child: ListTile(
                        //             leading: SizedBox(
                        //                 height: 30,
                        //                 child: Image.asset(
                        //                     "assets/images/database.png")),
                        //             title: Text(
                        //               transformString(e["table"].toString()),
                        //               style: TextStyle(
                        //                   color: API.textcolor,
                        //                   fontSize: 13,
                        //                   fontWeight: FontWeight.w400),
                        //             ),
                        //             trailing: const Icon(
                        //               Icons.keyboard_arrow_right_outlined,
                        //               color: Colors.grey,
                        //               size: 20,
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     );
                        //   }).toList(),
                        // ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: const [
                            Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Text(
                                "From Cloud",
                                style: TextStyle(
                                    color: Colors.teal,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FutureBuilder(
                                future:
                                    FreshIceDatabase.instance.getCompanyById(1),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    Map<String, dynamic>? companyresponse =
                                        snapshot.data;
                                    return companyresponse!["status"] == 0
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: GestureDetector(
                                              onTap: () async {
                                                final connectivityResult =
                                                    await Connectivity()
                                                        .checkConnectivity();
                                                if (connectivityResult ==
                                                    ConnectivityResult.none) {
                                                  showDialog(
                                                    barrierDismissible: false,
                                                    context: context,
                                                    builder: (_) =>
                                                        API.alertboxScreen(
                                                            context),
                                                  );
                                                } else {
                                                  final shouldPop =
                                                      await onAlertPopUp(
                                                          context);
                                                  if (shouldPop == true) {
                                                    setState(() {
                                                      syncing = true;
                                                    });
                                                    final dynamic response =
                                                        await API
                                                            .getSyncTablesAPI(
                                                                widget.token,
                                                                context);
                                                    setState(() {
                                                      tables =
                                                          response["status"] ==
                                                                  "success"
                                                              ? response["data"]
                                                              : [];
                                                      companydetails =
                                                          response["status"] ==
                                                                  "success"
                                                              ? {
                                                                  "last_invoiced_no":
                                                                      response[
                                                                          "last_invoiced_no"],
                                                                  "next_invoice_no":
                                                                      response[
                                                                          "next_invoice_no"],
                                                                  "warehouse_id":
                                                                      response[
                                                                          "warehouse_id"]
                                                                }
                                                              : {};
                                                      transferids = response[
                                                                  "status"] ==
                                                              "success"
                                                          ? response[
                                                              "transfer_ids"]
                                                          : [];
                                                    });
                                                    final dynamic syncresponse =
                                                        await FreshIceDatabase
                                                            .instance
                                                            .insertDataAndMarkSelected(
                                                                tables);
                                                    if (syncresponse[
                                                            'status'] ==
                                                        'success') {
                                                      final dynamic
                                                          invoicenosyncresponse =
                                                          await FreshIceDatabase
                                                              .instance
                                                              .createOrUpdateCompany({
                                                        "id": 1,
                                                        "lastinvoicedno":
                                                            companydetails[
                                                                    "last_invoiced_no"]
                                                                .toString(),
                                                        "nextinvoiceno":
                                                            companydetails[
                                                                    "next_invoice_no"]
                                                                .toString(),
                                                        "warehouseid":
                                                            companydetails[
                                                                    "warehouse_id"]
                                                                .toString(),
                                                        "lastlocalsynced":
                                                            DateTime.now()
                                                                .toString()
                                                      });
                                                      if (invoicenosyncresponse[
                                                              "status"] ==
                                                          1) {
                                                        final dynamic
                                                            transferresponse =
                                                            await API
                                                                .postSyncTransferAPI(
                                                                    transferids,
                                                                    widget
                                                                        .token,
                                                                    context);
                                                        if (transferresponse[
                                                                "status"] ==
                                                            "success") {
                                                          setState(() {
                                                            syncing = false;
                                                          });
                                                        } else {
                                                          setState(() {
                                                            syncing = false;
                                                          });
                                                          API.showSnackBar(
                                                              'failed',
                                                              transferresponse[
                                                                      "message"]
                                                                  .toString(),
                                                              context);
                                                        }
                                                      } else {
                                                        setState(() {
                                                          syncing = false;
                                                        });
                                                        API.showSnackBar(
                                                            'failed',
                                                            invoicenosyncresponse[
                                                                    "message"]
                                                                .toString(),
                                                            context);
                                                      }
                                                    } else {
                                                      setState(() {
                                                        syncing = false;
                                                      });
                                                      API.showSnackBar(
                                                          'failed',
                                                          'There is an issue while restoring your data.Please contact software provider',
                                                          context);
                                                    }
                                                  }
                                                }
                                              },
                                              child: Container(
                                                height: 40,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2.3,
                                                decoration: BoxDecoration(
                                                  color: API.appcolor,
                                                  borderRadius:
                                                      BorderRadius.circular(40),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    const Text(
                                                      "Opening",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    ),
                                                    SizedBox(
                                                        height: 30,
                                                        width: 30,
                                                        child: Image.asset(
                                                            "assets/images/down.png"))
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        : AbsorbPointer(
                                            absorbing: convertDateTime(
                                                        companyresponse["data"][
                                                            "last_local_synced"]) ==
                                                    DateTime(
                                                        DateTime.now().year,
                                                        DateTime.now().month,
                                                        DateTime.now().day)
                                                ? true
                                                : false,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: GestureDetector(
                                                onTap: () async {
                                                  final connectivityResult =
                                                      await Connectivity()
                                                          .checkConnectivity();
                                                  if (connectivityResult ==
                                                      ConnectivityResult.none) {
                                                    showDialog(
                                                      barrierDismissible: false,
                                                      context: context,
                                                      builder: (_) =>
                                                          API.alertboxScreen(
                                                              context),
                                                    );
                                                  } else {
                                                    final shouldPop =
                                                        await onAlertPopUp(
                                                            context);
                                                    if (shouldPop == true) {
                                                      setState(() {
                                                        syncing = true;
                                                      });
                                                      final dynamic response =
                                                          await API
                                                              .getSyncTablesAPI(
                                                                  widget.token,
                                                                  context);
                                                      setState(() {
                                                        tables = response[
                                                                    "status"] ==
                                                                "success"
                                                            ? response["data"]
                                                            : [];
                                                        companydetails =
                                                            response["status"] ==
                                                                    "success"
                                                                ? {
                                                                    "last_invoiced_no":
                                                                        response[
                                                                            "last_invoiced_no"],
                                                                    "next_invoice_no":
                                                                        response[
                                                                            "next_invoice_no"],
                                                                    "warehouse_id":
                                                                        response[
                                                                            "warehouse_id"]
                                                                  }
                                                                : {};
                                                        transferids = response[
                                                                    "status"] ==
                                                                "success"
                                                            ? response[
                                                                "transfer_ids"]
                                                            : [];
                                                      });
                                                      final dynamic
                                                          syncresponse =
                                                          await FreshIceDatabase
                                                              .instance
                                                              .insertDataAndMarkSelected(
                                                                  tables);
                                                      if (syncresponse[
                                                              'status'] ==
                                                          'success') {
                                                        final dynamic
                                                            invoicenosyncresponse =
                                                            await FreshIceDatabase
                                                                .instance
                                                                .createOrUpdateCompany({
                                                          "id": 1,
                                                          "lastinvoicedno":
                                                              companydetails[
                                                                      "last_invoiced_no"]
                                                                  .toString(),
                                                          "nextinvoiceno":
                                                              companydetails[
                                                                      "next_invoice_no"]
                                                                  .toString(),
                                                          "warehouseid":
                                                              companydetails[
                                                                      "warehouse_id"]
                                                                  .toString(),
                                                          "lastlocalsynced":
                                                              DateTime.now()
                                                                  .toString()
                                                        });
                                                        if (invoicenosyncresponse[
                                                                "status"] ==
                                                            1) {
                                                          final dynamic
                                                              transferresponse =
                                                              await API
                                                                  .postSyncTransferAPI(
                                                                      transferids,
                                                                      widget
                                                                          .token,
                                                                      context);
                                                          if (transferresponse[
                                                                  "status"] ==
                                                              "success") {
                                                            setState(() {
                                                              syncing = false;
                                                            });
                                                          } else {
                                                            setState(() {
                                                              syncing = false;
                                                            });
                                                            API.showSnackBar(
                                                                'failed',
                                                                transferresponse[
                                                                        "message"]
                                                                    .toString(),
                                                                context);
                                                          }
                                                        } else {
                                                          setState(() {
                                                            syncing = false;
                                                          });
                                                          API.showSnackBar(
                                                              'failed',
                                                              invoicenosyncresponse[
                                                                      "message"]
                                                                  .toString(),
                                                              context);
                                                        }
                                                      } else {
                                                        setState(() {
                                                          syncing = false;
                                                        });
                                                        API.showSnackBar(
                                                            'failed',
                                                            'There is an issue while restoring your data.Please contact software provider',
                                                            context);
                                                      }
                                                    }
                                                  }
                                                },
                                                child: Container(
                                                  height: 40,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2.3,
                                                  decoration: BoxDecoration(
                                                    color: convertDateTime(
                                                                companyresponse[
                                                                        "data"][
                                                                    "last_local_synced"]) ==
                                                            DateTime(
                                                                DateTime.now()
                                                                    .year,
                                                                DateTime.now()
                                                                    .month,
                                                                DateTime.now()
                                                                    .day)
                                                        ? Colors.red
                                                        : API.appcolor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            40),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Text(
                                                        convertDateTime(companyresponse[
                                                                        "data"][
                                                                    "last_local_synced"]) ==
                                                                DateTime(
                                                                    DateTime.now()
                                                                        .year,
                                                                    DateTime.now()
                                                                        .month,
                                                                    DateTime.now()
                                                                        .day)
                                                            ? "Already Synced"
                                                            : "Opening",
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                      SizedBox(
                                                          height: 30,
                                                          width: 30,
                                                          child: convertDateTime(
                                                                      companyresponse[
                                                                              "data"]
                                                                          [
                                                                          "last_local_synced"]) ==
                                                                  DateTime(
                                                                      DateTime.now()
                                                                          .year,
                                                                      DateTime.now()
                                                                          .month,
                                                                      DateTime.now()
                                                                          .day)
                                                              ? Image.asset(
                                                                  "assets/images/stamp.png")
                                                              : Image.asset(
                                                                  "assets/images/down.png"))
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                  } else {
                                    return const SizedBox();
                                  }
                                }),
                            FutureBuilder(
                                future:
                                    FreshIceDatabase.instance.getCompanyById(1),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    Map<String, dynamic>? companyresponse =
                                        snapshot.data;
                                    return companyresponse!["status"] == 0
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: SizedBox(
                                                height: 40,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2.3),
                                          )
                                        : convertDateTime(companyresponse[
                                                        "data"]
                                                    ["last_local_synced"]) ==
                                                DateTime(
                                                    DateTime.now().year,
                                                    DateTime.now().month,
                                                    DateTime.now().day)
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    final connectivityResult =
                                                        await Connectivity()
                                                            .checkConnectivity();
                                                    if (connectivityResult ==
                                                        ConnectivityResult
                                                            .none) {
                                                      showDialog(
                                                        barrierDismissible:
                                                            false,
                                                        context: context,
                                                        builder: (_) =>
                                                            API.alertboxScreen(
                                                                context),
                                                      );
                                                    } else {
                                                      final shouldPop =
                                                          await onAlertPopUp(
                                                              context);
                                                      if (shouldPop == true) {
                                                        setState(() {
                                                          syncing = true;
                                                        });
                                                        final dynamic
                                                            inventorysyncresponse =
                                                            await API
                                                                .postIntermediateSyncAPI(
                                                                    widget
                                                                        .token,
                                                                    context);
                                                        if (inventorysyncresponse[
                                                                "status"] ==
                                                            "success") {
                                                          final dynamic
                                                              syncinventorytodbresponse =
                                                              await FreshIceDatabase
                                                                  .instance
                                                                  .intermediateInventorySync(
                                                                      inventorysyncresponse[
                                                                          "details"]);
                                                          if (syncinventorytodbresponse[
                                                                      "status"]
                                                                  .toString() ==
                                                              "1") {
                                                            final dynamic
                                                                transferresponse =
                                                                await API.postSyncTransferAPI(
                                                                    inventorysyncresponse[
                                                                        "transfer_ids"],
                                                                    widget
                                                                        .token,
                                                                    context);
                                                            if (transferresponse[
                                                                    "status"] ==
                                                                "success") {
                                                              pushWidgetWhileRemove(
                                                                  newPage: const SuccessPage(
                                                                      screen:
                                                                          CustomDrawerScreen()),
                                                                  context:
                                                                      context);
                                                            } else {
                                                              setState(() {
                                                                syncing = false;
                                                              });
                                                              API.showSnackBar(
                                                                  'failed',
                                                                  transferresponse[
                                                                          "message"]
                                                                      .toString(),
                                                                  context);
                                                            }
                                                          } else {
                                                            setState(() {
                                                              syncing = false;
                                                            });
                                                            API.showSnackBar(
                                                                "failed",
                                                                syncinventorytodbresponse[
                                                                        "message"]
                                                                    .toString(),
                                                                context);
                                                          }
                                                        } else {
                                                          setState(() {
                                                            syncing = false;
                                                          });
                                                          API.showSnackBar(
                                                              "failed",
                                                              inventorysyncresponse[
                                                                      "message"]
                                                                  .toString(),
                                                              context);
                                                        }
                                                      }
                                                    }
                                                  },
                                                  child: Container(
                                                    height: 40,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            2.3,
                                                    decoration: BoxDecoration(
                                                      color: API.appcolor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              40),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        const Text(
                                                          "Sync Inventory",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                        SizedBox(
                                                            height: 30,
                                                            width: 30,
                                                            child: Image.asset(
                                                                "assets/images/down.png"))
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                child: SizedBox(
                                                    height: 40,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            2.3),
                                              );
                                  } else {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: SizedBox(
                                          height: 40,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.3),
                                    );
                                  }
                                }),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: const [
                            Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Text(
                                "To Cloud",
                                style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: GestureDetector(
                                onTap: () async {
                                  final connectivityResult =
                                      await Connectivity().checkConnectivity();
                                  if (connectivityResult ==
                                      ConnectivityResult.none) {
                                    showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (_) =>
                                          API.alertboxScreen(context),
                                    );
                                  } else {
                                    final shouldPop =
                                        await onAlertPopUp(context);
                                    if (shouldPop == true) {
                                      setState(() {
                                        syncing = true;
                                      });
                                      await FreshIceDatabase.instance
                                          .getUnsyncedSalesHeadRecordsAndSync(
                                              widget.token, context)
                                          .then((value) {
                                        if (value["status"] == "success") {
                                          if (value["unsynced_records"].length >
                                              0) {
                                            setState(() {
                                              syncing = false;
                                            });
                                            API.showSnackBar(
                                                "failed",
                                                "Some records didnt synced.please check in your sales invoice screen",
                                                context);
                                          } else {
                                            pushWidgetWhileRemove(
                                                newPage: const SuccessPage(
                                                    screen:
                                                        CustomDrawerScreen()),
                                                context: context);
                                          }
                                        } else {
                                          setState(() {
                                            syncing = false;
                                          });
                                          API.showSnackBar(
                                              "failed",
                                              value["message"].toString(),
                                              context);
                                        }
                                      });
                                    }
                                  }
                                },
                                child: Container(
                                  height: 40,
                                  width:
                                      MediaQuery.of(context).size.width / 2.3,
                                  decoration: BoxDecoration(
                                    color: Colors.indigo,
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      const Text(
                                        "Sync Invoices",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      SizedBox(
                                          height: 30,
                                          width: 30,
                                          child: Image.asset(
                                              "assets/images/up.png"))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: GestureDetector(
                                onTap: () async {
                                  final connectivityResult =
                                      await Connectivity().checkConnectivity();
                                  if (connectivityResult ==
                                      ConnectivityResult.none) {
                                    showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (_) =>
                                          API.alertboxScreen(context),
                                    );
                                  } else {
                                    final shouldPop =
                                        await onAlertPopUp(context);
                                    if (shouldPop == true) {
                                      setState(() {
                                        syncing = true;
                                      });
                                      final dynamic inventorylistresponse =
                                          await FreshIceDatabase.instance
                                              .allInventoryList();
                                      print(inventorylistresponse);
                                      if (inventorylistresponse.length > 0) {
                                        final dynamic convertresponse =
                                            await convertInventory(
                                                inventorylistresponse);
                                        final dynamic syncinventoryresponse =
                                            await API
                                                .postSyncBalanceInventoryAPI(
                                                    convertresponse,
                                                    widget.token,
                                                    context);
                                        if (syncinventoryresponse["status"] ==
                                            "success") {
                                          final dynamic clearresponse =
                                              await FreshIceDatabase.instance
                                                  .deleteAllFromTable(
                                                      tableDatabaseInventory);
                                          if (clearresponse["status"]
                                                  .toString() ==
                                              "1") {
                                            await FreshIceDatabase.instance
                                                .getUnsyncedSalesHeadRecordsAndSync(
                                                    widget.token, context)
                                                .then((value) {
                                              if (value["status"] ==
                                                  "success") {
                                                if (value["unsynced_records"]
                                                        .length >
                                                    0) {
                                                  setState(() {
                                                    syncing = false;
                                                  });
                                                  API.showSnackBar(
                                                      "success",
                                                      "Inventory syncing is completed but Some Invoice records didnt synced.please check in your sales invoice screen",
                                                      context);
                                                } else {
                                                  pushWidgetWhileRemove(
                                                      newPage: const SuccessPage(
                                                          screen:
                                                              CustomDrawerScreen()),
                                                      context: context);
                                                }
                                              } else {
                                                setState(() {
                                                  syncing = false;
                                                });
                                                API.showSnackBar(
                                                    "failed",
                                                    value["message"].toString(),
                                                    context);
                                              }
                                            });
                                          } else {
                                            setState(() {
                                              syncing = false;
                                            });
                                            API.showSnackBar(
                                                "failed",
                                                clearresponse["message"]
                                                    .toString(),
                                                context);
                                          }
                                        } else {
                                          setState(() {
                                            syncing = false;
                                          });
                                          API.showSnackBar(
                                              "failed",
                                              syncinventoryresponse["message"]
                                                  .toString(),
                                              context);
                                        }
                                      } else {
                                        setState(() {
                                          syncing = false;
                                        });
                                        API.showSnackBar(
                                            "failed",
                                            "There is no inventory available in the table",
                                            context);
                                      }
                                    }
                                  }
                                },
                                child: Container(
                                  height: 40,
                                  width:
                                      MediaQuery.of(context).size.width / 2.3,
                                  decoration: BoxDecoration(
                                    color: Colors.indigo,
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      const Text(
                                        "Day Close",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      SizedBox(
                                          height: 30,
                                          width: 30,
                                          child: Image.asset(
                                              "assets/images/up.png"))
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
        ),
      ),
    );
  }
}
