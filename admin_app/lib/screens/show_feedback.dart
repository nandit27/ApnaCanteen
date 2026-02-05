import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShowFeedback extends StatefulWidget {
  ShowFeedback();

  @override
  VideoScreenState createState() => VideoScreenState();
}

class VideoScreenState extends State<ShowFeedback> {
  VideoScreenState();

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('feedback').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      "Feedback",
                      style:
                          TextStyle(fontSize: 40, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    // height: MediaQuery.of(context).size.height,
                    child: ListView(
                      children: snapshot.data!.docs.map((document) {
                        return Container(
                          width: MediaQuery.of(context).size.width / 1.2,
                          // height: MediaQuery.of(context).size.height / 2,
                          child: Container(
                            margin: EdgeInsets.all(8),
                            height: 100,
                            child: Column(
                              children: [
                                Expanded(
                                  child: Text(
                                    document['name'],
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                                Expanded(child: Text('\n')),
                                Expanded(
                                  child: Text(
                                    document['feedback'],
                                    style: TextStyle(fontSize: 20),
                                  ),
                                )
                              ],
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
