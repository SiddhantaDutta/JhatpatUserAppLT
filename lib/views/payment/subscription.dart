import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jhatpat/models/payment_model.dart';
import 'package:jhatpat/models/payment_status_model.dart';
import 'package:jhatpat/models/subscription_list_model.dart';
import 'package:jhatpat/models/user_model.dart';
import 'package:jhatpat/services/api/api_service.dart';
import 'package:jhatpat/services/shared_pref/shared_pref.dart';
import 'package:jhatpat/shared/buttons.dart';
import 'package:jhatpat/shared/loading.dart';
import 'package:jhatpat/shared/snackbar.dart';
import 'package:jhatpat/views/payment/paytm.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  // bool _paying = false;
  UserProfileData? user;

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  void getUserDetails() async {
    final userDetails =
        await DatabaseService(token: UserSharedPreferences.getUserToken())
            .getProfileDetails();

    if (userDetails != null) {
      setState(() {
        user = userDetails;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("⚡Subscription Screen");
    debugPrint(user == null ? "User is Null" : user.toString());
    debugPrint("Status Id");
    debugPrint(user?.subStatusId ?? "-1");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Subscriptions"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: FutureBuilder<List<SubscriptionList>?>(
          future: DatabaseService().getSubscriptionsList(),
          initialData: const [],
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return snapshot.connectionState == ConnectionState.done
                ? !snapshot.hasError
                    ? snapshot.hasData
                        ? snapshot.data.isNotEmpty
                            ? ListView.builder(
                                physics: const BouncingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics()),
                                itemCount: snapshot.data.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final List<SubscriptionList> list =
                                      snapshot.data;

                                  return Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0)),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(8.0),
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            list[index].name!,
                                            style: const TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                "₹ ${list[index].fees!}",
                                                style: const TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black54),
                                              ),
                                              user != null &&
                                                      user!.subscriptionId ==
                                                          list[index].id
                                                  ? Image.asset(
                                                      "assets/images/active.png",
                                                      height: 20,
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                        ],
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          const SizedBox(height: 10.0),
                                          Flexible(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                const Icon(Icons.mood),
                                                const SizedBox(width: 5.0),
                                                Text(
                                                    "Fee less bookings: ${list[index].freeBookings}"
                                                    "\n(valid for: ${list[index].freeBookingsValidity})"),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 5.0),
                                          Flexible(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                const Icon(
                                                    Icons.monetization_on),
                                                const SizedBox(width: 5.0),
                                                Text(
                                                    "Booking fees: ${list[index].bookFees}"),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 5.0),
                                          Flexible(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                const Icon(
                                                    Icons.calendar_month),
                                                const SizedBox(width: 5.0),
                                                user != null &&
                                                        user!.subscriptionId ==
                                                            list[index].id
                                                    ? Text(
                                                        "Valid till: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(user?.subscriptionEndDate ?? ""))}")
                                                    : Text(
                                                        "Plan validity: ${list[index].validity}"),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 10.0),
                                          user != null &&
                                                  user!.subscriptionId ==
                                                      list[index].id
                                              ? disabledBlackMaterialButtons(
                                                  const Text(
                                                    "Buy Plan",
                                                    style: TextStyle(
                                                        fontSize: 16.0,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                )
                                              : blackMaterialButtons(
                                                  () => pay(
                                                    list[index].id!,
                                                    list[index].fees!,
                                                  ),
                                                  const Text(
                                                    "Buy Plan",
                                                    style: TextStyle(
                                                        fontSize: 16.0,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const <Widget>[
                                    Icon(Icons.error,
                                        color: Colors.red, size: 32.0),
                                    SizedBox(width: 20.0),
                                    Text(
                                      "Could not load subscription plans",
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 16.0),
                                    )
                                  ],
                                ),
                              )
                        : const Center(
                            child: Loading(white: false, rad: 14.0),
                          )
                    : Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            Icon(Icons.error, color: Colors.red, size: 32.0),
                            SizedBox(width: 20.0),
                            Text(
                              "Could not load subscription plans",
                              style:
                                  TextStyle(color: Colors.red, fontSize: 16.0),
                            )
                          ],
                        ),
                      )
                : const Center(
                    child: Loading(white: false, rad: 14.0),
                  );
          },
        ),
      ),
    );
  }

  Future<void> pay(String id, String fees) async {
    // setState(() => _paying = true);
    try {
      final PaymentModel? subscriptionModel =
          await DatabaseService(token: UserSharedPreferences.getUserToken()!)
              .postSubscriptionInit(id);
      if (subscriptionModel != null) {
        final Map<dynamic, dynamic> map = await payTmPG(fees,
            subscriptionModel.orderId ?? "", subscriptionModel.txnToken ?? "");
        showSnackBar(
            context: context,
            content: "Payment successful",
            bgColor: Colors.green);
        await DatabaseService(token: UserSharedPreferences.getUserToken()!)
            .postUpdateSubStatus(PaymentStatus(
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
            .then((value) => value
                ? showSnackBar(
                    context: context,
                    content: "Subscription status updated",
                    bgColor: Colors.green)
                : showSnackBar(
                    context: context,
                    content: "Couldn't update subscription status"));
      }
    } catch (e) {
      showSnackBar(context: context, content: "$e");
    }
    // setState(() => _paying = false);
  }
}
