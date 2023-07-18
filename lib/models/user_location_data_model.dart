class UserLocationData {
  final String? phone;
  final String token;
  final String lat;
  final String lon;

  UserLocationData({
    this.phone,
    required this.token,
    required this.lat,
    required this.lon,
  });

  @override
  String toString() {
    return 'UserLocationData(phone: $phone, token: $token, lat: $lat, lon: $lon)';
  }
}
