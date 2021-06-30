import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(MyApp());
}

class Fcm {
  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) {
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
    }

    // Or do other work.
  }
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  String _message = '';

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid;
  var initializationSettingsIOS;
  var initializationSettings;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    initializeNotification();
    getMessage();
  }

  void initializeNotification() async {
    try {
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      var initializationSettingsAndroid =
          AndroidInitializationSettings('app_icon');
      var initializationSettingsIOS = IOSInitializationSettings();
      var initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: onSelectNotification);
    } catch (e) {
      print(e.toString());
    }
  }

  //get token of app
  _register() {
    _firebaseMessaging.getToken().then((token) => print(token));
  }

  void _showNotification({String title, String msg}) async {
    await _demoNotification(title: title, msg: msg);
  }

  Future<void> _demoNotification(
      {String title = "Hello, buddy",
      msg = 'A message from flutter buddy'}) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'channel_ID', 'channel name', 'channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'test ticker');

    var iOSChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSChannelSpecifics);

    await flutterLocalNotificationsPlugin
        .show(0, title, msg, platformChannelSpecifics, payload: 'test oayload');
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('Notification payload: $payload');
    }
    // await Navigator.push(context,
    //     new MaterialPageRoute(builder: (context) => new SecondRoute()));
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: <Widget>[
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              // Navigator.of(context, rootNavigator: true).pop();
              // await Navigator.push(context,
              //     MaterialPageRoute(builder: (context) => SecondRoute()));
            },
          )
        ],
      ),
    );
  }

  void getMessage() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
        setState(() {
          _message = message["notification"]["title"];
          _showNotification(
              title: message["notification"]["title"],
              msg: message["notification"]["body"]);
        });
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
        setState(() {
          _message = message["notification"]["title"];
          _showNotification(
              title: message["notification"]["title"],
              msg: message["notification"]["body"]);
        });
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
        setState(() {
          _message = message["notification"]["title"];
          _showNotification(
              title: message["notification"]["title"],
              msg: message["notification"]["body"]);
        });
      },
      onBackgroundMessage: Fcm.myBackgroundMessageHandler,
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Message: $_message"),
                OutlineButton(
                  child: Text("Register My Device"),
                  onPressed: () {
                    _register();
                  },
                ),
                // Text("Message: $message")
              ]),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showNotification,
          tooltip: 'Increment',
          child: Icon(Icons.notifications),
        ),
      ),
    );
  }
}
