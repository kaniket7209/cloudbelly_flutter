import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/screens/Login/map.dart';
import 'package:cloudbelly_app/screens/Tabs/Cart/view_cart.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/graphs.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/post_screen.dart';
import 'package:cloudbelly_app/screens/Tabs/tabs.dart';

import 'package:cloudbelly_app/screens/Login/login_screen.dart';
import 'package:cloudbelly_app/screens/Login/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(

  //     // options: DefaultFirebaseOptions.currentPlatform,
  //     );
  // initDynamicLinks();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => Auth()),
  ], child: const MyApp()));
}

// void initDynamicLinks() async {
//   FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
//     _handleDeepLink(dynamicLinkData.link);
//   }).onError((error) {
//     // Handle errors
//     print('Dynamic Link Failed: $error');
//   });

//   final data = await FirebaseDynamicLinks.instance.getInitialLink();
//   final Uri deepLink = data!.link;
//   _handleDeepLink(deepLink);
// }

// void _handleDeepLink(Uri deepLink) {
//   if (deepLink != null) {
//     // if (deepLink.pathSegments.contains('userProfile')) {
//     final String? userId = deepLink.queryParameters['id'];
//     if (userId != null) {
//       // Use navigatorKey to navigate without context
//       navigatorKey.currentState!.push(MaterialPageRoute(
//         builder: (context) {
//           return Profile();
//         },
//       ));
//     }
//     // }
//   }
// }

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return ResponsiveSizer(builder: (context, orientation, screenType) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (ctx) => Auth(),
          ),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'CloudBelly',
            theme: ThemeData(
              scrollbarTheme: ScrollbarThemeData(
                thumbColor: MaterialStateProperty.all<Color>(Color(0xFFFA6E00)),
                trackColor: MaterialStateProperty.all<Color>(
                    Color.fromRGBO(177, 217, 216, 1)),
              ),
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
              useMaterial3: true,
            ),
            initialRoute: WelcomeScreen.routeName,
            routes: {
              LoginScreen.routeName: (context) => LoginScreen(),
              '/map': (context) => MapScreen(),
              WelcomeScreen.routeName: (context) => WelcomeScreen(),
              Tabs.routeName: (context) => Tabs(),
              PostsScreen.routeName: (context) => PostsScreen(),
              GraphsScreen.routeName: (context) => GraphsScreen(),
              ViewCart.routeName: (context) => ViewCart(),
            },
          ),
        ),
      );
    });
  }
}
