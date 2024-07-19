// ignore_for_file: depend_on_referenced_packages, unused_import, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:freshice/backend/api.dart';
import 'package:freshice/maindatabase/databasemodels/companydatabasemodel.dart';
import 'package:freshice/maindatabase/databasemodels/customerdatabasemodel.dart';
import 'package:freshice/maindatabase/databasemodels/inventorydatabasemodel.dart';
import 'package:freshice/maindatabase/databasemodels/paymenttermdatabasemodel.dart';
import 'package:freshice/maindatabase/databasemodels/salesinvoicedetailsdatabasemodel.dart';
import 'package:freshice/maindatabase/databasemodels/salesinvoiceheaddatabasemodel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class FreshIceDatabase {
  static final FreshIceDatabase instance = FreshIceDatabase._init();
  static Database? _database;
  FreshIceDatabase._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await _initDB("freshicemaindatabase.db");
      return _database!;
    }
  }

  Future<Database> _initDB(String filepath) async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();

    String folderPath = join(documentDirectory.path, 'FreshIceDatabasefolder');

    Directory folder = Directory(folderPath);
    if (!(await folder.exists())) {
      await folder.create(recursive: true);
    }

    String dbPath = join(folder.path, filepath);

    return await openDatabase(dbPath, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    bool CustomerDatabaseTableExists =
        await doesTableExist(db, tableDatabaseCustomer);

    bool InventoryDatabaseTableExists =
        await doesTableExist(db, tableDatabaseInventory);

    bool CompanyDatabaseTableExists =
        await doesTableExist(db, tableDatabaseCompany);

    bool PaymentTermDatabaseTableExists =
        await doesTableExist(db, tableDatabasePaymentTerm);

    bool SalesHeadDatabaseTableExists =
        await doesTableExist(db, tableDatabaseSalesHead);

    bool SalesDetailsDatabaseTableExists =
        await doesTableExist(db, tableDatabaseSalesDetails);

    //variables for customer table
    const idType = "VARCHAR(255) NOT NULL";
    const customernameType = "VARCHAR(255) NOT NULL";
    const customerphonenoType = "VARCHAR(255) NOT NULL";
    const customeremailidType = "VARCHAR(255) NOT NULL";
    const customertrnType = "VARCHAR(255) NOT NULL";
    const customeraddressType = "TEXT NOT NULL";
    const customerpaymenttermType = "TEXT NOT NULL";
    const customerpaymenttermidType = "TEXT NOT NULL";
    const customerissyncedType = "TEXT NOT NULL";

    //variables for inventory table
    const idinventoryType = "VARCHAR(255) NOT NULL";
    const partnumberType = "VARCHAR(255)";
    const descriptionType = "TEXT";
    const brandidType = "VARCHAR(255)";
    const brandnameType = "VARCHAR(255)";
    const genericidType = "VARCHAR(255)";
    const genericnameType = "VARCHAR(255)";
    const availablequantityType = "VARCHAR(255)";
    const defaultunitnameType = "TEXT";
    const defaultunitidType = "TEXT";
    const defaultunitfactorType = "TEXT";
    const taxcodeType = "TEXT";
    const costrateType = "TEXT";
    const sellingpriceType = "TEXT";
    const arrunitsType = "TEXT";

    //variables for company table
    const idcompanyType = "INTEGER PRIMARY KEY AUTOINCREMENT";
    const companylastinvoicednoType = "VARCHAR(255) NOT NULL";
    const companynextinvoicenoType = "VARCHAR(255) NOT NULL";
    const companywarehouseidType = "VARCHAR(255) NOT NULL";
    const companylastlocalsyncedType = "VARCHAR(255) NOT NULL";

    //variables for payment term table
    const idpaymenttermType = "INTEGER PRIMARY KEY AUTOINCREMENT";
    const paymentcodeType = "TEXT";
    const paymenttermsType = "TEXT";
    const noofdaysType = "TEXT";
    const paymenttypeType = "TEXT";

    //variables for sales head table
    const idsalesheadType = "INTEGER PRIMARY KEY AUTOINCREMENT";
    const salesheadinvoiceidType = "TEXT";
    const salesheadinvoicedateType = "TEXT";
    const salesheadcustomeridType = "TEXT";
    const salesheadcustomernameType = "TEXT";
    const salesheadtotalamountType = "TEXT";
    const salesheadsubtotalamountType = "TEXT";
    const salesheadtotalvatType = "TEXT";
    const salesheadpaymenttypeidType = "TEXT";
    const salesheadissyncedType = "TEXT";
    const salesheadsynceddateType = "TEXT";
    const salesheadcreatedbyType = "TEXT";

    //variables for sales details table
    const idsalesdetailsType = "INTEGER PRIMARY KEY AUTOINCREMENT";
    const salesdetailsproductidType = "TEXT";
    const salesdetailsinvoiceidType = "TEXT";
    const salesdetailsinvoicedateType = "TEXT";
    const salesdetailspartnumberType = "TEXT";
    const salesdetailsdescriptionType = "TEXT";
    const salesdetailsunitidType = "TEXT";
    const salesdetailsunitnameType = "TEXT";
    const salesdetailsunitfactorType = "TEXT";
    const salesdetailsquantityType = "TEXT";
    const salesdetailsrateType = "TEXT";
    const salesdetailsdeductionamountType = "TEXT";
    const salesdetailstaxvatpercentageType = "TEXT";
    const salesdetailstaxvatamountType = "TEXT";
    const salesdetailssubamountType = "TEXT";
    const salesdetailssubvatType = "TEXT";
    const salesdetailssubnetType = "TEXT";
    const salesdetailscreatedbyType = "TEXT";

    if (!CustomerDatabaseTableExists) {
      db.execute('''
    CREATE TABLE $tableDatabaseCustomer (
      ${CustomerDatabaseFields.id} $idType,
      ${CustomerDatabaseFields.customername} $customernameType,
      ${CustomerDatabaseFields.customerphoneno} $customerphonenoType,
      ${CustomerDatabaseFields.customeraddress} $customeraddressType,
      ${CustomerDatabaseFields.customeremailid} $customeremailidType,
      ${CustomerDatabaseFields.customertrn} $customertrnType,
      ${CustomerDatabaseFields.customerpaymentterm} $customerpaymenttermType,
      ${CustomerDatabaseFields.customerpaymenttermid} $customerpaymenttermidType,
      ${CustomerDatabaseFields.issynced} $customerissyncedType
    )
    ''');
      print("Table created for customer");
    }

    if (!InventoryDatabaseTableExists) {
      db.execute('''
    CREATE TABLE $tableDatabaseInventory (
      ${InventoryDatabaseFields.id} $idinventoryType,
      ${InventoryDatabaseFields.partnumber} $partnumberType,
      ${InventoryDatabaseFields.description} $descriptionType,
      ${InventoryDatabaseFields.brandid} $brandidType,
      ${InventoryDatabaseFields.brandname} $brandnameType,
      ${InventoryDatabaseFields.genericid} $genericidType,
      ${InventoryDatabaseFields.genericname} $genericnameType,
      ${InventoryDatabaseFields.availableqty} $availablequantityType,
      ${InventoryDatabaseFields.defaultunitname} $defaultunitnameType,
      ${InventoryDatabaseFields.defaultunitid} $defaultunitidType,
      ${InventoryDatabaseFields.defaultunitfactor} $defaultunitfactorType,
      ${InventoryDatabaseFields.taxcode} $taxcodeType,
      ${InventoryDatabaseFields.costrate} $costrateType,
      ${InventoryDatabaseFields.sellingprice} $sellingpriceType,
      ${InventoryDatabaseFields.arrunits} $arrunitsType
    )
    ''');
      print("Table created for inventory");
    }

    if (!CompanyDatabaseTableExists) {
      db.execute('''
    CREATE TABLE $tableDatabaseCompany (
      ${CompanyDatabaseFields.id} $idcompanyType,
      ${CompanyDatabaseFields.lastinvoicedno} $companylastinvoicednoType,
      ${CompanyDatabaseFields.nextinvoiceno} $companynextinvoicenoType,
      ${CompanyDatabaseFields.warehouseid} $companywarehouseidType,
      ${CompanyDatabaseFields.lastlocalsynced} $companylastlocalsyncedType
    )
    ''');
      print("Table created for company");
    }

    if (!PaymentTermDatabaseTableExists) {
      db.execute('''
    CREATE TABLE $tableDatabasePaymentTerm (
      ${PaymentTermDatabaseFields.id} $idpaymenttermType,
      ${PaymentTermDatabaseFields.paymentcode} $paymentcodeType,
      ${PaymentTermDatabaseFields.paymentterms} $paymenttermsType,
      ${PaymentTermDatabaseFields.noofdays} $noofdaysType,
      ${PaymentTermDatabaseFields.paymenttype} $paymenttypeType
    )
    ''');
      print("Table created for payment term");
    }

    if (!SalesHeadDatabaseTableExists) {
      db.execute('''
    CREATE TABLE $tableDatabaseSalesHead (
      ${SalesHeadDatabaseFields.id} $idsalesheadType,
      ${SalesHeadDatabaseFields.invoiceid} $salesheadinvoiceidType,
      ${SalesHeadDatabaseFields.invoicedate} $salesheadinvoicedateType,
      ${SalesHeadDatabaseFields.customerid} $salesheadcustomeridType,
      ${SalesHeadDatabaseFields.customername} $salesheadcustomernameType,
      ${SalesHeadDatabaseFields.totalamount} $salesheadtotalamountType,
      ${SalesHeadDatabaseFields.subtotalamount} $salesheadsubtotalamountType,
      ${SalesHeadDatabaseFields.totalvat} $salesheadtotalvatType,
      ${SalesHeadDatabaseFields.paymenttypeid} $salesheadpaymenttypeidType,
      ${SalesHeadDatabaseFields.issynced} $salesheadissyncedType,
      ${SalesHeadDatabaseFields.synceddate} $salesheadsynceddateType,
      ${SalesHeadDatabaseFields.createdby} $salesheadcreatedbyType
    )
    ''');
      print("Table created for sales head");
    }

    if (!SalesDetailsDatabaseTableExists) {
      db.execute('''
    CREATE TABLE $tableDatabaseSalesDetails (
      ${SalesDetailsDatabaseFields.id} $idsalesdetailsType,
      ${SalesDetailsDatabaseFields.productid} $salesdetailsproductidType,
      ${SalesDetailsDatabaseFields.invoiceid} $salesdetailsinvoiceidType,
      ${SalesDetailsDatabaseFields.invoicedate} $salesdetailsinvoicedateType,
      ${SalesDetailsDatabaseFields.partnumber} $salesdetailspartnumberType,
      ${SalesDetailsDatabaseFields.description} $salesdetailsdescriptionType,
      ${SalesDetailsDatabaseFields.unitid} $salesdetailsunitidType,
      ${SalesDetailsDatabaseFields.unitname} $salesdetailsunitnameType,
      ${SalesDetailsDatabaseFields.unitfactor} $salesdetailsunitfactorType,
      ${SalesDetailsDatabaseFields.quantity} $salesdetailsquantityType,
      ${SalesDetailsDatabaseFields.rate} $salesdetailsrateType,
      ${SalesDetailsDatabaseFields.deductionamount} $salesdetailsdeductionamountType,
      ${SalesDetailsDatabaseFields.taxvatpercentage} $salesdetailstaxvatpercentageType,
      ${SalesDetailsDatabaseFields.taxvatamount} $salesdetailstaxvatamountType,
      ${SalesDetailsDatabaseFields.subamount} $salesdetailssubamountType,
      ${SalesDetailsDatabaseFields.subvat} $salesdetailssubvatType,
      ${SalesDetailsDatabaseFields.subnet} $salesdetailssubnetType,
      ${SalesDetailsDatabaseFields.createdby} $salesdetailscreatedbyType
    )
    ''');
      print("Table created for sales details");
    }
  }

  Future<bool> doesTableExist(Database db, String tableName) async {
    var result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'");
    return result.isNotEmpty;
  }

  Future<Map<String, int>> getTableCounts() async {
    Database db = await database;
    Map<String, int> tableCounts = {};

    List<Map<String, dynamic>> tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name LIKE 'pos_%';",
    );

    for (var table in tables) {
      String tableName = table['name'];
      int count = Sqflite.firstIntValue(
              await db.rawQuery('SELECT COUNT(*) FROM $tableName;')) ??
          0;
      tableCounts[tableName] = count;
    }

    return tableCounts;
  }

  Future<Map<String, dynamic>> createCustomer(
      Map<String, dynamic> customerdetails) async {
    final db = await instance.database;

    final existingCustomer = await db.query(
      tableDatabaseCustomer,
      where: 'customer_phone_no = ?',
      whereArgs: [customerdetails["customer_phone_no"]],
    );

    if (existingCustomer.isNotEmpty) {
      return {
        "status": 0,
        "message": "Phone number is already in the database",
      };
    }
    try {
      await db.insert(
        tableDatabaseCustomer,
        CustomerDatabaseModel(
                id: customerdetails["id"],
                customername: customerdetails["customer_name"],
                customerphoneno: customerdetails["customer_phone_no"],
                customeremailid: customerdetails["customer_email_id"],
                customertrn: customerdetails["customer_trn"],
                customeraddress: customerdetails["customer_address"],
                customerpaymenttermid:
                    customerdetails["customer_payment_term_id"],
                customerpaymentterm: customerdetails["customer_payment_term"],
                issynced: customerdetails["is_synced"])
            .tojson(),
      );
      return {"status": 1, "message": "Customer created successfully"};
    } catch (e) {
      print("Error inserting data: $e");
      return {
        "status": 0,
        "message": "There is an issue while inserting your data to the database"
      };
    }
  }

  Future<Map<String, dynamic>> createOrUpdateCompany(
      Map<String, dynamic> companydetails) async {
    final db = await instance.database;

    try {
      await db.insert(
        tableDatabaseCompany,
        CompanyDatabaseModel(
                id: companydetails["id"],
                lastinvoicedno: companydetails["lastinvoicedno"],
                nextinvoiceno: companydetails["nextinvoiceno"],
                warehouseid: companydetails["warehouseid"],
                lastlocalsynced: companydetails["lastlocalsynced"])
            .tojson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return {
        "status": 1,
        "message": "Company details added/updated successfully"
      };
    } catch (e) {
      print("Error inserting/updating data: $e");
      return {
        "status": 0,
        "message":
            "There is an issue while inserting/updating your data to the database"
      };
    }
  }

  Future<Map<String, dynamic>> getCompanyById(int id) async {
    final db = await instance.database;

    try {
      final result = await db.query(
        tableDatabaseCompany,
        where: '${CompanyDatabaseFields.id} = ?',
        whereArgs: [id],
      );

      if (result.isNotEmpty) {
        print(result.first);
        return {
          "status": 1,
          "message": "Record retrieved successfully",
          "data": result.first
        };
      } else {
        return {"status": 0, "message": "No record found with the provided id"};
      }
    } catch (e) {
      return {"status": 0, "message": "Error querying data"};
    }
  }

  Future<Map<String, dynamic>> checkProductAvailability(
      List<dynamic> products) async {
    final db = await instance.database;

    List<dynamic> availableProducts = [];
    List<String> unavailableProducts = [];

    Map<String, num> productQuantities = {};
    for (var product in products) {
      String productId = product['product_id'];
      num quantity = num.parse(product['quantity'].toString()) *
          num.parse(product['unit_factor'].toString());
      if (productQuantities.containsKey(productId)) {
        productQuantities[productId] = productQuantities[productId]! + quantity;
      } else {
        productQuantities[productId] = quantity;
      }
    }

    for (var productId in productQuantities.keys) {
      List<Map<String, dynamic>> inventoryRecords = await db.query(
        tableDatabaseInventory,
        where: '${InventoryDatabaseFields.id} = ?',
        whereArgs: [productId],
      );

      if (inventoryRecords.isNotEmpty) {
        num availableQty = num.parse(inventoryRecords[0]
                [InventoryDatabaseFields.availableqty]
            .toString());
        num requiredQty = productQuantities[productId]!;

        if (availableQty >= requiredQty) {
          products
              .where((product) => product['product_id'] == productId)
              .forEach((product) {
            availableProducts.add(product);
          });
        } else {
          String arrUnitsJson =
              inventoryRecords[0][InventoryDatabaseFields.arrunits];
          List<dynamic> arrUnits = jsonDecode(arrUnitsJson);

          String availableUnitsMessage = arrUnits.map((unit) {
            num unitQuantity =
                availableQty / num.parse(unit['unit_factor'].toString());
            return '$unitQuantity ${unit['unit_name']}';
          }).join(' / ');

          unavailableProducts.add(
              'Product ${inventoryRecords[0][InventoryDatabaseFields.partnumber]} has only $availableUnitsMessage available');
        }
      } else {
        unavailableProducts
            .add('Product with ID $productId is not available in inventory');
      }
    }

    if (unavailableProducts.isEmpty) {
      return {
        'status': 'success',
        'available_products': availableProducts,
        'unavailable_products': unavailableProducts,
      };
    } else {
      return {
        'status': 'error',
        'message': unavailableProducts.join(', '),
        'available_products': availableProducts,
        'unavailable_products': unavailableProducts,
      };
    }
  }

  // Future<Map<String, dynamic>> checkProductAvailability(
  //     List<dynamic> products) async {
  //   final db = await instance.database;

  //   List<dynamic> availableProducts = [];
  //   List<String> unavailableProducts = [];

  //   Map<String, num> productQuantities = {};
  //   for (var product in products) {
  //     String productId = product['product_id'];
  //     num quantity = num.parse(product['quantity'].toString()) *
  //         num.parse(product['unit_factor'].toString());
  //     if (productQuantities.containsKey(productId)) {
  //       productQuantities[productId] = productQuantities[productId]! + quantity;
  //     } else {
  //       productQuantities[productId] = quantity;
  //     }
  //   }

  //   for (var productId in productQuantities.keys) {
  //     List<Map<String, dynamic>> inventoryRecords = await db.query(
  //       tableDatabaseInventory,
  //       where: '${InventoryDatabaseFields.id} = ?',
  //       whereArgs: [productId],
  //     );

  //     if (inventoryRecords.isNotEmpty) {
  //       num availableQty = num.parse(inventoryRecords[0]
  //               [InventoryDatabaseFields.availableqty]
  //           .toString());
  //       num requiredQty = productQuantities[productId]!;

  //       if (availableQty >= requiredQty) {
  //         products
  //             .where((product) => product['product_id'] == productId)
  //             .forEach((product) {
  //           availableProducts.add(product);
  //         });
  //       } else {
  //         unavailableProducts.add(
  //             'Product ${inventoryRecords[0][InventoryDatabaseFields.partnumber]} has only $availableQty quantity available');
  //       }
  //     } else {
  //       unavailableProducts
  //           .add('Product with ID $productId is not available in inventory');
  //     }
  //   }

  //   if (unavailableProducts.isEmpty) {
  //     return {
  //       'status': 'success',
  //       'available_products': availableProducts,
  //       'unavailable_products': unavailableProducts,
  //     };
  //   } else {
  //     return {
  //       'status': 'error',
  //       'message': unavailableProducts.join(', '),
  //       'available_products': availableProducts,
  //       'unavailable_products': unavailableProducts,
  //     };
  //   }
  // }

  Future<List<CustomerDatabaseModel>> searchCustomerList(
      String searchTerm) async {
    final db = await instance.database;

    if (searchTerm.isEmpty) {
      final List<Map<String, Object?>> result =
          await db.query(tableDatabaseCustomer, orderBy: "customer_name ASC");
      print(result);
      return result
          .map((json) => CustomerDatabaseModel.fromJson(json))
          .toList();
    } else {
      final List<Map<String, Object?>> result = await db.rawQuery(
        "SELECT * FROM $tableDatabaseCustomer WHERE customer_name LIKE ? ORDER BY customer_name ASC",
        ['%$searchTerm%'],
      );
      return result
          .map((json) => CustomerDatabaseModel.fromJson(json))
          .toList();
    }
  }

  // Future<List<CustomerDatabaseModel>> searchCustomerList(
  //     String searchTerm) async {
  //   final db = await instance.database;

  //   if (searchTerm.isEmpty) {
  //     final List<Map<String, Object?>> result =
  //         await db.query(tableDatabaseCustomer);
  //     print(result);
  //     return result
  //         .map((json) => CustomerDatabaseModel.fromJson(json))
  //         .toList();
  //   } else {
  //     final List<Map<String, Object?>> result = await db.rawQuery(
  //       "SELECT * FROM $tableDatabaseCustomer WHERE customer_name LIKE ? ORDER BY customer_name ASC",
  //       ['%$searchTerm%'],
  //     );
  //     return result
  //         .map((json) => CustomerDatabaseModel.fromJson(json))
  //         .toList();
  //   }
  // }

  Future<List<PaymentTermDatabaseModel>> searchPaymentTermList(
      String searchTerm) async {
    final db = await instance.database;

    if (searchTerm.isEmpty) {
      final List<Map<String, Object?>> result =
          await db.query(tableDatabasePaymentTerm);
      return result
          .map((json) => PaymentTermDatabaseModel.fromJson(json))
          .toList();
    } else {
      final List<Map<String, Object?>> result = await db.rawQuery(
        "SELECT * FROM $tableDatabasePaymentTerm WHERE payment_terms LIKE ?",
        ['%$searchTerm%'],
      );
      return result
          .map((json) => PaymentTermDatabaseModel.fromJson(json))
          .toList();
    }
  }

  Future<List<InventoryDatabaseModel>> searchInventoryList(
      String searchTerm) async {
    final db = await instance.database;

    List<Map<String, Object?>> result;

    if (searchTerm.isEmpty) {
      result = await db.query(tableDatabaseInventory);
    } else {
      result = await db.rawQuery(
        "SELECT * FROM $tableDatabaseInventory WHERE part_number LIKE ? OR description LIKE ?",
        ['%$searchTerm%', '%$searchTerm%'],
      );
    }
    print(result);

    return result.map((json) => InventoryDatabaseModel.fromJson(json)).toList();
  }

  Future<List<dynamic>> allInventoryList() async {
    final db = await instance.database;
    List<Map<String, Object?>> result;
    result = await db.query(tableDatabaseInventory);
    print(result);
    return result;
  }

  Future<Map<String, dynamic>> deleteAllFromTable(String tableName) async {
    final db = await instance.database;
    try {
      await db.delete(tableName);
      return {"status": 1, "message": "Records cleared successfully"};
    } catch (e) {
      return {"status": 0, "message": e.toString()};
    }
  }

  Future<Map<String, dynamic>> intermediateInventorySync(
      List<dynamic> products) async {
    final db = await instance.database;

    try {
      for (var product in products) {
        String productId = product['id'].toString();
        num defaultUnitFactor =
            num.parse(product['default_unit_factor'].toString());
        num availableQty = num.parse(product['available_qty'].toString());
        num totalAvailableQty = defaultUnitFactor * availableQty;

        List<Map<String, dynamic>> existingRecords = await db.query(
          tableDatabaseInventory,
          where: '${InventoryDatabaseFields.id} = ?',
          whereArgs: [productId],
        );

        if (existingRecords.isNotEmpty) {
          num currentQty = num.parse(existingRecords[0]
                  [InventoryDatabaseFields.availableqty]
              .toString());
          num updatedQty = currentQty + totalAvailableQty;

          await db.update(
            tableDatabaseInventory,
            {
              InventoryDatabaseFields.availableqty: updatedQty.toString(),
            },
            where: '${InventoryDatabaseFields.id} = ?',
            whereArgs: [productId],
          );
        } else {
          await db.insert(
            tableDatabaseInventory,
            {
              InventoryDatabaseFields.id: productId,
              InventoryDatabaseFields.partnumber: product['part_number'],
              InventoryDatabaseFields.description: product['description'],
              InventoryDatabaseFields.brandid: product['brand_id'],
              InventoryDatabaseFields.brandname: product['brand_name'],
              InventoryDatabaseFields.genericid: product['generic_id'],
              InventoryDatabaseFields.genericname: product['generic_name'],
              InventoryDatabaseFields.availableqty:
                  totalAvailableQty.toString(),
              InventoryDatabaseFields.defaultunitname:
                  product['default_unit_name'],
              InventoryDatabaseFields.defaultunitid: product['default_unit_id'],
              InventoryDatabaseFields.defaultunitfactor:
                  product['default_unit_factor'].toString(),
              InventoryDatabaseFields.taxcode: product['tax_code'],
              InventoryDatabaseFields.costrate: product['cost_rate'].toString(),
              InventoryDatabaseFields.sellingprice:
                  product['selling_price'].toString(),
              InventoryDatabaseFields.arrunits:
                  jsonEncode(product['arr_units']),
            },
          );
        }
      }

      return {"status": 1, "message": "Inventory synced successfully"};
    } catch (e) {
      return {"status": 0, "message": e.toString()};
    }
  }

  // Future<void> intermediateInventorySync(List<dynamic> products) async {
  //   final db = await instance.database;

  //   for (var product in products) {
  //     String productId = product['id'].toString();
  //     num defaultUnitFactor =
  //         num.parse(product['default_unit_factor'].toString());
  //     num availableQty = num.parse(product['available_qty'].toString());
  //     num totalAvailableQty = defaultUnitFactor * availableQty;

  //     List<Map<String, dynamic>> existingRecords = await db.query(
  //       tableDatabaseInventory,
  //       where: '${InventoryDatabaseFields.id} = ?',
  //       whereArgs: [productId],
  //     );

  //     if (existingRecords.isNotEmpty) {
  //       num currentQty = num.parse(existingRecords[0]
  //               [InventoryDatabaseFields.availableqty]
  //           .toString());
  //       num updatedQty = currentQty + totalAvailableQty;

  //       await db.update(
  //         tableDatabaseInventory,
  //         {
  //           InventoryDatabaseFields.availableqty: updatedQty.toString(),
  //         },
  //         where: '${InventoryDatabaseFields.id} = ?',
  //         whereArgs: [productId],
  //       );
  //     } else {
  //       await db.insert(
  //         tableDatabaseInventory,
  //         {
  //           InventoryDatabaseFields.id: productId,
  //           InventoryDatabaseFields.partnumber: product['part_number'],
  //           InventoryDatabaseFields.description: product['description'],
  //           InventoryDatabaseFields.brandid: product['brand_id'],
  //           InventoryDatabaseFields.brandname: product['brand_name'],
  //           InventoryDatabaseFields.genericid: product['generic_id'],
  //           InventoryDatabaseFields.genericname: product['generic_name'],
  //           InventoryDatabaseFields.availableqty: totalAvailableQty.toString(),
  //           InventoryDatabaseFields.defaultunitname:
  //               product['default_unit_name'],
  //           InventoryDatabaseFields.defaultunitid: product['default_unit_id'],
  //           InventoryDatabaseFields.defaultunitfactor:
  //               product['default_unit_factor'].toString(),
  //           InventoryDatabaseFields.taxcode: product['tax_code'],
  //           InventoryDatabaseFields.costrate: product['cost_rate'].toString(),
  //           InventoryDatabaseFields.sellingprice:
  //               product['selling_price'].toString(),
  //           InventoryDatabaseFields.arrunits: jsonEncode(product['arr_units']),
  //         },
  //       );
  //     }
  //   }
  // }

  // Future<Map<String, dynamic>> deleteAllTables() async {
  //   final db = await instance.database;

  //   final List<Map<String, dynamic>> tables = await db.rawQuery(
  //       "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';");

  //   Batch batch = db.batch();
  //   for (var table in tables) {
  //     String tableName = table['name'];
  //     batch.execute('DROP TABLE IF EXISTS $tableName');
  //   }

  //   try {
  //     await batch.commit(noResult: true);
  //     return {"status": 1, "message": "Database cleared"};
  //   } catch (e) {
  //     return {"status": 0, "message": e.toString()};
  //   }
  // }

  Future<Map<String, dynamic>> checkCustomerTable() async {
    final db = await instance.database;

    try {
      final List<Map<String, dynamic>> result = await db
          .rawQuery('SELECT COUNT(*) as count FROM $tableDatabaseCustomer');
      int count = result.first['count'];

      if (count > 0) {
        return {
          "status": 1,
          "message": "Customer table has records",
          "count": count
        };
      } else {
        return {
          "status": 0,
          "message": "Customer table is empty",
          "count": count
        };
      }
    } catch (e) {
      return {"status": 0, "message": e.toString()};
    }
  }

  Future<Map<String, dynamic>> clearAllTables() async {
    final db = await instance.database;

    final List<Map<String, dynamic>> tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';");

    Batch batch = db.batch();
    for (var table in tables) {
      String tableName = table['name'];
      batch.execute('DELETE FROM $tableName');
    }

    try {
      await batch.commit(noResult: true);
      return {"status": 1, "message": "All table data cleared"};
    } catch (e) {
      return {"status": 0, "message": e.toString()};
    }
  }

  Future<Map<String, dynamic>> insertDataAndMarkSelected(
      List<dynamic> data) async {
    final db = await instance.database;
    try {
      for (var i = 0; i < data.length; i++) {
        String tableName = data[i]['table'];
        print("This is the table name");
        print(tableName);
        bool tableExists = await doesTableExist(db, tableName);
        print("The table exists");
        print(tableExists);
        if (tableExists) {
          await db.transaction((txn) async {
            if (tableName == 'pos_inventory') {
              for (var entry in data[i]["details"]) {
                int? count = Sqflite.firstIntValue(await txn.rawQuery(
                    'SELECT COUNT(*) FROM $tableName WHERE id = ?',
                    [entry['id']]));
                if (count! > 0) {
                  await txn.update(
                    tableName,
                    {
                      'part_number': entry['part_number'],
                      'description': entry['description'],
                      'brand_id': entry['brand_id'],
                      'brand_name': entry['brand_name'],
                      'generic_id': entry['generic_id'],
                      'generic_name': entry['generic_name'],
                      'available_qty': entry['available_qty'],
                      'default_unit_name': entry['default_unit_name'],
                      'default_unit_id': entry['default_unit_id'],
                      'default_unit_factor': entry['default_unit_factor'],
                      'tax_code': entry['tax_code'],
                      'cost_rate': entry['cost_rate'],
                      'selling_price': entry['selling_price'],
                      'arr_units': jsonEncode(entry['arr_units']),
                    },
                    where: 'id = ?',
                    whereArgs: [entry['id']],
                  );
                } else {
                  await txn.insert(tableName, {
                    'id': entry['id'].toString(),
                    'part_number': entry['part_number'],
                    'description': entry['description'],
                    'brand_id': entry['brand_id'],
                    'brand_name': entry['brand_name'],
                    'generic_id': entry['generic_id'],
                    'generic_name': entry['generic_name'],
                    'available_qty': entry['available_qty'],
                    'default_unit_name': entry['default_unit_name'],
                    'default_unit_id': entry['default_unit_id'],
                    'default_unit_factor': entry['default_unit_factor'],
                    'tax_code': entry['tax_code'],
                    'cost_rate': entry['cost_rate'],
                    'selling_price': entry['selling_price'],
                    'arr_units': jsonEncode(entry['arr_units']),
                  });
                }
              }
            } else if (tableName == 'pos_customer') {
              for (var entry in data[i]["details"]) {
                int? count = Sqflite.firstIntValue(await txn.rawQuery(
                    'SELECT COUNT(*) FROM $tableName WHERE id = ?',
                    [entry['id']]));
                if (count! > 0) {
                  await txn.update(
                    tableName,
                    {
                      'customer_name': entry['customer_name'],
                      'customer_phone_no': entry['customer_phone_no'],
                      'customer_email_id': entry['customer_email_id'],
                      'customer_trn': entry['customer_trn'],
                      'customer_address': entry['customer_address'],
                      'customer_payment_term_id':
                          entry['customer_payment_term_id'],
                      'customer_payment_term': entry['customer_payment_term'],
                      'is_synced': "Y"
                    },
                    where: 'id = ?',
                    whereArgs: [entry['id']],
                  );
                } else {
                  await txn.insert(tableName, {
                    'id': entry['id'].toString(),
                    'customer_name': entry['customer_name'],
                    'customer_phone_no': entry['customer_phone_no'],
                    'customer_email_id': entry['customer_email_id'],
                    'customer_trn': entry['customer_trn'],
                    'customer_address': entry['customer_address'],
                    'customer_payment_term_id':
                        entry['customer_payment_term_id'],
                    'customer_payment_term': entry['customer_payment_term'],
                    'is_synced': "Y"
                  });
                }
              }
            } else {
              await txn.rawDelete('DELETE FROM $tableName');
              for (var entry in data[i]["details"]) {
                await txn.insert(tableName, entry);
              }
            }
          });
        }
      }
      return {'status': 'success'};
    } catch (e) {
      print(e);
      return {'status': 'error'};
    }
  }

  // Future<Map<String, dynamic>> insertDataAndMarkSelected(
  //     List<dynamic> data) async {
  //   final db = await instance.database;
  //   try {
  //     for (var i = 0; i < data.length; i++) {
  //       String tableName = data[i]['table'];
  //       print("This is the table name");
  //       print(tableName);
  //       bool tableExists = await doesTableExist(db, tableName);
  //       print("The table exists");
  //       print(tableExists);
  //       if (tableExists) {
  //         await db.transaction((txn) async {
  //           if (tableName == 'pos_inventory') {
  //             for (var entry in data[i]["details"]) {
  //               print("This is the entry");
  //               print(entry);
  //               int? count = Sqflite.firstIntValue(await txn.rawQuery(
  //                   'SELECT COUNT(*) FROM $tableName WHERE id = ?',
  //                   [entry['id']]));
  //               if (count! > 0) {
  //                 await txn.update(
  //                   tableName,
  //                   {
  //                     'part_number': entry['part_number'],
  //                     'description': entry['description'],
  //                     'brand_id': entry['brand_id'],
  //                     'brand_name': entry['brand_name'],
  //                     'generic_id': entry['generic_id'],
  //                     'generic_name': entry['generic_name'],
  //                     'available_qty': entry['available_qty'],
  //                     'default_unit_name': entry['default_unit_name'],
  //                     'default_unit_id': entry['default_unit_id'],
  //                     'default_unit_factor': entry['default_unit_factor'],
  //                     'tax_code': entry['tax_code'],
  //                     'cost_rate': entry['cost_rate'],
  //                     'selling_price': entry['selling_price'],
  //                     'arr_units': jsonEncode(entry['arr_units']),
  //                   },
  //                   where: 'id = ?',
  //                   whereArgs: [entry['id']],
  //                 );
  //               } else {
  //                 await txn.insert(tableName, {
  //                   'id': entry['id'],
  //                   'part_number': entry['part_number'],
  //                   'description': entry['description'],
  //                   'brand_id': entry['brand_id'],
  //                   'brand_name': entry['brand_name'],
  //                   'generic_id': entry['generic_id'],
  //                   'generic_name': entry['generic_name'],
  //                   'available_qty': entry['available_qty'],
  //                   'default_unit_name': entry['default_unit_name'],
  //                   'default_unit_id': entry['default_unit_id'],
  //                   'default_unit_factor': entry['default_unit_factor'],
  //                   'tax_code': entry['tax_code'],
  //                   'cost_rate': entry['cost_rate'],
  //                   'selling_price': entry['selling_price'],
  //                   'arr_units': jsonEncode(entry['arr_units']),
  //                 });
  //               }
  //             }
  //           } else if (tableName == 'pos_customer') {
  //             for (var entry in data[i]["details"]) {
  //               print("This is the entry");
  //               print(entry);
  //               int? count = Sqflite.firstIntValue(await txn.rawQuery(
  //                   'SELECT COUNT(*) FROM $tableName WHERE id = ?',
  //                   [entry['id']]));
  //               if (count! > 0) {
  //                 await txn.update(
  //                   tableName,
  //                   {
  //                     'customer_name': entry['customer_name'],
  //                     'customer_phone_no': entry['customer_phone_no'],
  //                     'customer_email_id': entry['customer_email_id'],
  //                     'customer_trn': entry['customer_trn'],
  //                     'customer_address': entry['customer_address'],
  //                     'customer_payment_term_id':
  //                         entry['customer_payment_term_id'],
  //                     'customer_payment_term': entry['customer_payment_term'],
  //                     'is_synced': "Y"
  //                   },
  //                   where: 'id = ?',
  //                   whereArgs: [entry['id']],
  //                 );
  //               } else {
  //                 await txn.insert(tableName, {
  //                   'id': entry['id'],
  //                   'customer_name': entry['customer_name'],
  //                   'customer_phone_no': entry['customer_phone_no'],
  //                   'customer_email_id': entry['customer_email_id'],
  //                   'customer_trn': entry['customer_trn'],
  //                   'customer_address': entry['customer_address'],
  //                   'customer_payment_term_id':
  //                       entry['customer_payment_term_id'],
  //                   'customer_payment_term': entry['customer_payment_term'],
  //                   'is_synced': "Y"
  //                 });
  //               }
  //             }
  //           } else {
  //             await txn.rawDelete('DELETE FROM $tableName');
  //             for (var entry in data[i]["details"]) {
  //               await txn.insert(tableName, entry);
  //             }
  //           }
  //         });
  //       }
  //     }
  //     return {'status': 'success'};
  //   } catch (e) {
  //     print(e);
  //     return {'status': 'error'};
  //   }
  // }

  // Future<Map<String, dynamic>> insertDataAndMarkSelected(
  //     List<dynamic> data) async {
  //   final db = await instance.database;
  //   try {
  //     for (var i = 0; i < data.length; i++) {
  //       String tableName = data[i]['table'];
  //       print("This is the table name");
  //       print(tableName);
  //       bool tableExists = await doesTableExist(db, tableName);
  //       print("The table exists");
  //       print(tableExists);
  //       if (tableExists) {
  //         await db.transaction((txn) async {
  //           await txn.rawDelete('DELETE FROM $tableName');
  //           for (var entry in data[i]["details"]) {
  //             print("This is the entry");
  //             print(entry);
  //             if (tableName == 'pos_inventory') {
  //               await txn.insert(tableName, {
  //                 'id': entry['id'],
  //                 'part_number': entry['part_number'],
  //                 'description': entry['description'],
  //                 'brand_id': entry['brand_id'],
  //                 'brand_name': entry['brand_name'],
  //                 'generic_id': entry['generic_id'],
  //                 'generic_name': entry['generic_name'],
  //                 'available_qty': entry['available_qty'],
  //                 'default_unit_name': entry['default_unit_name'],
  //                 'default_unit_id': entry['default_unit_id'],
  //                 'default_unit_factor': entry['default_unit_factor'],
  //                 'tax_code': entry['tax_code'],
  //                 'cost_rate': entry['cost_rate'],
  //                 'selling_price': entry['selling_price'],
  //                 'arr_units': jsonEncode(entry['arr_units']),
  //               });
  //             } else if (tableName == 'pos_customer') {
  //               await txn.insert(tableName, {
  //                 'id': entry['id'],
  //                 'customer_name': entry['customer_name'],
  //                 'customer_phone_no': entry['customer_phone_no'],
  //                 'customer_email_id': entry['customer_email_id'],
  //                 'customer_trn': entry['customer_trn'],
  //                 'customer_address': entry['customer_address'],
  //                 'customer_payment_term_id': entry['customer_payment_term_id'],
  //                 'customer_payment_term': entry['customer_payment_term'],
  //                 'is_synced': "Y"
  //               });
  //             } else {
  //               await txn.insert(tableName, entry);
  //             }
  //           }
  //         });
  //       }
  //     }
  //     return {'status': 'success'};
  //   } catch (e) {
  //     print(e);
  //     return {'status': 'error'};
  //   }
  // }

  // Future<Map<String, dynamic>> createSalesTransaction(
  //     String invoiceid,
  //     String invoicedate,
  //     String customerid,
  //     String customername,
  //     String totalamount,
  //     String subtotalamount,
  //     String totalvat,
  //     String paymenttypeid,
  //     List<dynamic> itemslist,
  //     String createdby) async {
  //   final db = await instance.database;

  //   try {
  //     await db.transaction((txn) async {
  //       await txn.insert(
  //           tableDatabaseSalesHead,
  //           SalesHeadDatabaseModel(
  //                   invoiceid: invoiceid,
  //                   invoicedate: invoicedate,
  //                   customerid: customerid,
  //                   customername: customername,
  //                   totalamount: totalamount,
  //                   subtotalamount: subtotalamount,
  //                   totalvat: totalvat,
  //                   paymenttypeid: paymenttypeid,
  //                   createdby: createdby)
  //               .tojson());

  //       for (var salesdetail in itemslist) {
  //         await txn.insert(
  //           tableDatabaseSalesDetails,
  //           SalesDetailsDatabaseModel(
  //                   productid: salesdetail["product_id"],
  //                   invoiceid: salesdetail["invoice_id"],
  //                   invoicedate: salesdetail["invoice_date"],
  //                   partnumber: salesdetail["part_number"],
  //                   description: salesdetail["description"],
  //                   unitid: salesdetail["unit_id"],
  //                   unitname: salesdetail["unit_name"],
  //                   unitfactor: salesdetail["unit_factor"],
  //                   quantity: salesdetail["quantity"],
  //                   rate: salesdetail["rate"],
  //                   deductionamount: salesdetail["deduction_amount"],
  //                   taxvatpercentage: salesdetail["tax_vat_percentage"],
  //                   taxvatamount: salesdetail["tax_vat_amount"],
  //                   subamount: salesdetail["sub_amount"],
  //                   subvat: salesdetail["sub_vat"],
  //                   subnet: salesdetail["sub_net"],
  //                   createdby: createdby)
  //               .tojson(),
  //         );
  //       }
  //       await txn.rawUpdate(
  //         'UPDATE $tableDatabaseCompany SET next_invoice_no = next_invoice_no + 1 WHERE id = 1',
  //       );
  //     });

  //     return {"status": 1, "message": "Sales transaction added successfully"};
  //   } catch (e) {
  //     print("Error inserting/updating sales transaction: $e");
  //     return {
  //       "status": 0,
  //       "message":
  //           "There is an issue while inserting/updating your data to the database"
  //     };
  //   }
  // }

  Future<List<Map<String, dynamic>>>
      getSalesHeadRecordsCountByDayOfWeek() async {
    final db = await instance.database;

    try {
      final result = await db.rawQuery('''
      SELECT 
        strftime('%w', invoice_date) AS day_of_week, 
        COUNT(*) AS count 
      FROM $tableDatabaseSalesHead 
      GROUP BY day_of_week
    ''');

      const dayNames = {
        '0': 'Sunday',
        '1': 'Monday',
        '2': 'Tuesday',
        '3': 'Wednesday',
        '4': 'Thursday',
        '5': 'Friday',
        '6': 'Saturday',
      };

      Map<String, int> countsByDay = {
        'Sunday': 0,
        'Monday': 0,
        'Tuesday': 0,
        'Wednesday': 0,
        'Thursday': 0,
        'Friday': 0,
        'Saturday': 0,
      };

      for (var row in result) {
        String dayOfWeek = row['day_of_week'] as String;
        int count = row['count'] as int;
        countsByDay[dayNames[dayOfWeek]!] = count;
      }

      List<Map<String, dynamic>> countsByDayList =
          countsByDay.entries.map((entry) {
        return {'day': entry.key, 'count': entry.value};
      }).toList();

      return countsByDayList;
    } catch (e) {
      print("Error retrieving sales head records count by day of week: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> createSalesTransaction(
      String invoiceid,
      String invoicedate,
      String customerid,
      String customername,
      String totalamount,
      String subtotalamount,
      String totalvat,
      String paymenttypeid,
      List<dynamic> itemslist,
      String issynced,
      String synceddate,
      String createdby) async {
    final db = await instance.database;

    try {
      await db.transaction((txn) async {
        await txn.insert(
          tableDatabaseSalesHead,
          SalesHeadDatabaseModel(
            invoiceid: invoiceid,
            invoicedate: invoicedate,
            customerid: customerid,
            customername: customername,
            totalamount: totalamount,
            subtotalamount: subtotalamount,
            totalvat: totalvat,
            paymenttypeid: paymenttypeid,
            issynced: issynced,
            synceddate: synceddate,
            createdby: createdby,
          ).tojson(),
        );

        for (var salesdetail in itemslist) {
          await txn.insert(
            tableDatabaseSalesDetails,
            SalesDetailsDatabaseModel(
              productid: salesdetail["product_id"],
              invoiceid: salesdetail["invoice_id"],
              invoicedate: salesdetail["invoice_date"],
              partnumber: salesdetail["part_number"],
              description: salesdetail["description"],
              unitid: salesdetail["unit_id"],
              unitname: salesdetail["unit_name"],
              unitfactor: salesdetail["unit_factor"],
              quantity: salesdetail["quantity"],
              rate: salesdetail["rate"],
              deductionamount: salesdetail["deduction_amount"],
              taxvatpercentage: salesdetail["tax_vat_percentage"],
              taxvatamount: salesdetail["tax_vat_amount"],
              subamount: salesdetail["sub_amount"],
              subvat: salesdetail["sub_vat"],
              subnet: salesdetail["sub_net"],
              createdby: createdby,
            ).tojson(),
          );

          await txn.rawUpdate(
            'UPDATE $tableDatabaseInventory '
            'SET available_qty = available_qty - ? '
            'WHERE id = ?',
            [
              (num.parse(salesdetail["quantity"]) *
                      num.parse(salesdetail["unit_factor"]))
                  .toString(),
              salesdetail["product_id"]
            ],
          );
        }

        await txn.rawUpdate(
          'UPDATE $tableDatabaseCompany '
          'SET next_invoice_no = next_invoice_no + 1 '
          'WHERE id = 1',
        );
      });

      return {"status": 1, "message": "Sales transaction added successfully"};
    } catch (e) {
      print("Error inserting/updating sales transaction: $e");
      return {
        "status": 0,
        "message":
            "There is an issue while inserting/updating your data to the database"
      };
    }
  }

  Future<Map<String, dynamic>> updateSyncStatus(String invoiceid) async {
    final db = await instance.database;

    try {
      int count = await db.rawUpdate('''
      UPDATE $tableDatabaseSalesHead 
      SET is_synced = 'Y', synced_date = ?
      WHERE invoice_id = ?
    ''', [DateTime.now().toString(), invoiceid]);

      return {
        "status": 1,
        "message": count > 0
            ? "Sync status updated successfully"
            : "No record found with the given invoice_id"
      };
    } catch (e) {
      print("Error updating sync status: $e");
      return {
        "status": 0,
        "message": "There is an issue while updating the sync status"
      };
    }
  }

  String formatDateString(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<Map<String, dynamic>> syncSingleInvoiceById(
      String invoiceId, String token, BuildContext context) async {
    final db = await instance.database;

    try {
      final List<Map<String, dynamic>> records = await db.query(
        tableDatabaseSalesHead,
        where: 'invoice_id = ? AND is_synced = ?',
        whereArgs: [invoiceId, 'N'],
      );

      if (records.isEmpty) {
        return {
          'status': 'error',
          'message':
              'The invoice with ID $invoiceId is either already synced or does not exist.',
        };
      }

      Map<String, dynamic> record = records.first;
      String customerid = record['customer_id'];
      String roundoffamount = "0";
      String paymenttypeid = record["payment_type_id"];
      String invoicedate = formatDateString(record["invoice_date"].toString());
      String grandtotal = record['total_amount'];

      final List<Map<String, dynamic>> salesDetails = await db.query(
        tableDatabaseSalesDetails,
        where: 'invoice_id = ?',
        whereArgs: [invoiceId],
      );

      List<dynamic> materials = salesDetails.map((detail) {
        return {
          'product_id': detail['product_id'],
          'invoice_id': detail['invoice_id'],
          'invoice_date': detail['invoice_date'],
          'part_number': detail['part_number'],
          'description': detail['description'],
          'unit_id': detail['unit_id'],
          'unit_name': detail['unit_name'],
          'unit_factor': detail['unit_factor'],
          'quantity': detail['quantity'],
          'rate': detail['rate'],
          'deduction_amount': detail['deduction_amount'],
          'tax_vat_percentage': detail['tax_vat_percentage'],
          'tax_vat_amount': detail['tax_vat_amount'],
          'sub_amount': detail['sub_amount'],
          'sub_vat': detail['sub_vat'],
          'sub_net': detail['sub_net'],
          'created_by': detail['created_by']
        };
      }).toList();

      Map<String, dynamic> response = await API.postSyncInvoicesAPI(
        invoiceId,
        customerid,
        paymenttypeid,
        roundoffamount,
        grandtotal,
        invoicedate,
        materials,
        token,
        context,
      );

      if (response['status'] == 'success') {
        await db.update(
          tableDatabaseSalesHead,
          {
            'is_synced': 'Y',
            'synced_date': DateTime.now().toString(),
          },
          where: 'invoice_id = ?',
          whereArgs: [invoiceId],
        );

        return {
          'status': 'success',
          'message': 'Invoice $invoiceId synced successfully.',
        };
      } else {
        return {
          'status': 'error',
          'message':
              'Failed to sync invoice $invoiceId. ${response['message']}',
        };
      }
    } catch (e) {
      print("Error syncing invoice $invoiceId: $e");
      return {
        'status': 'error',
        'message': 'An error occurred while syncing invoice $invoiceId. $e',
      };
    }
  }

  Future<Map<String, dynamic>> getUnsyncedSalesHeadRecordsAndSync(
      String token, BuildContext context) async {
    final db = await instance.database;
    List<Map<String, dynamic>> syncedRecords = [];
    List<Map<String, dynamic>> unsyncedRecords = [];

    try {
      final List<Map<String, dynamic>> records = await db.query(
        tableDatabaseSalesHead,
        where: 'is_synced = ?',
        whereArgs: ['N'],
      );
      print("this is the records");
      print(records);

      if (records.isEmpty) {
        return {
          'status': 'error',
          'synced_records': [],
          'unsynced_records': [],
          "message": "There is no remaining invoices to sync to cloud"
        };
      } else {
        for (var record in records) {
          String invoiceid = record['invoice_id'];
          String customerid = record['customer_id'];
          String roundoffamount = "0";
          String paymenttypeid = record["payment_type_id"];
          String invoicedate =
              formatDateString(record["invoice_date"].toString());
          print("This is the invoice date");
          print(invoicedate);
          String grandtotal = record['total_amount'];

          final List<Map<String, dynamic>> salesDetails = await db.query(
            tableDatabaseSalesDetails,
            where: 'invoice_id = ?',
            whereArgs: [invoiceid],
          );

          List<dynamic> materials = salesDetails.map((detail) {
            return {
              'product_id': detail['product_id'],
              'invoice_id': detail['invoice_id'],
              'invoice_date': detail['invoice_date'],
              'part_number': detail['part_number'],
              'description': detail['description'],
              'unit_id': detail['unit_id'],
              'unit_name': detail['unit_name'],
              'unit_factor': detail['unit_factor'],
              'quantity': detail['quantity'],
              'rate': detail['rate'],
              'deduction_amount': detail['deduction_amount'],
              'tax_vat_percentage': detail['tax_vat_percentage'],
              'tax_vat_amount': detail['tax_vat_amount'],
              'sub_amount': detail['sub_amount'],
              'sub_vat': detail['sub_vat'],
              'sub_net': detail['sub_net'],
              'created_by': detail['created_by']
            };
          }).toList();

          Map<String, dynamic> response = await API.postSyncInvoicesAPI(
            invoiceid,
            customerid,
            paymenttypeid,
            roundoffamount,
            grandtotal,
            invoicedate,
            materials,
            token,
            context,
          );

          if (response['status'] == 'success') {
            await db.update(
              tableDatabaseSalesHead,
              {
                'is_synced': 'Y',
                'synced_date': DateTime.now().toString(),
              },
              where: 'invoice_id = ?',
              whereArgs: [invoiceid],
            );
            syncedRecords.add(record);
          } else {
            unsyncedRecords.add(record);
          }
        }

        return {
          'status': 'success',
          'synced_records': syncedRecords,
          'unsynced_records': unsyncedRecords,
          "message": "Synced successfully"
        };
      }
    } catch (e) {
      print("Error retrieving unsynced sales head records and syncing: $e");
      return {
        'status': 'error',
        'synced_records': [],
        'unsynced_records': [],
        "message": e.toString()
      };
    }
  }

  Future<Map<String, dynamic>> getUnsyncedSalesHeadRecordsAndSyncAndLogOut(
      String token, BuildContext context) async {
    final db = await instance.database;
    List<Map<String, dynamic>> syncedRecords = [];
    List<Map<String, dynamic>> unsyncedRecords = [];

    try {
      final List<Map<String, dynamic>> records = await db.query(
        tableDatabaseSalesHead,
        where: 'is_synced = ?',
        whereArgs: ['N'],
      );
      print("this is the records");
      print(records);

      if (records.isEmpty) {
        return {
          'status': 'success',
          'synced_records': [],
          'unsynced_records': [],
          "message": "There is no remaining invoices to sync to cloud"
        };
      } else {
        for (var record in records) {
          String invoiceid = record['invoice_id'];
          String customerid = record['customer_id'];
          String roundoffamount = "0";
          String paymenttypeid = record["payment_type_id"];
          String invoicedate =
              formatDateString(record["invoice_date"].toString());
          print("This is the invoice date");
          print(invoicedate);
          String grandtotal = record['total_amount'];

          final List<Map<String, dynamic>> salesDetails = await db.query(
            tableDatabaseSalesDetails,
            where: 'invoice_id = ?',
            whereArgs: [invoiceid],
          );

          List<dynamic> materials = salesDetails.map((detail) {
            return {
              'product_id': detail['product_id'],
              'invoice_id': detail['invoice_id'],
              'invoice_date': detail['invoice_date'],
              'part_number': detail['part_number'],
              'description': detail['description'],
              'unit_id': detail['unit_id'],
              'unit_name': detail['unit_name'],
              'unit_factor': detail['unit_factor'],
              'quantity': detail['quantity'],
              'rate': detail['rate'],
              'deduction_amount': detail['deduction_amount'],
              'tax_vat_percentage': detail['tax_vat_percentage'],
              'tax_vat_amount': detail['tax_vat_amount'],
              'sub_amount': detail['sub_amount'],
              'sub_vat': detail['sub_vat'],
              'sub_net': detail['sub_net'],
              'created_by': detail['created_by']
            };
          }).toList();

          Map<String, dynamic> response = await API.postSyncInvoicesAPI(
            invoiceid,
            customerid,
            paymenttypeid,
            roundoffamount,
            grandtotal,
            invoicedate,
            materials,
            token,
            context,
          );

          if (response['status'] == 'success') {
            await db.update(
              tableDatabaseSalesHead,
              {
                'is_synced': 'Y',
                'synced_date': DateTime.now().toString(),
              },
              where: 'invoice_id = ?',
              whereArgs: [invoiceid],
            );
            syncedRecords.add(record);
          } else {
            unsyncedRecords.add(record);
          }
        }

        return {
          'status': 'success',
          'synced_records': syncedRecords,
          'unsynced_records': unsyncedRecords,
          "message": "Synced successfully"
        };
      }
    } catch (e) {
      print("Error retrieving unsynced sales head records and syncing: $e");
      return {
        'status': 'error',
        'synced_records': [],
        'unsynced_records': [],
        "message": e.toString()
      };
    }
  }

  // Future<List<SalesHeadDatabaseModel>> getAllSalesHeadRecords(
  //     String searchterm) async {
  //   final db = await instance.database;
  //   try {
  //     String query = 'SELECT * FROM $tableDatabaseSalesHead';
  //     List<dynamic> args = [];

  //     if (searchterm.isNotEmpty) {
  //       query += ' WHERE customer_name LIKE ? OR invoice_id LIKE ?';
  //       String searchPattern = '%$searchterm%';
  //       args.addAll([searchPattern, searchPattern]);
  //     }

  //     final List<Map<String, dynamic>> result = await db.rawQuery(query, args);
  //     print("this is the data");
  //     print(result);
  //     List<SalesHeadDatabaseModel> salesHeadRecords =
  //         result.map((json) => SalesHeadDatabaseModel.fromJson(json)).toList();
  //     return salesHeadRecords;
  //   } catch (e) {
  //     print("Error retrieving sales head records: $e");
  //     return [];
  //   }
  // }

  Future<List<SalesHeadDatabaseModel>> getAllSalesHeadRecords(
      String searchterm, DateTime? invoiceDate) async {
    final db = await instance.database;
    try {
      String query = 'SELECT * FROM $tableDatabaseSalesHead';
      List<dynamic> args = [];

      if (searchterm.isNotEmpty) {
        query += ' WHERE customer_name LIKE ? OR invoice_id LIKE ?';
        String searchPattern = '%$searchterm%';
        args.addAll([searchPattern, searchPattern]);
      }

      if (invoiceDate != null) {
        if (args.isNotEmpty) {
          query += ' AND ';
        } else {
          query += ' WHERE ';
        }
        String formattedDate = "${invoiceDate.year.toString().padLeft(4, '0')}-"
            "${invoiceDate.month.toString().padLeft(2, '0')}-"
            "${invoiceDate.day.toString().padLeft(2, '0')}";

        query += 'SUBSTR(invoice_date, 1, 10) = ?';
        args.add(formattedDate);
      }

      query += ' ORDER BY invoice_date DESC';

      final List<Map<String, dynamic>> result = await db.rawQuery(query, args);
      print("this is the data");
      print(result);
      List<SalesHeadDatabaseModel> salesHeadRecords =
          result.map((json) => SalesHeadDatabaseModel.fromJson(json)).toList();
      return salesHeadRecords;
    } catch (e) {
      print("Error retrieving sales head records: $e");
      return [];
    }
  }

  // Future<List<SalesHeadDatabaseModel>> getAllSalesHeadRecords(
  //     String searchterm, DateTime? invoiceDate) async {
  //   final db = await instance.database;
  //   try {
  //     String query = 'SELECT * FROM $tableDatabaseSalesHead';
  //     List<dynamic> args = [];

  //     if (searchterm.isNotEmpty) {
  //       query += ' WHERE customer_name LIKE ? OR invoice_id LIKE ?';
  //       String searchPattern = '%$searchterm%';
  //       args.addAll([searchPattern, searchPattern]);
  //     }

  //     if (invoiceDate != null) {
  //       if (args.isNotEmpty) {
  //         query += ' AND ';
  //       } else {
  //         query += ' WHERE ';
  //       }
  //       query += 'invoice_date = ?';
  //       args.add(formatDateString(invoiceDate.toString()));
  //     }

  //     // Order by invoice_date DESC to get the most recent records first
  //     query += ' ORDER BY invoice_date DESC';

  //     final List<Map<String, dynamic>> result = await db.rawQuery(query, args);
  //     print("this is the data");
  //     print(result);
  //     List<SalesHeadDatabaseModel> salesHeadRecords =
  //         result.map((json) => SalesHeadDatabaseModel.fromJson(json)).toList();
  //     return salesHeadRecords;
  //   } catch (e) {
  //     print("Error retrieving sales head records: $e");
  //     return [];
  //   }
  // }

  // Future<List<SalesHeadDatabaseModel>> getAllSalesHeadRecords() async {
  //   final db = await instance.database;
  //   try {
  //     final List<Map<String, dynamic>> result =
  //         await db.query(tableDatabaseSalesHead);
  //     List<SalesHeadDatabaseModel> salesHeadRecords =
  //         result.map((json) => SalesHeadDatabaseModel.fromJson(json)).toList();
  //     return salesHeadRecords;
  //   } catch (e) {
  //     print("Error retrieving sales head records: $e");
  //     return [];
  //   }
  // }

  Future<List<SalesDetailsDatabaseModel>> getSalesDetailsByInvoiceId(
      String invoiceId) async {
    final db = await instance.database;

    try {
      final List<Map<String, dynamic>> result = await db.query(
        tableDatabaseSalesDetails,
        where: '${SalesDetailsDatabaseFields.invoiceid} = ?',
        whereArgs: [invoiceId],
      );
      print(result);

      List<SalesDetailsDatabaseModel> salesDetails = result
          .map((json) => SalesDetailsDatabaseModel.fromJson(json))
          .toList();
      return salesDetails;
    } catch (e) {
      print("Error retrieving sales details for invoice_id $invoiceId: $e");
      return [];
    }
  }
}
