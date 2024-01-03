class CoinbaseData {
  String address;
  String chainName;
  int chainId;

  CoinbaseData({
    required this.address,
    required this.chainName,
    required this.chainId,
  });

  factory CoinbaseData.fromJson(Map<String, dynamic> json) {
    return CoinbaseData(
      address: json['address'].toString(),
      chainName: json['chain'].toString(),
      chainId: int.parse(json['networkId'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'chain': chainName,
      'networkId': chainId,
    };
  }

  CoinbaseData copytWith({
    String? address,
    String? chainName,
    int? chainId,
  }) {
    return CoinbaseData(
      address: address ?? this.address,
      chainName: chainName ?? this.chainName,
      chainId: chainId ?? this.chainId,
    );
  }
}
