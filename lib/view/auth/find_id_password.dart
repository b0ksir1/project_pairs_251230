import 'package:flutter/material.dart';

class FindIdPassword extends StatefulWidget {
  const FindIdPassword({super.key});

  @override
  State<FindIdPassword> createState() => _FindIdPasswordState();
}

class _FindIdPasswordState extends State<FindIdPassword> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text('FindIdPassword')),
    );
  }
}