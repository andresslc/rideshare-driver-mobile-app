/// ----------------------
/// LOGIN PARAMS
/// ----------------------
class SendOtpParams {
  final String phone;
  final String countryCode;

  const SendOtpParams({required this.phone, required this.countryCode});

  Map<String, dynamic> toJson() {
    return {"phone": "$countryCode$phone", "role": 'driver'};
  }
}

// / ----------------------
/// VERIFY OTP PARAMS
/// ----------------------
class VerifyOtpParams {
  final String phone;
  final String? fcm;
  final String otp;
  final String countryCode;

  const VerifyOtpParams({
    required this.phone,
    required this.otp,
    this.fcm,
    required this.countryCode,
  });

  Map<String, dynamic> toJson() {
    return {
      "phone": "$countryCode$phone",
      "otp": otp,
      "role": 'driver',

      if (fcm != null) "fcmToken": fcm,
    };
  }
}
