import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:freshice/backend/api.dart';
import 'package:freshice/maindatabase/database.dart';
import 'package:freshice/maindatabase/databasemodels/salesinvoicedetailsdatabasemodel.dart';

class ViewSalesItems extends StatefulWidget {
  final String invoiceid;
  const ViewSalesItems({super.key, required this.invoiceid});

  @override
  State<ViewSalesItems> createState() => _ViewSalesItemsState();
}

class _ViewSalesItemsState extends State<ViewSalesItems> {
  List<SalesDetailsDatabaseModel> salesitems = [];
  int rounding = 2;

  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      setState(() {
        loading = true;
      });
      final dynamic response = await FreshIceDatabase.instance
          .getSalesDetailsByInvoiceId(widget.invoiceid);
      print("this is the details");
      print(response);
      setState(() {
        salesitems = response;
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
            'View Sales Items',
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
          child: ListView.builder(
              itemCount: salesitems.length,
              itemBuilder: (context, index) {
                return Container(
                  height: MediaQuery.of(context).size.height / 8,
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    elevation: 10,
                    semanticContainer: true,
                    child: Row(
                      children: [
                        Container(
                            width: 80,
                            height: MediaQuery.of(context).size.height / 10,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Image.asset('assets/images/noimage.jpg'),
                            )),
                        Expanded(
                            child: Container(
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 8, bottom: 2),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 0),
                                          child: Text(
                                            "${salesitems[index].partnumber} / ${salesitems[index].description}",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const VerticalDivider(),
                                    Container(
                                      width:
                                          MediaQuery.of(context).size.width / 4,
                                      child: Text(
                                        "Price : ${double.parse(salesitems[index].rate.toString()).toStringAsFixed(2)}",
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                height: 3,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                4.2,
                                        child: Text(
                                          "Amt : ${num.parse(salesitems[index].subamount).toStringAsFixed(rounding)}",
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                5,
                                        child: Text(
                                          "VAT : ${num.parse(salesitems[index].subvat).toStringAsFixed(rounding)}",
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                4.2,
                                        child: Text(
                                          "Net : ${num.parse(salesitems[index].subnet).toStringAsFixed(rounding)}",
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400),
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                4.2,
                                        child: Text(
                                          "Unit : ${salesitems[index].unitname.toString()}",
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                5,
                                        child: Text(
                                          "Qty : ${salesitems[index].quantity.toString()}",
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                4.2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                      ],
                    ),
                  ),
                );
              }),
        ));
  }
}
