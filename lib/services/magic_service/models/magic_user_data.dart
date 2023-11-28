class MagicUserData {
  String email;
  String address;
  int chainId;

  MagicUserData({
    required this.email,
    required this.chainId,
    required this.address,
  });

  factory MagicUserData.fromJson(Map<String, dynamic> json) {
    return MagicUserData(
      email: json['email'].toString(),
      address: json['address'].toString(),
      chainId: int.parse(json['chainId'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'address': address,
      'chainId': chainId,
    };
  }
}
