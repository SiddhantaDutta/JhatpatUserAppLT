class UserLoginRegData {
  final String phone;
  final String token;
  final String? otp;

  UserLoginRegData({
    required this.phone,
    required this.token,
    this.otp,
  });

  @override
  String toString() =>
      'UserLoginRegData(phone: $phone, token: $token, otp: $otp)';
}
