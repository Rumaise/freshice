const String tableDatabaseCompany = "pos_company";

class CompanyDatabaseFields {
  static const String id = 'id';
  static const String lastinvoicedno = 'last_invoiced_no';
  static const String nextinvoiceno = 'next_invoice_no';
  static const String warehouseid = 'warehouse_id';
  static const String lastlocalsynced = 'last_local_synced';
}

class CompanyDatabaseModel {
  final int? id;
  final String lastinvoicedno;
  final String nextinvoiceno;
  final String warehouseid;
  final String lastlocalsynced;

  const CompanyDatabaseModel(
      {this.id,
      required this.lastinvoicedno,
      required this.nextinvoiceno,
      required this.warehouseid,
      required this.lastlocalsynced});

  Map<String, Object?> tojson() => {
        CompanyDatabaseFields.id: id,
        CompanyDatabaseFields.lastinvoicedno: lastinvoicedno,
        CompanyDatabaseFields.nextinvoiceno: nextinvoiceno,
        CompanyDatabaseFields.warehouseid: warehouseid,
        CompanyDatabaseFields.lastlocalsynced: lastlocalsynced
      };

  static CompanyDatabaseModel fromJson(Map<String, Object?> json) =>
      CompanyDatabaseModel(
          id: json[CompanyDatabaseFields.id] as int,
          lastinvoicedno: json[CompanyDatabaseFields.lastinvoicedno] as String,
          nextinvoiceno: json[CompanyDatabaseFields.nextinvoiceno] as String,
          warehouseid: json[CompanyDatabaseFields.warehouseid] as String,
          lastlocalsynced:
              json[CompanyDatabaseFields.lastlocalsynced] as String);
}
