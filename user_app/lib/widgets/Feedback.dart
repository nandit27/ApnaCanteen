import 'package:flutter/material.dart';
import 'package:user_app/global.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_app/widgets/BottomNavBarWidget.dart';

class FeedBack extends StatefulWidget {
  @override
  _BestFoodWidgetState createState() => _BestFoodWidgetState();
}

TextEditingController feedbackController = TextEditingController();

class _BestFoodWidgetState extends State<FeedBack> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feedback Form',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Center(
              child: Text(
            'Feedback',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          )),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  alignment: Alignment.center,
                  height: 150,
                  width: MediaQuery.of(context).size.width / 1.2,
                  child: TextFormField(
                    maxLines: null,
                    controller: feedbackController,
                    decoration: InputDecoration(
                      hintText: 'Feedback',
                      border: InputBorder.none,
                      fillColor: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border.all(
                      color: Colors.pink,
                      width: 1.0,
                    ),
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              SignInButtonWidget2(),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavBarWidget(),
      ),
    );
  }
}

class SignInButtonWidget2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0xFFfbab66),
          ),
          BoxShadow(
            color: Color(0xFFf7418c),
          ),
        ],
        gradient: LinearGradient(
            colors: [Color(0xFFf7418c), Color(0xFFfbab66)],
            begin: const FractionalOffset(0.2, 0.2),
            end: const FractionalOffset(1.0, 1.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp),
      ),
      child: MaterialButton(
          highlightColor: Colors.transparent,
          splashColor: Color(0xFFf7418c),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 32.0),
            child: Text(
              "SUBMIT",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontFamily: "WorkSansBold"),
            ),
          ),
          onPressed: () => {
                submitFeedback(),
              }),
    );
  }
}

submitFeedback() {
  print(feedbackController);
  FirebaseFirestore.instance
      .collection('feedback')
      .add({"feedback": feedbackController.text, "name": currentUser})
      .then((result) => {})
      .catchError((err) {
        print("Error submitting feedback: $err");
        return <String, dynamic>{};
      });
  feedbackController.clear();
}
