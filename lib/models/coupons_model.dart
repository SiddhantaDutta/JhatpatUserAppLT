class CouponsModel {
  final String? id;
  final String? code;
  final String? details;
  final String? payType;
  final String? minAmount;
  final String? discType;
  final String? discValue;

  CouponsModel({
    this.id,
    this.code,
    this.details,
    this.payType,
    this.minAmount,
    this.discType,
    this.discValue,
  });

  @override
  String toString() {
    return 'CouponsModel(id: $id, code: $code, details: $details, payType: $payType, minAmount: $minAmount, discType: $discType, discValue: $discValue)';
  }
}
