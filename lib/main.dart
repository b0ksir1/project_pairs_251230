import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:project_pairs_251230/firebase_options.dart';
import 'package:project_pairs_251230/view/product/main_page.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async  {
  WidgetsFlutterBinding.ensureInitialized();
  // public 신용카드 결제키
  Stripe.publishableKey = "pk_test_51SlPLl2Ypir8wPmXWCoQI5sqxtrBTMWLZsEvbsoPiGX1oNWUi9ALh0K4KtkSffV5NVvL6CEezRfGQjhz3EQGQqr900CDFWlj5r";
  await Stripe.instance.applySettings();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: const MainPage(),
    );
  }
}
