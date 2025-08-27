import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sorteos_app/config/constants/environment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const isPrd = bool.fromEnvironment("dart.vm.product");

  if (isPrd) {
    await Environment.initPrdEnvironment();
  } else {
    await Environment.initLocalEnvironment();
  }

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: Environment.apiKey,
      appId: Environment.appId,
      messagingSenderId: Environment.messagingSenderId,
      projectId: Environment.projectId,
    ),
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('Hello World!'))),
    );
  }
}
