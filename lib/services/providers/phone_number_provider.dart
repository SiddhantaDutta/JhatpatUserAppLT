import 'package:flutter_riverpod/flutter_riverpod.dart';

// * Used in authentication to preserve the phone number
// * between phone number field and otp field.
final phoneNumProvider = StateProvider<String>((ref) => "");
