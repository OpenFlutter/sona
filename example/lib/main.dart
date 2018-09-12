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
  sona.Sona realSona = new sona.Sona();

  @override
  void initState() {
    super.initState();
    sona.register(sona.RegisterGetuiPushModel(
        appID: "your app id",
        appKey: "your app key",
        appSecret: "app secret"
    ));
//    sona.receivedMessageData.listen(_receiveData,onError: (error){
//      print("erro ");
//    },onDone: (){
//      print("done");
//    });

    realSona.receivedMessageData.listen(_receiveData,onError: (err){
      print("err");
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
