import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:freshice/backend/api.dart';
import 'package:freshice/frontend/viewsalesitems.dart';
import 'package:freshice/maindatabase/database.dart';
import 'package:freshice/maindatabase/databasemodels/salesinvoiceheaddatabasemodel.dart';
import 'package:route_transitions/route_transitions.dart';

class SalesListScreen extends StatefulWidget {
  final String token;
  const SalesListScreen({super.key, required this.token});

  @override
  State<SalesListScreen> createState() => _SalesListScreenState();
}

class _SalesListScreenState extends State<SalesListScreen> {
  TextEditingController searchcontroller = TextEditingController();

  List<SalesHeadDatabaseModel> saleslist = [];

  int rounding = 2;
  int selectedindex = -1;

  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      setState(() {
        loading = true;
      });
      final dynamic response =
          await FreshIceDatabase.instance.getAllSalesHeadRecords("", null);
      setState(() {
        saleslist = response;
        loading = false;
      });
    });
  }

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
            "Sales",
            style: TextStyle(
                color: API.buttoncolor,
                fontSize: 16,
                fontWeight: FontWeight.w300),
          ),
          actions: [
            IconButton(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2015, 8),
                      lastDate: DateTime(2101));
                  if (picked != null) {
                    setState(() {
                      loading = true;
                    });
                    final dynamic response = await FreshIceDatabase.instance
                        .getAllSalesHeadRecords("", picked);
                    setState(() {
                      saleslist = response;
                      loading = false;
                    });
                  }
                },
                icon: Icon(
                  Icons.calendar_month,
                  color: API.appcolor,
                ))
          ],
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: saleslist.isEmpty
              ? API.emptyWidget(context)
              : loading
                  ? API.loadingScreen(context)
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          child: TextFormField(
                            style: TextStyle(fontSize: API.appfontsize),
                            controller: searchcontroller,
                            textAlign: TextAlign.left,
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(color: API.appcolor)),
                              contentPadding: const EdgeInsets.all(10),
                              hintText: "Search",
                              labelText: "Search",
                              isDense: true,
                              prefixIcon: Icon(
                                Icons.search,
                                color: API.appcolor,
                              ),
                            ),
                            onChanged: (val) async {
                              final dynamic response = await FreshIceDatabase
                                  .instance
                                  .getAllSalesHeadRecords(val, null);
                              setState(() {
                                saleslist = response;
                              });
                            },
                          ),
                        ),
                        Expanded(
                            child: Container(
                          child: ListView.builder(
                              itemCount: saleslist.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  child: Card(
                                    elevation: 10,
                                    semanticContainer: true,
                                    child: ListTile(
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 5),
                                                  child: Text(
                                                    "Inv Id : ${saleslist[index].invoiceid}",
                                                    style: TextStyle(
                                                        color: API.textcolor,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  slideRightWidget(
                                                      newPage: ViewSalesItems(
                                                          invoiceid:
                                                              saleslist[index]
                                                                  .invoiceid),
                                                      context: context);
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10),
                                                  child: Container(
                                                    height: 25,
                                                    child: const Icon(
                                                      Icons.remove_red_eye,
                                                      color: Colors.teal,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Container(
                                              //   height: 25,
                                              //   child: Image.asset(
                                              //       "assets/images/photo-print.png"),
                                              // )
                                            ],
                                          ),
                                          const Divider(
                                            height: 5,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            child: Text(
                                              saleslist[index]
                                                      .customername
                                                      .toString() +
                                                  saleslist[index]
                                                      .customerid
                                                      .toString(),
                                              style: TextStyle(
                                                  color: API.appcolor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          const Divider(
                                            height: 5,
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    4,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 5),
                                                      child: Text(
                                                        "Amount",
                                                        style: TextStyle(
                                                            color:
                                                                API.textcolor,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w300),
                                                      ),
                                                    ),
                                                    Text(
                                                      num.parse(saleslist[index]
                                                              .subtotalamount
                                                              .toString())
                                                          .toStringAsFixed(
                                                              rounding),
                                                      style: TextStyle(
                                                          color: API.textcolor,
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    4.5,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 5),
                                                      child: Text(
                                                        "VAT",
                                                        style: TextStyle(
                                                            color:
                                                                API.textcolor,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w300),
                                                      ),
                                                    ),
                                                    Text(
                                                      num.parse(saleslist[index]
                                                              .totalvat
                                                              .toString())
                                                          .toStringAsFixed(
                                                              rounding),
                                                      style: TextStyle(
                                                          color: API.textcolor,
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    3.5,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 5),
                                                      child: Text(
                                                        "Total",
                                                        style: TextStyle(
                                                            color:
                                                                API.textcolor,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w300),
                                                      ),
                                                    ),
                                                    Text(
                                                      num.parse(saleslist[index]
                                                              .totalamount
                                                              .toString())
                                                          .toStringAsFixed(
                                                              rounding),
                                                      style: TextStyle(
                                                          color: API.textcolor,
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              selectedindex == index
                                                  ? const CircularProgressIndicator(
                                                      color: Colors.green,
                                                      strokeWidth: 1,
                                                    )
                                                  : saleslist[index]
                                                              .issynced
                                                              .toString() ==
                                                          "N"
                                                      ? GestureDetector(
                                                          onTap: () async {
                                                            setState(() {
                                                              selectedindex =
                                                                  index;
                                                            });
                                                            await FreshIceDatabase
                                                                .instance
                                                                .syncSingleInvoiceById(
                                                                    saleslist[
                                                                            index]
                                                                        .invoiceid,
                                                                    widget
                                                                        .token,
                                                                    context)
                                                                .then(
                                                                    (value) async {
                                                              setState(() {
                                                                selectedindex =
                                                                    -1;
                                                              });
                                                              if (value["status"]
                                                                      .toString() ==
                                                                  "success") {
                                                                setState(() {
                                                                  loading =
                                                                      true;
                                                                });
                                                                final dynamic
                                                                    response =
                                                                    await FreshIceDatabase
                                                                        .instance
                                                                        .getAllSalesHeadRecords(
                                                                            "",
                                                                            null);
                                                                setState(() {
                                                                  saleslist =
                                                                      response;
                                                                  loading =
                                                                      false;
                                                                });
                                                              } else {
                                                                API.showSnackBar(
                                                                    "failed",
                                                                    value["message"]
                                                                        .toString(),
                                                                    context);
                                                              }
                                                            });
                                                          },
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Container(
                                                                height: 25,
                                                                width: 30,
                                                                child: Image.asset(
                                                                    "assets/images/cloud.png"),
                                                              ),
                                                              const Text(
                                                                "Not Synced",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red,
                                                                    fontSize: 9,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w300),
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      : Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Container(
                                                              height: 25,
                                                              width: 30,
                                                              child: Image.asset(
                                                                  "assets/images/stamp.png"),
                                                            ),
                                                            const Text(
                                                              "Synced",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .teal,
                                                                  fontSize: 9,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300),
                                                            )
                                                          ],
                                                        )
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ))
                      ],
                    ),
        ));
  }
}
