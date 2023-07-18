import 'package:flutter_riverpod/flutter_riverpod.dart';

// * Used to switch between phone and otp fields in auth page.
final otpScreenBoolProvider = StateProvider<bool>((ref) => false);
