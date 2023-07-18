class PaymentModel {
  final String? signature;
  final String? txnToken;
  final String? orderId;

  PaymentModel({
    this.signature,
    this.txnToken,
    this.orderId,
  });

  @override
  String toString() =>
      'PaymentModel(signature: $signature, txnToken: $txnToken, orderId: $orderId)';
}
