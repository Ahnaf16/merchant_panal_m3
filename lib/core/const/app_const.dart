class ProductConst {
  static const List<String> ram = ['4GB', '6GB', '8GB', '12GB'];

  static const List<String> storage = ['64GB', '128GB', '256GB', '512GB'];
  static const List<String> specList = [
    'RAM',
    'Storage',
    'Display',
    'Chipset',
    'Charging',
    'Battery'
  ];
  static const List<String> brands = [
    'Apple',
    'Samsung',
    'Google',
    'Sony',
    'OnePlus',
    'Xiaomi',
    'Realme',
    'Oppo',
    'Vivo',
    'Tecno',
    'Infinix'
  ];
}

class LocalPath {
  static String androidDownloadDir(String fileName) =>
      '/storage/emulated/0/Download/$fileName';
}
