import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jhatpat/constants/app_constants.dart';
import 'package:jhatpat/shared/buttons.dart';
import 'package:jhatpat/shared/snackbar.dart';
import 'package:jhatpat/models/booking_detail_model.dart';
import 'package:jhatpat/services/providers/user_location_provider.dart';
import 'package:jhatpat/permission.dart';
import 'package:jhatpat/services/api/api_service.dart';
import 'package:jhatpat/services/shared_pref/shared_pref.dart';
import 'package:jhatpat/shared/booking_status_states.dart';
import 'package:jhatpat/shared/bottom_sheet_top_shadow.dart';
import 'package:jhatpat/views/home/home_drawer.dart';
import 'package:jhatpat/views/payment/ride_payment.dart';
import 'package:url_launcher/url_launcher.dart';

class RidePage extends ConsumerStatefulWidget {
  final BookingDetails bookingDetails;

  const RidePage({
    Key? key,
    required this.bookingDetails,
  }) : super(key: key);

  @override
  ConsumerState<RidePage> createState() => _RidePageState();
}

class _RidePageState extends ConsumerState<RidePage> {
  GoogleMapController? _controller;

  List<LatLng> polylineCoordinates = [];
  List<LatLng> pickDropCoordinates = [];

  // 0 - Cash , 1 - Online
  int paymentType = 0;
  bool isPaymentTypeLoading = false;
  CameraPosition? initialCameraPosition;
  BookingDetails? bookingDetails;
  BitmapDescriptor carIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor fromIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor dropIcon = BitmapDescriptor.defaultMarker;

  Timer? _timer;

  int status = -1;

  @override
  void initState() {
    super.initState();
    setState(() {
      bookingDetails = widget.bookingDetails;
    });
    setCustomMarkerIcon();
    updateBookingStatus();
    getPickDropCoordinates();
    setState(() {});
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      debugPrint("⏱️ TIMER ${DateTime.now().second}");
      updateBookingStatus();
    });
  }

  void getPickDropCoordinates() async {
    if (bookingDetails == null) {
      debugPrint("❌ Get Pick Drop Coordinates Error | Booking Details = null");
      return;
    } else {
      if (bookingDetails!.pickupLat != null &&
          bookingDetails!.pickupLng != null &&
          bookingDetails!.dropLat != null &&
          bookingDetails!.dropLng != null) {
        final pickDrop = await getPolylinePoints(
            sourceLocation: PointLatLng(
                getPosition(position: bookingDetails!.pickupLat!),
                getPosition(position: bookingDetails!.pickupLng!)),
            destinationLocation: PointLatLng(
                getPosition(position: bookingDetails!.dropLat!),
                getPosition(position: bookingDetails!.dropLng!)));
        setState(() {
          pickDropCoordinates = pickDrop;
        });
        debugPrint("✅ PICK - DROP POLYLINES CREATED");
      }
    }
  }

  void updateBookingStatus() async {
    final BookingDetails details =
        await DatabaseService(token: UserSharedPreferences.getUserToken())
            .postBookingStatus();

    int currentStatus =
        bookingStatusStates.indexOf(details.status?.toLowerCase() ?? "");

    List<LatLng> points = pickDropCoordinates;

    // ***********************************************************************
    // *  Add Code inside current status block, thats gonna run periodically *
    // ***********************************************************************

    // & INIT
    if (currentStatus == 0) {
    }
    // & REJECTED
    else if (currentStatus == 1) {
      Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(
            builder: (context) => const PermissionsPage(),
          ),
          (route) => false);
    }
    // & ACCEPTED
    else if (currentStatus == 2) {
      debugPrint("🛣️ Car - Pick | Polylines Synced");

      if (details.lat != null &&
          details.lng != null &&
          details.pickupLat != null &&
          details.pickupLng != null) {
        PointLatLng carLocation = PointLatLng(
            getPosition(position: details.lat ?? "0.0"),
            getPosition(position: details.lng ?? "0.0"));
        PointLatLng pickLocation = PointLatLng(
            getPosition(position: details.pickupLat ?? "0.0"),
            getPosition(position: details.pickupLng ?? "0.0"));

        // * Get Cuurent Polyline from Car - Pick Location
        points = await getPolylinePoints(
            sourceLocation: carLocation, destinationLocation: pickLocation);
      }
    }
    // & START
    else if (currentStatus == 3) {
      debugPrint("🛣️ Car - Drop | Polylines Synced");

      if (details.lat != null &&
          details.lng != null &&
          details.dropLat != null &&
          details.dropLng != null) {
        PointLatLng carLocation = PointLatLng(
            getPosition(position: details.lat!),
            getPosition(position: details.lng!));
        PointLatLng dropLocation = PointLatLng(
            getPosition(position: details.dropLat!),
            getPosition(position: details.dropLng!));

        // * Get Curent Polyline from Car - Drop Location
        points = await getPolylinePoints(
            sourceLocation: carLocation, destinationLocation: dropLocation);
      }
    }
    // & COMPLETED
    else if (currentStatus == 4) {
    }
    // & PAID
    else if (currentStatus == 5) {
      showCupertinoDialog(
        context: context,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: CupertinoAlertDialog(
            title: const Text("Payment Successfull"),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                child: const Text("Continue"),
                onPressed: () async {
                  Navigator.of(context).pop;
                  Navigator.of(context).pushAndRemoveUntil(
                      CupertinoPageRoute(
                        builder: (context) => const PermissionsPage(),
                      ),
                      (route) => false);
                },
              ),
            ],
          ),
        ),
      );
    }
    // & CANCELLED
    else if (currentStatus == 6) {
      showCupertinoDialog(
        context: context,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: CupertinoAlertDialog(
            title: const Text("Ride Cancelled"),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                child: const Text("Okay"),
                onPressed: () async {
                  Navigator.of(context).pop;
                  Navigator.of(context).pushAndRemoveUntil(
                      CupertinoPageRoute(
                          builder: (context) => const PermissionsPage()),
                      (route) => false);
                },
              ),
            ],
          ),
        ),
      );
    }

    setState(() {
      bookingDetails = details;

      if (currentStatus == 2 || currentStatus == 3) {
        polylineCoordinates = points;
      } else {
        polylineCoordinates = pickDropCoordinates;
      }

      if (details.payType == "cash") {
        paymentType = 0;
      } else {
        paymentType = 1;
      }

      if (details.status != null) {
        status = currentStatus;
      }
    });
  }

  double getPosition({required String position}) => double.parse(position);

  Future<List<LatLng>> getPolylinePoints({
    required PointLatLng sourceLocation,
    required PointLatLng destinationLocation,
  }) async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      API_KEY,
      sourceLocation,
      destinationLocation,
    );

    List<LatLng> points = [];

    if (result.points.isNotEmpty) {
      for (var pointLatLng in result.points) {
        points.add(
          LatLng(pointLatLng.latitude, pointLatLng.longitude),
        );
      }
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("⭐ ${bookingDetails?.status?.toUpperCase() ?? ""} | Ride Page");
    return WillPopScope(
      onWillPop: () async {
        showCupertinoDialog<bool>(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text("Do you want to exit the app?"),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                child: const Text("Yes"),
                onPressed: () => exit(0),
              ),
              CupertinoDialogAction(
                child: const Text("No"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
        return true;
      },
      child: SafeArea(
        // child: !_mapLoading
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  zoom: 16,
                  target: LatLng(
                    ref.read(userLocationProvider)?.latitude ?? 0.0,
                    ref.read(userLocationProvider)?.longitude ?? 0.0,
                  ),
                ),
                onMapCreated: (controller) => _controller = controller,
                mapToolbarEnabled: false,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
                compassEnabled: false,
                markers: {
                  // & Car Marker
                  Marker(
                    visible: status == 0 || status == 2 || status == 3,
                    icon: carIcon,
                    markerId: const MarkerId("vehicle"),
                    infoWindow: InfoWindow(
                      title: "Your Cab",
                      snippet: bookingDetails?.carNumber == null
                          ? ""
                          : bookingDetails!.carNumber,
                    ),
                    position: LatLng(
                      double.parse(bookingDetails?.lat ?? "0.0"),
                      double.parse(bookingDetails?.lng ?? "0.0"),
                    ),
                  ),

                  // & Pickup Marker
                  Marker(
                    visible: status != 3,
                    markerId: const MarkerId("pickup"),
                    icon: fromIcon,
                    infoWindow: const InfoWindow(
                      title: "Pickup Point",
                    ),
                    position: LatLng(
                        double.parse(bookingDetails?.pickupLat ?? "0.0"),
                        double.parse(bookingDetails?.pickupLng ?? "0.0")),
                  ),

                  // & Drop Marker
                  Marker(
                    visible: status != 2,
                    icon: dropIcon,
                    markerId: const MarkerId("drop"),
                    infoWindow: const InfoWindow(
                      title: "Drop Point",
                    ),
                    position: LatLng(
                      double.parse(bookingDetails?.dropLat ?? "0.0"),
                      double.parse(bookingDetails?.dropLng ?? "0.0"),
                    ),
                  ),
                },
                polylines: polylineCoordinates.isNotEmpty
                    ? <Polyline>{
                        Polyline(
                          endCap: Cap.roundCap,
                          polylineId: const PolylineId("polyline"),
                          points: polylineCoordinates,
                          color: const Color.fromARGB(255, 86, 86, 86),
                          width: 5,
                        ),
                      }
                    : <Polyline>{},
              ),
              // * TOP Booking Details {FROM - Distance - Estimated Time - TO}
              getBookingDetailsFragment(),
            ],
          ),
          // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
          bottomSheet: status == 0
              // & Init
              ? const InitRideFragment()
              : status == 1
                  // & Rejected
                  ? const RejectedRideFragment()
                  : status == 2
                      // & Accepted
                      ? acceptedFragment()
                      : status == 3
                          // & Start
                          ? startFragment()
                          : status == 4
                              // & Completed
                              ? completedFragment()
                              : status == 5
                                  // & Paid
                                  ? paidFragment()
                                  : status == 6
                                      // & Cancelled
                                      ? cancelledFragment()

                                      // * Loading
                                      : loadingFragment(),

          drawer: const HomeDrawer(),
          floatingActionButton: status == 3
              ? FloatingActionButton(
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.sos_rounded),
                  onPressed: () async {
                    try {
                      final supportNo = await DatabaseService().getSosNum();
                      await launchUrl(Uri(scheme: "tel", path: supportNo));
                    } catch (e) {
                      showSnackBar(
                          context: context,
                          content: "Couldn't get Emergency No");
                    }
                  },
                )
              : null,
        ),
      ),
    );
  }

  BottomSheet completedFragment() {
    return BottomSheet(
      onClosing: () {},
      enableDrag: false,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))),
      builder: (context) => Container(
        decoration: bottomSheetTopShadow,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // *  Driver Image    Car Image
            // *  Driver Name      Car No
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    // Driver Image
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.black,
                        maxRadius: 22,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: bookingDetails!.driverImage == null
                              ? Image.asset(
                                  AppConstants.defaultUserAvatarAssetPath,
                                  fit: BoxFit.contain,
                                )
                              : CachedNetworkImage(
                                  imageUrl:
                                      "${AppConstants.driverStorageApiUrl}${bookingDetails!.driverImage!}",
                                  placeholder: (context, url) =>
                                      const CupertinoActivityIndicator(),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                    AppConstants.defaultUserAvatarAssetPath,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        bookingDetails?.driverName ?? "Driver Name",
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Car Image & Car no
                Expanded(
                  flex: 1,
                  child: Column(
                    // Driver Image
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        maxRadius: 22,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: bookingDetails!.carImage == null
                              ? Image.asset(
                                  AppConstants.defaultCarAssetPath,
                                  fit: BoxFit.contain,
                                )
                              : CachedNetworkImage(
                                  imageUrl:
                                      "${AppConstants.userStorageApiUrl}{bookingDetails!.carImage!}",
                                  placeholder: (context, url) =>
                                      const CupertinoActivityIndicator(),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                    AppConstants.defaultCarAssetPath,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        bookingDetails == null ||
                                bookingDetails!.carNumber == null
                            ? "Vehicle Number"
                            : bookingDetails!.carNumber!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),
            const Divider(thickness: 2),
            const SizedBox(height: 4),

            // * PICK UP Address
            Row(
              children: <Widget>[
                const Icon(
                  Icons.circle,
                  color: Colors.black,
                  size: 14,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  // Pick Up Address
                  child: Text(
                    bookingDetails?.pickupAdd ?? "",
                    style: const TextStyle(
                        fontSize: 14.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // ! Drop Address
            Row(
              children: <Widget>[
                const Icon(
                  Icons.circle,
                  color: Colors.red,
                  size: 14,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  // Pick Up Address
                  child: Text(
                    bookingDetails?.dropAdd ?? "",
                    style: const TextStyle(
                        fontSize: 14.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total Distance : ${bookingDetails?.dist ?? "0.0"} Km",
                  style: const TextStyle(
                      fontSize: 14.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Final Time : ${bookingDetails?.finalTime ?? "0.0"}",
                  style: const TextStyle(
                      fontSize: 14.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 4),
            const Divider(thickness: 2),
            const SizedBox(height: 4),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      "Ride Fee: ",
                    ),
                    Text("+ ₹ ${bookingDetails?.payableAmount ?? "0"}"),
                  ],
                ),
                if (bookingDetails?.convenienceFee != null)
                  const SizedBox(height: 5.0),
                if (bookingDetails?.convenienceFee != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        "Convenience Fee: ",
                      ),
                      Text(
                        "+ ₹ ${bookingDetails?.convenienceFee ?? ""}",
                      ),
                    ],
                  ),
                if (bookingDetails?.extraAmount != null)
                  const SizedBox(height: 5.0),
                if (bookingDetails?.extraAmount != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        "Extra Fee: ",
                      ),
                      Text(
                        "+ ₹ ${bookingDetails?.extraAmount ?? "0"}",
                      ),
                    ],
                  ),
                if (bookingDetails?.disc != null) const SizedBox(height: 5.0),
                if (bookingDetails?.disc != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        "Discount: ",
                      ),
                      Text(
                        "- ₹ ${bookingDetails?.disc ?? ""}",
                      ),
                    ],
                  ),
                const SizedBox(height: 6.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      "Payable Amount : ",
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "----",
                      style: TextStyle(color: Colors.green),
                    ),
                    Text(
                      "₹ ${bookingDetails?.payableAmount ?? "0"}",
                      style: const TextStyle(
                          color: Colors.green,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 4),
            const Divider(thickness: 2),
            const SizedBox(height: 4),

            // * Payment Menu
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<int>(
                    value: paymentType,
                    hint: const Text("Payment Type"),
                    items: const [
                      DropdownMenuItem(
                        value: 0,
                        child: Text("Cash"),
                      ),
                      DropdownMenuItem(
                        value: 1,
                        child: Text("Online"),
                      ),
                    ],
                    onChanged: (value) async {
                      if (value != null) {
                        if (paymentType != value) {
                          setState(() {
                            isPaymentTypeLoading = true;
                          });
                          try {
                            final isPaymentTypeUpdated = await DatabaseService(
                                    token: UserSharedPreferences.getUserToken())
                                .postUpdatePaymentType(
                                    bookingId: bookingDetails!.bookingId!,
                                    paymentType:
                                        value == 0 ? "cash" : "online");
                            if (isPaymentTypeUpdated) {
                              setState(() {
                                paymentType = value;
                                isPaymentTypeLoading = false;
                              });
                            }
                          } catch (e) {
                            showSnackBar(
                                context: context,
                                content: "Unable to Update Payment Type");
                            setState(() {
                              isPaymentTypeLoading = false;
                            });
                          }
                        }
                      }
                    },
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      onPressed: () {
                        if (isPaymentTypeLoading) {
                          return;
                        }
                        // * Online
                        if (paymentType == 1) {
                          if (bookingDetails != null) {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                  builder: (context) => RidePaymentPage(
                                      bookingDetails: bookingDetails!)),
                            );
                            // (route) => false);
                          } else {
                            showSnackBar(
                                context: context,
                                content:
                                    "Couldn'd Initiate Online Payment Mode");
                          }
                        } else {
                          showCupertinoDialog(
                            barrierDismissible: true,
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: const Text("Ride Completed"),
                              content: Text(
                                "Payable Amount: ₹ ${bookingDetails?.payableAmount ?? "0"}",
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              actions: <CupertinoDialogAction>[
                                CupertinoDialogAction(
                                  child: const Text("Okay"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: isPaymentTypeLoading
                          ? const CupertinoActivityIndicator(
                              color: Colors.white,
                            )
                          : Text(
                              paymentType == 0 ? "PAY IN CASH" : "PAY ONLINE"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BottomSheet paidFragment() {
    return BottomSheet(
      onClosing: () {},
      enableDrag: false,
      builder: (context) => Container(
        height: 0,
      ),
    );
  }

  BottomSheet startFragment() {
    return BottomSheet(
      onClosing: () {},
      enableDrag: false,
      builder: (context) => Container(
        height: 0,
      ),
    );
  }

  BottomSheet cancelledFragment() {
    return BottomSheet(
      onClosing: () {},
      enableDrag: false,
      builder: (context) => Container(
        height: 0,
      ),
    );
  }

  BottomSheet loadingFragment() {
    return BottomSheet(
      onClosing: () {},
      enableDrag: false,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))),
      builder: (context) => Container(
        decoration: bottomSheetTopShadow,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 42),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            CupertinoActivityIndicator(
              radius: 14,
            )
          ],
        ),
      ),
    );
  }

  BottomSheet acceptedFragment() {
    return BottomSheet(
      onClosing: () {},
      enableDrag: false,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))),
      builder: (context) => Container(
        decoration: bottomSheetTopShadow,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: Colors.black,
                  maxRadius: 32,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: bookingDetails!.driverImage == null
                        ? Image.asset(
                            AppConstants.defaultUserAvatarAssetPath,
                            fit: BoxFit.contain,
                          )
                        : CachedNetworkImage(
                            imageUrl:
                                "${AppConstants.driverStorageApiUrl}${bookingDetails!.driverImage!}",
                            placeholder: (context, url) =>
                                const CupertinoActivityIndicator(),
                            errorWidget: (context, url, error) => Image.asset(
                              AppConstants.defaultUserAvatarAssetPath,
                              fit: BoxFit.contain,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Center(
                    child: Text(
                      bookingDetails?.driverName ?? "Driver Name",
                      style: const TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                IconButton(
                  onPressed: () async {
                    try {
                      if (bookingDetails!.driverPhone == null) {
                        showSnackBar(
                            context: context,
                            content: "Unable to get Driver Phone Number");
                        return;
                      }
                      await launchUrl(Uri(
                          scheme: "tel",
                          path: bookingDetails?.driverPhone ?? ""));
                    } catch (e) {
                      Clipboard.setData(
                          ClipboardData(text: bookingDetails?.driverPhone!));
                      showSnackBar(
                          context: context,
                          content:
                              "Couldn't call driver, number copied to clipboar");
                    }
                  },
                  icon: const Icon(Icons.call),
                  color: Colors.green,
                  iconSize: 32.0,
                )
              ],
            ),
            Row(
              children: <Widget>[
                Container(
                  height: 100.0,
                  width: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: bookingDetails!.carImage == null
                      ? Image.asset(
                          AppConstants.defaultCarAssetPath,
                          fit: BoxFit.contain,
                        )
                      : CachedNetworkImage(
                          imageUrl:
                              "${AppConstants.userStorageApiUrl}${bookingDetails!.carImage!}",
                          placeholder: (context, url) =>
                              const CupertinoActivityIndicator(),
                          errorWidget: (context, url, error) => Image.asset(
                                AppConstants.defaultCarAssetPath,
                                fit: BoxFit.contain,
                              )),
                ),
                const SizedBox(width: 20.0),
                Row(
                  children: [
                    const Text(
                      "Vehicle No: ",
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Text(
                      bookingDetails!.carNumber == null
                          ? ""
                          : bookingDetails!.carNumber!.toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                for (int i = 0; i < bookingDetails!.otp!.length; i++)
                  Container(
                    height: 60.0,
                    width: 60.0,
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: const Color.fromARGB(31, 133, 133, 133),
                    ),
                    child: Center(
                      child: Text(
                        bookingDetails!.otp![i],
                        style: const TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Positioned getBookingDetailsFragment() {
    return Positioned(
      child: Align(
        alignment: status == 4 ? Alignment.topLeft : Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 6.0,
            shadowColor: Colors.black38,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Builder(
                  builder: ((context) => IconButton(
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        icon: const Icon(Icons.menu_rounded,
                            color: Colors.black87),
                      )),
                ),
                status == 4
                    ? const SizedBox(
                        height: 0,
                        width: 0,
                      )
                    : Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: const Color.fromARGB(31, 133, 133, 133),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    const Icon(
                                      Icons.circle,
                                      color: Colors.black,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      // Pick Up Address
                                      child: Text(
                                          bookingDetails?.pickupAdd ?? "",
                                          style: const TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5.0),
                                Row(
                                  children: <Widget>[
                                    const Icon(
                                      Icons.move_down,
                                      color: Colors.black26,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10.0),
                                    Expanded(
                                      // Ride Detail Distance + Estimated Time
                                      child: Text(
                                        "${bookingDetails?.dist ?? "0"} Km, ${(bookingDetails?.estTime)?.substring(0, 2)}:${(bookingDetails?.estTime)!.substring(3, 5)}:${(bookingDetails?.estTime!)!.substring(6, 8)}",
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5.0),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.circle,
                                      color: Colors.red.shade700,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 10.0),
                                    Expanded(
                                      // Drop Address
                                      child: Text(bookingDetails?.dropAdd ?? "",
                                          style: const TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis),
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
        ),
      ),
    );
  }

  Future<BookingDetails> getBookingStatus() async {
    try {
      final BookingDetails bookingDetails =
          await DatabaseService(token: UserSharedPreferences.getUserToken())
              .postBookingStatus();
      return bookingDetails;
    } catch (e) {
      rethrow;
    }
  }

  // ^ Load Custom Markers
  void setCustomMarkerIcon() {
    // * Car
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, AppConstants.mapCarAssetPath)
        .then((car) {
      carIcon = car;
    });

    // * Pickup Pin
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, AppConstants.mapPickupPin)
        .then((pin) {
      fromIcon = pin;
    });

    // * Drop Pin
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, AppConstants.mapDropPin)
        .then((marker) {
      dropIcon = marker;
    });
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }
}

class RejectedRideFragment extends StatelessWidget {
  const RejectedRideFragment({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: () {},
      enableDrag: false,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))),
      builder: (context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 42),
        decoration: bottomSheetTopShadow,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Finding New Driver ...",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            blackMaterialButtons(() {}, const Text("Exit"))
          ],
        ),
      ),
    );
  }
}

class InitRideFragment extends StatelessWidget {
  const InitRideFragment({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: () {},
      enableDrag: false,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))),
      builder: (context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 42),
        decoration: bottomSheetTopShadow,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Waiting for Driver Approval",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(150, 38)),
              onPressed: () async {
                showCupertinoDialog(
                  context: context,
                  builder: (context) => WillPopScope(
                    onWillPop: () async => true,
                    child: CupertinoAlertDialog(
                      title: const Text("Cancel Ride?"),
                      actions: <CupertinoDialogAction>[
                        CupertinoDialogAction(
                          child: const Text("No"),
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                        ),
                        CupertinoDialogAction(
                          child: const Text("Yes"),
                          onPressed: () async {
                            Navigator.pop(context);
                            Navigator.of(context).pop;
                            Navigator.of(context).pushAndRemoveUntil(
                                CupertinoPageRoute(
                                    builder: (context) =>
                                        const PermissionsPage()),
                                (route) => false);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: const Text("Cancel"),
            ),
          ],
        ),
      ),
    );
  }
}
