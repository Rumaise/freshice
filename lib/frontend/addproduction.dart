// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:freshice/backend/api.dart';
import 'package:freshice/frontend/customdrawerscreen.dart';
import 'package:freshice/frontend/successpage.dart';
import 'package:route_transitions/route_transitions.dart';

class AddProductionScreen extends StatefulWidget {
  final String token;
  const AddProductionScreen({super.key, required this.token});

  @override
  State<AddProductionScreen> createState() => _AddProductionScreenState();
}

class _AddProductionScreenState extends State<AddProductionScreen> {
  TextEditingController quantitycontroller = TextEditingController();
  TextEditingController availablequantitycontroller = TextEditingController();

  List<dynamic> billofmaterial = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      setState(() {
        loading = true;
      });
      final dynamic response = await API.getBOMListAPI(widget.token, context);
      print(response);
      setState(() {
        billofmaterial =
            response["status"] == "success" ? response["data"] : [];
        loading = false;
      });
    });
  }

  int selectedindex = -1;
  bool loading = false;
  bool subloading = false;
  bool sheetloading = false;

  Future<void> calculateDetails(List<dynamic> details, num quantity) async {
    for (int i = 0; i < details.length; i++) {
      setState(() {
        details[i]["quantity"] =
            (num.parse(details[i]["bom_qty"].toString()) * quantity)
                .toStringAsFixed(2);
      });
    }
  }

  Future<Map<String, dynamic>> checkAvailableQty(List<dynamic> details) async {
    int isavailable = 0;
    for (int i = 0; i < details.length; i++) {
      if (num.parse(details[i]["quantity"].toString()) <
          num.parse(details[i]["available_qty"].toString())) {
        setState(() {
          isavailable = isavailable + 1;
        });
      }
    }
    return {
      "status": "success",
      "data": isavailable == details.length ? true : false
    };
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
          "Add Production",
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
            : billofmaterial.isEmpty
                ? API.emptyWidget(context)
                : ListView.builder(
                    itemCount: billofmaterial.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 10,
                        semanticContainer: true,
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: Text(
                                  "Product",
                                  style: TextStyle(
                                      color: API.textcolor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w300),
                                ),
                              ),
                              Text(
                                billofmaterial[index]["part_number"]
                                            .toString()
                                            .toLowerCase() ==
                                        "null"
                                    ? "-"
                                    : billofmaterial[index]["part_number"]
                                        .toString(),
                                style: const TextStyle(
                                    color: Colors.teal,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2.5,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5),
                                          child: Text(
                                            "Description",
                                            style: TextStyle(
                                                color: API.textcolor,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w300),
                                          ),
                                        ),
                                        Text(
                                          billofmaterial[index]["description"]
                                                      .toString()
                                                      .toLowerCase() ==
                                                  "null"
                                              ? "-"
                                              : billofmaterial[index]
                                                      ["description"]
                                                  .toString(),
                                          style: TextStyle(
                                              color: API.textcolor,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 4.5,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5),
                                          child: Text(
                                            "Qty",
                                            style: TextStyle(
                                                color: API.textcolor,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w300),
                                          ),
                                        ),
                                        Text(
                                          billofmaterial[index]["quantity"]
                                              .toString(),
                                          style: TextStyle(
                                              color: API.textcolor,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              )
                            ],
                          ),
                          trailing: selectedindex == index && subloading
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    CircularProgressIndicator(
                                      color: Colors.teal,
                                      strokeWidth: 1,
                                    ),
                                  ],
                                )
                              : GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      selectedindex = index;
                                      subloading = true;
                                    });
                                    final dynamic subresponse =
                                        await API.postBOMMaterialDetailsAPI(
                                            billofmaterial[index]["bom_id"]
                                                .toString(),
                                            widget.token,
                                            context);
                                    setState(() {
                                      selectedindex = -1;
                                      quantitycontroller.text =
                                          subresponse["quantity"].toString();
                                      availablequantitycontroller.text =
                                          subresponse["available_qty"]
                                              .toString();
                                      subloading = false;
                                    });
                                    if (subresponse["status"] == "success") {
                                      // ignore: use_build_context_synchronously
                                      showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          isDismissible: false,
                                          builder: (context) {
                                            return StatefulBuilder(builder:
                                                (BuildContext context,
                                                    StateSetter setSheetState) {
                                              return sheetloading
                                                  ? API.loadingScreen(context)
                                                  : Padding(
                                                      padding: EdgeInsets.only(
                                                          bottom: MediaQuery.of(
                                                                  context)
                                                              .viewInsets
                                                              .bottom),
                                                      child:
                                                          SingleChildScrollView(
                                                              child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                            Container(
                                                              height: 30,
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              color:
                                                                  API.appcolor,
                                                              child:
                                                                  const Center(
                                                                child: Text(
                                                                  "Auto Production",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          13,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      20),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceAround,
                                                                children: [
                                                                  Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        2.3,
                                                                    child:
                                                                        TextFormField(
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              API.appfontsize),
                                                                      controller:
                                                                          quantitycontroller,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .number,
                                                                      textInputAction:
                                                                          TextInputAction
                                                                              .next,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        border:
                                                                            const OutlineInputBorder(),
                                                                        focusedBorder:
                                                                            OutlineInputBorder(borderSide: BorderSide(color: API.appcolor)),
                                                                        contentPadding:
                                                                            const EdgeInsets.all(10),
                                                                        hintText:
                                                                            "Qty",
                                                                        labelText:
                                                                            "Qty",
                                                                        isDense:
                                                                            true,
                                                                      ),
                                                                      onChanged:
                                                                          (val) async {
                                                                        print(
                                                                            "this is the value");
                                                                        print(
                                                                            val);
                                                                        if (val
                                                                            .isEmpty) {
                                                                        } else {
                                                                          await calculateDetails(
                                                                              subresponse["data"],
                                                                              num.parse(val));
                                                                          setSheetState(
                                                                              () {});
                                                                        }
                                                                      },
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        2.3,
                                                                    child:
                                                                        TextFormField(
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              API.appfontsize),
                                                                      controller:
                                                                          availablequantitycontroller,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                      readOnly:
                                                                          true,
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .number,
                                                                      textInputAction:
                                                                          TextInputAction
                                                                              .next,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        border:
                                                                            const OutlineInputBorder(),
                                                                        focusedBorder:
                                                                            OutlineInputBorder(borderSide: BorderSide(color: API.appcolor)),
                                                                        contentPadding:
                                                                            const EdgeInsets.all(10),
                                                                        hintText:
                                                                            "Available",
                                                                        labelText:
                                                                            "Available",
                                                                        isDense:
                                                                            true,
                                                                      ),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            Row(
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      left: 20,
                                                                      top: 8,
                                                                      bottom:
                                                                          8),
                                                                  child: Text(
                                                                    "Materials",
                                                                    style: TextStyle(
                                                                        color: API
                                                                            .textcolor,
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Wrap(
                                                              children: subresponse[
                                                                      "data"]
                                                                  .map<Widget>(
                                                                      (e) {
                                                                return Card(
                                                                    elevation:
                                                                        10,
                                                                    semanticContainer:
                                                                        true,
                                                                    child:
                                                                        ListTile(
                                                                      title:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(vertical: 5),
                                                                            child:
                                                                                Text(
                                                                              "Product",
                                                                              style: TextStyle(color: API.textcolor, fontSize: 10, fontWeight: FontWeight.w300),
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            "${e["part_number"]} / ${e["description"]}",
                                                                            style: TextStyle(
                                                                                color: API.textcolor,
                                                                                fontSize: 13,
                                                                                fontWeight: FontWeight.w500),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      subtitle:
                                                                          Column(
                                                                        children: [
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceAround,
                                                                            children: [
                                                                              Container(
                                                                                width: MediaQuery.of(context).size.width / 3.5,
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.symmetric(vertical: 5),
                                                                                      child: Text(
                                                                                        "BOM Qty",
                                                                                        style: TextStyle(color: API.textcolor, fontSize: 10, fontWeight: FontWeight.w300),
                                                                                      ),
                                                                                    ),
                                                                                    TextFormField(
                                                                                      style: TextStyle(fontSize: API.appfontsize),
                                                                                      initialValue: e["bom_qty"].toString(),
                                                                                      key: Key(e["bom_qty"].toString()),
                                                                                      textAlign: TextAlign.left,
                                                                                      readOnly: true,
                                                                                      keyboardType: TextInputType.number,
                                                                                      textInputAction: TextInputAction.next,
                                                                                      decoration: InputDecoration(
                                                                                        border: const OutlineInputBorder(),
                                                                                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: API.appcolor)),
                                                                                        contentPadding: const EdgeInsets.all(10),
                                                                                        hintText: "BOM Qty",
                                                                                        isDense: true,
                                                                                      ),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              Container(
                                                                                width: MediaQuery.of(context).size.width / 3.5,
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.symmetric(vertical: 5),
                                                                                      child: Text(
                                                                                        "Qty",
                                                                                        style: TextStyle(color: API.textcolor, fontSize: 10, fontWeight: FontWeight.w300),
                                                                                      ),
                                                                                    ),
                                                                                    TextFormField(
                                                                                      style: TextStyle(fontSize: API.appfontsize),
                                                                                      initialValue: e["quantity"].toString(),
                                                                                      key: Key(e["quantity"].toString()),
                                                                                      textAlign: TextAlign.left,
                                                                                      readOnly: true,
                                                                                      keyboardType: TextInputType.number,
                                                                                      textInputAction: TextInputAction.next,
                                                                                      decoration: InputDecoration(
                                                                                        border: const OutlineInputBorder(),
                                                                                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: API.appcolor)),
                                                                                        contentPadding: const EdgeInsets.all(10),
                                                                                        hintText: "Qty",
                                                                                        isDense: true,
                                                                                      ),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              Container(
                                                                                width: MediaQuery.of(context).size.width / 3.5,
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.symmetric(vertical: 5),
                                                                                      child: Text(
                                                                                        "Avl Qty",
                                                                                        style: TextStyle(color: num.parse(e["quantity"].toString()) < num.parse(e["available_qty"].toString()) ? Colors.black : Colors.red, fontSize: 10, fontWeight: FontWeight.w300),
                                                                                      ),
                                                                                    ),
                                                                                    TextFormField(
                                                                                      style: TextStyle(fontSize: API.appfontsize, color: num.parse(e["quantity"].toString()) < num.parse(e["available_qty"].toString()) ? API.textcolor : Colors.white),
                                                                                      initialValue: e["available_qty"],
                                                                                      textAlign: TextAlign.left,
                                                                                      readOnly: true,
                                                                                      keyboardType: TextInputType.number,
                                                                                      textInputAction: TextInputAction.next,
                                                                                      decoration: InputDecoration(
                                                                                        fillColor: num.parse(e["quantity"].toString()) < num.parse(e["available_qty"].toString()) ? Colors.white : Color(0xFFe57373),
                                                                                        filled: true,
                                                                                        border: const OutlineInputBorder(),
                                                                                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: num.parse(e["quantity"].toString()) < num.parse(e["available_qty"].toString()) ? Colors.grey : Colors.teal)),
                                                                                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: API.appcolor)),
                                                                                        contentPadding: const EdgeInsets.all(10),
                                                                                        hintText: "Avl Qty",
                                                                                        isDense: true,
                                                                                      ),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              )
                                                                            ],
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                8,
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ));
                                                              }).toList(),
                                                            ),
                                                            const SizedBox(
                                                              height: 8,
                                                            ),
                                                            GestureDetector(
                                                              onTap: () async {
                                                                if (quantitycontroller
                                                                    .text
                                                                    .isEmpty) {
                                                                  API.showSnackBar(
                                                                      "failed",
                                                                      "Please enter quantity",
                                                                      context);
                                                                } else {
                                                                  setSheetState(
                                                                      () {
                                                                    sheetloading =
                                                                        true;
                                                                  });
                                                                  final dynamic
                                                                      checkavailableresponse =
                                                                      await checkAvailableQty(
                                                                          subresponse[
                                                                              "data"]);
                                                                  if (checkavailableresponse[
                                                                              "status"] ==
                                                                          "success" &&
                                                                      checkavailableresponse[
                                                                          "data"]) {
                                                                    final dynamic productionresponse = await API.postSaveAutoProductionAPI(
                                                                        subresponse["bom_id"]
                                                                            .toString(),
                                                                        quantitycontroller
                                                                            .text,
                                                                        widget
                                                                            .token,
                                                                        context);
                                                                    if (productionresponse[
                                                                            "status"] ==
                                                                        "success") {
                                                                      pushWidgetWhileRemove(
                                                                          newPage: const SuccessPage(
                                                                              screen:
                                                                                  CustomDrawerScreen()),
                                                                          context:
                                                                              context);
                                                                    } else {
                                                                      setSheetState(
                                                                          () {
                                                                        sheetloading =
                                                                            false;
                                                                      });
                                                                      API.showSnackBar(
                                                                          "failed",
                                                                          productionresponse["message"]
                                                                              .toString(),
                                                                          context);
                                                                    }
                                                                  } else {
                                                                    setSheetState(
                                                                        () {
                                                                      sheetloading =
                                                                          false;
                                                                    });
                                                                    API.showSnackBar(
                                                                        "failed",
                                                                        "Please check materials available quantity",
                                                                        context);
                                                                  }
                                                                }
                                                              },
                                                              child: Container(
                                                                height: 40,
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    2,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: API
                                                                      .appcolor,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              40),
                                                                ),
                                                                child:
                                                                    const Center(
                                                                  child: Text(
                                                                    "Submit",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            13,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          ])));
                                            });
                                          }).then((value) {
                                        setState(() {
                                          quantitycontroller.text = "";
                                          availablequantitycontroller.text = "";
                                          sheetloading = false;
                                        });
                                      });
                                    }
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                          decoration: BoxDecoration(
                                              color: API.appcolor,
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: const Padding(
                                            padding: EdgeInsets.only(
                                                left: 8,
                                                top: 5,
                                                bottom: 5,
                                                right: 8),
                                            child: Text(
                                              "Production",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                        ),
                      );
                    }),
      ),
    );
  }
}
