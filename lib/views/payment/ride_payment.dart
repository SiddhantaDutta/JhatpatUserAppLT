import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jhatpat/models/booking_detail_model.dart';
import 'package:jhatpat/models/coupons_model.dart';
import 'package:jhatpat/models/payment_model.dart';
import 'package:jhatpat/models/payment_status_model.dart';
import 'package:jhatpat/permission.dart';
import 'package:jhatpat/services/api/api_service.dart';
import 'package:jhatpat/services/shared_pref/shared_pref.dart';
import 'package:jhatpat/shared/buttons.dart';
import 'package:jhatpat/shared/loading.dart';
import 'package:jhatpat/shared/snackbar.dart';
import 'package:jhatpat/views/payment/paytm.dart';

class RidePaymentPage extends StatefulWidget {
  const RidePaymentPage({Key? key, required this.bookingDetails})
      : super(key: key);
  final BookingDetails bookingDetails;

  @override
  State<RidePaymentPage> createState() => _RidePaymentPageState();
}

class _RidePaymentPageState extends State<RidePaymentPage> {
  bool _error = false;
  bool _loading = true;
  bool _paying = false;
  bool _couponSelecting = false;
  late BookingDetails _bookingDetails;
  List<CouponsModel> _couponList = <CouponsModel>[];
  int? _couponIndex;

  @override
  void initState() {
    super.initState();
    _bookingDetails = widget.bookingDetails;
    loadCoupons().whenComplete(() => setState(() => _loading = false));
  }

  Future<void> loadCoupons() async {
    try {
      _couponList = await DatabaseService().postAllCouponsList(
              _bookingDetails.payableAmount, _bookingDetails.payType) ??
          <CouponsModel>[];
    } catch (e) {
      setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("🪟 Ride Payment");
    debugPrint(_bookingDetails.toString());
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ride Payment"),
      ),
      body: !_error
          ? CustomScrollView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: !_loading
                      ? Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: <Widget>[
                              Card(
                                elevation: 6.0,
                                shadowColor: Colors.black38,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0)),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12.0, horizontal: 8.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            color: const Color.fromARGB(
                                                31, 133, 133, 133),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  const Icon(Icons.circle,
                                                      color: Colors.black),
                                                  const SizedBox(width: 10.0),
                                                  Expanded(
                                                    child: Text(
                                                        _bookingDetails
                                                            .pickupAdd!,
                                                        style: const TextStyle(
                                                            fontSize: 15.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 5.0),
                                              Row(
                                                children: <Widget>[
                                                  const Icon(Icons.move_down,
                                                      color: Colors.black26),
                                                  const SizedBox(width: 10.0),
                                                  Text(
                                                    "${_bookingDetails.dist!}, ${(_bookingDetails.finalTime!).substring(0, 2)}:${(_bookingDetails.finalTime!).substring(3, 5)}:${(_bookingDetails.finalTime!).substring(6, 8)}",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 5.0),
                                              Row(
                                                children: <Widget>[
                                                  Icon(Icons.circle,
                                                      color:
                                                          Colors.red.shade700),
                                                  const SizedBox(width: 10.0),
                                                  Expanded(
                                                    child: Text(
                                                        _bookingDetails
                                                            .dropAdd!,
                                                        style: const TextStyle(
                                                            fontSize: 15.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              if (_couponList.isNotEmpty)
                                const Text(
                                  "Coupons applicable:",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              const SizedBox(height: 10.0),
                              if (_couponList.isNotEmpty)
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    for (int i = 0; i < _couponList.length; i++)
                                      !_couponSelecting
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Card(
                                                color: _couponIndex != null
                                                    ? _couponIndex == i
                                                        ? Colors.green.shade700
                                                        : Colors.white
                                                    : Colors.green.shade700,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0)),
                                                child: ListTile(
                                                  onTap: () async {
                                                    setState(() =>
                                                        _couponSelecting =
                                                            true);
                                                    try {
                                                      _bookingDetails =
                                                          await DatabaseService()
                                                              .postApplyCoupon(
                                                                  _bookingDetails
                                                                      .bookingId!,
                                                                  _couponList[i]
                                                                      .id!);
                                                      setState(() =>
                                                          _couponIndex = i);
                                                    } catch (e) {
                                                      showSnackBar(
                                                          context: context,
                                                          content:
                                                              "Couldn't apply coupon");
                                                      _couponIndex = null;
                                                    }
                                                    setState(() =>
                                                        _couponSelecting =
                                                            false);
                                                  },
                                                  title: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Expanded(
                                                          child: Text(
                                                            _couponList[i]
                                                                .code!,
                                                            style: TextStyle(
                                                                fontSize: 18.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: _couponIndex !=
                                                                        null
                                                                    ? _couponIndex ==
                                                                            i
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .black
                                                                    : Colors
                                                                        .white),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        Text(
                                                          "${_couponList[i].discValue}% OFF!",
                                                          style: TextStyle(
                                                              fontSize: 16.0,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: _couponIndex !=
                                                                      null
                                                                  ? _couponIndex ==
                                                                          i
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .blue
                                                                  : Colors
                                                                      .white),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  subtitle: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 16.0,
                                                            right: 16.0,
                                                            bottom: 16.0),
                                                    child: Text(
                                                      _couponList[i].details!,
                                                      style: TextStyle(
                                                          color: _couponIndex !=
                                                                  null
                                                              ? _couponIndex ==
                                                                      i
                                                                  ? Colors
                                                                      .white70
                                                                  : Colors
                                                                      .black54
                                                              : Colors.white70),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0)),
                                                child: const ListTile(
                                                    title:
                                                        Loading(white: false)),
                                              ),
                                            ),
                                    const SizedBox(height: 5.0),
                                  ],
                                ),
                            ],
                          ),
                        )
                      : const Center(child: Loading(white: false, rad: 14.0)),
                )
              ],
            )
          : Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  Icon(Icons.error, color: Colors.red, size: 32.0),
                  SizedBox(width: 5.0),
                  Text(
                    "Something went wrong, couldn't load payment details",
                    style: TextStyle(color: Colors.red, fontSize: 16.0),
                  )
                ],
              ),
            ),
      bottomNavigationBar: !_error && !_loading
          ? Container(
              constraints:
                  BoxConstraints.tight(const Size(double.infinity, 250)),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    topRight: Radius.circular(15.0)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0.0, -2.0),
                    blurRadius: 4.0,
                    spreadRadius: 2.0,
                  )
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: !_couponSelecting
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            const Text(
                              "Ride Fee: ",
                            ),
                            Text("+ ₹ ${_bookingDetails.payableAmount ?? "0"}"),
                          ],
                        ),
                        if (_bookingDetails.convenienceFee != null)
                          const SizedBox(height: 5.0),
                        if (_bookingDetails.convenienceFee != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              const Text(
                                "Convenience Fee: ",
                              ),
                              Text(
                                "+ ₹ ${_bookingDetails.convenienceFee ?? ""}",
                              ),
                            ],
                          ),
                        if (_bookingDetails.extraAmount != null)
                          const SizedBox(height: 5.0),
                        if (_bookingDetails.extraAmount != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              const Text(
                                "Extra Fee: ",
                              ),
                              Text(
                                "+ ₹ ${_bookingDetails.extraAmount ?? "0"}",
                              ),
                            ],
                          ),
                        if (_bookingDetails.disc != null)
                          const SizedBox(height: 5.0),
                        if (_bookingDetails.disc != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              const Text(
                                "Discount: ",
                              ),
                              Text(
                                "- ₹ ${_bookingDetails.disc ?? ""}",
                              ),
                            ],
                          ),
                        const SizedBox(height: 5.0),
                        const Divider(thickness: 2),
                        const SizedBox(height: 5.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            const Text(
                              "Payable Amount: ",
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              "----",
                              style: TextStyle(color: Colors.green),
                            ),
                            Text(
                              "₹ ${_bookingDetails.payableAmount ?? "0"}",
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15.0),
                        blackMaterialButtons(
                          () async {
                            setState(() => _paying = true);
                            try {
                              final PaymentModel? paymentModel =
                                  await DatabaseService(
                                          token: UserSharedPreferences
                                              .getUserToken()!)
                                      .postPaymentInit(
                                          _bookingDetails.bookingId!);
                              if (paymentModel != null) {
                                final Map<dynamic, dynamic> map = await payTmPG(
                                    _bookingDetails.payableAmount!,
                                    paymentModel.orderId ?? "",
                                    paymentModel.txnToken ?? "");
                                showSnackBar(
                                    context: context,
                                    content: "Payment Successful",
                                    bgColor: Colors.green);
                                await DatabaseService(
                                        token: UserSharedPreferences
                                            .getUserToken()!)
                                    .postUpdatePaymentStatus(PaymentStatus(
                                  RESPMSG: map["RESPMSG"],
                                  CURRENCY: map["CURRENCY"],
                                  TXNID: map["TXNID"],
                                  ORDERID: map["ORDERID"],
                                  CHECKSUMHASH: map["CHECKSUMHASH"],
                                  TXNDATE: map["TXNDATE"],
                                  TXNAMOUNT: map["TXNAMOUNT"],
                                  PAYMENTMODE: map["PAYMENTMODE"],
                                  BANKNAME: map["BANKNAME"],
                                  RESPCODE: map["RESPCODE"],
                                  STATUS: map["STATUS"],
                                  BANKTXNID: map["BANKTXNID"],
                                  GATEWAYNAME: map["GATEWAYNAME"],
                                  MID: map["MID"],
                                ))
                                    .then((value) async {
                                  if (value) {
                                    debugPrint(
                                        "✅ Update Payment Status > Payment Status Updated!");
                                    showSnackBar(
                                        context: context,
                                        content: "Thank You! Keep Booking.",
                                        bgColor: Colors.blue);
                                    await Future.delayed(
                                        const Duration(seconds: 2));
                                    Navigator.of(context).pushAndRemoveUntil(
                                        CupertinoPageRoute(
                                            builder: (context) =>
                                                const PermissionsPage()),
                                        (route) => false);
                                  } else {
                                    showSnackBar(
                                      context: context,
                                      content: "Couldn't update payment status",
                                    );

                                    await Future.delayed(
                                        const Duration(seconds: 1));
                                    Navigator.of(context).pushAndRemoveUntil(
                                        CupertinoPageRoute(
                                            builder: (context) =>
                                                const PermissionsPage()),
                                        (route) => false);
                                  }
                                });
                              }
                            } catch (e) {
                              showSnackBar(context: context, content: "$e");
                            }
                            setState(() => _paying = false);
                          },
                          !_paying
                              ? const Text(
                                  "Pay",
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : const Loading(white: true),
                        ),
                      ],
                    )
                  : const Loading(white: false),
            )
          : const SizedBox(),
    );
  }
}
