// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:freshice/backend/api.dart';

class CurrentStock extends StatefulWidget {
  final String token;
  final String defaultwarehouseid;
  final String defaultwarehousename;
  const CurrentStock(
      {super.key,
      required this.token,
      required this.defaultwarehouseid,
      required this.defaultwarehousename});

  @override
  State<CurrentStock> createState() => _CurrentStockState();
}

class _CurrentStockState extends State<CurrentStock> {
  TextEditingController searchcontroller = TextEditingController();

  List<dynamic> currentstock = [];
  List<dynamic> warehouse = [];
  Map<String, dynamic> selectedwarehouse = {};

  bool loading = false;
  bool viewgrid = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      setState(() {
        loading = true;
        selectedwarehouse = {
          "id": widget.defaultwarehouseid,
          "name": widget.defaultwarehousename
        };
      });
      final dynamic wareresponse =
          await API.getWarehouseListAPI(widget.token, context);
      final dynamic response = await API.getCurrentStockListAPI(
          widget.defaultwarehouseid, "", widget.token, context);
      setState(() {
        warehouse =
            wareresponse["status"] == "success" ? wareresponse["data"] : [];
        currentstock = response["status"] == "success" ? response["data"] : [];
        loading = false;
      });
      print("This is the warehouse");
      print(widget.defaultwarehousename);
      print(widget.defaultwarehouseid);
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
            "Current Stock",
            style: TextStyle(
                color: API.buttoncolor,
                fontSize: 16,
                fontWeight: FontWeight.w300),
          ),
          actions: [
            selectedwarehouse.isNotEmpty
                ? GestureDetector(
                    onTap: () async {
                      showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          isDismissible: false,
                          builder: (context) {
                            return StatefulBuilder(builder:
                                (BuildContext context,
                                    StateSetter setSheetState) {
                              return Padding(
                                  padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                          .viewInsets
                                          .bottom),
                                  child: SingleChildScrollView(
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                        Container(
                                          height: 30,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Choose Warehouse",
                                                style: TextStyle(
                                                    color: API.buttoncolor,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w300),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Divider(
                                          height: 5,
                                          indent: 30,
                                          endIndent: 30,
                                        ),
                                        Wrap(
                                          children: warehouse.map<Widget>((e) {
                                            return ListTile(
                                              onTap: () async {
                                                setState(() {
                                                  loading = true;
                                                  selectedwarehouse = e;
                                                });
                                                Navigator.pop(context);
                                                final dynamic response = await API
                                                    .getCurrentStockListAPI(
                                                        selectedwarehouse
                                                                .isEmpty
                                                            ? ""
                                                            : selectedwarehouse[
                                                                    "id"]
                                                                .toString(),
                                                        "",
                                                        widget.token,
                                                        context);
                                                setState(() {
                                                  currentstock =
                                                      response["status"] ==
                                                              "success"
                                                          ? response["data"]
                                                          : [];
                                                  loading = false;
                                                });
                                              },
                                              title: Text(
                                                e["name"].toString(),
                                                style: TextStyle(
                                                    color: API.textcolor,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                              trailing: const Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                size: 20,
                                              ),
                                            );
                                          }).toList(),
                                        )
                                      ])));
                            });
                          });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 8),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 3,
                        decoration: BoxDecoration(
                            border: Border.all(color: API.appcolor),
                            borderRadius: BorderRadius.circular(30)),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Text(
                              selectedwarehouse["name"].toString(),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: API.textcolor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox()
          ],
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: loading
              ? API.loadingScreen(context)
              : currentstock.isEmpty
                  ? API.emptyWidget(context)
                  : Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
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
                                        borderSide:
                                            BorderSide(color: API.appcolor)),
                                    contentPadding: const EdgeInsets.all(10),
                                    hintText: "Search",
                                    labelText: "Search",
                                    isDense: true,
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: API.appcolor,
                                    ),
                                  ),
                                  onChanged: (value) async {
                                    final dynamic response =
                                        await API.getCurrentStockListAPI(
                                            selectedwarehouse.isEmpty
                                                ? ""
                                                : selectedwarehouse["id"]
                                                    .toString(),
                                            value,
                                            widget.token,
                                            context);
                                    setState(() {
                                      currentstock =
                                          response["status"] == "success"
                                              ? response["data"]
                                              : [];
                                    });
                                  },
                                ),
                              ),
                            ),
                            IconButton(
                                onPressed: () {},
                                icon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        viewgrid = !viewgrid;
                                      });
                                    },
                                    icon: Icon(
                                      !viewgrid
                                          ? Icons.grid_on_rounded
                                          : Icons.list,
                                      color: API.textcolor,
                                    )))
                          ],
                        ),
                        Expanded(
                            child: Container(
                                child: viewgrid
                                    ? GridView.builder(
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                childAspectRatio: 8.8 / 10,
                                                mainAxisSpacing: 0.0,
                                                crossAxisSpacing: 0.0),
                                        itemCount: currentstock.length,
                                        itemBuilder: (context, index) {
                                          return Stack(
                                            children: [
                                              Card(
                                                elevation: 6,
                                                semanticContainer: true,
                                                child: Column(
                                                  children: [
                                                    Expanded(
                                                        child: Stack(
                                                      children: [
                                                        SizedBox(
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .all(
                                                                      10.0),
                                                              child: Image.asset(
                                                                  'assets/images/noimage.jpg'),
                                                            )),
                                                      ],
                                                    )),
                                                    SizedBox(
                                                      height: 80,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      // color: Colors.red,
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          8,
                                                                      vertical:
                                                                          3),
                                                                  child: Text(
                                                                    currentstock[index]
                                                                            [
                                                                            "part_number"]
                                                                        .toString(),
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            13,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          8,
                                                                      vertical:
                                                                          3),
                                                                  child: Text(
                                                                    currentstock[index]
                                                                            [
                                                                            "description"]
                                                                        .toString(),
                                                                    maxLines: 2,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            13,
                                                                        fontWeight:
                                                                            FontWeight.w300),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          8,
                                                                      vertical:
                                                                          0),
                                                                  child: Text(
                                                                    "Price : ${double.parse(currentstock[index]["selling_price"].toString()).toStringAsFixed(2)}",
                                                                    style: TextStyle(
                                                                        color: API
                                                                            .appcolor,
                                                                        fontSize:
                                                                            13,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            width: 60,
                                                            height: 50,
                                                            // color: Colors.red,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      vertical:
                                                                          5),
                                                                  child: Text(
                                                                    "Avl Qty",
                                                                    style: TextStyle(
                                                                        color: API
                                                                            .textcolor,
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.w300),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  num.parse(currentstock[index]
                                                                              [
                                                                              "available_qty"]
                                                                          .toString())
                                                                      .toStringAsFixed(
                                                                          2),
                                                                  style: TextStyle(
                                                                      color: API
                                                                          .textcolor,
                                                                      fontSize:
                                                                          13,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        })
                                    : ListView.builder(
                                        itemCount: currentstock.length,
                                        itemBuilder: (context, index) {
                                          return Stack(
                                            children: [
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    10,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Card(
                                                  elevation: 10,
                                                  semanticContainer: true,
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 80,
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            10,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(15.0),
                                                          child: Image.asset(
                                                              'assets/images/noimage.jpg'),
                                                        ),
                                                      ),
                                                      const VerticalDivider(
                                                        thickness: 1,
                                                      ),
                                                      Expanded(
                                                          child: Container(
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 8,
                                                                      bottom:
                                                                          2),
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        Container(
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                8,
                                                                            vertical:
                                                                                0),
                                                                        child:
                                                                            Text(
                                                                          "${currentstock[index]["part_number"].toString()}",
                                                                          maxLines:
                                                                              1,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style: const TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 13,
                                                                              fontWeight: FontWeight.w500),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      child:
                                                                          VerticalDivider()),
                                                                  SizedBox(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        4,
                                                                    child: Text(
                                                                      "Price : ${double.parse(currentstock[index]["selling_price"].toString()).toStringAsFixed(2)}",
                                                                      style: TextStyle(
                                                                          color: API
                                                                              .appcolor,
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            const Divider(
                                                              height: 3,
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 2),
                                                              child: Container(
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          SizedBox(
                                                                        height:
                                                                            30,
                                                                        child:
                                                                            Text(
                                                                          currentstock[index]["description"]
                                                                              .toString(),
                                                                          maxLines:
                                                                              2,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style: const TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 13,
                                                                              fontWeight: FontWeight.w300),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )),
                                                      Container(
                                                        width: 60,
                                                        height: 50,
                                                        // color: Colors.red,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .symmetric(
                                                                      vertical:
                                                                          5),
                                                              child: Text(
                                                                "Avl Qty",
                                                                style: TextStyle(
                                                                    color: API
                                                                        .textcolor,
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w300),
                                                              ),
                                                            ),
                                                            Text(
                                                              num.parse(currentstock[
                                                                              index]
                                                                          [
                                                                          "available_qty"]
                                                                      .toString())
                                                                  .toStringAsFixed(
                                                                      2),
                                                              style: TextStyle(
                                                                  color: API
                                                                      .textcolor,
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      )))
                      ],
                    ),
        ));
  }
}
