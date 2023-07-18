class UserProfileData {
  final String? phone;
  final String? id;
  final String? deviceId;
  final String? token;
  final String? name;
  final String? email;
  final String? image;
  final String? bankName;
  final String? nameOnAcc;
  final String? accNum;
  final String? ifsc;
  final String? branch;
  final String? subStatusId;
  final String? lat;
  final String? lng;
  final String? created;
  final String? modified;
  final String? subscriptionId;
  final String? subscriptionEndDate;

  UserProfileData({
    this.phone,
    this.id,
    this.deviceId,
    this.token,
    this.name,
    this.email,
    this.image,
    this.bankName,
    this.nameOnAcc,
    this.accNum,
    this.ifsc,
    this.branch,
    this.subStatusId,
    this.lat,
    this.lng,
    this.created,
    this.modified,
    this.subscriptionId,
    this.subscriptionEndDate,
  });

  @override
  String toString() {
    return 'UserProfileData(phone: $phone, id: $id, deviceId: $deviceId, token: $token, name: $name, email: $email, image: $image, bankName: $bankName, nameOnAcc: $nameOnAcc, accNum: $accNum, ifsc: $ifsc, branch: $branch, subStatusId: $subStatusId, lat: $lat, lng: $lng, created: $created, modified: $modified, subscriptionId: $subscriptionId, subscriptionEndDate: $subscriptionEndDate)';
  }
}
