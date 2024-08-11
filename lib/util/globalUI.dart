import 'package:flutter/material.dart';
import 'package:test2/value/global_variable.dart';

final globalContext = GlobalScaffoldMessenger.globalScaffoldKey;

void showSnackBar(String message, Color? color){

  if(color!=null){
    globalContext.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }else if(color == null){
    globalContext.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}