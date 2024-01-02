import 'package:event/event.dart';
import 'package:web3modal_flutter/services/coinbase_service/models/coinbase_data.dart';

class CoinbaseConnectEvent implements EventArgs {
  final CoinbaseData? data;
  CoinbaseConnectEvent(this.data);
}

class CoinbaseErrorEvent implements EventArgs {
  final String? error;
  CoinbaseErrorEvent(this.error);
}

class CoinbaseSessionEvent implements EventArgs {
  String? address;
  String? chainName;
  String? chainId;

  CoinbaseSessionEvent({
    this.address,
    this.chainName,
    this.chainId,
  });
}

class CoinbaseResponseEvent implements EventArgs {
  String? data;
  CoinbaseResponseEvent({required this.data});
}
