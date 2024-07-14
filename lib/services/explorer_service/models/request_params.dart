class RequestParams {
  final int page; // eg. 1
  final int entries; // eg. 100
  final String? search; // eg. MetaMa...
  final String? include; // eg. id1,id2,id3
  final String? exclude; // eg. id1,id2,id3
  final String? platform; // 'ios' | 'android'

  const RequestParams({
    required this.page,
    required this.entries,
    this.search,
    this.include,
    this.exclude,
    this.platform,
  });

  Map<String, dynamic> toJson({bool short = false}) {
    Map<String, dynamic> params = {
      'page': page.toString(),
      'entries': entries.toString(),
    };
    if ((search ?? '').isNotEmpty) {
      params['search'] = search;
    }
    if ((include ?? '').isNotEmpty && !short) {
      params['include'] = include;
    }
    if ((exclude ?? '').isNotEmpty && !short) {
      params['exclude'] = exclude;
    }
    if ((platform ?? '').isNotEmpty) {
      params['platform'] = platform;
    }

    return params;
  }

  RequestParams copyWith({
    int? page,
    int? entries,
    String? search,
    String? include,
    String? exclude,
    String? platform,
  }) =>
      RequestParams(
        page: page ?? this.page,
        entries: entries ?? this.entries,
        search: search ?? this.search,
        include: include ?? this.include,
        exclude: exclude ?? this.exclude,
        platform: platform ?? this.platform,
      );

  RequestParams nextPage() => RequestParams(
        page: page + 1,
        entries: entries,
        search: search,
        include: include,
        exclude: exclude,
        platform: platform,
      );
}
