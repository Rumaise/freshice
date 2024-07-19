import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:freshice/backend/api.dart';

class ProductionOrderScreen extends StatefulWidget {
  const ProductionOrderScreen({super.key});

  @override
  State<ProductionOrderScreen> createState() => _ProductionOrderScreenState();
}

class _ProductionOrderScreenState extends State<ProductionOrderScreen> {
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
          "Production Order",
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
            Row(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 10,
                  width: MediaQuery.of(context).size.width / 2.3,
                  child: const Card(
                    elevation: 10,
                    semanticContainer: true,
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height / 10,
                  width: MediaQuery.of(context).size.width / 2.3,
                  child: const Card(
                    elevation: 10,
                    semanticContainer: true,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
