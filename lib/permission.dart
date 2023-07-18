import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jhatpat/models/booking_detail_model.dart';
import 'package:jhatpat/services/providers/user_location_provider.dart';
import 'package:jhatpat/shared/booking_status_states.dart';
import 'package:jhatpat/shared/buttons.dart';
import 'package:jhatpat/shared/loading.dart';
import 'package:jhatpat/views/home/home.dart';
import 'package:jhatpat/views/home/location_services.dart';
import 'package:jhatpat/views/home/ride.dart';

class PermissionsPage extends ConsumerStatefulWidget {
  final BookingDetails? bookingDetails;

  const PermissionsPage({this.bookingDetails, Key? key}) : super(key: key);

  @override
  ConsumerState<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends ConsumerState<PermissionsPage> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    getLoc().whenComplete(() => setState(() => _loading = false));
  }

  Future<void> getLoc() async {
    determinePosition().then((location) async {
      debugPrint("Location | ${location?.latitude} ${location?.longitude}");
      if (location == null) {
        return null;
      } else {
        ref
            .read(userLocationProvider.notifier)
            .update((state) => LatLng(location.latitude, location.longitude));
        if (widget.bookingDetails != null) {
          final status = widget.bookingDetails?.status ?? "";

          // * User Not in Ride
          if (bookingStatusStates.indexOf(status.toLowerCase()) == 0 ||
              bookingStatusStates.indexOf(status.toLowerCase()) == 2 ||
              bookingStatusStates.indexOf(status.toLowerCase()) == 3 ||
              bookingStatusStates.indexOf(status.toLowerCase()) == 4) {
            debugPrint("✅ USER IN RIDE");
            Navigator.of(context).pushAndRemoveUntil(
                CupertinoPageRoute(
                    builder: (context) => RidePage(
                          bookingDetails: widget.bookingDetails!,
                        )),
                (route) => false);
          } else {
            // !  Current User NOT in Ride
            debugPrint("❌ USER NOT IN RIDE");

            Navigator.of(context).pushAndRemoveUntil(
                CupertinoPageRoute(builder: (context) => const HomePage()),
                (route) => false);
          }
        } else {
          debugPrint("PERMISSION SCREEN > BOOKING DETAILS IS NULL");
          Navigator.of(context).pushAndRemoveUntil(
              CupertinoPageRoute(builder: (context) => const HomePage()),
              (route) => false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("🪟 Permission Screen");
    return Scaffold(
      body: Center(
        child: !_loading
            ? Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(Icons.location_on,
                        size: 48.0, color: Colors.black54),
                    const SizedBox(height: 15.0),
                    const Text(
                      "Location Permission Required",
                      style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20.0),
                    blackMaterialButtons(
                      () {
                        setState(() => _loading = true);
                        getLoc().whenComplete(
                            () => setState(() => _loading = false));
                      },
                      const Text("Retry", style: TextStyle(fontSize: 16.0)),
                    ),
                  ],
                ),
              )
            : const Loading(white: false, rad: 14.0),
      ),
    );
  }
}
