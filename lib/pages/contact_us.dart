import 'package:flutter/material.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact Us",
         style: TextStyle(fontWeight: FontWeight.w600),),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,

      )
      ,);
  }
}