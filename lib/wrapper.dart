import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jhatpat/shared/snackbar.dart';
import 'package:jhatpat/models/booking_detail_model.dart';
import 'package:jhatpat/permission.dart';
import 'package:jhatpat/services/api/api_service.dart';
import 'package:jhatpat/services/shared_pref/shared_pref.dart';
import 'package:jhatpat/views/auth/auth_page.dart';

class WrapperPage extends StatefulWidget {
  const WrapperPage({Key? key}) : super(key: key);

  @override
  State<WrapperPage> createState() => _WrapperPageState();
}

class _WrapperPageState extends State<WrapperPage> {
  bool _error = false;
  final int _wrapperDuration = 2;

  @override
  void initState() {
    super.initState();
    splashMethod();
  }

  Future splashMethod() async {
    UserSharedPreferences.getLoggedInOrNot()
        ? checkIfUserInRide().then((bookingDetails) {
            Navigator.of(context).pushAndRemoveUntil(
                CupertinoPageRoute(
                    builder: (context) => PermissionsPage(
                          bookingDetails: bookingDetails,
                        )),
                (route) => false);
          })
        : Future.delayed(Duration(seconds: _wrapperDuration)).whenComplete(() =>
            Navigator.of(context).pushAndRemoveUntil(
                CupertinoPageRoute(
                    builder: (context) => const AuthenticationPage()),
                (route) => false));
  }

  Future<BookingDetails?> checkIfUserInRide() async {
    try {
      final bookingDetails =
          await DatabaseService(token: UserSharedPreferences.getUserToken()!)
              .postBookingStatus()
              .timeout(const Duration(seconds: 15), onTimeout: () {
        setState(() => _error = true);
        showSnackBar(context: context, content: "Could Not Load Data!");
        throw "Couldn't load data";
      });
      return bookingDetails;
    } catch (e) {
      debugPrint("WRAPPER > CHECK IF USER IN RIDE > $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("🪟 Wrapper Screen");
    return Scaffold(
      body: !_error
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: Image.asset(
                      "assets/images/LogoWTxt.png",
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    "assets/images/SplashBottom.png",
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.asset(
                  "assets/images/LogoWTxt.png",
                ),
                const SizedBox(height: 40.0),
                Row(
                  children: <Widget>[
                    Icon(Icons.error, size: 38.0, color: Colors.red.shade800),
                    const SizedBox(width: 10.0),
                    Text(
                      "Couldn't Connect to Servers",
                      style:
                          TextStyle(fontSize: 16.0, color: Colors.red.shade800),
                    )
                  ],
                ),
              ],
            ),
    );
  }
}
