class MagicData {
  String email;
  String address;
  int chainId;

  MagicData({
    required this.email,
    required this.chainId,
    required this.address,
  });

  factory MagicData.fromJson(Map<String, dynamic> json) {
    return MagicData(
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

  @override
  String toString() => toJson().toString();

  MagicData copytWith({
    String? email,
    String? address,
    int? chainId,
  }) {
    return MagicData(
      email: email ?? this.email,
      address: address ?? this.address,
      chainId: chainId ?? this.chainId,
    );
  }
}
