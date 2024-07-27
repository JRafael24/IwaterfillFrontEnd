import 'package:flutter/material.dart';
import 'package:iwaterfill/screens/buywater.dart';
import 'package:iwaterfill/screens/login.dart';
import 'package:iwaterfill/screens/profile.dart';
import 'package:iwaterfill/screens/refill.dart';
import 'package:iwaterfill/screens/signup.dart';
import 'package:iwaterfill/screens/dashboard.dart';
import 'package:iwaterfill/screens/transactionhistory.dart';



void main() => runApp(MaterialApp(

  initialRoute: '/login',
  routes: {
    '/dashboard' : (context) => Dashboard(),
    '/signup' : (context) => Signup(),
    '/login' : (context) => Login(),
    '/buywater' : (context) => BuyWater(),
    '/transactionhistory' : (context) => TransactionHistory(),
    '/refill' : (context) => Refill(),
    '/profile' : (context) => Profile(),

   

  },
));

