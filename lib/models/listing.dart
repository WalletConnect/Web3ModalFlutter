import 'dart:convert';

class Listing {
  final String id;
  final String name;
  final String homepage;
  final String imageId;
  final int order;
  final String? mobileLink;
  final String? desktopLink;
  final String? webappLink;
  final String? appStore;
  final String? playStore;
  final String? rdns;
  final List<Injected>? injected;

  const Listing({
    required this.id,
    required this.name,
    required this.homepage,
    required this.imageId,
    required this.order,
    this.mobileLink,
    this.desktopLink,
    this.webappLink,
    this.appStore,
    this.playStore,
    this.rdns,
    this.injected,
  });

  Listing copyWith({
    String? id,
    String? name,
    String? homepage,
    String? imageId,
    int? order,
    String? mobileLink,
    String? desktopLink,
    String? webappLink,
    String? appStore,
    String? playStore,
    String? rdns,
    List<Injected>? injected,
  }) =>
      Listing(
        id: id ?? this.id,
        name: name ?? this.name,
        homepage: homepage ?? this.homepage,
        imageId: imageId ?? this.imageId,
        order: order ?? this.order,
        mobileLink: mobileLink ?? this.mobileLink,
        desktopLink: desktopLink ?? this.desktopLink,
        webappLink: webappLink ?? this.webappLink,
        appStore: appStore ?? this.appStore,
        playStore: playStore ?? this.playStore,
        rdns: rdns ?? this.rdns,
        injected: injected ?? this.injected,
      );

  factory Listing.fromRawJson(String str) => Listing.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Listing.fromJson(Object? json) {
    final j = json as Map<String, dynamic>? ?? {};
    return Listing(
      id: j['id'],
      name: j['name'],
      homepage: j['homepage'],
      imageId: j['image_id'],
      order: j['order'],
      mobileLink: j['mobile_link'],
      desktopLink: j['desktop_link'],
      webappLink: j['webapp_link'],
      appStore: j['app_store'],
      playStore: j['play_store'],
      rdns: j['rdns'],
      injected: j['injected'] == null
          ? []
          : List<Injected>.from(
              j['injected']!.map((x) => Injected.fromJson(x)),
            ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'homepage': homepage,
        'image_id': imageId,
        'order': order,
        'mobile_link': mobileLink,
        'desktop_link': desktopLink,
        'webapp_link': webappLink,
        'app_store': appStore,
        'play_store': playStore,
        'rdns': rdns,
        'injected': injected == null
            ? []
            : List<dynamic>.from(injected!.map((x) => x.toJson())),
      };
}

class Injected {
  final String namespace;
  final String injectedId;

  Injected({required this.namespace, required this.injectedId});

  Injected copyWith({String? namespace, String? injectedId}) => Injected(
        namespace: namespace ?? this.namespace,
        injectedId: injectedId ?? this.injectedId,
      );

  factory Injected.fromRawJson(String str) =>
      Injected.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Injected.fromJson(Map<String, dynamic> json) => Injected(
        namespace: json['namespace'],
        injectedId: json['injected_id'],
      );

  Map<String, dynamic> toJson() => {
        'namespace': namespace,
        'injected_id': injectedId,
      };
}
