import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GraphsScreen extends StatefulWidget {
  static const routeName = '/dashboard-graphs';
  const GraphsScreen({super.key});

  @override
  State<GraphsScreen> createState() => _GraphsScreenState();
}

class _GraphsScreenState extends State<GraphsScreen> {
  String iframeUrl = "";
  var _iframeController;

  List<dynamic> itemList = [];

  String _selectedId = '';
  bool _didchanged = true;

  @override
  void didChangeDependencies() {
    if (_didchanged) {
      final Map<String, dynamic> arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

      itemList = arguments['items'];

      _selectedId = itemList[0]['ID'];
      String temp = _generateTokenAndLaunchDashboard();
      _setWebviewController(temp);
      _didchanged = false;
    }
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  Future<void> _refreshFeed() async {
    setState(() {
      _didchanged = true;
    });
  }

  void _setWebviewController(String url) {
    _iframeController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  String _generateTokenAndLaunchDashboard() {
    final String METABASE_SITE_URL = "https://metabase.cloudbelly.in";
    final String METABASE_SECRET_KEY =
        "efdd99d7d0b5d40cac89a83bf3a9c0ada50377c09b586d3aceb71078c1234b43";

    final payload = JWT({
      "resource": {"dashboard": 8},
      "params": {
        'email': Provider.of<Auth>(context, listen: false).user_email,
        'item_id': _selectedId,
      },
      // "exp": (DateTime.now().millisecondsSinceEpoch ~/ 1000) +
      //     (10 * 60) // 10 minute expiration
    });

    String token = payload.sign(SecretKey(METABASE_SECRET_KEY));

    String iframeUrl =
        '$METABASE_SITE_URL/embed/dashboard/$token#bordered=true&titled=false';

    print('iframe: $iframeUrl');

    return iframeUrl;
  }

  @override
  Widget build(BuildContext context) {
    // List<String> namesList =
    //     itemList.map((product) => product['NAME'] as String).toList();
    //  = itemList[0]['ID'];
    //  = namesList[0];
    return Scaffold(
      body: Column(
        children: [
          RefreshIndicator(
            onRefresh: _refreshFeed,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(children: [
                Space(7.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        TouchableOpacity(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                              top: 1.h,
                              bottom: 1.h,
                              right: 3.w,
                              left: 5.w,
                            ),
                            child: const Text(
                              '<<',
                              style: TextStyle(
                                color: Color(0xFFFA6E00),
                                fontSize: 24,
                                fontFamily: 'Kavoon',
                                fontWeight: FontWeight.w900,
                                height: 0.04,
                                letterSpacing: 0.66,
                              ),
                            ),
                          ),
                        ),
                        const Text(
                          'KPI',
                          style: TextStyle(
                            color: Color(0xFF094B60),
                            fontSize: 26,
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.w600,
                            height: 0.03,
                            letterSpacing: 0.78,
                          ),
                        )
                      ],
                    ),
                    Center(
                      child: DropdownButton<String>(
                        value: _selectedId,
                        onChanged: (value) {
                          setState(() {
                            _selectedId = value.toString();
                            String temp = _generateTokenAndLaunchDashboard();
                            _setWebviewController(temp);
                          });
                        },
                        underline:
                            Container(), // This line removes the bottom line
                        items: itemList
                            .map<DropdownMenuItem<String>>((dynamic mp) {
                          return DropdownMenuItem<String>(
                            value: mp['ID'],
                            child: Text(
                              mp['NAME'],
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF0A4C61),
                                  fontFamily: 'Product Sans',
                                  fontWeight: FontWeight.w400),
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  ],
                ),
                Space(3.h),
              ]),
            ),
          ),
          SizedBox(
              height: 84.h,
              // height: 80.h,
              child: WebViewWidget(controller: _iframeController)),
        ],
      ),
    );
  }
}
