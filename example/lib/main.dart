import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:sona/sona.dart' as sona;

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _result = 'Unknown';


  @override
  void initState() {
    super.initState();
    sona.register(
        appID: "your app id",
        appKey: "your app key",
        appSecret: "app secret"
    ).then((data){
      print(data.runtimeType.toString());
    });
    sona.receivedMessageData.listen(_receiveData,onError: (error){
      print("erro ");
    },onDone: (){
      print("done");
    });



  }


  _receiveData(dynamic data){

    setState(() {
      _result = data.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: new Center(
          child: new Text('messge: $_result\n'),
        ),
      ),
    );
  }
}
