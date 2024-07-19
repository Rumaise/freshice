// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:freshice/backend/api.dart';
import 'package:freshice/frontend/customdrawerscreen.dart';
import 'package:freshice/frontend/successpage.dart';
import 'package:freshice/maindatabase/database.dart';
import 'package:freshice/maindatabase/databasemodels/customerdatabasemodel.dart';
import 'package:freshice/maindatabase/databasemodels/paymenttermdatabasemodel.dart';
import 'package:freshice/model/customermodel.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:sqflite/sqlite_api.dart';

class AddSalesScreen extends StatefulWidget {
  final String userid;
  const AddSalesScreen({super.key, required this.userid});

  @override
  State<AddSalesScreen> createState() => _AddSalesScreenState();
}

class _AddSalesScreenState extends State<AddSalesScreen> {
  Map<String, dynamic> customer = {};
  Map<String, dynamic> paymentterm = {};
  Map<String, dynamic> companydetails = {};
  List<dynamic> shoppingcart = [];
  int rounding = 2;
  String quantity = "";

  bool loading = false;
  bool sheetloading = false;

  Map<String, dynamic> calculateProductItem(
    Map<String, dynamic> product,
  ) {
    print("reached here");
    String amount = (num.parse(product["selling_price"].toString()) *
            num.parse(product["quantity"].toString()))
        .toString();
    String vat =
        (num.parse(amount) * (num.parse(product["taxcode"].toString()) / 100))
            .toString();
    String net = (num.parse(amount) + num.parse(vat)).toString();
    product["amount"] = amount;
    product["vat"] = vat;
    product["net"] = net;
    return product;
  }

  void updateproductItem(List<dynamic> cart, int index) {
    String amount = (num.parse(cart[index]["selling_price"].toString()) *
            num.parse(cart[index]["quantity"].toString()))
        .toString();
    String vat = (num.parse(amount) *
            (num.parse(cart[index]["taxcode"].toString()) / 100))
        .toString();
    String net = (num.parse(amount) + num.parse(vat)).toString();
    cart[index]["amount"] = amount;
    cart[index]["vat"] = vat;
    cart[index]["net"] = net;
  }

  Future<Map<String, dynamic>> calculateTotal(List<dynamic> inputList) async {
    double totalamount = 0.0;
    double totalvat = 0.0;
    double totalnet = 0.0;

    for (var element in inputList) {
      if (element.containsKey("amount") &&
          element.containsKey("vat") &&
          element.containsKey("net")) {
        double amount = double.parse(element["amount"].toString());
        double vat = double.parse(element["vat"].toString());
        double net = double.parse(element["net"].toString());
        totalamount = totalamount + amount;
        totalvat = totalvat + vat;
        totalnet = totalnet + net;
      }
    }

    return {
      "total_amount": totalamount,
      "total_vat": totalvat,
      "total_net": totalnet
    };
  }

  Future<Map<String, dynamic>> checkQuantityCheck(
    List<dynamic> shoppingcart,
    String currentproductid,
    String currentquantity,
  ) async {
    bool isavailable = false;
    num quantity = 0;
    for (int i = 0; i < shoppingcart.length; i++) {
      if (shoppingcart[i]["id"].toString() == currentproductid) {
        quantity = quantity + num.parse(shoppingcart[i]["quantity"].toString());
      }
    }
    print("This is the total quantity");
    print(quantity);

    return {"status": "success", "is_available": isavailable};
  }

  Future<List<dynamic>> convertShoppingCart(
    List<dynamic> shoppingcart,
    String invoiceid,
    String invoicedate,
  ) async {
    List<dynamic> result = [];
    for (int i = 0; i < shoppingcart.length; i++) {
      final data = {
        "product_id": shoppingcart[i]["id"].toString(),
        "invoice_id": invoiceid,
        "invoice_date": invoicedate,
        "part_number": shoppingcart[i]["part_number"].toString(),
        "description": shoppingcart[i]["description"].toString(),
        "unit_id": shoppingcart[i]["unit_id"].toString(),
        "unit_name": shoppingcart[i]["unit_name"].toString(),
        "unit_factor": shoppingcart[i]["unit_factor"].toString(),
        "quantity": shoppingcart[i]["quantity"].toString(),
        "rate": shoppingcart[i]["selling_price"].toString(),
        "deduction_amount": "0",
        "tax_vat_percentage": shoppingcart[i]["taxcode"].toString(),
        "tax_vat_amount": shoppingcart[i]["vat"].toString(),
        "sub_amount": shoppingcart[i]["amount"].toString(),
        "sub_vat": shoppingcart[i]["vat"].toString(),
        "sub_net": shoppingcart[i]["net"].toString()
      };
      result.add(data);
    }
    return result;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      setState(() {
        loading = true;
      });
      final dynamic response =
          await FreshIceDatabase.instance.getCompanyById(1);
      setState(() {
        companydetails = response["status"] == 0 ? {} : response["data"];
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
          "Add Sales",
          style: TextStyle(
              color: API.buttoncolor,
              fontSize: 16,
              fontWeight: FontWeight.w300),
        ),
        actions: [
          companydetails.isEmpty
              ? const SizedBox()
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  "Invoice ID",
                                  style: TextStyle(
                                      color: API.textcolor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300),
                                ),
                              ),
                              Text(
                                companydetails["next_invoice_no"].toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.teal,
                                    overflow: TextOverflow.visible,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: Padding(
                  padding: const EdgeInsets.only(
                    top: 5,
                    bottom: 0,
                    left: 20,
                    right: 20,
                  ),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: customer.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                customer = {};
                                shoppingcart.clear();
                              });
                            },
                            child: SizedBox(
                              height: 58,
                              child: InputDecorator(
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: BorderSide(
                                        width: 0.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(
                                        color: Colors.green,
                                        width: 0.5,
                                      ),
                                    ),
                                    hintStyle: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        color: Color.fromRGBO(181, 184, 203, 1),
                                        fontWeight: FontWeight.w300,
                                        fontSize: 11),
                                    contentPadding: const EdgeInsets.fromLTRB(
                                        20.0, 10.0, 20.0, 10.0),
                                    hintText: "Select Customer",
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0))),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.6,
                                        child: Text(
                                          "${customer["name"]} - ${customer["phone"]}",
                                          style: TextStyle(
                                            color: API.textcolor,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.delete,
                                        color: Colors.grey[400],
                                        size: 18,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : SizedBox(
                            child: TypeAheadField(
                                hideSuggestionsOnKeyboardHide: false,
                                textFieldConfiguration: TextFieldConfiguration(
                                  style: TextStyle(
                                      color: API.textcolor,
                                      fontWeight: FontWeight.bold),
                                  cursorColor: API.bordercolor,
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: API.appcolor)),
                                    filled: true,
                                    fillColor: Colors.white,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: BorderSide(
                                        width: 0.5,
                                      ),
                                    ),
                                    hintStyle: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        color: Color.fromRGBO(181, 184, 203, 1),
                                        fontWeight: FontWeight.w300,
                                        fontSize: 11),
                                    contentPadding: const EdgeInsets.fromLTRB(
                                        20.0, 10.0, 20.0, 10.0),
                                    hintText: "Customer",
                                  ),
                                ),
                                suggestionsCallback: (value) async {
                                  return await FreshIceDatabase.instance
                                      .searchCustomerList(value);
                                },
                                itemBuilder: (context,
                                    CustomerDatabaseModel? customerlist) {
                                  final listdata = customerlist;
                                  return ListTile(
                                    dense: true,
                                    title: Text(
                                      listdata!.customername.toString(),
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      maxLines: 1,
                                      style: TextStyle(
                                          color: API.textcolor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  );
                                },
                                onSuggestionSelected: (CustomerDatabaseModel?
                                    customerlist) async {
                                  final data = {
                                    'id': customerlist!.id,
                                    "name": customerlist.customername,
                                    "phone": customerlist.customerphoneno
                                  };
                                  setState(() {
                                    customer = data;
                                  });
                                  print(customer);
                                }),
                          ),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 10, top: 10),
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Choose Items",
                      style: TextStyle(
                          color: Color(0xFF263238),
                          fontWeight: FontWeight.w300,
                          fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            AbsorbPointer(
              absorbing: customer.isEmpty ? true : false,
              child: SizedBox(
                height: 50,
                child: Padding(
                    padding: const EdgeInsets.only(
                      top: 5,
                      bottom: 0,
                      left: 20,
                      right: 20,
                    ),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: SizedBox(
                        child: TypeAheadField(
                            textFieldConfiguration: TextFieldConfiguration(
                              style: TextStyle(
                                  color: API.textcolor,
                                  fontWeight: FontWeight.bold),
                              cursorColor: API.bordercolor,
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: BorderSide(
                                      color: API.bordercolor,
                                      width: 0.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: const BorderSide(
                                      color: Colors.green,
                                      width: 0.5,
                                    ),
                                  ),
                                  hintStyle: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: Color.fromRGBO(181, 184, 203, 1),
                                      fontWeight: FontWeight.w300,
                                      fontSize: 11),
                                  contentPadding: const EdgeInsets.fromLTRB(
                                      20.0, 10.0, 20.0, 10.0),
                                  hintText: "Product",
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(8.0))),
                            ),
                            suggestionsCallback: (value) async {
                              return await FreshIceDatabase.instance
                                  .searchInventoryList("");
                            },
                            itemBuilder: (context, productlist) {
                              final listdata = productlist;
                              return ListTile(
                                dense: true,
                                title: Text(
                                  "${listdata!.partnumber} / ${listdata.description}",
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: API.textcolor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400),
                                ),
                              );
                            },
                            onSuggestionSelected: (productlist) {
                              final data = {
                                "id": productlist.id.toString(),
                                "part_number":
                                    productlist.partnumber.toString(),
                                "description":
                                    productlist.description.toString(),
                                "brand_id": productlist.brandid.toString(),
                                "brand_name": productlist.brandname.toString(),
                                "generic_id": productlist.genericid.toString(),
                                "generic_name":
                                    productlist.genericname.toString(),
                                "available_qty":
                                    productlist.availableqty.toString(),
                                "unit_id": productlist.defaultunitid.toString(),
                                "unit_name":
                                    productlist.defaultunitname.toString(),
                                "unit_factor":
                                    productlist.defaultunitfactor.toString(),
                                "taxcode": productlist.taxcode.toString(),
                                "cost_rate": productlist.costrate.toString(),
                                "selling_price":
                                    productlist.sellingprice.toString(),
                                "arr_units": productlist.arrunits,
                                "quantity": "1",
                                "quantity_controller":
                                    TextEditingController(text: "1"),
                                "amount": "0",
                                "vat": "0",
                                "net": "0"
                              };
                              setState(() {
                                shoppingcart.add(calculateProductItem(data));
                              });
                              print("This is shopping cart");
                              print(shoppingcart);
                            }),
                      ),
                    )),
              ),
            ),
            Expanded(
                child: Container(
              // color: Colors.red,
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                          color: Colors.green,
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                child: shoppingcart.isEmpty
                                    ? Center(
                                        child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.3,
                                            child: Image.asset(
                                                "assets/images/box.png")),
                                      )
                                    : ListView.builder(
                                        itemCount: shoppingcart.length,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                8,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Card(
                                              elevation: 10,
                                              semanticContainer: true,
                                              child: Row(
                                                children: [
                                                  Container(
                                                      width: 80,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              10,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(20.0),
                                                        child: Image.asset(
                                                            'assets/images/noimage.jpg'),
                                                      )),
                                                  Expanded(
                                                      child: Container(
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 8,
                                                                  bottom: 2),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            0),
                                                                    child: Text(
                                                                      "${shoppingcart[(shoppingcart.length - 1) - index]["part_number"]} / ${shoppingcart[(shoppingcart.length - 1) - index]["description"]}",
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: const TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              const VerticalDivider(),
                                                              Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    4,
                                                                child: Text(
                                                                  "Price : ${double.parse(shoppingcart[(shoppingcart.length - 1) - index]["selling_price"].toString()).toStringAsFixed(2)}",
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const Divider(
                                                          height: 3,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 2),
                                                          child: Container(
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      4.2,
                                                                  child: Text(
                                                                    "Amt : ${num.parse(shoppingcart[(shoppingcart.length - 1) - index]["amount"]).toStringAsFixed(rounding)}",
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      5,
                                                                  child: Text(
                                                                    "VAT : ${num.parse(shoppingcart[(shoppingcart.length - 1) - index]["vat"]).toStringAsFixed(rounding)}",
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      4.2,
                                                                  child: Text(
                                                                    "Net : ${num.parse(shoppingcart[(shoppingcart.length - 1) - index]["net"]).toStringAsFixed(rounding)}",
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        const Divider(
                                                          height: 3,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      8),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              GestureDetector(
                                                                onTap: () {
                                                                  showModalBottomSheet(
                                                                      context:
                                                                          context,
                                                                      isScrollControlled:
                                                                          true,
                                                                      isDismissible:
                                                                          false,
                                                                      builder:
                                                                          (context) {
                                                                        return StatefulBuilder(builder: (BuildContext
                                                                                context,
                                                                            StateSetter
                                                                                setSheetState) {
                                                                          return Padding(
                                                                              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                                                              child: SingleChildScrollView(
                                                                                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                                                                                Container(
                                                                                  height: 30,
                                                                                  width: MediaQuery.of(context).size.width,
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: [
                                                                                      Text(
                                                                                        "Choose unit",
                                                                                        style: TextStyle(color: API.buttoncolor, fontSize: 14, fontWeight: FontWeight.w300),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                Divider(
                                                                                  height: 5,
                                                                                  indent: 30,
                                                                                  endIndent: 30,
                                                                                ),
                                                                                Wrap(
                                                                                  children: jsonDecode(shoppingcart[(shoppingcart.length - 1) - index]["arr_units"]).map<Widget>((e) {
                                                                                    return Column(
                                                                                      children: [
                                                                                        Container(
                                                                                          width: MediaQuery.of(context).size.width,
                                                                                          child: ListTile(
                                                                                            onTap: () {
                                                                                              setSheetState(() {
                                                                                                shoppingcart[(shoppingcart.length - 1) - index]["unit_id"] = e["id"].toString();
                                                                                                shoppingcart[(shoppingcart.length - 1) - index]["unit_name"] = e["unit_name"].toString();
                                                                                                shoppingcart[(shoppingcart.length - 1) - index]["unit_factor"] = e["unit_factor"].toString();
                                                                                                shoppingcart[(shoppingcart.length - 1) - index]["selling_price"] = e["unit_price"].toString();
                                                                                              });
                                                                                              Navigator.pop(context);
                                                                                              setState(() {
                                                                                                updateproductItem(shoppingcart, (shoppingcart.length - 1) - index);
                                                                                              });
                                                                                            },
                                                                                            title: Column(
                                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                                              children: [
                                                                                                Text(
                                                                                                  "Unit".toString(),
                                                                                                  style: TextStyle(color: API.buttoncolor, fontSize: 11, fontWeight: FontWeight.w300),
                                                                                                ),
                                                                                                Text(
                                                                                                  e["unit_name"].toString(),
                                                                                                  style: TextStyle(color: API.buttoncolor, fontSize: 14, fontWeight: FontWeight.w500),
                                                                                                ),
                                                                                                SizedBox(
                                                                                                  height: 3,
                                                                                                )
                                                                                              ],
                                                                                            ),
                                                                                            subtitle: Row(
                                                                                              children: [
                                                                                                Container(
                                                                                                  width: MediaQuery.of(context).size.width / 3.5,
                                                                                                  child: Column(
                                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                    children: [
                                                                                                      Text(
                                                                                                        "Factor".toString(),
                                                                                                        style: TextStyle(color: API.buttoncolor, fontSize: 11, fontWeight: FontWeight.w300),
                                                                                                      ),
                                                                                                      Text(
                                                                                                        e["unit_factor"].toString(),
                                                                                                        style: TextStyle(color: API.buttoncolor, fontSize: 13, fontWeight: FontWeight.w400),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                                Container(
                                                                                                  width: MediaQuery.of(context).size.width / 3.5,
                                                                                                  child: Column(
                                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                    children: [
                                                                                                      Text(
                                                                                                        "Price".toString(),
                                                                                                        style: TextStyle(color: API.buttoncolor, fontSize: 11, fontWeight: FontWeight.w300),
                                                                                                      ),
                                                                                                      Text(
                                                                                                        e["unit_price"].toString(),
                                                                                                        style: TextStyle(color: API.buttoncolor, fontSize: 13, fontWeight: FontWeight.w400),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                )
                                                                                              ],
                                                                                            ),
                                                                                            trailing: shoppingcart[(shoppingcart.length - 1) - index]["unit_id"].toString() == e["id"].toString()
                                                                                                ? Icon(
                                                                                                    Icons.check_circle_outline_rounded,
                                                                                                    color: Colors.green,
                                                                                                  )
                                                                                                : Icon(
                                                                                                    Icons.keyboard_arrow_right_rounded,
                                                                                                    color: Colors.grey,
                                                                                                  ),
                                                                                          ),
                                                                                        ),
                                                                                        Divider(
                                                                                          height: 5,
                                                                                        )
                                                                                      ],
                                                                                    );
                                                                                  }).toList(),
                                                                                )
                                                                              ])));
                                                                        });
                                                                      });
                                                                },
                                                                child:
                                                                    Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      4,
                                                                  height: 30,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Color
                                                                        .fromRGBO(
                                                                            248,
                                                                            248,
                                                                            253,
                                                                            1),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: API
                                                                          .bordercolor,
                                                                    ),
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      Expanded(
                                                                          child:
                                                                              Container(
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              const EdgeInsets.only(left: 5),
                                                                          child:
                                                                              Text(
                                                                            shoppingcart[(shoppingcart.length - 1) - index]["unit_name"].toString(),
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style: const TextStyle(
                                                                                color: Colors.black,
                                                                                fontSize: 12,
                                                                                fontWeight: FontWeight.w400),
                                                                          ),
                                                                        ),
                                                                      )),
                                                                      Icon(
                                                                        Icons
                                                                            .keyboard_arrow_down_outlined,
                                                                        size:
                                                                            23,
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                width: 120,
                                                                height: 35,
                                                                child: Row(
                                                                  children: [
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        if (int.parse(shoppingcart[(shoppingcart.length - 1) -
                                                                                index]["quantity"]) >
                                                                            0) {
                                                                          if (int.parse(shoppingcart[(shoppingcart.length - 1) - index]["quantity"]) ==
                                                                              1) {
                                                                            setState(() {
                                                                              shoppingcart.remove(shoppingcart[(shoppingcart.length - 1) - index]);
                                                                            });
                                                                          } else {
                                                                            setState(() {
                                                                              shoppingcart[(shoppingcart.length - 1) - index]["quantity"] = (int.parse(shoppingcart[(shoppingcart.length - 1) - index]["quantity"]) - 1).toString();
                                                                              shoppingcart[(shoppingcart.length - 1) - index]["quantity_controller"].text = shoppingcart[(shoppingcart.length - 1) - index]["quantity"].toString();
                                                                              updateproductItem(shoppingcart, (shoppingcart.length - 1) - index);
                                                                            });
                                                                          }
                                                                        }
                                                                      },
                                                                      child:
                                                                          const Icon(
                                                                        Icons
                                                                            .remove,
                                                                        color: Colors
                                                                            .black,
                                                                        size:
                                                                            23,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                        child:
                                                                            Padding(
                                                                      padding: const EdgeInsets
                                                                              .symmetric(
                                                                          vertical:
                                                                              3),
                                                                      child:
                                                                          Container(
                                                                        child: TextFormField(
                                                                            key: ValueKey(((shoppingcart.length - 1) - index).toString()),
                                                                            controller: shoppingcart[(shoppingcart.length - 1) - index]["quantity_controller"],
                                                                            keyboardType: TextInputType.number,
                                                                            cursorColor: Colors.grey[400],
                                                                            textAlign: TextAlign.center,
                                                                            inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                                                                            style: TextStyle(
                                                                              color: API.textcolor,
                                                                              fontSize: 14,
                                                                            ),
                                                                            decoration: InputDecoration(
                                                                                filled: true,
                                                                                fillColor: const Color.fromRGBO(248, 248, 253, 1),
                                                                                enabledBorder: OutlineInputBorder(
                                                                                  borderRadius: BorderRadius.circular(0.0),
                                                                                  borderSide: BorderSide(
                                                                                    color: API.bordercolor,
                                                                                    width: 1.0,
                                                                                  ),
                                                                                ),
                                                                                focusedBorder: OutlineInputBorder(
                                                                                  borderRadius: BorderRadius.circular(0.0),
                                                                                  borderSide: const BorderSide(
                                                                                    color: Colors.green,
                                                                                    width: 1.0,
                                                                                  ),
                                                                                ),
                                                                                hintStyle: const TextStyle(color: Color.fromRGBO(181, 184, 203, 1), fontWeight: FontWeight.w300, fontSize: 11),
                                                                                contentPadding: const EdgeInsets.fromLTRB(8.0, 2.0, 8.0, 2.0),
                                                                                hintText: "Qty",
                                                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(0.0))),
                                                                            onChanged: (val) {
                                                                              if (val.isEmpty) {
                                                                                API.showSnackBar("failed", "Quantity should not be empty", context);
                                                                              } else {
                                                                                setState(() {
                                                                                  shoppingcart[(shoppingcart.length - 1) - index]["quantity"] = val.toString();
                                                                                  updateproductItem(shoppingcart, (shoppingcart.length - 1) - index);
                                                                                });
                                                                              }
                                                                            }),
                                                                      ),
                                                                    )),
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          shoppingcart[(shoppingcart.length - 1) - index]
                                                                              [
                                                                              "quantity"] = (int.parse(shoppingcart[(shoppingcart.length - 1) - index]["quantity"]) +
                                                                                  1)
                                                                              .toString();
                                                                          shoppingcart[(shoppingcart.length - 1) - index]["quantity_controller"].text =
                                                                              shoppingcart[(shoppingcart.length - 1) - index]["quantity"].toString();
                                                                          updateproductItem(
                                                                            shoppingcart,
                                                                            (shoppingcart.length - 1) -
                                                                                index,
                                                                          );
                                                                        });
                                                                      },
                                                                      child:
                                                                          const Icon(
                                                                        Icons
                                                                            .add,
                                                                        color: Colors
                                                                            .black,
                                                                        size:
                                                                            23,
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ))
                                                ],
                                              ),
                                            ),
                                          );
                                        })),
                          ),
                          Container(
                            height: 60,
                            width: MediaQuery.of(context).size.width,
                            // color: Colors.green,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: FutureBuilder(
                                      future: calculateTotal(shoppingcart),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.done) {
                                          Map<String, dynamic>? details =
                                              snapshot.data;
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: Text(
                                              "Total : ${double.parse((details!["total_net"]).toString()).toStringAsFixed(rounding)}",
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w300),
                                            ),
                                          );
                                        } else {
                                          return const SizedBox();
                                        }
                                      }),
                                ),
                                Text(
                                  "Items ( ${shoppingcart.length} )",
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w300),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (shoppingcart.isEmpty) {
                                      API.showSnackBar(
                                          "failed",
                                          "Please add atleast a item to continue",
                                          context);
                                    } else {
                                      showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          isDismissible: false,
                                          builder: (context) {
                                            return StatefulBuilder(builder:
                                                (BuildContext context,
                                                    StateSetter setSheetState) {
                                              return sheetloading
                                                  ? Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              4,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: API.loadingScreen(
                                                          context),
                                                    )
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
                                                            const Divider(),
                                                            SizedBox(
                                                              height: 50,
                                                              child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                    top: 5,
                                                                    bottom: 0,
                                                                    left: 20,
                                                                    right: 20,
                                                                  ),
                                                                  child:
                                                                      SizedBox(
                                                                    width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width,
                                                                    child: paymentterm
                                                                            .isNotEmpty
                                                                        ? GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              setSheetState(() {
                                                                                paymentterm = {};
                                                                              });
                                                                            },
                                                                            child:
                                                                                SizedBox(
                                                                              height: 58,
                                                                              child: InputDecorator(
                                                                                decoration: InputDecoration(
                                                                                    filled: true,
                                                                                    fillColor: Colors.white,
                                                                                    enabledBorder: OutlineInputBorder(
                                                                                      borderRadius: BorderRadius.circular(5.0),
                                                                                      borderSide: BorderSide(
                                                                                        width: 0.5,
                                                                                      ),
                                                                                    ),
                                                                                    focusedBorder: OutlineInputBorder(
                                                                                      borderRadius: BorderRadius.circular(5.0),
                                                                                      borderSide: const BorderSide(
                                                                                        color: Colors.green,
                                                                                        width: 0.5,
                                                                                      ),
                                                                                    ),
                                                                                    hintStyle: const TextStyle(fontFamily: 'Montserrat', color: Color.fromRGBO(181, 184, 203, 1), fontWeight: FontWeight.w300, fontSize: 11),
                                                                                    contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                                                                    hintText: "Payment Term",
                                                                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0))),
                                                                                child: Container(
                                                                                  width: MediaQuery.of(context).size.width,
                                                                                  decoration: const BoxDecoration(
                                                                                    color: Colors.white,
                                                                                  ),
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    children: [
                                                                                      SizedBox(
                                                                                        width: MediaQuery.of(context).size.width / 1.6,
                                                                                        child: Text(
                                                                                          "${paymentterm["payment_terms"]}",
                                                                                          style: TextStyle(
                                                                                            color: API.textcolor,
                                                                                            fontSize: 14,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      Icon(
                                                                                        Icons.delete,
                                                                                        color: Colors.grey[400],
                                                                                        size: 18,
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          )
                                                                        : SizedBox(
                                                                            child: TypeAheadField(
                                                                                hideSuggestionsOnKeyboardHide: false,
                                                                                textFieldConfiguration: TextFieldConfiguration(
                                                                                  style: TextStyle(color: API.textcolor, fontWeight: FontWeight.bold),
                                                                                  cursorColor: API.bordercolor,
                                                                                  decoration: InputDecoration(
                                                                                    border: const OutlineInputBorder(),
                                                                                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: API.appcolor)),
                                                                                    filled: true,
                                                                                    fillColor: Colors.white,
                                                                                    enabledBorder: OutlineInputBorder(
                                                                                      borderRadius: BorderRadius.circular(5.0),
                                                                                      borderSide: BorderSide(
                                                                                        width: 0.5,
                                                                                      ),
                                                                                    ),
                                                                                    hintStyle: const TextStyle(fontFamily: 'Montserrat', color: Color.fromRGBO(181, 184, 203, 1), fontWeight: FontWeight.w300, fontSize: 11),
                                                                                    contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                                                                    hintText: "Payment Term",
                                                                                  ),
                                                                                ),
                                                                                suggestionsCallback: (value) async {
                                                                                  return await FreshIceDatabase.instance.searchPaymentTermList(value);
                                                                                },
                                                                                itemBuilder: (context, PaymentTermDatabaseModel? paymenttermlist) {
                                                                                  final listdata = paymenttermlist;
                                                                                  return ListTile(
                                                                                    dense: true,
                                                                                    title: Text(
                                                                                      listdata!.paymentterms.toString(),
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                      softWrap: false,
                                                                                      maxLines: 1,
                                                                                      style: TextStyle(color: API.textcolor, fontSize: 14, fontWeight: FontWeight.w400),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                                onSuggestionSelected: (PaymentTermDatabaseModel? paymenttermlist) async {
                                                                                  final data = {
                                                                                    'id': paymenttermlist!.id,
                                                                                    "payment_code": paymenttermlist.paymentcode,
                                                                                    "payment_terms": paymenttermlist.paymentterms
                                                                                  };
                                                                                  print(data);
                                                                                  setState(() {
                                                                                    paymentterm = data;
                                                                                  });
                                                                                  print(paymentterm);
                                                                                }),
                                                                          ),
                                                                  )),
                                                            ),
                                                            const Divider(
                                                              height: 5,
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                const Padding(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              20),
                                                                  child: Text(
                                                                    "Total Item(s)",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          20),
                                                                  child: Text(
                                                                    shoppingcart
                                                                        .length
                                                                        .toString(),
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const Divider(
                                                              height: 5,
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                const Padding(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              20),
                                                                  child: Text(
                                                                    "Amount",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                ),
                                                                FutureBuilder(
                                                                    future: calculateTotal(
                                                                        shoppingcart),
                                                                    builder:
                                                                        (context,
                                                                            snapshot) {
                                                                      if (snapshot
                                                                              .connectionState ==
                                                                          ConnectionState
                                                                              .done) {
                                                                        Map<String,
                                                                                dynamic>?
                                                                            details =
                                                                            snapshot.data;
                                                                        return Padding(
                                                                          padding:
                                                                              const EdgeInsets.symmetric(horizontal: 20),
                                                                          child:
                                                                              Text(
                                                                            double.parse((details!["total_amount"]).toString()).toStringAsFixed(2),
                                                                            style: const TextStyle(
                                                                                color: Colors.black,
                                                                                fontSize: 12,
                                                                                fontWeight: FontWeight.w500),
                                                                          ),
                                                                        );
                                                                      } else {
                                                                        return const Padding(
                                                                          padding:
                                                                              EdgeInsets.symmetric(horizontal: 20),
                                                                          child:
                                                                              Text(
                                                                            "0",
                                                                            style: TextStyle(
                                                                                color: Colors.black,
                                                                                fontSize: 12,
                                                                                fontWeight: FontWeight.w500),
                                                                          ),
                                                                        );
                                                                      }
                                                                    })
                                                              ],
                                                            ),
                                                            const Divider(
                                                              height: 5,
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                const Padding(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              20),
                                                                  child: Text(
                                                                    "VAT",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                ),
                                                                FutureBuilder(
                                                                    future: calculateTotal(
                                                                        shoppingcart),
                                                                    builder:
                                                                        (context,
                                                                            snapshot) {
                                                                      if (snapshot
                                                                              .connectionState ==
                                                                          ConnectionState
                                                                              .done) {
                                                                        Map<String,
                                                                                dynamic>?
                                                                            details =
                                                                            snapshot.data;
                                                                        return Padding(
                                                                          padding:
                                                                              const EdgeInsets.symmetric(horizontal: 20),
                                                                          child:
                                                                              Text(
                                                                            double.parse((details!["total_vat"]).toString()).toStringAsFixed(2),
                                                                            style: const TextStyle(
                                                                                color: Colors.black,
                                                                                fontSize: 12,
                                                                                fontWeight: FontWeight.w500),
                                                                          ),
                                                                        );
                                                                      } else {
                                                                        return const Padding(
                                                                          padding:
                                                                              EdgeInsets.symmetric(horizontal: 20),
                                                                          child:
                                                                              Text(
                                                                            "0",
                                                                            style: TextStyle(
                                                                                color: Colors.black,
                                                                                fontSize: 12,
                                                                                fontWeight: FontWeight.w500),
                                                                          ),
                                                                        );
                                                                      }
                                                                    })
                                                              ],
                                                            ),
                                                            const Divider(
                                                              height: 5,
                                                            ),
                                                            Container(
                                                              color: Colors
                                                                  .green[100],
                                                              height: 20,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  const Padding(
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            20),
                                                                    child: Text(
                                                                      "Net",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                  ),
                                                                  FutureBuilder(
                                                                      future: calculateTotal(
                                                                          shoppingcart),
                                                                      builder:
                                                                          (context,
                                                                              snapshot) {
                                                                        if (snapshot.connectionState ==
                                                                            ConnectionState.done) {
                                                                          Map<String, dynamic>?
                                                                              details =
                                                                              snapshot.data;
                                                                          return Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 20),
                                                                            child:
                                                                                Text(
                                                                              double.parse((details!["total_net"]).toString()).toStringAsFixed(2),
                                                                              style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w500),
                                                                            ),
                                                                          );
                                                                        } else {
                                                                          return const Padding(
                                                                            padding:
                                                                                EdgeInsets.symmetric(horizontal: 20),
                                                                            child:
                                                                                Text(
                                                                              "0",
                                                                              style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w500),
                                                                            ),
                                                                          );
                                                                        }
                                                                      })
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            GestureDetector(
                                                              onTap: () async {
                                                                if (paymentterm
                                                                    .isEmpty) {
                                                                  API.showSnackBar(
                                                                      'failed',
                                                                      'Please select payment term',
                                                                      context);
                                                                } else {
                                                                  final dynamic
                                                                      calculateresponse =
                                                                      await calculateTotal(
                                                                          shoppingcart);
                                                                  final dynamic
                                                                      shoppingresponse =
                                                                      await convertShoppingCart(
                                                                          shoppingcart,
                                                                          companydetails[
                                                                              "next_invoice_no"],
                                                                          DateTime.now()
                                                                              .toString());
                                                                  print(
                                                                      "this is the shopping response");
                                                                  print(
                                                                      shoppingresponse);
                                                                  final dynamic
                                                                      quantityresponse =
                                                                      await FreshIceDatabase
                                                                          .instance
                                                                          .checkProductAvailability(
                                                                              shoppingresponse);
                                                                  if (quantityresponse[
                                                                          "status"] ==
                                                                      "success") {
                                                                    final dynamic response = await FreshIceDatabase.instance.createSalesTransaction(
                                                                        companydetails[
                                                                            "next_invoice_no"],
                                                                        DateTime.now()
                                                                            .toString(),
                                                                        customer["id"]
                                                                            .toString(),
                                                                        customer["name"]
                                                                            .toString(),
                                                                        calculateresponse["total_net"]
                                                                            .toString(),
                                                                        calculateresponse["total_amount"]
                                                                            .toString(),
                                                                        calculateresponse["total_vat"]
                                                                            .toString(),
                                                                        paymentterm["id"]
                                                                            .toString(),
                                                                        shoppingresponse,
                                                                        "N",
                                                                        "",
                                                                        widget
                                                                            .userid);
                                                                    if (response["status"]
                                                                            .toString() ==
                                                                        "1") {
                                                                      pushWidgetWhileRemove(
                                                                          newPage: const SuccessPage(
                                                                              screen:
                                                                                  CustomDrawerScreen()),
                                                                          context:
                                                                              context);
                                                                    } else {
                                                                      API.showSnackBar(
                                                                          "failed",
                                                                          response["message"]
                                                                              .toString(),
                                                                          context);
                                                                    }
                                                                  } else {
                                                                    API.showSnackBar(
                                                                        "failed",
                                                                        quantityresponse["message"]
                                                                            .toString(),
                                                                        context);
                                                                  }
                                                                }
                                                              },
                                                              child: Container(
                                                                height: 60,
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                child: Card(
                                                                  elevation: 10,
                                                                  semanticContainer:
                                                                      true,
                                                                  color: Colors
                                                                      .indigo,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: const [
                                                                      Text(
                                                                        "Submit",
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .white,
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.w500),
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.symmetric(horizontal: 5),
                                                                        child:
                                                                            Text(
                                                                          "",
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.w500),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          ])),
                                                    );
                                            });
                                          }).then((value) {
                                        print("This is running");
                                        setState(() {});
                                      });
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.5,
                                          height: 50,
                                          child: Card(
                                            elevation: 10,
                                            color: API.appcolor,
                                            semanticContainer: true,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6)),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: const [
                                                Text(
                                                  "Shopping Cart",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w300),
                                                ),
                                                Icon(
                                                  Icons.shopping_bag,
                                                  color: Colors.white,
                                                  size: 20,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
