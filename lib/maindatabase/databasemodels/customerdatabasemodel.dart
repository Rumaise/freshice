const String tableDatabaseCustomer = "pos_customer";

class CustomerDatabaseFields {
  static const String id = 'id';
  static const String customername = 'customer_name';
  static const String customerphoneno = 'customer_phone_no';
  static const String customeremailid = 'customer_email_id';
  static const String customertrn = 'customer_trn';
  static const String customeraddress = 'customer_address';
  static const String customerpaymenttermid = 'customer_payment_term_id';
  static const String customerpaymentterm = 'customer_payment_term';
  static const String issynced = 'is_synced';
}

class CustomerDatabaseModel {
  final String id;
  final String customername;
  final String customerphoneno;
  final String customeremailid;
  final String customertrn;
  final String customeraddress;
  final String customerpaymenttermid;
  final String customerpaymentterm;
  final String issynced;

  const CustomerDatabaseModel(
      {required this.id,
      required this.customername,
      required this.customerphoneno,
      required this.customeremailid,
      required this.customertrn,
      required this.customeraddress,
      required this.customerpaymenttermid,
      required this.customerpaymentterm,
      required this.issynced});

  Map<String, Object?> tojson() => {
        CustomerDatabaseFields.id: id,
        CustomerDatabaseFields.customername: customername,
        CustomerDatabaseFields.customerphoneno: customerphoneno,
        CustomerDatabaseFields.customeremailid: customeremailid,
        CustomerDatabaseFields.customertrn: customertrn,
        CustomerDatabaseFields.customeraddress: customeraddress,
        CustomerDatabaseFields.customerpaymenttermid: customerpaymenttermid,
        CustomerDatabaseFields.customerpaymentterm: customerpaymentterm,
        CustomerDatabaseFields.issynced: issynced
      };

  static CustomerDatabaseModel fromJson(Map<String, Object?> json) =>
      CustomerDatabaseModel(
        id: json[CustomerDatabaseFields.id] as String,
        customername: json[CustomerDatabaseFields.customername] as String,
        customerphoneno: json[CustomerDatabaseFields.customerphoneno] as String,
        customeremailid: json[CustomerDatabaseFields.customeremailid] as String,
        customertrn: json[CustomerDatabaseFields.customertrn] as String,
        customeraddress: json[CustomerDatabaseFields.customeraddress] as String,
        customerpaymenttermid:
            json[CustomerDatabaseFields.customerpaymenttermid] as String,
        customerpaymentterm:
            json[CustomerDatabaseFields.customerpaymentterm] as String,
        issynced: json[CustomerDatabaseFields.issynced] as String,
      );
}
