const String tableDatabaseSalesDetails = "pos_sales_details";

class SalesDetailsDatabaseFields {
  static const String id = 'id';
  static const String productid = 'product_id';
  static const String invoiceid = 'invoice_id';
  static const String invoicedate = 'invoice_date';
  static const String partnumber = 'part_number';
  static const String description = 'description';
  static const String unitid = 'unit_id';
  static const String unitname = 'unit_name';
  static const String unitfactor = 'unit_factor';
  static const String quantity = 'quantity';
  static const String rate = 'rate';
  static const String deductionamount = 'deduction_amount';
  static const String taxvatpercentage = 'tax_vat_percentage';
  static const String taxvatamount = 'tax_vat_amount';
  static const String subamount = 'sub_amount';
  static const String subvat = 'sub_vat';
  static const String subnet = 'sub_net';
  static const String createdby = 'created_by';
}

class SalesDetailsDatabaseModel {
  final int? id;
  final String productid;
  final String invoiceid;
  final String invoicedate;
  final String partnumber;
  final String description;
  final String unitid;
  final String unitname;
  final String unitfactor;
  final String quantity;
  final String rate;
  final String deductionamount;
  final String taxvatpercentage;
  final String taxvatamount;
  final String subamount;
  final String subvat;
  final String subnet;
  final String createdby;

  const SalesDetailsDatabaseModel(
      {this.id,
      required this.productid,
      required this.invoiceid,
      required this.invoicedate,
      required this.partnumber,
      required this.description,
      required this.unitid,
      required this.unitname,
      required this.unitfactor,
      required this.quantity,
      required this.rate,
      required this.deductionamount,
      required this.taxvatpercentage,
      required this.taxvatamount,
      required this.subamount,
      required this.subvat,
      required this.subnet,
      required this.createdby});

  Map<String, Object?> tojson() => {
        SalesDetailsDatabaseFields.id: id,
        SalesDetailsDatabaseFields.productid: productid,
        SalesDetailsDatabaseFields.invoiceid: invoiceid,
        SalesDetailsDatabaseFields.invoicedate: invoicedate,
        SalesDetailsDatabaseFields.partnumber: partnumber,
        SalesDetailsDatabaseFields.description: description,
        SalesDetailsDatabaseFields.unitid: unitid,
        SalesDetailsDatabaseFields.unitname: unitname,
        SalesDetailsDatabaseFields.unitfactor: unitfactor,
        SalesDetailsDatabaseFields.quantity: quantity,
        SalesDetailsDatabaseFields.rate: rate,
        SalesDetailsDatabaseFields.deductionamount: deductionamount,
        SalesDetailsDatabaseFields.taxvatpercentage: taxvatpercentage,
        SalesDetailsDatabaseFields.taxvatamount: taxvatamount,
        SalesDetailsDatabaseFields.subamount: subamount,
        SalesDetailsDatabaseFields.subvat: subvat,
        SalesDetailsDatabaseFields.subnet: subnet,
        SalesDetailsDatabaseFields.createdby: createdby
      };

  static SalesDetailsDatabaseModel fromJson(Map<String, Object?> json) =>
      SalesDetailsDatabaseModel(
          id: json[SalesDetailsDatabaseFields.id] as int,
          productid: json[SalesDetailsDatabaseFields.productid] as String,
          invoiceid: json[SalesDetailsDatabaseFields.invoiceid] as String,
          invoicedate: json[SalesDetailsDatabaseFields.invoicedate] as String,
          partnumber: json[SalesDetailsDatabaseFields.partnumber] as String,
          description: json[SalesDetailsDatabaseFields.description] as String,
          unitid: json[SalesDetailsDatabaseFields.unitid] as String,
          unitname: json[SalesDetailsDatabaseFields.unitname] as String,
          unitfactor: json[SalesDetailsDatabaseFields.unitfactor] as String,
          quantity: json[SalesDetailsDatabaseFields.quantity] as String,
          rate: json[SalesDetailsDatabaseFields.rate] as String,
          deductionamount:
              json[SalesDetailsDatabaseFields.deductionamount] as String,
          taxvatpercentage:
              json[SalesDetailsDatabaseFields.taxvatpercentage] as String,
          taxvatamount: json[SalesDetailsDatabaseFields.taxvatamount] as String,
          subamount: json[SalesDetailsDatabaseFields.subamount] as String,
          subvat: json[SalesDetailsDatabaseFields.subvat] as String,
          subnet: json[SalesDetailsDatabaseFields.subnet] as String,
          createdby: json[SalesDetailsDatabaseFields.createdby] as String);
}
