import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';

class UnilinksServices {
  static String _code = '';

  static String get code => _code;

  static bool get hascode => _code.isNotEmpty;

  static void reset() => _code = "";
  List<String> usedId = [];
  static init() async {
    try {
      final Uri? uri = await getInitialUri();
      uniHandler(uri);
    } on PlatformException catch (e) {
      print("failed:: $e");
    } on FormatException {
      print("formate exception");
    }

    uriLinkStream.listen((Uri? uri) async {
      uniHandler(uri);
    }, onError: (error) {
      print("onurilinkerror:: $error");
    });
  }

  static uniHandler(Uri? uri) {
    if (uri == null || uri.queryParameters.isEmpty) return;
    Map<String, String> param = uri.queryParameters;
    String type = param['type'] ?? "";
    print("receivedCode:: $type");
    if (type == "post") {
    } else {}
  }


}
