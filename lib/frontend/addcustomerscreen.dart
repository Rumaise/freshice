// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:freshice/backend/api.dart';
import 'package:freshice/maindatabase/database.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  TextEditingController namecontroller = TextEditingController();
  TextEditingController phonecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController trncontroller = TextEditingController();
  TextEditingController addresscontroller = TextEditingController();

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
            "Add Customer",
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
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: TextFormField(
                    style: TextStyle(fontSize: API.appfontsize),
                    controller: namecontroller,
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: API.appcolor)),
                      contentPadding: const EdgeInsets.all(10),
                      hintText: "Name",
                      labelText: "Name",
                      isDense: true,
                      prefixIcon: Icon(
                        Icons.person_2_outlined,
                        color: API.appcolor,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: TextFormField(
                    style: TextStyle(fontSize: API.appfontsize),
                    controller: phonecontroller,
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: API.appcolor)),
                      contentPadding: const EdgeInsets.all(10),
                      hintText: "Phone",
                      labelText: "Phone",
                      isDense: true,
                      prefixIcon: Icon(
                        Icons.phone_android,
                        color: API.appcolor,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: TextFormField(
                    style: TextStyle(fontSize: API.appfontsize),
                    controller: emailcontroller,
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: API.appcolor)),
                      contentPadding: const EdgeInsets.all(10),
                      hintText: "Email",
                      labelText: "Email",
                      isDense: true,
                      prefixIcon: Icon(
                        Icons.email,
                        color: API.appcolor,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: TextFormField(
                    style: TextStyle(fontSize: API.appfontsize),
                    controller: trncontroller,
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: API.appcolor)),
                      contentPadding: const EdgeInsets.all(10),
                      hintText: "TRN ",
                      labelText: "TRN",
                      isDense: true,
                      prefixIcon: Icon(
                        Icons.file_present_rounded,
                        color: API.appcolor,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: TextFormField(
                    style: TextStyle(fontSize: API.appfontsize),
                    controller: addresscontroller,
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.streetAddress,
                    textInputAction: TextInputAction.done,
                    maxLines: 5,
                    minLines: 3,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: API.appcolor)),
                      contentPadding: const EdgeInsets.all(10),
                      hintText: "Address",
                      labelText: "Address",
                      isDense: true,
                      prefixIcon: Icon(
                        Icons.apartment,
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
                    final dynamic customerserverresponse =
                        await FreshIceDatabase.instance.createCustomer({
                      'customer_name': namecontroller.text,
                      'customer_phone_no': phonecontroller.text,
                      'customer_email_id': emailcontroller.text,
                      'customer_trn': trncontroller.text,
                      'customer_address': addresscontroller.text,
                      'is_synced': 'N'
                    });
                    if (customerserverresponse["status"] == 1) {
                      API.showSnackBar(
                          "success", "Customer created successfully", context);
                      Navigator.pop(context);
                    } else {
                      API.showSnackBar(
                          "failed",
                          customerserverresponse["message"].toString(),
                          context);
                    }
                  },
                  child: Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width / 2,
                    decoration: BoxDecoration(
                      color: API.appcolor,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                )
              ],
            )));
  }
}
