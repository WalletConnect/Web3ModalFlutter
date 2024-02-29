enum AnalyticsPlatform {
  mobile,
  web,
  qrcode,
  email,
  unsupported,
}

abstract class AnalyticsEvent {
  abstract final String type;
  abstract final String event;
  abstract final Map<String, dynamic>? properties;

  Map<String, dynamic> toMap();
}

class ModalCreatedEvent implements AnalyticsEvent {
  @override
  String get type => 'track';

  @override
  String get event => 'MODAL_CREATED';

  @override
  Map<String, dynamic>? get properties => null;

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'event': event,
        if (properties != null) 'properties': properties,
      };
}

class ModalLoadedEvent implements AnalyticsEvent {
  @override
  String get type => 'track';

  @override
  String get event => 'MODAL_LOADED';

  @override
  Map<String, dynamic>? get properties => null;

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'event': event,
        if (properties != null) 'properties': properties,
      };
}

class ModalOpenEvent implements AnalyticsEvent {
  final bool _connected;
  ModalOpenEvent({
    required bool connected,
  }) : _connected = connected;

  @override
  String get type => 'track';

  @override
  String get event => 'MODAL_OPEN';

  @override
  Map<String, dynamic>? get properties => {
        'connected': _connected,
      };

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'event': event,
        if (properties != null) 'properties': properties,
      };
}

class ModalCloseEvent implements AnalyticsEvent {
  final bool _connected;
  ModalCloseEvent({
    required bool connected,
  }) : _connected = connected;

  @override
  String get type => 'track';

  @override
  String get event => 'MODAL_CLOSE';

  @override
  Map<String, dynamic>? get properties => {
        'connected': _connected,
      };

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'event': event,
        if (properties != null) 'properties': properties,
      };
}

class ClickAllWalletsEvent implements AnalyticsEvent {
  @override
  String get type => 'track';

  @override
  String get event => 'CLICK_ALL_WALLETS';

  @override
  Map<String, dynamic>? get properties => null;

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'event': event,
        if (properties != null) 'properties': properties,
      };
}

class ClickNetworksEvent implements AnalyticsEvent {
  @override
  String get type => 'track';

  @override
  String get event => 'CLICK_NETWORKS';

  @override
  Map<String, dynamic>? get properties => null;

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'event': event,
        if (properties != null) 'properties': properties,
      };
}

class SwitchNetworkEvent implements AnalyticsEvent {
  final String _network;
  SwitchNetworkEvent({
    required String network,
  }) : _network = network;

  @override
  String get type => 'track';

  @override
  String get event => 'SWITCH_NETWORK';

  @override
  Map<String, dynamic>? get properties => {
        'network': _network,
      };

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'event': event,
        if (properties != null) 'properties': properties,
      };
}

class SelectWalletEvent implements AnalyticsEvent {
  final String _name;
  final String? _platform;
  SelectWalletEvent({
    required String name,
    String? platform,
  })  : _name = name,
        _platform = platform;

  @override
  String get type => 'track';

  @override
  String get event => 'SELECT_WALLET';

  @override
  Map<String, dynamic>? get properties => {
        'name': _name,
        if (_platform != null) 'platform': _platform,
      };

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'event': event,
        if (properties != null) 'properties': properties,
      };
}

class ConnectSuccessEvent implements AnalyticsEvent {
  final String _name;
  final String? _method;
  ConnectSuccessEvent({
    required String name,
    String? method,
  })  : _name = name,
        _method = method;

  @override
  String get type => 'track';

  @override
  String get event => 'CONNECT_SUCCESS';

  @override
  Map<String, dynamic>? get properties => {
        'name': _name,
        if (_method != null) 'method': _method,
      };

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'event': event,
        if (properties != null) 'properties': properties,
      };
}

class ConnectErrorEvent implements AnalyticsEvent {
  final String _message;
  ConnectErrorEvent({
    required String message,
  }) : _message = message;

  @override
  String get type => 'track';

  @override
  String get event => 'CONNECT_ERROR';

  @override
  Map<String, dynamic>? get properties => {
        'message': _message,
      };

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'event': event,
        if (properties != null) 'properties': properties,
      };
}

class DisconnectSuccessEvent implements AnalyticsEvent {
  @override
  String get type => 'track';

  @override
  String get event => 'DISCONNECT_SUCCESS';

  @override
  Map<String, dynamic>? get properties => null;

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'event': event,
        if (properties != null) 'properties': properties,
      };
}

class DisconnectErrorEvent implements AnalyticsEvent {
  @override
  String get type => 'track';

  @override
  String get event => 'DISCONNECT_ERROR';

  @override
  Map<String, dynamic>? get properties => null;

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'event': event,
        if (properties != null) 'properties': properties,
      };
}

class ClickWalletHelpEvent implements AnalyticsEvent {
  @override
  String get type => 'track';

  @override
  String get event => 'CLICK_WALLET_HELP';

  @override
  Map<String, dynamic>? get properties => null;

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'event': event,
        if (properties != null) 'properties': properties,
      };
}

class ClickNetworkHelpEvent implements AnalyticsEvent {
  @override
  String get type => 'track';

  @override
  String get event => 'CLICK_NETWORK_HELP';

  @override
  Map<String, dynamic>? get properties => null;

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'event': event,
        if (properties != null) 'properties': properties,
      };
}

class ClickGetWalletEvent implements AnalyticsEvent {
  @override
  String get type => 'track';

  @override
  String get event => 'CLICK_GET_WALLET';

  @override
  Map<String, dynamic>? get properties => null;

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'event': event,
        if (properties != null) 'properties': properties,
      };
}
