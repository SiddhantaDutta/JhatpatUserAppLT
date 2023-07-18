class BookingPrices {
  final String? cityId;
  final String? carId;
  final String? carType;
  final String? passengerNo;
  final String? approxPrice;

  BookingPrices({
    this.cityId,
    this.carId,
    this.carType,
    this.passengerNo,
    this.approxPrice,
  });

  @override
  String toString() {
    return 'BookingPrices(cityId: $cityId, carId: $carId, carType: $carType, passengerNo: $passengerNo, approxPrice: $approxPrice)';
  }
}
