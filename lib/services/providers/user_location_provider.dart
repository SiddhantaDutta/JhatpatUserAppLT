import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// * User Current Location
final userLocationProvider = StateProvider<LatLng?>((ref) => null);
