class RideDetail {
  final String? bookingId;
  final String? bookingCode;
  final String? pickupAdd;
  final String? pickupLat;
  final String? pickupLng;
  final String? dropAdd;
  final String? dropLat;
  final String? dropLng;
  final String? dist;
  final String? estTime;

  final String? estAmount;
  final String? status;
  final String? carId;
  final String? cityId;
  final String? driverId;
  final String? driverName;
  final String? driverImg;
  final String? driverPhone;
  final String? carImg;
  final String? carNum;
  final String? otp;

  RideDetail({
    this.bookingId,
    this.bookingCode,
    this.pickupAdd,
    this.pickupLat,
    this.pickupLng,
    this.dropAdd,
    this.dropLat,
    this.dropLng,
    this.dist,
    this.estTime,
    this.estAmount,
    this.status,
    this.carId,
    this.cityId,
    this.driverId,
    this.driverName,
    this.driverImg,
    this.driverPhone,
    this.carImg,
    this.carNum,
    this.otp,
  });

  @override
  String toString() {
    return 'RideDetail(bookingId: $bookingId, bookingCode: $bookingCode, pickupAdd: $pickupAdd, pickupLat: $pickupLat, pickupLng: $pickupLng, dropAdd: $dropAdd, dropLat: $dropLat, dropLng: $dropLng, dist: $dist, estTime: $estTime, estAmount: $estAmount, status: $status, carId: $carId, cityId: $cityId, driverId: $driverId, driverName: $driverName, driverImg: $driverImg, driverPhone: $driverPhone, carImg: $carImg, carNum: $carNum, otp: $otp)';
  }
}
