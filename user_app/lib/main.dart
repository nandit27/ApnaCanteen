import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:user_app/authenticate/AuthScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  var state = "true";
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "",
        appId: "",
        messagingSenderId: "484592064169",
        projectId: "",
        storageBucket: "",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  FirebaseFirestore.instance
      .collection("startstop")
      .doc("nsbLA2tTBDx1N02rwxn6")
      .get()
      .then((value) {
    state = value.data()?['value']?.toString() ?? "true";
    print(state);
    if (state == "true") {
      runApp(MyApp());
    } else {
      runApp(closed());
    }
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto'),
      home: AuthScreen(),
    );
  }
}

class closed extends StatefulWidget {
  @override
  _closedState createState() => _closedState();
}

class _closedState extends State<closed> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  height: 200,
                  width: 300,
                  child: Image.asset(
                    'assets/images/closeddown.jpg',
                    height: 200,
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                "The canteen is closed",
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
