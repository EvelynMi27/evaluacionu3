import 'package:flutter/material.dart';
import 'login.dart';
import 'paquetes.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paquexpress',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/':(context)=>const Login(),
        '/ver_paquetes':(context)=>const VerPaquetes(),
      },
    );
  }
}

