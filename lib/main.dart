import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/screens/Login/map.dart';
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
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => Auth()),
  ], child: const MyApp()));
}

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
            debugShowCheckedModeBanner: false,
            title: 'CloudBelly',
            theme: ThemeData(
              scrollbarTheme: ScrollbarThemeData(
                thumbColor: MaterialStateProperty.all<Color>(Color(0xFFFA6E00)),
                trackColor: MaterialStateProperty.all<Color>(
                    Color.fromRGBO(177, 217, 216, 1)),
              ),
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
            },
          ),
        ),
      );
    });
  }
}
