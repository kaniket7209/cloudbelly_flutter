import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;  // Add this to your pubspec.yaml
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloudbelly_app/screens/Login/commonLoginScreen.dart';
import 'package:cloudbelly_app/screens/Tabs/tabs.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomeScreen extends StatefulWidget {
  static const routeName = '/welcome-screen';

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  Future<String> _getVersionFromLocalProperties() async {
    try {
      final file = File('android/local.properties');
      final properties = file.readAsStringSync();
      final versionNameMatch = RegExp(r'flutter\.versionName=(.+)').firstMatch(properties);
      final versionName = versionNameMatch?.group(1);

      return versionName ?? '';
    } catch (e) {
      print('Error reading local.properties: $e');
      return '';
    }
  }

  Future<void> _checkForUpdates() async {
    try {
      // Attempt to get version from PackageInfo first
      String currentVersion = '';

      try {
        final packageInfo = await PackageInfo.fromPlatform();
        currentVersion = packageInfo.version;
      } catch (e) {
        print('Failed to get version from PackageInfo: $e');
      }

      // If still empty, try reading from local.properties
      if (currentVersion.isEmpty) {
        currentVersion = await _getVersionFromLocalProperties();
      }

      if (currentVersion.isEmpty) {
        _checkLoginStatus();
        return;
      }

      print("Current Version: $currentVersion  New Version: ");
      final newVersion = await _getLatestVersionFromAPI();

      if (_isNewVersionAvailable(currentVersion, newVersion)) {
        _showUpdateDialog();
      } else {
        _checkLoginStatus();
      }
    } catch (e) {
      print('Error checking for updates: $e');
      _checkLoginStatus();
    }
  }

Future<String> _getLatestVersionFromAPI() async {
  final url = 'https://app.cloudbelly.in/version';
  try {
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['version'];
    } else {
      throw Exception('Failed to load version info from API');

    }
  } catch (e) {
    print('Error fetching version from API: $e');
    throw Exception('Failed to fetch the latest version from API');
  }
}
 
  bool _isNewVersionAvailable(String currentVersion, String newVersion) {
    final current = currentVersion.split('.').map(int.parse).toList();
    final latest = newVersion.split('.').map(int.parse).toList();
    print("Latest Version: $latest  Current Version: $current");
    for (var i = 0; i < latest.length; i++) {
      if (latest[i] > current[i]) return true;
      if (latest[i] < current[i]) return false;
    }
    return false;
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Available'),
          content: Text(
              'A new version of the app is available. Please update to continue.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _checkLoginStatus();
              },
              child: Text('No Thanks'),
            ),
            ElevatedButton(
              onPressed: () async {
                final url = Uri.parse(
                    'https://play.google.com/store/apps/details?id=com.app.cloudbelly_app');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  print('Could not launch $url');
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userData')) {
      Navigator.of(context).pushReplacementNamed(Tabs.routeName);
    } else {
      Navigator.of(context).pushReplacementNamed(CommonLoginScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          child:  Image.asset('assets/images/cloudbelly_logo.png',
                  width: 500, height: 500),
         
          
        ),
      ),
    );
  }
}