import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  AddressModel({
    this.id = '',
    required this.name,
    required this.division,
    required this.district,
    required this.address,
    required this.billingNumber,
    required this.type,
    required this.isDefault,
  }) : fullAddress = '$address, $district, $district';

  factory AddressModel.fromDoc(DocumentSnapshot doc) => AddressModel(
        id: doc.id,
        name: doc['name'] as String,
        division: doc['divition'] as String,
        district: doc['district'] as String,
        address: doc['address'] as String,
        billingNumber: doc['billingNumber'] as String,
        type: AddressType.fromMap('${doc['type']}'),
        isDefault: doc['isDefault'] as bool,
      );

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      name: map['name'] as String,
      division: map['divition'] as String,
      district: map['district'] as String,
      address: map['address'] as String,
      billingNumber: map['billingNumber'] as String,
      type: AddressType.fromMap('${map['type']}'),
      isDefault: map['isDefault'] as bool,
    );
  }

  static AddressModel empty = AddressModel(
    name: '',
    division: '',
    district: '',
    address: '',
    billingNumber: '',
    type: AddressType.home,
    isDefault: false,
  );

  final String address;
  final String billingNumber;
  final String district;
  final String division;
  final String fullAddress;
  final String id;
  final bool isDefault;
  final String name;
  final AddressType? type;

  Map<String, dynamic> toMap() => {
        'name': name,
        'divition': division,
        'district': district,
        'address': address,
        'billingNumber': billingNumber,
        'type': type?.name,
        'isDefault': isDefault,
      };

  AddressModel copyWith({
    String? id,
    String? address,
    String? billingNumber,
    String? district,
    String? division,
    String? fullAddress,
    bool? isDefault,
    String? name,
    AddressType? type,
  }) {
    return AddressModel(
      id: id ?? this.id,
      address: address ?? this.address,
      billingNumber: billingNumber ?? this.billingNumber,
      district: district ?? this.district,
      division: division ?? this.division,
      isDefault: isDefault ?? this.isDefault,
      name: name ?? this.name,
      type: type ?? this.type,
    );
  }
}

enum AddressType {
  home,
  office;

  static AddressType? fromMap(String type) {
    final map = <String, AddressType>{'home': home, 'office': office};
    return map[type];
  }
}
