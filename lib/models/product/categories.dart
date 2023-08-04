enum Categories {
  smartPhone('Smart Phone'),
  preOwned('Pre Owned Devices'),
  tws('TWS'),
  featurePhone('Feature phone'),
  smartWatch('Smart Watch'),
  headPhone('Head Phone'),
  wireEarphone('Wire Earphone'),
  neckband('Neckband'),
  adapterCable('Adapter & Cable'),
  powerBank('Power Bank'),
  soundBox('Sound Box'),
  smartTV('Smart TV'),
  laptop('Laptop'),
  others('Others');

  final String title;
  const Categories(this.title);

  String toMap() => title;

  factory Categories.fromMap(String type) {
    final map = <String, Categories>{
      'Smart Phone': smartPhone,
      'Pre Owned Devices': preOwned,
      'Feature phone': featurePhone,
      'Smart Watch': smartWatch,
      'Head Phone': headPhone,
      'Wire Earphone': wireEarphone,
      'Neckband': neckband,
      'TWS': tws,
      'Adapter & Cable': adapterCable,
      'Power Bank': powerBank,
      'Sound Box': soundBox,
      'Smart TV': smartTV,
      'Laptop': laptop,
      'Others': others,
    };
    return map[type] ?? others;
  }
}

enum ProductType {
  regular,
  flash,
  campaign,
  hot;

  factory ProductType.fromString(String type) => values.byName(type);
}
