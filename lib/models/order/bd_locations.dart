//cSpell:disable

enum BDLocations {
  dhaka(
    'Dhaka',
    [
      'Dhaka',
      'Faridpur',
      'Gazipur',
      'Gopalganj',
      'Kishoreganj',
      'Madaripur',
      'Manikganj',
      'Munshiganj',
      'Narayanganj',
      'Narsingdi',
      'Rajbari',
      'Shariatpur',
      'Tangail',
    ],
  ),
  rajshahi(
    'Rajshahi',
    [
      'Rajshahi',
      'Bogra',
      'Jaipurhat',
      'Naogaon',
      'Natore',
      'Chapainawabganj',
      'Pabna',
      'Sirajganj',
    ],
  ),
  rangpur(
    'Rangpur',
    [
      'Rangpur',
      'Dinajpur',
      'Gaibandha',
      'Kurigram',
      'Lalmonirhat',
      'Nilphamari',
      'Panchagarh',
      'Thakurgaon'
    ],
  ),
  sylhet(
    'Sylhet',
    ['Sylhet', 'Habiganj', 'Moulvibazar', 'Sunamganj'],
  ),
  barisal(
    'Barisal',
    ['Barisal', 'Barguna', 'Bhola', 'Jhalokati', 'Patuakhali', 'Pirojpur'],
  ),
  chittagong(
    'Chittagong',
    [
      'Chittagong',
      'Bandarban',
      'Brahmanbaria',
      'Chandpur',
      'Comilla',
      'Cox\'s Bazar',
      'Feni',
      'Khagrachari',
      'Lakshmipur',
      'Noakhali',
      'Rangamati'
    ],
  ),
  mymensingh(
    'Mymensingh',
    ['Mymensingh', 'Jamalpur', 'Netrokona', 'Sherpur'],
  ),
  khulna(
    'Khulna',
    [
      'Khulna',
      'Bagerhat',
      'Chuadanga',
      'Jessore',
      'Jhenaidah',
      'Kushtia',
      'Magura',
      'Meherpur',
      'Narail',
      'Satkhira'
    ],
  ),
  ;

  final List<String> district;
  final String division;
  const BDLocations(this.division, this.district);

  static BDLocations fromDivision(String type) {
    final map = <String, BDLocations>{
      'Dhaka': dhaka,
      'Rajshahi': rajshahi,
      'Rangpur': rangpur,
      'Sylhet': sylhet,
      'Barisal': barisal,
      'Chittagong': chittagong,
      'Mymensingh': mymensingh,
      'Khulna': khulna,
    };

    return map[type] ?? dhaka;
  }
}
