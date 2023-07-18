class SubscriptionList {
  final String? id;
  final String? name;
  final String? fees;
  final String? validity;
  final String? bookFees;
  final String? freeBookings;
  final String? freeBookingsValidity;

  SubscriptionList({
    this.id,
    this.name,
    this.fees,
    this.validity,
    this.bookFees,
    this.freeBookings,
    this.freeBookingsValidity,
  });

  @override
  String toString() {
    return 'SubscriptionList(id: $id, name: $name, fees: $fees, validity: $validity, bookFees: $bookFees, freeBookings: $freeBookings, freeBookingsValidity: $freeBookingsValidity)';
  }
}
