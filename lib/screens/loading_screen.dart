import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  final String message;
  final Future<void> Function() loadData;
  final Widget nextScreen;
  const LoadingScreen({super.key, required this.message, required this.loadData, required this.nextScreen});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late String _displayMsg = widget.message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}
