import 'package:flutter_riverpod/flutter_riverpod.dart';

// * Stores token returned from the initial login/register API.
final tokenProvider = StateProvider<String?>((ref) => null);
