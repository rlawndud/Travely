import 'package:flutter/material.dart';
import 'package:test2/value/global_variable.dart';

void showSnackBar(String message, Color? color){
  final globalContext = GlobalVariable.globalScaffoldMessengerKey.currentState;

  if(globalContext!=null){
    if(color!=null){
      globalContext.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
        ),
      );
    }else if(color == null){
      globalContext.showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
  }
}