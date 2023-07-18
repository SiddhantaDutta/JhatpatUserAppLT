import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jhatpat/models/booking_detail_model.dart';
import 'package:jhatpat/models/booking_prices_model.dart';
import 'package:jhatpat/models/coupons_model.dart';
import 'package:jhatpat/models/driver_list_model.dart';
import 'package:jhatpat/models/payment_model.dart';
import 'package:jhatpat/models/payment_status_model.dart';
import 'package:jhatpat/models/subscription_list_model.dart';
import 'package:jhatpat/models/user_login_registration_data_model.dart';
import 'package:jhatpat/models/user_model.dart';

// ignore: constant_identifier_names
const String API_KEY = "AIzaSyAVveVNAsAKcU6lX9p53j6YBzCKrfoo_gk";

class DatabaseService {
  DatabaseService({this.token});
  final String? token;

  final String _sthWentWrong = "Something went wrong, please try again";

  final String _baseUrl = "https://dev.jhatpat.app/api/user/";

  final String _postLogRegUrl = "login_register";
  final String _postOtpVerification = "verifyOtp";
  final String _getResendOtp = "resendOtp";
  final String _postUpdateUserDetails = "updateUserDetails";
  final String _postGetUserDetails = "getUserProfileDetails";
  final String _postDriversList = "driversList";
  final String _getSubscriptionList = "subscriptionList";
  final String _postSubInit = "subscription_initiate";
  final String _postUpdateSubStatus = "update_subscription_status";
  final String _postCityId = "cityId";
  final String _postBookingPrices = "booking_prices";
  final String _postBookingInit = "booking_initiate";
  final String _postFindDriver = "findDriver";
  final String _postAllCoupon = "allCoupon";
  final String _postApplyCoupon = "applyCoupon";
  final String _postBookingStatus = "bookingStatus";
  final String _postPaymentInit = "paymentInitiate";
  final String _postUpdatePaymentStatus = "updatePaymentStatus";
  final String _postUpdatePaymentType = "updatePaymentType";
  final String _postBookingHistory = "bookingHistory";
  final String _getSupportNum = "support";

  var dio = Dio();

  Future<UserLoginRegData?> postLoginRegister({String? phNum}) async {
    debugPrint("➡️ LOGIN REGISTER > $phNum");
    try {
      Response response = await dio.post(
        _baseUrl + _postLogRegUrl,
        data: {
          "phone_no": phNum!,
          "type": "1",
        },
      );
      debugPrint("⬅️ LOGIN REGISTER > $response");

      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        return UserLoginRegData(
          phone: decodedResponse["data"]["phone"],
          token: decodedResponse["data"]["token"],
        );
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      debugPrint("❗ LOGIN REGISTER > $e");
      throw e.toString();
    }
  }

  Future<bool> postVerifyOtp(String otp, String id) async {
    debugPrint("➡️ VERIFY OTP > Otp: $otp, Device Id: $id");
    try {
      Response response = await dio.post(
        _baseUrl + _postOtpVerification,
        options: Options(headers: {
          "user-token": token,
        }),
        data: {
          "otp": otp,
          "deviceId": id,
        },
      );
      debugPrint("⬅️ VERIFY OTP > $response");
      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        return true;
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      debugPrint("❗ VERIFY OTP > $e");
      throw e.toString();
    }
  }

  Future<bool> postResendOtp() async {
    debugPrint("➡️ RESEND OTP");
    try {
      Response response = await dio.post(
        _baseUrl + _getResendOtp,
        options: Options(headers: {
          "user-token": token,
        }),
      );
      debugPrint("⬅️ RESEND OTP > $response");

      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        return true;
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      debugPrint("❗ RESEND OTP > $e");
      throw e.toString();
    }
  }

  Future<UserProfileData?> getProfileDetails() async {
    debugPrint("➡️ PROFILE DETAILS");
    try {
      Response response = await dio.post(
        _baseUrl + _postGetUserDetails,
        options: Options(headers: {
          "user-token": token!,
        }),
      );
      debugPrint("⬅️ PROFILE DETAILS > $response");
      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        return UserProfileData(
          id: decodedResponse["data"]["User_Profile_Details"]["id"].toString(),
          phone: decodedResponse["data"]["User_Profile_Details"]["user_phone"],
          name: decodedResponse["data"]["User_Profile_Details"]["user_name"],
          email: decodedResponse["data"]["User_Profile_Details"]["user_email"],
          token: decodedResponse["data"]["User_Profile_Details"]["user_token"],
          image: decodedResponse["data"]["User_Profile_Details"]["user_image"]
              .toString(),
          accNum: decodedResponse["data"]["User_Profile_Details"]["account_no"],
          ifsc: decodedResponse["data"]["User_Profile_Details"]["ifsc"],
          branch: decodedResponse["data"]["User_Profile_Details"]["branch"],
          lat: decodedResponse["data"]["User_Profile_Details"]["lat"],
          lng: decodedResponse["data"]["User_Profile_Details"]["lng"],
          nameOnAcc: decodedResponse["data"]["User_Profile_Details"]
              ["name_on_account"],
          bankName: decodedResponse["data"]["User_Profile_Details"]
              ["bank_name"],
          subStatusId: decodedResponse["data"]["User_Profile_Details"]
              ["user_sub_status_id"],
          deviceId: decodedResponse["data"]["User_Profile_Details"]
              ["user_device_id"],
          created: decodedResponse["data"]["User_Profile_Details"]
              ["created_at"],
          modified: decodedResponse["data"]["User_Profile_Details"]
              ["updated_at"],
          subscriptionId: decodedResponse["data"]["customer_subscription"]
                  ["subscription_id"]
              .toString(),
          subscriptionEndDate: decodedResponse["data"]["customer_subscription"]
              ["end_date"],
        );
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      debugPrint("❗ PROFILE DETAILS > $e");
      throw e.toString();
    }
  }

  Future<bool> postUserDetails(UserProfileData data) async {
    debugPrint("➡️ User Details > $data");

    try {
      Response response = await dio.post(
        _baseUrl + _postUpdateUserDetails,
        options: Options(headers: {
          "user-token": token!,
        }),
        data: {
          "user_name": data.name,
          "user_email": data.email,
          "bank_name": data.bankName,
          "name_on_account": data.nameOnAcc,
          "account_no": data.accNum,
          "ifsc": data.ifsc,
          "branch_name": data.branch,
          "user_device_id": data.deviceId,
        },
      );
      debugPrint("⬅️ User Details > $response");

      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        return true;
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      debugPrint("❗ User Details > $e");
      throw e.toString();
    }
  }

  Future<bool> postUserImage(String img) async {
    debugPrint("➡️ USER IMAGE > Img: $img");
    try {
      Response response = await dio.post(
        _baseUrl + _postUpdateUserDetails,
        options: Options(headers: {
          "user-token": token!,
        }),
        data: {
          "user_image": img,
        },
      );
      debugPrint("⬅️ USER IMAGE > $response");
      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        return true;
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      debugPrint("❗ USER IMAGE > $e");
      throw e.toString();
    }
  }

  Future<List<DriverListModel>?> postDriversList(LatLng latLng) async {
    debugPrint(
        "➡️ DRIVERS LIST > Lat: ${latLng.latitude}, Lng: ${latLng.longitude}");
    try {
      Response response = await dio.post(
        _baseUrl + _postDriversList,
        data: {
          "lat": latLng.latitude,
          "lng": latLng.longitude,
        },
      );
      debugPrint("⬅️ DRIVERS LIST > $response");
      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        final List<dynamic> list = decodedResponse["data"];
        return list
            .map((e) => DriverListModel(
                  lat: e["current_latitude"],
                  lng: e["current_longitude"],
                  dist: e["distance"].toString(),
                ))
            .toList();
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      debugPrint("❗ DRIVERS LIST: $e");
      throw e.toString();
    }
  }

  Future<List<SubscriptionList>?> getSubscriptionsList() async {
    debugPrint("➡️ Subscription List");
    try {
      Response response = await dio.get(
        _baseUrl + _getSubscriptionList,
      );
      debugPrint("⬅️ Subscription List > $response");
      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        final List<dynamic> list = decodedResponse["data"];
        return list
            .map((e) => SubscriptionList(
                  id: e["id"],
                  name: e["subscription_name"],
                  fees: e["fees"],
                  validity: e["plan_valid_for"],
                  bookFees: e["booking_fees"],
                  freeBookings: e["no_of_free_booking_fees"].toString(),
                  freeBookingsValidity: e["no_of_free_booking_valid_for"],
                ))
            .toList();
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      debugPrint("❗ Subscription List > $e");
      throw e.toString();
    }
  }

  Future<PaymentModel?> postSubscriptionInit(String id) async {
    debugPrint("➡️ Subscription Init > ID: $id");
    try {
      Response response = await dio.post(
        _baseUrl + _postSubInit,
        options: Options(headers: {
          "user-token": token!,
        }),
        data: {
          "subscription_id": id,
        },
      );
      debugPrint("⬅️ Subscription Init > $response");

      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["body"]["resultInfo"]["resultStatus"] == "S") {
        return PaymentModel(
          signature: decodedResponse["head"]["signature"],
          txnToken: decodedResponse["body"]["txnToken"],
          orderId: decodedResponse["orderId"],
        );
      } else {
        throw _sthWentWrong;
      }
    } catch (e) {
      debugPrint("❗ Subscription Init > $e");
      throw e.toString();
    }
  }

  Future<bool> postUpdateSubStatus(PaymentStatus status) async {
    debugPrint("➡️ Update Subscription Status > STATUS: $status");

    try {
      Response response = await dio.post(
        _baseUrl + _postUpdateSubStatus,
        options: Options(headers: {
          "user-token": token!,
        }),
        data: {
          "RESPMSG": status.RESPMSG,
          "CURRENCY": status.CURRENCY,
          "TXNID": status.TXNID,
          "ORDERID": status.ORDERID,
          "CHECKSUMHASH": status.CHECKSUMHASH,
          "TXNDATE": status.TXNDATE,
          "TXNAMOUNT": status.TXNAMOUNT,
          "PAYMENTMODE": status.PAYMENTMODE,
          "BANKNAME": status.BANKNAME,
          "RESPCODE": status.RESPCODE,
          "STATUS": status.STATUS,
          "BANKTXNID": status.BANKTXNID,
          "GATEWAYNAME": status.GATEWAYNAME,
          "MID": status.MID,
        },
      );
      debugPrint("⬅️ Update Subscription Status > $response");

      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        return true;
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      debugPrint("❗ Update Subscription Status > $e");
      throw e.toString();
    }
  }

  Future<int> postCityId({required LatLng latLng}) async {
    debugPrint("➡️ CITY ID > Lat: ${latLng.latitude} Lng: ${latLng.longitude}");
    try {
      Response response = await dio.post(
        _baseUrl + _postCityId,
        data: {
          "lat": latLng.latitude,
          "lng": latLng.longitude,
        },
      );
      debugPrint("⬅️ CITY ID > ${response.data}");
      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        return decodedResponse["data"]["id"];
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      debugPrint("❗CITY ID: $e");
      throw e.toString();
    }
  }

  Future<List<BookingPrices>?> postBookingPriceList(
      String cityId, String dist) async {
    debugPrint("➡️ BOOKING PRICE LIST > City Id: $cityId, Distance: $dist");

    try {
      Response response = await dio.post(
        _baseUrl + _postBookingPrices,
        options: Options(headers: {
          "user-token": token!,
        }),
        data: {
          "city_id": cityId,
          "distance": dist,
        },
      );
      debugPrint("⬅️ BOOKING PRICE LIST > $response");
      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        final List<dynamic> list = decodedResponse["data"];
        return list
            .map((e) => BookingPrices(
                  cityId: e["city_id"].toString(),
                  carId: e["car_id"].toString(),
                  carType: e["car_type"],
                  passengerNo: e["passenger_no"].toString(),
                  approxPrice: e["aprox_price"].toString(),
                ))
            .toList();
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      debugPrint("❗ BOOKING PRICE LIST > $e");
      throw e.toString();
    }
  }

  Future<BookingDetails?> postBookingInitiate(
      BookingDetails bookingDetails) async {
    debugPrint(
        "➡️ BOOKING INITIATE > Car Id: ${bookingDetails.carId}, City Id: ${bookingDetails.cityId}, Pay Type: ${bookingDetails.payType}, .....");
    try {
      Response response = await dio.post(_baseUrl + _postBookingInit,
          options: Options(headers: {
            "user-token": token!,
          }),
          data: {
            "car_id": bookingDetails.carId,
            "city_id": bookingDetails.cityId,
            "pickup_address": bookingDetails.pickupAdd,
            "pickup_lat": bookingDetails.pickupLat,
            "pickup_long": bookingDetails.pickupLng,
            "drop_address": bookingDetails.dropAdd,
            "drop_lat": bookingDetails.dropLat,
            "drop_long": bookingDetails.dropLng,
            "distance": bookingDetails.dist,
            "estimated_time": bookingDetails.estTime,
            "estimated_amount": bookingDetails.estAmount,
            "pay_type": bookingDetails.payType,
          });
      debugPrint("⬅️ BOOKING INITIATE > $response");
      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        return BookingDetails(
          bookingId: decodedResponse["data"]["bookingDetails"]["booking_id"]
              .toString(),
          bookingCode: decodedResponse["data"]["bookingDetails"]["booking_code"]
              .toString(),
        );
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      debugPrint("❗ BOOKING INITIATE > $e");
      throw e.toString();
    }
  }

  Future<BookingDetails?> postFindDriver(String bookId) async {
    debugPrint("➡️ FIND DRIVER > Booking Id: $bookId");
    try {
      Response response = await dio.post(
        _baseUrl + _postFindDriver,
        options: Options(headers: {
          "user-token": token!,
        }),
        data: {
          "booking_id": bookId,
        },
      );
      debugPrint("⬅️ FIND DRIVER > $response");
      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        return BookingDetails(
          bookingId: decodedResponse["data"]["bookingDetails"]["booking_id"]
              .toString(),
          carId: decodedResponse["data"]["bookingDetails"]["car_id"].toString(),
          cityId:
              decodedResponse["data"]["bookingDetails"]["city_id"].toString(),
          bookingCode: decodedResponse["data"]["bookingDetails"]
              ["booking_code"],
          pickupAdd: decodedResponse["data"]["bookingDetails"]
              ["pickup_address"],
          pickupLat: decodedResponse["data"]["bookingDetails"]["pickup_lat"],
          pickupLng: decodedResponse["data"]["bookingDetails"]["pickup_long"],
          dropAdd: decodedResponse["data"]["bookingDetails"]["drop_address"],
          dropLat: decodedResponse["data"]["bookingDetails"]["drop_lat"],
          dropLng: decodedResponse["data"]["bookingDetails"]["drop_long"],
          finalTime: decodedResponse["data"]["bookingDetails"]["final_time"],
          extraTime: decodedResponse["data"]["bookingDetails"]["extra_time"],
          extraAmount: decodedResponse["data"]["bookingDetails"]["extra_fees"]
              .toString(),
          convenienceFee: decodedResponse["data"]["bookingDetails"]
                  ["convenience_fees"]
              .toString(),
          finalDistFee: decodedResponse["data"]["bookingDetails"]
                  ["final_distance_fees"]
              .toString(),
          payType: decodedResponse["data"]["bookingDetails"]["pay_type"],
          payableAmount: decodedResponse["data"]["bookingDetails"]
                  ["payble_amount"]
              .toString(),
          status: decodedResponse["data"]["bookingDetails"]["status"],
          dist:
              decodedResponse["data"]["bookingDetails"]["distance"].toString(),
          estTime: decodedResponse["data"]["bookingDetails"]["est_time"],
          otp: decodedResponse["data"]["bookingDetails"]["otp"].toString(),
          lat: decodedResponse["data"]["driverDetails"]["current_latitude"],
          lng: decodedResponse["data"]["driverDetails"]["current_longitude"],
          driverImage: decodedResponse["data"]["driverDetails"]["driver_image"],
          driverName: decodedResponse["data"]["driverDetails"]["driver_name"],
          driverPhone: decodedResponse["data"]["driverDetails"]["driver_phone"],
          carImage: decodedResponse["data"]["driverDetails"]["car_image"],
          carNumber: decodedResponse["data"]["driverDetails"]["car_no"],
        );
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      debugPrint("❗ FIND DRIVER > $e");
      throw e.toString();
    }
  }

  Future<List<CouponsModel>?> postAllCouponsList(
      String? amount, String? payType) async {
    debugPrint("➡️ ALL COUPONS LIST > Amount: $amount, PayType: $payType");

    try {
      Response? response;
      if (amount != null) {
        response = await dio.post(
          _baseUrl + _postAllCoupon,
          data: {
            "final_amount": amount,
            "pay_type": payType,
          },
        );
      } else {
        response = await dio.post(
          _baseUrl + _postAllCoupon,
        );
      }
      debugPrint("⬅️ ALL COUPONS LIST > $response");

      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        final List<dynamic> list = decodedResponse["data"];
        return list
            .map((e) => CouponsModel(
                  id: e["id"].toString(),
                  code: e["coupon_code"],
                  details: e["details"],
                  payType: e["pay_type"],
                  minAmount: e["min_amount"].toString(),
                  discType: e["discount_type"],
                  discValue: e["discount_value"].toString(),
                ))
            .toList();
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      debugPrint("❗ ALL COUPONS LIST: $e");
      throw e.toString();
    }
  }

  Future<List<BookingDetails>?> postBookingHistory() async {
    debugPrint("➡️ BOOKING HISTORY");
    try {
      Response response = await dio.post(_baseUrl + _postBookingHistory,
          options: Options(headers: {
            "user-token": token,
          }));
      debugPrint("⬅️ BOOKING HISTORY $response");

      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        final List<dynamic> list = decodedResponse["data"];
        return list
            .map((e) => BookingDetails(
                  bookingId: e["id"].toString(),
                  carId: e["car_id"].toString(),
                  cityId: e["city_id"].toString(),
                  bookingCode: e["booking_code"],
                  bookingDate: e["booking_date"],
                  pickupAdd: e["pickup_address"],
                  pickupLat: e["pickup_lat"],
                  pickupLng: e["pickup_long"],
                  dropAdd: e["drop_address"],
                  dropLat: e["drop_lat"],
                  dropLng: e["drop_long"],
                  dist: e["distance"].toString(),
                  finalTime: e["final_time"],
                  extraTime: e["extra_time"],
                  extraAmount: e["extra_fees"].toString(),
                  convenienceFee: e["convenience_fees"].toString(),
                  finalDistFee: e["final_distance_fees"].toString(),
                  payType: e["pay_type"],
                  couponCode: e["coupon_code"],
                  disc: e["discount"].toString(),
                  payableAmount: e["payble_amount"].toString(),
                  status: e["status"],
                ))
            .toList();
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      debugPrint("❗ BOOKING HISTORY $e");
      throw e.toString();
    }
  }

  Future<BookingDetails> postBookingStatus() async {
    debugPrint("🗝️ Token > $token");
    debugPrint("➡️ BOOKING STATUS");
    try {
      Response response = await dio.post(_baseUrl + _postBookingStatus,
          options: Options(headers: {
            "user-token": token!,
          }));
      debugPrint("⬅️ BOOKING STATUS > $response");

      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        return BookingDetails(
          bookingId: decodedResponse["data"]["bookingDetails"]["booking_id"]
              .toString(),
          carId: decodedResponse["data"]["bookingDetails"]["car_id"].toString(),
          cityId:
              decodedResponse["data"]["bookingDetails"]["city_id"].toString(),
          bookingCode: decodedResponse["data"]["bookingDetails"]
              ["booking_code"],
          pickupAdd: decodedResponse["data"]["bookingDetails"]
              ["pickup_address"],
          pickupLat: decodedResponse["data"]["bookingDetails"]["pickup_lat"],
          pickupLng: decodedResponse["data"]["bookingDetails"]["pickup_long"],
          dropAdd: decodedResponse["data"]["bookingDetails"]["drop_address"],
          dropLat: decodedResponse["data"]["bookingDetails"]["drop_lat"],
          dropLng: decodedResponse["data"]["bookingDetails"]["drop_long"],
          finalTime: decodedResponse["data"]["bookingDetails"]["final_time"],
          extraTime: decodedResponse["data"]["bookingDetails"]["extra_time"],
          extraAmount: decodedResponse["data"]["bookingDetails"]["extra_fees"]
              .toString(),
          convenienceFee: decodedResponse["data"]["bookingDetails"]
                  ["convenience_fees"]
              .toString(),
          finalDistFee: decodedResponse["data"]["bookingDetails"]
                  ["final_distance_fees"]
              .toString(),
          payType: decodedResponse["data"]["bookingDetails"]["pay_type"],
          payableAmount: decodedResponse["data"]["bookingDetails"]
                  ["payble_amount"]
              .toString(),
          status: decodedResponse["data"]["bookingDetails"]["status"],
          dist:
              decodedResponse["data"]["bookingDetails"]["distance"].toString(),
          estTime: decodedResponse["data"]["bookingDetails"]["est_time"],
          otp: decodedResponse["data"]["bookingDetails"]["otp"],
          lat: decodedResponse["data"]["driverDetails"]["current_latitude"],
          lng: decodedResponse["data"]["driverDetails"]["current_longitude"],
          driverImage: decodedResponse["data"]["driverDetails"]["driver_image"],
          driverName: decodedResponse["data"]["driverDetails"]["driver_name"],
          driverPhone: decodedResponse["data"]["driverDetails"]["driver_phone"],
          carImage: decodedResponse["data"]["driverDetails"]["car_image"],
          carNumber: decodedResponse["data"]["driverDetails"]["car_no"],
        );
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      debugPrint("❗ BOOKING STATUS: $e");
      throw e.toString();
    }
  }

  Future<PaymentModel?> postPaymentInit(String bookId) async {
    debugPrint("➡️ Payment Init > BookingId: $bookId");
    try {
      Response response = await dio.post(
        _baseUrl + _postPaymentInit,
        options: Options(headers: {
          "user-token": token!,
        }),
        data: {
          "booking_id": bookId,
        },
      );
      debugPrint("⬅️ Payment Init > $response");

      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["body"]["resultInfo"]["resultStatus"] == "S") {
        return PaymentModel(
          signature: decodedResponse["head"]["signature"],
          txnToken: decodedResponse["body"]["txnToken"],
          orderId: decodedResponse["orderId"],
        );
      } else {
        throw _sthWentWrong;
      }
    } catch (e) {
      debugPrint("❗ Payment Init > $e");
      throw e.toString();
    }
  }

  Future<bool> postUpdatePaymentType(
      {required String bookingId, required String paymentType}) async {
    debugPrint(
        "➡️ UPDATE PAYMENT TYPE > Booking Id: $bookingId, Payment Type: $paymentType");
    try {
      Response response = await dio.post(
        _baseUrl + _postUpdatePaymentType,
        options: Options(headers: {
          "user-token": token,
        }),
        data: {
          "booking_id": bookingId,
          "pay_type": paymentType,
        },
      );
      debugPrint("➡️ UPDATE PAYMENT TYPE > $response");
      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        return true;
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      debugPrint("❗ UPDATE PAYMENT TYPE > $e");
      throw e.toString();
    }
  }

  Future<bool> postUpdatePaymentStatus(PaymentStatus status) async {
    debugPrint("➡️ UPDATE PAYMENT STATUS > $status");

    try {
      Response response = await dio.post(
        _baseUrl + _postUpdatePaymentStatus,
        options: Options(headers: {
          "user-token": token!,
        }),
        data: {
          "RESPMSG": status.RESPMSG,
          "CURRENCY": status.CURRENCY,
          "TXNID": status.TXNID,
          "ORDERID": status.ORDERID,
          "CHECKSUMHASH": status.CHECKSUMHASH,
          "TXNDATE": status.TXNDATE,
          "TXNAMOUNT": status.TXNAMOUNT,
          "PAYMENTMODE": status.PAYMENTMODE,
          "BANKNAME": status.BANKNAME,
          "RESPCODE": status.RESPCODE,
          "STATUS": status.STATUS,
          "BANKTXNID": status.BANKTXNID,
          "GATEWAYNAME": status.GATEWAYNAME,
          "MID": status.MID,
        },
      );
      debugPrint("⬅️ UPDATE PAYMENT Status > $response");

      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        return true;
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      debugPrint("❗ UPDATE PAYMENT Status > $e");
      throw e.toString();
    }
  }

  Future<BookingDetails> postApplyCoupon(String bookId, String couponId) async {
    debugPrint("➡️ APPLY COUPON > Booking Id: $bookId, Coupon Id: $couponId");

    try {
      Response response = await dio.post(
        _baseUrl + _postApplyCoupon,
        data: {
          "booking_id": bookId,
          "coupon_id": couponId,
        },
      );
      debugPrint("⬅️ APPLY COUPON > $response");

      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        return BookingDetails(
          bookingId: decodedResponse["data"]["bookingDetails"]["booking_id"]
              .toString(),
          bookingCode: decodedResponse["data"]["bookingDetails"]
              ["booking_code"],
          cityId:
              decodedResponse["data"]["bookingDetails"]["city_id"].toString(),
          carId: decodedResponse["data"]["bookingDetails"]["car_id"].toString(),
          pickupAdd: decodedResponse["data"]["bookingDetails"]
              ["pickup_address"],
          pickupLat: decodedResponse["data"]["bookingDetails"]["pickup_lat"],
          pickupLng: decodedResponse["data"]["bookingDetails"]["pickup_long"],
          dropAdd: decodedResponse["data"]["bookingDetails"]["drop_address"],
          dropLat: decodedResponse["data"]["bookingDetails"]["drop_lat"],
          dropLng: decodedResponse["data"]["bookingDetails"]["drop_long"],
          dist:
              decodedResponse["data"]["bookingDetails"]["distance"].toString(),
          estTime: decodedResponse["data"]["bookingDetails"]["est_time"],
          estAmount: decodedResponse["data"]["bookingDetails"]["est_amount"]
              .toString(),
          finalTime: decodedResponse["data"]["bookingDetails"]["final_time"],
          extraTime: decodedResponse["data"]["bookingDetails"]["extra_time"],
          extraAmount: decodedResponse["data"]["bookingDetails"]["extra_fees"]
              .toString(),
          convenienceFee: decodedResponse["data"]["bookingDetails"]
                  ["convenience_fees"]
              .toString(),
          finalDistFee: decodedResponse["data"]["bookingDetails"]
                  ["final_distance_fees"]
              .toString(),
          disc:
              decodedResponse["data"]["bookingDetails"]["discount"].toString(),
          payType: decodedResponse["data"]["bookingDetails"]["pay_type"],
          payableAmount: decodedResponse["data"]["bookingDetails"]
                  ["payble_amount"]
              .toString(),
          status: decodedResponse["data"]["bookingDetails"]["status"],
          couponCode: decodedResponse["data"]["couponDetails"]["coupon_code"],
          couponId:
              decodedResponse["data"]["couponDetails"]["coupon_id"].toString(),
        );
      } else {
        throw decodedResponse["message"];
      }
    } catch (e) {
      debugPrint("❗ APPLY COUPON > $e");
      throw e.toString();
    }
  }

  Future<String> getSupportNum() async {
    try {
      debugPrint("➡️ SUPPORT NUM");
      Response response = await dio.get(
        _baseUrl + _getSupportNum,
      );
      debugPrint("⬅️ SUPPORT NUM > $response");
      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        return decodedResponse["data"]["support_contact"];
      } else {
        throw _sthWentWrong;
      }
    } catch (e) {
      debugPrint("❗ SUPPORT NUM > $e");
      throw e.toString();
    }
  }

  Future<String> getSosNum() async {
    try {
      debugPrint("➡️ SOS NUM");
      Response response = await dio.get(
        _baseUrl + _getSupportNum,
      );
      debugPrint("⬅️ SOS NUM > $response");
      final Map<String, dynamic> decodedResponse = response.data;
      if (decodedResponse["success"] == "1") {
        return decodedResponse["data"]["sos_contact"];
      } else {
        throw _sthWentWrong;
      }
    } catch (e) {
      debugPrint("❗ SOS NUM > $e");
      throw e.toString();
    }
  }
}
