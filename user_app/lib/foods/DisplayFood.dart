//import 'dart:html';

import 'package:user_app/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_app/global.dart';

class ShowCategory extends StatefulWidget {
  ShowCategory();
  @override
  VideoScreenState createState() => VideoScreenState();
}

int _defaultValue = 1;
TextEditingController val = TextEditingController(text: "1");

class VideoScreenState extends State<ShowCategory> {
  VideoScreenState();

  void _increment() {
    if (_defaultValue <= 50) {
      setState(() {
        val.text = (int.parse(val.text.toString()) + 1).toString();
        _defaultValue++;
      });
    }
  }

  void _decrement() {
    if (_defaultValue > 1) {
      setState(() {
        val.text = (int.parse(val.text.toString()) - 1).toString();
        _defaultValue--;
      });
    }
  }

  Widget build(BuildContext context) {
    return Container(
      height: 270,
      child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView(
              scrollDirection: Axis.horizontal,
              children: snapshot.data!.docs.map((document) {
                if (document['available'] == 'N') {
                  return Center(
                    child: Container(
                      height: 0,
                      width: 0,
                    ),
                  );
                }
                return Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(
                          left: 10, right: 5, top: 5, bottom: 5),
                      decoration: BoxDecoration(boxShadow: []),
                      child: Card(
                        color: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(5.0),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Center(
                          child: Image.network(
                        document['images'][0].toString(),
                        width: 130,
                        height: 100,
                      )),
                    ),
                    ElevatedButton(
                        child: Text("add to cart"),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0))),
                                child: Container(
                                  height: 300,
                                  child: Column(
                                    children: <Widget>[
                                      Padding(padding: EdgeInsets.all(30)),
                                      Text(
                                        "Name: " + document['name'].toString(),
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Text(
                                        "Price: " + document['price'].toString(),
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Text(
                                        "Quantity:",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Container(
                                                width: 35,
                                                height: 35,
                                                child: FloatingActionButton(
                                                  onPressed: _decrement,
                                                  child: Icon(
                                                    Icons.remove,
                                                    color: Colors.black,
                                                  ),
                                                  backgroundColor: Colors.white,
                                                ),
                                              ),
                                              Container(
                                                  width: 20,
                                                  height: 10,
                                                  child: TextField(
                                                    controller: val,
                                                  )),
                                              Container(
                                                width: 35,
                                                height: 35,
                                                child: FloatingActionButton(
                                                  onPressed: _increment,
                                                  child: Icon(Icons.add,
                                                      color: Colors.black),
                                                  backgroundColor: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors.blueAccent,
                                          ),
                                          child: Text(
                                            "Add",
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          onPressed: () {
                                            addToCart(document['name'],
                                                document['price'], context);

                                            _defaultValue = 1;
                                            val.text = "1";
                                          }),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.bottomLeft,
                          padding: EdgeInsets.only(left: 5, top: 5),
                          child: Text(document['name'],
                              style: TextStyle(
                                  color: Color(0xFF6e6e71),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.bottomLeft,
                          padding: EdgeInsets.only(left: 5, top: 5, right: 5),
                          child: Text('Rs. ' + document['price'].toString(),
                              style: TextStyle(
                                  color: Color(0xFF6e6e71),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ],
                );
              }).toList(),
            );
          }),
    );
  }
}

void addToCart(var name, var price, context) {
  print(_defaultValue);
  quantity.add(int.parse(_defaultValue.toString()));
  items.add(name);
  print(price);
  prices.add(double.parse(price.toString()));
  print(quantity.length);
  print(items.length);
  total = calculateTotal();
  reload(context);
}

void reload(context) {
  print("reload");
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => HomePage()),
  );
}
