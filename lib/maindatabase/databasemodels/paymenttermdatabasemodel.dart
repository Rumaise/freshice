const String tableDatabasePaymentTerm = "pos_payment_term";

class PaymentTermDatabaseFields {
  static const String id = 'id';
  static const String paymentcode = 'payment_code';
  static const String paymentterms = 'payment_terms';
  static const String noofdays = 'no_of_days';
  static const String paymenttype = 'payment_type';
}

class PaymentTermDatabaseModel {
  final int? id;
  final String paymentcode;
  final String paymentterms;
  final String noofdays;
  final String paymenttype;

  const PaymentTermDatabaseModel(
      {this.id,
      required this.paymentcode,
      required this.paymentterms,
      required this.noofdays,
      required this.paymenttype});

  Map<String, Object?> tojson() => {
        PaymentTermDatabaseFields.id: id,
        PaymentTermDatabaseFields.paymentcode: paymentcode,
        PaymentTermDatabaseFields.paymentterms: paymentterms,
        PaymentTermDatabaseFields.noofdays: noofdays,
        PaymentTermDatabaseFields.paymenttype: paymenttype
      };

  static PaymentTermDatabaseModel fromJson(Map<String, Object?> json) =>
      PaymentTermDatabaseModel(
          id: json[PaymentTermDatabaseFields.id] as int,
          paymentcode: json[PaymentTermDatabaseFields.paymentcode] as String,
          paymentterms: json[PaymentTermDatabaseFields.paymentterms] as String,
          noofdays: json[PaymentTermDatabaseFields.noofdays] as String,
          paymenttype: json[PaymentTermDatabaseFields.paymenttype] as String);
}
