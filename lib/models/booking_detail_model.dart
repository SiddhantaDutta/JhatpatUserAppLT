class BookingDetails {
  final String? bookingId;
  final String? bookingCode;
  final String? bookingDate;
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
  final String? payType;
  final String? finalTime;
  final String? extraTime;
  final String? extraAmount;
  final String? convenienceFee;
  final String? finalDistFee;
  final String? couponId;
  final String? couponCode;
  final String? disc;
  final String? payableAmount;
  final String? otp;
  // * Driver Details
  final String? lat;
  final String? lng;
  final String? driverImage;
  final String? driverName;
  final String? driverPhone;
  final String? carImage;
  final String? carNumber;

  BookingDetails({
    this.bookingId,
    this.bookingCode,
    this.bookingDate,
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
    this.payType,
    this.finalTime,
    this.extraTime,
    this.extraAmount,
    this.convenienceFee,
    this.finalDistFee,
    this.couponId,
    this.couponCode,
    this.disc,
    this.payableAmount,
    this.otp,
    this.lat,
    this.lng,
    this.driverImage,
    this.driverName,
    this.driverPhone,
    this.carImage,
    this.carNumber,
  });

  @override
  String toString() {
    return 'BookingDetails(bookingId: $bookingId, bookingCode: $bookingCode, bookingDate: $bookingDate, pickupAdd: $pickupAdd, pickupLat: $pickupLat, pickupLng: $pickupLng, dropAdd: $dropAdd, dropLat: $dropLat, dropLng: $dropLng, dist: $dist, estTime: $estTime, estAmount: $estAmount, status: $status, carId: $carId, cityId: $cityId, payType: $payType, finalTime: $finalTime, extraTime: $extraTime, extraAmount: $extraAmount, convenienceFee: $convenienceFee, finalDistFee: $finalDistFee, couponId: $couponId, couponCode: $couponCode, disc: $disc, payableAmount: $payableAmount, otp: $otp, lat: $lat, lng: $lng, driverImage: $driverImage, driverName: $driverName, driverPhone: $driverPhone, carImage: $carImage, carNumber: $carNumber)';
  }
}
