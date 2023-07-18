// ignore_for_file: non_constant_identifier_names

class PaymentStatus {
  final String? RESPMSG;
  final String? CURRENCY;
  final String? TXNID;
  final String? ORDERID;
  final String? CHECKSUMHASH;
  final String? TXNDATE;
  final String? TXNAMOUNT;
  final String? PAYMENTMODE;
  final String? BANKNAME;
  final String? RESPCODE;
  final String? STATUS;
  final String? BANKTXNID;
  final String? GATEWAYNAME;
  final String? MID;

  PaymentStatus({
    this.RESPMSG,
    this.CURRENCY,
    this.TXNID,
    this.ORDERID,
    this.CHECKSUMHASH,
    this.TXNDATE,
    this.TXNAMOUNT,
    this.PAYMENTMODE,
    this.BANKNAME,
    this.RESPCODE,
    this.STATUS,
    this.BANKTXNID,
    this.GATEWAYNAME,
    this.MID,
  });

  @override
  String toString() {
    return 'PaymentStatus(RESPMSG: $RESPMSG, CURRENCY: $CURRENCY, TXNID: $TXNID, ORDERID: $ORDERID, CHECKSUMHASH: $CHECKSUMHASH, TXNDATE: $TXNDATE, TXNAMOUNT: $TXNAMOUNT, PAYMENTMODE: $PAYMENTMODE, BANKNAME: $BANKNAME, RESPCODE: $RESPCODE, STATUS: $STATUS, BANKTXNID: $BANKTXNID, GATEWAYNAME: $GATEWAYNAME, MID: $MID)';
  }
}
