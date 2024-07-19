const String tableDatabaseSalesHead = "pos_sales_head";

class SalesHeadDatabaseFields {
  static const String id = 'id';
  static const String invoiceid = 'invoice_id';
  static const String invoicedate = 'invoice_date';
  static const String customerid = 'customer_id';
  static const String customername = 'customer_name';
  static const String totalamount = 'total_amount';
  static const String subtotalamount = 'sub_total_amount';
  static const String totalvat = 'total_vat';
  static const String paymenttypeid = 'payment_type_id';
  static const String issynced = 'is_synced';
  static const String synceddate = 'synced_date';
  static const String createdby = 'created_by';
}

class SalesHeadDatabaseModel {
  final int? id;
  final String invoiceid;
  final String invoicedate;
  final String customerid;
  final String customername;
  final String totalamount;
  final String subtotalamount;
  final String totalvat;
  final String paymenttypeid;
  final String? issynced;
  final String? synceddate;
  final String createdby;

  const SalesHeadDatabaseModel(
      {this.id,
      required this.invoiceid,
      required this.invoicedate,
      required this.customerid,
      required this.customername,
      required this.totalamount,
      required this.subtotalamount,
      required this.totalvat,
      required this.paymenttypeid,
      this.issynced,
      this.synceddate,
      required this.createdby});

  Map<String, Object?> tojson() => {
        SalesHeadDatabaseFields.id: id,
        SalesHeadDatabaseFields.invoiceid: invoiceid,
        SalesHeadDatabaseFields.invoicedate: invoicedate,
        SalesHeadDatabaseFields.customerid: customerid,
        SalesHeadDatabaseFields.customername: customername,
        SalesHeadDatabaseFields.totalamount: totalamount,
        SalesHeadDatabaseFields.subtotalamount: subtotalamount,
        SalesHeadDatabaseFields.totalvat: totalvat,
        SalesHeadDatabaseFields.paymenttypeid: paymenttypeid,
        SalesHeadDatabaseFields.issynced: issynced,
        SalesHeadDatabaseFields.synceddate: synceddate,
        SalesHeadDatabaseFields.createdby: createdby
      };

  static SalesHeadDatabaseModel fromJson(Map<String, Object?> json) =>
      SalesHeadDatabaseModel(
          id: json[SalesHeadDatabaseFields.id] as int,
          invoiceid: json[SalesHeadDatabaseFields.invoiceid] as String,
          invoicedate: json[SalesHeadDatabaseFields.invoicedate] as String,
          customerid: json[SalesHeadDatabaseFields.customerid] as String,
          customername: json[SalesHeadDatabaseFields.customername] as String,
          totalamount: json[SalesHeadDatabaseFields.totalamount] as String,
          subtotalamount:
              json[SalesHeadDatabaseFields.subtotalamount] as String,
          totalvat: json[SalesHeadDatabaseFields.totalvat] as String,
          paymenttypeid: json[SalesHeadDatabaseFields.paymenttypeid] as String,
          issynced: json[SalesHeadDatabaseFields.issynced] as String,
          synceddate: json[SalesHeadDatabaseFields.synceddate] as String,
          createdby: json[SalesHeadDatabaseFields.createdby] as String);
}
