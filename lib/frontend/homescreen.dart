// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously, prefer_const_literals_to_create_immutables

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:freshice/backend/api.dart';
import 'package:freshice/frontend/addproduction.dart';
import 'package:freshice/frontend/addsalesscreen.dart';
import 'package:freshice/frontend/cloudsync.dart';
import 'package:freshice/frontend/customersscreen.dart';
import 'package:freshice/frontend/inventoryscreen.dart';
import 'package:freshice/frontend/notifications.dart';
import 'package:freshice/frontend/saleslistscreen.dart';
import 'package:freshice/frontend/settingsscreen.dart';
import 'package:freshice/maindatabase/database.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userdetails;
  final zoomdrawerdontroller;
  const HomeScreen(
      {super.key,
      required this.userdetails,
      required this.zoomdrawerdontroller});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChartData> dashboarddetails = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      setState(() {
        loading = true;
      });
      final dynamic response =
          await FreshIceDatabase.instance.getSalesHeadRecordsCountByDayOfWeek();

      final dynamic chartresponse = await convertToChartData(response);
      print("this is the user details");
      print(widget.userdetails);
      setState(() {
        dashboarddetails = chartresponse;
        loading = false;
      });
    });
  }

  Future<List<ChartData>> convertToChartData(List<dynamic> details) async {
    List<ChartData> result = [];
    for (int i = 0; i < details.length; i++) {
      result.add(ChartData(details[i]["day"].toString(),
          double.parse(details[i]["count"].toString())));
    }
    return result;
  }

  bool loading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              widget.zoomdrawerdontroller.toggle();
            },
            icon: FaIcon(
              FontAwesomeIcons.barsStaggered,
              color: API.buttoncolor,
              size: 20,
            )),
        centerTitle: true,
        title: Text(
          "Fresh Ice Factory",
          style: TextStyle(
              color: API.buttoncolor,
              fontSize: 16,
              fontWeight: FontWeight.w300),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
                width: 50,
                height: 50,
                child: Image.asset("assets/images/freshice.png")),
          ),
          // IconButton(
          //     onPressed: () {
          //       slideRightWidget(
          //           newPage: const NotificationsScreen(), context: context);
          //     },
          //     icon: FaIcon(
          //       FontAwesomeIcons.bell,
          //       color: API.buttoncolor,
          //       size: 20,
          //     ))
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: loading
            ? API.loadingScreen(context)
            : Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  FutureBuilder(
                      future: FreshIceDatabase.instance.checkCustomerTable(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          bool issynced =
                              snapshot.data!["status"].toString() == "1"
                                  ? true
                                  : false;
                          return issynced
                              ? Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Container(
                                        height: 20,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 30),
                                          child: Row(
                                            children: [
                                              Text(
                                                "Weekly Sales",
                                                style: TextStyle(
                                                    color: API.buttoncolor,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w300),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2),
                                      child: Container(
                                        height: issynced
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                2.8
                                            : (MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    2.8) -
                                                50,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: SfCartesianChart(
                                                    primaryXAxis:
                                                        CategoryAxis(),
                                                    primaryYAxis: NumericAxis(
                                                        minimum: 0,
                                                        maximum: 40,
                                                        interval: 10),
                                                    tooltipBehavior:
                                                        TooltipBehavior(
                                                            enable: true),
                                                    series: <
                                                        CartesianSeries<
                                                            ChartData, String>>[
                                                  BarSeries<ChartData, String>(
                                                      dataSource:
                                                          dashboarddetails,
                                                      xValueMapper:
                                                          (ChartData data, _) =>
                                                              data.x,
                                                      yValueMapper:
                                                          (ChartData data, _) =>
                                                              data.y,
                                                      name: 'Sales',
                                                      color: API.appcolor)
                                                ])),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    Container(
                                      height: 50,
                                      width: MediaQuery.of(context).size.width,
                                      child: Card(
                                        elevation: 10,
                                        semanticContainer: true,
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 8),
                                                  child: Text(
                                                    "Database Sync Notice",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                              ],
                                            )),
                                            GestureDetector(
                                              onTap: () {
                                                slideRightWidget(
                                                    newPage: CloudSyncScreen(
                                                      token: widget
                                                          .userdetails["token"]
                                                          .toString(),
                                                    ),
                                                    context: context);
                                              },
                                              child: Container(
                                                height: 40,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2.3,
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(40),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    const Text(
                                                      "Sync Now",
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
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Container(
                                        height: 20,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 30),
                                          child: Row(
                                            children: [
                                              Text(
                                                "Weekly Sales",
                                                style: TextStyle(
                                                    color: API.buttoncolor,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w300),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2),
                                      child: Container(
                                        height: issynced
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                2.8
                                            : (MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    2.8) -
                                                50,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: SfCartesianChart(
                                                    primaryXAxis:
                                                        CategoryAxis(),
                                                    primaryYAxis: NumericAxis(
                                                        minimum: 0,
                                                        maximum: 40,
                                                        interval: 10),
                                                    tooltipBehavior:
                                                        TooltipBehavior(
                                                            enable: true),
                                                    series: <
                                                        CartesianSeries<
                                                            ChartData, String>>[
                                                  BarSeries<ChartData, String>(
                                                      dataSource:
                                                          dashboarddetails,
                                                      xValueMapper:
                                                          (ChartData data, _) =>
                                                              data.x,
                                                      yValueMapper:
                                                          (ChartData data, _) =>
                                                              data.y,
                                                      name: 'Sales',
                                                      color: API.appcolor)
                                                ])),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                  ],
                                );
                        } else {
                          return SizedBox(
                            height: 0,
                          );
                        }
                      }),
                  Container(
                    height: MediaQuery.of(context).size.height / 2.28,
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                      color: API.appcolor,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20))),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          widget.userdetails["app_direct_sale"].toString() ==
                                  "1"
                              ? GestureDetector(
                                  onTap: () {
                                    slideRightWidget(
                                        newPage: AddSalesScreen(
                                          userid: widget.userdetails["userid"]
                                              .toString(),
                                        ),
                                        context: context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              10,
                                      child: Card(
                                        elevation: 10,
                                        semanticContainer: true,
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: FaIcon(
                                                FontAwesomeIcons.fileCirclePlus,
                                                color: API.appcolor,
                                              ),
                                            ),
                                            Expanded(
                                                child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                              child: Text(
                                                "Add Direct Sale",
                                                style: TextStyle(
                                                    color: API.textcolor,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            )),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 20),
                                              child: FaIcon(
                                                FontAwesomeIcons.angleRight,
                                                color: API.appcolor,
                                                size: 25,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Wrap(
                              alignment: WrapAlignment.spaceAround,
                              children: [
                                widget.userdetails["app_sales"].toString() ==
                                        "1"
                                    ? GestureDetector(
                                        onTap: () {
                                          slideRightWidget(
                                              newPage: SalesListScreen(
                                                token: widget
                                                    .userdetails["token"]
                                                    .toString(),
                                              ),
                                              context: context);
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.2,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              10,
                                          child: Card(
                                            elevation: 10,
                                            semanticContainer: true,
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10),
                                                  child: FaIcon(
                                                    FontAwesomeIcons
                                                        .fileCircleCheck,
                                                    color: API.appcolor,
                                                  ),
                                                ),
                                                Expanded(
                                                    child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 8),
                                                  child: Text(
                                                    "Sales",
                                                    style: TextStyle(
                                                        color: API.textcolor,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                ))
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
                                widget.userdetails["app_production"]
                                            .toString() ==
                                        "1"
                                    ? GestureDetector(
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
                                                  API.alertboxScreen(context),
                                            );
                                          } else {
                                            slideRightWidget(
                                                newPage: AddProductionScreen(
                                                  token: widget
                                                      .userdetails["token"]
                                                      .toString(),
                                                ),
                                                context: context);
                                          }
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.2,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              10,
                                          child: Card(
                                            elevation: 10,
                                            semanticContainer: true,
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10),
                                                  child: FaIcon(
                                                    FontAwesomeIcons.industry,
                                                    color: API.appcolor,
                                                  ),
                                                ),
                                                Expanded(
                                                    child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 8),
                                                  child: Text(
                                                    "Production",
                                                    style: TextStyle(
                                                        color: API.textcolor,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                ))
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
                                widget.userdetails["app_customers"]
                                            .toString() ==
                                        "1"
                                    ? GestureDetector(
                                        onTap: () {
                                          slideRightWidget(
                                              newPage: const CustomerScreen(),
                                              context: context);
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.2,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              10,
                                          child: Card(
                                            elevation: 10,
                                            semanticContainer: true,
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10),
                                                  child: FaIcon(
                                                    FontAwesomeIcons.userGroup,
                                                    color: API.appcolor,
                                                  ),
                                                ),
                                                Expanded(
                                                    child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 8),
                                                  child: Text(
                                                    "Customers",
                                                    style: TextStyle(
                                                        color: API.textcolor,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                ))
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
                                widget.userdetails["app_inventory"]
                                            .toString() ==
                                        "1"
                                    ? GestureDetector(
                                        onTap: () {
                                          slideRightWidget(
                                              newPage: const InventoryList(),
                                              context: context);
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.2,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              10,
                                          child: Card(
                                            elevation: 10,
                                            semanticContainer: true,
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10),
                                                  child: FaIcon(
                                                    FontAwesomeIcons.cubes,
                                                    color: API.appcolor,
                                                  ),
                                                ),
                                                Expanded(
                                                    child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 8),
                                                  child: Text(
                                                    "Inventory",
                                                    style: TextStyle(
                                                        color: API.textcolor,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                ))
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
                                widget.userdetails["app_cloud_sync"]
                                            .toString() ==
                                        "1"
                                    ? GestureDetector(
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
                                                  API.alertboxScreen(context),
                                            );
                                          } else {
                                            slideRightWidget(
                                                newPage: CloudSyncScreen(
                                                  token: widget
                                                      .userdetails["token"]
                                                      .toString(),
                                                ),
                                                context: context);
                                          }
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.2,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              10,
                                          child: Card(
                                            elevation: 10,
                                            semanticContainer: true,
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10),
                                                  child: FaIcon(
                                                    FontAwesomeIcons.sync,
                                                    color: API.appcolor,
                                                  ),
                                                ),
                                                Expanded(
                                                    child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 8),
                                                  child: Text(
                                                    "Cloud Sync",
                                                    style: TextStyle(
                                                        color: API.textcolor,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                ))
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
                                widget.userdetails["app_device_settings"]
                                            .toString() ==
                                        "1"
                                    ? GestureDetector(
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
                                                  API.alertboxScreen(context),
                                            );
                                          } else {
                                            slideRightWidget(
                                                newPage: SettingsScreen(
                                                  token: widget
                                                      .userdetails["token"]
                                                      .toString(),
                                                ),
                                                context: context);
                                          }
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.2,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              10,
                                          child: Card(
                                            elevation: 10,
                                            semanticContainer: true,
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10),
                                                  child: FaIcon(
                                                    FontAwesomeIcons.gears,
                                                    color: API.appcolor,
                                                  ),
                                                ),
                                                Expanded(
                                                    child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 8),
                                                  child: Text(
                                                    "Settings",
                                                    style: TextStyle(
                                                        color: API.textcolor,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                ))
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);

  final String x;
  final double y;
}
