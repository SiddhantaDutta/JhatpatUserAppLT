class DriverListModel {
  final String? lat;
  final String? lng;
  final String? dist;

  DriverListModel({
    this.lat,
    this.lng,
    this.dist,
  });

  @override
  String toString() => 'DriverListModel(lat: $lat, lng: $lng, dist: $dist)';
}
