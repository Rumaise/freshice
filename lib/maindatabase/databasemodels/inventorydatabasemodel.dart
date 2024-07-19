const String tableDatabaseInventory = "pos_inventory";

class InventoryDatabaseFields {
  static const String id = 'id';
  static const String partnumber = 'part_number';
  static const String description = 'description';
  static const String brandid = 'brand_id';
  static const String brandname = 'brand_name';
  static const String genericid = 'generic_id';
  static const String genericname = 'generic_name';
  static const String availableqty = 'available_qty';
  static const String defaultunitname = 'default_unit_name';
  static const String defaultunitid = 'default_unit_id';
  static const String defaultunitfactor = 'default_unit_factor';
  static const String taxcode = 'tax_code';
  static const String costrate = 'cost_rate';
  static const String sellingprice = 'selling_price';
  static const String arrunits = 'arr_units';
}

class InventoryDatabaseModel {
  final String id;
  final String partnumber;
  final String description;
  final String brandid;
  final String brandname;
  final String genericid;
  final String genericname;
  final String availableqty;
  final String defaultunitname;
  final String defaultunitid;
  final String defaultunitfactor;
  final String taxcode;
  final String costrate;
  final String sellingprice;
  final String arrunits;

  const InventoryDatabaseModel(
      {required this.id,
      required this.partnumber,
      required this.description,
      required this.brandid,
      required this.brandname,
      required this.genericid,
      required this.genericname,
      required this.availableqty,
      required this.defaultunitname,
      required this.defaultunitid,
      required this.defaultunitfactor,
      required this.taxcode,
      required this.costrate,
      required this.sellingprice,
      required this.arrunits});

  Map<String, Object?> tojson() => {
        InventoryDatabaseFields.id: id,
        InventoryDatabaseFields.partnumber: partnumber,
        InventoryDatabaseFields.description: description,
        InventoryDatabaseFields.brandid: brandid,
        InventoryDatabaseFields.brandname: brandname,
        InventoryDatabaseFields.genericid: genericid,
        InventoryDatabaseFields.genericname: genericname,
        InventoryDatabaseFields.availableqty: availableqty,
        InventoryDatabaseFields.defaultunitname: defaultunitname,
        InventoryDatabaseFields.defaultunitid: defaultunitid,
        InventoryDatabaseFields.defaultunitfactor: defaultunitfactor,
        InventoryDatabaseFields.taxcode: taxcode,
        InventoryDatabaseFields.costrate: costrate,
        InventoryDatabaseFields.sellingprice: sellingprice,
        InventoryDatabaseFields.arrunits: arrunits
      };

  static InventoryDatabaseModel fromJson(Map<String, Object?> json) =>
      InventoryDatabaseModel(
          id: json[InventoryDatabaseFields.id].toString(),
          partnumber: json[InventoryDatabaseFields.partnumber].toString(),
          description: json[InventoryDatabaseFields.description].toString(),
          brandid: json[InventoryDatabaseFields.brandid].toString(),
          brandname: json[InventoryDatabaseFields.brandname].toString(),
          genericid: json[InventoryDatabaseFields.genericid].toString(),
          genericname: json[InventoryDatabaseFields.genericname].toString(),
          availableqty: json[InventoryDatabaseFields.availableqty].toString(),
          defaultunitname:
              json[InventoryDatabaseFields.defaultunitname].toString(),
          defaultunitid: json[InventoryDatabaseFields.defaultunitid].toString(),
          defaultunitfactor:
              json[InventoryDatabaseFields.defaultunitfactor].toString(),
          taxcode: json[InventoryDatabaseFields.taxcode].toString(),
          costrate: json[InventoryDatabaseFields.costrate].toString(),
          sellingprice: json[InventoryDatabaseFields.sellingprice].toString(),
          arrunits: json[InventoryDatabaseFields.arrunits].toString());
}
