import 'package:web3modal_flutter/utils/url/i_url_utils.dart';
import 'package:web3modal_flutter/utils/url/url_utils.dart';

class UrlUtilsSingleton {
  IUrlUtils instance;

  UrlUtilsSingleton() : instance = UrlUtils();
}

final urlUtils = UrlUtilsSingleton();
