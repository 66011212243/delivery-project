import 'package:flutter/material.dart';

class Ridersendorder extends StatefulWidget {
  String order_id;
  Ridersendorder({super.key, required this.order_id});

  @override
  State<Ridersendorder> createState() => _RidersendorderState();
}

class _RidersendorderState extends State<Ridersendorder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(widget.order_id)));
  }
}
