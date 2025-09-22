//
//  main.dart
//  Blaink Flutter Example
//
//  Prompted by Raşid Ramazanov using Cursor on 21.09.2025.
//

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:blaink_flutter/blaink_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blaink Flutter Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Blaink Flutter Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> implements BlainkDelegate {
  String _status = 'Not initialized';
  String? _userId;
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _initializeBlaink();
    _setupFCM();
  }

  void _initializeBlaink() {
    Blaink.setDelegate(this);
    
    Blaink.setup(
      sdkKey: "eyJwbCI6IjEyQjE1RUQ1LTBBNzAtNDU2QS05RjRFLTlFQUNBMDk2QTEwQiJ9",
      environment: PushEnvironment.development,
      isDebugLogsEnabled: true,
    ).then((_) {
      setState(() {
        _status = 'Initialized';
      });
    }).catchError((error) {
      setState(() {
        _status = 'Initialization failed: $error';
      });
    });
  }

  void _setupFCM() {
    FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        _fcmToken = token;
      });
      
      if (token != null) {
        Blaink.registerForRemoteNotifications(token);
      }
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      setState(() {
        _fcmToken = newToken;
      });
      Blaink.registerForRemoteNotifications(newToken);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Status: $_status',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            if (_userId != null)
              Text(
                'User ID: $_userId',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            const SizedBox(height: 16),
            if (_fcmToken != null)
              Text(
                'FCM Token: ${_fcmToken!.substring(0, 20)}...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _updateUser,
              child: const Text('Update User'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _getCurrentUser,
              child: const Text('Get Current User'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateUser() {
    Blaink.updateUser(
      firstName: 'John',
      lastName: 'Doe',
      email: 'john.doe@example.com',
      phone: '+1234567890',
    );
  }

  void _getCurrentUser() async {
    final userId = await Blaink.getCurrentUser();
    setState(() {
      _userId = userId;
    });
  }

  // MARK: - BlainkDelegate

  @override
  void didReceiveNotification(Map<String, String> payload) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Received notification: ${payload.toString()}')),
    );
  }

  @override
  void didRegisterForBlainkNotifications(String userId) {
    setState(() {
      _userId = userId;
      _status = 'Registered successfully';
    });
  }

  @override
  void didFailToRegisterForBlainkNotifications(String error) {
    setState(() {
      _status = 'Registration failed: $error';
    });
  }

  @override
  void didRefreshFCMToken(String newToken) {
    setState(() {
      _fcmToken = newToken;
    });
    Blaink.registerForRemoteNotifications(newToken);
  }
}