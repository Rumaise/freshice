class CustomerModel {
  String? name;
  String? phone;
  String? email;
  String? trn;

  CustomerModel({this.name, this.phone, this.email, this.trn});

  CustomerModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    trn = json['trn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['phone'] = phone;
    data['email'] = email;
    data['trn'] = trn;
    return data;
  }
}
