import 'package:flutter_riverpod/flutter_riverpod.dart';

// * Used to help the drawer know when profile has been updated.
final profileUpdated = StateProvider<bool>((ref) => true);
