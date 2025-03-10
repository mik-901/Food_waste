import 'package:capstone/screens/Loginpage.dart';
import 'package:flutter/material.dart';
import 'Loginpage.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  await Tflite.loadModel(model: ''); // Load TFLite model
  runApp(const MyApp());
}
Future<void> loadModel(dynamic Tflite) async {
  await Tflite.loadModel(
    model: "assets/model.tflite",
    labels: "assets/labels.txt",
  );

}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Wastage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(), // Start with the login page
    );
  }
}